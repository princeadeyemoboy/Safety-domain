libname assinm "/home/u63305369/Assignment";


proc printto log= "/home/u63305369/Assignment/dm.log";
run;
/***sorting, removing duplicate value and  blank for 
usubjid and country since they are 
required variable and blank value cannot be present;*/
proc sort data=assinm.dmm nodupkey out=demogs1;
by _all_;
where usubjid ne " " and  country ne " ";
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
format country $countryfmt.;
run;

*create format for country;
proc format;
value $countryfmt
"FRA" = "EU"
"NLD" = "EU"
"USA" = "US";
run;

**proc means for Age var;
%macro dm(var=, label=, ord=);
proc means data=demog_sorted;
by trtm;
var &var.;
*id age;
output out=&var._mean
n=_n
mean=_mean
std=_std
median=_median
p25=_q1
p75=_q3
min=_min
max=_max;
*where &var ne .;
run;

***concat q,q3 and min,max and using put function
 to convert the numeric data to char;
data &var._mean1;
length N $20 MEAN $20 SD $20 MEDIAN $20 Q1_Q3 $20 MIN_MAX $20;
set &var._mean;
N=put(_n, 2.0);
MEAN= put(_mean, 4.1);
SD= put(_std, 4.1);
MEDIAN= put(_median, 4.1);
Q1_Q3= put(_q1, 4.1) || " " || "," || put(_q3,4.1);
MIN_MAX= put(_MIN, 4.1) || " " || "," || put(_MAX,4.1);
run; 

data &var._mean2;
*length N 8 MEAN 8 sd $8 MEDIAN 8 Q1_Q3 $8 MIN_MAX $8;
set &var._mean1;
keep trtm N MEAN SD MEDIAN Q1_Q3 MIN_MAX;
*drop_;
run;

**Transposing the column to row;
proc transpose data=&var._mean2 out=&var._mean3;
*by trtm;
var n mean sd median q1_q3 min_max;
run;

**rename col1:col5 to their respectives trts;
data &var._mean4;
set &var._mean3(rename=(col1=trt1 col2=trt2 col3=trt3
col4=trt4 col5=total _name_ = Age));
run;

***create a new column called new_val;
data &var._mean5;
length new_val $20;
set &var._mean4;
if Age = "N" then new_val ="N";
else if age = "MEAN" then new_val = "MEAN";
else if age = "SD" then new_val = "SD";
else if age = "MEDIAN" then new_val = "MEDIAN";
else if age = "Q1_Q3" then new_val = "Q1,Q3";
else if age = "MIN_MAX" then new_val = "MIN, MAX";
run;

data &var._dummy;
length new_val $30;
new_val= &label;
run;

data &var._x;
set &var._dummy &var._mean5;
*drop age;
ord= &ord;
run;
%mend;

**age in years;
**age in years;
%dm(var=agedrv1n, label="Baseline age -years", ord=4);
**BSA_IN;
%dm(var=BSA_1N, label="Baseline BSA m(*ESC*){super 2}", ord=6);

****percent and count for region/country;
***proc freq to reflect display the count and percent in the output dataset for the sex variable;
%macro dmfreq(tab=, ord=, label=);
proc freq data=demog_sorted;
by trtm;
table trtm &tab./nocum out=&tab._freq;
where &tab. ne " ";
run;

***concat count and percent;
data &tab._freq1;
set &tab._freq;
count_percent= put(count, 2.0) || "(" || put(percent, 2.0) || ")";
drop percent count;
run;
**transposing**;
proc sort data=&tab._freq1; by &tab.; run;
proc transpose data=&tab._freq1 out=&tab._freq2;
id trtm;
var count_percent;
by &tab.;
run;

data &tab._rename;
length new_val $20;
set &tab._freq2(rename=(A=TRT1 B=TRT2 C=TRT3 D=TRT4 E=TOTAL));
drop _name_;
new_val = " "; 
run;

data &tab._dummy;
length new_val $20;
new_val = &label;
run;
 
data &tab._dummy3;
set &tab._dummy &tab._rename;
ord=&ord;
run;
%mend;

***Sex;
%dmfreq(tab=sex, ord=2, label="Sex - n(%)");
data sex;
set sex_dummy3;
if sex = "M" then new_val = "Men";
else if sex = "F" then new_val = "Women";
else if sex = "U" then new_val = "Unkown";
if new_val ne " " then do;
TRT3 = compress(TRT3);
TOTAL = compress(TOTAL);
end;
run;

***country;
%dmfreq(tab=country, ord=1, label="Region - n(%)");
data country;
set country_dummy3;
if country = "FRA" then new_val = "Europe";
*else if COUNTRY = "NLD" then new_val = "Europe";
else if country = "USA" then new_val = "North America";
run;

%macro RE(tab=);
proc freq data=demog_sorted;
by trtm;
table trtm &tab./nocum out=&tab.;
where race ne " ";
run;

data &tab._1;
set &tab.;
count_percent= put(count, 3.0) || "(" || put(percent, 3.0) || ")";
drop percent count;
run;
  
proc sort data=&tab._1; by descending &tab.; run;
proc transpose data=&tab._1 out=&tab._2;
id trtm;
var count_percent;
by descending &tab.;
run;
%mend;

%RE(tab=race);
%RE(tab=ethnic);

*merging the product of race and ethnic using set statement 
and removing the extra blanks in variables D, E, C;
data race_ethnic;
set Race_2 Ethnic_2(rename=(Ethnic=Race));
if race ne " " then do;
D = compress(D);
E = compress(E);
C = compress(C);
end;
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

*create age_group for <65 and >=65;
data age_group;
length agedrv1n 8 trtm $1 age_group $20;
   set demog_sorted;
 if agedrv1n < 65 then age_group = "<65";
else if agedrv1n >= 65  then age_group = ">=65";
   keep agedrv1n age_group trtm; 
run;

data age_groupx;
length agedrv1n 8 trtm $1 age_group $20;
set demog_sorted;
if agedrv1n < 75 then age_group = "<75";
else if agedrv1n >= 75  then age_group = ">=75";
*else if agedrv1n >=75 then age_group = ">75";
keep agedrv1n age_group trtm; 
run;

*macro for the two age_gp;
%macro agegp(dsn=);
**applying proc freq to the the age_group var; 
proc freq data=&dsn.;
length age_group 8;
by trtm;
table age_group/nocum out=&dsn._1;
where age_group ne " ";
run;

**concat count and percent;
data &dsn._2;
set &dsn._1;
count_percent = put(count, 2.0) || "(" || put(percent, 2.0) || ")";
drop count percent;
run;

**sorting and transposing;
proc sort data=&dsn._2; by descending age_group; run;
proc transpose data=&dsn._2 out=&dsn._3;
id trtm;
var count_percent;
by descending age_group;
run;
%mend;

***calling the macros for the two age group;
%agegp(dsn=age_group);

%agegp(dsn=age_groupx);

***verticallly merging the product of age_group and age_groupx;
data age;
set age_group_3 age_groupx_3;
*drop new_val;
run;

data agegroup_renamex;
length new_val $20;
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
ord=5;
run;

data agegrp_dummy6;
set dummy6 agegroup_renamex;
ord=5;
run;
  
***vertically merging all the product of proc freqs and proc means;    
data dm_dataset;
length new_val $30 TRT1 $20 TRT2 $20 TRT3 $20 TRT4 $20 TOTAL $20;
set country sex race_dummy5 
agedrv1n_x agegrp_dummy6 BSA_1N_x;
drop age sex country;
run;

***generating the report;
ods listing close;
ods rtf file= "/home/u63305369/Assignment/dm.rtf";
*option ods escape char="^";
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
