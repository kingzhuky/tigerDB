library(data.table)
Args <- commandArgs(T)
#Args <- c("7SK","Melanoma_Nathanson_2017_anti-CTLA-4_Female","None","None","FALSE","png")
filename <- Args[1]
outpath <- Args[2]
tmp.table <- read.table(filename)
tmp.colname <- unlist(lapply(strsplit(colnames(tmp.table),"[.]"),function(x){tmp.str = ifelse(is.na(x[3]),"",paste0(" ",x[3]));paste0(x[1],",",x[2],tmp.str)}))
tmp.colname[1] <- 'gene'
colnames(tmp.table) = tmp.colname
fwrite(tmp.table,file.path(outpath,filename),sep="\t")