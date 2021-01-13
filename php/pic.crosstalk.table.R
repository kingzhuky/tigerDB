library(data.table)
library(jsonlite)

if(Sys.info()[8]=="zky"){
  Path='/data3/zhuky/TIGER_data/New_tiger/'
  resPath="/data3/zhuky/TIGER_data/New_tiger/img/"
}else{
  Path='/bakup/tiger/'
  resPath="/bakup/tiger/img/"
}


Args <- commandArgs(T)

# Args <- c("CAC","B_C2_RNR1","B_C4_RNR2")

cancer.type <- Args[1]
celltype1 <- Args[2] #All\Tcell\Bcell
celltype2 <-  Args[3]

maintitle <- paste(cancer.type, celltype1, celltype2,sep="-")

crosstalk.table <- fread(paste0(Path,"crosstalk/",cancer.type,"_Crosstalk.mean.tsv"),sep = "\t")
selected.cols.index <- intersect(grep(celltype1,colnames(crosstalk.table)),grep(celltype2,colnames(crosstalk.table)))
selected.cols <- colnames(crosstalk.table)[c(1,selected.cols.index)]
output.table <- crosstalk.table[, ..selected.cols]
output.table <- output.table[which(apply(output.table[,lapply(.SD, as.numeric),.SDcols = -c("gene")], 1, sum)!=0),]
table.json <- toJSON(pretty=TRUE, output.table)
cat(table.json, file = (con <- file(paste0(resPath,maintitle,".json"), "w", encoding = "UTF-8")))
close(con)
cat(maintitle)
