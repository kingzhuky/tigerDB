library(jsonlite)
library(data.table)
library(dplyr)
library(gtools)
library(survival)
library(survminer)
library(rlist)
my36colors <-c('#D6E7A3',"orange1", 'lightblue','#7142AC',"darkcyan","royalblue1","red3",'#53A85F',"deeppink",
               "mediumvioletred","gold","darkorange2", "tan2","darkorange2","darkorchid","chocolate4","darkred","lightskyblue","gold1")
mytheme <- theme_bw() + 
  theme(plot.title=element_text(size=rel(2),hjust=0.5),
        axis.title=element_text(size=rel(1)),
        axis.text.x = element_text(angle=0,hjust=0.5, vjust=0.5,size = rel(1.2),color="black"),
        axis.text.y = element_text(angle=0,hjust=1, vjust=0.5,size = rel(1.2),color="black"),
        panel.grid.major=element_line(color="grey96"),
        panel.grid.minor=element_line(color="grey96"),
        panel.border=element_rect(color="black",size=1),
        axis.line=element_line(color="black",size=0.5))

Args <- commandArgs(T)
# Args <- c("CD274,CD3D","SIG1","Melanoma-GSE100797_ACT")
# Args <- c("CD274,CD3D","SIG1","Melanoma-PRJEB23709_anti-CTLA-4+anti-PD-1_Female")
gene <- unlist(strsplit(Args[1],split=','))
sigid <- Args[2]
mergedatasets <- Args[3]


maintitle1 <- paste(paste(gene,collapse = "_"),paste(mergedatasets,collapse = "_"),
                    "dot",sep="-")
maintitle2 <- paste(sigid,paste(mergedatasets,collapse = "_"),
                    "km",sep="-")
if(nchar(maintitle1) > 200) {
  maintitle1 <- paste("longSig",
                      "sigsurv-dotplot",sep="-")
  maintitle2 <- paste("longSig",
                      "sigsurv-kmplot",sep="-")
}

normalMed <- ""
loading.data.path <- "Response_data/"
result.path <- "./img/"
load(paste0(loading.data.path,"ResponseData.RData"))
title.gene <- "Custom Geneset"

## generate survival matrix
GenerateTCGASigScore <- function(exp.table,sig.weighted.mat){
  tmp.table <- exp.table[sig.weighted.mat[,.(GENE_SYMBOL)], on= c("GENE_SYMBOL"), nomatch = F]
  sig.weighted.mat <- sig.weighted.mat[tmp.table[,.(GENE_SYMBOL)], on= c("GENE_SYMBOL"), nomatch = F]
  SIG.score.seplist <- lapply(sig.weighted.mat[,-c("GENE_SYMBOL")], function(x){tmp.table[,lapply(.SD,weighted.mean,w=x), .SDcols=-c("GENE_SYMBOL")]})
}

surv.sample.info <- sample.info[!is.na(`overall survival (days)`),]
colnames(surv.sample.info)[c(9,10)] <- c("Overall_survival_days","Status")
surv.sample.info$Status <- ifelse(surv.sample.info$Status == "Dead", 1, 0)
exp.cutoff <- 0.5
SIG.mat <- readRDS("Signature_data/SIG.mat.RDS")
SIG.matrix <- SIG.mat[,lapply(.SD, as.numeric),by = c("GENE_SYMBOL")]
# if(!file.exists(paste0(result.path,maintitle,".json")) | nchar(maintitle1) > 200 ){
  exp.mergearray <- NULL
  exp.table <- readRDS(paste0(loading.data.path,mergedatasets,".Response.Rds"))
  exp.array <- exp.table[GENE_SYMBOL %in% c(gene)]
  exp.array$score_group <- ifelse(exp.array[,GENE_SYMBOL] %in% gene, "CustomGene","NormalGene")
  exp.array <- exp.array[,lapply(.SD, function(x){mean(x,na.rm = TRUE)}), by = c("score_group") , .SDcols = -c("GENE_SYMBOL")] # Weighted gene = 1
  exp.array <- data.frame(row.names = exp.array[,score_group],exp.array[,-c("score_group")])
  exp.mergearray <- rbind(exp.mergearray,t(exp.array))
  exp.mergearray <- data.table(sample_id = rownames(exp.mergearray), exp.mergearray)
  exp.mergearray$sample_id <- gsub("^X", "", exp.mergearray$sample_id)
  plot.data <- exp.mergearray[sample.info[,c(1,9,10)], on = c("sample_id"), nomatch = F]
  plot.data <- plot.data[,lapply(.SD, function(x)x[1]), by = c("sample_id")] ## remove same samples
  colnames(plot.data)[seq(ncol(plot.data)-1,ncol(plot.data))] <- c("Overall_survival_days","Status")
  plot.data$Status <- ifelse(plot.data$Status == "Dead", 1, 0)
  if( sum(!is.na(plot.data$Overall_survival_days)) < 3 ){
    hr.p.pscore <- "0_0_0"
  }else{
    if (normalMed == "gene"){
      plot.data$gene.exp <- plot.data[,CustomGene]/plot.data[,NormalGene]
      plot.data <- plot.data[abs(gene.exp) != Inf,] ## delete nonsense values
    }else{
      plot.data$gene.exp <- plot.data[,CustomGene]
    }
    surv.plot.data <- plot.data[!is.na(plot.data$Overall_survival_days),]
    order.index <-  order(surv.plot.data$gene.exp,decreasing = T)
    up.index <- order.index[seq(1,round(nrow(surv.plot.data)*exp.cutoff))]
    down.index <- order.index[seq(round(nrow(surv.plot.data)*(1-exp.cutoff))+1,nrow(surv.plot.data))]
    surv.plot.data$group <- "0"
    surv.plot.data[up.index,"group"] <- "Custom_high"
    surv.plot.data[down.index,"group"] <- "Custom_low"
    surv.plot.data <- subset(surv.plot.data,group != "0")
    surv.plot.data$group <- factor(surv.plot.data$group)
    cox.res <- coxph(Surv(as.numeric(Overall_survival_days),Status)~group,data =surv.plot.data)
    cox.res <- summary(cox.res)
    tmp.res <- cox.res$coefficients[c(2,5)]
    tmp.res[3] <- round(sign(log(tmp.res[1],2)) * -log10(tmp.res[2]),3)
    hr.p.pscore <- paste(round(tmp.res,4),collapse = "_")
  }
  hrp.data <- melt(surv.zscore.table[,c("signature",..mergedatasets)],id = c("signature"))
  hrp.data[,variable := NULL]
  hr.p.data.table <- rbind(data.table(signature = title.gene, value = hr.p.pscore),hrp.data)
  hr.data.table <- hr.p.data.table[,lapply(.SD, function(x){strsplit(x,"_")[[1]][1]}), by=c("signature")]
  p.data.table <- hr.p.data.table[,lapply(.SD, function(x){strsplit(x,"_")[[1]][2]}), by=c("signature")]
  hr.p.plot.data <- hr.data.table[p.data.table, on=c("signature")]
  setnames(hr.p.plot.data,c("signature","hr","p"))
  hr.p.plot.data <- hr.p.plot.data[,lapply(.SD, as.numeric),by = c("signature")]
  hr.p.plot.data <- hr.p.plot.data[rbind(data.table(SignatureID = "Custom Geneset", SignatureName = "Custom Geneset"), SIG.info[,.(SignatureID,SignatureName)]), on = c("signature" = "SignatureID"), nomatch = FALSE]
  dot.plot <- ggplot(na.omit(hr.p.plot.data), aes(x = hr, y = -log(p,10), color = SignatureName)) + 
    geom_point(size = 6) + mytheme +
    scale_color_manual(values = my36colors)
  SIG.score.response.seplist <- GenerateTCGASigScore(exp.table,SIG.matrix)
  SIG.score.list <- list.rbind(SIG.score.response.seplist) %>% data.frame(row.names = names(SIG.score.response.seplist), .) %>% t() %>% data.table(sample_id = row.names(.), .)
  SIG.score.list$sample_id <- gsub("^X", "", SIG.score.list[,sample_id])
  SIG.score.plot.data <- merge(SIG.score.list,plot.data,by = "sample_id",all.y = T)
  setnames(SIG.score.plot.data,"gene.exp",title.gene)
  keep.col <- c("sample_id",sigid,"Overall_survival_days","Status")
  surv.plot.data <- SIG.score.plot.data[,..keep.col]
  if(sigid %in% SIG.info$SignatureID){
    signame <- SIG.info[SignatureID == sigid][["SignatureName"]]
  }else{
    signame <- sigid
  }
  setnames(surv.plot.data, sigid, "gene.exp")
  surv.plot.data <- surv.plot.data[!is.na(plot.data$Overall_survival_days),]
  order.index <-  order(surv.plot.data$gene.exp,decreasing = T)
  up.index <- order.index[seq(1,round(nrow(surv.plot.data)*exp.cutoff))]
  down.index <- order.index[seq(round(nrow(surv.plot.data)*(1-exp.cutoff))+1,nrow(surv.plot.data))]
  surv.plot.data$group <- "0"
  surv.plot.data[up.index,"group"] <- "Custom_high"
  surv.plot.data[down.index,"group"] <- "Custom_low"
  surv.plot.data <- subset(surv.plot.data,group != "0")
  surv.plot.data$group <- factor(surv.plot.data$group)
  sfit <- surv_fit(Surv(as.numeric(Overall_survival_days),Status)~group,data=surv.plot.data)
  surv.plot <- ggsurvplot(sfit, conf.int = TRUE, pval = TRUE, risk.table = TRUE,
                                   legend.labs = c("High", "Low"), legend.title = signame,
                                   xlab = "Time (Days)",
                                   palette = c("dodgerblue2", "orchid2"),
                                   risk.table.height = 0.3,
                                   ggtheme = theme_bw() + 
                                     theme(text = element_text(size = 15),
                                           plot.title = element_text(size = 20, hjust = 0.5),
                                           axis.text = element_text(color = "black")))

# }
  filename = paste0(result.path,maintitle1,".png")
  filename2 = paste0(result.path,maintitle2,".png")
  ggsave(filename = filename, plot = dot.plot, width = 300, height =120, unit = "mm", dpi=100)
  # if(datatype == "png"){
    png(file=filename2)
    print(surv.plot)
    dev.off()
  # }else{
  #   pdf(file=paste0(result.path,maintitle1,".pdf"))
  #   print(response.surv.plot)
  #   dev.off()
  # }
cat(paste(maintitle1,maintitle2,sep = ","))
