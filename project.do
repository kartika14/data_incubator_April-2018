version 15
capture log close
set more off
clear
clear matrix
clear mata

	    glo rootdir		"C:\Users\WB485280\OneDrive - WBG\personal\docs\jobs\data_science\challenge"
		glo	datadir     "${rootdir}\rawdata"
		glo outdir		"${rootdir}\output"
		glo dodir		"${rootdir}\dofiles"
        
		cd "${outdir}"
		
	    log using dataincubator, replace t

* ------------------------------------------------------------------------------

  display "`c(current_time)' `c(current_date)'"

* Project : Data Incubator Challenge April 2018

* Dataset used: census1968-2014.dta and round1all.dta

* ------------------------------------------------------------------------------

///////////CENSUS DATA////////////////
 
	
*Import department panel data from census		
    use "$datadir\census1968-2014\census1968-2014.dta", clear
    rename an_recens year
    
	g byte popt_res = 1
	
	
*Nationality

    gen     nation=1  if natio=="000"
	replace nation=2  if natio=="001"
	replace nation=3  if natio=="1IT"
	replace nation=4  if natio=="1ES"
	replace nation=5  if natio=="1PT"
	replace nation=6  if natio=="2**"
	replace nation=7  if natio=="3DZ"
	replace nation=8  if natio=="3MA"
	replace nation=9  if natio=="3TN"
	replace nation=10 if natio=="3**"
	replace nation=11 if natio=="4TR"
	replace nation=12 if natio=="***"
    label define na  1"french by birth" 2 "french by acquisition" 3"italien" ///
	                 4"spanish" 5"portugal" 6"other european" 7"algerian" ///
					 8"moroccan" 9"tunisian" 10"other africans" 11"turkish" 12 "other"
    label values nation na
	
	gen     euimmigrant=0
	replace euimmigrant=1 if nation==3 | nation==4 | nation==5 | nation==6 
	
	gen     noneuimmigrant=0
	replace noneuimmigrant=1 if nation==7 | nation==8 | nation==9 | nation==10 | nation==11 | nation==12

	gen     immigrant=euimmigrant+noneuimmigrant
	
	gen     citizen_immi=0
	replace citizen_immi=1 if nation==2
	
	gen     voting_cit=0
	replace voting_cit=1 if nation==1 
	replace voting_cit=1 if nation==2
	
	gen     citizen_immig_18up=0
	replace citizen_immig_18up=1 if citizen_immi==1 & age18abv==1
	

   
		g byte popt_res = 1

   
	tab nation                , gen(nationality)
    

		
*Collapsing data to create dept level estimates (keeping the same labels)


foreach v of var nationality1-nationality12 euimmigrant noneuimmigrant immigrant citizen_immi voting_cit citizen_immig_18up popt_res {
 	local l`v' : variable label `v'
        if `"`l`v''"' == "" {
 		local l`v' "`v'"
  	}
  }
collapse (sum) nationality1-nationality12 euimmigrant noneuimmigrant immigrant citizen_immi voting_cit citizen_immig_18up popt_res [pw=pond], by(dep_res_16 year)


 foreach v of var nationality1-nationality12 euimmigrant noneuimmigrant immigrant citizen_immi voting_cit citizen_immig_18up popt_res {
 	label var `v' "`l`v''"
 }

save "$datadir\collapsed_census.dta", replace 


///////////ELECTION DATA////////////
 
  use "$datadir\election\round1all.dta", clear
  drop in 983/1665
  tab Year
  rename Year year
  * dropping overseas territory and corsica

drop if Code_du_departement=="99" | ///
        Code_du_departement=="971" | Code_du_departement=="972" |Code_du_departement=="973" | ///
		Code_du_departement=="974" | Code_du_departement=="975" |Code_du_departement=="979" | ///
		Code_du_departement=="985" | Code_du_departement=="986" |Code_du_departement=="987" | Code_du_departement=="988"
  
 drop if Code_du_departement=="20" /// Corse was divided into upper and lower corsica in 1975
 
 replace Code_du_departement="96" if Code_du_departement=="2A"
 replace Code_du_departement="97" if Code_du_departement=="2B"
 replace Code_du_departement="01" if Code_du_departement=="1"
 replace Code_du_departement="02" if Code_du_departement=="2"
 replace Code_du_departement="03" if Code_du_departement=="3"
 replace Code_du_departement="04" if Code_du_departement=="4"
 replace Code_du_departement="05" if Code_du_departement=="5"
 replace Code_du_departement="06" if Code_du_departement=="6"
 replace Code_du_departement="07" if Code_du_departement=="7"
 replace Code_du_departement="08" if Code_du_departement=="8"
 replace Code_du_departement="09" if Code_du_departement=="9"

 sort   Code_du_departement
 encode Code_du_departement, gen( dept)
 order  Code_du_departement dept
 
 _strip_labels dept //removing value labels from dept
 
 * gen a new year variable to match the census data
 
 gen     date=1 if year==1988
 replace date=2 if year==1995
 replace date=3 if year==2002
 replace date=3 if year==2007
 replace date=4 if year==2012
 replace date=5 if year==2017
 replace date=6 if year==1969
 replace date=6 if year==1974
 replace date=7 if year==1981
 replace date=0.1 if year==1965

 rename year year_election
 
 * Cleaning election variables
 
 *1965
 rename mitterrandcir             mitterrandcir65 
 rename lecanuetmrp               lecanuetmrp65
 rename degaulleunr               degaulleunr65
 rename tixiervignancourexd       tixiervignancourexd65
 rename marcilhacydvd             marcilhacydvd65 
 rename barbudiv                  barbudiv65
 
 *1969
 rename krivinelcr                krivinelcr69
 rename rocardpsu                 rocardpsu69 
 rename duclospcf                 duclospcf69 
 rename pompidouudr               pompidouudr69_74 
 rename defferresfio              defferresfio69 
 rename pohercd                   pohercd69
 rename ducateldiv                ducateldiv69
 
 *1974
 rename laguillerlo               laguillerlo74to17 
 rename krivinelcr_01             krivinelcr74 
 rename mitterrandps              mitterrandps74to17
 rename dumonteco                 dumonteco74
 rename mullermdsr                mullermdsr74
 rename giscarddestaingri         giscarddestaingri74_02_07
 rename royerdvd                  royerdvd74
 rename renouvinnar               renouvinnar74
 rename herauddiv                 herauddiv74
 rename sebagdiv                  sebagdiv74
 
 *1981
 rename bouchardeaupsu            bouchardeaupsu81 
 rename marchaispcf               marchaispcf81to07 
 rename crepeaumrg                crepeaumrg81 
 rename lalondeeco                lalondeeco81 
 rename giscarddestaingudf        giscarddestaingudf81_88 
 rename chiracrpr                 chiracrpr81to02 
 rename debredvd                  debredvd81
 rename garauddvd                 garauddvd81 
 
 *1988
 rename bousselmpt                bousselmpt88 
 rename juquin                    juquin88 
 rename waechterv                 waechterv88to07 
 
 *1995
 rename balladurudf               balladurudf95 
 rename devilliersmpf             devilliersmpf95_07 
 rename cheminadepoe              cheminadepoe95_12_17 
 
 *2002
 rename glucksteinpt              glucksteinpt02_07 
 rename besancenotlcr             besancenotlcr02_07 
 rename taubiraprg                taubiraprg02
 rename chevenementprep           chevenementprep02 
 rename lepagecap21               lepagecap2102 
 rename madelindl                 madelindl02 
 rename boutinudfdiss             boutinudfdiss02 
 rename megretmnr                 megretmnr02 
 rename saintjossecnpt            saintjossecnpt02_07 
 
 *2007
 rename bove                      bove07 
 rename sarkozyump                sarkozyump07_12 
 
 *2012
 rename jeanlucmelenchonfg        jeanlucmelenchonfg12 
 rename philippepoutounpa         philippepoutounpa12_17 
 rename evajolyeelv               evajolyeelv12 
 rename franãoisbayroumodem       franãoisbayroumodem12 
 rename nicolasdupontaignandlr    nicolasdupontaignandlr12
 
 *2017
 rename vote_fillon               fillon17
 rename vote_melenchon            melenchon17
 rename vote_dupont_aignan        dupontaignan17
 rename vote_asselineau           asselineau17
 rename vote_lassalle             lassalle17
 
 
 rename lepenf                    lepenfn1
 
 gen     extreme_rt=.
 replace extreme_rt=tixiervignancourexd65 if tixiervignancourexd65~=.
 replace extreme_rt=lepenfn1 if lepenfn1~=.
 replace extreme_rt=extreme_rt+megretmnr02 if megretmnr02~=.

 gen     extreme_left=.
 replace extreme_left=krivinelcr69 if krivinelcr69~=.
 replace extreme_left=laguillerlo74to17 if laguillerlo74to17~=.
 replace extreme_left=krivinelcr74+extreme_left if krivinelcr74~=.
 replace extreme_left=bousselmpt88+extreme_left if bousselmpt88~=.
 replace extreme_left=besancenotlcr02_07+extreme_left  if besancenotlcr02_07 ~=.
 replace extreme_left=glucksteinpt02_07+extreme_left if glucksteinpt02_07~=.
 replace extreme_left=philippepoutounpa12_17+extreme_left if philippepoutounpa12_17~=.

 
 sort dept date
 save "$datadir\dept_election_panel_v1.dta", replace 


***Merging census and election data
 
merge m:1 dept date using "$datadir\collapsed_census.dta"

gen temp_year= year_election

drop _merge

sort dept temp_year 
 
save "$datadir\dept_panel.dta", replace 

 
*Immigrant shares
egen eu                   =rowtotal (nationality3 nationality4 nationality5 nationality6)
egen noneu                =rowtotal (nationality7 nationality8 nationality9 nationality10 nationality11 nationality12)
gen nc_immig              =eu+noneu
gen cit_immig             =nationality2
gen total_immig           =nc_immig+cit_immig
gen share_eu              =(eu/popt_res)
gen share_noneu           =(noneu/popt_res)
gen share_nc_immig        =(nc_immig/popt_res)
gen share_immig           =(total_immig/popt_res)

*Among voting population
gen share_fn              =(lepenfn/exprimãs)
gen share_ext_rt          =(extreme_rt/exprimãs )
gen share_ext_lft         =(extreme_left/exprimãs )


*Labels
label var share_fn              "Share of FN votes"
label var share_ext_rt          "Share of extreme-right votes"
label var share_ext_lft         "Share of extreme-left votes"
label var share_immig           "Share of all immigrants in total pop"
label var share_eu              "Share of EU non-citizen immigrants in total pop"
label var share_noneu           "Share of NonEU non-citizen immigrants in total pop"
label var share_nc_immig        "Share of non-citizen immigrants in total pop"
label var nc_immig              "No. of non-citizen immigrants"
label var cit_immig             "No. of citizen immigrants"
label var total_immig           "No. of total immigrants"
label var cmvoteshare           "Share of citizen immigrant in voting pop"


sort dept year_election
save "$outdir\frenchpanel_v1.dta", replace
 
 
///////////////////////////////////////////
***Box plots FIGURE 1
//////////////////////////////////////////
use "$outdir\frenchpanel_v1.dta", clear

gen tshare_fn=share_fn*100

graph box tshare_fn if year_election>=1988, over(year_election) ///
                ytitle("Share of votes for FN") ///
	            title ("Voting for FN in presedential elections") name(part0) 

gen tshare_nc_immig=share_nc_immig*100
gen tcmvoteshare=cmvoteshare*100
gen tshare_immig=share_immig*100

graph box tshare_nc_immig if year_election>=1988, over(year_election) ///
                ytitle("Share of non-citizen immigrants in total pop") ///
	            title ("Share of non-citizen immigrants") ///
				name(part00)

graph box tcmvoteshare if year_election>=1988, over(year_election) ///
                ytitle("Share of naturalized immigrants in voting pop") ///
	            title ("Share of naturalized immigrants")  ///
                name(part000) 
				
graph combine part0 part00 part000, holes(2) iscale(0.5) scheme(s2gcolor) title(Figure 1: Distribution of FN vote share and immigrant shares over time, size(3))

///////////////////////////////////////////
***Correlation FIGURE 2
//////////////////////////////////////////				
use "$outdir\frenchpanel_v1.dta", clear


keep if year_election == 1988 | year_election == 2017
bysort dep_res_16 ( year_election ): gen y        = share_fn    - share_fn[_n-1]
bysort dep_res_16 ( year_census ): gen x          = share_immig - share_immig[_n-1]
aaplot y x, msymbol(o) xtitle("Change in total immigrant share 1988-2017") ///
                       ytitle("Change in FN vote share 1988-2017") ///
					   title (Figure 2: Correlation between change in voting for FN and change in immigration, size(3))


					   
log close
