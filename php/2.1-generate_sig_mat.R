library(jsonlite)
library(data.table)
library(dplyr)
library(gtools)
Args <- commandArgs(T)
#Args <- c("PDCD1")
gene.arr <- unlist(strsplit(Args[1],split=','))
maintitle <- paste(paste(gene.arr,collapse = "_"),
                   "TCGA",sep="-")
loading.data.path <- "TCGA_data/"
result.path <- "./img/"
if(nchar(maintitle) > 200) {
  maintitle <- paste("longSig",
                     "TCGA",sep="-")
}

if(!file.exists(paste0(result.path,maintitle,".json")) | nchar(maintitle) > 200 ){
  load(paste0(loading.data.path,"TCGA.data.table.RData"))
  tablecortest <- function(x,y){
    test.res <- cor.test(x,y)
    res <- paste0(round(c(test.res$estimate,test.res$p.value),3), collapse = "_")
    return(res)
  }
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
  Sig.score.matrix <- CalCustomSig(gene.arr,SIG.score.table,loading.data.path)
  SIG.cor.matrix <- Sig.score.matrix[,lapply(.SD,function(x){tablecortest(x,CustomSig)}), .SDcols=-c("CustomSig","sample_id"),by = cancer_type]
  sort.index <- mixedsort(colnames(SIG.cor.matrix))
  SIG.cor.matrix <- SIG.cor.matrix[,..sort.index]
  SIG.cor.matrix.json <- data.frame(row.names = SIG.cor.matrix[,cancer_type],SIG.cor.matrix[,-c("cancer_type")]) %>% 
    t() %>% data.table(Signature = rownames(.),.) %>%
    toJSON(pretty=TRUE,.)
  cat(SIG.cor.matrix.json, file = (con <- file(paste0(result.path,maintitle,".json"), "w", encoding = "UTF-8")))
  close(con)
}
cat(maintitle)



