library(ggpubr)
library(ggplot2)
library(data.table)
library(dplyr)
Args <- commandArgs(T)

#Args <- c("TP53_CD274","BRCA","SIG1","none","none","pearson","pdf")
gene <- unlist(strsplit(Args[1],split=','))
cancer<- unlist(strsplit(Args[2],split=','))
signature<-Args[3]
normalMed<-Args[4]
normalGene<-Args[5]
corMed<-Args[6] #pearson spearman kendall
datatype<-Args[7]
Log.scale <- T

loading.data.path <- "/bakup/tiger/TCGA_data/"
result.path <- "./img/"

maintitle <- paste(paste(gene,collapse = "_"),cancer,signature,
                   normalMed,normalGene,corMed,
                   datatype,sep="-")
if( nchar(maintitle) > 200 ) {
  maintitle <- paste("longSig",cancer,signature,
                     normalMed,normalGene,corMed,
                     datatype,sep="-")
}
# if(!file.exists(paste0(result.path,maintitle,".png")) | nchar(maintitle) > 200){
  load(paste0(loading.data.path,"TCGA.data.table.RData"))
  CalCustomSig <- function(gene.arr,SIG.score.table,loading.data.path){
    customsig.weight.table <- data.table(GENE_SYMBOL = gene.arr, CustomSig = 1)
    custom.sig.table <- NULL
    for(gene.name in gene.arr){
      gene.exp.arr <- readRDS(paste0(loading.data.path,gsub("/","-",gene.name),"-TCGA.exp.table.Rds"))
      rbind(gene.exp.arr)
      if(is.null(custom.sig.table)){
        custom.sig.table <- gene.exp.arr
      }else{
        custom.sig.table <- rbind(custom.sig.table, gene.exp.arr)
      }
    }
    CustomSig.score <- lapply(customsig.weight.table[,.(CustomSig)], function(x){custom.sig.table[,lapply(.SD,weighted.mean,w=x), .SDcols=-c("GENE_SYMBOL")]})
    Sig.score.matrix <- data.table(sample_id = names(CustomSig.score$CustomSig) ,CustomSig = as.numeric(CustomSig.score$CustomSig))[SIG.score.table, on = c("sample_id"), nomatch = F]
    return(Sig.score.matrix)
  }
  Sig.score.matrix <- CalCustomSig(gene,SIG.score.table,loading.data.path)
  
  mergedata <- data.frame()
  save.col <- c("sample_id","CustomSig",signature)
  if (normalMed == "gene"){
    load("TCGA.data.table.RData")
    gene.table <- TCGA.exp.table[GENE_SYMBOL == normalGene, -c("GENE_SYMBOL")] %>% 
                    t() %>%
                    data.table(sample_id = rownames(.), .) %>%
                    .[Sig.score.matrix[cancer_type == cancer, ..save.col], on = c("sample_id"), nomatch = F] %>%
                    .[V1 != 0, -c("sample_id")]
    gene.table$exp <- gene.table[,CustomSig] / gene.table[,V1]
  }else{
    gene.table <- Sig.score.matrix[cancer_type == cancer,..save.col]
    gene.table$exp <- gene.table[,CustomSig]
  }
  mergedata <- as.data.frame(gene.table[,c("exp",..signature)]) ## delete nonsense values
  
  if(Log.scale) mergedata$exp <- log2(mergedata$exp + 1)
  
  # setting ggplot theme
  own.theme <- theme(plot.title=element_text(size = 20, hjust=0.5),
                     axis.title = element_text(size = 15, face = "plain", colour = "black"),
                     axis.text = element_text(size = 15, face = "plain", colour = "black"),
                     text = element_text(size = 15, face = "plain", colour = "black"),
                     panel.grid = element_blank())
  
  correlation.plot <- ggplot(mergedata, aes(exp,mergedata[,signature])) +
                              geom_point(size = 2) + 
                              theme_bw() +
                              labs(x= paste0("log2(","Custom Signature + 1 )"),y = signature) +
                              stat_cor(method = corMed, label.sep = "\n",size=5) +
                              ggtitle(paste(paste(gene,collapse = "_"),signature,sep="-")) +
                              own.theme
  if(datatype == "png"){
    filename = paste0(result.path,maintitle,".png")
  }else{
    filename = paste0(result.path,maintitle,".pdf")
  }
  ggsave(filename = filename,plot = correlation.plot, dpi = 100)
# }
cat(maintitle)
