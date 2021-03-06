library(stringr);library(plyr);library(ggplot2);library(data.table);library(magrittr);library(ggpubr);
colors=c('#D6E7A3',"orange1", 'lightblue','#7142AC',"darkcyan","royalblue1","red3",'#53A85F',"deeppink",
         "mediumvioletred","gold","darkorange2", "tan2","darkorange2","darkorchid","chocolate4","darkred","lightskyblue","gold1")
mytheme <- theme_bw() + 
  theme(plot.title=element_text(size=rel(2),hjust=0.5),
        axis.title=element_text(size=rel(1)),
        axis.text.x = element_text(angle=0,hjust=0.5, vjust=0.5,size = rel(1.2),color="black"),
        axis.text.y = element_text(angle=0,hjust=0.5, vjust=0.5,size = rel(1.2),color="black"),
        panel.grid.major=element_line(color="white"),
        panel.grid.minor=element_line(color="white"),
        panel.border=element_rect(color="black",size=1),
        axis.line=element_line(color="black",size=0.5))
if(Sys.info()[1]=="Windows"){
  Path='D:/tiger/'
  resPath="D:/tiger/img/"
}else{
  Path='/bakup/tiger/'
  resPath="/bakup/tiger/img/"
}

Args <- commandArgs(T)

#Args <- c("PDAC","Myeloid",'CD1C')
cancer_type=Args[1]
global.cluster=Args[2] #All\Tcell\Bcell
#sub.cluster <- unlist(strsplit(Args[3]%>% str_replace_all('-',' '),split=',')) #T cell_B cell_pDC_NK
gene = Args[3]



maintitle <- paste(paste(cancer_type,collapse = "_"),paste(global.cluster,collapse = "_"),
                   gene,sep="-")


genefile=paste0(Path,cancer_type,'/',cancer_type,'.gene/',global.cluster,'/',gene,'.rds')

if (file.exists(genefile)){
  
  
  now.meta=paste0(Path,cancer_type,'/',cancer_type,'/',cancer_type,'.metadata.rds')
  
  metadata=readRDS(now.meta)
  now.meta=metadata[[global.cluster]]
  now.data=readRDS(paste0(Path,cancer_type,'/',cancer_type,'.gene/',global.cluster,'/',gene,'.rds'))

  if(ncol(now.data)==2){
    now.data=data.frame(now.meta,gene=now.data$Integrate)
  }else{
    now.data=data.frame(now.meta,gene=now.data$RNA)
  }
  my.data=now.data
    
  p=ggplot(now.data,aes(x=recluster,y=gene,fill=recluster))+geom_boxplot(outlier.colour = NA,linetype='dashed')+stat_boxplot(outlier.colour = NA,aes(ymin=..lower..,ymax=..upper..))+
      stat_boxplot(geom = "errorbar",aes(ymin=..ymax..),width=0.2,color="black")+
      stat_boxplot(geom = "errorbar",aes(ymax=..ymin..),width=0.2,color="black")+mytheme+
      theme(legend.position = 'none',axis.title.x = element_blank())+labs(y='Gene Expression')+
      theme(axis.ticks = element_blank(),axis.title=element_text(size=rel(1.2)))+
      scale_fill_manual(values = colors)+theme(axis.text.x = element_text(angle=45,hjust=1, vjust=1,size = rel(1.2),color="black"),axis.text.y = element_text(size = rel(1.5),color="black"),plot.title = element_text(size=15))
    

  length=now.data$recluster %>% unique() %>% length()
      
  maintitle1=paste0(maintitle,'.boxplot.marker.expression.png')
  ggsave(paste0(resPath,maintitle1),p,width = length*12+12,height =80, unit = "mm", dpi=100)
    
    
    
  now.now.data=data.frame(now.meta[,c('UMAP_1','UMAP_2','recluster')],Expr=my.data$gene)
  now.now.data[now.now.data$Expr>3,'Expr']=3
  now.now.data[now.now.data$Expr< -3,'Expr']= -3
  p=ggplot(now.now.data,aes(x=UMAP_1,y=UMAP_2,color=Expr))+geom_point(size=0.5)+
    scale_color_gradientn(colors = c('#cacaca30','#ffbf8750','red'))+mytheme+ theme(
      panel.border=element_rect(color="white",size=1),axis.line=element_line(color="white",size=0.5),
      axis.text.x = element_text(angle=0,hjust=0, vjust=1,size = rel(1.2),color="white"),axis.ticks = element_blank(),
      axis.text.y = element_text(angle=0,hjust=0, vjust=1,size = rel(1.2),color="white"),plot.title = element_text(size=15),panel.grid.major=element_line(color="grey96"),
      panel.grid.minor=element_line(color="grey96")
    )
  
  maintitle2=paste0(maintitle,'.umap.expr.png')
  ggsave(paste0(resPath,'',maintitle2),p,width = 110,height =80, unit = "mm", dpi=100)
  maintitle5=paste(maintitle1,maintitle2,sep=",")


  cat(maintitle5)
}else{
  cat(0)
}
