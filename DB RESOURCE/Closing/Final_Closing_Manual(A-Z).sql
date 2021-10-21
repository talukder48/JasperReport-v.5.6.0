*************************************************************************************************************
SELECT  SUBSTR(B.LOAN_CODE,13,1)||'-'||SUBSTR(B.LOAN_CODE,1,1) PROD_TYPE ,SUM( B.CUM_INT_BAL+ B.CUM_PRIN_BAL )
FROM BHBFCFLAT1819.YR_END_BAL B WHERE B.LOC_CODE='0600' AND B.FIN_YEAR='2018-2019'
GROUP BY SUBSTR(B.LOAN_CODE,13,1)||'-'||SUBSTR(B.LOAN_CODE,1,1) 

---------------------------check account drop . if has run the process from front end-------------------------------
select *
  from bhbfcflat1819.acc_drop
 where fin_year = '2019-2020'
   and loc_code = '0402'
   and (cum_prin_bal <> 0 or cum_int_bal <> 0);
--------------------------Error Code Finding-----------------------------------------------------------------------
Select Loc_code,
       loan_type,
       loan_cat,
       loan_acc,
       memo_no,
       pay_date,
       pay_amt,
       purpose,
       ln_type_bk,
       bank,
       period,
       actual_loc_code,
       actual_error,
       branch_code
  from bhbfcflat1819.TMP_RECEIPT
 where actual_error in
       ('Invalid Account Number',
        'Duplicat Account Number and valid account but more than one Branch',
        'No Error and it is duplicate entry',
        'No Error and valid account but more than one Branch')
   and PAY_DATE BETWEEN to_date('01/07/2019', 'dd/mm/rrrr') AND
       to_date('30/06/2020', 'dd/mm/rrrr')
   and actual_loc_code is null
   and PURPOSE = 'M' --branch_code is null AND
   AND LOC_CODE = '0402'
 order by loc_code, loan_type, actual_error ;   

---------------------------------Actual loc code generation process-------------------------------------------------
begin
   bhbfcflat1819.generate_actual_loc_code_new('JUN-19-20');
end;
---------------------------------check duplicate BF correction ------------------------------------------------------
select * from bhbfcflat1819.bf_correction  b where 
b.loc_code='0402' and fin_year='2019-2020' and b.loan_code='1003100010003' 

group by loan_code having count(*)>1;

select distinct substr(m.loan_code,13,1) product, substr(m.loan_code,1,1) type  from bhbfcflat1819.loan_mas m where m.loc_code='0402'

select * from bhbfcflat1819.yr_end_bal y,bhbfcflat1819.bf_correction b 
where y.loc_code=b.loc_code
and y.loan_code=b.LOAN_CODE
and y.fin_year='2019-2020'
and b.fin_year='2019-2020'
and y.loc_code='0402'
and( y.cum_prin_bal<>b.cum_prin_bal or y.cum_int_bal<>b.cum_int_bal);

--------------------------------------bf correction process---------------------------------------------------------
declare fin_year varchar2(10):='2019-2020';
        p_office bhbfcflat1819.loan_mas.loc_code%type:='0402';
begin
for idx in(select distinct substr(m.loan_code,13,1) product, substr(m.loan_code,1,1) type  from bhbfcflat1819.loan_mas m where m.loc_code=p_office)loop      
     /*       If Previlage is not given then run it from front end            */
     bhbfcflat1819.bf_correction_process.BF_CORR_Select_date(fin_year,p_office,idx.type,idx.product);
 end loop;  
 --commit;
end;
------------------------------------delete temporary table data--------------------------------------------------------------
declare p_office bhbfcflat1819.loan_mas.loc_code%type:='0402';
begin
for idx in(select distinct substr(m.loan_code,13,1) product, substr(m.loan_code,1,1) type  from bhbfcflat1819.loan_mas m where m.loc_code=p_office)loop           
     delete from bhbfcflat1819.beg_of_month where loc_code=p_office and substr(loan_code,1,1)=idx.type and substr(loan_code,13,1)=idx.product;
     delete from bhbfcflat1819.tmp_rpt_bal where  loc_code=p_office and substr(loan_code,1,1)=idx.type and substr(loan_code,13,1)=idx.product;
     delete from bhbfcflat1819.rpt_to_date where  loc_code=p_office and substr(loan_code,1,1)=idx.type and substr(loan_code,13,1)=idx.product;
 end loop;  
end;
------------------------run month begin process-------------------------------------------------------
declare fin_year varchar2(10):='2019-2020';
        period   varchar2(10):='JUN-19-20';
        p_office bhbfcflat1819.loan_mas.loc_code%type:='0402';
begin
for idx in(select distinct substr(m.loan_code,13,1) product, substr(m.loan_code,1,1) type  from bhbfcflat1819.loan_mas m where m.loc_code=p_office)loop      
      /*       If Previlage is not given then run it from front end            */
      bhbfcflat1819.lm_month_beg_process.Month_Beg_proc_Start(p_office,'00000000','99999999',idx.type,idx.product,period); 
       dbms_output.put_line(p_office||'-'||idx.product||'-'||idx.type); 
       
 end loop; 
end;

 delete from bhbfcflat1819.beg_of_month where loc_code='0402'; 
 delete from bhbfcflat1819.tmp_rpt_bal where  loc_code='0402';  
 delete from bhbfcflat1819.rpt_to_date where  loc_code='0402'; 

--------------------------checking the temporary table data----------------------------------------------------

select *from bhbfcflat1819.beg_of_month where loc_code='0402';
select *from bhbfcflat1819.tmp_rpt_bal where loc_code='0402';
select *from bhbfcflat1819.rpt_to_date where loc_code='0402';

----------------------------run year end calculation process----------------------------------------------------
declare fin_year varchar2(10):='2019-2020';
        p_office bhbfcflat1819.loan_mas.loc_code%type:='0402';
begin  
for idx in(select distinct substr(m.loan_code,13,1) product, substr(m.loan_code,1,1) type  from bhbfcflat1819.loan_mas m where m.loc_code=p_office)loop          
      /*       If Previlage is not given then run it from front end            */
      bhbfcflat1819.yr_end_calculation_process.yr_end_select_data(fin_year,p_office,idx.product,idx.type,'0000000000000','99999999999999');
 end loop; 
end;
-----------------------------run year end classification process------------------------------------------------
declare fin_year varchar2(10):='2019-2020';
        p_office bhbfcflat1819.loan_mas.loc_code%type:='0402';
begin  
for idx in(select distinct substr(m.loan_code,13,1) product, substr(m.loan_code,1,1) type  from bhbfcflat1819.loan_mas m where m.loc_code=p_office)loop          
      /*       If Previlage is not given then run it from front end            */
      bhbfcflat1819.yr_end_ln_classification.Ln_Class_Select_Data(fin_year,p_office,idx.product,idx.type,'0000000000000','99999999999999');
      DBMS_OUTPUT.ENABLE (buffer_size => NULL);
 end loop; 
end;
------------------------------check all loanmas data into tmp_rpt_bal is entered or not-------------------------

SELECT LOAN_MAS.loan_code FROM bhbfcflat1819.LOAN_MAS  WHERE LOAN_MAS.loan_active='Y' and loc_code='0402' 
      minus  
select distinct b.loan_code from bhbfcflat1819.tmp_rpt_bal  b where b.loc_code='0402'
---------------------------------------------------------------------------------------------------------------
