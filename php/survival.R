# Args <- commandArgs()
# gene<- unlist(strsplit(Args[6],split='_'))
# cancer<- unlist(strsplit(Args[7],split=','))
# signature<-Args[8]
# normalMed<-Args[9]
# normalGene<-Args[10]
# corMed<-Args[11]
# mergedatasets<-Args[12]
# datatype<-Args[13]
# 
# maintitle=paste(gene,cancer,signature,normalMed,normalGene,corMed,mergedatasets,datatype,sep="-")
# maintitle2=paste(gene,cancer,signature,normalMed,normalGene,corMed,mergedatasets,datatype,sep="\n")
maintitle='abc'
png(file=paste("./img/",maintitle,".png",sep=""))
background<-rgb(255, 246, 237,max=255)
par(bg=background)
plot(1:20)
text(10,10, maintitle)
dev.off()



cat (maintitle)

