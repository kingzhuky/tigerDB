library(stringr);library(plyr);library(ggplot2);library(data.table);library(magrittr);library(ggpubr);library(jsonlite)

colors=c('#D6E7A3',"orange1", 'lightblue','#7142AC',"darkcyan","royalblue1","red3",'#53A85F',"deeppink",
         "mediumvioletred","gold","darkorange2", "tan2","darkorange2","darkorchid","chocolate4","darkred","lightskyblue","gold1")

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
  Path='D:/tiger/'
  resPath="D:/tiger/img/"
}else{
  Path='/bakup/tiger/'
  resPath="/bakup/tiger/img/"
}

Args <- commandArgs(T)

#Args <- c("BCC","All",'CXCL13','CD200','T cell','spearman')
#Args <- c("PDAC","CD4",'Myeloid')
cancer_type=Args[1]
cluster1=Args[2]
cluster2=Args[3]




maintitle <- paste(paste(cancer_type,collapse = "_"),paste(cluster1,collapse = "_"),cluster2,sep="-")
metadata=readRDS(paste0(Path,cancer_type,'/',cancer_type,'/',cancer_type,'.metadata.rds'))


metadata=metadata[[1]]
metadata=metadata[!duplicated(metadata$Patient),]
rownames(metadata)=metadata$Patient


cluster.percent=readRDS(paste0(Path,cancer_type,'/',cancer_type,'/co-cluster.percent.rds'))
cluster.percent[,'Tissue']=metadata[cluster.percent$Patient,'Tissue'] 
cluster.percent=cluster.percent[cluster.percent$recluster %in% c(cluster1,cluster2),]
cluster.percent$per=cluster.percent$per*100
cluster.percent=cluster.percent[,c(1,2,3,5,4)]
cluster.percent=dcast(cluster.percent,Patient+Tissue~recluster)
cluster.percent[is.na(cluster.percent)]=0
 


sta=c(pvalue=cor.test(cluster.percent[,3],cluster.percent[,4],method = 'spearman')[['p.value']] %>% round(4),
      r=cor.test(cluster.percent[,3],cluster.percent[,4],method = 'spearman')[['estimate']]%>% round(4))

p=ggplot(cluster.percent,aes(x=cluster.percent[,3],y=cluster.percent[,4],colour=Tissue))+geom_point(alpha=0.5,size=3)+scale_colour_manual(values = colors[c(6,9,8,2)])+mytheme+stat_smooth(method = lm,level=0.99,size=0.5)+
  geom_rug(size=0.2,length = unit(0.02, "npc"))+annotate('text',x=-Inf,y=Inf,label=paste0('r=',sta[2],'\np=',sta[1]),hjust=-0.3,vjust=2)+
  labs(x=paste0('Percentage of ',cluster1,' cells (%)'),y=paste0('Percentage of ',cluster2,' cells (%)'))+theme(plot.title = element_text(size=15))

ggsave(paste0(resPath,maintitle,'.png'),p,dpi = 100,width = 6,height = 5)

cat(maintitle)
 
