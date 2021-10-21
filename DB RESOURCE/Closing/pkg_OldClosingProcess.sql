create or replace package pkg_ClosingProcess is
procedure sp_yr_end_closing(p_fin_year in varchar2 ,p_office_code in varchar2,p_period in varchar2,p_error out varchar2);
  -- Author  : Mosharraf Hossain Talukder
  -- Created : 16-Aug-20 2:43:05 PM
  -- Purpose :
procedure sp_data_posting(p_fin_year varchar2, p_office    varchar2);
procedure sp_half_yr_end_closing(p_fin_year in varchar2 ,p_office_code in varchar2,p_period in varchar2,p_error out varchar2);

end pkg_ClosingProcess;
/
create or replace package body pkg_ClosingProcess is

procedure sp_data_posting(p_fin_year varchar2, p_office    varchar2) is
begin
 for idx in(select distinct substr(m.loan_code,1,1) type  from bhbfc1819.loan_mas m where m.loc_code=p_office)loop          
  bhbfc1819.lm_yr_end_posting.data_posting(p_fin_year,p_office,idx.type,'0000000000000','99999999999999');
end loop;                    
end sp_data_posting;



procedure sp_yr_end_closing(p_fin_year in varchar2 ,p_office_code in varchar2,p_period in varchar2,p_error out varchar2)is
begin
       --bhbfc1819.generate_actual_loc_code_new(p_period);
        delete from bhbfc1819.beg_of_month where loc_code=p_office_code; 
        delete from bhbfc1819.tmp_rpt_bal where  loc_code=p_office_code;  
        delete from bhbfc1819.rpt_to_date where  loc_code=p_office_code; 
        commit;
       for idx in(select distinct  substr(m.loan_code,1,1) type  from bhbfc1819.loan_mas m where m.loc_code=p_office_code)loop
           bhbfc1819.lm_memo_validation_process.data_validation (p_office_code,p_period,'','',idx.type,'','','','AP');
           DBMS_OUTPUT.ENABLE (buffer_size => NULL);
       end loop;
       bhbfc1819.lm_month_beg_process.Month_Beg_proc_Start(p_office_code,'','','',p_period);
       DBMS_OUTPUT.ENABLE (buffer_size => NULL);
       
       for idx in(select distinct substr(m.loan_code,1,1) type  from bhbfc1819.loan_mas m where m.loc_code=p_office_code)loop
               bhbfc1819.yr_end_calculation_process.yr_end_select_data(p_fin_year,p_office_code,idx.type,'0000000000000','99999999999999');
       DBMS_OUTPUT.ENABLE (buffer_size => NULL);
       commit;
       end loop;
       DBMS_OUTPUT.ENABLE (buffer_size => NULL);
       /*for idx in(select distinct substr(m.loan_code,1,1) type  from loan_mas m where m.loc_code=p_office_code)loop
               bhbfc1819.yr_end_ln_classification.Ln_Class_Select_Data(p_fin_year,p_office_code,idx.type,'0000000000000','99999999999999');
       end loop;*/
exception when others then
           p_error:='Error in sp_yr_end_closing ->'||sqlerrm;
end sp_yr_end_closing;


procedure sp_half_yr_end_closing(p_fin_year in varchar2 ,p_office_code in varchar2,p_period in varchar2,p_error out varchar2)is
begin
       --bhbfc1819.generate_actual_loc_code_new(p_period);
        delete from bhbfc1819.beg_of_month where loc_code=p_office_code; 
        delete from bhbfc1819.tmp_rpt_bal where  loc_code=p_office_code;  
        delete from bhbfc1819.rpt_to_date where  loc_code=p_office_code; 
        commit;
       for idx in(select distinct  substr(m.loan_code,1,1) type  from bhbfc1819.loan_mas m where m.loc_code=p_office_code)loop
           bhbfc1819.lm_memo_validation_process.data_validation (p_office_code,p_period,'','',idx.type,'','','','AP');
           DBMS_OUTPUT.ENABLE (buffer_size => NULL);
       end loop;
       bhbfc1819.lm_month_beg_process.Month_Beg_proc_Start(p_office_code,'','','',p_period);
       DBMS_OUTPUT.ENABLE (buffer_size => NULL);
       
       for idx in(select distinct substr(m.loan_code,1,1) type  from bhbfc1819.loan_mas m where m.loc_code=p_office_code)loop
       --bhbfc1819.yr_end_calculation_process.yr_end_select_data(p_fin_year,p_office_code,idx.type,'0000000000000','99999999999999');       
       bhbfc1819.uptodt_psnl_ldgr_proc_safkat.updt_ldgr_select_data(p_period,'2019-2020',null,p_period,idx.type,'0000000000000','99999999999999');  
       DBMS_OUTPUT.ENABLE (buffer_size => NULL);
       commit;
       end loop;
       DBMS_OUTPUT.ENABLE (buffer_size => NULL);
       for idx in(select distinct substr(m.loan_code,1,1) type  from loan_mas m where m.loc_code=p_office_code)loop
              -- bhbfc1819.yr_end_ln_classification.Ln_Class_Select_Data(p_fin_year,p_office_code,idx.type,'0000000000000','99999999999999');
       bhbfc1819.HALF_YR_Classification.Ln_Class_Select_Data(p_fin_year,p_office_code,idx.type,'0000000000000','99999999999999');
       end loop;
exception when others then
           p_error:='Error in sp_yr_end_closing ->'||sqlerrm;
end sp_half_yr_end_closing;

begin
  null;
end pkg_ClosingProcess;
/
