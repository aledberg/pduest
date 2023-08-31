## code to produce a figure showing the estimated
## first run the code in main.R to create "fitStan"
require(ggplot2)

sums <- as.data.frame(summary(fitStan))
indx <- grepl("totalN\\[",labels(sums[1])[[1]])
indxmiss <- grepl("totalMiss",labels(sums[1])[[1]])

## total number of patients per year
totpat <- vector(length = standat$nYears)
for (i in 1:standat$nYears) {
    totpat[i] <- 0
    for (j in 1:4)
        totpat[i] <- totpat[i]+standat$nPat[j+(i-1)*4]
}


pldat <- data.frame(y = sums$summary.mean[indx],
                    upper = sums$summary.97.5.[indx],
                    lower = sums$summary.2.5.[indx],
                    years = ylist,
                    type = "total")
pldat <- rbind(pldat,data.frame(y = sums$summary.mean[indxmiss],
                    upper = sums$summary.97.5.[indxmiss],
                    lower = sums$summary.2.5.[indxmiss],
                    years = ylist,
                    type = "missing"))

pldat <- rbind(pldat,data.frame(y = totpat,
                    upper = NA,
                    lower = NA,
                    years = ylist,
                    type = "patienter"))

pldat$t2 <- factor(pldat$type,levels = c("total","missing","patienter"))

pl <- ggplot(data = pldat,aes(x = years,y = y,col = t2))+geom_line(linetype = "dashed")+
    geom_errorbar(aes(ymin = lower,ymax = upper))+geom_point(size = 4)+
    theme_bw(base_size = 14)+xlab("år")+ylab("antal personer (posterior mean +- 95% cred. int.)")+
    theme(legend.position = c(0.7,0.6))+
    labs(color = NULL)+scale_color_discrete(labels = c("total","\"hidden\" popluation","patients in health care"))

show(pl)
