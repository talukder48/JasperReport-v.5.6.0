
---------------------------------------------------------------------
#Disburse info by product,type,location wise
select *
  from bhbfcflat1819.disburse
 where loc_code = '0603'
   and period like '%-18-19'
   and substr(loan_code, 1, 1) = '1'
   and substr(loan_code, 13, 1) = '3'

--------------------------------------------------------------------
select substr(b.loan_code, 1, 1) loan_type,
       substr(b.loan_code, 2, 8) loanCase,
       substr(b.loan_code, 10, 2) loan_catagory,
      -- b.loc_code,
      -- b.loan_code,
       m.name1,
       m.m_add1,
       m.cell_no,
       m.sanc_amt,
       m.loan_period,
       m.repay_date,
       ADD_MONTHS(m.repay_date,(m.loan_period)) as expiry_date,
       m.prin_inst + m.int_inst installment,
       b.cum_prin_inst_ov + b.cum_n_int_inst_ov Overdue,
       b.ln_criteria,
       FUR_INT_FALL_DUE,
      -- fur_prin_fall_due + fur_int_fall_due falldue,
       b.cum_prin_bal,
       b.cum_int_bal,
       b.cum_prin_bal + b.cum_int_bal total_balance
  from BHBFCflat1819.tmp_rpt_bal b
  join BHBFCflat1819.Loan_Mas m
    on (b.loan_code = m.loan_code and b.loc_code = m.loc_code)
 where fin_year = '2018-2019'
   and (cum_prin_inst_ov + cum_n_int_inst_ov > 0.00 or
       FUR_INT_FALL_DUE > 0.00)
   and b.loc_code = '0800';
------------------------------------------------------------------
select LOC_CODE, LN_TYPE, PRODUCT, DISBURSE, LOAN_LED,LOAN_LED-DISBURSE as  DIFF from table(pkg_loan.fn_disberse)
where LOAN_LED-DISBURSE>0
order by LOC_CODE
-------------------------------------------------------------------
SELECT *FROM(
select B.LOC_CODE,sum(prin_dr),
       B.REF_NO,
       SUBSTR(LOAN_CODE, 13, 1) ||'-'|| SUBSTR(LOAN_CODE, 1, 1) PRODUCT_LOAN
       
  from bhbfcprj.rpt_to_date B
 WHERE TRANS_TYPE = 'D'
 GROUP BY REF_NO,
          SUBSTR(LOAN_CODE, 13, 1) ||'-'|| SUBSTR(LOAN_CODE, 1, 1) ,LOC_CODE
MINUS
select LOC_CODE,sum(disb_amt),
       D.CHEQUE_NO,
       SUBSTR(LOAN_CODE, 13, 1) ||'-'|| SUBSTR(LOAN_CODE, 1, 1) PRODUCT_LOAN
  from bhbfcprj.disburse D

 GROUP BY CHEQUE_NO,
          SUBSTR(LOAN_CODE, 13, 1) ||'-'|| SUBSTR(LOAN_CODE, 1, 1) ,LOC_CODE)
          ORDER BY LOC_CODE
---------------------------------------------------------------------------------------
select r.actual_loc_code,sum(r.pay_amt)
  from bhbfcf1819.tmp_receipt r
 where loc_code = '0901'
   and r.loc_code <> r.actual_loc_code
   and period like '%-18-19'
   and r.pay_date between '01-jul-2018' and '30-jun-2019'
   group by actual_loc_code
   order by actual_loc_code
--------------------------------------------------------------------------
select *
  from bhbfcflat1819.loan_mas m
 where m.loan_acc like '%250015%'
    or m.loan_acc like '%250016%'
    or m.loan_acc like '%250019%';
	---------------------------
	SELECT *FROM TABLE( PKG_RPT.FN_GET_DATA('2018-2019')) ORDER BY LOC_CODE;//CLASSIFIED & UNCLASSIFIED LOAN REPORT
	-----------------------------
	
	
	
select sum(pay_amt) from bhbfcFLAT1819.TMP_RECEIPT where loc_code='5004' and loan_type='1' and
PAY_DATE BETWEEN to_date('01/07/2019','dd/mm/rrrr') AND to_date('31/12/2019','dd/mm/rrrr')

-------memo collection from others branches for pallabi office ------------
select sum(pay_amt) from bhbfcFLAT1819.TMP_RECEIPT where  loan_type='1' and
PAY_DATE BETWEEN to_date('01/07/2019','dd/mm/rrrr') AND to_date('31/12/2019','dd/mm/rrrr')
and loc_code<>'5004' and actual_loc_code='5004'

------Actual memo collection for Pallabi br. (consider all branaches of bhbfch)  --loan ledger summary
select sum(pay_amt) from bhbfcFLAT1819.RECEIPT where loc_code='5004' and substr(loan_code,1,1)='1' and
PAY_DATE BETWEEN to_date('01/07/2019','dd/mm/rrrr') AND to_date('31/12/2019','dd/mm/rrrr')	








*******************************new product******************************

select sum(pay_amt) 
--count(*)
from bhbfcFLAT1819.TMP_RECEIPT where actual_loc_code='3000' and loan_type='2' and loan_product='3' and
PAY_DATE BETWEEN to_date('01/07/2019','dd/mm/rrrr') AND to_date('30/06/2020','dd/mm/rrrr')

-------memo collection from others branches for pallabi office ------------
select sum(pay_amt) from bhbfcFLAT1819.TMP_RECEIPT where  
PAY_DATE BETWEEN to_date('01/07/2019','dd/mm/rrrr') AND to_date('30/06/2020','dd/mm/rrrr')
and  actual_loc_code='3000'

------Actual memo collection for Pallabi br. (consider all branaches of bhbfch)  --loan ledger summary
select sum(pay_amt)
 from bhbfcFLAT1819.RECEIPT where loc_code='3000' and substr(loan_code,1,1)='2' 
and substr(loan_code,13,1)='3'
and PAY_DATE BETWEEN to_date('01/07/2019','dd/mm/rrrr') AND to_date('30/06/2020','dd/mm/rrrr')

	
**************IDB: Account : 2018-2019, Disburse : 2019-2020 ************
SELECT B.LOC_CODE,
       (SELECT L.LOC_DESC
          FROM BHBFCPRJ.LOCATION L
         WHERE L.LOC_CODE = B.LOC_CODE) OFFICE_NAME,
       SUM(B.DISB_AMT)
  FROM bhbfcprj.Disburse B
 WHERE B.LOAN_CODE IN ((select M.LOAN_CODE
                         from bhbfcprj.Yr_End_Bal m
                        where M.FIN_YEAR = '2018-2019'))
   AND B.PERIOD LIKE '%-19-20'
 GROUP BY B.LOC_CODE
 ORDER BY B.LOC_CODE

***************IDB: Account : 2019-2020, Disburse : 2019-2020 *********
SELECT B.LOC_CODE,
       (SELECT L.LOC_DESC
          FROM BHBFCPRJ.LOCATION L
         WHERE L.LOC_CODE = B.LOC_CODE) OFFICE_NAME,
       SUM(B.DISB_AMT)
  FROM bhbfcprj.Disburse B
 WHERE B.LOAN_CODE IN (SELECT M.LOAN_CODE FROM BHBFCPRJ.LOAN_MAS M
                MINUS
                select M.LOAN_CODE from bhbfcprj.Yr_End_Bal m where M.FIN_YEAR='2018-2019')
   AND B.PERIOD LIKE '%-19-20'
 GROUP BY B.LOC_CODE
 ORDER BY B.LOC_CODE
**********************************************************	
	
	
select   bank,substr(loan_code,1 ,1)  loan_type, substr(loan_code,2 ,8)  loan_acc,loc_code,memo_no,pay_date,pay_amt,purpose  from bhbfcflat1819.receipt m where m.loc_code='2002' and m.purpose='M'
minus
select   bank ,loan_type,loan_acc,loc_code,memo_no,pay_date,pay_amt,purpose  from bhbfcflat1819.tmp_receipt m where m.loc_code='2002' and m.purpose='M'
  	
*****************************************************	
select (select m.brn_name from prms_mbranch m where m.brn_code=s.emp_brn_code) office_name,e.emp_name,
(select d.dept_name from prms_brn_department d where d.dept_code=s.emp_dept_code) dept,
e.highest_degree 
from prms_employee e 
, prms_emp_sal s 
where s.emp_id=e.emp_id
and s.acc_no_active <>'N'
and s.desig_code in('41','51') 
and e.highest_degree like '%E%'
and e.highest_degree not like '%Engl%'
and e.highest_degree not like '%Econ%'
and e.highest_degree not like '%Env%' 
and e.highest_degree not like '%ECONO%' 
and e.highest_degree not like '%POLITI%' 
and e.highest_degree not like '%FINA%' 
and e.highest_degree not like '%PHYSIO%'
