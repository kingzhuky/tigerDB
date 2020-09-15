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
colors=c('#E5D2DD', '#53A85F', '#F1BB72', '#F3B1A0', '#D6E7A3', '#57C3F3', '#476D87',
         '#E95C59', '#E59CC4', '#AB3282', '#23452F', '#BD956A', '#8C549C', '#585658',
         '#9FA3A8', '#E0D4CA', '#5F3D69', '#C5DEBA', '#58A4C3', '#E4C755', '#F7F398',
         '#AA9A59', '#E63863', '#E39A35', '#C1E6F3', '#6778AE', '#91D0BE', '#B53E2B',
         '#712820', '#DCC1DD', '#CCE0F5',  '#CCC9E6', '#625D9E', '#68A180', '#3A6963',
         '#968175')
if(Sys.info()[1]=="Windows"){
  Path='D:/tiger/'
  resPath="D:/tiger/img/"
}else{
  Path='/bakup/tiger/'
  resPath="/bakup/tiger/img/"
}


Args <- commandArgs(T)

# Args <- c("BCC",'All','CD247')
# Args <- c("PDAC","All",'CD3D')
# Args <- c("HCC","All",'CD3D')
# Args <- c("CCRCC","All",'CD8A')
# Args <- c("BTCC","CD4",'CD8A')
# Args <- c("CAC","All",'CD8A')



cancer_type=Args[1]
global.cluster=Args[2] #All\Tcell\Bcell
#sub.cluster <- unlist(strsplit(Args[3],split=',')) #T cell_B cell_pDC_NK
gene = Args[3]
#show_response=Args[5]
maintitle <- paste(paste(cancer_type,collapse = "_"),paste(global.cluster,collapse = "_"),
                   gene,sep="-")
maintitle1=paste0(maintitle,'.p6.png')
maintitle2=paste0(maintitle,'.p7.png')
genefile=paste0(Path,cancer_type,'/',cancer_type,'.gene/',global.cluster,'/',gene,'.rds')
if (file.exists(genefile)){

  Mono=readRDS(paste0(Path,cancer_type,'/',cancer_type,'/',cancer_type,'.Mono.rds'))
  
  pic.evlou=function(global.cluster ,  gene,show_response){  
    now.data.df= Mono[[global.cluster]][['data_df']]
    now.edge.df=Mono[[global.cluster]][['edge_df']]
    names(colors)=levels(as.factor(now.data.df$recluster))
    #colors[setdiff(unique(now.data.df$recluster))]='#aeaeb110'
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
      ggsave(paste0(resPath,'',maintitle,'.p6.png'),width = 150,height =110, unit = "mm", dpi=100,p)
      
    #}
    
    now.data=readRDS(paste0(Path,cancer_type,'/',cancer_type,'.gene/',global.cluster,'/',gene,'.rds'))
    gene.exp=now.data
    rownames(gene.exp)=rownames(gene.exp) %>% str_replace_all('-','.')
    now.data.df[,'gene']=gene.exp[rownames(now.data.df),'gene']
    now.data.df[now.data.df$gene>3,'gene']=3
    now.data.df[now.data.df$gene< -3,'gene']=-3
    p <- ggplot(data = now.data.df, aes(x = data_dim_1,y = data_dim_2))+
      geom_segment(aes_string(x = "source_prin_graph_dim_1",y = "source_prin_graph_dim_2", xend = "target_prin_graph_dim_1",yend = "target_prin_graph_dim_2"), size = 1, 
                   linetype = "solid", na.rm = TRUE, data = now.edge.df)+ geom_point(size = I(1), na.rm = TRUE,aes(color=gene))+scale_color_gradientn(colours =  c('#0600ff99','#e5e5e830','#f6082999'),limits=c(-3,3))+mytheme+
      guides(color=guide_legend(override.aes = list(size = 3),title = NULL))+labs(x='Component1',y='Component2')
    
    
    ggsave(paste0(resPath,'',maintitle,'.p7.png'),width = 150,height =110, unit = "mm", dpi=100,p)
    cat(paste(maintitle1,maintitle2,sep=","))
    
  }
pic.evlou(global.cluster ,  gene,show_response)
}else{
  cat(0)
}
