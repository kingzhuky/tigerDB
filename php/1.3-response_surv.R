library(dplyr)
library(ggplot2)
library(survival)
library(survminer)
library(data.table)
library(jsonlite)

Args <- commandArgs(T)
#Args <- c("TP53_CD274","Melanoma_PRJEB23709_ALL,Melanoma_PRJEB23709_anti-PD-1","gene","CD3D","0.5","pdf")
#Args <- c("TP53","ccRCC_Braun_2020_EVEROLIMUS","None","None","0.5","png")
#Args <- c("ALPL,BST1,CD93,CEACAM3,CREB5,CRISPLD2,CSF3R,CXCR1,CXCR2,CYP4F3,DYSF,FCAR,FCGR3B,FPR1,FPR2,G0S2,H2BC5,HPSE,KCNJ15,LILRB2,MGAM,MME,NA,PDE4B,S100A12,SIGLEC5,SLC22A4,SLC25A37,TECPR2,TNFRSF10C,VNN3","Melanoma_PRJEB23709_ALL","None","None","0.2","png")
gene <- unlist(strsplit(Args[1],split=','))
mergedatasets <- unlist(strsplit(Args[2],split=','))
normalMed <- Args[3]
normalGene <- Args[4]
exp.cutoff <- as.numeric(Args[5])
datatype <- Args[6]

#gene <- "TP53"
#cancer <- "ACC"
loading.data.path <- "Response_data/"
result.path <- "./img/"

load(paste0(loading.data.path,"ResponseData.RData"))
maintitle1 <- paste(paste(gene,collapse = "_"),
                    paste(mergedatasets,collapse = "_"),normalMed,normalGene,
                    exp.cutoff,"survival",
                    datatype,sep="-")
maintitle2 <- paste(paste(gene,collapse = "_"),
                    paste(mergedatasets,collapse = "_"),normalMed,normalGene,
                    exp.cutoff,"survival",
                    sep="-")
if(nchar(maintitle1) > 200 | nchar(maintitle2) > 200) {
  maintitle1 <- paste("longSig",
                      paste(mergedatasets,collapse = "_"),normalMed,normalGene,
                      exp.cutoff,"survival",
                      datatype,sep="-")
  maintitle2 <- paste("longSig",paste(mergedatasets,collapse = "_"),
                      paste(mergedatasets,collapse = "_"),normalMed,normalGene,
                      exp.cutoff,"survival",
                      sep="-")
}

# whether.res.exist <- file.exists(paste0(result.path,maintitle2,".png"),paste0(result.path,maintitle1,".png"))
# if( sum(whether.res.exist) == 0| nchar(maintitle1) > 200 | nchar(maintitle2) > 200){
  ## setting title
  title.gene <- ifelse(length(gene) > 1, ifelse(length(gene) <= 1, paste0(gene,collapse = ","), "Geneset Score"), gene)
  exp.mergearray <- NULL
  for (sl.dataset in mergedatasets){
    exp.array <- readRDS(paste0(loading.data.path,sl.dataset,".Response.Rds"))[GENE_SYMBOL %in% c(normalGene,gene)]
    exp.array$score_group <- ifelse(exp.array[,GENE_SYMBOL] %in% gene, "CustomGene","NormalGene")
    exp.array <- exp.array[,lapply(.SD, mean), by = c("score_group") , .SDcols = -c("GENE_SYMBOL")] # Weighted gene = 1
    exp.array <- data.frame(row.names = exp.array[,score_group],exp.array[,-c("score_group")], check.names = FALSE)
    exp.mergearray <- rbind(exp.mergearray,t(exp.array))
  }
  exp.mergearray <- data.table(sample_id = rownames(exp.mergearray), exp.mergearray)
  plot.data <- exp.mergearray[sample.info[,c(1,9,10)], on = c("sample_id"), nomatch = F]
  plot.data <- plot.data[,lapply(.SD, function(x)x[1]), by = c("sample_id")] ## remove same samples
  colnames(plot.data)[seq(ncol(plot.data)-1,ncol(plot.data))] <- c("Overall_survival_days","Status")
  plot.data$Status <- ifelse(plot.data$Status == "Dead", 1, 0)
  if( sum(!is.na(plot.data$Overall_survival_days)) < 3 ){
    maintitle1 <- 0
    maintitle2 <- 0
  }else{
    if (normalMed == "gene"){
      plot.data$gene.exp <- plot.data[,CustomGene]/plot.data[,NormalGene]
      plot.data <- plot.data[abs(gene.exp) != Inf,] ## delete nonsense values
      title.plot <- paste(title.gene,"normalized",sep = "-")
    }else{
      plot.data$gene.exp <- plot.data[,CustomGene]
      title.plot <- title.gene
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
    sfit <- survfit(Surv(as.numeric(Overall_survival_days),Status)~group,data=surv.plot.data)
    response.surv.plot <- ggsurvplot(sfit, conf.int = TRUE, pval = TRUE, risk.table = TRUE,
                                     legend.labs = c("High", "Low"), legend.title = title.gene,
                                     xlab = "Time (Days)",
                                     palette = c("dodgerblue2", "orchid2"),
                                     risk.table.height = 0.3,
                                     ggtheme = theme_bw() + 
                                       theme(text = element_text(size = 15),
                                             plot.title = element_text(size = 20, hjust = 0.5),
                                             axis.text = element_text(color = "black")))
    surv.sample.info <- sample.info[!is.na(`overall survival (days)`),]
    colnames(surv.sample.info)[c(9,10)] <- c("Overall_survival_days","Status")
    surv.sample.info$Status <- ifelse(surv.sample.info$Status == "Dead", 1, 0)
    valid.sig <- c("gene.exp",colnames(SIG.score.list)[-1])
    surv.SIG.list <- surv.plot.data[SIG.score.list,on = c("sample_id"), nomatch = F]
    dataset <- t(data.frame(row.names = surv.SIG.list[,sample_id],surv.SIG.list[,..valid.sig]))
    dataset <- na.omit(dataset)
    dataset <- as.data.frame(dataset)
    covariates <- rownames(dataset)
    forest.plot.data <- sapply(covariates, function(x){
      surv.data <-  data.table(sample_id = colnames(dataset), t(dataset[x,]))[surv.sample.info[,c(1,9,10)], on = c("sample_id"), nomatch = F][,-c("sample_id")]
      order.index <-  order(surv.data[,1],decreasing = T)
      up.index <- order.index[seq(1,round(nrow(surv.data)*exp.cutoff))]
      down.index <- order.index[seq(round(nrow(surv.data)*(1-exp.cutoff))+1,nrow(surv.data))]
      surv.data$group <- "0"
      surv.data[up.index,"group"] <- paste0(x,"_high")
      surv.data[down.index,"group"] <- paste0(x,"_low")
      surv.data <- subset(surv.data,group != "0")
      surv.data$group <- factor(surv.data$group)
      # sfit <- survfit(Surv(as.numeric(Overall_survival_days),Status)~group,data=surv.data)
      cox.res <- coxph(Surv(as.numeric(Overall_survival_days),Status)~group,data =surv.data)
      cox.res <- summary(cox.res)
      cox.res$table
      p.value <- signif(cox.res$wald["pvalue"], digits=4)
      wald.test <- signif(cox.res$wald["test"], digits=4)
      beta<-signif(cox.res$coef[1], digits=4);#coeficient beta
      HR <-signif(cox.res$coef[2], digits=4);#exp(beta)
      HR.confint.lower <- signif(cox.res$conf.int[,"lower .95"],4)
      HR.confint.upper <- signif(cox.res$conf.int[,"upper .95"],4)
      # p.value <- signif(cox.res$wald["pvalue"], digits=4)
      # wald.test <- signif(cox.res$wald["test"], digits=4)
      # beta<-signif(cox.res$coef[1], digits=4);#coeficient beta
      # HR <-signif(cox.res$coef[2], digits=4);#exp(beta)
      # HR.confint.lower <- signif(cox.res$conf.int[,"lower .95"],4)
      # HR.confint.upper <- signif(cox.res$conf.int[,"upper .95"],4)
      # HR.text <- paste0(HR, " (",
      #                   HR.confint.lower, "-", HR.confint.upper, ")")
      res<-c(beta, HR, p.value,HR,HR.confint.lower,HR.confint.upper )
      names(res)<-c("beta", "HR", "p.value","mean","lower","upper")
      return(res)
    })
    colnames(forest.plot.data)[1] <- title.gene
    forest.plot.data.table <- data.table(SignatureID = colnames(forest.plot.data),t(forest.plot.data))
    forest.plot.data.table[,`:=`(beta = NULL, mean = NULL, CI95 = paste0(lower,"-",upper),lower = NULL, upper = NULL)]
    forest.plot.data.table <- SIG.info[,c("SignatureID","SignatureCite")][forest.plot.data.table, on = c("SignatureID"),nomatch = NA]
    setnames(forest.plot.data.table,c("SignatureID","SignatureCite","p.value"),c("signature_id","Signature_Cite","PValue"))
    forest.plot.data.table[1,"Signature_Cite"] <- title.gene
    forest.plot.data.table.json <- toJSON(pretty=TRUE, forest.plot.data.table)
    cat(forest.plot.data.table.json, file = (con <- file(paste0(result.path,maintitle2,".json"), "w", encoding = "UTF-8")))
    close(con)
    
    if(datatype == "png"){
      png(file=paste0(result.path,maintitle1,".png"))
      print(response.surv.plot)
      dev.off()
    }else{
      pdf(file=paste0(result.path,maintitle1,".pdf"))
      print(response.surv.plot)
      dev.off()
    }
  }
# }
cat(paste(maintitle1,maintitle2,sep=","))

