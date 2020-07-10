library(dplyr)
library(ggplot2)
library(survival)
library(survminer)

Args <- commandArgs(T)
#Args <- c("TP53","SKCM","gene","CD3D","0.5","PRJEB23709,SRP070710,phs000452","pdf")
gene <- unlist(strsplit(Args[1],split='_'))
cancer <- unlist(strsplit(Args[2],split='_'))
normalMed <- Args[3]
normalGene <- Args[4]
exp.cutoff <- as.numeric(Args[5])
mergedatasets <- unlist(strsplit(Args[6],split=','))
datatype <- Args[7]

if(Sys.info()[1]=="Windows"){
  path="D:/javascript/tigetData/"
  
}else{
  path="/bakup/tiger/"
}


setwd(path)

load.dir <- path
#gene <- "TP53"
#cancer <- "ACC"
load(paste(load.dir,"Response_datasets.RData",sep = ""))

#gene <- "TP53"
#cancer <- "ACC"
exp.mergearray <- NULL
for (sl.dataset in mergedatasets){
  if (normalMed == "gene"){
    exp.array <- subset(response.data.list[[sl.dataset]],gene_symbol %in% c(gene,normalGene))
    rownames(exp.array) <- exp.array[,"gene_symbol"]
    exp.array <- exp.array[c(gene,normalGene),]
    exp.mergearray <- rbind(exp.mergearray,t(exp.array[,-1]))
  }
  else{
    exp.array <- subset(response.data.list[[sl.dataset]],gene_symbol == gene)
    rownames(exp.array) <- exp.array[,"gene_symbol"]
    exp.mergearray <- rbind(exp.mergearray,t(exp.array[,-1]))
  }
}
plot.data <- cbind(exp.mergearray,subset(sample.info[rownames(exp.mergearray),],select = c(8,9)))
colnames(plot.data)[seq(ncol(plot.data)-1,ncol(plot.data))] <- c("Overall_survival_days","Status")
plot.data$Status <- ifelse(plot.data$Status == "Dead", 1, 0)
if (normalMed == "gene"){
  plot.data$gene.exp <- plot.data[,1]/plot.data[,2]
  plot.data <- plot.data[plot.data[,2] != 0,] ## delete nonsense values
}else{
  plot.data$gene.exp <- plot.data[,1]
}

surv.plot.data <- plot.data[!is.na(plot.data$Overall_survival_days),]
order.index <-  order(surv.plot.data$gene.exp,decreasing = T)
up.index <- order.index[seq(1,round(nrow(surv.plot.data)*exp.cutoff))]
down.index <- order.index[seq(round(nrow(surv.plot.data)*(1-exp.cutoff))+1,nrow(surv.plot.data))]
surv.plot.data$group <- "0"
surv.plot.data[up.index,"group"] <- paste0(gene,"_high")
surv.plot.data[down.index,"group"] <- paste0(gene,"_low")
surv.plot.data <- subset(surv.plot.data,group != "0")
surv.plot.data$group <- factor(surv.plot.data$group)
sfit <-survfit(Surv(as.numeric(Overall_survival_days),Status)~group,data=surv.plot.data)
response.surv.plot <- ggsurvplot(sfit, conf.int = TRUE, pval = TRUE, risk.table = TRUE,
                                 legend.labs = c("High", "Low"), legend.title = gene,
                                 title = paste(paste(cancer, collapse = "_"), gene, sep="-"),
                                 palette = c("dodgerblue2", "orchid2"),
                                 risk.table.height = 0.3,
                                 ggtheme = theme_bw() + 
                                           theme(text = element_text(size = 15),
                                                 plot.title = element_text(size = 20, hjust = 0.5),
                                                 axis.text = element_text(color = "black")))

maintitle=paste(gene,paste(cancer,collapse = "_"),normalMed,normalGene,
                exp.cutoff,paste(mergedatasets,collapse = "_"),
                datatype,sep="-")
if(datatype == "png"){
  png(file=paste0(path,"/img/",maintitle,".png"))
  print(response.surv.plot)
  dev.off()
}else{
  pdf(file=paste0(path,"/img/",maintitle,".pdf"))
  print(response.surv.plot)
  dev.off()
}

cat (maintitle)

