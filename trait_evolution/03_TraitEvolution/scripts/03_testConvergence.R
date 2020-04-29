
###get variables from comand line

args = commandArgs(trailingOnly=TRUE)


# load packages
require(coda)

###  set initial burnin. | the parfile of the variable rates model alread defines a burnin, only after which the chain is sampled.
###. this script tests if the chain has converged. if the chain has converged it created a file "additional_burinin" to define for downstream analyses how many of the posterior samples to be used

burnin =0
cropat=4000


###  specify file to ue
dirname=args[1]
filename=args[2]

TREE=args[3]
TRAIT=args[4]
AXES=args[5]



###  read the chain from the Bayes Traits run


d = scan(paste(dirname, filename, ".Log.txt", sep=""), what="numeric", sep="\t")
startH = grep("Iteration", d)[2]
endH = grep("Node", d)[2]+1
startD = endH +1
endD=length(d)
dimC =length(d[startH:endH])
dimR =length(d[startD:endD])/dimC
post=as.data.frame(matrix(d[startD:endD],dimR, dimC ,byrow = T))
names(post) = d[startH: endH]
post= post[,-length(post)]
for ( i in c(2,4,5,6,7)) post[,i] = as.numeric(as.character(post[,i]))


########  make plot function to visualze the chain convergence

plot_chain = function(input, burnin=0) {
  if(burnin!= 0) {input= input[-c(1:burnin),]}
  input$NoParam= input[,6] + input[,7]
  par(mfrow=c(4,2), mar=c(5,5,2,2))
  hist(input $Lh, col="deepskyblue4", border="black" , br=100, main= "", xlab="Lh")
  plot(input $Lh ~ c(1:length(input$Iteration)), pch=16, cex=0.1 , col="deepskyblue4", ylab="Lh", xlab="sample");lines( c(1:length(input$Iteration)), input $Lh, col="deepskyblue4")
  abline( lm(input $Lh ~ c(1:length(input $Iteration)) )); abline( mean(input $Lh), 0, col="red", lty="dashed")
  hist(input[,4], br=100, col="deepskyblue4", border="black", main= "" , xlab="Alpha")
  plot(input[,4] ~ c(1:length(input$Iteration)), pch=16, cex=0.1, col="deepskyblue4", ylab="Alpha", xlab="sample");lines( c(1:length(input$Iteration)), input[,4], col="deepskyblue4")
  abline( lm(input[,4] ~ c(1:length(input $Iteration)) )); abline( mean(input[,4]), 0, col="red", lty="dashed")
  hist(input[,5], br=20, col="deepskyblue4", border="black" , main= "", xlab="Sigma^2")
  plot(input[,5] ~ c(1:length(input$Iteration)), pch=16, cex=0.1, col="deepskyblue4", ylab="Sigma^2", xlab="sample");lines( c(1:length(input$Iteration)), input[,5], col="deepskyblue4")
  abline( lm(input[,5] ~ c(1:length(input $Iteration)) )); abline( mean(input[,5]), 0, col="red", lty="dashed")
  hist(input$NoParam, br=47, col="deepskyblue4", border="black" , main= "", xlab="number of shifts")
  plot(input $NoParam ~ c(1:length(input$Iteration)), pch=16, cex=0.1, col="deepskyblue4", ylab="number of shifts", xlab="sample");lines( c(1:length(input$Iteration)), input $NoParam, col="deepskyblue4")
  abline( lm(input $NoParam ~ c(1:length(input $Iteration)) )); abline( mean(input $NoParam), 0, col="red", lty="dashed")
}







print(paste("##############################	 testing ", TREE, " ", TRAIT, " ", AXES, " for convergence      ##############################", sep=""))


####. if the chain passes the test, the diagnostic stats is saved to file, the burnin file is generated (defining the posterior sample of the chain), the chain of the posterior sample is plotted and the mean logLikelihood of the posterior sample to be used in further analysis is calculated and written to file


MC2= mcmc(data=post[,-c(1,3)])
HD= heidel.diag(MC2)

        if ( if(all(!is.na(HD[,1]))) all(HD[,2] <= cropat) else print("FALSE")){
                write.table( HD, paste(dirname, filename, "_Chain_Diag_HD_", burnin, "_burnin.txt", sep=""), sep="\t", quote=F)
                write.table(cropat,paste(dirname, "additional_burnin.txt", sep=""),row.name=F, col.name=F)      
                meanLH=mean(post$Lh[-c(1:cropat)]) ##. calculate mean log-likelihood
                write.table(meanLH,paste(dirname, "mean_Lh_VarRates_", cropat, "_burnin.txt", sep=""),row.name=F, col.name=F)
                ## and mean AIC-scores
                post$numpar= post[,6]+ post[,7] +2
                post$AIC = (-2*post$Lh)+(2*post$numpar)
                meanAIC= mean(post$AIC)
				write.table(meanAIC,paste(dirname, "mean_AIC_VarRates_", cropat, "_burnin.txt", sep=""),row.name=F, col.name=F)
                print("****  chain converged ****")
                print(HD)
                print("****   number of posterior samples:   ****")
                print(length(post$Lh[-c(1:cropat)]))
                pdf(file=paste(dirname, filename, "_Chain_plots_burn_", cropat, ".pdf", sep="") )
                plot_chain(post, cropat)
                dev.off()
                }else{ print("****   chain failed to converge   ****")}


