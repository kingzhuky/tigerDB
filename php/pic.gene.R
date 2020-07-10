library(stringr);library(plyr);library(ggplot2);library(data.table);library(magrittr);library(ggpubr);
colors=c("#cc4a53",'#00ADDB','#7142AC',"#42B540",'#000080','#07702b',"#7FFF00","#AD002A","#ED0000",'#ABD205','#F0BE7E','#4D2213',"#FDAF91",'#85E1D0','#C979CD','#F26A1299',"#ADB6B699",'#4B79AB99',"#0099B499",'#FF149399','#00800099',"#1B191999")

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


# Args <- c("BCC","All","T-cell,B-cell,pDC,NK",'CD3D')
# Args <- c("HCC","All","T-cell,B-cell,CAF,TAM",'CD3D')
# Args <- c("TNBC","All","CD8_γδ,Myeloid,CD4_IL7R+,CD4_RGCC+",'CD8A')
# Args <- c("PDAC","All","Acinar,Ductal,Myeloid,T-cell",'CD3D')
# Args <- c("NSCLC","All","Plasma,Myeloid,Malignant,T-cell",'CD8A')


cancer_type=Args[1]
global.cluster=Args[2] #All\Tcell\Bcell
sub.cluster <- unlist(strsplit(Args[3]%>% str_replace_all('-',' '),split=',')) #T cell_B cell_pDC_NK
gene = Args[4]


maintitle <- paste(paste(cancer_type,collapse = "_"),paste(global.cluster,collapse = "_"),
                   paste(sub.cluster,collapse = "_"),
                   gene,sep="-")


genefile=paste0(Path,cancer_type,'/',cancer_type,'.gene/',global.cluster,'/',gene,'.rds')

if (file.exists(genefile)){
  

  now.meta=paste0(Path,cancer_type,'/',cancer_type,'/',cancer_type,'.metadata.rds')
  
metadata=readRDS(genefile)

pic.DEA=function(global.cluster , sub.cluster, gene){
  now.meta=metadata[[global.cluster]]
  now.data=readRDS(paste0(Path,cancer_type,'/',cancer_type,'.gene/',global.cluster,'/',gene,'.rds'))
  now.data=now.data+scale_x_discrete(limits=sub.cluster)+scale_fill_manual(values = colors)
  now.data$labels$title=gene
  maintitle1=paste0(maintitle,'.p1.png')
  ggsave(paste0(resPath,maintitle1),now.data)
  now.now.data=now.data$data
  #now.now.data=now.now.data[now.now.data$recluster %in% sub.cluster,]
  now.now.data[now.now.data$gene>3,'gene']=3
  now.now.data[now.now.data$gene< -3,'gene']= -3
  p=ggplot(now.now.data,aes(x=tSNE_1,y=tSNE_2,color=gene))+geom_point(size=0.5)+scale_color_gradientn(colors = c('#cacaca30','white','red'))+mytheme
  maintitle2=paste0(maintitle,'.p2.png')
  ggsave(paste0(resPath,'',maintitle2),p,width = 5.5,dpi=100,height = 5)
  maintitle5=paste(maintitle1,maintitle2,sep=",")
  
  if(length(unique(now.meta$Response))>1){
    now.now.data=now.data$data
    now.now.data=data.frame(now.meta,gene=now.now.data$gene)
    now.now.data=now.now.data[now.now.data$recluster %in% sub.cluster,]
    now.now.data=now.now.data[now.now.data$Tissue=='Tumor',]
    p=ggplot(now.now.data,aes(x=recluster,y=gene,fill=Response))+geom_boxplot(outlier.colour = NA)+mytheme+scale_fill_manual(values = c('blue','red'))+ylim(-1,4)+
    stat_compare_means(aes(group=Response,label = ..p.signif..),method ='t.test')+theme(axis.title = element_blank())
    maintitle3=paste0(maintitle,'.p3.png')
    ggsave(paste0(resPath,'',maintitle3),p)
    maintitle5=paste(maintitle5,maintitle3,sep=",")
  }
  if(length(unique(now.meta$Tissue))>1){
    now.now.data=now.data$data
    now.now.data=data.frame(now.meta,gene=now.now.data$gene)
    now.now.data=now.now.data[now.now.data$recluster %in% sub.cluster,]
    p=ggplot(now.now.data,aes(x=recluster,y=gene,fill=Tissue))+geom_boxplot(outlier.colour = NA)+mytheme+scale_fill_manual(values =c('blue','red'))+ylim(-1,4)+
      stat_compare_means(aes(group=Tissue,label = ..p.signif..),method ='t.test')+theme(axis.title = element_blank())
    maintitle4=paste0(maintitle,'.p4.png')
    ggsave(paste0(resPath,'',maintitle4),p)
    maintitle5=paste(maintitle5,maintitle4,sep=",")
  }  
  return(maintitle5)
}

maintitle5=pic.DEA(global.cluster , sub.cluster, gene)

cat(maintitle5)
}else{
  cat(0)
}