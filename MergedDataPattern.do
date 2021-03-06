/* 23/12/2012 	:  Importation des donn�es et pr�-traitement  */
/*				: remplacement des missings, des ", " etc..*/
/* 23/01/2013 	: Visualisation des missing par variable et par an   */
/* 24/01/2013	: Definition of variables Y, K, L, E,  M (to discuss)     */
/* 05/02/2012 	: Nouvelles d�finitions des inputs et des outputs (C +N ) */
/* 29/03/2013	: V�rifiaction des variables, cr�ation de nouvelles listes (C+N)*/
/* 29/03/2013 	: Cr�ation d'un fichier avec toutes les variables KLEM possibles  */ 


/* Remove everything  */
clear
clear results
clear matrix

global root C:\chris\Zprogs\Air\progs

/* Convenient mode for results (no stops, all results listed  */
set more off
set output proc
/* Change working directory to the one specified in $root*/

cd $root

/*------------------------------*/
/* PART 1 : Data importation   */
/*==============================*/
/* Data importation from the text tabulated files */
insheet using "../Sources/merge6.csv", delimit(";")

/*Tratment of the variables 
-  removing NA --> .  
-  convert to numeric        
-  remove the  comas still remaining in some variables (convert to . (decimal )    */
/* 23/01/2013 : la variable "carrier" a une compagnie "NA", on retire cette variable de l'analyse */

quietly ds year-totalpersonneltotalexpenditure
local Allvar `r(varlist)'
foreach v of local Allvar{
	*di " variable `v' treated"
	quietly capture replace `v' = "" if `v' == "NA"
	quietly destring `v', dpcomma replace

}


egen Id=group(carrier)   /* Generates a unique identifier for each carrier  */
order Id carrier* year 
/* Attention : l'unit� est me milier de dollars sauf totalpersonneltotalexpenditure  */
replace totalpersonneltotalexpenditure = totalpersonneltotalexpenditure/1000


/* On peut incorporer des zones g�ographiques en utilsant le code pays */
gen Region = 0
forvalues i=1/9 {
	local j=`i'*100	
	replace Region = `i' if country_code >=`i'00 & country_code <= `i'99
 }
 
replace Region = 0 if country_code == 900 /* We put canada with USA  */   
label define typoRegion 0 "North America", modify
label define typoRegion 1 "South America", modify
label define typoRegion 2 "Central America", modify
label define typoRegion 3 "South America 2", modify
label define typoRegion 4 "Europe", modify
label define typoRegion 5 "Africa", modify
label define typoRegion 6 "Arabia", modify
label define typoRegion 7 "Asia", modify
label define typoRegion 8 "Malaysia", modify 
*label define typoRegion 9 "Canada", modify 

label value Region typoRegion

/* Mise en forme donn�es logitudinales  */

*xtset  Id year
*xtdescribe, patterns(50)

/*********************************************	*/
/* variables of interest 						*/

/*  Computation of new input variables (C+ N) */

gen KnonFlying = oe_amortimobfgt/priceindex  /* non flying capital (in value)*/
gen KflyingExpenditure = oe_fgtequipinsu + oe_fgtrentequip  + oe_fgtequipmain + oe_amortfgtequi

gen MaterialExpenditure = (oe_totoperatexp - totalpersonneltotalexpenditure - fuelexp - KflyingExpenditure -oe_amortimobfgt)
gen MaterialQuantity = MaterialExpenditure/priceindex
* voir si on remplace les M <0 par 0

gen PaxRevenue = or_schdpax + or_nschdpaxexcb + or_schdexcebag
gen FreightRevenue = or_schdfreight +or_schdmail + or_nschdfgtmail

/* Cr�ation des  outputs  */
gen Ypax = rpktotal
gen Yfreight = rtktotal -tkpaxtotal
gen Yincidental = or_othertot /priceindex
* todo cr�er un indice cf Diewert et al. (1982) Nath ref�rence � citer....
gen Yrevenue = or_total/priceindex

/* Capital */
local Kvar "mtowkg  KnonFlying KflyingExpenditure  oe_amortimobfgt oe_fgtequipinsu oe_fgtrentequip  oe_fgtequipmain oe_amortfgtequi "

/* - Labor                                      */
*local Lvar "totalpersonnelendyearpersonnel  totalpersonneltotalexpenditure pilotsandcopilotstotalexpenditur  pilotsandcopilotsendyearpersonne"
local Lvar "totalpersonnelendyearpersonnel  totalpersonneltotalexpenditure "

/* - Energy                                     */
local Evar "fuelexp fuelprice fuelquantity"

/* - Material                                    */
local Mvar "MaterialExpenditure MaterialQuantity  oe_totoperatexp "

/* - Output                                    */
*local Outvar " Ypax Yfreight Yincidental Yrevenue PaxRevenue  FreightRevenue  or_total or_othertot rpktotal rtktotal rpktotaldom rpktotalint rtktotaldom rtktotalint tkpaxtotal"
local Outvar " Ypax Yfreight Yincidental Yrevenue  PaxRevenue FreightRevenue or_total or_othertot rpktotal rtktotal  tkpaxtotal"

/* Liste de toutes les variables pertinentes */
local KLEMYvar  "`Kvar' `Lvar' `Evar' `Mvar' `Outvar'"

sum `KLEMYvar'
des `KLEMYvar', full

/* Tentative de visualisation des missings */
	
misstable  summarize  `KLEMYvar' 

/* Cr�ation d'une matrice qui contient les % de non nul par variable et par an */

local n : word count `KLEMYvar'
matrix nonnul = J( `n',15, 0)
mat rowname nonnul = `KLEMYvar'
mat colname nonnul = 1995 1996 1997 1998 1999 2000 2001 2002 2003 2004 2005 2006 2007 2008 2009

local i=1
foreach v of local KLEMYvar{
	 local j= 1
	forvalues y = 1995/2009{
		quietly distinct carrier  if year == `y' 
		local nbcar =`r(N)'
		quietly count if `v'!=. & year == `y'
		*mat nonnul[`i' , `j']= round(`r(N)'*100/`nbcar', 4)  /* <<< a voir si on veut des % ?  */
		mat nonnul[`i' , `j']= `r(N)'  						/* Nbs ?  */
		local j= `j' +1
	}
	local i= `i'+1
}
mat list nonnul
outtable using Graphics/table2, mat(nonnul) replace

/* =========================== CREATION DES VARIABLES d'INTERET ===================*/ 

/* CHOIX DES VARIABLES FINALES  */

gen Y = Yrevenue
/* Cr�� le 29/03/2013  YQ pas complet (CN)  */
gen YQ = Ypax*(PaxRevenue/or_total) + Yfreight*(FreightRevenue/or_total) + Yincidental*(or_othertot/or_total) 
gen K = mtowkg
gen L = totalpersonnelendyearpersonnel
gen E = fuelquantity
gen M = MaterialQuantity	
gen YsurK = Y/K if K != 0
gen YsurL = Y/L if L != 0
gen YsurE = Y/E if E != 0
gen YsurM = Y/M if M != 0

/* TEST de la base : */
gen Test0 =Y*K*L*E*M
bysort year : count if  Test0 >0 & Test0!=.

gen YK= Y*K
bysort year : count if YK >0 & YK!=.

gen YKL = YK*L
bysort year : count if YKL >0 & YKL!=.

gen YE= Y*E
bysort year : count if YE >0 & YE!=.

gen EL=E*L
bysort year : count if EL >0 & EL!=.

bysort year : list carriername if Test0 >0 & Test0!=.
edit Id carriername year if Test0 >0 & Test0 !=.


/* Mise en ordre des donn�es et exportation */

order Id carrier* year Y K L E M `KLEMYvar' country* Region Test0
sort carrier year
preserve  
/* On garde un fichier complet pour "l'analyse des trous " Modifi� le 30/03/2013 */
keep Id carrier* year Y YQ K L E M `KLEMYvar' country* Region Test0
keep if year !=2010
label data "File created by MergedDataPattern.do, many (slected) Y, KLEM"
save   ../data/MultiYKLEM.dta, replace
/* On pr�f�re sauver en csv...*/
outsheet using  ../data/MultiYKLEM.csv , replace delimiter(";")

/* Fichier utilis� par R avec un seul Y, K, L, E, M */
label data "File created by MergedDataPattern.do, Only one variable for each KLEM"
keep Id carrier*  year Y* K L E M  country* Region  Test0
save   ../data/AllyearsKLEM.dta, replace
/* On pr�f�re sauver en csv...*/
outsheet using  ../data/AllyearsKLEM.csv , replace delimiter(";")
restore


/*Visualisation between - within par variable   */
foreach v of local KLEMYvar{
	di " variable `v' treated"
	xtsum `v'
	}

		
/essai */
egen toto = rownonmiss( mtowkg )
bysort year : egen tata= sum(toto)

bysort year : sum tata		
		
xtsum rpktotal
xttab rpktotal

/* Si on veut rendre rectangle notre jeu de donn�es (en emplisssant de missing  */
*fillin carrier year

