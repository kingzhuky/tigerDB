library(data.table)
library(jsonlite)
library(tidyverse)
cellnum.filelist <- dir(path = "/data10/liuxf/New_Tiger/Cellnum", pattern = "[.]txt$", full.names = TRUE)
scRNA.info <- fread("/data10/liuxf/New_Tiger/table_file/20210115-scRNAseqinfo.txt", sep = "\t")[!is.na(PMID)]
SCID.table <- fread("/data10/liuxf/New_Tiger/homescinfo.tsv")
cellnum.table <- NULL
for( file in cellnum.filelist ){
  dataset.id <- strsplit(file,"[/.]")[[1]][6]
  tmp.cellnum.table <- fread(file) %>% 
                        as.data.frame(.) %>%
                        mutate(total = rowSums(.[2:ncol(.)])) %>%
                        as.data.table()
  tmp.cellnum.table[, datasetid := dataset.id]
  tmp.cellnum.table <- tmp.cellnum.table[,.(datasetid,GlobelCluster,total)]
  cellnum.table <- rbind(cellnum.table,tmp.cellnum.table)
}
cellnum.anno.table <- merge(unique(SCID.table[,.(datasetid, CancerType)],by = "datasetid"),
                            cellnum.table, by = "datasetid", all.y = TRUE)
cellnum.anno.table[, datasetid := NULL]
cellnum.anno.mat <- dcast(cellnum.anno.table, GlobelCluster ~ CancerType,fun.aggregate = sum, value.var = c("total"))
cellnum.json <- toJSON(pretty=TRUE,cellnum.anno.mat)
cat(cellnum.json, file = (con <- file("cellnum_stat.json", "w", encoding = "UTF-8")))
close(con)
