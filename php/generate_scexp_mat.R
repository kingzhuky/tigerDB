library(data.table)
library(dplyr)
library(rlist)
library(rjson)
library(parallel)
setwd("/data10/liuxf/New_Tiger")
scRNA.info <- fread("/data10/liuxf/New_Tiger/table_file/20210115-scRNAseqinfo.txt", sep = "\t")[!is.na(PMID)]
SCID.table <- fread("/data10/liuxf/New_Tiger/homescinfo.tsv")
SCID.table[,`:=`(SCID_Name = paste(datasetid,GlobalCluster,CellType,sep = ","), datasetid = NULL, CancerType = NULL, CellType = NULL, GlobalCluster = NULL)]
# ## home COEA table
# COEA.file.list <- dir("/data3/zhuky/TIGER_data/tiger/rest/coexp",full.names = TRUE, recursive = TRUE, pattern = ".rds", all.files = TRUE)
# # file.path <- COEA.file.list[1]
# file.path <- grep("BCC.coexp/All/A2M[.]rds",COEA.file.list,value = TRUE)
# mat2table <- function(file.path){
#   dataset.id <- strsplit(file.path,"[/.]")[[1]][8] # cancertype from file.path
#   cancer_type <- scRNA.info[datasetid == dataset.id, cancertype]
#   subtypename <- strsplit(file.path,"[/.]")[[1]][10] # globalcluster from file.path
#   geneA <- strsplit(file.path,"[/.]")[[1]][11] # geneA from file.path
#   COEA.mat <- as.data.table(readRDS(file.path),keep.rownames = T)
#   COEA.mat[rn == "HHIP"]
#   COEA.table <- melt(COEA.mat,id.vars = c("rn"),variable.name = "cell_type",na.rm = T,value.name = "r")
#   setnames(COEA.table,"rn","geneb")
#   COEA.table[,`:=`(genea = geneA,ID = paste(dataset.id,cancer_type,subtypename,cell_type,sep = ","), cell_type = NULL)]
#   COEA.table <- COEA.table[genea != geneb]
#   setorder(COEA.table,-r)
#   COEA.table[, head(.SD,10), by = c("ID")]
# }
# COEA.table <- mclapply(COEA.file.list, mat2table,mc.cores = 30)
# COEA.merge.table <- list.rbind(COEA.table)
# COEA.ID.table <- unique(COEA.merge.table[,.(ID)],by = c("ID"))

## homemarker table
singlecell.marker.rds <- dir("/data10/liuxf/New_Tiger/table_file",full.names = TRUE, recursive = TRUE, pattern = "scmarkermat_", all.files = TRUE)
singlecell.marker.rds <- grep("pvalue",singlecell.marker.rds,invert = TRUE,value = TRUE)
singlecell.marker.rds <- grep("rest_table",singlecell.marker.rds,invert = TRUE,value = TRUE)
home.marker.table <- NULL
# rds.file <- singlecell.marker.rds[1]
# subtypename <- "All"
colnames(scRNA.info)
for( rds.file in singlecell.marker.rds ){
  dataset.id <- strsplit(rds.file,"[/._]")[[1]][9]
  cancer_type <- scRNA.info[Cancertype == dataset.id, Cancertype_name]
  tmp.single.mat.logfc <- fread(rds.file)
  tmp.single.mat.p <- fread(gsub("[.]tsv",".pvalue.tsv",rds.file))
  # colnames(tmp.single.mat.logfc) <- gsub(pattern = "[.]$",replacement = "+", colnames(tmp.single.mat.logfc))
  # colnames(tmp.single.mat.p) <- gsub(pattern = "[.]$",replacement = "+", colnames(tmp.single.mat.p))
  # colnames(tmp.single.mat.logfc) <- gsub(pattern = "[.]",replacement = " ", colnames(tmp.single.mat.logfc))
  # colnames(tmp.single.mat.p) <- gsub(pattern = "[.]",replacement = " ", colnames(tmp.single.mat.p))
  p.table <- melt(tmp.single.mat.p,id.vars = c("gene"),variable.name = "cell_type",na.rm = T,value.name = "P_Value")
  fc.table <- melt(tmp.single.mat.logfc,id.vars = c("gene"),variable.name = "cell_type",na.rm = T,value.name = "Log2FoldChange")
  fc.p.table <- merge(fc.table,p.table,by = c("cell_type","gene"))
  setDT(fc.p.table)
  setnames(fc.p.table,c("gene"),c("GENE_SYMBOL"))
  fc.p.table[,`:=`(SCID_Name = paste(dataset.id,cell_type,sep = ","), cell_type = NULL)]
  home.marker.table <- rbind(home.marker.table,fc.p.table)
}
home.marker.table <- SCID.table[home.marker.table,on = c("SCID_Name")]
home.marker.table[,`:=`(SCID_Name = NULL, MarkerID = paste0(GENE_SYMBOL,"-",SCID))]
setcolorder(home.marker.table,c("GENE_SYMBOL","Log2FoldChange","P_Value","SCID","MarkerID"))

# home diffexp table
logfc.file <- dir("/data10/liuxf/New_Tiger/table_file",full.names = TRUE, recursive = TRUE, pattern = "scdiffmat_", all.files = TRUE)
logfc.file <- grep("pavlue",logfc.file,invert = TRUE,value = TRUE)
logfc.file <- grep("pvalue",logfc.file,invert = TRUE,value = TRUE)
logfc.file <- grep("rest_table",logfc.file,invert = TRUE,value = TRUE)
# file <- logfc.file[1]
home.sc.diffexp.table <- NULL
for(file in logfc.file){
  dataset.id <- strsplit(file,"[/._]")[[1]][9]
  cancer_type <- scRNA.info[Cancertype == dataset.id, Cancertype_name]
  condition <- scRNA.info[Cancertype == dataset.id, glo]
  tmp.single.mat.logfc <- fread(file)
  tmp.single.mat.p <- fread(gsub("[.]tsv",".pvalue.tsv",file))
  p.table <- melt(tmp.single.mat.p,id.vars = c("gene"),variable.name = "cell_type",na.rm = T,value.name = "P_Value")
  fc.table <- melt(tmp.single.mat.logfc,id.vars = c("gene"),variable.name = "cell_type",na.rm = T,value.name = "Log2FoldChange")
  fc.p.table <- merge(fc.table,p.table,by = c("cell_type","gene"))
  setDT(fc.p.table)
  setnames(fc.p.table,c("gene"),c("geneid"))
  fc.p.table[,`:=`(SCID_Name = paste(dataset.id,cell_type,sep = ","), cell_type = NULL,condition = condition)]
  home.sc.diffexp.table <- rbind(home.sc.diffexp.table,fc.p.table)
}

home.sc.diffexp.table[,P_Value := -log10(P_Value)]
home.sc.diffexp.table <- SCID.table[home.sc.diffexp.table,on = c("SCID_Name")]
home.sc.diffexp.table[,`:=`(SCID_Name = NULL)]
setcolorder(home.sc.diffexp.table,c("geneid","Log2FoldChange","P_Value","SCID","condition"))
home.sc.diffexp.rnr.table <- home.sc.diffexp.table[condition == "Response vs Non-response"][, condition := NULL]
home.sc.diffexp.tn.table <- home.sc.diffexp.table[condition == "Tumor vs Normal"][, condition := NULL]
home.sc.diffexp.rnr.table[,`:=`(rnrid = paste(geneid,SCID,sep = "-"))]
home.sc.diffexp.tn.table[,`:=`(tnid = paste(geneid,SCID,sep = "-"))]

fwrite(home.marker.table,file = "homemarkertable.csv",sep = ",")
fwrite(home.sc.diffexp.rnr.table,file = "home_scdiffexp_rnr.csv",sep = ",")
fwrite(home.sc.diffexp.tn.table,file = "home_scdiffexp_tn.csv",sep = ",")
length(unique(home.marker.table$SCID))
