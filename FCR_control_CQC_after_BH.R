
source('R/Simulations/3D/simulationUtility.R')




configurations<- expand.grid(
  rho= c(0, 0.2, 0.4, 0.6, 0.8, 0.95),
  replications=100L, 
  sigma.scale= c(0.5, 1, 1.5),
  pi1=c(0, 0.1, 0.5, 0.9),
  n.sample=c(4, 16, 32))

## Serial version (uncomment to run)
# configuration.fcrs<- apply(configurations, 1, wrapRun)

# Parallel version
library(parallel)
cl<- makeCluster(getOption("cl.cores", 2))
clusterEvalQ(cl=cl, source('simulationUtility.R'))
configuration.fcrs<- parApply(cl=cl, configurations, 1, wrapComputeFCRs3D)
stopCluster(cl)


configuration.fcrs.df<- data.frame(configurations, t(configuration.fcrs))
configuration.fcrs.df$CI.arm<- with(configuration.fcrs.df, 2* sd.FCR/sqrt(length.FCR))
configuration.fcrs.df$FWHM<- with(configurations, sapply(sigma.scale, function(y) geometricMean(diag(var2FWHM(observed.sigma.voxels*y)))))


## Visualize:
FCR<- 0.1
base.plot<- ggplot(data=configuration.fcrs.df) + 
  ylab("FCR") + xlab('Mean effect') + xlim(c(0, 0.95)) +
  geom_line(aes(y=mean.FCR , x=rho, colour = factor(n.sample)), size=1, shape=1) +
  geom_hline(mapping=aes(yintercept= FCR), lty=2) +
  geom_segment(mapping=aes(x=rho, y=mean.FCR-CI.arm, xend=rho, yend=mean.FCR+CI.arm, colour = factor(n.sample)), size=0.5) +
  facet_grid(FWHM ~  pi1, labeller = label_both)
base.plot


