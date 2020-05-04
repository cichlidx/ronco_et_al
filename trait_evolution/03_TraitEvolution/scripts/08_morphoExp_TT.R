## Fabrizia Ronco
## April 2020




############################################
##################  ------ calculate morphospace expansion through time for the empirical data and the 500 Brownian motion simulations and compare them
#############################################


##  get variables from comand line
args = commandArgs(trailingOnly=TRUE)

dirname= args[1]
TRAIT= args[2]
AXES= args[3]
n=0.15 #n= as.numeric(args[6])



d= read.table(paste(dirname,"AncRec_sampled_by","_",n,"_",TRAIT,"_",AXES, ".txt", sep=""), h=T)
d$sample2 = as.factor(d$sample)


#####--------  make function for normalization
normalize = function(x){(x-min(x,na.rm=T))/(max(x,na.rm=T)-min(x,na.rm=T))}

##########################################################################################
#########   prepare the output for the different stats per timeslice over the trait axes
##########################################################################################

statsOtime= as.data.frame(matrix(NA, length(levels(d$sample2)) , 1 ))
statsOtime[,1]= as.numeric(as.character(levels(d$sample2)))
names(statsOtime)="time"


#############################################
#########  ----------------------------------- get range from each timeslice:
minv= aggregate( d[,1], list(d$sample2), min)
maxv= aggregate( d[,1], list(d$sample2), max)
### range of the axes
statsOtime$range= abs(minv[,-1]-maxv[,-1])


#############################################
######################  --------------------- get number of linegaes per timeslice
count_per_bin= aggregate( d[,1], list(d$sample2), length )
## combine and remove the first row = root value as diversity= 0
statsOtime$numLineages = count_per_bin[,2]
##########################################################################################
#########   do the same stats over the BM iterations
##########################################################################################

numsim=500
BM_raw=read.table( paste(dirname, "Anc_states_BMnullModel","_", numsim, "sim", "_", TRAIT, "_", AXES, ".txt" ,sep=""),h=T)


#####  prepare output for the mean values
mean_statsBM= as.data.frame(matrix(NA, length(levels(d$sample2)) , 1 ))
mean_statsBM[,1]= as.numeric(as.character(levels(d$sample2)))
names(mean_statsBM)="time"

#############################################
#########  ----------------------------------- get range from each timeslice for each iteration
rangeSim = aggregate( BM_raw[,2: (numsim+1)], list(d$sample2), function(x) abs(diff(range(x))))
mean_statsBM$mean_range = apply(rangeSim[,-1], 1, mean  )


##########################################################################################
#########   comparison of slopes  brownian motion versus empirical data,  and the range of the 500 simuulation  in tim-slices of 0.15 Myr
##########################################################################################

###. slope is calcualted over 3 timeslices , starting from each timeslice -> sliding window with overlap
smo=3

Dif_slopeBMrange = matrix(NA,(dim(statsOtime)[1]-smo), 500 )
LstatsOtime= cbind(statsOtime$time, normalize(statsOtime$range)*100)
for ( i in 1:500) {
        for ( j in 1:(dim(statsOtime)[1]-smo) ){
                tmpSIM= cbind(statsOtime$time, normalize(rangeSim[,i+1])*100)
                BM_slope= lm( tmpSIM[j:(j+smo),2] ~ tmpSIM[j:(j+smo),1])$coefficients[2]
                OBS_slope= lm( LstatsOtime[j:(j+smo),2] ~ LstatsOtime[j:(j+smo),1])$coefficients[2]
                Dif_slopeBMrange[j,i]= OBS_slope- BM_slope
        }
        
}
MEAN_DIF_SLOPE_RANGE=apply(Dif_slopeBMrange, 1, mean)

###  get the timevector of the center of each sliding window (for plotting the slopes its shifted because the slope is calculated inbetween three sampling points 

tshift=median(statsOtime$time[1:c(smo+1)])
t1=statsOtime$time+tshift
t1= t1[1:c(length(t1)-smo)]




###  calucualte teh 95% polygon for the comparisons to all the 500 BM simulations

        k=nrow(Dif_slopeBMrange)
        dd=c(0.05/2, 1-0.05/2)
        tmp=sapply(1:k, function(x) quantile(Dif_slopeBMrange[x,], probs=dd, na.rm=TRUE))
        yy=c(tmp[1,], rev(tmp[2,]))
        xx=c(t1 , rev(t1))
        polyRANG_E_RANGE =cbind(x=xx, y=yy)

save(statsOtime, file=paste(dirname, "stats_over_time_observed.Rdata", sep=""))
save(mean_statsBM, file=paste(dirname, "stats_over_time_BM.Rdata", sep=""))

Dif_slopeBMrange2 =cbind(t1, Dif_slopeBMrange )
save(Dif_slopeBMrange2, file=paste(dirname, "Diff_slope_to_sim_over_time.Rdata", sep=""))




