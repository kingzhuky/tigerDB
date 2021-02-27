library(jsonlite)
library(data.table)
library(dplyr)
library(gtools)
library(pROC)
library(jsonlite)
library(survival)
library(survminer)
library(plotROC)
colors=c("#cc4a5399",'#00ADDB99','#7142AC99',"#42B54099",'#00008099','#07702b99',"#7FFF0099","#AD002A","#ED000099",'#ABD20599','#F0BE7E','#4D221399',"#FDAF9199",'#85E1D099','#C979CD99','#F26A1299',"#ADB6B699",'#4B79AB99',"#0099B499",'#FF149399','#00800099',"#1B191999")
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
Args <- c("CD274,CD3D","SIG1","Melanoma-GSE100797_ACT")
gene <- unlist(strsplit(Args[1],split=','))
sigid <- Args[2]
mergedatasets <- Args[3]


maintitle1 <- paste(paste(gene,collapse = "_"),paste(mergedatasets,collapse = "_"),
                    "bar",sep="-")
maintitle2 <- paste(sigid,paste(mergedatasets,collapse = "_"),
                    "roc",sep="-")
if(nchar(maintitle1) > 200) {
  maintitle1 <- paste("longSig",
                      "response-barplot",sep="-")
  maintitle2 <- paste("longSig",
                      "response-rocplot",sep="-")
}

normalMed <- ""
loading.data.path <- "Response_data/"
result.path <- "./img/"
load(paste0(loading.data.path,"ResponseData.RData"))
SIG.mat <- readRDS("Signature_data/SIG.mat.RDS")
SIG.matrix <- SIG.mat[,lapply(.SD, as.numeric),by = c("GENE_SYMBOL")]
title.gene <- "Custom Geneset"
# if(!file.exists(paste0(result.path,maintitle,".json")) | nchar(maintitle1) > 200 ){
exp.mergearray <- NULL
exp.table <- readRDS(paste0(loading.data.path,sl.dataset,".Response.Rds"))
exp.array <- exp.table[GENE_SYMBOL %in% c(gene)]
exp.array$score_group <- ifelse(exp.array[,GENE_SYMBOL] %in% gene, "CustomGene","NormalGene")
exp.array <- exp.array[,lapply(.SD, mean), by = c("score_group") , .SDcols = -c("GENE_SYMBOL")] # Weighted gene = 1
exp.array <- data.frame(row.names = exp.array[,score_group],exp.array[,-c("score_group")])
exp.mergearray <- rbind(exp.mergearray,t(exp.array))
exp.mergearray <- data.table(sample_id = rownames(exp.mergearray), exp.mergearray)
exp.mergearray$sample_id <- gsub("^X", "", exp.mergearray$sample_id)
if(nrow(na.omit(exp.mergearray)) > 3){
  plot.data <- exp.mergearray[sample.info[,.(sample_id,response_NR)], on = c("sample_id"),nomatch = F]
  plot.data <- plot.data[,lapply(.SD, function(x)x[1]), by = c("sample_id")] ## remove same samples
  if (normalMed == "gene"){
    plot.data$gene.exp <- plot.data[,CustomGene]/plot.data[,NormalGene]
    plot.data <- plot.data[abs(gene.exp) != Inf,] ## delete nonsense values
  }else{
    plot.data$gene.exp <- plot.data[,CustomGene]
  }
  plot.data$group <- plot.data$response_NR
  plot.data$group[plot.data$response_NR %in% c("R","MR")] <- "Responder (R)"
  plot.data$group[plot.data$response_NR %in% c("N","NR","Resistance","NE")] <- "Non-Responder (NR)"
  plot.data <- plot.data[plot.data$group %in% c("Non-Responder (NR)","Responder (R)"),]
  roc.data <- roc(factor(plot.data[,group],levels = c("Responder (R)","Non-Responder (NR)")),plot.data[,gene.exp],levels=c("Responder (R)","Non-Responder (NR)"))
  auc.score <- auc(roc.data)[1]
}else{
  auc.score <- 0
}
auc.data <- melt(auc.data.list[,c("group",..mergedatasets[-2])],id = c("group"))
auc.data.mean <- auc.data[, lapply(.SD, mean), by = group, .SDcols = c("value")] # merge dataset
auc.plot.data <- rbind(data.table(group = title.gene, value = auc.score),auc.data.mean)
names(auc.plot.data)[2] <- "AUC" 
auc.table <- SIG.info[,c("SignatureID","SignatureName")][auc.plot.data, on = c("SignatureID" = "group"),nomatch = NA]
auc.table[1,"SignatureName"] <- title.gene
colnames(auc.table)[c(1:2)] <- c("signature_id","Signature_Name")
bar.plot <- ggplot(na.omit(auc.table),aes(x = Signature_Name, y = AUC, fill = Signature_Name)) + 
  geom_bar(stat = 'identity', position = 'dodge', width = 0.7) + mytheme +
  scale_fill_manual(values = my36colors[1:20]) +
  geom_text(mapping = aes(label = round(AUC,2))) + 
  coord_flip() + theme(legend.position='none') + ylab("AUC") + xlab("")

GenerateTCGASigScore <- function(exp.table,sig.weighted.mat){
  tmp.table <- exp.table[sig.weighted.mat[,.(GENE_SYMBOL)], on= c("GENE_SYMBOL"), nomatch = F]
  sig.weighted.mat <- sig.weighted.mat[tmp.table[,.(GENE_SYMBOL)], on= c("GENE_SYMBOL"), nomatch = F]
  SIG.score.seplist <- lapply(sig.weighted.mat[,-c("GENE_SYMBOL")], function(x){tmp.table[,lapply(.SD,weighted.mean,w=x), .SDcols=-c("GENE_SYMBOL")]})
}
system.time(
  SIG.score.response.seplist <- GenerateTCGASigScore(exp.table,SIG.matrix)
)
SIG.score.list <- list.rbind(SIG.score.response.seplist) %>% data.frame(row.names = names(SIG.score.response.seplist), .) %>% t() %>% data.table(sample_id = row.names(.), .)
SIG.score.list$sample_id <- gsub("^X", "", SIG.score.list[,sample_id])
SIG.score.plot.data <- merge(SIG.score.list,plot.data,by = "sample_id",all.y = T)
setnames(SIG.score.plot.data,"gene.exp",title.gene)
keep.col <- c(sigid,"group")
roc.plot.data <- melt(SIG.score.plot.data[,..keep.col], "group", variable.name = "sigid", value.name = "AUC")
if(sigid %in% SIG.info$SignatureID){
  signame <- SIG.info[SignatureID == sigid][["SignatureName"]]
}else{
  signame <- sigid
}

p <- ggplot(roc.plot.data, aes(d = group, m = AUC)) +
  geom_roc(show.legend = TRUE, labels=FALSE,pointsize = 0)+ ggpubr::theme_classic2() +
  scale_color_manual(values = my36colors[1:20]) + xlab("1 - Specificity") + ylab("Sensitivity") + 
  scale_x_continuous(expand = c(0, 0)) + scale_y_continuous(expand = c(0, 0))
auc <- calc_auc(p)$AUC
roc.plot <- p + annotate("text", x = .75, y = .25, 
                         label = paste0(signame, paste(" AUC =", round(auc, 3), "\n"),collapse = ""),
                         size = 4)
# }
filename = paste0(result.path,maintitle1,".png")
filename2 = paste0(result.path,maintitle2,".png")
ggsave(filename = filename, plot = bar.plot, width = 300, height =120, unit = "mm", dpi=100)
ggsave(filename = filename2, plot = roc.plot, width = 200, height =120, unit = "mm", dpi=100)
cat(paste(maintitle1,maintitle2,sep = ","))
