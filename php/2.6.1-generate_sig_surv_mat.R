library(jsonlite)
library(data.table)
library(dplyr)
library(gtools)
library(rlist)
Args <- commandArgs(T)
#Args <- c("PDCD1,CD3D")
gene <- unlist(strsplit(Args[1],split=','))
maintitle <- paste(paste(gene,collapse = "_"),
                   "sig-survival",sep="-")
if(nchar(maintitle) > 200) {
  maintitle <- paste("longSig",
                     "sig-survival",sep="-")
}

normalMed <- ""
exp.cutoff <- 0.5
loading.data.path <- "Response_data/"
result.path <- "./img/"
load(paste0(loading.data.path,"ResponseData.RData"))
mergedatasets <- dir(loading.data.path,pattern = ".Response.Rds")

title.gene <- "Custom Geneset"
pscore.arr <- data.table(signature = title.gene)
# if(!file.exists(paste0(result.path,maintitle,".json"))){
  for (sl.dataset in colnames(surv.zscore.table)[-1]){
    exp.mergearray <- NULL
    exp.array <- readRDS(paste0(loading.data.path,sl.dataset,".Response.Rds"))[GENE_SYMBOL %in% c(gene)]
    exp.array$score_group <- ifelse(exp.array[,GENE_SYMBOL] %in% gene, "CustomGene","NormalGene")
    exp.array <- exp.array[,lapply(.SD, mean), by = c("score_group") , .SDcols = -c("GENE_SYMBOL")] # Weighted gene = 1
    exp.array <- data.frame(row.names = exp.array[,score_group],exp.array[,-c("score_group")])
    exp.mergearray <- rbind(exp.mergearray,t(exp.array))
    exp.mergearray <- data.table(sample_id = rownames(exp.mergearray), exp.mergearray)
    exp.mergearray$sample_id <- gsub("^X", "", exp.mergearray$sample_id)
    plot.data <- exp.mergearray[sample.info[,c(1,9,10)], on = c("sample_id"), nomatch = F]
    plot.data <- plot.data[,lapply(.SD, function(x)x[1]), by = c("sample_id")] ## remove same samples
    colnames(plot.data)[seq(ncol(plot.data)-1,ncol(plot.data))] <- c("Overall_survival_days","Status")
    plot.data$Status <- ifelse(plot.data$Status == "Dead", 1, 0)
    if( sum(!is.na(plot.data$Overall_survival_days)) < 3 ){
      pscore <- 0
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
      pscore <- round(sign(log(tmp.res[1],2)) * -log10(tmp.res[2]),3)
    }
    pscore.arr <- cbind(pscore.arr,pscore)
    setnames(pscore.arr,"pscore",sl.dataset)
  }
  surv.zscore <- surv.zscore.table[,lapply(.SD, function(x){strsplit(x,"_")[[1]][3]}),by = c("signature")]
  pscore.table <- rbind(pscore.arr, surv.zscore) %>% toJSON(pretty=TRUE,.)
  cat(pscore.table, file = (con <- file(paste0(result.path,maintitle,".json"), "w", encoding = "UTF-8")))
  close(con)
# }
cat(maintitle)
