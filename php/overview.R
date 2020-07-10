library(stringr);library(plyr);library(ggplot2);library(data.table);library(magrittr);library(ggpubr);
library(pheatmap)
colors=c("#cc4a5399",'#00ADDB99','#7142AC99',"#42B54099",'#00008099','#07702b99',"#7FFF0099","#AD002A","#ED000099",'#ABD20599','#F0BE7E','#4D221399',"#FDAF9199",'#85E1D099','#C979CD99','#F26A1299',"#ADB6B699",'#4B79AB99',"#0099B499",'#FF149399','#00800099',"#1B191999")
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

#Args <- c("BCC","All","T-cell,B-cell,pDC,NK")
#Args <- c("HCC","All","T-cell,B-cell,CAF,TAM")
#Args <- c("TNBC","All","CD8_γδ,Myeloid,CD4_IL7R+,CD4_RGCC+")
#Args <- c("PDAC","All","Acinar,Ductal,Myeloid,T-cell")
#Args <- c("NSCLC","All","Plasma,Myeloid,Malignant,T-cell")



cancer_type=Args[1]
global.cluster=Args[2] #All\Tcell\Bcell
sub.cluster <- unlist(strsplit(Args[3] %>% str_replace_all('-',' '),split=',')) #T cell_B cell_pDC_NK

metadata=readRDS(paste0(Path,cancer_type,'/',cancer_type,'/',cancer_type,'.metadata.rds'))

# 
# metadata[['All']][,'Tissue']='Tumor'
# metadata[['Tcell']][,'Tissue']='Tumor'
# metadata[['All']][,'Response']='No.have'
# metadata[['Tcell']][,'Response']='No.have'
# 
# saveRDS(metadata,paste0(Path,cancer_type,'/',cancer_type,'/',cancer_type,'.metadata.rds'))

#------全局概览-------
pic.overview=function(metadata , global.cluster , sub.cluster){
  meta=metadata[[global.cluster]]
  names(colors)=levels(as.factor(meta$recluster))
  colors[setdiff(unique(meta$recluster),sub.cluster)]='#aeaeb140'
  p1=ggplot(meta,aes(x=tSNE_1,y=tSNE_2,color=recluster))+geom_point(size=0.3)+mytheme+scale_color_manual(values = colors)+
    guides(color = guide_legend(override.aes = list(size = 3),title = NULL))
  pic.name1=paste('tsne',cancer_type,global.cluster,paste(sub.cluster,collapse = "_"),sep='-')
  ggsave(paste0(resPath,pic.name1,'.png'),width = 6,height = 5,dpi=100,p1)
  
  
  meta=meta[meta$recluster %in% sub.cluster,]
  if(!is.null(levels(meta$Response))){
    now.meta=meta %>% data.table() %$% .[,.N,.(recluster,Response,Patient)] %>% data.frame()
    now.meta= ddply(now.meta,'Patient',transform,per=N/sum(N))
    now.meta=now.meta[now.meta$recluster %in% sub.cluster,]
    p2=ggplot(now.meta,aes(x=recluster,y=per,color=Response))+geom_boxplot()+scale_color_manual(values = c('blue','red'))+mytheme+
      geom_jitter(aes(x=recluster,y=per,color=Response),position = position_jitterdodge())+
      stat_compare_means(aes(group=Response,label = ..p.signif..),method ='wilcox')+theme(axis.title.x = element_blank())+labs(y=' (%) of cells')
    pic.name2=paste('Boxplot-Response',cancer_type,global.cluster,paste(sub.cluster,collapse = "_"),sep='-')
    ggsave(paste0(resPath,pic.name2,'.png'),p2)
    
    
    now.meta=meta[meta$Tissue=='Tumor',]
    Response.per=now.meta$Response %>% table() %>% prop.table() %>% data.frame()
    expect=now.meta$recluster %>% table() %>% data.table()
    expect=expect[expect$N!=0,]
    expect.now=(matrix(Response.per$Freq)%*% t(matrix(expect$N)) %>% t())
    
    observed=now.meta %>% data.table() %$% .[,.N,.(recluster,Response)] %>% data.frame()
    observed= dcast(observed,recluster~Response)
    rownames(observed)=observed$recluster
    observed=observed[,-1]
    observed[is.na(observed)]=0
    Resoe=observed/expect.now
    Resoe=Resoe[rownames(Resoe) %in% sub.cluster,]
    bk = unique(c(seq(0,2, length=100)))
    p3=pheatmap(Resoe,cluster_rows = F,cluster_cols = F,display_numbers = T,number_color = 'black',breaks=bk,fontsize = 12, color=colorRampPalette(c("lightblue" , "white","red"),bias=1)(100))
    pic.name3=paste('Heatmap-Response',cancer_type,global.cluster,paste(sub.cluster,collapse = "_"),sep='-')
    ggsave(paste0(resPath,pic.name3,'.png'), plot = print(p3), units ='in')
  }
  if(sum(meta$Tissue=='Tumor')!=nrow(meta)){
    now.meta=meta %>% data.table() %$% .[,.N,.(recluster,Tissue,Patient)] %>% data.frame()
    now.meta= ddply(now.meta,'Patient',transform,per=N/sum(N))
    now.meta=now.meta[now.meta$recluster %in% sub.cluster,]
    p2=ggplot(now.meta,aes(x=recluster,y=per,color=Tissue))+geom_boxplot()+scale_color_manual(values = c('blue','red'))+mytheme+
      geom_jitter(aes(x=recluster,y=per,color=Tissue),position = position_jitterdodge())+
      stat_compare_means(aes(group=Tissue,label = ..p.signif..),method ='wilcox')+theme(axis.title.x = element_blank())+labs(y=' (%) of cells')
    pic.name4=paste('Boxplot-tissue',cancer_type,global.cluster,paste(sub.cluster,collapse = "_"),sep='-')
    ggsave(paste0(resPath,pic.name4,'.png'),p2)

    now.meta=meta
    Tissue.per=now.meta$Tissue %>% table() %>% prop.table() %>% data.frame()
    expect=now.meta$recluster %>% table() %>% data.table()
    expect=expect[expect$N!=0,]
    expect.now=(matrix(Tissue.per$Freq)%*% t(matrix(expect$N)) %>% t())
    
    observed=now.meta %>% data.table() %$% .[,.N,.(recluster,Tissue)] %>% data.frame()
    observed= dcast(observed,recluster~Tissue)
    rownames(observed)=observed$recluster
    observed=observed[,-1]
    observed[is.na(observed)]=0
    Resoe=observed/expect.now
    Resoe=Resoe[rownames(Resoe) %in% sub.cluster,]
    bk = unique(c(seq(0,2, length=100)))
    p3=pheatmap(Resoe,cluster_rows = F,cluster_cols = F,display_numbers = T,number_color = 'black',breaks=bk,fontsize = 12, color=colorRampPalette(c("lightblue" , "white","red"),bias=1)(100))
    pic.name5=paste('Heatmap-tissue',cancer_type,global.cluster,paste(sub.cluster,collapse = "_"),sep='-')
    ggsave(paste0(resPath,pic.name5,'.png'), plot = print(p3), units ='in')
  }

  if(!is.null(levels(meta$Response)) & sum(meta$Tissue=='Tumor')!=nrow(meta)){
    cat(paste(pic.name1,pic.name2,pic.name3,pic.name4,pic.name5,sep=','))
  }else if (is.null(levels(meta$Response)) & sum(meta$Tissue=='Tumor')!=nrow(meta)){
    cat(paste(pic.name1,pic.name4,pic.name5,sep=','))
  }else if (!is.null(levels(meta$Response)) & sum(meta$Tissue=='Tumor')==nrow(meta)){
    cat(paste(pic.name1,pic.name2,pic.name3,sep=','))
  }else{
    cat(paste(pic.name1,sep=','))
  }
}

pic.overview(metadata, global.cluster , sub.cluster )


