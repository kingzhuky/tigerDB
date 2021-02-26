library(jsonlite)
library(data.table)
library(dplyr)
library(gtools)
library(pROC)
library(jsonlite)
library(survival)
library(survminer)
Args <- commandArgs(T)
#Args <- c("CD274,CD3D","Melanoma-GSE100797_ACT")
gene <- unlist(strsplit(Args[1],split=','))
mergedatasets <- unlist(strsplit(Args[2],split=','))


maintitle1 <- paste(paste(gene,collapse = "_"),paste(mergedatasets,collapse = "_"),
                    "table",sep="-")
maintitle2 <- paste(paste(gene,collapse = "_"),paste(mergedatasets,collapse = "_"),
                    "survival",sep="-")
if(nchar(maintitle1) > 200) {
  maintitle1 <- paste("longSig",
                      "response-auctable",sep="-")
  maintitle2 <- paste("longSig",
                      "response-survtable",sep="-")
}

normalMed <- ""
loading.data.path <- "Response_data/"
result.path <- "./img/"
load(paste0(loading.data.path,"ResponseData.RData"))
title.gene <- "Custom Geneset"
exp.cutoff <- 0.5
# if(!file.exists(paste0(result.path,maintitle,".json")) | nchar(maintitle1) > 200 ){
  for (sl.dataset in mergedatasets){
    exp.mergearray <- NULL
    exp.array <- readRDS(paste0(loading.data.path,sl.dataset,".Response.Rds"))[GENE_SYMBOL %in% c(gene)]
    exp.array$score_group <- ifelse(exp.array[,GENE_SYMBOL] %in% gene, "CustomGene","NormalGene")
    exp.array <- exp.array[,lapply(.SD, mean), by = c("score_group") , .SDcols = -c("GENE_SYMBOL")] # Weighted gene = 1
    exp.array <- data.frame(row.names = exp.array[,score_group],exp.array[,-c("score_group")])
    exp.mergearray <- rbind(exp.mergearray,t(exp.array))
  }  
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
    
    auc.score <- auc(roc(factor(plot.data[,group],levels = c("Responder (R)","Non-Responder (NR)")),plot.data[,gene.exp],levels=c("Responder (R)","Non-Responder (NR)")))[1]
  }else{
    auc.score <- 0
  }
  auc.data <- melt(auc.data.list[,c("group",..mergedatasets[-2])],id = c("group"))
  auc.data.mean <- auc.data[, lapply(.SD, mean), by = group, .SDcols = c("value")] # merge dataset
  auc.plot.data <- rbind(data.table(group = title.gene, value = auc.score),auc.data.mean)
  names(auc.plot.data)[2] <- "AUC" 
  auc.table <- SIG.info[,c("SignatureID","SignatureCite")][auc.plot.data, on = c("SignatureID" = "group"),nomatch = NA]
  auc.table[1,"SignatureCite"] <- title.gene
  colnames(auc.table)[c(1:2)] <- c("signature_id","Signature_Cite")
  auc.table.json <- toJSON(pretty=TRUE,auc.table)
  cat(auc.table.json, file = (con <- file(paste0(result.path,maintitle1,".json"), "w", encoding = "UTF-8")))
  close(con)
  
  plot.data <- exp.mergearray[sample.info[,c(1,9,10)], on = c("sample_id"), nomatch = F]
  plot.data <- plot.data[,lapply(.SD, function(x)x[1]), by = c("sample_id")] ## remove same samples
  colnames(plot.data)[seq(ncol(plot.data)-1,ncol(plot.data))] <- c("Overall_survival_days","Status")
  plot.data$Status <- ifelse(plot.data$Status == "Dead", 1, 0)
  if( sum(!is.na(plot.data$Overall_survival_days)) < 3 ){
    maintitle2 <- "0"
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
      surv.data <- data.table(sample_id = colnames(dataset), t(dataset[x,]))
      surv.data <- surv.data[surv.sample.info[,c(1,9,10)], on = c("sample_id"), nomatch = F][,-c("sample_id")]
      order.index <-  order(surv.data[,1],decreasing = T)
      up.index <- order.index[seq(1,round(nrow(surv.data)*exp.cutoff))]
      down.index <- order.index[seq(round(nrow(surv.data)*(1-exp.cutoff))+1,nrow(surv.data))]
      surv.data$group <- "0"
      surv.data[up.index,"group"] <- paste0(x,"_high")
      surv.data[down.index,"group"] <- paste0(x,"_low")
      surv.data <- subset(surv.data,group != "0")
      surv.data$group <- factor(surv.data$group)
      sfit <- surv_fit(Surv(as.numeric(Overall_survival_days),Status)~group,data=surv.data)
      
      cox.res <- coxph(Surv(as.numeric(Overall_survival_days),Status)~group,data =surv.data)
      cox.res <- summary(cox.res)
      cox.res$table
      p.value <- signif(surv_pvalue(sfit)$pval, digits=4)
      wald.test <- signif(cox.res$wald["test"], digits=4)
      beta<-signif(cox.res$coef[1], digits=4);#coeficient beta
      HR <-signif(cox.res$coef[2], digits=4);#exp(beta)
      HR.confint.lower <- signif(cox.res$conf.int[,"lower .95"],4)
      HR.confint.upper <- signif(cox.res$conf.int[,"upper .95"],4)
      res<-c(beta, HR, p.value,HR,HR.confint.lower,HR.confint.upper )
      names(res)<-c("beta", "HR", "p.value","mean","lower","upper")
      return(res)
    })
    colnames(forest.plot.data)[1] <- "Custom Geneset"
    forest.plot.data.table <- data.table(SignatureID = colnames(forest.plot.data),t(forest.plot.data))
    forest.plot.data.table[,`:=`(beta = NULL, mean = NULL, CI95 = paste0(lower,"-",upper),lower = NULL, upper = NULL)]
    forest.plot.data.table <- SIG.info[,c("SignatureID","SignatureCite")][forest.plot.data.table, on = c("SignatureID"),nomatch = NA]
    setnames(forest.plot.data.table,c("SignatureID","SignatureCite","p.value"),c("signature_id","Signature_Cite","PValue"))
    forest.plot.data.table[1,"Signature_Cite"] <- "Custom Geneset"
    forest.plot.data.table.json <- toJSON(pretty=TRUE, forest.plot.data.table)
    cat(forest.plot.data.table.json, file = (con2 <- file(paste0(result.path,maintitle2,".json"), "w", encoding = "UTF-8")))
    close(con2)
  }
# }
cat(paste(maintitle1,maintitle2,sep = ","))
