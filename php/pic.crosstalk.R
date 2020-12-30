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


if(Sys.info()[8]=="zky"){
  Path='/data3/zhuky/TIGER_data/New_tiger/scped/'
  resPath="/data3/zhuky/TIGER_data/New_tiger/img/"
}else{
  Path='/bakup/tiger/'
  resPath="/bakup/tiger/img/"
}


Args <- commandArgs(T)

# Args <- c("CAC","HLA-DPA1_TNFSF9",'All.Acinar.B_C1_RPS4Y1')
Args <- c("CAC","CRTAM_CADM1","Tumor,CD4_C1_IL7R|CD8_C4_GNLY")

#Args <- c("PDAC","Tcell")
#Args <- c("PDAC","Myeloid")
cancer_type=Args[1]
pair=Args[2] #All\Tcell\Bcell
# sub.cluster <- unlist(strsplit(Args[3] %>% str_replace_all('-',' '),split=',')) #T cell_B cell_pDC_NK

gene1=(pair %>% str_split('_') %>% unlist())[1]
gene2=(pair %>% str_split('_') %>% unlist())[2]

name.gene1=gene1;name.gene2=gene2


cellpair=Args[3]

cell.type=cellpair%>% str_remove('\\w.+?[\\.|,]')

maintitle <- paste(paste(cancer_type,collapse = "_"),paste(pair,collapse = "_"),cellpair,sep="-")
maintitle <- gsub("[,|]","-",maintitle)


cell.type1=cell.type %>% str_extract('\\w.+?[\\.|]') %>% str_remove('[\\.|]')
cell.type2=cell.type %>% str_remove('\\w.+?[\\.|]')


type1=cell.type1;type2=cell.type2

metadata=readRDS(paste0(Path,cancer_type,'/',cancer_type,'/',cancer_type,'.metadata.rds'))

cell.type.list=list()
for(i in names(metadata)){
  cell.type.list[[i]]=data.frame(large.group=i,samll.group=metadata[[i]]$recluster %>% unique())
}
cell.type.list=Reduce(rbind,cell.type.list)



cell.type1=cell.type.list[cell.type.list$samll.group==cell.type1,'large.group'] %>% as.character()
cell.type2=cell.type.list[cell.type.list$samll.group==cell.type2,'large.group'] %>% as.character()

gene1=paste0(Path,cancer_type,'/',cancer_type,'.gene/',cell.type1,'/',gene1,'.rds')
gene2=paste0(Path,cancer_type,'/',cancer_type,'.gene/',cell.type2,'/',gene2,'.rds')







if (file.exists(gene1) & file.exists(gene2) ){


  gene1=readRDS(gene1)
  gene2=readRDS(gene2)
  gene1=data.frame(metadata[[cell.type1]],gene1)
  gene2=data.frame(metadata[[cell.type2]],gene2)
  
  gene1[gene1$recluster!=type1,'recluster']='Other cells'
  gene1[gene1$recluster!=type1,'RNA']=min(gene1$RNA)
  gene2[gene2$recluster!=type2,'recluster']='Other cells'
  gene2[gene2$recluster!=type2,'RNA']=min(gene2$RNA)
  gene1[gene1$recluster!=type1,'Tissue']=' Other cells'
  gene2[gene2$recluster!=type2,'Tissue']=' Other cells'
  
  #------Umap-type1----------
  p1=ggplot(gene1,aes(x=UMAP_1,y=UMAP_2,color=Tissue))+geom_point(size=0.3)+mytheme+scale_color_manual(values = c('#00000008',colors[c(6,9,8,2)]))+
    guides(color = guide_legend(override.aes = list(size = 3),title = NULL))+labs(title = paste0('Tissue in ',type1))+ theme(
      panel.border=element_rect(color="white",size=1),axis.line=element_line(color="white",size=0.5),
      axis.text.x = element_text(angle=0,hjust=0.5, vjust=0.5,size = rel(1.2),color="white"),axis.ticks = element_blank(),
      axis.text.y = element_text(angle=0,hjust=0.5, vjust=0.5,size = rel(1.2),color="white"),plot.title = element_text(size=15)
    )
  maintitle1=paste0(maintitle,'.umap.tissue.type1')
  ggsave(paste0(resPath,maintitle1,'.png'),width =110,height =80, unit = "mm", dpi=100,p1)
  
  
  #---Gene expression Umap--------
  gene1$Expr=gene1$RNA
  gene1[gene1$Expr>3,'Expr']=3

  p=ggplot(gene1,aes(x=UMAP_1,y=UMAP_2,color=Expr))+geom_point(size=0.5)+
    scale_color_gradientn(colors = c('#cacaca30','#ffbf8750','red'))+mytheme+ theme(
      panel.border=element_rect(color="white",size=1),axis.line=element_line(color="white",size=0.5),
      axis.text.x = element_text(angle=0,hjust=0, vjust=1,size = rel(1.2),color="white"),axis.ticks = element_blank(),
      axis.text.y = element_text(angle=0,hjust=0, vjust=1,size = rel(1.2),color="white"),plot.title = element_text(size=12),panel.grid.major=element_line(color="grey96"),
      panel.grid.minor=element_line(color="grey96")
    )+labs(title = paste0('UMAP Plot of ',name.gene1,' Expression in ',type1))
  
  maintitle2=paste0(maintitle,'.umap.expr.type1')
  ggsave(paste0(resPath,maintitle2,'.png'),width =100,height =80, unit = "mm", dpi=100,p)
  
  
  
  
  #------Umap-type2----------
  p1=ggplot(gene2,aes(x=UMAP_1,y=UMAP_2,color=Tissue))+geom_point(size=0.3)+mytheme+scale_color_manual(values = c('#00000008',colors[c(6,9,8,2)]))+
    guides(color = guide_legend(override.aes = list(size = 3),title = NULL))+labs(title = paste0('Tissue in ',type2))+ theme(
      panel.border=element_rect(color="white",size=1),axis.line=element_line(color="white",size=0.5),
      axis.text.x = element_text(angle=0,hjust=0.5, vjust=0.5,size = rel(1.2),color="white"),axis.ticks = element_blank(),
      axis.text.y = element_text(angle=0,hjust=0.5, vjust=0.5,size = rel(1.2),color="white"),plot.title = element_text(size=15)
    )
  maintitle3=paste0(maintitle,'.umap.tissue.type2')
  ggsave(paste0(resPath,maintitle3,'.png'),width =110,height =80, unit = "mm", dpi=100,p1)
  
  
  
  #---Gene expression Umap--------
  gene2$Expr=gene2$RNA
  gene2[gene2$Expr>3,'Expr']=3
  
  p=ggplot(gene2,aes(x=UMAP_1,y=UMAP_2,color=Expr))+geom_point(size=0.5)+
    scale_color_gradientn(colors = c('#cacaca30','#ffbf8750','red'))+mytheme+ theme(
      panel.border=element_rect(color="white",size=1),axis.line=element_line(color="white",size=0.5),
      axis.text.x = element_text(angle=0,hjust=0, vjust=1,size = rel(1.2),color="white"),axis.ticks = element_blank(),
      axis.text.y = element_text(angle=0,hjust=0, vjust=1,size = rel(1.2),color="white"),plot.title = element_text(size=12),panel.grid.major=element_line(color="grey96"),
      panel.grid.minor=element_line(color="grey96")
    )+labs(title = paste0('UMAP Plot of ',name.gene1,' Expression in ',type2))
  
  maintitle4=paste0(maintitle,'.umap.expr.type2')
  ggsave(paste0(resPath,maintitle4,'.png'),width =100,height =80, unit = "mm", dpi=100,p)
  
  
  maintitle5=paste(maintitle1,maintitle2,maintitle3,maintitle4,sep=",")
  
  cat(maintitle5)
}else{
  cat(0)
}