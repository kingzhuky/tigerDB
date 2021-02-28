setwd("/data1/zhuky/TIGER_dataset")
load("Response_data/ResponseData.RData")
Rds.list <- dir("Response_data","Rds",full.names = T)
example.file <- Rds.list[grep("GSE91061",Rds.list)]
example.data <- readRDS(example.file)
example.anno.table <- sample.info[sample_id %in% colnames(example.data)]
example.anno.group.table <- example.anno.table[,.(sample_id,`M Stage`)]
setnames(example.anno.group.table,"M Stage","group")
example.anno.group.table <- example.anno.group.table[group != ""]
example.anno.group.table[, group:= ifelse(group == "#N/A","UNKNOWN",group)]
fwrite(example.data, file = "Download/customSig_example.exp.tsv",sep = "\t")
fwrite(example.anno.group.table, file = "Download/customSig_example.anno.tsv",sep = "\t")


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