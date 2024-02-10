libname aevent  "/home/u63305369/Assignment";

data Ae1;
  set aevent.ae_report; 
  ***generating end day, month and year of aeendtc;
  E_Year= input(substr(AEENDTC, 1,4), best8.);
  E_Month= input(substr(AEENDTC, 6,2), best8.);
  E_day = input(substr(AEENDTC,9,2), best8.);
  
  
 ***generating end day, month and year of aesdtc;
  S_Year= input(substr(AESTDTC, 1,4), best8.);
  S_Month= input(substr(AESTDTC, 6,2), best8.);
  S_day = input(substr(AESTDTC,9,2), best8.);
  
***generating end day, month and year of RFSTDTC;
  R_Year= input(substr(RFSTDTC, 1,4), best8.);
  R_Month= input(substr(RFSTDTC, 6,2), best8.);
  R_day = input(substr(RFSTDTC,9,2), best8.);
 
  RUN;
  
  
data aesd;
  set ae1;
  
  ***if year is missing AESTDTC;
  if s_day=. and s_month=. and s_year=. then do;
  if AEENDTC>=RFSTDTC or AEENDTC in(" ", "ONGOING") then do;
   s_day=r_day;
   s_month = r_month;
   s_year= r_year;
  end;
  else do;
   s_day=1;
   s_month = 1;
   s_year= e_year;
  end;
  Astdtf = "Y";
  end;
  
  ***if month is missing AESTDTC;
  if s_day and s_month = . then do;
  if s_year=r_year and (AEENDTC >= RFSTDTC or AEENDTC 
  in (" ",  "ONGOING")) then do;
   s_day=r_day;
   s_month=r_month;
  end;
  else do;
   s_day=1 ;
   s_month=1;
  end;
  Astdtf = "M";
  end;

    ****if day is missing AESTDTC;
  if S_day= . then do;
  if R_month = S_Month and R_year = S_year and 
  (AEENDTC>= RFSTDTC or  AEENDTC in (" ", "ONGOING")) 
  then s_day= R_day; * myd(R_day, E_month, E_year);
  else s_day= 01;
  Astdtf= "D";
  end;

  ***if year is missing AEENDTC;
  if e_day=. and e_month=. and e_year=. then do;
	e_day=.;
	e_month = .;
	e_year= .;
	Aendtf= "Y";
  end;

  run;
  ***if month is missing AEENDTC;
  
  data m_smonth;
  set aesd;
  if e_day and e_month = . then do;
    e_day=31;
    e_month=12;
    Aendtf= "M";
  end;
 
  ****if day is missing AEENDTC, considering if month ends
  in 31, 30, 28 or 29(in the case of leapyear);
  
  if e_day= . and e_year ne . then do;
  if e_month in(4,6,9,11) then e_day=30;
  else if e_month in(1,3,5,7,8,10,12) then e_day=31;
  else if e_month = 2 and mod(e_year,4)=0 then e_day= 29;
  else if e_month = 2 then e_day=28;
  Aendtf= "D";
  end;
run;

**Analysis Start date and Analysis End date;
data report;
  set m_smonth;
  if e_year ne . then do;
  Astdt= mdy(s_month, s_day, s_year);
  Aendt = mdy(e_month, e_day, e_year);
  end;
  format Aendt yymmdd10. Astdt yymmdd10.;
run;

data final_report;
  retain usubjid rfstdtc AESTDTC Astdt AEENDTC Aendt;
  set report;
  by usubjid;
  drop r_day r_month r_year e_day e_year 
  e_month s_year s_month s_day;
  
  *derive the Treatment Emergent Adverse Event Flag;
  
  if AESTDTC >= rfstdtc then TEAEF = "Y";
  If first.usubjid then Aeseq = .;
  Aeseq+1;
  label Aendt = "Analysis end date" 
  Astdt = "Analysis start date" 
  TEAEF = "Treatment emergent adverse event flag"
   Astdtf = "Analysis start date inputation flag"
   Aendtf = "Analysis end date inputation flag";
run;


****note to work on aesd;
proc copy in=work out=aevent; 
select final_report; 
run;


**for the second dataset;
data Ae1B;
  set aevent.adae; 
  ***generating end day, month and year of aeendtc;
  E_Year=  substr(AEENDTC, 1,4);
  E_Month= substr(AEENDTC, 6,2);
  E_day = substr(AEENDTC,9,2);
  *end;

  
 ***generating end day, month and year of aesdtc;
  S_Year= substr(AESTDTC, 1,4);
  S_Month= substr(AESTDTC, 6,2);
  S_day = substr(AESTDTC,9,2);
  
***generating end day, month and year of RFSTDTC;
  R_Year= substr(RFSTDTC, 1,4);
  R_Month= substr(RFSTDTC, 6,2);
  R_day = substr(RFSTDTC,9,2);
 * end;
  RUN;
  
  
data AESD2;
  set ae1B;
  ***if year is missing AESTDTC;
  if s_day=" " and s_month= " " and s_year= " " then do;
  if AEENDTC>=RFSTDTC or AEENDTC in(" ", "ONGOING") then do;
   s_day=r_day;
   s_month = r_month;
   s_year= r_year;
  end;
  else do;
   s_day="01";
   s_month = "01";
   s_year= e_year;
  end;
  Astdtf = "Y";
  end;
  
  ***if month is missing AESTDTC;
  if s_day = " " and s_month = " " then do;
  if s_year=r_year and (AEENDTC >= RFSTDTC or AEENDTC 
  in (" ",  "ONGOING")) then do;
   s_day=r_day;
   s_month=r_month;
  end;
  else do;
   s_day="01";
   s_month="01";
  end;
  Astdtf = "M";
  end;

    ****if day is missing AESTDTC;
  if S_day= " " then do;
  if R_month = S_Month and R_year = S_year and 
  (AEENDTC>= RFSTDTC or  AEENDTC in (" ", "ONGOING")) 
  then s_day= R_day;
  else s_day= "01";
  Astdtf= "D";
  end;


  ***if year is missing AEENDTC;
  if e_day= "" and e_month= " " and e_year=" " then do;
	e_day=" ";
	e_month = " ";
	e_year= " ";
	Aendtf= "Y";
  end;
  run;

  ***if month is missing AEENDTC;
  
  data m_smonth2;
  set aesd2;
  if e_day = " " and e_month = " " then do;
    e_day="31";
    e_month="12";
    Aendtf= "M";
    *drop AEENDTC; 
  end;
 
  ****if day is missing AEENDTC, considering if month ends
  in 31, 30, 28 or 29(in the case of leapyear);
  *create a temp var by converting e_year to numeric to be able to create a condition for leap years;
  e_year_leap = input(e_year, 4.);
  if e_day= " " then do;
  if e_month in("04","06","11","09") then e_day="30";
 else if e_month in("01","03","05","07","08","10","12") then e_day="31";
  else if e_month = "02" and (mod(e_year_leap,04)=0) then e_day= "29";
  else if e_month = "02" then e_day="28";
  Aendtf= "D";
  end;
run;


data adae_report;
length AEENDTC AESTDTC $10;;
  set m_smonth2;
   AESTDTC= catx("-", s_year, s_month, s_day);
 AEENDTC= catx("-", e_year, e_month, e_day);
run;

data final_adae_report;
  retain usubjid rfstdtc AESTDTC Astdt AEENDTC Aendt;
  set adae_report;
  by usubjid;
  drop r_day r_month r_year e_day e_year 
  e_month s_year s_month s_day e_year_leap;
  if AESTDTC >= rfstdtc then TEAEF = "Y";
  If first.usubjid then Aeseq = .;
  Aeseq+1;
  label Aendt = "Analysis end date" 
  Astdt = "Analysis start date" 
  TEAEF = "Treatment emergent adverse event flag"
   Astdtf = "Analysis start date inputation flag"
   Aendtf = "Analysis end date inputation flag";
run;


proc copy in=work out=aevent; 
select final_adae_report; 
run;
proc printto;
run;