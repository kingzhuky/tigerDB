load("test_data/Response_datasets.RData")
names(response.data.list[1:4])
logfc.mat <- data.frame(row.names = rownames(mat),gene_symbol = mat$gene_symbol)
for(mat in response.data.list[1:4]){
  print(row.names(mat)[1:10])
  tmp.mat <- mat[,2:ncol(mat)]
  response.index <- sample.info[colnames(tmp.mat),"Treatment"] == "PRE"
  tmp.log2fc <- data.frame(row.names = rownames(mat),
                           logfc = log2(apply(tmp.mat[,!response.index],1,mean)/apply(tmp.mat[,response.index],1,mean)+1))
  logfc.mat <- cbind(logfc.mat,tmp.log2fc)
}
colnames(logfc.mat)[2:5] <- c("Melanoma_PRJEB23709","GBM_PRJNA482620","Melanoma_SRP070710","Melanoma_SRP094781")
write.csv(logfc.mat,"R_NR.csv",quote = F, row.names = F)
