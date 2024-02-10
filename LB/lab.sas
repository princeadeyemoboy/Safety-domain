proc printto log= "/home/u63305369/Assignment/lb-final.log";
libname myw "/home/u63305369/Assignment";


proc sort data=myw.lb out=lb1;
by usubjid paramcd visitnum; 
run;

**one or more records per Usubjid and paramcd;
proc sql;
create table temp_data1 as
select distinct usubjid, paramcd
from lb1;
quit;

**use do loop to create avisit1-9;
data temp_data2;
  set temp_data1;
  length avisit $50;
  do visitnum = 1 to 9;
     avisit = "VISIT-" || strip(put(visitnum, best.));
     output;
  end;
run;

**sort the resulting data by usubjid paramcd visitnum;
proc sort data=temp_data2;
by usubjid paramcd visitnum;
run;
  


*merge temp_data2 to lb2 and create dtype to indicate that derived missing visit;
data lb_perm;
merge temp_data2(in=a) lb1(in=b);
by usubjid paramcd visitnum;
if a and not b then dtype="LOCF";
drop visitnum;
run; 



*use retain statement for locf for; 
data lb_data1(drop= base1 avalu1 chg1 aval1 pchg1);
retain  base1 chg1 aval1 avalu1 pchg1;
set lb_perm;
if base ne . then base1=base;
else base=base1;
if chg ne . then chg1=chg;
else chg=chg1;
if avalu ne " " then avalu1=avalu;
else avalu=avalu1;
if aval ne . then aval1=aval;
else aval=aval1;
if pchg ne . then pchg1=pchg;
else pchg=pchg1;
run; 


***derive the lbseq for unique records for the final dataset;
data myw.lb_final;
set lb_data1;
by usubjid;
if first.usubjid then lbseq=.;
lbseq+1;
run;

proc printto;
run;




