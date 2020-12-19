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
colors=c('#D6E7A3',"orange1", 'lightblue','#7142AC',"darkcyan","royalblue1","red3",'#53A85F',"deeppink",
         "mediumvioletred","gold","darkorange2", "tan2","darkorange2","darkorchid","chocolate4","darkred","lightskyblue","gold1")

if(Sys.info()[1]=="Windows"){
  Path='D:/tiger/'
  resPath="D:/tiger/img/"
}else{
  Path='/bakup/tiger/'
  resPath="/bakup/tiger/img/"
}


Args <- commandArgs(T)


#Args <- c("PDAC","All",'CD8A')

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
  now.data.df= Mono[[global.cluster]][['data_df']]
  now.edge.df=Mono[[global.cluster]][['edge_df']]
  names(colors)=levels(as.factor(now.data.df$recluster))

  p <- ggplot(data = now.data.df, aes(x = data_dim_1,y = data_dim_2))+
        geom_segment(aes_string(x = "source_prin_graph_dim_1",y = "source_prin_graph_dim_2", xend = "target_prin_graph_dim_1",yend = "target_prin_graph_dim_2"), size = 0.5, linetype='dashed', na.rm = TRUE, data = now.edge.df)+ 
    geom_point(size = I(1.5), na.rm = TRUE,aes(color=recluster))+scale_color_manual(values = colors)+mytheme+
    guides(color=guide_legend(override.aes = list(size = 3),title = NULL))+labs(x='Component1',y='Component2')+theme(
      panel.border=element_rect(color="white",size=1),axis.line=element_line(color="white",size=0.5),
      axis.text.x = element_text(angle=0,hjust=0.5, vjust=0.5,size = rel(1.2),color="white"),axis.ticks = element_blank(),
      axis.text.y = element_text(angle=0,hjust=0.5, vjust=0.5,size = rel(1.2),color="white"),plot.title = element_text(size=15),        
      panel.grid.major=element_line(color="grey96"),
      panel.grid.minor=element_line(color="grey96")
    )+labs(title = 'Pseudo-time of cells')
  
  
  ggsave(paste0(resPath,'',maintitle,'.p6.png'),width = 130,height =100, unit = "mm", dpi=100,p)
      
    #}
    
    now.data=readRDS(paste0(Path,cancer_type,'/',cancer_type,'.gene/',global.cluster,'/',gene,'.rds'))
    gene.exp=now.data
    # rownames(gene.exp)=rownames(gene.exp) %>% str_replace_all('-','.')
    # rownames(gene.exp)=rownames(gene.exp) %>% str_replace_all(':','.')
    if(ncol(gene.exp)==2){
      now.data.df[,'Expr']=gene.exp[rownames(now.data.df),'Integrate']
    }else{
      now.data.df[,'Expr']=gene.exp[rownames(now.data.df),'RNA']
    }
    now.data.df[now.data.df$Expr>3,'Expr']=3
    now.data.df[now.data.df$Expr< -3,'Expr']=-3
    
    p <- ggplot(data = now.data.df, aes(x = data_dim_1,y = data_dim_2))+
      geom_segment(aes_string(x = "source_prin_graph_dim_1",y = "source_prin_graph_dim_2", xend = "target_prin_graph_dim_1",yend = "target_prin_graph_dim_2"), size = 0.5, linetype = "dashed", na.rm = TRUE, data = now.edge.df)+ 
      geom_point(size = I(1.5), na.rm = TRUE,aes(colour=Expr))+scale_colour_gradientn(colours =  c('blue','#e5e5e830','red'),limits=c(-3,3))+mytheme+
      labs(x='Component1',y='Component2')+theme(
        panel.border=element_rect(color="white",size=1),axis.line=element_line(color="white",size=0.5),
        axis.text.x = element_text(angle=0,hjust=0.5, vjust=0.5,size = rel(1.2),color="white"),axis.ticks = element_blank(),
        axis.text.y = element_text(angle=0,hjust=0.5, vjust=0.5,size = rel(1.2),color="white"),plot.title = element_text(size=15),        
        panel.grid.major=element_line(color="grey96"),
        panel.grid.minor=element_line(color="grey96")
      )+labs(title = paste0('Pseudo-time of cells with ',gene,' expression'))
    
    
    ggsave(paste0(resPath,'',maintitle,'.p7.png'),width = 120,height =100, unit = "mm", dpi=100,p)
    cat(paste(maintitle1,maintitle2,sep=","))

}else{
  cat(0)
}
