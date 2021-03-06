library(stringr);library(plyr);library(ggplot2);library(data.table);library(magrittr);library(ggpubr);library(Hmisc);library(jsonlite);library(msigdbr);
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

#Args <- c("PDAC","Myeloid",'Apical junction')

cancer_type=Args[1]
global.cluster=Args[2] #All\Tcell\Bcell
#sub.cluster <- unlist(strsplit(Args[3]%>% str_replace_all('-',' '),split=',')) #T cell_B cell_pDC_NK
pathway = Args[3]

maintitle <- paste(paste(cancer_type,collapse = "_"),paste(global.cluster,collapse = "_"),gsub(" ","_",pathway),sep="-")

m_df=msigdbr(species = 'Homo sapiens',category = 'H')
hset=m_df %>% split(x=.$gene_symbol,f=.$gs_name)
names(hset)=names(hset) %>% str_remove('HALLMARK_') %>% tolower() %>% Hmisc::capitalize()%>% str_replace_all('_',' ')
hset=hset[[pathway]]


all.have.gene=list.files(paste0(Path,cancer_type,'/',cancer_type,'.gene/',global.cluster,'/')) %>% str_remove('\\.rds')
hset=hset[hset %in% all.have.gene]
gene.exp.list=list()
for(i in hset){
  genefile=readRDS(paste0(Path,cancer_type,'/',cancer_type,'.gene/',global.cluster,'/',i,'.rds'))
  gene.exp.list[[i]]=genefile[,'RNA']
}
gene.exp.list=data.frame(gene.exp.list) 
gene.exp.list1=gene.exp.list
gene.exp.list=gene.exp.list%>% apply(1,mean)

#rownames(gene.exp.list)=rownames(genefile)
now.meta=paste0(Path,cancer_type,'/',cancer_type,'/',cancer_type,'.metadata.rds')
metadata=readRDS(now.meta)
metadata=metadata[[global.cluster]]
metadata[,'score']=gene.exp.list



  
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
    #maintitle5=paste(maintitle1,maintitle2,sep=",")
    
    if(length(unique(metadata$Response))>1){

      #------Umap-----------
      p1=ggplot(metadata,aes(x=UMAP_1,y=UMAP_2,color=Response))+geom_point(size=0.3)+mytheme+scale_color_manual(values = colors[c(6,9,8,2)])+
        guides(color = guide_legend(override.aes = list(size = 3),title = NULL))+ theme(
          panel.border=element_rect(color="white",size=1),axis.line=element_line(color="white",size=0.5),
          axis.text.x = element_text(angle=0,hjust=0.5, vjust=0.5,size = rel(1.2),color="white"),axis.ticks = element_blank(),
          axis.text.y = element_text(angle=0,hjust=0.5, vjust=0.5,size = rel(1.2),color="white"),plot.title = element_text(size=15)
        )
      maintitle1=paste0(maintitle,'.umap.response')
      ggsave(paste0(resPath,maintitle1,'.png'),width =110,height =80, unit = "mm", dpi=100,p1)
      
      #---Gene expression Umap--------
      p=ggplot(metadata,aes(x=UMAP_1,y=UMAP_2,color=score))+geom_point(size=0.5)+
        scale_color_gradientn(colors = c('#cacaca30','#ffbf8750','red'))+mytheme+ theme(
          panel.border=element_rect(color="white",size=1),axis.line=element_line(color="white",size=0.5),
          axis.text.x = element_text(angle=0,hjust=0, vjust=1,size = rel(1.2),color="white"),axis.ticks = element_blank(),
          axis.text.y = element_text(angle=0,hjust=0, vjust=1,size = rel(1.2),color="white"),plot.title = element_text(size=15),panel.grid.major=element_line(color="grey96"),
          panel.grid.minor=element_line(color="grey96")
        )
      
      maintitle2=paste0(maintitle,'.umap.expr')
      ggsave(paste0(resPath,maintitle2,'.png'),width =110,height =80, unit = "mm", dpi=100,p)
      
      #---Gene expression boxplot--------
      p=ggplot(metadata,aes(x=recluster,y=score,fill=Response))+geom_boxplot(outlier.colour = NA)+mytheme+scale_fill_manual(values =colors[c(6,9,8,2)])+ylim(-1,2)+
        stat_compare_means(aes(group=Response,label = ..p.signif..),method ='wilcox',label.y =1.6)+
        theme(axis.title = element_blank(),axis.text.x = element_text(angle=30,hjust=0.5, vjust=0.5,size = rel(1.2),color="black"))+
        theme(axis.ticks = element_blank(),axis.title=element_text(size=rel(1.2)))+
        theme(axis.text.x = element_text(angle=45,hjust=1, vjust=1,size = rel(1.2),color="black"),axis.text.y = element_text(size = rel(1.5),color="black"),plot.title = element_text(size=15))+
        theme(axis.title.x=element_blank())+labs(y='Gene Expression')
      
      
      length=metadata$recluster %>% unique() %>% length()
      
      maintitle3=paste0(maintitle,'.boxplot.expr.res-nores')
      ggsave(paste0(resPath,'',maintitle3,".png"),p,width = length*12+40,height =80, unit = "mm", dpi=100)
      maintitle4=paste(maintitle1,maintitle2,maintitle3,sep=",")
      
      
      
      
      
      
      
      
    }
  
  
    if(length(unique(metadata$Tissue))>1){
      

      #------Umap-----------
      p1=ggplot(metadata,aes(x=UMAP_1,y=UMAP_2,color=Tissue))+geom_point(size=0.3)+mytheme+scale_color_manual(values = colors[c(6,9,8,2)])+
        guides(color = guide_legend(override.aes = list(size = 3),title = NULL))+ theme(
          panel.border=element_rect(color="white",size=1),axis.line=element_line(color="white",size=0.5),
          axis.text.x = element_text(angle=0,hjust=0.5, vjust=0.5,size = rel(1.2),color="white"),axis.ticks = element_blank(),
          axis.text.y = element_text(angle=0,hjust=0.5, vjust=0.5,size = rel(1.2),color="white"),plot.title = element_text(size=15)
        )
      maintitle1=paste0(maintitle,'.umap.tissue')
      ggsave(paste0(resPath,maintitle1,'.png'),width =110,height =80, unit = "mm", dpi=100,p1)
      
      #---Gene expression Umap--------
      p=ggplot(metadata,aes(x=UMAP_1,y=UMAP_2,color=score))+geom_point(size=0.5)+
        scale_color_gradientn(colors = c('#cacaca30','#ffbf8750','red'))+mytheme+ theme(
          panel.border=element_rect(color="white",size=1),axis.line=element_line(color="white",size=0.5),
          axis.text.x = element_text(angle=0,hjust=0, vjust=1,size = rel(1.2),color="white"),axis.ticks = element_blank(),
          axis.text.y = element_text(angle=0,hjust=0, vjust=1,size = rel(1.2),color="white"),plot.title = element_text(size=15),panel.grid.major=element_line(color="grey96"),
          panel.grid.minor=element_line(color="grey96")
        )
      
      maintitle2=paste0(maintitle,'.umap.expr')
      ggsave(paste0(resPath,maintitle2,'.png'),width =110,height =80, unit = "mm", dpi=100,p)
      
      #---Gene expression boxplot--------
       p=ggplot(metadata,aes(x=recluster,y=score,fill=Tissue))+geom_boxplot(outlier.colour = NA)+mytheme+scale_fill_manual(values =colors[c(6,9,8,2)])+ylim(-1,2)+
        stat_compare_means(aes(group=Tissue,label = ..p.signif..),method ='wilcox',label.y =1.6)+
        theme(axis.title = element_blank(),axis.text.x = element_text(angle=30,hjust=0.5, vjust=0.5,size = rel(1.2),color="black"))+
        theme(axis.ticks = element_blank(),axis.title=element_text(size=rel(1.2)))+
        theme(axis.text.x = element_text(angle=45,hjust=1, vjust=1,size = rel(1.2),color="black"),axis.text.y = element_text(size = rel(1.5),color="black"),plot.title = element_text(size=15))+
        theme(axis.title.x=element_blank())+labs(y='Gene Expression')
        
      
      length=metadata$recluster %>% unique() %>% length()
      
      maintitle3=paste0(maintitle,'.boxplot.expr.TN')
      ggsave(paste0(resPath,'',maintitle3,'.png'),p,width = length*12+40,height =80, unit = "mm", dpi=100)
      maintitle4=paste(maintitle1,maintitle2,maintitle3,sep=",")

  cat(maintitle4)
}else{
  cat(0)
}

new.meta=data.frame(recluster=metadata$recluster,gene.exp.list1)
new.meta=  new.meta %>% dplyr::group_by(recluster) %>% dplyr::summarise_all(mean) %>% data.frame()
rownames(new.meta)=new.meta[,1]
new.meta=new.meta[,-1]
new.meta=new.meta %>%t() %>% data.frame()
now.matrix=data.table(gene=rownames(new.meta),new.meta)
SIG.cor.matrix.json <-  now.matrix%>%toJSON(pretty=TRUE,.)
cat(SIG.cor.matrix.json, file = (con <- file(paste0(resPath,maintitle,".json"), "w", encoding = "UTF-8")))
close(con)


