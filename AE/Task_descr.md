## Tasks:

1. **Impute the AE Start date and End Date following the Guidelines/Rules mentioned below.**

   - **Adverse Event Date Imputation Rule:**
     - Adverse Event Start Date:
       - It is equal to `AESTDTC` when is completed, otherwise, the following imputation rules are applied if the adverse events are not "ongoing."
         1. If the start year is missing:
            - If Stop Date is on or after First Dose Date, missing, or "ongoing," use First Dose Date.
            - Otherwise, use January 1 of the stop year.
         2. If the start month is missing:
            - If the start year is the same as the first dose year and Stop Date is on or after First Dose Date, missing, or "ongoing," use First Dose Date.
            - Otherwise, use January 1 of the start year.
         3. If the start day is missing:
            - If the start year and month are the same as the first dose year and month and Stop Date is on or after First Dose Date, missing, or "ongoing," use First Dose Date.
            - Otherwise, use the first day of the month of the start year.

       - Adverse Event End Date:
         - It is equal to `AEENDTC` when is completed, otherwise, the following imputation rules are applied if the adverse events are not "ongoing."
            1. If the stop year is missing, use missing value "." and assume the adverse experience is "ongoing."
            2. If the stop month is missing, use December 31 of the stop year.
            3. If the stop day is missing, use the last day of the month of the stop year.

2. **Derive the Treatment Emergent Flag using the Imputed dates. The TEAE is defined below.**

   - **Treatment Emergent Adverse Event (TEAE):**
     - Treatment Emergent AE can be defined as an event that occurred after treatment. If treatment (reference) start date and AE start date are similar, then the event will be considered as TEAE.

---------------------------------------------------*********----------------------------------------------------
