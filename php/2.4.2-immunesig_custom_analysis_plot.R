library(stringr);library(plyr);library(ggplot2);library(data.table);library(magrittr);library(ggpubr);
library(reshape2)
library(rlist)
Args <- commandArgs(TRUE)
#Args <- c("./img/ImmuneSig-Custom-SigScore-boxplot-2020_12_19_00_21_30.RDS","SIG6","2020_12_19_00_21_30","png")
table.rds.file <- Args[1]
sigid <- Args[2]
keyID <- ifelse(is.na(Args[3]), gsub("[-: ]","_",Sys.time()), Args[3])
datatype <- Args[4]

loading.data.path <- "Signature_data/"
result.path <- "./img/"

maintitle1 <- paste("ImmuneSig-Custom","groupScore","boxplot",keyID,sigid,sep="-")

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

## Generate Group Score boxplot
sig.score.group.table <- readRDS(table.rds.file)
save.cols <-  c("sample_id", "group", sigid)
plot.data <- melt(sig.score.group.table[, ..save.cols], id.vars = c("sample_id","group"), variable.name = "sigid",value.name = "sig_score")
group.boxplot <- ggplot(plot.data[!is.na(sig_score)], aes(x=sigid, y=sig_score, fill=group)) +
                    geom_boxplot(outlier.colour = NA) + mytheme +
                    scale_fill_manual(values = colors) +
                    theme(axis.title = element_blank(),
                          axis.text.x = element_text(angle=90,hjust=0.5, vjust=0.5,size = rel(1.2),
                                                     color="black"))

if(datatype == "png"){
  filename1 = paste0(result.path,maintitle1,".png")
}else{
  filename1 = paste0(result.path,maintitle1,".pdf")
}
ggsave(filename = filename2,plot = group.boxplot, dpi = 100)

cat(paste(maintitle1,maintitle2,sep=","))