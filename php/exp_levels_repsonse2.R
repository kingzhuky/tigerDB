library(dplyr)
library(ggplot2)

#Args <- commandArgs(T)
Args <- c("TP53","SKCM","PR,CR","SD,PD","None","None","TRUE","PRJEB23709,SRP070710,phs000452","png")
gene <- unlist(strsplit(Args[1],split='_'))
cancer<- Args[2]
response.group <- unlist(strsplit(Args[3],split=','))
nonresponse.group <- unlist(strsplit(Args[4],split=','))
normalMed <- Args[5]
normalGene <- Args[6]
Log.scale <- Args[7]
mergedatasets <- unlist(strsplit(Args[8],split=','))
datatype <- Args[9]


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
plot.data <- cbind(exp.mergearray,subset(sample.info[rownames(exp.mergearray),],select = response))
if (normalMed == "gene"){
  plot.data$gene.exp <- plot.data[,1]/plot.data[,2]
  plot.data <- plot.data[plot.data[,2] != 0,] ## delete nonsense values
}else{
  plot.data$gene.exp <- plot.data[,1]
}
plot.data$group <- plot.data$response
plot.data$group[plot.data$response %in% response.group] <- "R"
plot.data$group[plot.data$response %in% nonresponse.group] <- "N"
plot.data <- plot.data[plot.data$group %in% c("N","R"),]

if(Log.scale) plot.data$gene.exp <- log2(plot.data$gene.exp + 1)
response.plot <- ggplot(plot.data, aes(group,gene.exp,fill=group))+geom_violin()+
                 geom_boxplot(width = .4)+
                 theme_bw() + labs(x= element_blank(),y = "Enrichment") +
                 ggtitle(paste(paste(cancer,collapse = "_"),gene,sep="-")) +
                 theme(plot.title=element_text(size = 20, hjust=0.5),
                       axis.title.y = element_text(size = 15, face = "plain", colour = "black"),
                       axis.text = element_text(size = 15, face = "plain", colour = "black")) 

maintitle=paste(gene,paste(cancer,collapse = "_"),
                paste(response.group,nonresponse.group,sep="_",collapse = "_"),
                normalMed,normalGene,paste(mergedatasets,collapse = "_"),
                datatype,sep="-")

if(datatype == "png"){
  png(file=paste0(path,"/img/",maintitle,".png"))
  print(response.plot)
  dev.off()
}else{
  pdf(file=paste0(path,"/img/",maintitle,".pdf"))
  print(response.plot)
  dev.off()
}

cat (maintitle)

