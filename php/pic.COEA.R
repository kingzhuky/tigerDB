library(stringr);library(plyr);library(ggplot2);library(data.table);library(magrittr);library(ggpubr);library(jsonlite)

mytheme <- theme_bw() + 
  theme(plot.title=element_text(size=rel(2),hjust=0.5),
        axis.title=element_text(size=rel(1)),
        axis.text.x = element_text(angle=0,hjust=0.5, vjust=0.5,size = rel(1.2)),
        axis.text.y = element_text(angle=0,hjust=0.5, vjust=0.5,size = rel(1.2)),
        panel.grid.major=element_line(color="white"),
        panel.grid.minor=element_line(color="white"),
        panel.border=element_rect(color="black",size=1),
        axis.line=element_line(color="black",size=0.5))


if(Sys.info()[1]=="Windows"){
  Path='E:/hongwan/'
  resPath="D:/javascript/tigetData/"
}else{
  Path='/bakup/tiger/'
  resPath="/bakup/tiger/img/"
}

Args <- commandArgs(T)

#Args <- c("BCC","All",'CXCL13')

cancer_type=Args[1]
global.cluster=Args[2] #All\Tcell\Bcell
gene = Args[3]

maintitle <- paste(paste(cancer_type,collapse = "_"),paste(global.cluster,collapse = "_"),
                   gene,sep="-")
if(!file.exists(paste0(resPath,maintitle,".json"))){
  now.matrix=readRDS(paste0(Path,cancer_type,'/',cancer_type,'.coexp/',global.cluster,'/',gene,'.rds'))
  now.matrix=data.table(gene=rownames(now.matrix),now.matrix)
  SIG.cor.matrix.json <-  now.matrix%>%toJSON(pretty=TRUE,.)
  cat(SIG.cor.matrix.json, file = (con <- file(paste0(resPath,maintitle,".json"), "w", encoding = "UTF-8")))
  close(con)
}
  

cat(maintitle)
