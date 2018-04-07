
stata-mp -q -b do 1__genMicroData.do
R CMD BATCH --no-save 2__recodeData.R
R CMD BATCH --no-save 3__imputeMVN.R
R CMD BATCH --no-save 4__recodeImputedData.R
stata-mp -q -b do 5__calcRegionalGini.do
stata-mp -q -b do 6__genFinalImputedDataset.do

stata-mp -q -b do 7__genMicroDataRobust13.do
R CMD BATCH --no-save 8__recodeDataRobust13.R

stata-mp -q -b do 9__genMicroDataRobust12.do
R CMD BATCH --no-save 10__recodeDataRobust12.R
