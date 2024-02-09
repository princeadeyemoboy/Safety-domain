proc printto log= "/home/u63305369/Assignment/vital.log";
libname assinm "/home/u63305369/Assignment";

data vital_sign;
set assinm.vsraw;
***generating the visit date in iso8061 format;
  vs_datey= input(vs_date, yymmdd8.);
  vs_datey1 =put(vs_datey, yymmdd10.); 
  timey = substr(time, 1, 2);
  timez = substr(time, 3, 2);
  timexy = catx(":", timey, timez);
  *BP = put(systolic, 3.0) || "/" || put(diastolic, 2.0);
  *temperature=temperaturey;
  vsdate_time= catx("T", vs_datey1, timexy);
  drop timey timez timexy vs_datey1 vs_datey;
run;

***sorting by the variable whic will intend to remain as column**;
proc sort data=vital_sign out=vital_sign1;
  by patient visit timepoint vsdate_time;
run;


***transposing systolic tempetc in var statement to rows; 
proc transpose data=vital_sign1 out=trans_vit(rename=(patient=USUBJID
 _name_=VSTEST col1=VSORRES));
  by patient visit timepoint vsdate_time temp_unit;
  var systolic diastolic respiratory_rate heart_rate temperature;
run;

data vs1;
set trans_vit;
**assign vsorres to vsstres;
VSSTRESC = VSORRES;

***converting Farenheit to celsius in vsstres 
using if else do statement;
if VSSTRESC in ("98", "96", "98.4", "98.2", "99.6", "99.4" ) then do;
  VSSTRESC= (VSSTRESC-32)*5/9;
  end;
else do;
 VSSTRESC=VSSTRESC;
 end;

***generating vsorresu and vsstresn using if else do
 statement for each test temp, systolic etc;
if vstest in("Systolic", "Diastolic") then do;
  VSORRESU = "mmHg";
  VSSTRESU ="mmHg";
end;


else if vstest = "Respiratory_Rate" then do;
  VSORRESU = "br/min";
  VSSTRESU ="br/min";
end; 

else if vstest = "Heart_Rate" then do;
  VSORRESU = "bpm";
  VSSTRESU ="bpm";
end;

else if VSORRES in("98", "96", "98.4", "98.2", "99.6", "99.4") then do;
  VSORRESU = "°F";
  *VSSTRESU= "°C";  
end;
else do;
  VSORRESU = "°C";
end;

if VSSTRESC in("36.9","36.6", "36.4", "36.7", "36.67", "35.56", 
"36.89", "36.78", "37.44", "37.56") then do;
  VSSTRESU= "°C";
end;
drop temp_unit _label_;
run;



***converting char data to numeric and using if_else condition to apply
 diff format to  VSSTRESC to form  VSSTRESN ***;
data vs2x;
set vs1;
  if VSSTRESC in("36.6", "36.9", "36.4", "36.7") then 
  VSSTRESN = input(put(VSSTRESC,4.1), best12.);
  else if VSSTRESC in ("36.67", 
  "36.89", "36.78", "37.44", "37.56") then 
  VSSTRESN = input(put(VSSTRESC,5.2), best12.);
  else VSSTRESN = input(put(VSSTRESC,3.0), best12.);
run;


 

***sorting***;
proc sort 
data=vs2x out=vs4;
 by usubjid vstest visit VSSTRESU VSORRESU; 
 run;

*Average for each test findings with proc means nd by statement;
proc means data=vs4 mean noprint;
  by usubjid vstest visit VSSTRESU VSORRESU;
  var VSSTRESN;
  output out=vs5 mean=VSSTRESN;
run;

data vs6;
set vs5;
if visit = "Screening" then visit = "Baseline";
run;

*manipulating and renaming and merging vertically with the previous records*;
data vital(rename=(timepoint= EPOCH visit=VISIT1 vsdate_time=VSDTC));;
set vs2x vs6; 
run;

proc sort data=vital out=vital1; by usubjid vstest; run;

***Calculating vseq to create uniqueness and creating the derived flag;;
data vital2(rename=(VISIT1=VISIT));
retain USUBJID VISIT1 EPOCH VSDTC VSTEST VSORRES VSORRESU VSSTRESC VSSTRESN VSSTRESU;
set vital1(drop= _TYPE_ _FREQ_ );
  by usubjid vstest;
  if first.usubjid then VSSEQ =.;
  VSSEQ+1;
  if visit1 = "Baseline" then VSDRVFL = "Y";
  if visit1 = "Baseline" then VSBLFL = "Y"; 
  if usubjid ne " " then Domain = "VS";
run;



****exporting vital_sign to an external location;
proc copy in=work out=assinm; 
select vital2; 
run;
proc printto;
run;