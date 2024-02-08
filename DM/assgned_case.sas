libname assinm "/home/u63305369/Assignment";

proc printto log= "/home/u63305369/Assignment/dm.log";
run;
***sorting, removing duplicate value and  blank for 
usubjid and country since they are 
required variable and blank value cannot be present;
proc sort data=assinm.dmm nodupkey out=demogs1;
by _all_;
where usubjid ne " " and  country ne " ";;
run;

***generating the total treatment as "E";
data demogs;
set demogs1;
output; 
trtm = "E";
output;
run;

***proc sorting by trtm to be used for the statistics;
proc sort data=demogs out=demog_sorted;
by trtm;
*format country $countryfmt. sex $sexfmt.;
run;

**proc means for Age var;
proc means data=demog_sorted;
by trtm;
var agedrv1n;
*id age;
output out=dm_mean1
n=_n
mean=_mean
std=_std
median=_median
p25=_q1
p75=_q3
min=_min
max=_max;
where agedrv1n ne .;
run;
va
***concat q,q3 and min,max and using put function
 to convert the numeric data to char;
data dm_trt;
length N $20 MEAN $20 SD $20 MEDIAN $20 Q1_Q3 $20 MIN_MAX $20;
set dm_mean1;
N=put(_n, 2.0);
MEAN= put(_mean, 4.1);
SD= put(_std, 4.1);
MEDIAN= put(_median, 4.1);
Q1_Q3= put(_q1, 4.1) || " " || "," || put(_q3,4.1);
MIN_MAX= put(_MIN, 4.1) || " " || "," || put(_MAX,4.1);
run; 

data dm_trt1;
*length N 8 MEAN 8 sd $8 MEDIAN 8 Q1_Q3 $8 MIN_MAX $8;
set dm_trt;
keep trtm N MEAN SD MEDIAN Q1_Q3 MIN_MAX;
*drop_;
run;

**Transposing the column to row;
proc transpose data=dm_trt1 out=dm_trt_trans;
*by trtm;
var n mean sd median q1_q3 min_max;
run;



data dm_trt_age;
set dm_trt_trans(rename=(col1=trt1 col2=trt2 col3=trt3
col4=trt4 col5=total _name_ = Age));
run;


data dm_trt_trans;
length new_val $20;
set dm_trt_age;
if Age = "N" then new_val ="N";
else if age = "MEAN" then new_val = "MEAN";
else if age = "SD" then new_val = "SD";
else if age = "MEDIAN" then new_val = "MEDIAN";
else if age = "Q1_Q3" then new_val = "Q1,Q3";
else if age = "MIN_MAX" then new_val = "MIN, MAX";
run;

data dummy;
length new_val $20;
new_val= "Baseline Age - years";
run;

data agex;
set dummy dm_trt_trans;
*drop age;
ord=4;
run;


***same as in age variable;
proc means data=demog_sorted;
by trtm;
var bsa_1n;
output out=dm_mean_bsa
n=_n
mean=_mean
std=_std
median=_median
p25=_q1
p75=_q3
min=_min
max=_max;
run;

data dm_bsa;
length N $20 MEAN $20 SD $20 MEDIAN $20 Q1_Q3 $20 MIN_MAX $20;
set dm_mean_bsa;
N=put(_n, 2.0);
MEAN= put(_mean, 4.1);
SD= put(_std, 4.1);
MEDIAN= put(_median, 4.1);
Q1_Q3= put(_q1, 4.1) || " " || "," || put(_q3,4.1);
MIN_MAX= put(_MIN, 4.1) || " " || "," || put(_MAX,4.1);
run;

data dm_bsa1;
set dm_bsa;
keep trtm N MEAN SD MEDIAN Q1_Q3 MIN_MAX;
run;

proc transpose data=dm_bsa1 out=dm_bsa_trans;
*by trtm;
var n mean sd median q1_q3 min_max;
run;

data dm_bsa_trans1;
set dm_bsa_trans(rename=(col1=trt1 col2=trt2 col3=trt3 col4=trt4 
col5=total _name_ = bsa));
*label "bsa m" ||("esc"){unicode "2072"x};
run;

data bsa_newval;
length new_val $20;
set dm_bsa_trans1;
if bsa = "N" then new_val ="N";
else if bsa = "MEAN" then new_val = "MEAN";
else if bsa = "SD" then new_val = "SD";
else if bsa = "MEDIAN" then new_val = "MEDIAN";
else if bsa = "Q1_Q3" then new_val = "Q1,Q3";
else if bsa = "MIN_MAX" then new_val = "MIN, MAX";
run;



*****NOTE PLEASE//;
data label1;
length label $20;
label= "Baseline BSA - m**2"; 
run;
data dummy2;
set label1;
if label = "Baseline BSA - m**2" then new_val = "Baseline BSA m"||"^{super2}";
drop label;
option ods escape char="^";
run;

data bsax;
set dummy2 bsa_newval;
ord=6;
run;


****percent and count for region/country;


***proc freq to reflect display the count and percent in the output dataset for the sex variable;
proc freq data=demog_sorted;
by trtm;
table trtm sex/nocum out=sex;
where sex ne " ";
run;

***concat count and percent;
data sex1;
set sex;
count_percent= put(count, 2.0) || "(" || put(percent, 2.0) || ")";
drop percent count;
run;
**transposing**;
proc sort data=sex1; by sex; run;
proc transpose data=sex1 out=sex2;
id trtm;
var count_percent;
by sex;
run;

data sex_rename;
length new_val $20;
set sex2(rename=(A=TRT1 B=TRT2 C=TRT3 D=TRT4 E=TOTAL));
drop _name_;
if sex = "M" then new_val = "Men";
else if sex = "F" then new_val = "Women";
else if sex = "U" then new_val = "Unkown";
run;

data dummy3;
length new_val $20;
new_val = "Sex - n(%)";
run;
 
data sex_dummy3;
set dummy3 sex_rename;
ord=2;
run;

***format to convert "fRA" and "NDL" to Eu and USA to US;
proc format;
value $countryfmt
"FRA" = "EU"
"NLD" = "EU"
"USA" = "US";
run;

proc sort data=demogs out=demog_sorted;
by trtm;
format country $countryfmt.;
run;
***same as in sex;
proc freq data=demog_sorted;
by trtm;
table trtm country/nocum out=country;
run;

data country1;
set country;
count_percent= put(count, 2.0) || "(" || put(percent, 2.0) || ")";
drop percent count;
run;

proc sort data=country1; by country; run;
proc transpose data=country1 out=country2;
id trtm;
var count_percent;
by country;
run;

data country_rename;
length new_val $20;
set country2(rename=(A=TRT1 B=TRT2 C=TRT3 D=TRT4 E=TOTAL));
drop _name_;
if country = "FRA" then new_val = "Europe";
*else if COUNTRY = "NLD" then new_val = "Europe";
else if country = "USA" then new_val = "North America";
run;

data dummy4;
length new_val $20;
new_val = "Region - n(%)";
run;
 
data country_dummy4;
set dummy4 country_rename;
*drop country;
ord=1;
run;


***proc freq for race;
proc freq data=demog_sorted;
by trtm;
table trtm race/nocum out=race;
where race ne " ";
run;

data race1;
set race;
count_percent= put(count, 3.0) || "(" || put(percent, 3.0) || ")";
drop percent count;
run;
  
proc sort data=race1; by descending race; run;
proc transpose data=race1 out=race2;
id trtm;
var count_percent;
by descending race;
run;

***proc freq for ethnic;
proc freq data=demog_sorted;
by trtm;
table trtm ethnic/nocum out=ethnic;
where ethnic ne " ";
run;

data ethnic1;
set ethnic;
count_percent= put(count, 3.0) || "(" || put(percent, 3.0) || ")";
drop percent count;
run;
  
proc sort data=ethnic1; by descending ethnic; run;
proc transpose data=ethnic1 out=ethnic2(rename=(Ethnic=Race));
id trtm;
var count_percent;
by descending ethnic;
run;


*merging the product of race and ethnic using set statement;
data race_ethnic;
set race2 ethnic2;
drop _name_;
run;

data race_ethnic_rename;
length new_val $30;
set race_ethnic(rename=(A=TRT1 B=TRT2 C=TRT3 D=TRT4 E=TOTAL));
if race = "WHITE" then new_val = "White or Caucasian";
else if race = "OTHER" then new_val = "Others";
else if race = "BLACK" then new_val = "Black or African America";
else if race = "HISPANIC OR LATINO" then new_val = "HISPANIC OR LATINO";
else if race = "NOT HISPANIC OR LATINO" then new_val = "NOT HISPANIC OR LATINO";
else if race = "ASIAN" then new_val = "ASIAN";
run;

data dummy5;
length new_val $30;
new_val = "Race/ethnicity - n(%)";
run;
 
data race_dummy5;
set dummy5 race_ethnic_rename;
ord=3;
drop race;
run;


***applying if else condition to categ the data age var as <65 and >=65;
data age_group;
length agedrv1n 8 trtm $1 age_group $20;
   set demog_sorted;
 if agedrv1n < 65 then age_group = "<65";
else if agedrv1n >= 65  then age_group = ">=65";
*else if agedrv1n >=75 then age_group = ">75";
   keep agedrv1n age_group trtm; 
run;

**applying proc freq to the the age_group var; 
proc freq data=age_group;
length age_group 8;
by trtm;
table age_group/nocum out=age_group1;
where age_group ne " ";
run;

**concat count and percent;
data age_grp2;
set age_group1;
count_percent = put(count, 2.0) || "(" || put(percent, 2.0) || ")";
drop count percent;
run;

**sorting and transposing;
proc sort data=age_grp2; by descending age_group; run;
proc transpose data=age_grp2 out=trans_agegroup;
id trtm;
var count_percent;
by descending age_group;
run;

***applying if else statement to get age_groupx as <75 and >=75;
data age_groupx;
length agedrv1n 8 trtm $1 age_group $20;
set demog_sorted;
if agedrv1n < 75 then age_group = "<75";
else if agedrv1n >= 75  then age_group = ">=75";
*else if agedrv1n >=75 then age_group = ">75";
keep agedrv1n age_group trtm; 
run;


****same as age_group;
proc freq data=age_groupx;
length age_group 8;
by trtm;
table age_group/nocum out=age_groupx1;
where age_group ne " ";
run;

data age_grpx2;
set age_groupx1;
count_percent = put(count, 2.0) || "(" || put(percent, 2.0) || ")";
drop count percent;
run;

proc sort data=age_grpx2; by descending age_group; run;
proc transpose data=age_grpx2 out=trans_agegroupx;
id trtm;
var count_percent;
by descending age_group;
run;

***verticallly merging the product of age_group and age_groupx;
data age;
set trans_agegroup trans_agegroupx;
drop new_val;
run;

data agegroup_renamex;
length new_val $30;
set age(rename=(A=TRT1 B=TRT2 C=TRT3 D=TRT4 E=TOTAL));
if age_group= "<65" then new_val = "<65";
else if age_group= ">=65" then new_val = ">=65";
else if age_group= ">=75" then new_val = ">=75";
else if age_group= "<75" then new_val = "<75";
drop _name_ age_group;
run;


data dummy6;
length new_val $30;
new_val="Baseline age group - n(%)";
*ord=5;
run;


data agegrp_dummy6;
set dummy6 agegroup_renamex;
ord=5;
run;


***vertically merging all the product of proc freqs and proc means;    
data dm_dataset;
length new_val $30 TRT1 $10 TRT2 $10 TRT3 $10 TRT4 $10 TOTAL $10;
set country_dummy4 sex_dummy3 race_dummy5 
agex agegrp_dummy6 bsax;
drop age_group;
run;

***generating a report;
ods listing close;
ods rtf file= "/home/u63305369/Assignment/dm.rtf";
option ods escape char="^";
proc report data=dm_dataset headskip nowd headline split='^' missing contents=""
style(report)={cellpadding=1pt cellspacing=0pt just=c frame=above asis=on rules=groups}
style(header)={font=('Courier New',9pt,normal) just=C asis=Off background=white fontweight=bold borderbottomwidth=2 bordertopwidth=2}
style(column)={font=('Courier New',9pt,normal) asis=on}
style(lines) ={font=('Courier New',9pt,normal) asis=on} ;

title1 "Safety Domain Assessment (Descriptive)";
title2 "Assessment ID: CDALEAP_2999.02A"; 
title3 "Domain: Demography (DM)";
column ord new_val TRT1 TRT2 TRT3 TRT4 TOTAL;
define ord/order noprint;
break after ord/skip;
define new_val/"description" style={just=l asis=on cellwidth=34.5%} flow width=10 display;
define TRT1/ style={just=c asis=on cellwidth=11%} flow ;
define TRT2/ style={just=c asis=on cellwidth=11%} flow ;
define TRT3/ style={just=c asis=on cellwidth=11%} flow ;
define TRT4/ style={just=c asis=on cellwidth=11%} flow ;
define TOTAL/ style={just=c asis=on cellwidth=11%} flow ;
RUN; 
ods listing;
ods rtf close;
*ods  html close;
proc printto;
run;