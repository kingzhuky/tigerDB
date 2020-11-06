library(stringr);library(plyr);library(ggplot2);library(data.table);library(magrittr);library(ggpubr);
colors=c('#E5D2DD', '#53A85F', '#F1BB72', '#F3B1A0', '#D6E7A3', '#57C3F3', '#476D87',
         '#E95C59', '#E59CC4', '#AB3282', '#23452F', '#BD956A', '#8C549C', '#585658',
         '#9FA3A8', '#E0D4CA', '#5F3D69', '#C5DEBA', '#58A4C3', '#E4C755', '#F7F398',
         '#AA9A59', '#E63863', '#E39A35', '#C1E6F3', '#6778AE', '#91D0BE', '#B53E2B',
         '#712820', '#DCC1DD', '#CCE0F5',  '#CCC9E6', '#625D9E', '#68A180', '#3A6963',
         '#968175')
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


# Args <- c("BCC","All",'A1BG')
# Args <- c("PDAC","All",'CD3D')
# Args <- c("HCC","All",'CD3D')
# Args <- c("CCRCC","All",'CD8A')
# Args <- c("BTCC","CD4",'CD8A')
# Args <- c("CAC","All",'CD8A')

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
  
  pic.DEA=function(global.cluster , gene){
    now.meta=metadata[[global.cluster]]
    now.data=readRDS(paste0(Path,cancer_type,'/',cancer_type,'.gene/',global.cluster,'/',gene,'.rds'))
    my.data=now.data
    # 
    # now.data=data.frame(now.meta,gene=now.data$gene)
    # p=ggplot(now.data,aes(x=recluster,y=gene,fill=recluster))+stat_boxplot(geom = "errorbar",width=0.3)+geom_boxplot(outlier.colour = NA)+mytheme+
    #   theme(legend.position = 'none',axis.title.x = element_blank())+labs(y='Gene Expression')+theme(axis.ticks = element_blank(),plot.title = element_text(size=10, hjust = 0))
    # now.data=p+scale_fill_manual(values = colors)
    # now.data$labels$title=gene
    # maintitle1=paste0(maintitle,'.p1.png')
    # ggsave(paste0(resPath,maintitle1),now.data,width = 8)
    # 
    # 
    # 
    # now.now.data=data.frame(now.meta[,c('tSNE_1','tSNE_2','recluster')],gene=my.data$gene)
    # 
    # #now.now.data=now.now.data[now.now.data$recluster %in% sub.cluster,]
    # now.now.data[now.now.data$gene>3,'gene']=3
    # now.now.data[now.now.data$gene< -3,'gene']= -3
    # p=ggplot(now.now.data,aes(x=tSNE_1,y=tSNE_2,color=gene))+geom_point(size=0.5)+scale_color_gradientn(colors = c('#cacaca30','#ffbf8750','red'))+mytheme
    # maintitle2=paste0(maintitle,'.p2.png')
    # ggsave(paste0(resPath,'',maintitle2),p,width = 5.5,dpi=100,height = 5)
    # maintitle5=paste(maintitle1,maintitle2,sep=",")
    
    if(length(unique(now.meta$Response))>1){
      now.now.data=data.frame(now.meta,gene=my.data$gene)
      now.now.data=data.frame(now.meta,gene=now.now.data$gene)
      #now.now.data=now.now.data[now.now.data$recluster %in% sub.cluster,]
      now.now.data=now.now.data[now.now.data$Tissue=='Tumor',]
      p=ggplot(now.now.data,aes(x=recluster,y=gene,fill=Response))+geom_boxplot(outlier.colour = NA)+mytheme+scale_fill_manual(values = c('#016af3','#f34b01'))+ylim(-1,4)+
        stat_compare_means(aes(group=Response,label = ..p.signif..),method ='wilcox')+theme(axis.title = element_blank(),axis.text.x = element_text(angle=30,hjust=0.5, vjust=0.5,size = rel(1.2),color="black"))
      maintitle3=paste0(maintitle,'.p1.png')
      ggsave(paste0(resPath,'',maintitle3),p,width = 150,height =110, unit = "mm", dpi=100)
      maintitle5=paste(maintitle3,sep=",")
      
      # now.now.data=data.frame(now.meta[,c('tSNE_1','tSNE_2','recluster')],gene=my.data$gene)
      # 
      # #now.now.data=now.now.data[now.now.data$recluster %in% sub.cluster,]
      # now.now.data[now.now.data$gene>3,'gene']=3
      # now.now.data[now.now.data$gene< -3,'gene']= -3
      # p=ggplot(now.now.data,aes(x=tSNE_1,y=tSNE_2,color=gene))+geom_point(size=0.5)+scale_color_gradientn(colors = c('#cacaca30','#ffbf8750','red'))+mytheme
      now.now.data=data.frame(now.meta[,c('tSNE_1','tSNE_2','recluster','Response')],gene=my.data$gene)
      p=ggplot(now.now.data,aes(x=tSNE_1,y=tSNE_2,color=Response))+geom_point(size=0.5)+scale_color_manual(values = c('#016af3','#f34b01'))+mytheme
      maintitle7=paste0(maintitle,'.p7.png')
      ggsave(paste0(resPath,'',maintitle7),p,width = 150,height =110, unit = "mm", dpi=100)
      maintitle5=paste(maintitle5,maintitle7,sep=",")
    }
    if(length(unique(now.meta$Tissue))>1){
      now.now.data=data.frame(now.meta,gene=my.data$gene)
      now.now.data=data.frame(now.meta,gene=now.now.data$gene)
      #now.now.data=now.now.data[now.now.data$recluster %in% sub.cluster,]
      p=ggplot(now.now.data,aes(x=recluster,y=gene,fill=Tissue))+geom_boxplot(outlier.colour = NA)+mytheme+scale_fill_manual(values =c('#016af3','#f34b01','#f5e31b'))+ylim(-1,4)+
        stat_compare_means(aes(group=Tissue,label = ..p.signif..),method ='wilcox',label.y =3.8)+theme(axis.title = element_blank(),axis.text.x = element_text(angle=30,hjust=0.5, vjust=0.5,size = rel(1.2),color="black"))
      maintitle4=paste0(maintitle,'.p3.png')
      ggsave(paste0(resPath,'',maintitle4),p,width = 150,height =110, unit = "mm", dpi=100)
      maintitle5=paste(maintitle4,sep=",")
      
      now.now.data=data.frame(now.meta[,c('tSNE_1','tSNE_2','recluster','Tissue')],gene=my.data$gene)
      p=ggplot(now.now.data,aes(x=tSNE_1,y=tSNE_2,color=Tissue))+geom_point(size=0.5)+scale_color_manual(values = c('#016af3','#f34b01','#f5e31b'))+mytheme
      maintitle6=paste0(maintitle,'.p4.png')
      ggsave(paste0(resPath,'',maintitle6),p,width = 150,height =110, unit = "mm", dpi=100)
      maintitle5=paste(maintitle5,maintitle6,sep=",")
    }  
    return(maintitle5)
  }
  
  maintitle5=pic.DEA(global.cluster , gene)
  
  cat(maintitle5)
}else{
  cat(0)
}
