library(ggpubr)
library(ggplot2)

Args <- commandArgs(T)
#Args <- c("TP53","SKCM_BRCA","TotalMutation","gene","CD3D","pearson","SKCM,BRCA","pdf")
gene<- unlist(strsplit(Args[1],split='_'))
cancer<- unlist(strsplit(Args[2],split='_'))
signature<-Args[3]
normalMed<-Args[4]
normalGene<-Args[5]
corMed<-Args[6] #pearson spearman kendall
mergedatasets <- unlist(strsplit(Args[7],split=','))
datatype<-Args[8]
Log.scale <- "TRUE"


if(Sys.info()[1]=="Windows"){
  path="D:/javascript/tigetData/"
 
}else{
  path="/bakup/tiger/"
}

setwd(path)
load.dir <- path
#gene <- "TP53"
#cancer <- "ACC"
load(paste(load.dir,"TCGA_signature.RData",sep = ""))

mergedata <- NULL
for (sl.dataset in mergedatasets){
  if (normalMed == "gene"){
    exp.array <- subset(TCGA.exp.matrix.list[[sl.dataset]],rownames(TCGA.exp.matrix.list[[sl.dataset]]) %in% c(gene,normalGene))
    exp.array <- exp.array[c(gene,normalGene),]
    sig.array <- subset(TCGA.signature.list[[sl.dataset]],select = signature)
    same.samples <- intersect(rownames(sig.array),colnames(exp.array))
    sl.dataset.mergedata <- data.frame(t(exp.array[,same.samples]),signature = sig.array[same.samples,])
    mergedata <- rbind(mergedata,sl.dataset.mergedata)
  }
  else{
    exp.array <- subset(TCGA.exp.matrix.list[[sl.dataset]],rownames(TCGA.exp.matrix.list[[sl.dataset]]) == gene)
    sig.array <- subset(TCGA.signature.list[[sl.dataset]],select = signature)
    same.samples <- intersect(rownames(sig.array),colnames(exp.array))
    sl.dataset.mergedata <- data.frame(t(exp.array[,same.samples]),signature = sig.array[same.samples,])
    mergedata <- rbind(mergedata,sl.dataset.mergedata)
  }
}
if (normalMed == "gene"){
  mergedata$gene.exp <- mergedata[,1]/mergedata[,2]
  mergedata <- mergedata[mergedata[,2] != 0,] ## delete nonsense values
}else{
  mergedata$gene.exp <- mergedata[,1]
}

if(Log.scale == "TRUE") mergedata$gene.exp <- log2(mergedata$gene.exp + 1)
mergedata$signature <- mergedata$signature/40
cor.result <- cor.test(mergedata$signature,mergedata$gene.exp,method = corMed)
# setting ggplot theme
own.theme <- theme(plot.title=element_text(size = 20, hjust=0.5),
                   axis.title = element_text(size = 15, face = "plain", colour = "black"),
                   axis.text = element_text(size = 15, face = "plain", colour = "black"),
                   text = element_text(size = 15, face = "plain", colour = "black"),
                   panel.grid = element_blank())
            

correlation.plot <- ggplot(mergedata, aes(gene.exp,signature))+geom_point(size = 2)+ theme_bw()+
                        labs(x= paste0("log2(",gene," RPKM)"),y = signature) +
                        stat_cor(method = corMed, label.sep = " ",size=5)+
                        ggtitle(paste(paste(cancer,collapse = "_"),gene,sep="-")) +own.theme

maintitle=paste(gene,paste(cancer,collapse = "_"),signature,normalMed,normalGene,
                corMed,paste(mergedatasets,collapse = "_"),
                datatype,sep="-")
if(datatype == "png"){
  png(file=paste0(path,"/img/",maintitle,".png"))
  print(correlation.plot)
  dev.off()
}else{
  pdf(file=paste0(path,"/img/",maintitle,".pdf"))
  print(correlation.plot)
  dev.off()
}
cat (maintitle)

