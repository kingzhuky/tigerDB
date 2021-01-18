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
  Path='D:/tiger/'
  resPath="D:/tiger/img/"
}else{
  Path='/bakup/tiger/'
  resPath="/bakup/tiger/img/"
}

Args <- commandArgs(T)

#Args <- c("BCC","All",'CXCL13','CD200','T cell','spearman')
#Args <- c("PDAC","All",'CD3D','CD3E','Ductal','spearman',0)
cancer_type=Args[1]
global.cluster=Args[2]
its.gene=Args[3] #All\Tcell\Bcell
click.gene = Args[4]
click.cluster <-Args[5] #unlist(strsplit(Args[5]%>% str_replace_all('-',' '),split=',')) #T cell_B cell_pDC_NK
method=Args[6]
delete.zero=as.numeric(Args[7])

maintitle <- paste(paste(cancer_type,collapse = "_"),paste(global.cluster,collapse = "_"),
                   its.gene,click.gene,click.cluster,method,delete.zero,sep="-")
metadata=readRDS(paste0(Path,cancer_type,'/',cancer_type,'/',cancer_type,'.metadata.rds'))
metadata=metadata[[global.cluster]]

names.gene=c(its.gene=its.gene,click.gene=click.gene)
its.gene=readRDS(paste0(Path,cancer_type,'/',cancer_type,'.gene/',global.cluster,'/',its.gene,'.rds'))
click.gene=readRDS(paste0(Path,cancer_type,'/',cancer_type,'.gene/',global.cluster,'/',click.gene,'.rds'))


now.data=data.frame(cluster=metadata[as.numeric(rownames(click.gene)),'recluster'],its.gene=its.gene$Integrate,click.gene=click.gene$Integrate)
now.data=now.data[now.data$cluster %in% click.cluster,]


if(delete.zero==1){
  nouse=table(now.data$its.gene) %>% data.frame()
  nouse1=table(now.data$click.gene) %>% data.frame()
  now.data=now.data[now.data$its.gene!=nouse[nouse$Freq==max(nouse$Freq),'Var1'] & now.data$click.gene!=nouse1[nouse1$Freq==max(nouse1$Freq),'Var1'],]
}


sta=c(pvalue=cor.test(now.data$its.gene,now.data$click.gene,method = method)[['p.value']] %>% round(4),
        r=cor.test(now.data$its.gene,now.data$click.gene,method = method)[['estimate']]%>% round(4))
  
p=ggplot(now.data,aes(x=its.gene,y=click.gene))+geom_point(alpha=0.05)+mytheme+stat_smooth(method = lm,level=0.95,size=0.5,color='#1b79f5')+
    geom_rug(size=0.2,length = unit(0.02, "npc"))+annotate('text',x=-Inf,y=Inf,label=paste0('r=',sta[2],'\np=',sta[1]),hjust=-0.3,vjust=2)+
    labs(x=paste0(names.gene['its.gene'],' Expression'),y=paste0(names.gene['click.gene'],' Expression'))+labs(title = paste0('Correlation between ',names.gene['its.gene'],' and ',names.gene['click.gene']))+theme(plot.title = element_text(size=15))
ggsave(paste0(resPath,maintitle,'.png'),p,dpi = 100,width = 5,height = 5)

cat(maintitle)

