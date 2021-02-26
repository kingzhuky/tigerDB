library(stringr);library(plyr);library(ggplot2);library(data.table);library(magrittr);library(ggpubr);
library(reshape2)
library(rlist)
library(jsonlite)
Args <- commandArgs(TRUE)
#Args <- c("Download/customSig_example.exp.tsv.zip","none","asdasda")
#Args <- c("Download/customSig_example.exp.tsv","none","png")
exp.matrix.file <- Args[1]
sample.anno.file <- ifelse(Args[2] == "none", NA, Args[2])
keyID <- ifelse(is.na(Args[3]), gsub("[-: ]","_",Sys.time()), Args[3])
if(gregexpr("[.]zip$", exp.matrix.file)[[1]][1] != -1){
  tmp_dir = tempdir()
  outf = unzip(exp.matrix.file, list = TRUE)$Name
  unzip(exp.matrix.file, outf, exdir = tmp_dir)
  exp.matrix.table <- fread(file.path(tmp_dir, outf))
}else{
  exp.matrix.table <- fread(exp.matrix.file)
}
if(is.na(sample.anno.file)){
  sample.anno.table <- NULL
}else if(gregexpr("[.]zip$", sample.anno.file)[[1]][1] != -1){
  tmp_dir = tempdir()
  outf = unzip(sample.anno.file, list = TRUE)$Name
  unzip(sample.anno.file, outf, exdir = tmp_dir)
  sample.anno.table <- fread(file.path(tmp_dir, outf))
}else if(!is.na(sample.anno.file)){
  sample.anno.table <- fread(sample.anno.file)
}
loading.data.path <- "Signature_data/"
result.path <- "./img/"


sig.mat <- readRDS(paste0(loading.data.path,"SIG.mat.RDS"))

maintitle1 <- paste("ImmuneSig-Custom","SigScore","table",keyID,sep="-")
maintitle2 <- "0"

## Generate SigScore Table

sig.mat <- sig.mat[exp.matrix.table[,.(GENE_SYMBOL)], on= c("GENE_SYMBOL"), nomatch = F]
GenerateSigScore <- function(exp.table,sig.weighted.mat){
  tmp.table <- exp.table[sig.weighted.mat[,.(GENE_SYMBOL)], on= c("GENE_SYMBOL"), nomatch = F]
  sig.weighted.mat <- sig.weighted.mat[,lapply(.SD, as.numeric),by = c("GENE_SYMBOL")] 
  SIG.score.seplist <- lapply(sig.weighted.mat[,-c("GENE_SYMBOL")], function(x){tmp.table[,lapply(.SD,weighted.mean,w=x), .SDcols=-c("GENE_SYMBOL")]})
}
SIG.score.seplist <- GenerateSigScore(exp.matrix.table,sig.mat)
# SIG.score.table <- data.table(sig_id = names(SIG.score.seplist), list.rbind(SIG.score.seplist))
SIG.score.table <- list.rbind(SIG.score.seplist) %>% data.frame(row.names = names(SIG.score.seplist), .) %>% t() %>% data.table(sample_id = row.names(.), .)
## Generate Group Score boxplot
if(!is.na(sample.anno.file)){
  unique(SIG.score.table$group)
  SIG.score.table <- merge(sample.anno.table, SIG.score.table,by = "sample_id", all.y = TRUE)
  SIG.score.group.table <-  SIG.score.table[!is.na(group),lapply(.SD,mean),by = c("group"), .SDcols=-c("sample_id")]
  
  maintitle2 <- paste("ImmuneSig-Custom","GroupSigScore","table",keyID,sep="-")
  ## save tmp table 
  saveRDS(SIG.score.table[!is.na(group)], paste0(result.path,maintitle1,".RDS"))
  ## save json
  SIG.score.group.table.json <- toJSON(pretty = TRUE, SIG.score.group.table)
  cat(SIG.score.group.table.json, file = (con <- file(paste0(result.path,maintitle2,".json"), "w", encoding = "UTF-8")))
  close(con)
}
SIG.score.table.json <- toJSON(pretty = TRUE, SIG.score.table)
cat(SIG.score.table.json, file = (con <- file(paste0(result.path,maintitle1,".json"), "w", encoding = "UTF-8")))
close(con)

cat(paste(maintitle1,maintitle2,sep=","))
