library(dplyr);library(data.table);library(ggplot2);library(ggsci);library(ggpubr)
library(pROC)
library(jsonlite)

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
# Args <- c("CD274,CD3D","Melanoma-Nathanson_2017_anti-CTLA-4","CR","SD,PD","NULL","NULL","TRUE","pdf")
# Args <- c("ALPL,BST1,CD93,CEACAM3,CREB5,CRISPLD2,CSF3R,CXCR1,CXCR2,CYP4F3,DYSF,FCAR,FCGR3B,FPR1,FPR2,G0S2,H2BC5,HPSE,KCNJ15,LILRB2,MGAM,MME,NA,PDE4B,S100A12,SIGLEC5,SLC22A4,SLC25A37,TECPR2,TNFRSF10C,VNN3","Melanoma_PRJEB23709_ALL,Melanoma_PRJEB23709_anti-PD-1","PR,CR","SD,PD","NULL","NULL","TRUE","pdf")
gene <- unlist(strsplit(Args[1],split=','))
mergedatasets <- unlist(strsplit(Args[2],split=','))
response.group <- unlist(strsplit(Args[3],split=','))
nonresponse.group <- unlist(strsplit(Args[4],split=','))
normalMed <- Args[5]
normalGene <- Args[6]
Log.scale <- Args[7]
datatype <- Args[8]

loading.data.path <- "Response_data/"
result.path <- "./img/"
load(paste0(loading.data.path,"ResponseData.RData"))
maintitle1 <- paste(paste(gene,collapse = "_"),paste(mergedatasets,collapse = "_"),
                    paste(response.group,nonresponse.group,sep="_",collapse = "_"),
                    normalMed,normalGene,Log.scale,
                    datatype,"box",sep="-")
whether.in.auc.list <- sum(mergedatasets %in% colnames(auc.data.list)) == length(mergedatasets)
# if(whether.in.auc.list){
maintitle2 <- paste(paste(gene,collapse = "_"),paste(mergedatasets,collapse = "_"),
                    paste(response.group,nonresponse.group,sep="_",collapse = "_"),
                    normalMed,normalGene,Log.scale,
                    datatype,"table",sep="-")
# }else{
#   maintitle2 <- "0"
# }
if(nchar(maintitle1) > 200 | nchar(maintitle2) > 200) {
  maintitle1 <- paste("longSig",paste(mergedatasets,collapse = "_"),
                      paste(response.group,nonresponse.group,sep="_",collapse = "_"),
                      normalMed,normalGene,Log.scale,
                      datatype,"box",sep="-")
  maintitle2 <- paste("longSig",paste(mergedatasets,collapse = "_"),
                      paste(response.group,nonresponse.group,sep="_",collapse = "_"),
                      normalMed,normalGene,Log.scale,
                      datatype,"table",sep="-")
}

# whether.res.exist <- file.exists(paste0(result.path,maintitle2,".json"),paste0(result.path,maintitle1,".png"))
# if( sum(whether.res.exist) == 0 | nchar(maintitle1) > 200 | nchar(maintitle2) > 200){
## setting title
title.gene <- ifelse(length(gene) > 1, ifelse(length(gene) <= 3, paste0(gene,collapse = ","), "Custom_Geneset"), gene)

exp.mergearray <- NULL
for (sl.dataset in mergedatasets){
  exp.array <- readRDS(paste0(loading.data.path,sl.dataset,".Response.Rds"))[GENE_SYMBOL %in% c(normalGene,gene)]
  exp.array$score_group <- ifelse(exp.array[,GENE_SYMBOL] %in% gene, "CustomGene","NormalGene")
  exp.array <- exp.array[,lapply(.SD, mean), by = c("score_group") , .SDcols = -c("GENE_SYMBOL")] # Weighted gene = 1
  exp.array <- data.frame(row.names = exp.array[,score_group],exp.array[,-c("score_group")],check.names = F)
  exp.mergearray <- rbind(exp.mergearray,t(exp.array))
  
  # exp.array <- readRDS(paste0(loading.data.path,sl.dataset,".Response.Rds"))[GENE_SYMBOL %in% c(normalGene,gene)]
  # exp.array <- data.frame(row.names = exp.array[,GENE_SYMBOL],exp.array[,-c("GENE_SYMBOL")])
  # exp.mergearray <- rbind(exp.mergearray,t(exp.array))
}
exp.mergearray <- data.table(sample_id = rownames(exp.mergearray), exp.mergearray)
plot.data <- exp.mergearray[sample.info[,.(sample_id,response)], on = c("sample_id"),nomatch = F]
plot.data <- plot.data[,lapply(.SD, function(x)x[1]), by = c("sample_id")] ## remove same samples
if (normalMed == "gene"){
  plot.data$gene.exp <- plot.data[,CustomGene]/plot.data[,NormalGene]
  plot.data <- plot.data[abs(gene.exp) != Inf,] ## delete nonsense values
  title.plot <- paste(title.gene,"normalized",sep = "-")
}else{
  plot.data$gene.exp <- plot.data[,CustomGene]
  title.plot <- title.gene
}
plot.data$group <- plot.data$response
if(length(response.group) == 2) response.group <- c(response.group,"CRPR")
plot.data$group[plot.data$response %in% c("R","MR",response.group)] <- "Responder (R)"
plot.data$group[plot.data$response %in% c("N","NR","Resistance","NE",nonresponse.group)] <- "Non-Responder (NR)"
plot.data <- plot.data[plot.data$group %in% c("Non-Responder (NR)","Responder (R)"),]

if (Log.scale == "TRUE") {
  plot.data$gene.exp <- log2(plot.data$gene.exp + 1)
  ylab <- ifelse(length(gene) > 1,paste("Average Expression of Geneset (log2(FPKM + 1))"), paste("Gene Expression (log2(FPKM + 1))") )
}else{
  ylab <- ifelse(length(gene) > 1,paste("Average Expression of Geneset (FPKM)"), paste("Gene Expression (FPKM)") )
}
# response.plot <- ggplot(plot.data, aes(group,gene.exp,fill=group))+
#   geom_boxplot(width = .4) +
#   geom_jitter(color="black", size=0.7, alpha=.9) +
#   theme_bw() + labs(x= element_blank(),y = ylab) +
#   theme(legend.position="none",
#         plot.title= element_text(size = 20, hjust=0.5),
#         axis.title.y = element_text(size = 15, face = "plain", colour = "black"),
#         axis.text = element_text(size = 15, face = "plain", colour = "black")) +
#   stat_compare_means(aes(group = group),label.x.npc = 0.45,label.y.npc = 0.95, size = 6,label.sep = "\n")

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

if(whether.in.auc.list){
  auc.score <- auc(roc(factor(plot.data[,group],levels = c("Responder (R)","Non-Responder (NR)")),plot.data[,gene.exp],levels=c("Responder (R)","Non-Responder (NR)")))[1]
  auc.data <- melt(auc.data.list[,c("group",..mergedatasets[-2])],id = c("group"))
  auc.data.mean <- auc.data[, lapply(.SD, mean), by = group, .SDcols = c("value")] # merge dataset
  auc.plot.data <- rbind(data.table(group = title.gene, value = auc.score),auc.data.mean)
  names(auc.plot.data)[2] <- "AUC" 
  auc.table <- SIG.info[,c("SignatureID","SignatureName","Gene Symbol")][auc.plot.data, on = c("SignatureID" = "group"),nomatch = NA]
  auc.table[1,"SignatureName"] <- title.gene
  auc.table[1,"Gene Symbol"] <- title.gene
  setnames(auc.table,c("signature_id","signature_name","description","AUC"))
  auc.table.json <- toJSON(pretty=TRUE,auc.table)
  cat(auc.table.json, file = (con <- file(paste0(result.path,maintitle2,".json"), "w", encoding = "UTF-8")))
  close(con)
}
if(datatype == "png"){
  filename = paste0(result.path,maintitle1,".png")
  ggsave(filename = filename,plot = response.plot,width = 200, height =120, unit = "mm", dpi=100)
}else{
  filename = paste0(result.path,maintitle1,".pdf")
  ggsave(filename = filename,plot = response.plot,width = 220, height =120, unit = "mm", dpi=100,device = pdf())
  dev.off()
}
# }
cat(paste(maintitle1,maintitle2,sep=","))
