library(dplyr)
library(data.table)
library(ggplot2)
library(ggsci)
library(ggpubr)
library(pROC)
library(jsonlite)


Args <- commandArgs(T)
#Args <- c("TP53","Melanoma_PRJEB23709,Melanoma_GSE78220","PR,CR","SD,PD","gene","CD3D","TRUE","pdf")
#Args <- c("TP53_CD274","Melanoma_PRJEB23709,Melanoma_GSE78220","PR,CR","SD,PD","None","None","TRUE","pdf")
#Args <- c("TP53_CD274","Melanoma_PRJEB23709,Melanoma_GSE78220","PR,CR","SD,PD","gene","CD3D","TRUE","pdf")
#Args <- c("TP53","Melanoma_PRJEB23709","PR,CR","SD,PD","NULL","NULL","TRUE","pdf")
gene <- unlist(strsplit(Args[1],split='_'))
mergedatasets <- unlist(strsplit(Args[2],split=','))
response.group <- unlist(strsplit(Args[3],split=','))
nonresponse.group <- unlist(strsplit(Args[4],split=','))
normalMed <- Args[5]
normalGene <- Args[6]
Log.scale <- Args[7]
datatype <- Args[8]


load("ResponseData.RData")
exp.mergearray <- NULL
for (sl.dataset in mergedatasets){
  exp.array <- response.data.list[[sl.dataset]][GENE_SYMBOL %in% c(normalGene,gene)]
  exp.array$score_group <- ifelse(exp.array[,GENE_SYMBOL] %in% gene, "CustomGene","NormalGene")
  exp.array <- exp.array[,lapply(.SD, mean), by = c("score_group") , .SDcols = -c("GENE_SYMBOL")]
  exp.array <- data.frame(row.names = exp.array[,score_group],exp.array[,-c("score_group")])
  exp.mergearray <- rbind(exp.mergearray,t(exp.array))
}
exp.mergearray <- data.table(sample_id = rownames(exp.mergearray), exp.mergearray)
plot.data <- exp.mergearray[sample.info[,.(sample_id,response)], on = c("sample_id"),nomatch = F]
if (normalMed == "gene"){
  plot.data$gene.exp <- plot.data[,CustomGene]/plot.data[,NormalGene]
  plot.data <- plot.data[abs(gene.exp) != Inf,] ## delete nonsense values
}else{
  plot.data$gene.exp <- plot.data[,CustomGene]
}
plot.data$group <- plot.data$response
plot.data$group[plot.data$response %in% response.group] <- "R"
plot.data$group[plot.data$response %in% nonresponse.group] <- "NR"
plot.data <- plot.data[plot.data$group %in% c("NR","R"),]

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

auc.score <- auc(roc(factor(plot.data[,group],levels = c("R","NR")),plot.data[,gene.exp],levels=c("R","NR")))[1]
auc.data <- melt(auc.data.list[,c("group",..mergedatasets)],id = c("group"))
auc.data.mean <- auc.data[, lapply(.SD, mean), by = group, .SDcols = c("value")]
auc.plot.data <- rbind(data.table(group = "CustomGene", value = auc.score),auc.data.mean)
names(auc.plot.data)[2] <- "AUC" 
auc.table <- SIG.info[auc.plot.data, on = c("signature_id" = "group"),nomatch = NA]
auc.table$Signature_Cite[1] <- paste(gene,collapse = "_")
auc.table.json <- toJSON(pretty=TRUE,auc.table[,-c("Signature_name")])

maintitle1 <- paste(paste(gene,collapse = "_"),paste(mergedatasets,collapse = "_"),
                    paste(response.group,nonresponse.group,sep="_",collapse = "_"),
                    normalMed,normalGene,Log.scale,
                    datatype,"box",sep="-")

maintitle2 <- paste(paste(gene,collapse = "_"),paste(mergedatasets,collapse = "_"),
                paste(response.group,nonresponse.group,sep="_",collapse = "_"),
                normalMed,normalGene,Log.scale,
                datatype,"bar",sep="-")

if(datatype == "png"){
  png(file=paste0("./img/",maintitle1,".png"))
  print(response.plot)
  dev.off()
}else{
  pdf(file=paste0("./img/",maintitle1,".pdf"))
  print(response.plot)
  dev.off()
}
cat(auc.table.json, file = (con <- file(paste0(maintitle2,".json"), "w", encoding = "UTF-8")))
close(con)

cat(paste(maintitle1,maintitle2,sep=","))