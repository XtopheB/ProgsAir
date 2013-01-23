/* 23/12/2012 :  */

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
quietly ds
local Allvar `r(varlist)'
foreach v of local Allvar{
	di " variable `v' treated"
	quietly capture replace `v' = "" if `v' == "NA"
	quietly destring `v', dpcomma replace

}


egen ID=group(carrier)   /* Generates a unique identifier for each carrier  */
order ID carrier* year 

xtset  ID year
xtdescribe, patterns(50)

/*********************************************	*/
/* variables of interest 						*/

/* Capital */
local Kvar "mtowkg"

/* - Labor                                      */
local Lvar "totalpersonnelendyearpersonnel pilotsandcopilotstotalexpenditur totalpersonneltotalexpenditure pilotsandcopilotsendyearpersonne"

/* - Energy                                     */
local Evar "fuelexp fuelprice fuelquantity"

/* - Material                                    */
local Mvar ""

/* - Output                                    */
local Outvar " or_total or_othertot rpktotal rtktotal rpktotaldom rpktotalint rtktotaldom rtktotalint tkpaxtotal"

local KLEMYvar  "`Kvar' `Lvar' `Evar' `Mvar' `Outvar'"

foreach v of local KLEMYvar{
	di " variable `v' treated"
	xtsum `v'
	}


/* Tentative de visualisation des missiings */
egen toto = rownonmiss( mtowkg )
bysort year : egen tata= sum(toto)

bysort year : sum tata
	
misstable summarize   /* On a 14 missing pour ID (== "" pour carrier)   ! ETRANGE !!*/




xtsum rpktotal
xttab rpktotal

/* Si on veut rendre rectangle notre jeu de données (en emplisssant de missing  */
*fillin carrier year

