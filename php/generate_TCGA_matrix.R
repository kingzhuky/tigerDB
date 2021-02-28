library(data.table)
library(dplyr)
library(edgeR)
library(reshape2)
library(rlist)
library(stringr)
library(jsonlite)
## Generate Expresionn matrix of TCGA
TCGA.exp.table <- data.table()
TCGA.sample.anno <- data.table()
exp.file.list <- dir("./TCGA_exp_data","[.]txt$",full.names = TRUE)
for(cancer.exp.file in exp.file.list){
  # cancer.exp.file <- exp.file.list[1]
  cancer_type <- paste0("TCGA-",strsplit(cancer.exp.file,"[-.]")[[1]][3])
  cancer.exp <- fread(cancer.exp.file)
  colnames(cancer.exp)[1] <- "GENE_SYMBOL"
  TCGA.sample.anno <- rbind(TCGA.sample.anno, data.table(sample_id = colnames(cancer.exp)[-1], dataset_id = cancer_type))
  if(nrow(TCGA.exp.table)){
    TCGA.exp.table <- merge(TCGA.exp.table,cancer.exp,by = c("GENE_SYMBOL"),all = T)
  }else{
    TCGA.exp.table <- cancer.exp
  }
}
TCGA.sample.anno[, group := ifelse(as.numeric(str_extract(unlist(lapply(strsplit(TCGA.sample.anno$sample_id,"-"),function(x){x[4]})), "\\d+"))<10,"Tumor","Normal")]
fwrite(TCGA.sample.anno,"TCGA.sample.anno.tsv",sep = "\t")
table(TCGA.sample.anno$group)
dim(TCGA.exp.table)
TCGA.exp.table[1:10,1:10]

fpkmToTpm <- function(fpkm)
{
  exp(log(fpkm) - log(sum(fpkm)) + log(1e6))
}
TCGA.exp.df <- as.data.frame(TCGA.exp.table)
rownames(TCGA.exp.df) <- TCGA.exp.df$GENE_SYMBOL
TCGA.exp.df <- TCGA.exp.df[,-1]
TCGA.exp.tpm.df <- apply(TCGA.exp.df, 2, fpkmToTpm)
TCGA.exp.tpm.table <- data.table(TCGA.exp.tpm.df,keep.rownames = T)
setnames(TCGA.exp.tpm.table,"rn","GENE_SYMBOL")
TCGA.exp.tpm.table[1:10,1:10]

### zhou SERPIN genelist
gene.list <- fread("SERPIN.gene.list",header = F)
setdiff(gene.list[V1 != ""]$V1,TCGA.exp.table$GENE_SYMBOL)
tmp.table <- TCGA.exp.table[GENE_SYMBOL %in% gene.list[V1 != ""]$V1]
zhou.exp.table <- tmp.table[,-c("GENE_SYMBOL")] %>% data.frame(row.names = tmp.table$GENE_SYMBOL, .) %>% t() %>% data.table(sample_id = row.names(.), .)
zhou.exp.table$sample_id <- gsub("[.]","-",zhou.exp.table$sample_id)
zhou.exp.table.fpkm.table <- TCGA.sample.anno[zhou.exp.table,on = c("sample_id")]
setnames(zhou.exp.table.fpkm.table,"AGT","SERPINA8")

tmp.table <- TCGA.exp.tpm.table[GENE_SYMBOL %in% gene.list[V1 != ""]$V1]
zhou.exp.table.tpm <- tmp.table[,-c("GENE_SYMBOL")] %>% data.frame(row.names = tmp.table$GENE_SYMBOL, .) %>% t() %>% data.table(sample_id = row.names(.), .)
zhou.exp.table.tpm$sample_id <- gsub("[.]","-",zhou.exp.table.tpm$sample_id)
zhou.exp.table.tpm.table <- TCGA.sample.anno[zhou.exp.table.tpm,on = c("sample_id")]
setnames(zhou.exp.table.tpm.table,"AGT","SERPINA8")

fwrite(zhou.exp.table.fpkm.table,"TCGA-SETPIN-fpkm-table.tsv",sep = "\t")
fwrite(zhou.exp.table.tpm.table,"TCGA-SETPIN-tpm-table.tsv",sep = "\t")
## Generate Expresionn matrix of TCGA&GETx
# TCGA.GETx.exp.table <- fread("TCGA_GETX_exp_data/TcgaTargetGtex_rsem_gene_fpkm")
# TCGA.GETx.anno.table <- fread("TCGA_GETX_exp_data/TcgaTargetGTEX_phenotype.txt")
# unique(TCGA.GETx.anno.table$`_sample_type`)
# unique(TCGA.GETx.anno.table$`primary disease or tissue`)
# TCGA.GETx.anno.table[`_sample_type` =="Cell Line"]
# TCGA.GETx.anno.table[`primary disease or tissue` =="Heart - Atrial Appendage"]


## generate SIG weight matrix
SIG.table <-  na.omit(fread("SIG_list.csv",sep = ","))
keep.SIGID.str <- c("SIG1,SIG2,SIG24,SIG29,SIG3,SIG30,SIG56,SIG57,SIG58,SIG59,SIG60,SIG61,SIG62,SIG63")
keep.SIGID <- strsplit(keep.SIGID.str,",")[[1]]
SIG.table <- SIG.table[signature_id %in% keep.SIGID]
# test <- SIG.table[signature_id == "SIG18",Gene_symbol]
# test <- alias2Symbol(test, species = "Hs", expand.symbols = FALSE)
# test <-  alias2SymbolUsingNCBI(test,"Homo_sapiens.gene_info",required.columns = c("Symbol"))
# 
# test2 <- test2[test2$Symbol %in% test,]
# TCGA.exp.table[1:10,GENE_SYMBOL]
# fwrite(SIG.table,file = "SIG.table.csv",sep = ",")
SIG.mat <- acast(SIG.table, Gene_symbol ~ signature_id, value.var = c("Weight"),fun.aggregate = mean)
SIG.mat[is.nan(SIG.mat)] <-  0
SIG.mat <- data.table(GENE_SYMBOL = rownames(SIG.mat),SIG.mat)
dysfunction.sig <- fread("Dys.csv",sep = ",")[!is.na(symbol),c(4,2,3)]
exclusion.sig <- fread("Exc.csv",sep = ",")[!is.na(symbol),c(5,2,3,4)]
colnames(dysfunction.sig)[1] <- "GENE_SYMBOL"
colnames(exclusion.sig)[1] <- "GENE_SYMBOL"
dys.exc.sig <- merge(dysfunction.sig,exclusion.sig,all=T)
colnames(dys.exc.sig) <- c("GENE_SYMBOL","SIG59","SIG60","SIG61" ,"SIG62","SIG63")
SIG.mat <- merge(SIG.mat ,dys.exc.sig,by= c("GENE_SYMBOL") ,all =T)
SIG.mat[is.na(SIG.mat)] <- "0"
SIG.mat <- SIG.mat[,lapply(.SD, max), by = c("GENE_SYMBOL")]
SIG.mat$sum <- apply(SIG.mat[,-1], 1, function(x){sum(x!=0)})
SIG.mat <- SIG.mat[sum!=0]
SIG.mat[,sum:=NULL]
saveRDS(SIG.mat,"Signature_data/SIG.mat.RDS")
## generate sigscore matrix

GenerateTCGASigScore <- function(exp.table,sig.weighted.mat){
  tmp.table <- exp.table[sig.weighted.mat[,.(GENE_SYMBOL)], on= c("GENE_SYMBOL"), nomatch = F]
  SIG.score.seplist <- lapply(sig.weighted.mat[,-c("GENE_SYMBOL")], function(x){tmp.table[,lapply(.SD,weighted.mean,w=x), .SDcols=-c("GENE_SYMBOL")]})
}

### TCGA

SIG.matrix <-  TCGA.exp.table[,.(GENE_SYMBOL)][SIG.mat, on= c("GENE_SYMBOL"), nomatch = F]
SIG.matrix <- SIG.matrix[,lapply(.SD, as.numeric),by = c("GENE_SYMBOL")] 
system.time(
  SIG.score.seplist <- GenerateTCGASigScore(TCGA.exp.table,SIG.matrix)
)
SIG.score.TCGA.table <- list.rbind(SIG.score.seplist) %>% data.frame(row.names = names(SIG.score.seplist), .) %>% t() %>% data.table(sample_id = row.names(.), .)
SIG.score.TCGA.table$sample_id <- gsub("[.]", "-", SIG.score.TCGA.table[,sample_id])
SIG.score.TCGA.table <- TCGA.sample.anno[SIG.score.TCGA.table, on = c("sample_id"), nomatch = F]


### Bluk RNA-seq
load("Response_data/ResponseData.RData")
response.data.table <- readRDS("all.blukrnaseqdata.RDS")
SIG.res.matrix <- response.data.table[,.(GENE_SYMBOL)][SIG.mat, on= c("GENE_SYMBOL"), nomatch = F]
SIG.res.matrix <- SIG.res.matrix[,lapply(.SD, as.numeric),by = c("GENE_SYMBOL")]
system.time(
  SIG.score.response.seplist <- GenerateTCGASigScore(response.data.table,SIG.res.matrix)
)
SIG.score.response.table <- list.rbind(SIG.score.response.seplist) %>% data.frame(row.names = names(SIG.score.response.seplist), .) %>% t() %>% data.table(sample_id = row.names(.), .)
SIG.score.response.table$sample_id <- gsub("^X", "", SIG.score.response.table[,sample_id])
SIG.score.response.table <- sample.info[,.(sample_id,dataset_group,response_NR)][SIG.score.response.table, on = c("sample_id"), nomatch = F]
setnames(SIG.score.response.table, c("dataset_group","response_NR"),c("dataset_id","group"))

SIG.score.table <- rbind(SIG.score.TCGA.table,SIG.score.response.table)

saveRDS(SIG.score.TCGA.table,"Signature_data/SIG.score.TCGA.table.RDS")
saveRDS(SIG.score.response.table,"Signature_data/SIG.score.response.table.RDS")
saveRDS(SIG.score.table,"Signature_data/SIG.score.table.RDS")
## Generate expmat each gene

# SIG.score <- data.table(SIG_ID = names(SIG.score.seplist),list.rbind(SIG.score.seplist))
for(gene.name in TCGA.exp.table$GENE_SYMBOL){
  gene.table <- TCGA.exp.table[GENE_SYMBOL == gene.name]
  saveRDS(gene.table,file = paste0("TCGA_data/",gsub("/","-",gene.name),"-TCGA.exp.table.Rds"))
}
SIG.info <- fread("SIG.info.table.tsv",sep = "\t")
# Article.info <- fread("Ariticle.info.csv",sep = ",")
setnames(SIG.score.table,"dataset_id","cancer_type")
save(SIG.info,SIG.score.table,file = "TCGA_data/TCGA.data.table.RData")
length(unique(SIG.score.table$cancer_type))

load("Response_data/ResponseData.RData")
immuneSigView.df <- as.data.frame(auc.data.list)
rownames(immuneSigView.df) <- immuneSigView.df$group
immuneSigView.df <- immuneSigView.df[,-1]
immuneSigView.df[1:3,1:4]
immuneSigMeanAUC <- apply(immuneSigView.df[,1:10],1,function(x){
  mean(as.numeric(x)[!is.na(x)])
  })
immuneSigMeanAUC.table <- data.table(SignatureID = names(immuneSigMeanAUC), AUC = immuneSigMeanAUC)
immuneSigMeanAUC.table <- SIG.info[,.(SignatureID,SignatureName,SignatureCite,PMID)][immuneSigMeanAUC.table, on = c("SignatureID")]
immuneSigMeanAUC.table.json <- toJSON(pretty = TRUE, immuneSigMeanAUC.table)
cat(immuneSigMeanAUC.table.json, file = (con <- file("immuneSigView.json", "w", encoding = "UTF-8")))
close(con)
