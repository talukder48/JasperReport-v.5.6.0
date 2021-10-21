---------------------------------------isf/emi---------------------------------------------------------
begin
  for idx in(select *from bhbfcflat1819.location  m where m.off_code<63 and m.loc_code='1000')loop
  ClosingProcess.Closing_half_yr(idx.loc_code,'2020-2021','DEC-20-21','01-JUL-2020','31-DEC-2020');
  end loop;
end;

----------------------------------------ocr-------------------------------------------------------------
begin
  for idx in(select *from bhbfcocr.location  m where m.off_code<63 and m.loc_code='1000')loop
  OcrClosingProcess.Closing_half_yr(idx.loc_code,'2020-2021','DEC-20-21','01-JUL-2020','31-DEC-2020');
  end loop;
end;


----------------------------------------optional--------------------------------------------------------
SELECT LOAN_MAS.loan_code FROM bhbfcflat1819.LOAN_MAS  WHERE LOAN_MAS.loan_active='Y' and loc_code='1000' 
      minus  
select distinct b.loan_code from bhbfcflat1819.tmp_rpt_bal  b where b.loc_code='1000'
------------------------------------------old-----------------------------------------------------------
declare v_error varchar2(100):='';
begin
  for idx in(select *from bhbfcflat1819.location  m where m.off_code<63 and m.loc_code='1000')loop
     pkg_ClosingProcess.sp_half_yr_end_closing('2020-2021',idx.loc_code,'DEC-20-21',v_error);
     DBMS_OUTPUT.put_line('Process run -> '||idx.loc_code||'------'||v_error);
  end loop;
end;
---------------------------------------------------------------------------------------------------------