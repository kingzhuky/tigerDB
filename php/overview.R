library(stringr);library(plyr);library(ggplot2);library(data.table);library(magrittr);library(ggpubr);
library(pheatmap)
colors=c("#cc4a5399",'#00ADDB99','#7142AC99',"#42B54099",'#00008099','#07702b99',"#7FFF0099","#AD002A","#ED000099",'#ABD20599','#F0BE7E','#4D221399',"#FDAF9199",'#85E1D099','#C979CD99','#F26A1299',"#ADB6B699",'#4B79AB99',"#0099B499",'#FF149399','#00800099',"#1B191999")
my36colors <-c('#D6E7A3',"orange1", 'lightblue','#7142AC',"darkcyan","royalblue1","red3",'#53A85F',"deeppink",
               "mediumvioletred","gold","darkorange2", "tan2","darkorange2","darkorchid","chocolate4","darkred","lightskyblue","gold1")



mytheme <- theme_bw() + 
  theme(plot.title=element_text(size=rel(2),hjust=0.5),
        axis.title=element_text(size=rel(1)),
        axis.text.x = element_text(angle=0,hjust=0.5, vjust=0.5,size = rel(1.2),color="black"),
        axis.text.y = element_text(angle=0,hjust=0.5, vjust=0.5,size = rel(1.2),color="black"),
        panel.grid.major=element_line(color="grey96"),
        panel.grid.minor=element_line(color="grey96"),
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

#Args <- c("PDAC","Myeloid")
#Args <- c("PDAC","Tcell")
#Args <- c("PDAC","Myeloid")
cancer_type=Args[1]
global.cluster=Args[2] #All\Tcell\Bcell
# sub.cluster <- unlist(strsplit(Args[3] %>% str_replace_all('-',' '),split=',')) #T cell_B cell_pDC_NK

metadata=readRDS(paste0(Path,cancer_type,'/',cancer_type,'/',cancer_type,'.metadata.rds'))
sub.cluster <- metadata[[global.cluster]]$recluster %>% unique()


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
  names(my36colors)=levels(as.factor(meta$recluster))
  my36colors[setdiff(unique(meta$recluster)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             ,sub.cluster)]='#aeaeb140'
  
  #----分群图-----
  p1=ggplot(meta,aes(x=UMAP_1,y=UMAP_2,color=recluster))+geom_point(size=0.3)+mytheme+scale_color_manual(values = my36colors)+
    guides(color = guide_legend(override.aes = list(size = 3),title = NULL))+ theme(
    panel.border=element_rect(color="white",size=1),axis.line=element_line(color="white",size=0.5),
    axis.text.x = element_text(angle=0,hjust=0.5, vjust=0.5,size = rel(1.2),color="white"),axis.ticks = element_blank(),
    axis.text.y = element_text(angle=0,hjust=0.5, vjust=0.5,size = rel(1.2),color="white"),plot.title = element_text(size=15)
    )
   
  
    
    
    pic.name1=paste('umap',cancer_type,global.cluster,paste(sub.cluster,collapse = "_"),sep='-')
  ggsave(paste0(resPath,pic.name1,'.png'),width =120,height =80, unit = "mm", dpi=100,p1)
  
  #-----饼图-------
  table.pic=meta$recluster %>% table() %>% data.frame()
  table.pic1=meta$recluster%>% table() %>% prop.table() %>% data.frame()
  table.pic1$Freq=table.pic1$Freq*100
  table.pic=data.frame(table.pic,prop=table.pic1$Freq)
  
  pic.name2=paste('pie',cancer_type,global.cluster,paste(sub.cluster,collapse = "_"),sep='-')
  
  png(paste0(resPath,pic.name2,'.png'),width = 120, height =80, units = "mm",res = 100)
  pie(table.pic$Freq,labels=paste0(table.pic$.,' (',round(table.pic$prop,3),'%)'),col= my36colors,cex=0.8)

  dev.off()
  
  
  #----组织特异性图-------
  meta=meta[meta$recluster %in% sub.cluster,]
  if(!is.null(levels(meta$Response))){
    now.meta=meta %>% data.table() %$% .[,.N,.(recluster,Response,Patient)] %>% data.frame()
    now.meta= ddply(now.meta,'Patient',transform,per=N/sum(N))
    now.meta=now.meta[now.meta$recluster %in% sub.cluster,]
    now.meta$per=now.meta$per*100
    
    
    p2=ggplot(now.meta,aes(x=recluster,y=per,color=Response))+geom_boxplot(outlier.colour = NA)+scale_color_manual(values = c('#016af3','#f34b01'))+mytheme+
      geom_jitter(aes(x=recluster,y=per,color=Tissue),position = position_jitterdodge(),size=1,shape=1)+
      stat_compare_means(aes(group=Tissue,label = ..p.signif..),method ='wilcox')+theme(axis.title.x = element_blank())+labs(y=' (%) of cells')+
      theme(axis.text.x = element_text(angle=-20,hjust=0, vjust=1,size = rel(1.5),color="black"),
            axis.text.y = element_text(angle=0,hjust=0.5, vjust=0.5,size = rel(1.5),color="black"),
            panel.grid.major=element_line(color="grey95"),
            panel.grid.minor=element_line(color="grey95"),plot.title = element_text(size=15))
    
    pic.name3=paste('Boxplot-Response',cancer_type,global.cluster,paste(sub.cluster,collapse = "_"),sep='-')
    if(global.cluster=='Tcell'){
      ggsave(paste0(resPath,pic.name3,'.png'),p2,width = 120,height =80, unit = "mm", dpi=100)
    }else{
      ggsave(paste0(resPath,pic.name3,'.png'),p2,width = 200,height =80, unit = "mm", dpi=100)
    }
    
      }
  if(sum(meta$Tissue=='Tumor')!=nrow(meta)){
    now.meta=meta %>% data.table() %$% .[,.N,.(recluster,Tissue,Patient)] %>% data.frame()
    now.meta= ddply(now.meta,'Patient',transform,per=N/sum(N))
    now.meta=now.meta[now.meta$recluster %in% sub.cluster,]
    now.meta$per=now.meta$per*100
    p2=ggplot(now.meta,aes(x=recluster,y=per,color=Tissue))+geom_boxplot(outlier.colour = NA)+scale_color_manual(values = c('#016af3','#f34b01','#f5e31b','green'))+mytheme+
      geom_jitter(aes(x=recluster,y=per,color=Tissue),position = position_jitterdodge(),size=1,shape=1)+
      stat_compare_means(aes(group=Tissue,label = ..p.signif..),method ='wilcox')+theme(axis.title.x = element_blank())+labs(y=' (%) of cells')+
      theme(axis.text.x = element_text(angle=-20,hjust=0, vjust=1,size = rel(1.2),color="black"),
            axis.text.y = element_text(angle=0,hjust=0.5, vjust=0.5,size = rel(1.2),color="black"),axis.title=element_text(size=rel(1.5)),
            panel.grid.major=element_line(color="grey95"),legend.text = element_text(size=15),legend.title =  element_text(size=15),
            panel.grid.minor=element_line(color="grey95"),plot.title = element_text(size=15))
    pic.name4=paste('Boxplot-tissue',cancer_type,global.cluster,paste(sub.cluster,collapse = "_"),sep='-')
    
    if(global.cluster=='Tcell'){
    ggsave(paste0(resPath,pic.name4,'.png'),p2,width = 120,height =80, unit = "mm", dpi=100)
    }else{
    ggsave(paste0(resPath,pic.name4,'.png'),p2,width = 200,height =80, unit = "mm", dpi=100)
    }
    
  }
  
  
  #----细胞类型特异性-------
  heatmap.markers=readRDS(paste0(Path,cancer_type,'/',cancer_type,'/Classical.markers.heatmap.rds'))
  heatmap.markers=heatmap.markers[[global.cluster]]

  pic.name5=paste('Heatmap',cancer_type,global.cluster,paste(sub.cluster,collapse = "_"),sep='-')
  
  if(global.cluster=='Tcell'){
    ggsave(paste0(resPath,pic.name5,'.png'), plot = print(heatmap.markers),width = 120,height =80, unit = "mm", dpi=100)
  }else{
    ggsave(paste0(resPath,pic.name5,'.png'), plot = print(heatmap.markers),width = 200,height =80, unit = "mm", dpi=100)
  }
  
  
  

  if(!is.null(levels(meta$Response)) & sum(meta$Tissue=='Tumor')!=nrow(meta)){
    cat(paste(pic.name1,pic.name2,pic.name3,pic.name4,pic.name5,sep=','))
  }else if (is.null(levels(meta$Response)) & sum(meta$Tissue=='Tumor')!=nrow(meta)){
    cat(paste(pic.name1,pic.name2,pic.name4,pic.name5,sep=','))
  }else if (!is.null(levels(meta$Response)) & sum(meta$Tissue=='Tumor')==nrow(meta)){
    cat(paste(pic.name1,pic.name2,pic.name4,pic.name5,sep=','))
  }else{
    cat(paste(pic.name1,sep=','))
  }
}

pic.overview(metadata, global.cluster , sub.cluster )


