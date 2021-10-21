create or replace package ClosingProcess is
procedure Closing_half_yr (p_office in varchar2,p_fin_year in varchar2,p_period in varchar2,p_date1 in date,p_date2 in date);
  procedure sp_data_posting(p_fin_year varchar2, p_office    varchar2);
  procedure FinalClosing (p_office in varchar2,p_fin_year in varchar2,p_period in varchar2,p_date1 in date,p_date2 in date);
  procedure FinalClosing_Final (p_office in varchar2,p_fin_year in varchar2,p_period in varchar2,p_date1 in date,p_date2 in date);
  procedure FinalClosing_Final_product(p_office   in varchar2,p_fin_year in varchar2,p_period   in varchar2, p_date1    in date,p_date2    in date, p_product    in varchar2,P_type       in varchar2);
  /*
begin
  ClosingProcess.FinalClosing('5005','2019-2020','JUN-19-20','01-JUL-2019','30-JUN-2020');
end;
*/
end ClosingProcess;
/
create or replace package body ClosingProcess is


procedure sp_data_posting(p_fin_year varchar2, p_office    varchar2) is
begin
 for idx in(select distinct substr(m.loan_code,13,1) product, substr(m.loan_code,1,1) type  from bhbfcflat1819.loan_mas m where m.loc_code=p_office)loop          
  bhbfcflat1819.lm_yr_end_posting.data_posting(p_fin_year,p_office,idx.type,idx.product,'0000000000000','99999999999999');
end loop;                    
end sp_data_posting;


procedure FinalClosing_Final (p_office in varchar2,p_fin_year in varchar2,p_period in varchar2,p_date1 in date,p_date2 in date)is
    v_duplicate_bf_exception   exception;
    v_loan_ledger_exception    exception;
    v_beg_of_month_Exception   exception;
    v_account_drop_exception   exception;
    v_memo_error_exception     exception;
    v_memo_exist_exception     exception;
    pragma exception_init (v_duplicate_bf_exception, -20001);
    pragma exception_init (v_loan_ledger_exception , -20002);
    pragma exception_init (v_beg_of_month_Exception, -20003);
    pragma exception_init (v_account_drop_exception, -20004);
    pragma exception_init (v_memo_error_exception  , -20005);
    pragma exception_init (v_memo_exist_exception  , -20006);
    v_duplicate_bf_count number:=0;
    v_bf_exist           number:=0;
    V_acc                number:=0; 
    v_beg_month_row      number:=0;
    v_ac_total_month     number:=0; 
    v_acc_drop_exist     number:=0;
    V_error_exist_memo   number:=0;
    V_check_memo_exist   number:=0;
    
 begin
          
         
       bhbfcflat1819.generate_actual_loc_code_new(p_period);  
       /*memo validation process for a branch for all types of products */
       for idx in(select distinct substr(m.loan_code,13,1) product, substr(m.loan_code,1,1) type  from bhbfcflat1819.loan_mas m where m.loc_code=p_office)loop      
           bhbfcflat1819.Lm_Memo_Validation_Process.data_validation(p_office,p_period,'','',idx.product,idx.type,'','','','AP');
           DBMS_OUTPUT.ENABLE (buffer_size => NULL);
       end loop; 
       commit;
            
       /*  delete beg_of_month, tmp_rpt_bal,rpt_to_date for pre-process  */
       for idx in(select distinct substr(m.loan_code,13,1) product, substr(m.loan_code,1,1) type  from bhbfcflat1819.loan_mas m where m.loc_code=p_office)loop           
                delete from bhbfcflat1819.beg_of_month where loc_code=p_office and substr(loan_code,1,1)=idx.type and substr(loan_code,13,1)=idx.product;
                delete from bhbfcflat1819.tmp_rpt_bal where  loc_code=p_office and substr(loan_code,1,1)=idx.type and substr(loan_code,13,1)=idx.product;
                delete from bhbfcflat1819.rpt_to_date where  loc_code=p_office and substr(loan_code,1,1)=idx.type and substr(loan_code,13,1)=idx.product;
       end loop;  
       commit;
       /*           Run Beg of Month process for a Branch                 */
       bhbfcflat1819.lm_month_beg_process.Month_Beg_proc_Start(p_office,'','','','',p_period);
        DBMS_OUTPUT.ENABLE (buffer_size => NULL);
       commit;
       
       /*          Account*Month checking after beg of month process      */
       select count(*)*12 into v_ac_total_month FROM bhbfcflat1819.LOAN_MAS  WHERE LOAN_MAS.loan_active='Y' and loc_code=p_office ;       
       select count(*) into v_beg_month_row FROM bhbfcflat1819.beg_of_month  WHERE   loc_code=p_office ;
       
       --if v_ac_total_month<>v_beg_month_row then
       --    raise v_beg_of_month_Exception;
      -- end if;
       
       /*          Run Year End Calculation Process for a branch            */
       for idx in(select distinct substr(m.loan_code,13,1) product, substr(m.loan_code,1,1) type  from bhbfcflat1819.loan_mas m where m.loc_code=p_office)loop          
               bhbfcflat1819.yr_end_calculation_process.yr_end_select_data(p_fin_year,p_office,idx.product,idx.type,'0000000000000','99999999999999');
       end loop; 
       commit;
        /*         Run Year End Classification Process for a branch          */
       for idx in(select distinct substr(m.loan_code,13,1) product, substr(m.loan_code,1,1) type  from bhbfcflat1819.loan_mas m where m.loc_code=p_office)loop          
               bhbfcflat1819.yr_end_ln_classification.Ln_Class_Select_Data(p_fin_year,p_office,idx.product,idx.type,'0000000000000','99999999999999');
               DBMS_OUTPUT.ENABLE (buffer_size => NULL);
       end loop; 
       commit;       
       /*         check exist for all account in loan-ledger statement        */
      select count(*) into V_acc from (
       SELECT LOAN_MAS.loan_code FROM bhbfcflat1819.LOAN_MAS  WHERE LOAN_MAS.loan_active='Y' and loc_code=p_office 
            minus  
      select distinct b.loan_code from bhbfcflat1819.tmp_rpt_bal  b where b.loc_code=p_office);
      
     if V_acc<>0 then 
           raise v_loan_ledger_exception;
     end if;
  
  exception 
    when v_duplicate_bf_exception then
        dbms_output.put_line('Duplicate BF Correction is given-'||p_office);
    when v_loan_ledger_exception then
        dbms_output.put_line('All account is not posting for -'||p_office);   
    when v_beg_of_month_Exception then   
        dbms_output.put_line('Beg of month is not run for account -'||p_office); 
    when v_memo_exist_exception then 
        dbms_output.put_line('All memo is not posting to recipt from tmp_recipt -'||p_office); 
    when v_account_drop_exception then 
        dbms_output.put_line('Account Drop exist, Please run account drop process -'||p_office);   
    when v_memo_error_exception   then
        dbms_output.put_line('Error Exist in memo Data, Please validate it -'||p_office);                                                               
end  FinalClosing_Final;

procedure FinalClosing (p_office in varchar2,p_fin_year in varchar2,p_period in varchar2,p_date1 in date,p_date2 in date)is
    v_duplicate_bf_exception   exception;
    v_loan_ledger_exception    exception;
    v_beg_of_month_Exception   exception;
    v_account_drop_exception   exception;
    v_memo_error_exception     exception;
    v_memo_exist_exception     exception;
    pragma exception_init (v_duplicate_bf_exception, -20001);
    pragma exception_init (v_loan_ledger_exception , -20002);
    pragma exception_init (v_beg_of_month_Exception, -20003);
    pragma exception_init (v_account_drop_exception, -20004);
    pragma exception_init (v_memo_error_exception  , -20005);
    pragma exception_init (v_memo_exist_exception  , -20006);
    v_duplicate_bf_count number:=0;
    v_bf_exist           number:=0;
    V_acc                number:=0; 
    v_beg_month_row      number:=0;
    v_ac_total_month     number:=0; 
    v_acc_drop_exist     number:=0;
    V_error_exist_memo   number:=0;
    V_check_memo_exist   number:=0;
    
 begin
       /*             Check Account Drop for a branch                  */  
       select count(*) into v_acc_drop_exist from bhbfcflat1819.acc_drop where fin_year = p_fin_year and loc_code = p_office and (cum_prin_bal <> 0 or cum_int_bal <> 0);
         if v_acc_drop_exist>0 then
           raise v_account_drop_exception ;
         end if;
       /*             Error Finding in memo Data for a Branch          */  
      Select count(*) into V_error_exist_memo from bhbfcflat1819.TMP_RECEIPT
         where actual_error in('Invalid Account Number','Duplicat Account Number and valid account but more than one Branch', 'No Error and it is duplicate entry', 'No Error and valid account but more than one Branch')and PAY_DATE BETWEEN  p_date1 AND p_date2  and actual_loc_code is null and PURPOSE = 'M'  AND LOC_CODE = p_office order by loc_code, loan_type, actual_error;         
       if V_error_exist_memo>0 then
          raise v_memo_error_exception;
        end if;       
         
       bhbfcflat1819.generate_actual_loc_code_new(p_period);  
       /*memo validation process for a branch for all types of products */
       for idx in(select distinct substr(m.loan_code,13,1) product, substr(m.loan_code,1,1) type  from bhbfcflat1819.loan_mas m where m.loc_code=p_office)loop      
           bhbfcflat1819.Lm_Memo_Validation_Process.data_validation(p_office,p_period,'','',idx.product,idx.type,'','','','AP');
           DBMS_OUTPUT.ENABLE (buffer_size => NULL);
       end loop; 
       commit;
       
        /*  check all memo is posted in recipt table or not            */
        
       select count(*) into V_check_memo_exist from(                                        
                   select   bank ,loan_type,loan_acc,loc_code,memo_no,pay_date,pay_amt,purpose  from bhbfcflat1819.tmp_receipt m where m.loc_code=p_office and m.purpose='M'
                                                         minus                                       
                   select   bank,substr(loan_code,1 ,1)  loan_type, substr(loan_code,2 ,8)  loan_acc,loc_code,memo_no,pay_date,pay_amt,purpose  from bhbfcflat1819.receipt m where m.loc_code=p_office and m.purpose='M'
         );
 
     --  if V_check_memo_exist>0 then
     --      raise v_memo_exist_exception;
     --  end if;
       /*                    check BF data for the branch               */
        select count(*) into v_bf_exist from bhbfcflat1819.bf_correction  b where  b.loc_code=p_office and fin_year=p_fin_year;

       if v_bf_exist>0 then     
       /*              check duplicate BF data for the branch            */                   
          select count(*) into v_duplicate_bf_count from (select  loan_acc, count(*) from bhbfcflat1819.bf_correction where fin_year=p_fin_year and loc_code=p_office
          group by loan_acc having count(*)>1);                    
          if v_duplicate_bf_count>0 then
                raise v_duplicate_bf_exception;
          else
       /*              Run BF Correction Process for a branch            */
              for idx in(select distinct substr(m.loan_code,13,1) product, substr(m.loan_code,1,1) type  from bhbfcflat1819.loan_mas m where m.loc_code=p_office)loop      
                  bhbfcflat1819.bf_correction_process.BF_CORR_Select_date(p_fin_year,p_office,idx.type,idx.product);
              end loop; 
           commit;   
          end if;  
      end if;    
       /*  delete beg_of_month, tmp_rpt_bal,rpt_to_date for pre-process  */
       for idx in(select distinct substr(m.loan_code,13,1) product, substr(m.loan_code,1,1) type  from bhbfcflat1819.loan_mas m where m.loc_code=p_office)loop           
                delete from bhbfcflat1819.beg_of_month where loc_code=p_office and substr(loan_code,1,1)=idx.type and substr(loan_code,13,1)=idx.product;
                delete from bhbfcflat1819.tmp_rpt_bal where  loc_code=p_office and substr(loan_code,1,1)=idx.type and substr(loan_code,13,1)=idx.product;
                delete from bhbfcflat1819.rpt_to_date where  loc_code=p_office and substr(loan_code,1,1)=idx.type and substr(loan_code,13,1)=idx.product;
       end loop;  
       commit;
       /*           Run Beg of Month process for a Branch                 */
       bhbfcflat1819.lm_month_beg_process.Month_Beg_proc_Start(p_office,'','','','',p_period);
        DBMS_OUTPUT.ENABLE (buffer_size => NULL);
       commit;
       
       /*          Account*Month checking after beg of month process      */
       select count(*)*12 into v_ac_total_month FROM bhbfcflat1819.LOAN_MAS  WHERE LOAN_MAS.loan_active='Y' and loc_code=p_office ;       
       select count(*) into v_beg_month_row FROM bhbfcflat1819.beg_of_month  WHERE   loc_code=p_office ;
       
       if v_ac_total_month<>v_beg_month_row then
           raise v_beg_of_month_Exception;
       end if;
       
       /*          Run Year End Calculation Process for a branch            */
       for idx in(select distinct substr(m.loan_code,13,1) product, substr(m.loan_code,1,1) type  from bhbfcflat1819.loan_mas m where m.loc_code=p_office)loop          
               bhbfcflat1819.yr_end_calculation_process.yr_end_select_data(p_fin_year,p_office,idx.product,idx.type,'0000000000000','99999999999999');
       end loop; 
       commit;
        /*         Run Year End Classification Process for a branch          */
       for idx in(select distinct substr(m.loan_code,13,1) product, substr(m.loan_code,1,1) type  from bhbfcflat1819.loan_mas m where m.loc_code=p_office)loop          
               bhbfcflat1819.yr_end_ln_classification.Ln_Class_Select_Data(p_fin_year,p_office,idx.product,idx.type,'0000000000000','99999999999999');
               DBMS_OUTPUT.ENABLE (buffer_size => NULL);
       end loop; 
       commit;       
       /*         check exist for all account in loan-ledger statement        */
      select count(*) into V_acc from (
       SELECT LOAN_MAS.loan_code FROM bhbfcflat1819.LOAN_MAS  WHERE LOAN_MAS.loan_active='Y' and loc_code=p_office 
            minus  
      select distinct b.loan_code from bhbfcflat1819.tmp_rpt_bal  b where b.loc_code=p_office);
      
     if V_acc<>0 then 
           raise v_loan_ledger_exception;
     end if;
  
  exception 
    when v_duplicate_bf_exception then
        dbms_output.put_line('Duplicate BF Correction is given-'||p_office);
    when v_loan_ledger_exception then
        dbms_output.put_line('All account is not posting for -'||p_office);   
    when v_beg_of_month_Exception then   
        dbms_output.put_line('Beg of month is not run for account -'||p_office); 
    when v_memo_exist_exception then 
        dbms_output.put_line('All memo is not posting to recipt from tmp_recipt -'||p_office); 
    when v_account_drop_exception then 
        dbms_output.put_line('Account Drop exist, Please run account drop process -'||p_office);   
    when v_memo_error_exception   then
        dbms_output.put_line('Error Exist in memo Data, Please validate it -'||p_office);                                                               
end  FinalClosing; 
procedure FinalClosing_Final_product(p_office   in varchar2,
                                     p_fin_year in varchar2,
                                     p_period   in varchar2,
                                     p_date1    in date,
                                     p_date2    in date,
                                     p_product    in varchar2,
                                     P_type       in varchar2) is
  v_duplicate_bf_exception exception;
  v_loan_ledger_exception  exception;
  v_beg_of_month_Exception exception;
  v_account_drop_exception exception;
  v_memo_error_exception   exception;
  v_memo_exist_exception   exception;
  pragma exception_init(v_duplicate_bf_exception, -20001);
  pragma exception_init(v_loan_ledger_exception, -20002);
  pragma exception_init(v_beg_of_month_Exception, -20003);
  pragma exception_init(v_account_drop_exception, -20004);
  pragma exception_init(v_memo_error_exception, -20005);
  pragma exception_init(v_memo_exist_exception, -20006);
  v_duplicate_bf_count number := 0;
  v_bf_exist           number := 0;
  V_acc                number := 0;
  v_beg_month_row      number := 0;
  v_ac_total_month     number := 0;
  v_acc_drop_exist     number := 0;
  V_error_exist_memo   number := 0;
  V_check_memo_exist   number := 0;

begin

    bhbfcflat1819.generate_actual_loc_code_new(p_period);
  /*memo validation process for a branch for all types of products */
    bhbfcflat1819.Lm_Memo_Validation_Process.data_validation(p_office,
                                                             p_period,
                                                             '',
                                                             '',
                                                             p_product,
                                                             P_type,
                                                             '',
                                                             '',
                                                             '',
                                                             'AP');
    DBMS_OUTPUT.ENABLE(buffer_size => NULL);
  
  commit;

  /*  delete beg_of_month, tmp_rpt_bal,rpt_to_date for pre-process  */

    delete from bhbfcflat1819.beg_of_month
     where loc_code = p_office
       and substr(loan_code, 1, 1) = P_type
       and substr(loan_code, 13, 1) = p_product;
       
    delete from bhbfcflat1819.tmp_rpt_bal
     where loc_code = p_office
       and substr(loan_code, 1, 1) = P_type
       and substr(loan_code, 13, 1) = p_product;
    delete from bhbfcflat1819.rpt_to_date
     where loc_code = p_office
       and substr(loan_code, 1, 1) = P_type
       and substr(loan_code, 13, 1) = p_product;
 
  commit;
  /*           Run Beg of Month process for a Branch                 */
  bhbfcflat1819.lm_month_beg_process.Month_Beg_proc_Start(p_office,
                                                          '',
                                                          '',
                                                          p_product,
                                                          P_type,
                                                          p_period);
  DBMS_OUTPUT.ENABLE(buffer_size => NULL);
  commit;

  /*          Account*Month checking after beg of month process      */
  select count(*) * 12
    into v_ac_total_month
    FROM bhbfcflat1819.LOAN_MAS
   WHERE LOAN_MAS.loan_active = 'Y'
     and loc_code = p_office;
  select count(*)
    into v_beg_month_row
    FROM bhbfcflat1819.beg_of_month
   WHERE loc_code = p_office;

  --   if v_ac_total_month<>v_beg_month_row then
  --     raise v_beg_of_month_Exception;
  --end if;

  /*          Run Year End Calculation Process for a branch            */

    bhbfcflat1819.yr_end_calculation_process.yr_end_select_data(p_fin_year,
                                                                p_office,
                                                                p_product,
                                                                P_type,
                                                                '0000000000000',
                                                                '99999999999999');
  commit;
  /*         Run Year End Classification Process for a branch          */

    bhbfcflat1819.yr_end_ln_classification.Ln_Class_Select_Data(p_fin_year,
                                                                p_office,
                                                                p_product,
                                                                P_type,
                                                                '0000000000000',
                                                                '99999999999999');
    DBMS_OUTPUT.ENABLE(buffer_size => NULL);
  commit;
  /*         check exist for all account in loan-ledger statement        */
  select count(*)
    into V_acc
    from (SELECT LOAN_MAS.loan_code
            FROM bhbfcflat1819.LOAN_MAS
           WHERE LOAN_MAS.loan_active = 'Y'
             and loc_code = p_office
          minus
          select distinct b.loan_code
            from bhbfcflat1819.tmp_rpt_bal b
           where b.loc_code = p_office);

  if V_acc <> 0 then
    raise v_loan_ledger_exception;
  end if;

exception
  when v_duplicate_bf_exception then
    dbms_output.put_line('Duplicate BF Correction is given-' || p_office);
  when v_loan_ledger_exception then
    dbms_output.put_line('All account is not posting for -' || p_office);
  when v_beg_of_month_Exception then
    dbms_output.put_line('Beg of month is not run for account -' ||
                         p_office);
  when v_memo_exist_exception then
    dbms_output.put_line('All memo is not posting to recipt from tmp_recipt -' ||
                         p_office);
  when v_account_drop_exception then
    dbms_output.put_line('Account Drop exist, Please run account drop process -' ||
                         p_office);
  when v_memo_error_exception then
    dbms_output.put_line('Error Exist in memo Data, Please validate it -' ||
                         p_office);
end FinalClosing_Final_product;

procedure Closing_half_yr (p_office in varchar2,p_fin_year in varchar2,p_period in varchar2,p_date1 in date,p_date2 in date)is
    v_duplicate_bf_exception   exception;
    v_loan_ledger_exception    exception;
    v_beg_of_month_Exception   exception;
    v_account_drop_exception   exception;
    v_memo_error_exception     exception;
    v_memo_exist_exception     exception;
    pragma exception_init (v_duplicate_bf_exception, -20001);
    pragma exception_init (v_loan_ledger_exception , -20002);
    pragma exception_init (v_beg_of_month_Exception, -20003);
    pragma exception_init (v_account_drop_exception, -20004);
    pragma exception_init (v_memo_error_exception  , -20005);
    pragma exception_init (v_memo_exist_exception  , -20006);
    v_duplicate_bf_count number:=0;
    v_bf_exist           number:=0;
    V_acc                number:=0; 
    v_beg_month_row      number:=0;
    v_ac_total_month     number:=0; 
    v_acc_drop_exist     number:=0;
    V_error_exist_memo   number:=0;
    V_check_memo_exist   number:=0;
    
 begin
          
         
       bhbfcflat1819.generate_actual_loc_code_new(p_period);  
       /*memo validation process for a branch for all types of products */
       for idx in(select distinct substr(m.loan_code,13,1) product, substr(m.loan_code,1,1) type  from bhbfcflat1819.loan_mas m where m.loc_code=p_office)loop      
           bhbfcflat1819.Lm_Memo_Validation_Process.data_validation(p_office,p_period,'','',idx.product,idx.type,'','','','AP');
           DBMS_OUTPUT.ENABLE (buffer_size => NULL);
       end loop; 
       commit;
            
       /*  delete beg_of_month, tmp_rpt_bal,rpt_to_date for pre-process  */
       for idx in(select distinct substr(m.loan_code,13,1) product, substr(m.loan_code,1,1) type  from bhbfcflat1819.loan_mas m where m.loc_code=p_office)loop           
                delete from bhbfcflat1819.beg_of_month where loc_code=p_office and substr(loan_code,1,1)=idx.type and substr(loan_code,13,1)=idx.product;
                delete from bhbfcflat1819.tmp_rpt_bal where  loc_code=p_office and substr(loan_code,1,1)=idx.type and substr(loan_code,13,1)=idx.product;
                delete from bhbfcflat1819.rpt_to_date where  loc_code=p_office and substr(loan_code,1,1)=idx.type and substr(loan_code,13,1)=idx.product;
       end loop;  
       commit;
       /*           Run Beg of Month process for a Branch                 */
       bhbfcflat1819.lm_month_beg_process.Month_Beg_proc_Start(p_office,'','','','',p_period);
        DBMS_OUTPUT.ENABLE (buffer_size => NULL);
       commit;
       
       /*          Account*Month checking after beg of month process      */
       select count(*)*12 into v_ac_total_month FROM bhbfcflat1819.LOAN_MAS  WHERE LOAN_MAS.loan_active='Y' and loc_code=p_office ;       
       select count(*) into v_beg_month_row FROM bhbfcflat1819.beg_of_month  WHERE   loc_code=p_office ;
       
       /*          Run Year End Calculation Process for a branch            */
       for idx in(select distinct substr(m.loan_code,13,1) product, substr(m.loan_code,1,1) type  from bhbfcflat1819.loan_mas m where m.loc_code=p_office)loop          
               bhbfcflat1819.yr_end_calculation_proc_half.yr_end_select_data(p_fin_year,p_office,idx.product,idx.type,'0000000000000','99999999999999');
       end loop; 
       commit;
        /*         Run Year End Classification Process for a branch          */
       for idx in(select distinct substr(m.loan_code,13,1) product, substr(m.loan_code,1,1) type  from bhbfcflat1819.loan_mas m where m.loc_code=p_office)loop          
               bhbfcflat1819.half_yr_classification.Ln_Class_Select_Data(p_fin_year,p_office,idx.product,idx.type,'0000000000000','99999999999999');
               DBMS_OUTPUT.ENABLE (buffer_size => NULL);
       end loop; 
       commit;   
       
       /*         check exist for all account in loan-ledger statement        */
      select count(*) into V_acc from (
       SELECT LOAN_MAS.loan_code FROM bhbfcflat1819.LOAN_MAS  WHERE LOAN_MAS.loan_active='Y' and loc_code=p_office 
            minus  
      select distinct b.loan_code from bhbfcflat1819.tmp_rpt_bal  b where b.loc_code=p_office);
      
     if V_acc<>0 then 
           raise v_loan_ledger_exception;
     end if;
  
  exception 
    when v_duplicate_bf_exception then
        dbms_output.put_line('Duplicate BF Correction is given-'||p_office);
    when v_loan_ledger_exception then
        dbms_output.put_line('All account is not posting for -'||p_office);   
    when v_beg_of_month_Exception then   
        dbms_output.put_line('Beg of month is not run for account -'||p_office); 
    when v_memo_exist_exception then 
        dbms_output.put_line('All memo is not posting to recipt from tmp_recipt -'||p_office); 
    when v_account_drop_exception then 
        dbms_output.put_line('Account Drop exist, Please run account drop process -'||p_office);   
    when v_memo_error_exception   then
        dbms_output.put_line('Error Exist in memo Data, Please validate it -'||p_office);                                                               
end  Closing_half_yr;







begin
  null;
end ClosingProcess;
/
