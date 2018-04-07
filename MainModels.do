
/*============================================\
| Main Models                                 |
| needs from SSC: cmp, ghk2                   |
| D.S., Oxford, Nov. 6 2012 00:06             |
| D.S. Nov. 19 2012 18:44 added marg. fear    |
| D.S. Mar. 22 2013 18:11 bootstrap SE        |
| D.S. Jun 18 2013 added Gini samll sample    |
|                  correction                 |
\============================================*/


* Note 1: Our original analyses were carried out using
* Stata 12 MP for Limux run on OSC (Oxford's supercomputing cluster).

* Note 2: The analysis below is quite computationally intensive.
* You can reduce computation time considerably by removing 
* the bootstrap statements in programs m1_est and m2_est.



set more off

set seed 02143


* Load Data
use "Data.dta", clear

* rescale variables
replace Rgdp = Rgdp/10000
replace incdist = incdist/10000
replace age = age/10
*combine first redist. pref. cat. (due to sparsity)
recode rincd (1 2=1)(3=2)(4=3)(5=4)


* Merge in 5 overimputed Gini values and 
* replace Rgini with overmiputed value in each
* multiply imputed dataset
merge m:1 region using GiniData
drop _merge
forvalues i =1/5{
  replace Rgini = RGini`i' if _mi_m==`i'
}

* Center Macro variables
forvalues i = 1/5 {
  foreach v in Rgini Ruerate Rforeign Rgdp Rtech {
    qui sum `v' if _mi_m==`i'
    replace `v' = (`v'-`r(mean)') if _mi_m==`i'
  }
}





  
/* M1: redistribution eq., continuous income,
standard errors clustered by region/country via nonparametric bootstrap
multiple imputation estimates (standard error penalized for MI) */
program m1_est, eclass properties(mi)
bootstrap, clu(region cntry) rep(100): cmp (rincd= c.incdist##c.Rgini age female eduyrs transue transnlf hhmmb lowsup smempl whcol blcol noclass skillshg skillssp Rforeign Ruerate Rtech Rgdp), ind(5) nolr qui
end
mi est, post saving(m1_est, replace) vart: m1_est 1

/* Wald test vs M0 */
mi test [rincd]: incdist Rgini age female eduyrs transue transnlf hhmmb lowsup smempl whcol blcol noclass skillshg  skillssp Rforeign Ruerate Rtech Rgdp



/* TABLE 2a */
/* pred. prob.,4 cells: low high income, low high gini */
/* thus _at is */
/* 1: low income, low gini */
/* 2: low income, high gini */
/* 3: high income, low gini */
/* 4: high income, high gini */
/* Rgini and income distance set at 10th and 90th quantile,
   cf. tabstat Rgini, stat(p10 p90), if _mi_m!=0 
   and tabstat incdist, stat(p10 p90), if _mi_m!=0 */
program m1_predictions, eclass properties(mi)
 version 12
 args categ
 m1_est
margins, predict(eq(#1) pr outcome(`categ')) force at(incdist = -2.5 Rgini= -0.04) at(incdist = -2.5 Rgini= 0.05) at(incdist = 3 Rgini= -0.04) at(incdist = 3 Rgini= 0.05) vsquish noatlegend post
end
mi est: m1_predictions 4



/* TABLE 2b */
/* Rgini average marginal effect for low (_at 1) and high (_at 2) income individuals */
program m1_rgini, eclass properties(mi)
 version 12
 args categ
 m1_est
  margins, predict(eq(#1) pr outcome(`categ')) dydx(Rgini) force at(incdist = -2.5) at(incdist = 3) vsquish noatlegend post
end
mi est: m1_rgini 4 





/* M2: redistribution & fear eq., continuous income,
standard errors clustered by region/country via nonparametric bootstrap
multiple imputation estimates (standard error penalized for MI) */
program m2_est, eclass properties(mi)
bootstrap, clu(region cntry) rep(100): cmp (rincd= c.incdist##c.Rgini fear c.fear#c.incdist age female eduyrs transue transnlf hhmmb lowsup smempl whcol blcol noclass skillshg skillssp Ruerate Rtech Rgdp Rforeign) (fear=incdist Rgini age female eduyrs transue transnlf hhmmb lowsup smempl whcol blcol noclass victim Rgdp Rforeign), ind(5 5) nolr 
end
mi est, post saving(m2_est, replace) vart: m2_est 1

/* Wald test vs M0 */
mi test ([atanhrho_12]:_cons) ([fear]: incdist Rgini age female eduyrs transue transnlf hhmmb lowsup smempl whcol blcol noclass victim Rgdp Rforeign) ([rincd]: incdist Rgini fear age female eduyrs transue transnlf hhmmb lowsup smempl whcol blcol noclass skillshg skillssp Ruerate Rtech Rgdp Rforeign)

/* Wald test vs. M1 */
mi test ([atanhrho_12]:_cons) ([fear]: incdist Rgini age female eduyrs transue transnlf hhmmb lowsup smempl whcol blcol noclass victim Rgdp Rforeign)

/* Wald test corr+endog.effect == 0 */
mi test ([atanhrho_12]:_cons) ([rincd]:fear)



/* TABLE 3 */  

/* First row: marginal effect of fear (calculated via discrete prob. difference, 3->4) */
program m2_fear, eclass properties(mi)
 version 12
 args categ
 m2_est
 margins, predict(eq(#1) pr outcome(`categ')) force at(incdist = 3 fear=3) at(incdist = 3 fear=4) vsquish noatlegend post
end
mi est (diff21:_b[2._at]-_b[1._at]): m2_fear 4

/* Second row: Rgini average marginal effect for high income individuals */
program m2_rgini, eclass properties(mi)
 version 12
 args categ
 m2_est
 margins, predict(eq(#1) pr outcome(`categ')) dydx(Rgini) force at(incdist = 3) vsquish noatlegend post
end
mi est: m2_rgini 4 




* Average LogLikelihood values 
* This calculates a simple average LL for each model

matrix LL = (.,.,.,.,.)
matrix BIC = (.,.,.,.,.)

/* M1 */
forvalues i = 1/5{
  qui: cmp (rincd= c.incdist##c.Rgini age female eduyrs transue transnlf hhmmb lowsup smempl whcol blcol noclass skillshg skillssp Ruerate Rtech Rgdp Rforeign) , ind(5) nolr, if _mi_m==`i'
  mat LL[1, `i'] = e(ll)
  mat BIC[1, `i'] = -2*e(ll) + e(rank)*ln(e(N))
}
mata: rowsum(st_matrix("LL"))/5
mata: rowsum(st_matrix("BIC"))/5

/* M2 */
forvalues i = 1/5{
  qui: cmp (rincd= c.incdist##c.Rgini fear c.fear#c.incdist age female eduyrs transue transnlf hhmmb lowsup smempl whcol blcol noclass skillshg skillssp Rforeign Ruerate Rtech Rgdp) (fear=incdist Rgini age female eduyrs transue transnlf hhmmb lowsup smempl whcol blcol noclass victim Rgdp Rforeign), ind(5 5) nolr, if _mi_m==`i'
  mat LL[1, `i'] = e(ll)
  mat BIC[1, `i'] = -2*e(ll) + e(rank)*ln(e(N))
}
mata: rowsum(st_matrix("LL"))/5
mata: rowsum(st_matrix("BIC"))/5




