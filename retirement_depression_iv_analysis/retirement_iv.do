STATA code: 
* Clearing everything
clear all

* Setting working directory
cd "C:\Users\ASUS\OneDrive\Desktop\lab"

* Closing any open log files
cap log close

* Creating output directory
cap mkdir "output"

* Starting log file
local date = c(current_date)
log using "output\logfile_analysis_`date'.log", replace

* Loading the dataset
use "raw\easySHARE_rel9-0-0", clear

* Keeping 5 most recent waves from wave 5 to wave 9
keep if wave >= 5

* Restricting age range
keep if age >= 50 & age <= 69

* Keeping employed or retired people
keep if ep005 == 1 | ep005_ == 2

* Verifying countries
tab country

/* -----------------------------------
   RETIREMENT DEFINITION
   ----------------------------------- */
gen retired = (ep005_ == 1)
label var retired "Retired"

/* -----------------------------------
   DEPENDENT VARIABLE: Depression (EURO-D)
   ----------------------------------- */
replace eurod = . if eurod < 0
bysort mergeid (wave): gen eurod_change = eurod - eurod[_n-1]
label var eurod_change "Change in Depression Score"

/* -----------------------------------
   CONTROL VARIABLES
   ----------------------------------- */
* Age and Age Squared
gen agesq = age^2
label var agesq "Age squared"

* Gender
capture confirm variable female
if _rc != 0 {
    gen female = (gender == 2)
    label var female "Female"
}

* Education
replace isced1997_r = . if isced1997_r < 0
tab isced1997_r, gen(isced1997_r_)
label var isced1997_r_1 "No education"
forvalues i = 2/7 {
    local j = `i' - 1
    label var isced1997_r_`i' "ISCED-97: code `j'"
}
label var isced1997_r_8 "Still in school"
label var isced1997_r_9 "Other education"

label define isced_lbl 0 "No education" 1 "Primary" 2 "Lower secondary" 3 "Upper secondary" 4 "Post-secondary" 5 "Bachelor's" 6 "Master's/PhD" 95 "Still in school" 97 "Other"
label values isced1997_r isced_lbl

* Year Effects
tab int_year, gen(int_year_)
forvalues i = 1/8 {
    label var int_year_`i' "Time dummy for year `=2011+2*`i''"
}

* Marital Status
replace mar_stat = . if mar_stat < 0
tab mar_stat, gen(mar_stat_)
label var mar_stat_1 "Married, live with spouse"
label var mar_stat_2 "Registered partnership"
label var mar_stat_3 "Married, separate from spouse"
label var mar_stat_4 "Never married"
label var mar_stat_5 "Divorced"
label var mar_stat_6 "Widowed"

* Calculating Income
egen income = rowmean(income_pct_w1 income_pct_w2 income_pct_w4 income_pct_w5 income_pct_w6 income_pct_w7 income_pct_w8 income_pct_w9)
replace income = . if income == .
label var income "Household income percentile (average)"

/* -----------------------------------
   EARLY RETIREMENT AGE (ERA) - OECD Data
   ----------------------------------- */
gen era = .
label var era "Early Retirement Age"

* Austria
replace era = 62 if country == 11 & female == 0
replace era = 60 if country == 11 & female == 1 & int_year >= 2007

* Germany
replace era = 63 if country == 12

* Sweden
replace era = 61 if country == 13 & int_year <= 2020
replace era = 62 if country == 13 & int_year >= 2020

* Spain
replace era = 61 if country == 15

* Italy
replace era = 61 if country == 16 & female == 0 & int_year >= 2013 & int_year < 2019
replace era = 62 if country == 16 & female == 0 & int_year >= 2019

* France
replace era = 57 if country == 17

* Denmark
replace era = 60 if country == 18

* Greece
replace era = 62 if country == 19 & int_year >= 2013
replace era = 60 if country == 19 & int_year < 2013

* Switzerland
replace era = 63 if country == 20 & female == 0
replace era = 62 if country == 20 & female == 1

* Belgium
replace era = 63 if country == 23 & female == 0 & int_year >= 2019
replace era = 60 if country == 23 & female == 0 & int_year < 2019
replace era = 62 if country == 23 & int_year >= 2019
replace era = 60 if country == 23 & int_year < 2019

* Luxembourg
replace era = 57 if country == 31

* Hungary
replace era = 59 if country == 32 & female == 0 & int_year < 2013
replace era = 60 if country == 32 & int_year >= 2013
replace era = 57 if country == 32 & female == 1 & int_year < 2009
replace era = 59 if country == 32 & female == 1 & int_year < 2013 & int_year >= 2009

* Slovenia
replace era = 58 if country == 34 & female == 0 & int_year < 2013
replace era = 60 if country == 34 & female == 0 & int_year >= 2013
replace era = 56 if country == 34 & female == 1 & int_year < 2014
replace era = 58 if country == 34 & female == 1 & int_year >= 2009 & int_year < 2013
replace era = 60 if country == 34 & female == 1 & int_year >= 2013

* Estonia
replace era = 60 if country == 35 & female == 0
replace era = 60 if country == 35 & female == 1

* Lithuania
replace era = 57.5 if country == 48 & female == 0 & int_year < 2015
replace era = 61 if country == 48 & female == 0 & int_year >= 2015
replace era = 55 if country == 48 & female == 1 & int_year < 2015
replace era = 57 if country == 48 & female == 1 & int_year >= 2015 & int_year < 2019
replace era = 59 if country == 48 & female == 1 & int_year >= 2019

* Finland
replace era = 63 if country == 55

* Latvia
replace era = 60 if country == 57 & female == 0 & int_year <= 2018
replace era = 63 if country == 57 & female == 0 & int_year > 2018
replace era = 56.5 if country == 57 & female == 1 & int_year == 2005
replace era = 57 if country == 57 & female == 1 & int_year == 2006
replace era = 57.5 if country == 57 & female == 1 & int_year == 2007
replace era = 60 if country == 57 & female == 1 & int_year >= 2008 & int_year < 2014
replace era = 60.5 if country == 57 & female == 1 & int_year >= 2014 & int_year < 2018
replace era = 61 if country == 57 & female == 1 & int_year >= 2018 & int_year < 2020
replace era = 63 if country == 57 & female == 1 & int_year >= 2020

* Slovakia
replace era = 62 if country == 63 & female == 0 & int_year < 2015
replace era = 62.8 if country == 63 & female == 0 & int_year >= 2015
replace era = 58.5 if country == 63 & female == 1 & int_year < 2009
replace era = 60 if country == 63 & female == 1 & int_year >= 2009 & int_year <= 2014
replace era = 60.8 if country == 63 & female == 1 & int_year >= 2015

* Czech Republic
replace era = 60 if country == 28 & female == 0
replace era = 60 if country == 28 & female == 1

* Croatia
replace era = 60 if country == 47 & female == 0
replace era = 55 if country == 47 & female == 1 & int_year <= 2009
replace era = 58 if country == 47 & female == 1 & int_year > 2009

* Bulgaria
replace era = 54.5 if country == 51 & female == 0 & int_year <= 2008
replace era = 55 if country == 51 & female == 0 & int_year < 2010 & int_year > 2008
replace era = 57 if country == 51 & female == 0 & int_year < 2014 & int_year >= 2010
replace era = 60 if country == 51 & female == 0 & int_year >= 2014
replace era = 54 if country == 51 & female == 1 & int_year <= 2008
replace era = 55 if country == 51 & female == 1 & int_year < 2018 & int_year > 2008
replace era = 57 if country == 51 & female == 1 & int_year < 2020 & int_year >= 2018
replace era = 60 if country == 51 & female == 1 & int_year >= 2020

/* -----------------------------------
   INSTRUMENT DEFINITION
   ----------------------------------- */
gen instrument = (age >= era)
label var instrument "Age > ERA"

/* -----------------------------------
   DESCRIPTIVE STATISTICS
   ----------------------------------- */

* Defining variables for descriptive statistics
global desclist age mar_stat* isced1997_r_* retired eurod income female

* Generating summary statistics
eststo all: estpost sum $desclist
eststo work: estpost sum $desclist if retired == 0
eststo ret: estpost sum $desclist if retired == 1

* Exporting summary statistics table
esttab all work ret using "output/descriptives.doc", replace ///
    cells(mean(fmt(2)) sd(fmt(2))) label ///
    mtitles("Whole sample" "Employed" "Retired") ///
    refcat(mar_stat1 "Marital status" isced1997_r_1 "Education" ///
           retired "Retirement status" eurod "Depression (EURO-D)") ///
    nonumbers

/* -----------------------------------
   VISUALIZATIONS
   ----------------------------------- */

* Scatter plot of depression before and after retirement (by gender)
twoway (scatter eurod age if retired == 0 & female == 0, msymbol(o) mcolor(blue)) ///
       (scatter eurod age if retired == 1 & female == 0, msymbol(o) mcolor(red)) ///
       (scatter eurod age if retired == 0 & female == 1, msymbol(x) mcolor(blue%50)) ///
       (scatter eurod age if retired == 1 & female == 1, msymbol(x) mcolor(red%50)), ///
       title("Depression Level Before and After Retirement by Gender") ///
       legend(label(1 "Employed (Male)") label(2 "Retired (Male)") label(3 "Employed (Female)") label(4 "Retired (Female)"))
graph export "output/depression_trend.png", replace

* Histogram of depression for employed  people and retired people
histogram eurod if retired == 0, width(1) color(blue) percent title("Depression Score - Employed") name(hist_emp, replace)
graph export "output/hist_employed.png", replace

histogram eurod if retired == 1, width(1) color(red) percent title("Depression Score - Retired") name(hist_ret, replace)
graph export "output/hist_retired.png", replace

/* -----------------------------------
   REGRESSION ANALYSIS
   ----------------------------------- */

* Defining control variables
global controllist age agesq female mar_stat_2-mar_stat_6 isced1997_r_2-isced1997_r_9 int_year_2-int_year_8 income

* Dependent variable
global depvar eurod

* OLS Regression
eststo ols: reg $depvar retired
estadd local sample "OLS", replace

* OLS with controls
eststo ols_x: reg $depvar retired $controllist
estadd local sample "OLS w. controls", replace

* Fixed Effects (FE) Model
egen id = group(mergeid)
xtset id wave

* Fixed-effects regression
eststo fe: xtreg $depvar retired, fe
estadd local sample "FE", replace

* Fixed-effects with controls
eststo fe_x: xtreg $depvar retired $controllist, fe
estadd local sample "FE w. controls", replace

* Instrumental Variables (IV) Regression
* First stage
eststo first: reg retired instrument $controllist
predict retired_hat
estadd local sample "First-stage"

* Second stage
eststo iv: reg $depvar retired_hat $controllist
estadd local sample "IV, alt"

* Combined first and second stage
eststo ivreg: ivregress 2sls $depvar (retired = instrument)
estadd local sample "IV", replace

* IV with controls
eststo ivreg_x: ivregress 2sls $depvar $controllist (retired = instrument)
estadd local sample "IV w. controls", replace

/* -----------------------------------
   EXPORT RESULTS
   ----------------------------------- */

* Output for first stage
esttab first using "output/first_stage.doc", replace noabbrev label keep(instrument age agesq female mar_stat* isced1997_r_* int_year* income) nonumbers scalar("Sample") mlabels(Retirement) nonotes addnotes( ///
    "Notes: N=`=e(N)', t statistics in parentheses" ///
    "* p<0.05, ** p<0.01, *** p<0.001" )

* Output for OLS and FE
esttab ols ols_x fe fe_x using "output/ols_eurod.doc", replace ///
    label noabbrev keep(retired age agesq female mar_stat* isced1997_r_* int_year* income) ///
    nonumbers scalar("Sample") ///
    mlabels("OLS" "OLS w. controls" "FE" "FE w. controls" ) ///
    collabels(none) ///  // Remove "Variable" column header
    nonotes addnotes("Notes: N=`=e(N)', t statistics in parentheses" ///
                     "* p<0.05, ** p<0.01, *** p<0.001")

* Output for IV regressions
esttab iv ivreg_x ivreg using "output/iv_eurod.doc", replace ///
    label keep(retired age agesq female mar_stat* isced1997_r_* int_year* income) ///
    nonumbers noabbrev collabels("eurod") scalar("sample") ///
    nonotes addnotes("Notes: N=`=e(N)', t statistics in parentheses" ///
                     "* p<0.05, ** p<0.01, *** p<0.001")

* Close log file
log close
* Grouping income quartiles
xtile income_group = income, nq(4)
label var income_group "Income Quartile"

* Labeling income quartiles
label define income_group_lbl 1 "Lowest Income (Q1)" 2 "Lower-Middle Income (Q2)" 3 "Upper-Middle Income (Q3)" 4 "Highest Income (Q4)"
label values income_group income_group_lbl

* Analysis country 
levelsof country, local(countries)
foreach country of local countries {
    
	* Descriptives statistics for each country
    tabstat eurod if country == `country', by(income_group) stat(mean sd) format(%9.2f)

    * Regression by country 
    eststo ols_`country': reg eurod i.income_group $controllist if country == `country'
    estadd local sample "OLS w. controls", replace
}

* Descriptives depression level vs education 
tabstat eurod, by(isced1997_r) stat(mean sd) format(%9.2f)

* Regression education level vs depression
eststo edu_ols: reg eurod i.isced1997_r $controllist
estadd local sample "OLS w. controls", replace

* FE depression vs education level
eststo edu_fe: xtreg eurod i.isced1997_r $controllist, fe
estadd local sample "FE w. controls", replace

* Bar graph education level vs depression level
graph bar (mean) eurod, over(isced1997_r, label(labsize(vsmall))) ///
    title("Mean Depression Score by Education Level", size(medium)) ///
    ytitle("Mean Depression Score", size(small)) ///
    blabel(bar, format(%9.2f) size(small)) ///
    ylabel(, labsize(small)) ///
    name(edu_depression, replace)
graph export "output/edu_depression.png", replace

* Drop the existing mean_eurod variable if it exists
capture drop mean_eurod

* Generating variable mean_eurod, mean depression level by countries
bysort country: egen mean_eurod = mean(eurod)

summarize mean_eurod

* Max min level of depression by country
summarize mean_eurod, detail

list country mean_eurod if mean_eurod == r(min) | mean_eurod == r(max), clean

tabulate country, summarize(mean_eurod)

* Generating variable color_group based on quartile income mean_eurod

xtile color_group = mean_eurod, nq(4)
label define color_group_lbl 1 "Low Depression" 2 "Medium-Low Depression" 3 "Medium-High Depression" 4 "High Depression"
label values color_group color_group_lbl

* Bar chart countries mean_eurod depression level

gen low_depression = mean_eurod if color_group == 1
gen medium_low_depression = mean_eurod if color_group == 2
gen medium_high_depression = mean_eurod if color_group == 3
gen high_depression = mean_eurod if color_group == 4
graph hbar (mean) low_depression medium_low_depression medium_high_depression high_depression, ///
    over(country, sort(mean_eurod) descending label(labsize(vsmall))) ///
    title("Mean Depression Score by Country") ///
    ytitle("Mean Depression Score") ///
    blabel(bar, format(%9.2f)) ///
    ylabel(1(0.5)3) ///
    bar(1, color(blue)) ///
    bar(2, color(blue%50)) ///
    bar(3, color(red%50)) ///
    bar(4, color(red)) ///
    legend(label(1 "Low (Blue)") label(2 "Medium-Low (Blue)") label(3 "Medium-High (Red)") label(4 "High (Red)"))
graph export "output/depression_by_country.png", replace

describe mar_stat

* Labeling marital status levels
label define mar_stat_lbl 1 "Married, living with spouse" 2 "Registered partnership" 3 "Married, separated from spouse" 4 "Never married" 5 "Divorced" 6 "Widowed"
label values mar_stat mar_stat_lbl

* Bar graph marital status vs depression level
graph bar (mean) eurod, over(mar_stat, label(labsize(vsmall))) ///
    title("Mean Depression Score by Marital Status", size(medium)) ///
    ytitle("Mean Depression Score", size(small)) ///
    blabel(bar, format(%9.2f) size(small)) ///
    ylabel(, labsize(small)) ///
    bar(1, color(blue)) ///
    name(depression_marital_status, replace)

graph export "output/depression_marital_status.png", replace

* Generating income quartile from highest to lowest
xtile income_quartile = income, nq(4)
label define income_quartile_lbl 1 "Q1 (Lowest)" 2 "Q2" 3 "Q3" 4 "Q4 (Highest)"
label values income_quartile income_quartile_lbl

* Bar chart: Mean values income quartile vs depression
graph bar (mean) eurod, over(income_quartile, label(labsize(vsmall))) ///
    title("Mean Depression Score by Income Quartile", size(medium)) ///
    ytitle("Mean Depression Score (EURO-D)", size(small)) ///
    blabel(bar, format(%9.2f) size(small)) ///
    ylabel(, labsize(small)) ///
    bar(1, color(blue)) ///
    name(depression_income_bar, replace)

graph export "output/depression_income_bar.png", replace

