library(dplyr);library(data.table);library(ggplot2);library(ggsci);library(ggpubr)

mytheme <- theme_bw() + 
  theme(plot.title=element_text(size=rel(2),hjust=0.5),
        axis.title=element_text(size=rel(1)),
        axis.text.x = element_text(angle=0,hjust=0.5, vjust=0.5,size = rel(1.2),color="black"),
        axis.text.y = element_text(angle=0,hjust=0.5, vjust=0.5,size = rel(1.2),color="black"),
        panel.grid.major=element_line(color="grey96"),
        panel.grid.minor=element_line(color="grey96"),
        panel.border=element_rect(color="black",size=1),
        axis.line=element_line(color="black",size=0.5))

Args <- commandArgs(T)
#Args <- c("7SK","Melanoma-Nathanson_2017_anti-CTLA-4_Female","None","None","FALSE","png")
gene <- unlist(strsplit(Args[1],split=','))
mergedatasets <- unlist(strsplit(Args[2],split=','))
normalMed <- Args[3]
normalGene <- Args[4]
Log.scale <- Args[5]
datatype <- Args[6]

loading.data.path <- "Response_data/"
result.path <- "./img/"

maintitle1 <- paste(paste(gene,collapse = "_"),paste(mergedatasets,collapse = "_"),
                    normalMed,normalGene,Log.scale,
                    datatype,"box",sep="-")

# whether.res.exist <- file.exists(paste0(result.path,maintitle1,".png"))
# if( sum(whether.res.exist) == 0){
title.gene <- ifelse(length(gene) > 1, ifelse(length(gene) <= 3, paste0(gene,collapse = ","), "Custom_Geneset"), gene)
load(paste0(loading.data.path,"ResponseData.RData"))
exp.mergearray <- NULL
for (sl.dataset in mergedatasets){
  exp.array <- readRDS(paste0(loading.data.path,sl.dataset,".Response.Rds"))[GENE_SYMBOL %in% c(normalGene,gene)]
  exp.array$score_group <- ifelse(exp.array[,GENE_SYMBOL] %in% gene, "CustomGene","NormalGene")
  exp.array <- exp.array[,lapply(.SD, mean), by = c("score_group") , .SDcols = -c("GENE_SYMBOL")] # Weighted gene = 1
  exp.array <- data.frame(row.names = exp.array[,score_group],exp.array[,-c("score_group")], check.names = FALSE)
  exp.mergearray <- rbind(exp.mergearray,t(exp.array))
}
exp.mergearray <- data.table(sample_id = rownames(exp.mergearray), exp.mergearray)
plot.data <- exp.mergearray[sample.info[,.(sample_id,Treatment)], on = c("sample_id"),nomatch = F]
if (normalMed == "gene"){
  plot.data$gene.exp <- plot.data[,CustomGene]/plot.data[,NormalGene]
  plot.data <- plot.data[abs(gene.exp) != Inf,] ## delete nonsense values
  title.plot <- paste(title.gene,"normalized",sep = "-")
}else{
  plot.data$gene.exp <- plot.data[,CustomGene]
  title.plot <- title.gene
}
plot.data$group <- plot.data$Treatment
plot.data$group[plot.data$group != "PRE"] <- "POST"
if(length(unique(plot.data$group)) > 1){
  if (Log.scale == "TRUE") {
    plot.data$gene.exp <- log2(plot.data$gene.exp + 1)
    ylab <- ifelse(length(gene) > 1,paste("Average Expression of Geneset (log2(FPKM + 1))"), paste("Gene Expression (log2(FPKM + 1))") )
  }else{
    ylab <- ifelse(length(gene) > 1,paste("Average Expression of Geneset (FPKM)"), paste("Gene Expression (FPKM)") )
  }
  plot.data$group[plot.data$group == "PRE"] <- "Pre-Therapy"
  plot.data$group[plot.data$group == "POST"] <- "Post-Therapy"
  # response.plot <- ggplot(plot.data, aes(group,gene.exp,fill=group))+
  #                   geom_violin()+
  #                   geom_boxplot(width = .4)+
  #                   theme_bw() + labs(x= element_blank(),y = ylab) +
  #                   theme(plot.title=element_text(size = 20, hjust=0.5),
  #                         axis.title.y = element_text(size = 15, face = "plain", color = "black"),
  #                         axis.text = element_text(size = 15, face = "plain", color = "black")) +
  #                   stat_compare_means(aes(group = group),label.x.npc = 0.45, size = 6,label.sep = "\n")
  
  response.plot <- ggplot(plot.data,aes(x=group,y=gene.exp,color=group))+
    geom_boxplot(outlier.colour = NA,width = .4)+  
    scale_color_manual(values = c('#016af3','#f34b01'))+ mytheme+
    geom_jitter(position = position_jitterdodge(), size=0.7, shape=1)+
    stat_compare_means(aes(group = group),label.x.npc = 0.35,label.y.npc = 0.95, size = 5,label.sep = "\n",show.legend = F)+
    labs(x= element_blank(),y = ylab) +
    theme(axis.text.x = element_text(angle=0,hjust=0.5, vjust=0,size = 15,color="black"),
          axis.text.y = element_text(angle=0,hjust=0.5, vjust=0.5,size = 15,color="black"),
          axis.title.y = element_text(size = 15, face = "plain", colour = "black"),
          legend.text = element_text(size = 12,color="black"),
          legend.title = element_text(size = 12,color="black"),
          legend.key.size = unit(10, "mm"),
          panel.grid=element_line(color="grey95"))
  
  if(datatype == "png"){
    filename = paste0(result.path,maintitle1,".png")
    ggsave(filename = filename,plot = response.plot,width = 220, height =120, unit = "mm", dpi=80)
  }else{
    filename = paste0(result.path,maintitle1,".pdf")
    ggsave(filename = filename,plot = response.plot,width = 220, height =120, unit = "mm", dpi=100,device = pdf())
    dev.off()
  }
}else{
  maintitle1 <- "0"
}
# }
cat(paste(maintitle1,sep=","))

