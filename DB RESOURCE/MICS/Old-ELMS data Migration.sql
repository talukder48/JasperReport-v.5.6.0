-------------------------Disburse Data---------------------------------------------------
select 1 entity, c.acc_no,'HBL', '1',c.draw_dt,c.sanc_amt,5.00 Int_rate,c.repay_dt,c.sanc_amt,'MIG',trunc(sysdate),c.fin_year
from hbadv_cl1  c;

select 1 entity, c.acc_no,'COM', '1',c.draw_dt,c.sanc_amt,5.00 Int_rate,c.repay_dt,c.sanc_amt,'MIG',trunc(sysdate),c.fin_year
from   computer_hbadv_cl1 c;

select 1 entity, c.acc_no,'MOT', '1',c.draw_dt,c.sanc_amt,5.00 Int_rate,c.repay_dt,c.sanc_amt,'MIG',trunc(sysdate),c.fin_year
from   motor_hbadv_cl1 c;

select *from innovation.elms_disburse d where d.loan_type='HBL' for update

************************************************************************************************************************
----------------------------loan realization data---------------------------------------

---------------------------------hbl----------------------------------------------------
    select 1 entity,
       d.acc_no emp_id,
       'HBL' type,      
       decode(d.month_code, '7','2018','8', '2018','9','2018','10','2018','11','2018','12','2018','2019') year,             
       d.month_code,
       1 sl,
       d.salary_date real_date,
       'M' real_type,
       'C' dr_cr_type,
       'N' vou_type,
       d.dedu_amount,
       'MIG',
       trunc(sysdate)   
  from  hb_mon_ded d 
  -----------------------------------motor-----------------------------------------------
  
    select 1 entity,
       d.acc_no emp_id,
       'MOT' type,      
       decode(d.month_code, '7','2018','8', '2018','9','2018','10','2018','11','2018','12','2018','2019') year,             
       d.month_code,
       1 sl,
       d.salary_date real_date,
       'M' real_type,
       'C' dr_cr_type,
       'N' vou_type,
       d.dedu_amount,
       'MIG',
       trunc(sysdate)   
  from  motor_hb_mon_ded d 
  where month_code  in('1','2','3','4','5','6','7','8','9','10','11','12')
  -----------------------------------COmputer-----------------------------------------------
  
    select 1 entity,
       d.acc_no emp_id,
       'COM' type,      
       decode(d.month_code, '7','2018','8', '2018','9','2018','10','2018','11','2018','12','2018','2019') year,             
       d.month_code,
       1 sl,
       d.salary_date real_date,
       'M' real_type,
       'C' dr_cr_type,
       'N' vou_type,
       d.dedu_amount,
       'MIG',
       trunc(sysdate)   
  from  computer_hb_mon_ded d 
  where month_code  in('1','2','3','4','5','6','7','8','9','10','11','12')
*************************************************************************************************
-----------------------------Opening data for loan ledger & Summary-----------------------

---------------------------------------computer--------------------------------------------
insert into elms_ln_summary
select 1 ENTITY_NUM,
        t.acc_no EMP_ID,
       'COM' LOAN_TYPE,      
       t.prin_bal PRIN_BALANCE,
       t.int_bal,
       t.prin_bal + t.int_bal TOT_BALANCE
  from bhbfc.h_COMPUTER_HBADV_CL2 t where t.fin_year='2017-2018';
  
  insert into elms_ln_ledger
select 1 ENTITY_NUM,
        t.acc_no EMP_ID,
       'COM' LOAN_TYPE,
       2018 REAL_YEAR,
       6 REAL_MONTH_CODE,
       1 REL_SL,
       '30-jun-2019' REAL_DATE,
       '' REAL_TYPE,
       '' DR_CR_TYPE,
       '' VOUCHAR_TYPE,
       0 REAL_AMOUNT,
       t.prin_bal PRIN_BALANCE,
       0 INT_CHARGED,
       t.int_bal,
       t.prin_bal + t.int_bal TOT_BALANCE,
       'MIG' ENTD_BY,
       trunc(sysdate)
  from bhbfc.h_COMPUTER_HBADV_CL2 t where t.fin_year='2017-2018';
  
  delete from elms_ln_ledger l where l.loan_type='COM';
  delete from elms_ln_summary l where l.loan_type='COM';
  
  -----------------------------Motor----------------------------------
  
  select 1 ENTITY_NUM,
        t.acc_no EMP_ID,
       'MOT' LOAN_TYPE,      
       t.prin_bal PRIN_BALANCE,
       t.int_bal,
       t.prin_bal + t.int_bal TOT_BALANCE
  from h_motor_HBADV_CL2 t where t.fin_year='2017-2018';
  
  
  select 1 ENTITY_NUM,
        t.acc_no EMP_ID,
       'MOT' LOAN_TYPE,
       2018 REAL_YEAR,
       6 REAL_MONTH_CODE,
       1 REL_SL,
       '30-jun-2019' REAL_DATE,
       '' REAL_TYPE,
       '' DR_CR_TYPE,
       '' VOUCHAR_TYPE,
       0 REAL_AMOUNT,
       t.prin_bal PRIN_BALANCE,
       0 INT_CHARGED,
       t.int_bal,
       t.prin_bal + t.int_bal TOT_BALANCE,
       'MIG' ENTD_BY,
       trunc(sysdate)
  from h_motor_HBADV_CL2 t where t.fin_year='2017-2018';
  
  -------------------------HBL-------------------------------
  
    select 1 ENTITY_NUM,
        t.acc_no EMP_ID,
       'HBL' LOAN_TYPE,      
       t.prin_bal PRIN_BALANCE,
       t.int_bal,
       t.prin_bal + t.int_bal TOT_BALANCE
  from h_HBADV_CL2 t where t.fin_year='2017-2018';
  
  
  
  select 1 ENTITY_NUM,
        t.acc_no EMP_ID,
       'HBL' LOAN_TYPE,
       2018 REAL_YEAR,
       6 REAL_MONTH_CODE,
       1 REL_SL,
       '30-jun-2019' REAL_DATE,
       '' REAL_TYPE,
       '' DR_CR_TYPE,
       '' VOUCHAR_TYPE,
       0 REAL_AMOUNT,
       t.prin_bal PRIN_BALANCE,
       0 INT_CHARGED,
       t.int_bal,
       t.prin_bal + t.int_bal TOT_BALANCE,
       'MIG' ENTD_BY,
       trunc(sysdate)
  from h_HBADV_CL2 t where t.fin_year='2017-2018';
  ***********************************************************************************************
******************************computer***************************
  
  select * from(select t.branch_code,(select m.brn_name from prms_mbranch m where m.brn_code=t.branch_code)branch_name, (select e.emp_name from prms_employee e where e.emp_id=t.emp_id)name,t.emp_id ,t.sal_year,t.month_code, t.comp_deduc
  from prms_transaction t
 where entity_number = 1
   and sal_year = 2019
   and month_code > 6
   and t.comp_deduc > 0
union
select t.branch_code,(select m.brn_name from prms_mbranch m where m.brn_code=t.branch_code)branch_name, (select e.emp_name from prms_employee e where e.emp_id=t.emp_id)name,t.emp_id ,t.sal_year,t.month_code, t.comp_deduc
  from prms_transaction t
 where entity_number = 1
   and sal_year = 2020
   and month_code < 7
   and t.comp_deduc > 0)
   order by branch_code,emp_id,sal_year,month_code
   
   ******************************motor***************************

   
     select * from(select t.branch_code,(select m.brn_name from prms_mbranch m where m.brn_code=t.branch_code)branch_name, (select e.emp_name from prms_employee e where e.emp_id=t.emp_id)name,t.emp_id ,t.sal_year,t.month_code, t.mcycle_deduc
  from prms_transaction t
 where entity_number = 1
   and sal_year = 2019
   and month_code > 6
   and t.mcycle_deduc > 0
union
select t.branch_code,(select m.brn_name from prms_mbranch m where m.brn_code=t.branch_code)branch_name, (select e.emp_name from prms_employee e where e.emp_id=t.emp_id)name,t.emp_id ,t.sal_year,t.month_code, t.mcycle_deduc
  from prms_transaction t
 where entity_number = 1
   and sal_year = 2020
   and month_code < 7
   and t.mcycle_deduc > 0)
   order by branch_code,emp_id,sal_year,month_code

 