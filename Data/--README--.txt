
============================================================
Further replication materials for:
The Externalities of inequality. Fear of crime and 
redistribution in Western Europe

DATA 

The replication code on the dataverse comes with a file
called Data.dta for easier replication of our analyses.
This replication archive contains all steps to create
this datafile starting from original ESS data 
(downloaded from http://www.europeansocialsurvey.org/data)
The original ESS files are included in the folder 
original_ESS_files of this archive.
============================================================

D.S. April 14 2015


This archive creates file *data_imputed.dta* 
(This file is identical to Data.dta included in 
    our main Dataverse)
It further creates: *data_listwise.dta, DataRobust12, 
DataRobust13*, which are used in robustness tests.


Execute these 10 files in sequence:
Note: If you are on a unix-like system (Linux, MacOS) you can
simply run file *runall.sh* in your shell to execute all files.

1__genMicroData.do
2__recodeData.R
3__imputeMVN.R
4__recodeImputedData.R
5__calcRegionalGini.do
6__genFinalImputedDataset.do
7__genMicroDataRobust13.do
8__recodeDataRobust13.R
9__genMicroDataRobust12.do
10__recodeDataRobust12.R



Here is a short description of each file:

1__genMicroData.do: combines 4 ESS data sets and executes some
    basic recodes (incl. income calculations).

2__recodeData.R: merge combined ESS data file with regional data,
    harmonize names of Eurostat NUTS regions. Prepares dataset
    used for multiple imputation.

3__imputeMVN.R: Multivariate normal imputation of missing data

4__recodeImputedData.R: merge imputed data files with regional
    data, harmonize names of Eurostat NUTS regions.

5__calcRegionalGini.do: Calculate regional Gini estimates from
    average income of 5 imputed data sets.

6__genFinalImputedDataset.do: combine 5 imputed data sets from
    step 4 and merge regional gini from step 5.

7__genMicroDataRobust13.do
8__recodeDataRobust13.R
9__genMicroDataRobust12.do
10__recodeDataRobust12.R
    As above, but adapted for robustness tests 12 + 13
    (permuted midpoints and alternative def. of income dist.)    



Auxiliary files:
RegionalData.csv:   regional data, downloaded from Eurostat's
                    region database
ppp_cpi.dta:        Purchasing power parities, from Eurostat
isco2esec.do:       Do file converting ISCO codes to ESEC
                    social class scheme

