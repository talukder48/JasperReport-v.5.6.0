 
select *from elms_loanledger s where s.emp_id='1179' for update
select *from elms_ln_summary s where s.emp_id='1179' for update
  
SELECT *FROM ELMS_DISBURSE  D WHERE D.EMP_ID='947';
select * from elms_ln_ledger s where s.loan_type='MOT' AND EMP_ID='947';
select *from elms_ln_summary s where s.loan_type='MOT' AND EMP_ID='947';
SELECT *FROM ELMS_REALIZATION R WHERE R.EMP_ID='947' AND R.LOAN_TYPE='MOT';

SELECT MONTH_NAME,
       TO_CHAR(REAL_DATE) REAL_DATE,
       DECODE(REAL_TYPE, 'P', 'Principle', 'I', 'Interest', '') REAL_TYPE,
       DECODE(DR_CR_TYPE, 'D', 'Debit', 'C', 'Credit', '') DR_CR_TYPE,
       DECODE(VOUCHAR_TYPE, 'V', 'Voucher', 'D','Disburse','N','Normal') VOUCHAR_TYPE,
       REAL_AMT,
       PRIN_BAL,
       INT_CHARGED,
       INT_BAL,
       TOT_BAL
  FROM TABLE(PKG_ELMS.FN_LOAN_DATA(1,'9999', '921', 'MOT', '2018-2019', ''));
  
  ------------------------------blank month-------------------------------------------- 
BEGIN
FOR IDX IN (SELECT DISTINCT L.EMP_ID FROM ELMS_LN_LEDGER L WHERE L.LOAN_TYPE='MOT')LOOP
  BEGIN
INSERT INTO ELMS_REALIZATION V VALUES( 1 ,
       IDX.EMP_ID ,
       'MOT' ,      
       2018 ,             
       7,
       1 ,
       '25-JUL-2018',
       'M' ,
       'C' ,
       'N' ,
       0,
       'MIG',
       trunc(sysdate)   
  );
  EXCEPTION WHEN OTHERS THEN 
    DBMS_OUTPUT.put_line('exist the record');
  END ;
  
  END LOOP;
END; 
  
------------------------------Disburse to realization ----------------------------------
declare v_error varchar2(100):='';
V_MONTH_CODE       NUMBER(2);
V_YEAR             NUMBER(4);
V_type             varchar2(3):='COM';
begin
      for d  in(  SELECT *FROM ELMS_DISBURSE  D WHERE D.DISB_DATE BETWEEN '01-jul-2018' AND '30-jun-2019' AND D.LOAN_TYPE=V_type )loop    
 SELECT TO_NUMBER(TO_CHAR(TO_DATE(d.disb_date, 'dd-mon-yy'), 'mm'))
      INTO V_MONTH_CODE
      FROM DUAL;
    SELECT TO_NUMBER(TO_CHAR(d.disb_date, 'YYYY')) INTO V_YEAR FROM DUAL;   
        pkg_elms.SP_LOAN_REALIZATION(1,d.emp_id,d.loan_type,V_YEAR,V_MONTH_CODE,d.disb_date,'P','D','D',d.disb_amount,d.entd_by,v_error);
      end loop;  
end;  

------------------------------------------------------------------------------------------
INSERT INTO ELMS_LN_SUMMARY
select 1 ENTITY_NUM,
        t.acc_no EMP_ID,
       'MOT' LOAN_TYPE,      
       t.prin_bal PRIN_BALANCE,
       t.int_bal,
       t.prin_bal + t.int_bal TOT_BALANCE
  from BHBFC.h_motor_HBADV_CL2 t where t.fin_year='2017-2018';                                                                                                                                                                                                                                                                                                          
  
  INSERT INTO ELMS_LN_LEDGER
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
  from BHBFC.h_motor_HBADV_CL2 t where t.fin_year='2017-2018';
  ----------------------------------------------------------------run accrual process-------------------------------------
  
  
declare
  c1        number := 7;
  c2        number := 1;
  v_year    number := 2018;
  v_error   varchar2(400) := '';
  v_ln_type varchar2(4) := 'COM';
begin
  loop
    if c1 > 12 and c2 > 6 then
      exit;
    end if;
  
    if c1 < 13 then
      dbms_output.put_line(c1 || '-' || v_year);
      pkg_elms.SP_ACCRUAL_PROCESS(1, v_year, c1, v_ln_type, v_error);
      c1 := c1 + 1;
    end if;
  
    if c1 > 12 then
      dbms_output.put_line(c2 || '-' || to_char(v_year + 1));
      pkg_elms.SP_ACCRUAL_PROCESS(1, v_year + 1, c2, v_ln_type, v_error);
      c2 := c2 + 1;
    end if;
  
  end loop;

end;
SELECT *FROM ELMS_LN_LEDGER S WHERE S.EMP_ID='1198'
----------------------------------------------------------------RUN PF PROCESS-----------------------------------------------

declare
  c1        number := 7;
  c2        number := 1;
  v_year    number := 2018;
  v_error   varchar2(400) := '';
  
begin
  loop
    if c1 > 12 and c2 > 6 then
      exit;
    end if;
  
    if c1 < 13 then
      dbms_output.put_line(c1 || '-' || v_year);
      pkg_elms.SP_PF_PROCESS(1, v_year, c1, v_error);
      c1 := c1 + 1;
    end if;
  
    if c1 > 12 then
      dbms_output.put_line(c2 || '-' || to_char(v_year + 1));
      pkg_elms.SP_PF_PROCESS(1, v_year + 1, c2, v_error);
      c2 := c2 + 1;
    end if;
  
  end loop;

end;
----------------------------------------------------VOUCHER-----------------------------

declare
  v_error      varchar2(100) := '';
  V_MONTH_CODE NUMBER(2);
  V_YEAR       NUMBER(4);
  V_type       varchar2(3) := 'COM';
begin
  for d in (SELECT *
              FROM (SELECT M.ACC_NO,
                           M.VMVRM_DT,
                           NVL(PRIN_DB, 0) + NVL(INT_DB, 0) DR,
                           NVL(PRIN_CR, 0) + NVL(INT_CR, 0) CR
                      FROM BHBFC.COMPUTER_HB_VMVRM M
                     WHERE M.VMVRM_DT BETWEEN '01-JUL-2018' AND '30-JUN-2019'
                       AND PURPOSE = 'V')
             WHERE CR > 0) loop
    SELECT TO_NUMBER(TO_CHAR(TO_DATE(d.VMVRM_DT, 'dd-mon-yy'), 'mm'))
      INTO V_MONTH_CODE
      FROM DUAL;
    SELECT TO_NUMBER(TO_CHAR(d.VMVRM_DT, 'YYYY')) INTO V_YEAR FROM DUAL;
    pkg_elms.SP_LOAN_REALIZATION(1,
                                 d.ACC_NO,
                                 V_type,
                                 V_YEAR,
                                 V_MONTH_CODE,
                                 d.VMVRM_DT,
                                 'B',
                                 'C',
                                 'V',
                                 d.CR,
                                 'MIG',
                                 v_error);
  end loop;
end;

---------------------------------------------------------ADVANCE PAYMENT------------------------------------

declare
  v_error      varchar2(100) := '';
  V_MONTH_CODE NUMBER(2);
  V_YEAR       NUMBER(4);
  V_type       varchar2(3) := 'COM';
begin
  for d in (SELECT M.ACC_NO,M.VMVRM_DT,M.AMT FROM BHBFC.COMPUTER_HB_VMVRM M WHERE M.VMVRM_DT BETWEEN '01-JUL-2018' AND '30-JUN-2019' AND PURPOSE='MV'
) loop
    SELECT TO_NUMBER(TO_CHAR(TO_DATE(d.VMVRM_DT, 'dd-mon-yy'), 'mm'))
      INTO V_MONTH_CODE
      FROM DUAL;
    SELECT TO_NUMBER(TO_CHAR(d.VMVRM_DT, 'YYYY')) INTO V_YEAR FROM DUAL;
    pkg_elms.SP_LOAN_REALIZATION(1,
                                 d.ACC_NO,
                                 V_type,
                                 V_YEAR,
                                 V_MONTH_CODE,
                                 d.VMVRM_DT,
                                 'P',
                                 'C',
                                 'A',
                                 D.AMT,
                                 'MIG',
                                 v_error);
  end loop;
end;

/******************************************************
1.computer 2018-2019 done
2.motor 2018-2019 done
3. pf 2018-2019 done
   ******************************
   pf 2019-2020 done based on PRMS data. 
   
   need to run again; summary should be cleared again.

*/
