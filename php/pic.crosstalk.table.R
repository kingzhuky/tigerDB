library(data.table)
library(jsonlite)

if(Sys.info()[1]=="Windows"){
  Path='D:/tiger/'
  resPath="D:/tiger/img/"
}else{
  Path='/bakup/tiger/'
  resPath="/bakup/tiger/img/"
}

Args <- commandArgs(T)
#Args <- c("PDAC","All",'CD3D','CD3E')
cancer_type=Args[1]
celltype=Args[2] #All\Tcell\Bcell
maintitle = paste("crosstalk-",cancer_type,celltype,sep="-")
crosstalk.table = fread(paste0(Path,cancer_type,'/',cancer_type,'/','Crosstalk.mean.tsv'),sep = "\t")
corelated.col = colnames(crosstalk.table)[grep(celltype,colnames(crosstalk.table))]
output.table = crosstalk.table[, ..corelated.col]

table.json <- toJSON(pretty=TRUE, output.table)
cat(table.json, file = (con <- file(paste0(resPath,maintitle,".json"), "w", encoding = "UTF-8")))
close(con)
cat(maintitle)
