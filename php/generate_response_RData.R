library(data.table)
library(rlist)
library(reshape2)
library(pROC)
library(GEOquery)
library(dplyr)

# Sys.setenv(http_proxy="http://127.0.0.1:7891")

# load("ResponseData.RData")
id2symbol <- fread('Response_data/hg38/id2symbol.tsv',sep = "\t",header = F)
colnames(id2symbol) <- c("ENSEMBL_ID","GENE_SYMBOL")

response.data.table <- NULL
featurecount.mat.filelist <- dir("./","[.]expression[.]matrix")
genelen.table <- fread("gene_lenth.txt")
genelen.df <- data.frame(row.names = genelen.table$Geneid, lenth = genelen.table$Length)
for(file in featurecount.mat.filelist){
  # file <- featurecount.mat.filelist[2]
  tmp.table <- read.table(file)
  tmp.table <- tmp.table[rownames(genelen.df),]
  rpkm.table <- apply(tmp.table,2,function(x){
    x*10^9/sum(x)/genelen.df$lenth
  })
  rpkm.table <- as.data.table(rpkm.table,keep.rownames = T,che)
  setnames(rpkm.table,"rn","ENSEMBL_ID")
  if(is.null(response.data.table)){
    response.data.table <- rpkm.table
  }else{
    response.data.table <- merge(response.data.table, rpkm.table, by = "ENSEMBL_ID",all=TRUE)
  }
}
response.data.table <- id2symbol[response.data.table, on = c("ENSEMBL_ID"), nomatch = F][,-c("ENSEMBL_ID")]
id2symbol$ENSEMBL_ID <- unlist(lapply(strsplit(id2symbol$ENSEMBL_ID,split = "[.]"),function(x) x[1]))
id2symbol <- id2symbol[,lapply(.SD,function(x)x[1]),by = c("ENSEMBL_ID")]
# rsem_file <- dir("Response_data/hg38","[.]genes[.]results",full.names = T)
# response.data.table <- NULL
# for(file in rsem_file){
#   # file <- "Response_data/hg38/SRR3184279.genes.results"
#   sample_id <- strsplit(file,"[./]")[[1]][3]
#   tmp.table <- fread(file,sep = "\t",header = T)[,.(gene_id,FPKM)]
#   colnames(tmp.table) <- c("ENSEMBL_ID", sample_id)
#   tmp.table$ENSEMBL_ID <- unlist(lapply(strsplit(tmp.table$ENSEMBL_ID,split = "[.]"),function(x) x[1]))
#   tmp.table <- tmp.table[,lapply(.SD, median),by = c("ENSEMBL_ID")]
#   if(is.null(response.data.table)){
#     response.data.table <- tmp.table
#   }else{
#     response.data.table <- merge(response.data.table, tmp.table, by = "ENSEMBL_ID",all=TRUE)
#   }
# }
# 
# # phs000452.v2.p1
# phs000452.mat <- readRDS("phs000452.mat.RDS")

# GSE106128
GPL6947 <- getGEO('GPL6947',destdir =".")
GPL6947.anno.table <- data.table(Table(GPL6947))[,c("ID","Symbol")]
colnames(GPL6947.anno.table)[2] <- "GENE_SYMBOL"
# grep("ILMN_1343291",gpl515.anno.table$ID)
gse106128 <- getGEO('GSE106128',destdir =".")
exprSet <- as.data.frame(exprs(gse106128[[1]])) %>% data.table(ID = rownames(.), .)# 得到表达矩阵，行名为ID，需要转换
express <- merge(x = GPL6947.anno.table, y = exprSet, by = "ID")
gse106128.mat <- express[,-c("ID")]
gse106128.mat <- gse106128.mat[,lapply(.SD, mean), by = c("GENE_SYMBOL")]

# GSE67501
GPL14951 <- getGEO('GPL14951',destdir =".")
GPL14951.anno.table <- data.table(Table(GPL14951))[,c("ID","ILMN_Gene")]
colnames(GPL14951.anno.table)[2] <- "GENE_SYMBOL"
GSE67501 <- getGEO('GSE67501',destdir =".")
exprSet <- as.data.frame(exprs(GSE67501[[1]])) %>% data.table(ID = rownames(.), .)# 得到表达矩阵，行名为ID，需要转换
express <- merge(x = GPL14951.anno.table, y = exprSet, by = "ID")
GSE67501.mat <- express[,-c("ID")]
GSE67501.mat <- GSE67501.mat[,lapply(.SD, mean), by = c("GENE_SYMBOL")]

# GSE93157
GSE93157 <- getGEO('GSE93157',destdir =".")
GSE93157.mat <- as.data.frame(exprs(GSE93157[[1]])) %>% data.table(ID = rownames(.), .)
colnames(GSE93157.mat)[1] <- "GENE_SYMBOL"
GSE93157.mat <- GSE93157.mat[,lapply(.SD, mean), by = c("GENE_SYMBOL")]

# ccRCC_braun_2020
ccRCC_braun_2020.mat <- fread("ccRCC_braun_2020.csv")

ccRCC_braun_2020.mat <- ccRCC_braun_2020.mat[,lapply(.SD, mean), by = c("GENE_SYMBOL")]
colnames(ccRCC_braun_2020.mat) <- gsub("-","_",colnames(ccRCC_braun_2020.mat))
# Nathanson_2017
Nathanson_2017 <- fread("Nathanson_2017.csv")
Nathanson_2017.mat <- acast(Nathanson_2017, gene_short_name ~ sample,value.var = c("FPKM"), fun.aggregate = mean) %>% 
                      data.table( GENE_SYMBOL = rownames(.), .)
Nathanson_2017.mat <- Nathanson_2017.mat[,lapply(.SD, mean), by = c("GENE_SYMBOL")]
colnames(Nathanson_2017.mat)

load("Response_data/GSE115821_GSE100797.RData")
Melanoma_GSE100797 <- data.table(gse100797)
colnames(Melanoma_GSE100797) <- unlist(lapply(strsplit(colnames(Melanoma_GSE100797),"_"), function(x) paste(x[1],x[2],sep = "_")))
colnames(Melanoma_GSE100797)[1] <- "GENE_SYMBOL"
# Melanoma_GSE115821 <- data.table(gse115821_fpkm)
# colnames(Melanoma_GSE115821)[1] <- "GENE_SYMBOL"
# response.data.table[1:10,"SRR3184291"]
tmp.table <- response.data.table
response.data.table <- tmp.table
response.data.table <- merge(response.data.table, Melanoma_GSE100797, by = "GENE_SYMBOL",all.x=TRUE)
# response.data.table <- merge(response.data.table, Melanoma_GSE115821, by = "GENE_SYMBOL",all.x=TRUE)

# setdiff(gse106128.mat$GENE_SYMBOL,response.data.table$GENE_SYMBOL)
gse106128.mat$GENE_SYMBOL <- alias2SymbolUsingNCBI(gse106128.mat[,GENE_SYMBOL],"Homo_sapiens.gene_info",required.columns = c("Symbol"))
response.data.table <- merge(response.data.table, gse106128.mat, by = "GENE_SYMBOL",all.x=TRUE)
# test <- response.data.table
# response.data.table <- test
GSE67501.mat$GENE_SYMBOL <- alias2SymbolUsingNCBI(GSE67501.mat[,GENE_SYMBOL],"Homo_sapiens.gene_info",required.columns = c("Symbol"))
response.data.table <- merge(response.data.table, GSE67501.mat, by = "GENE_SYMBOL",all.x=TRUE)
response.data.table <- merge(response.data.table, GSE93157.mat, by = "GENE_SYMBOL",all.x=TRUE)
response.data.table <- merge(response.data.table, ccRCC_braun_2020.mat, by = "GENE_SYMBOL",all.x=TRUE)
response.data.table <- merge(response.data.table, Nathanson_2017.mat, by = "GENE_SYMBOL",all.x=TRUE)
response.data.table <- response.data.table[,lapply(.SD, mean), by = c("GENE_SYMBOL")]
colnames(response.data.table) <- gsub("-","_",colnames(response.data.table))
# length(test3)
# length(unique(test3))
# setdiff(test3,test2)
# colnames(response.data.table)
all.response.expdata.table <- as.data.frame(response.data.table[,-1],row.names = response.data.table$GENE_SYMBOL)
saveRDS(response.data.table,"all.blukrnaseqdata.RDS")
sample.info <- fread("20210105-sample_info.csv",sep = ",")
sample.info <- sample.info[sample_id != "" & Therapy != "#N/A"]
all.response.expdata.table <- all.response.expdata.table[,colnames(all.response.expdata.table) %in% sample.info$sample_id]

# batch <- data.frame(row.names = sample.info$sample_id, group = sample.info$dataset_group)[colnames(all.response.expdata.table),1]
# mod = model.matrix(~as.factor(group))  #group为分组信息。此步操作为建模。
# exp2 = ComBat(dat=exp, batch=batch, mod=mod, par.prior=TRUE, ref.batch="1")

GenerateResponseList <- function(sample.info, response.data.table, dataset_name, therapy = NULL, gender = NULL){
  res.list <- NULL
  if(!is.null(therapy) & !is.null(gender)){
    sample.id.arr <- intersect(sample.info[dataset_group == dataset_name & Therapy == therapy & Gender == gender, sample_id],
                               colnames(response.data.table))
    res.name <- paste(dataset_name,therapy,gender,sep = "_")
    if(length(sample.id.arr) != 0){
      res.list[[res.name]] <- response.data.table[,c("GENE_SYMBOL",..sample.id.arr)][,lapply(.SD,max),by = c("GENE_SYMBOL")]
    }
  }else if(is.null(therapy) & !is.null(gender)){
    sample.id.arr <- intersect(sample.info[dataset_group == dataset_name & Gender == gender, sample_id],
                               colnames(response.data.table))
    res.name <- paste(dataset_name,gender,sep = "_")
  }else if(!is.null(therapy) & is.null(gender)){
    sample.id.arr <- intersect(sample.info[dataset_group == dataset_name & Therapy == therapy, sample_id],
                               colnames(response.data.table))
    res.name <- paste(dataset_name,therapy,sep = "_")
  }else{
    sample.id.arr <- intersect(sample.info[dataset_group == dataset_name, sample_id],
                               colnames(response.data.table))
    res.name <- paste(dataset_name,sep = "_")
  }
  if(length(sample.id.arr) != 0){
    res.list[[res.name]] <- response.data.table[,c("GENE_SYMBOL",..sample.id.arr)][,lapply(.SD,max),by = c("GENE_SYMBOL")]
  }
  return(res.list)
}

intersect(colnames(response.data.table),sample.info[,sample_id])
setdiff(sample.info[,sample_id],colnames(response.data.table))
setdiff(colnames(response.data.table),sample.info[,sample_id])
response.data.list <- NULL
# dataset_name <- "Melanoma_GSE91061"
for( dataset_name in unique(sample.info[seq_type != "scRNA-seq", dataset_group])){
  therapy.arr <- unique(sample.info[dataset_group == dataset_name, Therapy])
  if(length(therapy.arr) > 1){
    res <- GenerateResponseList(sample.info,response.data.table,dataset_name)
    if(!is.null(res)) response.data.list[[paste0(names(res),"_ALL")]] <- res[[names(res)]]
  }
  for( therapy in therapy.arr ){
    gender.arr <- unique(sample.info[dataset_group == dataset_name & Therapy == therapy, Gender])
    res <- GenerateResponseList(sample.info,response.data.table,dataset_name,therapy)
    if(!is.null(res)) response.data.list[[names(res)]] <- res[[names(res)]]
    if(length(gender.arr) > 1){
      for( gender in gender.arr){
        res <- GenerateResponseList(sample.info,response.data.table,dataset_name,therapy,gender)
        if(!is.null(res)) response.data.list[[names(res)]] <- res[[names(res)]]
      }
    }
  }
}
names(response.data.list)

# load("Rscript/Response_datasets.RData")
# 
# id2symbol <- fread('gencode.v27lift37.geneid2genename',sep = "\t",header = F)
# colnames(id2symbol) <- c("ENSEMBL_ID", "GENE_SYMBOL")
# response.data.list <- lapply(response.data.list,function(x){data.table(ENSEMBL_ID = row.names(x),x)[id2symbol, on = c("ENSEMBL_ID"), nomatch = F][,-c("gene_symbol")]})
# response.data.list[[5]] <- NULL
# names(response.data.list) <- c("Melanoma_PRJEB23709", "GBM_PRJNA482620", "Melanoma_GSE78220", "Melanoma_GSE91061")
# response.data.list$Melanoma_PRJEB23709

## generate SIG score
library(org.Hs.eg.db)
library(edgeR)
SIG.table <- na.omit(fread("SIG_list.csv",sep = ","))
keep.SIGID.str <- c("SIG1,SIG2,SIG24,SIG29,SIG3,SIG30,SIG56,SIG57,SIG58,SIG59,SIG60,SIG61,SIG62,SIG63")
keep.SIGID <- strsplit(keep.SIGID.str,",")[[1]]
SIG.table <- SIG.table[signature_id %in% keep.SIGID]
SIG.table$Gene_symbol <-  alias2SymbolUsingNCBI(SIG.table[,Gene_symbol],"Homo_sapiens.gene_info",required.columns = c("Symbol"))
fwrite(SIG.table,file = "SIG.table.csv",sep = ",")
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
test <- melt(SIG.mat,id.vars = c("GENE_SYMBOL"))[value!=0,c(2,1)]
colnames(test) <- c("signature_id","Gene_symbol")
SIG.symbol <- na.omit(test)[,lapply(.SD, function(x)paste(x,collapse = ",")),by = c("signature_id"),.SDcols = c("Gene_symbol")]
SIG.info <- fread("SIG.info.csv")
SIG.info.table <- na.omit(merge(SIG.info,SIG.symbol,all.x = T))
colnames(SIG.info.table) <- c("SignatureID","SignatureName","SignatureCite","PMID","Title","AuthorInfo","JournalInfo","GeneSymbol")
fwrite(SIG.info.table,"SIG.info.table.tsv",sep = "\t")

## generate signatrue socre list
### generate SIG weight matrix
SIG.table <-  na.omit(fread("SIG_list.csv",sep = ","))
fwrite(SIG.table,file = "SIG.table.csv",sep = ",")
SIG.table <- SIG.table[signature_id %in% keep.SIGID]
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
SIG.matrix <- SIG.mat[,lapply(.SD, as.numeric),by = c("GENE_SYMBOL")]

## generate sigscore matrix

GenerateTCGASigScore <- function(exp.table,sig.weighted.mat){
  tmp.table <- exp.table[sig.weighted.mat[,.(GENE_SYMBOL)], on= c("GENE_SYMBOL"), nomatch = F]
  SIG.score.seplist <- lapply(sig.weighted.mat[,-c("GENE_SYMBOL")], function(x){tmp.table[,lapply(.SD,weighted.mean,w=x), .SDcols=-c("GENE_SYMBOL")]})
}
SIG.res.matrix <- response.data.table[,.(GENE_SYMBOL)][SIG.matrix, on= c("GENE_SYMBOL"), nomatch = F]
system.time(
  SIG.score.response.seplist <- GenerateTCGASigScore(response.data.table,SIG.res.matrix)
)
SIG.score.list <- list.rbind(SIG.score.response.seplist) %>% data.frame(row.names = names(SIG.score.response.seplist), .) %>% t() %>% data.table(sample_id = row.names(.), .)
SIG.score.list$sample_id <- gsub("^X", "", SIG.score.list[,sample_id])

auc.data.list <- data.table()
for (dataset.name in names(response.data.list)){
  dataset <- response.data.list[[dataset.name]]
  # SIG.matrix <-  SIG.mat[,.(SIG1,GENE_SYMBOL)][dataset, on= c("GENE_SYMBOL"), nomatch = NA]
  subset.SIG.matrix <-  SIG.matrix[dataset[,.(GENE_SYMBOL)], on= c("GENE_SYMBOL"), nomatch = F]
  subset.SIG.matrix[is.na(subset.SIG.matrix)] <- 0
  dataset <- dataset[SIG.matrix[,.(GENE_SYMBOL)], on= c("GENE_SYMBOL"), nomatch = F]
  SIG.score.seplist <- lapply(subset.SIG.matrix[,-c("GENE_SYMBOL")], function(x){dataset[,lapply(.SD,weighted.mean,w=x), .SDcols=-c("GENE_SYMBOL")]})
  SIG.score <- data.table(SIG_ID = names(SIG.score.seplist),list.rbind(SIG.score.seplist))
  intersect.sample_id <- intersect(colnames(dataset),colnames(SIG.score))
  R.id <- sample.info[sample_id %in% intersect.sample_id & response_NR == "R", sample_id]
  NR.id <- sample.info[sample_id %in% intersect.sample_id & response_NR == "N", sample_id]
  if(!length(R.id) | !length(NR.id)) next ; # skip non-response
  sample.NR.index <- data.frame(row.names = c(R.id,NR.id),
                                Group = factor(c(rep("R",time=length(R.id)),
                                                 rep("NR",time=length(NR.id)))))
  # setdiff(colnames(SIG.score),rownames(sample.NR.index))
  t.SIG.score <- t(data.frame(row.names = na.omit(SIG.score)$SIG_ID , na.omit(SIG.score)[,-c("SIG_ID")],check.names = F))[rownames(sample.NR.index),,drop=FALSE]
  auc.data <- apply(t.SIG.score, 2, function(x){auc(roc(sample.NR.index[,1],x,levels=c("R","NR")))[1]})
  auc.data.table <- data.table(group = names(auc.data), auc.value = auc.data)
  colnames(auc.data.table)[2] <- dataset.name
  if(nrow(auc.data.list)){
    auc.data.list <- merge(auc.data.list, auc.data.table, by = "group",all=TRUE)
  }else{
    auc.data.list <- auc.data.table
  }
}


SIG.info <- SIG.info.table
Article.info <- fread("Ariticle.info.csv",sep = ",")


## generate survival matrix
GenerateTCGASigScore <- function(exp.table,sig.weighted.mat){
  tmp.table <- exp.table[sig.weighted.mat[,.(GENE_SYMBOL)], on= c("GENE_SYMBOL"), nomatch = F]
  sig.weighted.mat <- sig.weighted.mat[tmp.table[,.(GENE_SYMBOL)], on= c("GENE_SYMBOL"), nomatch = F]
  SIG.score.seplist <- lapply(sig.weighted.mat[,-c("GENE_SYMBOL")], function(x){tmp.table[,lapply(.SD,weighted.mean,w=x), .SDcols=-c("GENE_SYMBOL")]})
}

surv.sample.info <- sample.info[!is.na(`overall survival (days)`),]
colnames(surv.sample.info)[c(9,10)] <- c("Overall_survival_days","Status")
surv.sample.info$Status <- ifelse(surv.sample.info$Status == "Dead", 1, 0)
zscore.mat <- NULL
exp.cutoff <- 0.5
SIG.mat <- readRDS("Signature_data/SIG.mat.RDS")
SIG.matrix <- SIG.mat[,lapply(.SD, as.numeric),by = c("GENE_SYMBOL")]
for (dataset.name in colnames(auc.data.list)[-1]){
  dataset <- readRDS(paste0(loading.data.path,dataset.name,".Response.Rds"))[,lapply(.SD, max), by = c("GENE_SYMBOL")]
  whether_surv <- nrow(surv.sample.info[,c(1,9,10)][data.table(sample_id = colnames(dataset)), on = c("sample_id"), nomatch = FALSE]) < 2
  if(whether_surv) next
  SIG.score.response.seplist <- GenerateTCGASigScore(dataset,SIG.matrix)
  SIG.score.list <- list.rbind(SIG.score.response.seplist) %>% data.frame(row.names = names(SIG.score.response.seplist), .) %>% t() %>% data.table(sample_id = row.names(.), .)
  SIG.score.list$sample_id <- gsub("^X", "", SIG.score.list[,sample_id])
  sample.names <- SIG.score.list$sample_id
  dataset <- t(SIG.score.list[,-1])
  colnames(dataset) <- sample.names
  dataset <- as.data.frame(dataset)
  covariates <- rownames(dataset)
  zscore.gene <- mclapply(covariates, function(x){
    # x <- covariates[1]
    # x <- "CD3D"
    surv.data <-  data.table(sample_id = colnames(dataset), t(dataset[x,]))[surv.sample.info[,c(1,9,10)], on = c("sample_id"), nomatch = FALSE][,-c("sample_id")]
    surv.data <- na.omit(surv.data)
    setnames(surv.data,x , "gene.exp")
    surv.data <- surv.data[gene.exp != 0] 
    if(nrow(surv.data) < 3){
      return(NA)
    }
    order.index <-  order(surv.data[,1],decreasing = T,na.last = TRUE)
    up.index <- order.index[seq(1,round(nrow(surv.data)*exp.cutoff))]
    down.index <- order.index[seq(round(nrow(surv.data)*(1-exp.cutoff))+1,nrow(surv.data))]
    surv.data$group <- "0"
    surv.data[up.index,"group"] <- paste0(x,"_high")
    surv.data[down.index,"group"] <- paste0(x,"_low")
    surv.data <- subset(surv.data,group != "0")
    surv.data$group <- factor(surv.data$group)
    # sfit <- survfit(Surv(as.numeric(Overall_survival_days),Status)~group,data=surv.data)
    cox.res <- coxph(Surv(as.numeric(Overall_survival_days),Status) ~ group,data =surv.data)
    cox.res <- summary(cox.res)
    tmp.res <- cox.res$coefficients[c(2,5)]
    tmp.res[3] <- sign(log(tmp.res[1],2)) * -log10(tmp.res[2])
    hr.p.pscore <- paste(round(tmp.res,4),collapse = "_")
    names(hr.p.pscore) <- x
    return(hr.p.pscore)
  },mc.cores = 40)
  zscore.gene <- na.omit(unlist(zscore.gene))
  zscore.table <- data.table(GENE_SYMBOL = names(zscore.gene), value = zscore.gene)
  colnames(zscore.table)[2] <- dataset.name
  if(is.null(zscore.mat)){
    zscore.mat <- zscore.table
  }else{
    zscore.mat <- merge(zscore.mat, zscore.table, by = "GENE_SYMBOL", all=TRUE)
  }
}
surv.zscore.table <- zscore.mat
setnames(surv.zscore.table,"GENE_SYMBOL","signature")
surv.zscore.table[signature == "SIG57", "Melanoma-GSE106128_DCs_treated_Male"]

save(sample.info,SIG.score.list,auc.data.list,surv.zscore.table,SIG.info,Article.info,file = "Response_data/ResponseData.RData")
for (dataset.name in names(response.data.list)){
  saveRDS(response.data.list[[dataset.name]],file = paste0("Response_data/",dataset.name,".Response.Rds"))
}

## auc table for immunesig page
immunesig.auc.table <- data.table(t(auc.data.list)[-1,],keep.rownames = T,check.names = F)
setnames(immunesig.auc.table,c("dataset_id",auc.data.list$group))
fwrite(immunesig.auc.table,"Signature_data/sigauctable.csv")
