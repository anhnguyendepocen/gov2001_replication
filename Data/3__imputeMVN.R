# Step 3 of 6
# Multivariate normal imputation of missing data


set.seed(123453)

# Required libraries
library(foreign)
library(Amelia)

# Read data
dat <- read.dta("working.dta", convert.factors=FALSE)


# set sensible bounds for income
# upper bound is max obsered income times 5
bounds <- matrix(NA, nrow=1, ncol=3)
bounds[1,1] <- which(colnames(dat)=="income_ppp2005")
bounds[1,2] <- 0
bounds[1,3] <- max(dat$income_ppp2005, na.rm=TRUE)*5

# MVN imputation, using amelia
# Cross-section is countrues
# Time dimension is survey year
imps <- amelia(dat, cs="cntry", ts="year", 
    idvars=c("cntryyear","idno","regionat", "regionbe", "regionch",
        "regionde", "regiondk", "regiones", "regionfr", "regiongb",
        "regionie", "regionnl", "regionno", "regionpt", "regionse",
        "regioach", "regioafi", "regioaes", "regioapt", "iscoco",
        "nacer1"), 
	ords=c("rincd", "fear", "equalop"), 
    noms=c("esec","transfer","denom"),
    polytime=2, bounds=bounds)

# compare densities of imputed income and rincd
compare.density(imps, var="income_ppp2005")
compare.density(imps, var="rincd")
	

# save imputed data set
save(imps, file="3__imputeMVN.Rdata")
	
