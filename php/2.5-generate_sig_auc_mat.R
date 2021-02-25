library(jsonlite)
library(data.table)
library(dplyr)
library(gtools)
library(pROC)
library(jsonlite)
Args <- commandArgs(T)
#Args <- c("PDCD1,CD3D")
gene <- unlist(strsplit(Args[1],split=','))
maintitle <- paste(paste(gene,collapse = "_"),
                   "response",sep="-")
if(nchar(maintitle) > 200) {
  maintitle <- paste("longSig",
                     "response",sep="-")
}

normalMed <- ""
loading.data.path <- "Response_data/"
result.path <- "./img/"
load(paste0(loading.data.path,"ResponseData.RData"))
mergedatasets <- dir(loading.data.path,pattern = ".Response.Rds")
auc.arr <- data.table(group="Custom Geneset")
if(!file.exists(paste0(result.path,maintitle,".json")) ){
  for (sl.dataset in colnames(auc.data.list)[-1]){
    exp.mergearray <- NULL
    exp.array <- readRDS(paste0(loading.data.path,sl.dataset,".Response.Rds"))[GENE_SYMBOL %in% c(gene)]
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
      
      auc.score <- auc(roc(factor(plot.data[,group],levels = c("Responder (R)","Non-Responder (NR)")),plot.data[,gene.exp],levels=c("Responder (R)","Non-Responder (NR)")))[1]
    }else{
      auc.score <- 0
    }
    auc.arr <- cbind(auc.arr,auc.score)
    setnames(auc.arr,"auc.score",sl.dataset)
  }
  auc.table <- rbind(auc.arr,auc.data.list) %>% toJSON(pretty=TRUE,.)
  cat(auc.table, file = (con <- file(paste0(result.path,maintitle,".json"), "w", encoding = "UTF-8")))
  close(con)
}
cat(maintitle)