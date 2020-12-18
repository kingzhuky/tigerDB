library(stringr);library(plyr);library(ggplot2);library(data.table);library(magrittr);library(ggpubr);
library(reshape2)
Args <- commandArgs(TRUE)
#Args <- c("SIG1","png")
sigid <- Args[1]
datatype <- Args[2]

loading.data.path <- "Signature_data/"
result.path <- "./img/"

maintitle1 <- paste("ImmuneSig-Detial","RNR","boxplot",sigid,sep="-")
maintitle2 <- paste("ImmuneSig-Detial","pancancer","boxplot",sigid,sep="-")

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

## Generate R-NR boxplot

R.NR.SIG.score.table <- readRDS(paste0(loading.data.path,"SIG.score.response.table.RDS"))
R.NR.plotdata <- melt(R.NR.SIG.score.table,id.vars = c("sample_id","dataset_id","group"),variable.name = "sigid",value.name = "sig_score")
plotdata <- R.NR.plotdata[sigid == sigid]
N.NR.boxplot <- ggplot(plotdata[!is.na(sig_score)], aes(x=dataset_id, y=sig_score, fill=group)) +
  geom_boxplot(outlier.colour = NA) + mytheme +
  scale_fill_manual(values =c('#016af3','#f34b01','#f5e31b')) +
  stat_compare_means(aes(group=group,label = ..p.signif..),method ='wilcox') +
  theme(axis.title = element_blank(),
        axis.text.x = element_text(angle=90,hjust=0.5, vjust=0.5,size = rel(1.2),
                                   color="black"))

## Generate pan-cancer boxplot

pancancer.SIG.score.table <- readRDS(paste0(loading.data.path,"SIG.score.TCGA.table.RDS"))
pancancer.plotdata <- melt(pancancer.SIG.score.table,id.vars = c("sample_id","dataset_id","group"),variable.name = "sigid",value.name = "sig_score")
pancancer.plotdata <- pancancer.plotdata[sigid == sigid]
pancancer.boxplot <- ggplot(pancancer.plotdata[!is.na(sig_score)], aes(x=dataset_id, y=sig_score, fill=group)) +
  geom_boxplot(outlier.colour = NA) + mytheme +
  scale_fill_manual(values =c('#016af3','#f34b01','#f5e31b')) +
  stat_compare_means(aes(group=group, label = ..p.signif..),method ='wilcox') +
  theme(axis.title = element_blank(),
        axis.text.x = element_text(angle=90,hjust=0.5, vjust=0.5,size = rel(1.2),
                                   color="black"))

if(datatype == "png"){
  filename1 = paste0(result.path,maintitle1,".png")
  filename2 = paste0(result.path,maintitle2,".png")
}else{
  filename1 = paste0(result.path,maintitle1,".pdf")
  filename2 = paste0(result.path,maintitle2,".pdf")
}
ggsave(filename = filename1,plot = N.NR.boxplot,width = 6,height = 2,units = "in", dpi = 100)
ggsave(filename = filename2,plot = pancancer.boxplot, dpi = 100)

cat(paste(maintitle1,maintitle2,sep=","))
