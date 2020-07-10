library(stringr);library(plyr);library(ggplot2);library(data.table);library(magrittr);library(ggpubr);

mytheme <- theme_bw() + 
  theme(plot.title=element_text(size=rel(2),hjust=0.5),
        axis.title=element_text(size=rel(1)),
        axis.text.x = element_text(angle=0,hjust=0.5, vjust=0.5,size = rel(1.2)),
        axis.text.y = element_text(angle=0,hjust=0.5, vjust=0.5,size = rel(1.2)),
        panel.grid.major=element_line(color="white"),
        panel.grid.minor=element_line(color="white"),
        panel.border=element_rect(color="black",size=1),
        axis.line=element_line(color="black",size=0.5))
colors=c("#cc4a5399",'#00ADDB99','#7142AC99',"#42B54099",'#00008099','#07702b99',"#7FFF0099","#AD002A","#ED000099",'#ABD20599','#F0BE7E','#4D221399',"#FDAF9199",'#85E1D099','#C979CD99','#F26A1299',"#ADB6B699",'#4B79AB99',"#0099B499",'#FF149399','#00800099',"#1B191999")

if(Sys.info()[1]=="Windows"){
  Path='E:/hongwan/'
  resPath="D:/javascript/tigetData/"
}else{
  Path='/bakup/tiger/'
  resPath="/bakup/tiger/img/"
}


Args <- commandArgs(T)

# Args <- c("BCC",'All',"CAF,Tumor,pDC,NK",'CD247')
# Args <- c("HCC","All","T-cell,B-cell,CAF,TAM",'CD3D')
# Args <- c("TNBC","All","CD8_γδ,Myeloid,CD4_IL7R+,CD4_RGCC+",'CD8A')
# Args <- c("PDAC","All","Acinar,Ductal,Myeloid,T-cell",'CD3D')
# Args <- c("NSCLC","All","Plasma,Myeloid,Malignant,T-cell",'CD8A')



cancer_type=Args[1]
global.cluster=Args[2] #All\Tcell\Bcell
sub.cluster <- unlist(strsplit(Args[3],split=',')) #T cell_B cell_pDC_NK
gene = Args[4]
#show_response=Args[5]

genefile=paste0(Path,cancer_type,'/',cancer_type,'.gene/',global.cluster,'/',gene,'.rds')

if (file.exists(genefile)){
  



maintitle <- paste(paste(cancer_type,collapse = "_"),paste(global.cluster,collapse = "_"),
                   paste(sub.cluster,collapse = "_"),
                   gene,sep="-")



Mono=readRDS(paste0(Path,cancer_type,'/',cancer_type,'/',cancer_type,'.Mono.rds'))

pic.evlou=function(global.cluster , sub.cluster, gene,show_response){  
  now.data.df= Mono[[global.cluster]][['data_df']]
  now.edge.df=Mono[[global.cluster]][['edge_df']]
  names(colors)=levels(as.factor(meta$recluster))
  colors[setdiff(unique(now.data.df$recluster),sub.cluster)]='#aeaeb110'
  #now.data.df=now.data.df[now.data.df$recluster %in% sub.cluster,]
  
  # if(show_response==0 & sum(colnames(now.data.df)=='Response')==1){
  #   p <- ggplot(data = now.data.df, aes(x = data_dim_1,y = data_dim_2))+
  #     geom_segment(aes_string(x = "source_prin_graph_dim_1",y = "source_prin_graph_dim_2", xend = "target_prin_graph_dim_1",yend = "target_prin_graph_dim_2"), size = 1, 
  #                  linetype = "solid", na.rm = TRUE, data = now.edge.df)+ geom_point(size = I(0.8), na.rm = TRUE,aes(color=recluster,shape=Response))+scale_color_manual(values = colors)+mytheme+
  #     guides(color=guide_legend(title = NULL))+labs(x='Component1',y='Component2')+scale_shape_manual(values = c(1,9))
  #   ggsave(paste0(resPath,'',maintitle,'.p5.png'),width = 5.5,height = 5,p) 
  #   maintitle1=paste0(maintitle,'.p5.png')
  # }else{
    p <- ggplot(data = now.data.df, aes(x = data_dim_1,y = data_dim_2))+
      geom_segment(aes_string(x = "source_prin_graph_dim_1",y = "source_prin_graph_dim_2", xend = "target_prin_graph_dim_1",yend = "target_prin_graph_dim_2"), size = 1, 
                   linetype = "solid", na.rm = TRUE, data = now.edge.df)+ geom_point(size = I(0.8), na.rm = TRUE,aes(color=recluster))+scale_color_manual(values = colors)+mytheme+
      guides(color=guide_legend(override.aes = list(size = 3),title = NULL))+labs(x='Component1',y='Component2')
    ggsave(paste0(resPath,'',maintitle,'.p6.png'),width = 5.5,height = 5,p)
    maintitle1=paste0(maintitle,'.p6.png')
  #}
  
  now.data=readRDS(paste0(Path,cancer_type,'/',cancer_type,'.gene/',global.cluster,'/',gene,'.rds'))
  gene.exp=now.data$data
  rownames(gene.exp)=rownames(gene.exp) %>% str_replace_all('-','.')
  now.data.df[,'gene']=gene.exp[rownames(now.data.df),'gene']
  now.data.df[now.data.df$gene>3,'gene']=3
  now.data.df[now.data.df$gene< -3,'gene']=-3
  p <- ggplot(data = now.data.df, aes(x = data_dim_1,y = data_dim_2))+
    geom_segment(aes_string(x = "source_prin_graph_dim_1",y = "source_prin_graph_dim_2", xend = "target_prin_graph_dim_1",yend = "target_prin_graph_dim_2"), size = 1, 
                 linetype = "solid", na.rm = TRUE, data = now.edge.df)+ geom_point(size = I(1), na.rm = TRUE,aes(color=gene))+scale_color_gradientn(colours =  c('#0600ff99','#e5e5e830','#f6082999'),limits=c(-3,3))+mytheme+
    guides(color=guide_legend(override.aes = list(size = 3),title = NULL))+labs(x='Component1',y='Component2')
  
  
  ggsave(paste0(resPath,'',maintitle,'.p7.png'),width = 5.5,height = 5,p)
  maintitle2=paste0(maintitle,'.p7.png')
  cat(paste(maintitle1,maintitle2,sep=","))
  
}

pic.evlou(global.cluster , sub.cluster, gene,show_response)
}else{
  cat(0)
}
