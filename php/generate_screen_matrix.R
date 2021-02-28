library(data.table)
library(dplyr)
screen.table <- NULL
pancner.info <- fread("fc/41588_2017_BFng3984_MOESM5_ESM.csv",sep = ",")
colnames(pancner.info)[1] <- "GENE_SYMBOL"
pancner.table <- data.table(GENE_SYMBOL = pancner.info$GENE_SYMBOL, Cell_panel_Essentiality = apply(pancner.info[,-c("GENE_SYMBOL")], 1, median))
screen.table <- pancner.table
csv.file <- dir(".","csv",full.names = T,recursive = T)
for (filename in grep("GSE107670",csv.file,value = T)){
  csv.table <- fread(filename, sep = ",")[,.(Gene,logFC)]
  colnames(csv.table) <- c("GENE_SYMBOL",strsplit(filename,split = "[/.]")[[1]][4])
  csv.table$GENE_SYMBOL <- toupper(csv.table$GENE_SYMBOL)
  if ( is.null(screen.table) ) {
    screen.table <- csv.table
  }else {
    screen.table <- merge(csv.table, screen.table, by = "GENE_SYMBOL",all=TRUE)
  }
}
mageck.res.file <- c("fc/GSE119450_T.tsv",
                     "fc/D10_MART-1_LibraryB.gene_summary.txt",
                     "fc/D10_MART-1_LibraryA.gene_summary.txt",
                     "fc/B16_NK.tsv",
                     "fc/K562_NK_ET_1.gene_summary.txt",
                     "fc/K562_NK_ET_2_5.gene_summary.txt")
for (filename in mageck.res.file ){
  csv.table <- fread(filename, sep = "\t")[,.(id,`neg|lfc`)]
  colnames(csv.table) <- c("GENE_SYMBOL",strsplit(filename,split = "[/.]")[[1]][2])
  csv.table$GENE_SYMBOL <- toupper(csv.table$GENE_SYMBOL)
  if ( is.null(screen.table) ) {
    screen.table <- csv.table
  }else {
    screen.table <- merge(csv.table, screen.table, by = "GENE_SYMBOL",all=TRUE)
  }
}
normal.csv.file <- c("fc/GSE112252_MC38_coculture_normalizedcounts.csv","fc/GSE112252_MC38_invitro_normalizedcounts.csv")

norm.count  <- fread("fc/GSE112252_MC38_coculture_normalizedcounts.csv")
csv.table <- apply(norm.count[,-1],1,function(x){c( GSE112252_MC38_OT1_IgG = mean(x[4:6])-mean(x[1:3]), GSE112252_MC38_OT1_PD1 = mean(x[7:9])-mean(x[1:3]))}) %>% 
  t() %>% data.table(GENE_SYMBOL = toupper(norm.count$V1), .)
if ( is.null(screen.table) ) {
  screen.table <- csv.table
}else {
  screen.table <- merge(csv.table, screen.table, by = "GENE_SYMBOL",all=TRUE)
}

norm.count  <- fread("fc/GSE112252_MC38_invitro_normalizedcounts.csv")
csv.table <- apply(norm.count[,-1],1,function(x){c( GSE112252_MC38_NK_10 = mean(x[3:7])-mean(x[1:2]), GSE112252_MC38_NK_20 = mean(x[8:9])-mean(x[1:2]))}) %>% 
  t() %>% data.table(GENE_SYMBOL = toupper(norm.count$gene), .)
if ( is.null(screen.table) ) {
  screen.table <- csv.table
}else {
  screen.table <- merge(csv.table, screen.table, by = "GENE_SYMBOL",all=TRUE)
}
# shRNA
mouse.screen.table <- NULL
shRNA.csv.file <- c("fc/B16_Primary_screen.csv","fc/B16_Secondary_screen.csv")
for(filename in shRNA.csv.file){
  csv.table <- fread(filename)[-c(1:3),c(1,5)]
  colnames(csv.table) <- c("GENE_SYMBOL",strsplit(filename,split = "[/.]")[[1]][2])
  csv.table <- csv.table[,lapply(.SD, max),by = c("GENE_SYMBOL")]
  csv.table[,2] <- log2(as.numeric(as.data.frame(csv.table)[,2]))
  csv.table$GENE_SYMBOL <- toupper(csv.table$GENE_SYMBOL)
  if ( is.null(mouse.screen.table) ) {
    mouse.screen.table <- csv.table
  }else {
    mouse.screen.table <- csv.table[mouse.screen.table, on = c("GENE_SYMBOL"), nomatch = NA]
  }
}
fwrite(screen.table,"screen_mat.csv",sep = ",")
fwrite(mouse.screen.table,"mouse.screen_mat.csv",sep = ",")
