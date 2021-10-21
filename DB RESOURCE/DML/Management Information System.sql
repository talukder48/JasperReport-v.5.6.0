-----------------SANCTION AND DISBURSEMENT-------------------------
SELECT

 case g.zero_eq_sanction
   when 0 then
    0
   else
    d.zero_eq_sanction_amt / g.zero_eq_sanction * 100
 end zero_eq_sanction_pct,
 
 case g.oths_pd_sanction
   when 0 then
    0
   else
    d.oth_prd_sanction_amt / g.oths_pd_sanction * 100
 end oth_prd_sanction_pct ,
 
 case g.zero_eq_disburse
   when 0 then
    0
   else
    d.zero_eq_disburse_amt / g.zero_eq_disburse * 100
 end zero_eq_disburse_pct,
 
 case g.oths_pd_disburse
   when 0 then
    0
   else
    d.oth_prd_disburse_amt / g.oths_pd_disburse * 100
 end oth_prd_disburse_pct
 
 
  FROM mis_goal_setup g
  join

 (SELECT branch_code,
         sum(d.zero_eq_sanction_amt) zero_eq_sanction_amt,
         sum(d.oth_prd_sanction_amt) oth_prd_sanction_amt,
         sum(d.zero_eq_disburse_amt) zero_eq_disburse_amt,
         sum(d.oth_prd_disburse_amt) oth_prd_disburse_amt
    FROM mis_loan_sanction_disburse d
   where d.entry_date between '01-jul-2020' and '31-may-2021'
   group by d.branch_code) d
    on (d.branch_code = g.branch_code)
 where g.target_code = 'FY20-21'
------------------------------RECOVERY---------------------------------------------
SELECT
  g.branch_code,
  (SELECT m.brn_name FROM prms_mbranch m where m.brn_code=g.branch_code)Branch_name,
 g.loan_uc_recovery,
 g.loan_cl_recovery,
 
 case g.loan_uc_recovery
   when 0 then
    0
   else
    d.uc_recovery_amt / g.loan_uc_recovery * 100
 end loan_uc_recovery_pct,
 
 case g.loan_cl_recovery
   when 0 then
    0
   else
    d.cl_recovery_amt / g.loan_cl_recovery * 100
 end loan_cl_recovery_pct 
 
  FROM mis_goal_setup g
  join

 (SELECT branch_code,
         sum(d.cl_recovery_amt) cl_recovery_amt,
         sum(d.uc_recovery_amt) uc_recovery_amt
        
    FROM mis_loan_recovery d
   where d.entry_date between '01-jul-2020' and '31-may-2021'
   group by d.branch_code) d
    on (d.branch_code = g.branch_code)
 where g.target_code = 'FY20-21'
-------------------------------COURT CASE------------------------------

SELECT g.branch_code,
       (SELECT m.brn_name
          FROM prms_mbranch m
         where m.brn_code = g.branch_code) branch,
       g.settle_writ_case,
       g.settle_executive_case,
       (SELECT sum(d.misc_cse) misc_cse
          FROM mis_court_case_settle d
         where d.branch_code = g.branch_code
           and d.entry_date between '01-jul-2020' and '31-may-2021') misc_achievement,
       (SELECT sum(d.executive_case) executive_case
          FROM mis_court_case_settle d
         where d.branch_code = g.branch_code
           and d.entry_date between '01-jul-2020' and '31-may-2021') exee_achievment
  FROM mis_goal_setup g
 where g.target_code = 'FY20-21'
 -------------------------DEED RETURN------------------------------------------
 
 SELECT g.branch_code,
       (SELECT m.brn_name
          FROM prms_mbranch m
         where m.brn_code = g.branch_code) branch,
       g.deed_return_fl,
       (SELECT sum(d.loan_account_no) loan_account_no
          FROM MIS_FAULTY_LN_CASE d
         where d.branch_code = g.branch_code
           and d.entry_date between '01-jul-2020' and '31-may-2021') DEED_RETURN_ACHIVEMENT
          
  FROM mis_goal_setup g
 where g.target_code = 'FY20-21'
 --------------------------KHARIDABARI--------------------------------------
 
 SELECT g.branch_code,
       (SELECT m.brn_name
          FROM prms_mbranch m
         where m.brn_code = g.branch_code) branch,
       g.Kharidabari_Procession,
       G.KHARIDABARI_SALE,
       (SELECT sum(d.procession) procession
          FROM MIS_KHARIDABARI d
         where d.branch_code = g.branch_code
           and d.entry_date between '01-jul-2020' and '31-may-2021') procession_ACHIEVMENT,
           
           (SELECT sum(d.Sale) Sale
          FROM MIS_KHARIDABARI d
         where d.branch_code = g.branch_code
           and d.entry_date between '01-jul-2020' and '31-may-2021') Sale_ACHIEVMENT       
  FROM mis_goal_setup g
 where g.target_code = 'FY20-21' FOR UPDATE 
---------------------------AUDIT-------------------------------

SELECT g.branch_code,
       (SELECT m.brn_name
          FROM prms_mbranch m
         where m.brn_code = g.branch_code) branch,
       g.audit_commercial,
       G.AUDIT_POST_AUDIT,
       (SELECT sum(d.commercial_obj) 
          FROM MIS_AUDIT_OB_DISPOSAL d
         where d.branch_code = g.branch_code
           and d.entry_date between '01-jul-2020' and '31-may-2021') commercial_ACHIEVMENT,          
           (SELECT sum(d.audit_obj) 
          FROM MIS_AUDIT_OB_DISPOSAL d
         where d.branch_code = g.branch_code
           and d.entry_date between '01-jul-2020' and '31-may-2021') POST_ACHIEVMENT       
  FROM mis_goal_setup g
 where g.target_code = 'FY20-21' FOR UPDATE 

-----------------------------------------------------
 SELECT ZONAL_OFFICE,
       TARGET_DESCRIPTION,
       ZONAL_OFFICE_NAME,
       SUM(TARGET_LOAN_SANC) TARGET_LOAN_SANC,
       SUM(ACHIVE_LOAN_SANC) ACHIVE_LOAN_SANC,
       SUM(TARGET_LOAN_DISB) TARGET_LOAN_DISB,
       SUM(ACHIVE_LOAN_DISB) ACHIVE_LOAN_DISB,
       SUM(TARGET_UC) TARGET_UC,
       SUM(UC_RECOVERY) UC_RECOVERY,
       SUM(TARGET_CL) TARGET_CL,
       SUM(CL_RECOVERY) CL_RECOVERY,
       SUM(TARGET_POSSESION) TARGET_POSSESION,
       SUM(ACHIVE_POSSESION) ACHIVE_POSSESION,
       SUM(TARGET_SALE) TARGET_SALE,
       SUM(ACHIVE_SALE) ACHIVE_SALE,
       SUM(TARGET_COMMERTIAL) TARGET_COMMERTIAL,
       SUM(ACHIVE_COMMERTIAL) ACHIVE_COMMERTIAL,
       SUM(TARGET_POST_AUDIT) TARGET_POST_AUDIT,
       SUM(ACHIVE_POST_AUDIT) ACHIVE_POST_AUDIT,
       SUM(TARGET_MISC) TARGET_MISC,
       SUM(ACHIVE_MISC) ACHIVE_MISC,
       SUM(TARGET_EXECUTION) TARGET_EXECUTION,
       SUM(ACHIVE_EXECUTION) ACHIVE_EXECUTION,
       SUM(TARGET_DEEDRETURN) TARGET_DEEDRETURN,
       SUM(ACHIVE_DEEDRETURN) ACHIVE_DEEDRETURN
  FROM table(pkg_mis_rpt_ho.fn_get_LOAN_data('FY20-21')) NATURAL
  JOIN table(pkg_mis_rpt_ho.fn_get_recovery_data('FY20-21')) NATURAL
  JOIN table(pkg_mis_rpt_ho.fn_get_kharidabari_data('FY20-21')) NATURAL
  JOIN table(pkg_mis_rpt_ho.fn_get_AUDIT_data('FY20-21')) NATURAL
  JOIN table(pkg_mis_rpt_ho.fn_get_courtcase_data('FY20-21')) NATURAL
  JOIN table(pkg_mis_rpt_ho.fn_get_deedreturn_data('FY20-21'))
 GROUP BY ZONAL_OFFICE, ZONAL_OFFICE_NAME, TARGET_DESCRIPTION
 ORDER BY ZONAL_OFFICE;



