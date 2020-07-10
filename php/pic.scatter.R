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
  resPath="/bakup/tiger/"
}

Args <- commandArgs(T)

#Args <- c("BCC","All",'CXCL13','CD200','T cell','spearman')

cancer_type=Args[1]
global.cluster=Args[2]
its.gene=Args[3] #All\Tcell\Bcell
click.gene = Args[4]

click.cluster <- unlist(strsplit(Args[5]%>% str_replace_all('-',' '),split=',')) #T cell_B cell_pDC_NK

method=Args[6]
maintitle <- paste(paste(cancer_type,collapse = "_"),paste(global.cluster,collapse = "_"),
                   its.gene,click.gene,click.cluster,method,sep="-")

pic.scatter=function(its.gene,click.gene,click.cluster,method){
  names.gene=c(its.gene=its.gene,click.gene=click.gene)
  its.gene=readRDS(paste0(Path,cancer_type,'/',cancer_type,'.gene/',global.cluster,'/',its.gene,'.rds'))
  click.gene=readRDS(paste0(Path,cancer_type,'/',cancer_type,'.gene/',global.cluster,'/',click.gene,'.rds'))
  now.data=data.frame(cluster=its.gene$data$recluster,its.gene=its.gene$data$gene,click.gene=click.gene$data$gene)
  now.data=now.data[now.data$cluster %in% click.cluster,]
  sta=c(pvalue=cor.test(now.data$its.gene,now.data$click.gene,method = method)[['p.value']] %>% round(4),
        r=cor.test(now.data$its.gene,now.data$click.gene,method = method)[['estimate']]%>% round(4))
  
  p=ggplot(now.data,aes(x=its.gene,y=click.gene))+geom_point(alpha=0.05)+mytheme+stat_smooth(method = lm,level=0.95)+
    geom_rug(size=0.2,length = unit(0.02, "npc"))+annotate('text',x=-Inf,y=Inf,label=paste0('r=',sta[2],'\np=',sta[1]),hjust=-0.3,vjust=2)+
    labs(x=names.gene['its.gene'],y=names.gene['click.gene'])
  ggsave(paste0(resPath,'/img/',maintitle,'.png'),p,dpi = 100)
  
}


pic.scatter(its.gene,click.gene,click.cluster,method)


cat(maintitle)

