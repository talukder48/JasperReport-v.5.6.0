**************************-New/prj/ocr-****************************
begin
  for idx in(select *from bhbfcflat1819.location  m where m.off_code<63 and m.loc_code='1000')loop
  ClosingProcess.FinalClosing(idx.loc_code,'2019-2020','JUN-19-20','01-JUL-2019','30-JUN-2020');
  end loop;
end;
-----------------------------------------------------------------------------------------------------
begin
 for idx in(select distinct substr(m.loan_code,13,1) product, substr(m.loan_code,1,1) type  from bhbfcflat1819.loan_mas m where m.loc_code='1000')loop      
                  bhbfcflat1819.bf_correction_process.BF_CORR_Select_date('2019-2020','1000',idx.type,idx.product);
              end loop; 
end;

----------------------------------------emi/isf---------------------------------------------
begin
  for idx in(select *from bhbfcflat1819.location  m where m.off_code<63 and m.loc_code='1000')loop
  ClosingProcess.FinalClosing_Final(idx.loc_code,'2019-2020','JUN-19-20','01-JUL-2019','30-JUN-2020');
  end loop;
end;

----------------------------------------ocr------------------------------------------------
begin
  for idx in(select *from bhbfcflat1819.location  m where m.off_code<63 and m.loc_code='1000')loop
  OcrClosingProcess.FinalClosing_Final(idx.loc_code,'2019-2020','JUN-19-20','01-JUL-2019','30-JUN-2020');
  end loop;
end;


------------------------------------------------------------------------------------------------------
SELECT LOAN_MAS.loan_code FROM bhbfcflat1819.LOAN_MAS  WHERE LOAN_MAS.loan_active='Y' and loc_code='1000' 
      minus  
select distinct b.loan_code from bhbfcflat1819.tmp_rpt_bal  b where b.loc_code='1000'

select *from bhbfcflat1819.location  m where m.off_code<63;


**************************-Govt Loan-****************************
declare v_error varchar2(100):='';
begin
  for idx in(select distinct m.loc_code from loan_mas  m )loop
     pkg_ClosingProcess.sp_yr_end_closing('2019-2020',idx.loc_code,'JUN-19-20',v_error);
     DBMS_OUTPUT.put_line('Process run -> '||idx.loc_code||'------'||v_error);
  end loop;
end;



declare v_error varchar2(100):='';
begin
  for idx in(select distinct m.loc_code from loan_mas  m )loop
     pkg_ClosingProcess.sp_half_yr_end_closing('2020-2021',idx.loc_code,'DEC-20-21',v_error);
     DBMS_OUTPUT.put_line('Process run -> '||idx.loc_code||'------'||v_error);
  end loop;
end;




























