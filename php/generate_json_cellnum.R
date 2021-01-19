library(data.table)
if(Sys.info()[7]=="zky"){
  Path='/data10/liuxf/New_Tiger/'
  resPath="D:/javascript/tigetData/"
}else{
  Path='/bakup/tiger/'
  resPath="/bakup/tiger/img/"
}

Args <- commandArgs(T)

#Args <- c("PDAC","Myeloid")
#Args <- c("PDAC","Tcell")
#Args <- c("PDAC","Myeloid")
dataset.id=Args[1]
global.cluster=Args[2] 

tmp.table <- fread(paste0(Path,"Cellnum/",dataset.id,".txt"))[GlobelCluster == global.cluster]
tmp.string <- apply(tmp.table,1,function(x){
    ifelse(names(x) == "GlobelCluster",NA,ifelse(x == 0,NA,ifelse(names(x) == "No.have",NA,paste0(names(x),": ",x))))
})
cellnum.string <- paste0(na.omit(tmp.string),collapse = ",")
cat(cellnum.string)