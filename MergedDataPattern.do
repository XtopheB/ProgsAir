/* 23/12/2012 	:  Importation des données et pré-traitement  */
/*				: remplacement des missings, des ", " etc..*/
/* 23/01/2013 	: Visualisation des missing par variable et par an   */


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

xtset  Id year
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

/* Liste de toutes les variables pertinentes */
local KLEMYvar  "`Kvar' `Lvar' `Evar' `Mvar' `Outvar'"

/* Tentative de visualisation des missiings */
	
misstable  summarize  `KLEMYvar' 

/* Création d'une matrice qui contient les % de non nul par variable et par an */

local n : word count `KLEMYvar'
matrix nonnul = J( `n',16, 0)
mat rowname nonnul = `KLEMYvar'
mat colname nonnul = 1995 1996 1997 1998 1999 2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010

local i=1
foreach v of local KLEMYvar{
	 local j= 1
	forvalues y = 1995/2010{
		quietly distinct carrier if year == `y'
		local nbcar =`r(N)'
		quietly count if `v'!=. & year == `y'
		mat nonnul[`i' , `j']= round(`r(N)'*100/`nbcar', 2)
		local j= `j' +1
	}
	local i= `i'+1
}
mat list nonnul
order Id carrier* year `KLEMYvar'
sort carrier year


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

/* Si on veut rendre rectangle notre jeu de données (en emplisssant de missing  */
*fillin carrier year

