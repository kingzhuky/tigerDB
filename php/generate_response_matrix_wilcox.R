library(data.table)
library(rlist)
library(limma)
library(edgeR)
library(survival)
library(survminer)
library(parallel)

setwd("/data1/zhuky/TIGER_dataset")
load("Response_data/ResponseData.RData")
unique(sample.info$dataset_id)
response.data.list <- NULL 
Rds.list <- dir("Response_data","Rds",full.names = T)
for(filename in Rds.list){
  dataset.name <- lapply(strsplit(filename,"[/.]"), function(x)x[2])[[1]]
  response.data.list[[dataset.name]] <- readRDS(file = paste0("Response_data/",dataset.name,".Response.Rds"))
}
names(response.data.list)
## generate response matrix
post_pre.mat.logfc <- NULL
post_pre.mat.p <- NULL
R_NR.mat.logfc <- NULL
R_NR.mat.p <- NULL
post_pre.mat.pscore <- NULL
R_NR.mat.pscore <- NULL


for (dataset.name in names(response.data.list)){ 
  # dataset.name <- "ccRCC_Braun_2020_anti-PD-1"
  dataset <- response.data.list[[dataset.name]]
  ### post_pre
  PRE.id <- sample.info[Treatment == "PRE" & sample_id %in% colnames(dataset), sample_id]
  POST.id <- sample.info[Treatment != "PRE"& sample_id %in% colnames(dataset), sample_id]
  if(length(PRE.id) > 1 & length(POST.id) > 1){
    sample.PRE.index <- data.frame(row.names = c(PRE.id,POST.id),
                                   Group = factor(c(rep("pre",time=length(PRE.id)),
                                                    rep("post",time=length(POST.id)))))
    PRE.index <- c("GENE_SYMBOL",row.names(sample.PRE.index))
    limma.mat <- dataset[!is.na(GENE_SYMBOL),..PRE.index]
    exp.table <- na.omit(melt(limma.mat))
    exp.table[,Group := sample.PRE.index[variable,]]
    test.list <- mclapply(unique(exp.table$GENE_SYMBOL), function(x){
      tmp.data <- exp.table[GENE_SYMBOL == x]
      test <- wilcox.test(as.formula("value ~ Group") ,data = tmp.data)
      c(GENE_SYMBOL = x, P.Value = test$p.value, logFC = log2(mean(tmp.data[Group == "post",value])/mean(tmp.data[Group == "pre",value])))
    },mc.cores = 20) 
    DEG_limma_voom <- as.data.table(list.rbind(test.list))
    DEG_limma_voom[,`:=`(P.Value = as.numeric(P.Value), logFC = as.numeric(logFC))]
    DEG_limma_voom[,`:=`(Pscore = sign(logFC) * round(-log10(P.Value),5))]
    if(!is.null(post_pre.mat.logfc)){
      post_pre.mat.logfc <- merge(post_pre.mat.logfc, DEG_limma_voom[,c("GENE_SYMBOL","logFC")], by = "GENE_SYMBOL",all=TRUE)
      post_pre.mat.p <- merge(post_pre.mat.p, DEG_limma_voom[,c("GENE_SYMBOL","P.Value")], by = "GENE_SYMBOL",all=TRUE)
      colnames(post_pre.mat.logfc)[ncol(post_pre.mat.logfc)] <- dataset.name
      colnames(post_pre.mat.p)[ncol(post_pre.mat.p)] <- dataset.name
      post_pre.mat.pscore <- merge(post_pre.mat.pscore, DEG_limma_voom[,c("GENE_SYMBOL","Pscore")], by = "GENE_SYMBOL",all=TRUE)
      colnames(post_pre.mat.pscore)[ncol(post_pre.mat.pscore)] <- dataset.name
    }else{
      post_pre.mat.logfc <- data.table(GENE_SYMBOL = DEG_limma_voom$GENE_SYMBOL,value = DEG_limma_voom$logFC)
      post_pre.mat.p <- data.table(GENE_SYMBOL = DEG_limma_voom$GENE_SYMBOL,value = DEG_limma_voom$P.Value)
      colnames(post_pre.mat.logfc)[ncol(post_pre.mat.logfc)] <- dataset.name
      colnames(post_pre.mat.p)[ncol(post_pre.mat.p)] <- dataset.name
      post_pre.mat.pscore <- data.table(GENE_SYMBOL = DEG_limma_voom$GENE_SYMBOL,value = DEG_limma_voom$Pscore)
      colnames(post_pre.mat.pscore)[ncol(post_pre.mat.pscore)] <- dataset.name
    }
  }
  ## R_NR
  R.id <- sample.info[response_NR == "R" & sample_id %in% colnames(dataset), sample_id]
  NR.id <- sample.info[response_NR == "N" & sample_id %in% colnames(dataset), sample_id]
  if(length(R.id) > 1 & length(NR.id) > 1){
    sample.NR.index <- data.frame(row.names = c(R.id,NR.id), 
                                  Group = factor(c(rep("R",time=length(R.id)),
                                                   rep("NR",time=length(NR.id)))))
    NR.index <- c("GENE_SYMBOL",rownames(sample.NR.index))
    limma.mat <- dataset[!is.na(GENE_SYMBOL),..NR.index]
    exp.table <- na.omit(melt(limma.mat))
    exp.table[,Group := sample.NR.index[variable,]]
    test.list <- mclapply(unique(exp.table$GENE_SYMBOL), function(x){
      tmp.data <- exp.table[GENE_SYMBOL == x]
      test <- wilcox.test(as.formula("value ~ Group") ,data = tmp.data)
      c(GENE_SYMBOL = x, P.Value = test$p.value, logFC = log2(mean(tmp.data[Group == "R",value])/mean(tmp.data[Group == "NR",value])))
    },mc.cores = 20) 
    DEG_limma_voom <- as.data.table(list.rbind(test.list))
    DEG_limma_voom[,`:=`(P.Value = as.numeric(P.Value), logFC = as.numeric(logFC))]
    DEG_limma_voom[,`:=`(Pscore = sign(logFC) * round(-log10(P.Value),5))]
    if(!is.null(R_NR.mat.logfc)){
      R_NR.mat.logfc <- merge(R_NR.mat.logfc, DEG_limma_voom[,c("GENE_SYMBOL","logFC")], by = "GENE_SYMBOL",all=TRUE)
      R_NR.mat.p <- merge(R_NR.mat.p, DEG_limma_voom[,c("GENE_SYMBOL","P.Value")], by = "GENE_SYMBOL",all=TRUE)
      colnames(R_NR.mat.logfc)[ncol(R_NR.mat.logfc)]  <- dataset.name
      colnames(R_NR.mat.p)[ncol(R_NR.mat.p)] <- dataset.name
      R_NR.mat.pscore <- merge(R_NR.mat.pscore, DEG_limma_voom[,c("GENE_SYMBOL","Pscore")], by = "GENE_SYMBOL",all=TRUE)
      colnames(R_NR.mat.pscore)[ncol(R_NR.mat.pscore)] <- dataset.name
    }else{
      R_NR.mat.logfc <- data.table(GENE_SYMBOL = DEG_limma_voom$GENE_SYMBOL ,value = DEG_limma_voom$logFC)
      R_NR.mat.p <- data.table(GENE_SYMBOL = DEG_limma_voom$GENE_SYMBOL ,value = DEG_limma_voom$P.Value)
      colnames(R_NR.mat.logfc)[ncol(R_NR.mat.logfc)] <- dataset.name
      colnames(R_NR.mat.p)[ncol(R_NR.mat.p)] <- dataset.name
      R_NR.mat.pscore <- data.table(GENE_SYMBOL = DEG_limma_voom$GENE_SYMBOL,value = DEG_limma_voom$Pscore)
      colnames(R_NR.mat.pscore)[ncol(R_NR.mat.pscore)] <- dataset.name
    }
  }
}

## generate dataset information
dateset.info <- NULL
for(dataset.name in names(response.data.list)){
  dataset <- response.data.list[[dataset.name]]
  ### post_pre
  PRE.id <- sample.info[Treatment == "PRE" & sample_id %in% colnames(dataset), sample_id]
  POST.id <- sample.info[Treatment != "PRE"& sample_id %in% colnames(dataset), sample_id]
  ## R_NR
  R.id <- sample.info[response_NR == "R" & sample_id %in% colnames(dataset), sample_id]
  NR.id <- sample.info[response_NR == "N" & sample_id %in% colnames(dataset), sample_id]
  tmp.info <- data.table(DatasetID = dataset.name, Rnum = length(R.id), NRnum = length(NR.id), Prenum = length(PRE.id), Postnum = length(POST.id))
  dateset.info <- rbind(dateset.info, tmp.info)
}



fwrite(dateset.info,file = "dateset.info.csv",sep = ",")
f.R_NR.mat.logfc <- R_NR.mat.logfc[, lapply(.SD, median), by = GENE_SYMBOL]
f.R_NR.mat.p <- R_NR.mat.p[, lapply(.SD, median), by = GENE_SYMBOL]
f.post_pre.mat.logfc <- post_pre.mat.logfc[,lapply(.SD, median), by = GENE_SYMBOL]
f.post_pre.mat.p <- post_pre.mat.p[, lapply(.SD, median), by = GENE_SYMBOL]
fwrite(f.R_NR.mat.logfc,file = "R_NR.mat.logfc.csv",sep = ",")
fwrite(f.R_NR.mat.p,file = "R_NR.mat.p.csv",sep = ",")
fwrite(f.post_pre.mat.logfc,file = "post_pre.mat.logfc.csv",sep = ",")
fwrite(f.post_pre.mat.p,file = "post_pre.mat.p.csv",sep = ",")

f.R_NR.mat.pscore <- R_NR.mat.pscore[, lapply(.SD, median), by = GENE_SYMBOL]
f.post_pre.mat.pscore <- post_pre.mat.pscore[, lapply(.SD, median), by = GENE_SYMBOL]
setnames(f.R_NR.mat.pscore,"GENE_SYMBOL","gene")
setnames(f.post_pre.mat.pscore,"GENE_SYMBOL","gene")
fwrite(f.R_NR.mat.pscore,file = "generate_mysql_script/expresponse.csv",sep = ",")
fwrite(f.post_pre.mat.pscore,file = "generate_mysql_script/exptherapy.csv",sep = ",")
## generate dataset info 
# for (dataset.name in names(response.data.list)){
#   dataset <- response.data.list[[dataset.name]]
#   dataset[sample.info[], on = c("sample_id"), nomatch = FALSE][]
# }

## generate survival matrix

surv.sample.info <- sample.info[!is.na(`overall survival (days)`),]
colnames(surv.sample.info)[c(9,10)] <- c("Overall_survival_days","Status")
surv.sample.info$Status <- ifelse(surv.sample.info$Status == "Dead", 1, 0)
zscore.mat <- NULL
exp.cutoff <- 0.5
# dataset.name <- "Melanoma_GSE78220_anti-PD-1_Female"

for (dataset.name in names(response.data.list)){
  # dataset.name <- names(response.data.list)[1]
  dataset <- response.data.list[[dataset.name]][,lapply(.SD, max), by = c("GENE_SYMBOL")]
  whether_surv <- nrow(surv.sample.info[,c(1,9,10)][data.table(sample_id = colnames(dataset)), on = c("sample_id"), nomatch = FALSE]) < 2
  if(whether_surv) next
  dataset <- data.frame(dataset[!is.na(GENE_SYMBOL),-c("GENE_SYMBOL")],row.names = dataset[!is.na(GENE_SYMBOL),GENE_SYMBOL],check.names = FALSE)
  # dataset <- as.data.frame(t(list.cbind(apply(dataset,1,function(x) if(sum(x != 0) > 2) x))))
  # dataset <- log2(dataset +1)
  # dataset <- na.omit(dataset)
  covariates <- rownames(dataset)
  zscore.gene <- mclapply(covariates, function(x){
    # x <- covariates[1]
    # x <- "CD3D"
    surv.data <-  data.table(sample_id = colnames(dataset), t(dataset[x,]))[surv.sample.info[,c(1,9,10)], on = c("sample_id"), nomatch = FALSE][,-c("sample_id")]
    surv.data <- na.omit(surv.data)
    setnames(surv.data,x , "gene.exp")
    surv.data <- surv.data[gene.exp != 0] 
    if(nrow(surv.data) < 3){
      return(NA)
    }
    order.index <-  order(surv.data[,1],decreasing = T,na.last = TRUE)
    up.index <- order.index[seq(1,round(nrow(surv.data)*exp.cutoff))]
    down.index <- order.index[seq(round(nrow(surv.data)*(1-exp.cutoff))+1,nrow(surv.data))]
    surv.data$group <- "0"
    surv.data[up.index,"group"] <- paste0(x,"_high")
    surv.data[down.index,"group"] <- paste0(x,"_low")
    surv.data <- subset(surv.data,group != "0")
    surv.data$group <- factor(surv.data$group)
    # sfit <- survfit(Surv(as.numeric(Overall_survival_days),Status)~group,data=surv.data)
    surv.data$group <- factor(surv.data$group,levels = c(paste0(x,"_low"),paste0(x,"_high")))
    cox.res <- coxph(Surv(as.numeric(Overall_survival_days),Status) ~ group,data =surv.data)
    cox.res <- summary(cox.res)
    tmp.res <- cox.res$coefficients[c(2,5)]
    tmp.res[3] <- ifelse(tmp.res[1] > 1, 1, -1) * -log10(tmp.res[2])
    hr.p.pscore <- paste(round(tmp.res,4),collapse = "_")
    names(hr.p.pscore) <- x
    return(hr.p.pscore)
  },mc.cores = 40)
  zscore.gene <- na.omit(unlist(zscore.gene))
  zscore.table <- data.table(GENE_SYMBOL = names(zscore.gene), value = zscore.gene)
  # zscore.table$value[zscore.table$value> 10000] <- NA
  colnames(zscore.table)[2] <- dataset.name
  if(is.null(zscore.mat)){
    zscore.mat <- zscore.table
  }else{
    zscore.mat <- merge(zscore.mat, zscore.table, by = "GENE_SYMBOL", all=TRUE)
  }
}

colnames(f.R_NR.mat.logfc)  
colnames(f.post_pre.mat.logfc) 
colnames(zscore.mat.hr) 
fwrite(zscore.mat, file = "response_surv.hr.p.mat.csv",sep = ",")
zscore.mat.pscore <- zscore.mat[,lapply(.SD, function(x){as.numeric(strsplit(x,"_")[[1]][3])}),by = c("GENE_SYMBOL")]
setnames(zscore.mat.pscore,"GENE_SYMBOL",'gene')
zscore.mat.pscore <- zscore.mat.pscore[,lapply(.SD, max),by = c("gene")]
fwrite(zscore.mat.pscore, file = "generate_mysql_script/survival.csv",sep = ",",quote = FALSE)
unique(zscore.mat.pscore$gene)
R_NR.fc.p.mat <- matrix(paste(as.matrix(R_NR.mat.logfc[,lapply(.SD, function(x) round(x,3)), .SDcols = -c("GENE_SYMBOL")]),
                              as.matrix(R_NR.mat.p[,lapply(.SD, function(x) round(x,3)), .SDcols = -c("GENE_SYMBOL")]),
                              sep = "_"),
                        nrow = nrow(R_NR.mat.logfc), ncol = ncol(R_NR.mat.logfc)-1)
colnames(R_NR.fc.p.mat) <- colnames(R_NR.mat.logfc)[-1]
rownames(R_NR.fc.p.mat) <- R_NR.mat.logfc[,GENE_SYMBOL]
post_pre.fc.p.mat <- matrix(paste(as.matrix(post_pre.mat.logfc[,lapply(.SD, function(x) round(x,3)), .SDcols = -c("GENE_SYMBOL")]),
                                  as.matrix(post_pre.mat.p[,lapply(.SD, function(x) round(x,3)), .SDcols = -c("GENE_SYMBOL")]),
                                  sep = "_"),
                            nrow = nrow(post_pre.mat.logfc), ncol = ncol(post_pre.mat.logfc)-1)
colnames(post_pre.fc.p.mat) <- colnames(post_pre.mat.logfc)[-1]
rownames(post_pre.fc.p.mat) <- post_pre.mat.logfc[,GENE_SYMBOL]
write.csv(R_NR.fc.p.mat,file = "R_NR.fc.p.mat.csv",quote = FALSE)
write.csv(post_pre.fc.p.mat,file = "post_pre.fc.p.mat.csv",quote = FALSE)

dim(zscore.mat.hr)

## generate tablecolumn

screen.name <- colnames(fread("screen_mat.csv"))[-1]
cbind(data.table(immuneresponseunion = names(response.data.list)),
      c(colnames(f.R_NR.mat.logfc)[-1],
        rep(NA,length(names(response.data.list)) - length(colnames(f.R_NR.mat.logfc)[-1]))
        ),
      c(colnames(f.post_pre.mat.logfc)[-1],
        rep(NA,length(names(response.data.list)) - length(colnames(f.post_pre.mat.logfc)[-1]))
        ),
      c(colnames(zscore.mat)[-1],
        rep(NA,length(names(response.data.list)) - length(colnames(zscore.mat)[-1]))
        ),
      c(screen.name,
        rep(NA,length(names(response.data.list)) - length(screen.name))
      )
      ) -> tablecolumn.tsv
colnames(tablecolumn.tsv) <- c("immuneresponseunion","expresponse","exptherapy","survival","immunescreening")
tablecolumn.tsv <- data.table(tablecolumn.tsv)
fwrite(tablecolumn.tsv,file = "tablecolumn.tsv", sep = "\t")
