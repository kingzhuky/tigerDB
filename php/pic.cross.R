library(stringr);library(plyr);library(ggplot2);library(data.table);library(magrittr);library(ggpubr);library(circlize)

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
  Path='E:/hongwan/'
  resPath="D:/javascript/tigetData/"
}else{
  Path='/bakup/tiger/'
  resPath="/bakup/tiger/img/"
}

Args <- commandArgs(T)
#Args <- c("BCC","CAF,Tumor,pDC,NK",'HLA-A','CD3G')
# Args <- c("HCC","T-cell,B-cell,CAF,TAM",'HLA-A','CD3G')
# Args <- c("NSCLC","Plasma,Myeloid,Malignant,T-cell",'HLA-A','CD3D')


cancer_type=Args[1]
global.cluster <- Args[2]
sub.cluster <- unlist(strsplit(Args[3]%>% str_replace_all('-',' '),split=',')) #T cell,B cell,pDC,NK
ligand = Args[4]
receptor = Args[5]


maintitle <- paste('Cross-',paste(cancer_type,collapse = "_"),
                   paste(sub.cluster,collapse = "_"),
                   ligand,receptor,sep="-")

crosstalk.result=readRDS(paste0(Path,cancer_type,'/',cancer_type,'/',cancer_type,'.crosstalk.result.rds'))

pic.cross=function(sub.cluster,ligand,receptor){
  now.crosstalk.result=crosstalk.result
  for(i in 1:length(now.crosstalk.result)){
    now.crosstalk.result[[i]]=now.crosstalk.result[[i]][now.crosstalk.result[[i]]$cell_from %in% sub.cluster & now.crosstalk.result[[i]]$cell_to %in% sub.cluster,]
  }
  maintitles=c()
  for(i in 1:length(now.crosstalk.result)){
    data=now.crosstalk.result[[i]]
    cell_group <- unique(c(data$cell_from, data$cell_to))
    genes <- c(structure(data$ligand, names = data$cell_from), 
               structure(data$receptor, names = data$cell_to))
    genes <- genes[!duplicated(paste(names(genes), genes))]
    genes <- genes[order(names(genes))]
    transparency = 0.5;track.height_1 = uh(2,"mm");track.height_2 = uh(12, "mm"); annotation.height_1 = 0.01;annotation.height_2 = 0.01
    link.arr.lty = "solid";data <- data %>% mutate(link_col = "#d2d2d2");link.arr.type = "triangle"
    link.arr.lwd=data$cell_from_mean_exprs;link.arr.width=data$cell_to_mean_exprs
    data <- data %>% mutate(arr_width = ifelse(link.arr.lwd == 1e-04, 2, 0.5 + 5/(max(abs(link.arr.lwd)) - min(abs(link.arr.lwd))) * 
                                                 (abs(link.arr.lwd) - min(abs(link.arr.lwd)))))
    data <- data %>% mutate(arr_width = 1)
    # data <- data %>% mutate(link.arr.width = data$arr_width/10)
    data <- data %>% mutate(link.arr.width = ifelse(link.arr.width == 1e-04, 0.2, (0.5 + 5/(max(abs(link.arr.width)) - min(abs(link.arr.width))) * (abs(link.arr.width) - min(abs(link.arr.width))))/10))
    
    comm_col <- structure(c("#99ff99", "#99ccff", "#ff9999","#ffcc99"), names = c("other", "cytokine", "checkpoint","growth factor"))
    gene_col <- structure(c(comm_col[data$comm_type], rep("#073c53",length(data$receptor))), names = c(data$ligand, data$receptor))
    grid.col = gene_col[genes]
    names(grid.col) <- paste(names(genes), genes)
    
    
    cell_types=union(data$cell_from,data$cell_to)
    cell_col <- structure(colors[1:length(cell_types)], names=cell_types)
    
    
    gap.degree <- do.call("c", lapply(table(names(genes)),function(i) c(rep(1, i - 1), 8)))
    circos.par(gap.degree = gap.degree)
    
    
    data.new=data
    data.new[data.new$ligand!=ligand,'arr_width']=0
    data.new[data.new$ligand!=ligand,'link.arr.width']=NA
    data.new[data.new$receptor==receptor,'link_col']='#e0146b'
    
    maintitles=c(maintitles,paste(maintitle,i,sep='-'))
    png(file=paste0(resPath,paste(maintitle,i,sep='-'),".png"),  width = 500, height = 500)
    chordDiagram(as.data.frame(cbind(paste(data.new$cell_from, data.new$ligand),paste(data.new$cell_to, data.new$receptor))), order = paste(names(genes),genes), grid.col = grid.col, transparency = transparency, 
                 directional = 1, link.arr.lwd = data.new$arr_width, direction.type = "arrows",
                 link.arr.lty = link.arr.lty, link.arr.type = link.arr.type, 
                 link.arr.width = data.new$link.arr.width, link.arr.col = data.new$link_col, 
                 col = "#00000000", annotationTrack = c("grid"), preAllocateTracks = list(list(track.height = track.height_1),list(track.height = track.height_2)), annotationTrackHeight = c(annotation.height_1,annotation.height_2))
    for (c in unique(names(genes))) {
      gene = as.character(genes[names(genes) == c])
      highlight.sector(sector.index = paste(c, gene), track.index = 3, 
                       col = ifelse(length(cell_col) == 1, cell_col, 
                                    cell_col[c]), text = c, text.vjust ="0.3cm", cex=1,
                       niceFacing = TRUE, lwd = par("lwd"))
    }
    if(names(now.crosstalk.result[i])=='Yes'){
      title('Response')
    }else if(names(now.crosstalk.result[i])=='No'){
      title('Non-Response')
    }else{ title(names(now.crosstalk.result[i])) }
    circos.clear()
    dev.off()
    
  }
  cat(paste(maintitles,collapse = ','))
}

pic.cross(sub.cluster,ligand,receptor)





