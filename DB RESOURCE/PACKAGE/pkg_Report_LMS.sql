create or replace package pkg_Report_LMS is

  type rec_data is record(
    product_nature varchar2(10),
    loc_code       varchar2(10),
    loc_name       varchar2(50),
    cl_account     number(10),
    cl_balance     number(18, 6),
    uc_account     number(10),
    uc_balance     number(18, 6),
    cl_overdue     number(18, 6),
    uc_overdue     number(18, 6),
    cl_falldue     number(18, 6),
    uc_falldue     number(18, 6),
    cl_recovery    number(18, 6),
    uc_recovery    number(18, 6));

  type v_data is table of rec_data;

  function fn_loan_recovery_data(p_fin_year    in varchar2,
                                 p_branch_code in varchar2) return v_data
    pipelined;

  type expired_loan is record(
    product_nature varchar2(10),
    LOC_CODE       varchar2(10),
    loc_name       varchar2(50),
    LOAN_CODE      varchar2(13),
    NAME1          varchar2(100),
    SANC_DATE      date,
    SANC_AMT       number(18, 6),
    INT_RATE       number(5, 2),
    REPAY_DATE     date,
    LOAN_PERIOD    number(5));
  type v_expired_loan is table of expired_loan;
  function fn_loan_expired_data(p_fin_year    in varchar2,
                                p_branch_code in varchar2)
    return v_expired_loan
    pipelined;

end pkg_Report_LMS;
/
create or replace package body pkg_Report_LMS is
  function fn_loan_expired_data(p_fin_year    in varchar2,
                                p_branch_code in varchar2)
    return v_expired_loan
    pipelined is
    w_expired_loan expired_loan;
  begin    
    select  m.brn_name into w_expired_loan.loc_name 
                 from prms_mbranch m
                where m.bran_cat_code = 'B'
                  and m.brn_code =p_branch_code;
    w_expired_loan.product_nature:='OLD';
    for idx in (SELECT LOC_CODE,           
                       LOAN_CODE,
                       NAME1,
                       SANC_DATE,
                       SANC_AMT,
                       INT_RATE,
                       repay_date,
                       loan_period
                  FROM loan_mas@olddb m
                 where m.loc_code = p_branch_code
                   and ADD_MONTHS(m.repay_date, m.loan_period) between
                       '01-jul-'||substr(p_fin_year,1,4) and '30-jun-'||substr(p_fin_year,6,4)
                   and m.loan_active = 'Y') loop
                   
         w_expired_loan.LOC_CODE:=idx.loc_code;  
         w_expired_loan.LOAN_CODE:=idx.LOAN_CODE;
         w_expired_loan.NAME1:=idx.NAME1;
         w_expired_loan.SANC_DATE:=idx.SANC_DATE;
         w_expired_loan.SANC_AMT:=idx.SANC_AMT;
         w_expired_loan.INT_RATE:=idx.INT_RATE;
         w_expired_loan.REPAY_DATE:=idx.REPAY_DATE;
         w_expired_loan.LOAN_PERIOD:= idx.LOAN_PERIOD  ;   
         pipe row(w_expired_loan);      
    end loop;  
    
    w_expired_loan.product_nature:='EMI';
    for idx in (SELECT LOC_CODE,           
                       LOAN_CODE,
                       NAME1,
                       SANC_DATE,
                       SANC_AMT,
                       INT_RATE,
                       repay_date,
                       loan_period
                  FROM loan_mas@emidb m
                 where m.loc_code = p_branch_code
                   and ADD_MONTHS(m.repay_date, m.loan_period) between
                       '01-jul-'||substr(p_fin_year,1,4) and '30-jun-'||substr(p_fin_year,6,4)
                   and m.loan_active = 'Y') loop
                   
         w_expired_loan.LOC_CODE:=idx.loc_code;  
         w_expired_loan.LOAN_CODE:=idx.LOAN_CODE;
         w_expired_loan.NAME1:=idx.NAME1;
         w_expired_loan.SANC_DATE:=idx.SANC_DATE;
         w_expired_loan.SANC_AMT:=idx.SANC_AMT;
         w_expired_loan.INT_RATE:=idx.INT_RATE;
         w_expired_loan.REPAY_DATE:=idx.REPAY_DATE;
         w_expired_loan.LOAN_PERIOD:= idx.LOAN_PERIOD  ;   
         pipe row(w_expired_loan);      
    end loop;  
    
  end fn_loan_expired_data;

  function fn_loan_recovery_data(p_fin_year    in varchar2,
                                 p_branch_code in varchar2) return v_data
    pipelined is
    w_data rec_data;
  
  begin
    for id in (select *
                 from prms_mbranch m
                where m.bran_cat_code = 'B'
                  and m.brn_code like p_branch_code) loop
      w_data.product_nature := 'OCR';
      w_data.loc_code       := id.brn_code;
      w_data.loc_name       := id.brn_name;
      pkg_lms_report.sp_loan_recovery_data@ocrdb(p_fin_year,
                                                 id.brn_code,
                                                 w_data.cl_balance,
                                                 w_data.uc_balance,
                                                 w_data.cl_overdue,
                                                 w_data.uc_overdue,
                                                 w_data.cl_falldue,
                                                 w_data.uc_falldue,
                                                 w_data.cl_recovery,
                                                 w_data.uc_recovery,
                                                 w_data.cl_account,
                                                 w_data.uc_account);
      pipe row(w_data);
    
    end loop;
    for id in (select *
                 from prms_mbranch m
                where m.bran_cat_code = 'B'
                  and m.brn_code like p_branch_code) loop
      w_data.product_nature := 'EMI';
      w_data.loc_code       := id.brn_code;
      w_data.loc_name       := id.brn_name;
      pkg_lms_report.sp_loan_recovery_data@emidb(p_fin_year,
                                                 id.brn_code,
                                                 w_data.cl_balance,
                                                 w_data.uc_balance,
                                                 w_data.cl_overdue,
                                                 w_data.uc_overdue,
                                                 w_data.cl_falldue,
                                                 w_data.uc_falldue,
                                                 w_data.cl_recovery,
                                                 w_data.uc_recovery,
                                                 w_data.cl_account,
                                                 w_data.uc_account);
      pipe row(w_data);
    end loop;
    for id in (select *
                 from prms_mbranch m
                where m.bran_cat_code = 'B'
                  and m.brn_code like p_branch_code) loop
      w_data.product_nature := 'ISF';
      w_data.loc_code       := id.brn_code;
      w_data.loc_name       := id.brn_name;
      pkg_lms_report.sp_loan_recovery_data@isfdb(p_fin_year,
                                                 id.brn_code,
                                                 w_data.cl_balance,
                                                 w_data.uc_balance,
                                                 w_data.cl_overdue,
                                                 w_data.uc_overdue,
                                                 w_data.cl_falldue,
                                                 w_data.uc_falldue,
                                                 w_data.cl_recovery,
                                                 w_data.uc_recovery,
                                                 w_data.cl_account,
                                                 w_data.uc_account);
      pipe row(w_data);
    end loop;
    for id in (select *
                 from prms_mbranch m
                where m.bran_cat_code = 'B'
                  and m.brn_code like p_branch_code) loop
      w_data.product_nature := 'OLD';
      w_data.loc_code       := id.brn_code;
      w_data.loc_name       := id.brn_name;
      pkg_lms_report.sp_loan_recovery_data@olddb(p_fin_year,
                                                 id.brn_code,
                                                 w_data.cl_balance,
                                                 w_data.uc_balance,
                                                 w_data.cl_overdue,
                                                 w_data.uc_overdue,
                                                 w_data.cl_falldue,
                                                 w_data.uc_falldue,
                                                 w_data.cl_recovery,
                                                 w_data.uc_recovery,
                                                 w_data.cl_account,
                                                 w_data.uc_account);
      pipe row(w_data);
    
    end loop;
    for id in (select *
                 from prms_mbranch m
                where m.bran_cat_code = 'B'
                  and m.brn_code like p_branch_code) loop
      w_data.product_nature := 'GOV';
      w_data.loc_code       := id.brn_code;
      w_data.loc_name       := id.brn_name;
      pkg_lms_report.sp_loan_recovery_data@govdb(p_fin_year,
                                                 id.brn_code,
                                                 w_data.cl_balance,
                                                 w_data.uc_balance,
                                                 w_data.cl_overdue,
                                                 w_data.uc_overdue,
                                                 w_data.cl_falldue,
                                                 w_data.uc_falldue,
                                                 w_data.cl_recovery,
                                                 w_data.uc_recovery,
                                                 w_data.cl_account,
                                                 w_data.uc_account);
      pipe row(w_data);
    
    end loop;
  
  end fn_loan_recovery_data;

begin
  null;
end pkg_Report_LMS;
/
