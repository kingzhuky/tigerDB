library(dplyr)
library(data.table)
library(ggplot2)
library(ggsci)
library(ggpubr)

Args <- commandArgs(T)
#Args <- c("TP53","Melanoma_PRJEB23709,Melanoma_GSE78220","gene","CD3D","TRUE","pdf")
#Args <- c("TP53","Melanoma_PRJEB23709,Melanoma_GSE78220","NULL","NULL","TRUE","pdf")
#Args <- c("RP11-87C12.6","Melanoma_GSE78220","None","None","TRUE","pdf")
gene <- unlist(strsplit(Args[1],split='_'))
mergedatasets <- unlist(strsplit(Args[2],split=','))
normalMed <- Args[3]
normalGene <- Args[4]
Log.scale <- Args[5]
datatype <- Args[6]

load("ResponseData.RData")
exp.mergearray <- NULL
for (sl.dataset in mergedatasets){
    exp.array <- response.data.list[[sl.dataset]][GENE_SYMBOL %in% c(normalGene,gene)]
    exp.array <- data.frame(row.names = exp.array[,GENE_SYMBOL],exp.array[,-c("GENE_SYMBOL")])
    exp.mergearray <- rbind(exp.mergearray,t(exp.array))
}
exp.mergearray <- data.table(sample_id = rownames(exp.mergearray), exp.mergearray)
plot.data <- exp.mergearray[sample.info[,.(sample_id,Treatment)], on = c("sample_id"),nomatch = F]
if (normalMed == "gene"){
  plot.data$gene.exp <- plot.data[,..gene]/plot.data[,..normalGene]
  plot.data <- plot.data[abs(gene.exp) != Inf,] ## delete nonsense values
}else{
  plot.data$gene.exp <- plot.data[,..gene]
}
plot.data$group <- plot.data$Treatment
plot.data$group[plot.data$group != "PRE"] <- "POST"


if (Log.scale == "TRUE") {
  plot.data$gene.exp <- log2(plot.data$gene.exp + 1)
  ylab <- paste("log2( FPKM + 1 )")
}else{
  ylab <- "FPKM"
}
response.plot <- ggplot(plot.data, aes(group,gene.exp,fill=group))+
  geom_violin()+
  geom_boxplot(width = .4)+
  theme_bw() + labs(x= element_blank(),y = ylab) +
  ggtitle(paste(paste(mergedatasets,collapse = "_"),gene,sep="-")) +
  theme(plot.title=element_text(size = 20, hjust=0.5),
        axis.title.y = element_text(size = 15, face = "plain", colour = "black"),
        axis.text = element_text(size = 15, face = "plain", colour = "black")) +
        stat_compare_means(aes(group = group), method="t.test" )

maintitle1 <- paste(paste(gene,collapse = "_"),paste(mergedatasets,collapse = "_"),
                normalMed,normalGene,Log.scale,
                datatype,"box",sep="-")

if(datatype == "png"){
  png(file=paste0("./img/",maintitle1,".png"))
  print(response.plot)
  dev.off()
}else{
  pdf(file=paste0("./img/",maintitle1,".pdf"))
  print(response.plot)
  dev.off()
}

cat(paste(maintitle1,sep=","))
