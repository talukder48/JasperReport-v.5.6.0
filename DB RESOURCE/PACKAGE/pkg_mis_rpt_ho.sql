create or replace package pkg_mis_rpt_ho is
  type recovery is record(
    target_description varchar2(100),
    ZONAL_OFFICE       varchar2(10),
    ZONAL_OFFICE_name  varchar2(50),
    BRANCH_CODE        varchar2(10),
    BRANCH_NAME        varchar2(50),
    TARGET_UC          number(18, 2),
    TARGET_CL          number(18, 2),
    CL_RECOVERY        number(18, 2),
    UC_RECOVERY        number(18, 2),
    UC_RECOVERY_PCT    number(12, 2),
    CL_RECOVERY_PCT    number(12, 2));
  type v_recovery is table of recovery;
  function fn_get_recovery_data(p_target_code in varchar2) return v_recovery
    pipelined;

  type Audit is record(
    target_description    varchar2(100),
    ZONAL_OFFICE          varchar2(10),
    ZONAL_OFFICE_name     varchar2(50),
    BRANCH_CODE           varchar2(10),
    BRANCH_NAME           varchar2(50),
    TARGET_COMMERTIAL     number(10),
    TARGET_POST_AUDIT     number(10),
    ACHIVE_COMMERTIAL     number(10),
    ACHIVE_POST_AUDIT     number(10),
    ACHIVE_COMMERTIAL_PCT number(12, 2),
    ACHIVE_POST_AUDIT_PCT number(12, 2));
  type v_Audit is table of Audit;
  function fn_get_AUDIT_data(p_target_code in varchar2) return v_Audit
    pipelined;

  type DeedReturn is record(
    target_description    varchar2(100),
    ZONAL_OFFICE          varchar2(10),
    ZONAL_OFFICE_name     varchar2(50),
    BRANCH_CODE           varchar2(10),
    BRANCH_NAME           varchar2(50),
    TARGET_DeedReturn     number(10),
    ACHIVE_DeedReturn     number(10),
    ACHIVE_DeedReturn_PCT number(12, 2));
  type v_DeedReturn is table of DeedReturn;
  function fn_get_deedreturn_data(p_target_code in varchar2)
    return v_DeedReturn
    pipelined;

  type kharidabari is record(
    target_description   varchar2(100),
    ZONAL_OFFICE         varchar2(10),
    ZONAL_OFFICE_name    varchar2(50),
    BRANCH_CODE          varchar2(10),
    BRANCH_NAME          varchar2(50),
    TARGET_possesion     number(10),
    TARGET_sale          number(10),
    ACHIVE_possesion     number(10),
    ACHIVE_sale          number(10),
    ACHIVE_possesion_PCT number(12, 2),
    ACHIVE_sale_PCT      number(12, 2));
  type v_kharidabari is table of kharidabari;

  function fn_get_kharidabari_data(p_target_code in varchar2)
    return v_kharidabari
    pipelined;

  type courtcase is record(
    target_description    varchar2(100),
    ZONAL_OFFICE          varchar2(10),
    ZONAL_OFFICE_name     varchar2(50),
    BRANCH_CODE           varchar2(10),
    BRANCH_NAME           varchar2(50),
    TARGET_misc           number(10),
    TARGET_execution      number(10),
    ACHIVE_misc           number(10),
    ACHIVE_execution      number(10),
    ACHIVE_misc_PCT       number(12, 2),
    ACHIVE_execution_PCT  number(12, 2),
    target_high_court     number(10),
    achive_high_court     number(10),
    achive_high_court_pct number(12, 2));
  type v_courtcase is table of courtcase;
  function fn_get_courtcase_data(p_target_code in varchar2)
    return v_courtcase
    pipelined;

  type Loan is record(
    target_description   varchar2(100),
    ZONAL_OFFICE         varchar2(10),
    ZONAL_OFFICE_name    varchar2(50),
    BRANCH_CODE          varchar2(10),
    BRANCH_NAME          varchar2(50),
    TARGET_LOAN_SANC     number(18, 2),
    TARGET_LOAN_DISB     number(18, 2),
    ACHIVE_LOAN_SANC     number(18, 2),
    ACHIVE_LOAN_DISB     number(18, 2),
    ACHIVE_LOAN_SANC_PCT number(12, 2),
    ACHIVE_LOAN_DISB_PCT number(12, 2));
  type v_Loan is table of Loan;

  type Loan_details is record(
    target_description         varchar2(100),
    ZONAL_OFFICE               varchar2(10),
    ZONAL_OFFICE_name          varchar2(50),
    BRANCH_CODE                varchar2(10),
    BRANCH_NAME                varchar2(50),
    TARGET_LOAN_SANC_zero      number(18, 2),
    TARGET_LOAN_SANC_other     number(18, 2),
    TARGET_LOAN_DISB_zero      number(18, 2),
    TARGET_LOAN_DISB_gov       number(18, 2),
    TARGET_LOAN_DISB_other     number(18, 2),
    ACHIVE_LOAN_SANC_zero      number(18, 2),
    ACHIVE_LOAN_SANC_other     number(18, 2),
    ACHIVE_LOAN_DISB_zero      number(18, 2),
    ACHIVE_LOAN_DISB_gov       number(18, 2),
    ACHIVE_LOAN_DISB_other     number(18, 2),
    ACHIVE_LOAN_SANC_PCT_zero  number(12, 2),
    ACHIVE_LOAN_SANC_PCT_other number(12, 2),
    ACHIVE_LOAN_DISB_PCT_zero  number(12, 2),
    ACHIVE_LOAN_DISB_PCT_gov   number(12, 2),
    ACHIVE_LOAN_DISB_PCT_other number(12, 2));
  type v_Loan_details is table of Loan_details;
  function fn_get_LOAN_details_data(p_target_code in varchar2)
    return v_Loan_details
    pipelined;
  function fn_get_LOAN_data(p_target_code in varchar2) return v_Loan
    pipelined;
  type performance is record(
    title_desc              varchar2(50),
    Target_description      varchar2(100),
    performance_description varchar2(100),
    BRANCH_CODE             varchar2(10),
    BRANCH_NAME             varchar2(50),
    Target                  number(18, 2),
    Acheivment              number(18, 2),
    Acheivment_PCT          number(12, 2));
  type v_performance is table of performance;
  function fn_get_performance_data(performance_type in varchar2,
                                   p_target_code    in varchar2,
                                   p_report_type    in varchar2)
    return v_performance
    pipelined;
  function get_targetFactor(p_target_code in varchar2) return number;
end pkg_mis_rpt_ho;
/
create or replace package body pkg_mis_rpt_ho is

  function get_targetFactor(p_target_code in varchar2) return number is
    V_FACTOR      NUMBER := 0;
    v_PARENT_code varchar2(10) := '';
  begin
  
    SELECT m.parent_code
      into v_PARENT_code
      FROM target_master m
     where m.target_code = p_target_code;
  
    IF v_PARENT_code IS NULL THEN
      V_FACTOR := 1;
    ELSE
      SELECT ROUND((SELECT m.end_date - m.start_date + 1
                      FROM target_master m
                     where m.target_code = p_target_code) /
                   (SELECT m.end_date - m.start_date + 1
                      FROM target_master m
                     where m.target_code = v_PARENT_code),
                   2) PCT
        INTO V_FACTOR
        FROM DUAL;
    
    END IF;
    return V_FACTOR;
  end get_targetFactor;

  function fn_get_courtcase_data(p_target_code in varchar2)
    return v_courtcase
    pipelined is
    w_courtcase courtcase;
    v_from_date date;
    v_to_date   date;
  begin
  
    SELECT m.start_date, m.end_date, m.target_description||'( From Date: '||to_char(m.start_date,'DD/MM/YYYY')||' To Date: '||to_char(m.end_date,'DD/MM/YYYY')||')'
      into v_from_date, v_to_date, w_courtcase.target_description
      FROM target_master m
     where m.target_code = p_target_code;
  
    for idx in (SELECT * FROM zonal_branch_mapping) loop
    
      w_courtcase.ZONAL_OFFICE := idx.zonal_off_code;
    
      SELECT m.brn_name
        into w_courtcase.ZONAL_OFFICE_name
        FROM prms_mbranch m
       where m.brn_code = idx.zonal_off_code;
    
      w_courtcase.BRANCH_CODE := idx.branch_off_code;
      SELECT m.brn_name
        into w_courtcase.BRANCH_NAME
        FROM prms_mbranch m
       where m.brn_code = idx.branch_off_code;
      begin
      
        SELECT g.settle_writ_case,
               g.settle_executive_case,
               misc_cse,
               executive_case,
               case g.settle_writ_case
                 when 0 then
                  0
                 else
                  round(misc_cse / g.settle_writ_case * 100, 2)
               end misc_pct,
               case settle_executive_case
                 when 0 then
                  0
                 else
                  round(executive_case / settle_executive_case * 100, 2)
               end ex_pct
          into w_courtcase.TARGET_misc,
               w_courtcase.TARGET_execution,
               w_courtcase.ACHIVE_misc,
               w_courtcase.ACHIVE_execution,
               w_courtcase.ACHIVE_misc_PCT,
               w_courtcase.ACHIVE_execution_PCT
          FROM mis_goal_setup g
          join (SELECT d.branch_code,
                       sum(d.misc_cse) misc_cse,
                       sum(d.executive_case) executive_case
                  FROM mis_court_case_settle d
                 where d.entry_date between v_from_date and v_to_date
                 group by branch_code) kk
            on (kk.branch_code = g.branch_code)
         where g.target_code = 'FY21-22'
           and g.branch_code = idx.branch_off_code;
      
      exception
        when others then
          w_courtcase.TARGET_misc          := 0;
          w_courtcase.TARGET_execution     := 0;
          w_courtcase.ACHIVE_misc          := 0;
          w_courtcase.ACHIVE_execution     := 0;
          w_courtcase.ACHIVE_misc_PCT      := 0;
          w_courtcase.ACHIVE_execution_PCT := 0;
        
      end;
      pipe row(w_courtcase);
    end loop;
  
  end fn_get_courtcase_data;

  function fn_get_kharidabari_data(p_target_code in varchar2)
    return v_kharidabari
    pipelined is
    w_kharidabari kharidabari;
    v_from_date   date;
    v_to_date     date;
  begin
  
    SELECT m.start_date, m.end_date, m.target_description||'( From Date: '||to_char(m.start_date,'DD/MM/YYYY')||' To Date: '||to_char(m.end_date,'DD/MM/YYYY')||')'
      into v_from_date, v_to_date, w_kharidabari.target_description
      FROM target_master m
     where m.target_code = p_target_code;
  
    for idx in (SELECT * FROM zonal_branch_mapping) loop
    
      w_kharidabari.ZONAL_OFFICE := idx.zonal_off_code;
    
      SELECT m.brn_name
        into w_kharidabari.ZONAL_OFFICE_name
        FROM prms_mbranch m
       where m.brn_code = idx.zonal_off_code;
    
      w_kharidabari.BRANCH_CODE := idx.branch_off_code;
      SELECT m.brn_name
        into w_kharidabari.BRANCH_NAME
        FROM prms_mbranch m
       where m.brn_code = idx.branch_off_code;
    
      begin
        SELECT g.kharidabari_procession,
               G.KHARIDABARI_SALE,
               procession_ACHIEVMENT,
               sale_ACHIEVMENT,
               CASE kharidabari_procession
                 WHEN 0 THEN
                  0
                 ELSE
                  ROUND(procession_ACHIEVMENT / kharidabari_procession * 100,
                        2)
               END possesion_PCT,
               CASE KHARIDABARI_SALE
                 WHEN 0 THEN
                  0
                 ELSE
                  ROUND(sale_ACHIEVMENT / KHARIDABARI_SALE * 100, 2)
               END sale_PCT
          into w_kharidabari.TARGET_possesion,
               w_kharidabari.TARGET_sale,
               w_kharidabari.ACHIVE_possesion,
               w_kharidabari.ACHIVE_sale,
               w_kharidabari.ACHIVE_possesion_PCT,
               w_kharidabari.ACHIVE_sale_PCT
          FROM mis_goal_setup g
          JOIN
        
         (SELECT D.BRANCH_CODE,
                 sum(d.procession) procession_ACHIEVMENT,
                 sum(d.sale) sale_ACHIEVMENT
            FROM mis_kharidabari d
           where d.entry_date between v_from_date and v_to_date
           GROUP BY D.BRANCH_CODE) KK
            ON (KK.branch_code = G.BRANCH_CODE)
         where g.target_code = 'FY21-22'
           and g.branch_code = idx.branch_off_code;
      
      exception
        when others then
          w_kharidabari.TARGET_possesion     := 0;
          w_kharidabari.TARGET_sale          := 0;
          w_kharidabari.ACHIVE_possesion     := 0;
          w_kharidabari.ACHIVE_sale          := 0;
          w_kharidabari.ACHIVE_possesion_PCT := 0;
          w_kharidabari.ACHIVE_sale_PCT      := 0;
        
      end;
      pipe row(w_kharidabari);
    end loop;
  end fn_get_kharidabari_data;

  function fn_get_deedreturn_data(p_target_code in varchar2)
    return v_DeedReturn
    pipelined is
    w_DeedReturn DeedReturn;
    v_from_date  date;
    v_to_date    date;
  begin
  
    SELECT m.start_date, m.end_date, m.target_description||'( From Date: '||to_char(m.start_date,'DD/MM/YYYY')||' To Date: '||to_char(m.end_date,'DD/MM/YYYY')||')'
      into v_from_date, v_to_date, w_DeedReturn.target_description
      FROM target_master m
     where m.target_code = p_target_code;
  
    for idx in (SELECT * FROM zonal_branch_mapping) loop
    
      w_DeedReturn.ZONAL_OFFICE := idx.zonal_off_code;
    
      SELECT m.brn_name
        into w_DeedReturn.ZONAL_OFFICE_name
        FROM prms_mbranch m
       where m.brn_code = idx.zonal_off_code;
    
      w_DeedReturn.BRANCH_CODE := idx.branch_off_code;
      SELECT m.brn_name
        into w_DeedReturn.BRANCH_NAME
        FROM prms_mbranch m
       where m.brn_code = idx.branch_off_code;
    
      begin
        SELECT TARGET,
               ACHIVE,
               case TARGET
                 when 0 then
                  0
                 else
                  round(ACHIVE / TARGET * 100, 2)
               end pct
          into w_DeedReturn.TARGET_DeedReturn,
               w_DeedReturn.ACHIVE_DeedReturn,
               w_DeedReturn.ACHIVE_DeedReturn_PCT
          FROM (SELECT g.deed_return_fl target,
                       (SELECT sum(l.loan_account_no)
                          FROM mis_faulty_ln_case l
                         where l.branch_code = g.branch_code
                           and l.entry_date between v_from_date and v_to_date) achive
                  FROM mis_goal_setup g
                 where g.target_code = 'FY21-22'
                   and g.branch_code = idx.branch_off_code);
      
      exception
        when others then
          w_DeedReturn.TARGET_DeedReturn     := 0;
          w_DeedReturn.ACHIVE_DeedReturn     := 0;
          w_DeedReturn.ACHIVE_DeedReturn_PCT := 0;
      end;
      pipe row(w_DeedReturn);
    end loop;
  
  end fn_get_deedreturn_data;

  function fn_get_AUDIT_data(p_target_code in varchar2) return v_Audit
    pipelined is
    w_Audit     Audit;
    v_from_date date;
    v_to_date   date;
  begin
  
    SELECT m.start_date, m.end_date, m.target_description||'( From Date: '||to_char(m.start_date,'DD/MM/YYYY')||' To Date: '||to_char(m.end_date,'DD/MM/YYYY')||')'
      into v_from_date, v_to_date, w_Audit.target_description
      FROM target_master m
     where m.target_code = p_target_code;
  
    for idx in (SELECT * FROM zonal_branch_mapping) loop
    
      w_Audit.ZONAL_OFFICE := idx.zonal_off_code;
    
      SELECT m.brn_name
        into w_Audit.ZONAL_OFFICE_name
        FROM prms_mbranch m
       where m.brn_code = idx.zonal_off_code;
    
      w_Audit.BRANCH_CODE := idx.branch_off_code;
      SELECT m.brn_name
        into w_Audit.BRANCH_NAME
        FROM prms_mbranch m
       where m.brn_code = idx.branch_off_code;
    
      begin
        SELECT g.audit_commercial,
               G.AUDIT_POST_AUDIT,
               commercial_ACHIEVMENT,
               POST_ACHIEVMENT,
               CASE audit_commercial
                 WHEN 0 THEN
                  0
                 ELSE
                  ROUND(commercial_ACHIEVMENT / audit_commercial * 100, 2)
               END COMM_PCT,
               CASE AUDIT_POST_AUDIT
                 WHEN 0 THEN
                  0
                 ELSE
                  ROUND(POST_ACHIEVMENT / AUDIT_POST_AUDIT * 100, 2)
               END POST_PCT
          into w_Audit.TARGET_COMMERTIAL,
               w_Audit.TARGET_POST_AUDIT,
               w_Audit.ACHIVE_COMMERTIAL,
               w_Audit.ACHIVE_POST_AUDIT,
               w_Audit.ACHIVE_COMMERTIAL_PCT,
               w_Audit.ACHIVE_POST_AUDIT_PCT
        
          FROM mis_goal_setup g
          JOIN
        
         (SELECT D.BRANCH_CODE,
                 sum(d.commercial_obj) commercial_ACHIEVMENT,
                 sum(d.audit_obj) POST_ACHIEVMENT
            FROM MIS_AUDIT_OB_DISPOSAL d
           where d.entry_date between v_from_date and v_to_date
           GROUP BY D.BRANCH_CODE) KK
            ON (KK.branch_code = G.BRANCH_CODE)
         where g.target_code = p_target_code
           and g.branch_code = idx.branch_off_code;
      
      exception
        when others then
          w_Audit.TARGET_COMMERTIAL     := 0;
          w_Audit.TARGET_POST_AUDIT     := 0;
          w_Audit.ACHIVE_COMMERTIAL     := 0;
          w_Audit.ACHIVE_POST_AUDIT     := 0;
          w_Audit.ACHIVE_COMMERTIAL_PCT := 0;
          w_Audit.ACHIVE_POST_AUDIT_PCT := 0;
        
      end;
      pipe row(w_Audit);
    end loop;
  
  end fn_get_AUDIT_data;

  function fn_get_recovery_data(p_target_code in varchar2) return v_recovery
    pipelined is
    w_recovery    recovery;
    v_from_date   date;
    v_to_date     date;
    V_FACTOR      NUMBER := 0;
    v_target_code varchar2(10) := '';
    v_PARENT_code varchar2(10) := '';
  begin
    V_FACTOR := get_targetFactor(p_target_code);
    SELECT m.parent_code
      into v_PARENT_code
      FROM target_master m
     where m.target_code = p_target_code;
  
    IF v_PARENT_code IS NULL THEN
      v_target_code := p_target_code;
    ELSE
      v_target_code := v_PARENT_code;
    end if;
  
    SELECT m.start_date, m.end_date, m.target_description||'( From Date: '||to_char(m.start_date,'DD/MM/YYYY')||' To Date: '||to_char(m.end_date,'DD/MM/YYYY')||')'
      into v_from_date, v_to_date, w_recovery.target_description
      FROM target_master m
     where m.target_code = p_target_code;
  
    for idx in (SELECT * FROM zonal_branch_mapping) loop
    
      w_recovery.ZONAL_OFFICE := idx.zonal_off_code;
    
      SELECT m.brn_name
        into w_recovery.ZONAL_OFFICE_name
        FROM prms_mbranch m
       where m.brn_code = idx.zonal_off_code;
    
      w_recovery.BRANCH_CODE := idx.branch_off_code;
      SELECT m.brn_name
        into w_recovery.BRANCH_NAME
        FROM prms_mbranch m
       where m.brn_code = idx.branch_off_code;
    
      SELECT m.loan_uc_recovery * V_FACTOR / 10000000,
             m.loan_cl_recovery * V_FACTOR / 10000000
        into w_recovery.TARGET_UC, w_recovery.TARGET_CL
        FROM mis_goal_setup m
       where m.target_code = v_target_code
         and m.branch_code = idx.branch_off_code;
    
      begin
        SELECT round(uc_recovery_amt / 10000000, 2) uc_recovery_amt,
               round(cl_recovery_amt / 10000000, 2) cl_recovery_amt,
               round(case g.loan_uc_recovery
                       when 0 then
                        0
                       else
                        d.uc_recovery_amt /( g.loan_uc_recovery * V_FACTOR) * 100
                     end,
                     2) loan_uc_recovery_pct,
               
               round(case g.loan_cl_recovery
                       when 0 then
                        0
                       else
                        d.cl_recovery_amt / (g.loan_cl_recovery * V_FACTOR) * 100
                     end,
                     2) loan_cl_recovery_pct
          into w_recovery.UC_RECOVERY,
               w_recovery.CL_RECOVERY,
               w_recovery.UC_RECOVERY_PCT,
               w_recovery.CL_RECOVERY_PCT
        
          FROM mis_goal_setup g
          join
        
         (SELECT branch_code,
                 sum(d.cl_recovery_amt) cl_recovery_amt,
                 sum(d.uc_recovery_amt) uc_recovery_amt
            FROM mis_loan_recovery d
           where d.entry_date between v_from_date and v_to_date
           group by d.branch_code) d
            on (d.branch_code = g.branch_code)
         where g.target_code = v_target_code
           and g.branch_code = idx.branch_off_code;
      exception
        when others then
          w_recovery.UC_RECOVERY     := 0;
          w_recovery.CL_RECOVERY     := 0;
          w_recovery.UC_RECOVERY_PCT := 0;
          w_recovery.CL_RECOVERY_PCT := 0;
        
      end;
      pipe row(w_recovery);
    end loop;
  
  end fn_get_recovery_data;

  function fn_get_LOAN_data(p_target_code in varchar2) return v_Loan
    pipelined is
    W_Loan        Loan;
    v_from_date   date;
    v_to_date     date;
    V_FACTOR      NUMBER := 0;
    v_target_code varchar2(10) := '';
    v_PARENT_code varchar2(10) := '';
  begin
    V_FACTOR := get_targetFactor(p_target_code);
    SELECT m.parent_code
      into v_PARENT_code
      FROM target_master m
     where m.target_code = p_target_code;
  
    IF v_PARENT_code IS NULL THEN
      v_target_code := p_target_code;
    ELSE
      v_target_code := v_PARENT_code;
    end if;
  
    SELECT m.start_date, m.end_date, m.target_description||'( From Date: '||to_char(m.start_date,'DD/MM/YYYY')||' To Date: '||to_char(m.end_date,'DD/MM/YYYY')||')'
      into v_from_date, v_to_date, W_Loan.target_description
      FROM target_master m
     where m.target_code = p_target_code;
  
    for idx in (SELECT * FROM zonal_branch_mapping) loop
    
      W_Loan.ZONAL_OFFICE := idx.zonal_off_code;
    
      SELECT m.brn_name
        into W_Loan.ZONAL_OFFICE_name
        FROM prms_mbranch m
       where m.brn_code = idx.zonal_off_code;
    
      W_Loan.BRANCH_CODE := idx.branch_off_code;
      SELECT m.brn_name
        into W_Loan.BRANCH_NAME
        FROM prms_mbranch m
       where m.brn_code = idx.branch_off_code;
    
      BEGIN
      
        SELECT (G.ZERO_EQ_SANCTION + G.OTHS_PD_SANCTION) * V_FACTOR /
               10000000 TARGET_SANC,
               
               ACHIVE_SANC / 10000000 ACHIVE_SANC,
               
               CASE G.ZERO_EQ_SANCTION + G.OTHS_PD_SANCTION
                 WHEN 0 THEN
                  0
                 ELSE
                  ACHIVE_SANC / ((G.ZERO_EQ_SANCTION + G.OTHS_PD_SANCTION) *V_FACTOR) * 100
               END SANC_PCT
        
          INTO W_Loan.TARGET_LOAN_SANC,
               W_Loan.ACHIVE_LOAN_SANC,
               W_Loan.ACHIVE_LOAN_SANC_PCT
        
          FROM mis_goal_setup g
          join (SELECT branch_code,
                       NVL(sum(d.zero_eq_sanction_amt), 0) +
                       NVL(sum(d.oth_prd_sanction_amt), 0) ACHIVE_SANC
                  FROM mis_loan_sanction d
                 where d.entry_date between v_from_date and v_to_date
                 group by d.branch_code) d
            on (d.branch_code = g.branch_code)
         where g.target_code = v_target_code
           AND G.BRANCH_CODE = IDX.BRANCH_OFF_CODE;
      
      exception
        when others then
        
          W_Loan.TARGET_LOAN_SANC     := 0;
          W_Loan.ACHIVE_LOAN_SANC     := 0;
          W_Loan.ACHIVE_LOAN_SANC_PCT := 0;
      END;
    
      begin
        SELECT (G.ZERO_EQ_DISBURSE + G.OTHS_PD_DISBURSE + g.gov_loan) *
               V_FACTOR / 10000000 TARGET_DISB,
               ACHIVE_DISBURSE / 10000000 ACHIVE_DISBURSE,
               CASE G.ZERO_EQ_DISBURSE + G.OTHS_PD_DISBURSE
                 WHEN 0 THEN
                  0
                 ELSE
                  ACHIVE_DISBURSE /
                  ((G.ZERO_EQ_DISBURSE + G.OTHS_PD_DISBURSE + g.gov_loan) *
                  V_FACTOR )* 100
               END DISB_PCT
        
          INTO W_Loan.TARGET_LOAN_DISB,
               W_Loan.ACHIVE_LOAN_DISB,
               W_Loan.ACHIVE_LOAN_DISB_PCT
        
          FROM mis_goal_setup g
          join (SELECT branch_code,
                       NVL(sum(d.zero_eq_sanction_amt), 0) +
                       NVL(sum(d.oth_prd_sanction_amt), 0) ACHIVE_SANC,
                       sum(d.zero_eq_disburse_amt) +
                       sum(d.oth_prd_disburse_amt)+ sum(d.gov_loan_disb) ACHIVE_DISBURSE
                  FROM mis_loan_sanction_disburse d
                 where d.entry_date between v_from_date and v_to_date
                 group by d.branch_code) d
            on (d.branch_code = g.branch_code)
         where g.target_code = v_target_code
           AND G.BRANCH_CODE = IDX.BRANCH_OFF_CODE;
      
      exception
        when others then
        
          W_Loan.TARGET_LOAN_DISB     := 0;
          W_Loan.ACHIVE_LOAN_DISB     := 0;
          W_Loan.ACHIVE_LOAN_DISB_PCT := 0;
        
      end;
      pipe row(W_Loan);
    end loop;
  
  end fn_get_LOAN_data;

  function fn_get_LOAN_details_data(p_target_code in varchar2)
    return v_Loan_details
    pipelined is
    W_Loan        Loan_details;
    v_from_date   date;
    v_to_date     date;
    V_FACTOR      NUMBER := 0;
    v_target_code varchar2(10) := '';
    v_PARENT_code varchar2(10) := '';
  begin
    V_FACTOR := get_targetFactor(p_target_code);
    SELECT m.parent_code
      into v_PARENT_code
      FROM target_master m
     where m.target_code = p_target_code;
  
    IF v_PARENT_code IS NULL THEN
      v_target_code := p_target_code;
    ELSE
      v_target_code := v_PARENT_code;
    end if;
  
    SELECT m.start_date, m.end_date, m.target_description||'( From Date: '||to_char(m.start_date,'DD/MM/YYYY')||' To Date: '||to_char(m.end_date,'DD/MM/YYYY')||')'
      into v_from_date, v_to_date, W_Loan.target_description
      FROM target_master m
     where m.target_code = p_target_code;
  
    for idx in (SELECT * FROM zonal_branch_mapping) loop
    
      W_Loan.ZONAL_OFFICE := idx.zonal_off_code;
    
      SELECT m.brn_name
        into W_Loan.ZONAL_OFFICE_name
        FROM prms_mbranch m
       where m.brn_code = idx.zonal_off_code;
    
      W_Loan.BRANCH_CODE := idx.branch_off_code;
      SELECT m.brn_name
        into W_Loan.BRANCH_NAME
        FROM prms_mbranch m
       where m.brn_code = idx.branch_off_code;
    
      BEGIN
      
        SELECT (G.ZERO_EQ_SANCTION) * V_FACTOR / 10000000 TARGET_SANC_zero,
               (G.OTHS_PD_SANCTION) * V_FACTOR / 10000000 ACHIVE_SANC_other,
               
               ACHIVE_SANC_Zero / 10000000 ACHIVE_SANC_Zero,
               ACHIVE_SANC_other / 10000000 ACHIVE_SANC_other,
               
               CASE G.ZERO_EQ_SANCTION
                 WHEN 0 THEN
                  0
                 ELSE
                  ACHIVE_SANC_Zero / (G.ZERO_EQ_SANCTION * V_FACTOR )* 100
               END SANC_PCT_zero,
               CASE G.OTHS_PD_SANCTION
                 WHEN 0 THEN
                  0
                 ELSE
                  ACHIVE_SANC_other /( G.OTHS_PD_SANCTION * V_FACTOR) * 100
               END SANC_PCT
        
          INTO W_Loan.TARGET_LOAN_SANC_zero,
               W_Loan.TARGET_LOAN_SANC_other,
               W_Loan.ACHIVE_LOAN_SANC_zero,
               W_Loan.ACHIVE_LOAN_SANC_other,
               W_Loan.ACHIVE_LOAN_SANC_PCT_zero,
               W_Loan.ACHIVE_LOAN_SANC_PCT_other
        
          FROM mis_goal_setup g
          join (SELECT branch_code,
                       NVL(sum(d.zero_eq_sanction_amt), 0) ACHIVE_SANC_Zero,
                       NVL(sum(d.oth_prd_sanction_amt), 0) ACHIVE_SANC_other
                  FROM mis_loan_sanction d
                 where d.entry_date between v_from_date and v_to_date
                 group by d.branch_code) d
            on (d.branch_code = g.branch_code)
         where g.target_code = v_target_code
           AND G.BRANCH_CODE = IDX.BRANCH_OFF_CODE;
      
      exception
        when others then
        
          W_Loan.TARGET_LOAN_SANC_zero      := 0;
          W_Loan.TARGET_LOAN_SANC_other     := 0;
          W_Loan.ACHIVE_LOAN_SANC_zero      := 0;
          W_Loan.ACHIVE_LOAN_SANC_other     := 0;
          W_Loan.ACHIVE_LOAN_SANC_PCT_zero  := 0;
          W_Loan.ACHIVE_LOAN_SANC_PCT_other := 0;
      END;
    
      begin
        SELECT (G.ZERO_EQ_DISBURSE) * V_FACTOR / 10000000 TARGET_DISB_zero,
               (g.gov_loan) * V_FACTOR / 10000000 TARGET_DISB_gov,
               (G.OTHS_PD_DISBURSE) * V_FACTOR / 10000000 TARGET_DISB_other,
               
               ACHIVE_DISBURSE_zero / 10000000 ACHIVE_DISBURSE_zero,
               ACHIVE_DISBURSE_gov / 10000000 ACHIVE_DISBURSE_gov,
               ACHIVE_DISBURSE_oth / 10000000 ACHIVE_DISBURSE_oth,
               
               CASE G.ZERO_EQ_DISBURSE
                 WHEN 0 THEN
                  0
                 ELSE
                  ACHIVE_DISBURSE_zero /
                  (G.ZERO_EQ_DISBURSE * V_FACTOR) * 100
               END DISB_PCT,
               
               CASE gov_loan
                 WHEN 0 THEN
                  0
                 ELSE
                  ACHIVE_DISBURSE_gov /
                 
                  ((g.gov_loan) * V_FACTOR) * 100
               END DISB_PCT_gov,
               
               CASE G.OTHS_PD_DISBURSE
                 WHEN 0 THEN
                  0
                 ELSE
                  ACHIVE_DISBURSE_oth / ((G.OTHS_PD_DISBURSE) * V_FACTOR) * 100
               END DISB_PCT_oth
        
          INTO W_Loan.TARGET_LOAN_DISB_zero,
               W_Loan.TARGET_LOAN_DISB_gov,
               W_Loan.TARGET_LOAN_DISB_other,
               W_Loan.ACHIVE_LOAN_DISB_zero,
               W_Loan.ACHIVE_LOAN_DISB_gov,
               W_Loan.ACHIVE_LOAN_DISB_other,
               W_Loan.ACHIVE_LOAN_DISB_PCT_zero,
               W_Loan.ACHIVE_LOAN_DISB_PCT_gov,
               W_Loan.ACHIVE_LOAN_DISB_PCT_other
        
          FROM mis_goal_setup g
          join (SELECT branch_code,
                       sum(d.zero_eq_disburse_amt) ACHIVE_DISBURSE_zero,
                       sum(nvl(d.gov_loan_disb, 0)) ACHIVE_DISBURSE_gov,
                       sum(d.oth_prd_disburse_amt) ACHIVE_DISBURSE_oth
                  FROM mis_loan_sanction_disburse d
                 where d.entry_date between v_from_date and v_to_date
                 group by d.branch_code) d
            on (d.branch_code = g.branch_code)
         where g.target_code = v_target_code
           AND G.BRANCH_CODE = IDX.BRANCH_OFF_CODE;
      
      exception
        when others then
        
          W_Loan.TARGET_LOAN_DISB_zero      := 0;
          W_Loan.TARGET_LOAN_DISB_gov       := 0;
          W_Loan.TARGET_LOAN_DISB_other     := 0;
          W_Loan.ACHIVE_LOAN_DISB_zero      := 0;
          W_Loan.ACHIVE_LOAN_DISB_gov       := 0;
          W_Loan.ACHIVE_LOAN_DISB_other     := 0;
          W_Loan.ACHIVE_LOAN_DISB_PCT_zero  := 0;
          W_Loan.ACHIVE_LOAN_DISB_PCT_gov   := 0;
          W_Loan.ACHIVE_LOAN_DISB_PCT_other := 0;
        
      end;
      pipe row(W_Loan);
    end loop;
  
  end fn_get_LOAN_details_data;

  function fn_get_performance_data(performance_type in varchar2,
                                   p_target_code    in varchar2,
                                   p_report_type    in varchar2)
    return v_performance
    pipelined is
    w_performance performance;
  begin
    if p_report_type = 'RecoveryPerformance' then
      w_performance.performance_description := 'Total Loan Recovery';
      if performance_type = 'T' then
        w_performance.title_desc := 'Top 10 Offices According to Performance';
        for idx in (SELECT *
                      FROM (SELECT BRANCH_NAME,
                                   target_description,
                                   BRANCH_CODE,
                                   TARGET_UC + TARGET_CL target,
                                   CL_RECOVERY + UC_RECOVERY achievment,
                                   round(case TARGET_UC + TARGET_CL
                                           when 0 then
                                            0
                                           else
                                            (CL_RECOVERY + UC_RECOVERY) /
                                            (TARGET_UC + TARGET_CL) * 100
                                         end,
                                         2) pct
                              FROM table(pkg_mis_rpt_ho.fn_get_recovery_data(p_target_code))
                             where TARGET_UC + TARGET_CL <> 0
                             order by round(case TARGET_UC + TARGET_CL
                                              when 0 then
                                               0
                                              else
                                               (CL_RECOVERY + UC_RECOVERY) /
                                               (TARGET_UC + TARGET_CL) * 100
                                            end,
                                            2) desc)
                     where rownum < 11) loop
          w_performance.Target_description := idx.target_description;
          w_performance.BRANCH_CODE        := idx.branch_code;
          w_performance.BRANCH_NAME        := idx.branch_name;
          w_performance.Target             := idx.target;
          w_performance.Acheivment         := idx.achievment;
          w_performance.Acheivment_PCT     := idx.pct;
          pipe row(w_performance);
        end loop;
      else
        w_performance.title_desc := 'Least 10 Offices According to Performance';
        for idx in (SELECT *
                      FROM (SELECT BRANCH_NAME,
                                   target_description,
                                   BRANCH_CODE,
                                   TARGET_UC + TARGET_CL target,
                                   CL_RECOVERY + UC_RECOVERY achievment,
                                   round(case TARGET_UC + TARGET_CL
                                           when 0 then
                                            0
                                           else
                                            (CL_RECOVERY + UC_RECOVERY) /
                                            (TARGET_UC + TARGET_CL) * 100
                                         end,
                                         2) pct
                              FROM table(pkg_mis_rpt_ho.fn_get_recovery_data(p_target_code))
                             where TARGET_UC + TARGET_CL <> 0
                             order by round(case TARGET_UC + TARGET_CL
                                              when 0 then
                                               0
                                              else
                                               (CL_RECOVERY + UC_RECOVERY) /
                                               (TARGET_UC + TARGET_CL) * 100
                                            end,
                                            2))
                     where rownum < 11) loop
          w_performance.Target_description := idx.target_description;
          w_performance.BRANCH_CODE        := idx.branch_code;
          w_performance.BRANCH_NAME        := idx.branch_name;
          w_performance.Target             := idx.target;
          w_performance.Acheivment         := idx.achievment;
          w_performance.Acheivment_PCT     := idx.pct;
          pipe row(w_performance);
        end loop;
      end if;
    
    elsif p_report_type = 'ClassifiedRecoveryPerformance' then
      w_performance.performance_description := 'Classified Loan Recovery';
      if performance_type = 'T' then
        w_performance.title_desc := 'Top 10 Offices According to Performance';
        for idx in (SELECT *
                      FROM (SELECT BRANCH_NAME,
                                   target_description,
                                   BRANCH_CODE,
                                   TARGET_CL target,
                                   CL_RECOVERY achievment,
                                   round(case TARGET_CL
                                           when 0 then
                                            0
                                           else
                                            (CL_RECOVERY) / (TARGET_CL) * 100
                                         end,
                                         2) pct
                              FROM table(pkg_mis_rpt_ho.fn_get_recovery_data(p_target_code))
                             where TARGET_CL <> 0
                             order by round(case TARGET_CL
                                              when 0 then
                                               0
                                              else
                                               (CL_RECOVERY) / (TARGET_CL) * 100
                                            end,
                                            2) desc)
                     where rownum < 11) loop
          w_performance.Target_description := idx.target_description;
          w_performance.BRANCH_CODE        := idx.branch_code;
          w_performance.BRANCH_NAME        := idx.branch_name;
          w_performance.Target             := idx.target;
          w_performance.Acheivment         := idx.achievment;
          w_performance.Acheivment_PCT     := idx.pct;
          pipe row(w_performance);
        end loop;
      else
        w_performance.title_desc := 'Least 10 Offices According to Performance';
        for idx in (SELECT *
                      FROM (SELECT BRANCH_NAME,
                                   BRANCH_CODE,
                                   target_description,
                                   TARGET_CL target,
                                   CL_RECOVERY achievment,
                                   round(case TARGET_CL
                                           when 0 then
                                            0
                                           else
                                            (CL_RECOVERY) / (TARGET_CL) * 100
                                         end,
                                         2) pct
                              FROM table(pkg_mis_rpt_ho.fn_get_recovery_data(p_target_code))
                             where TARGET_CL <> 0
                             order by round(case TARGET_CL
                                              when 0 then
                                               0
                                              else
                                               (CL_RECOVERY) / (TARGET_CL) * 100
                                            end,
                                            2))
                     where rownum < 11) loop
          w_performance.Target_description := idx.target_description;
          w_performance.BRANCH_CODE        := idx.branch_code;
          w_performance.BRANCH_NAME        := idx.branch_name;
          w_performance.Target             := idx.target;
          w_performance.Acheivment         := idx.achievment;
          w_performance.Acheivment_PCT     := idx.pct;
          pipe row(w_performance);
        end loop;
      end if;
    elsif p_report_type = 'MiscCCPerformance' then
      w_performance.performance_description := 'Court Case Settlement(Misc. Case)';
      if performance_type = 'T' then
        w_performance.title_desc := 'Top 10 Offices According to Performance';
        for idx in (SELECT *
                      FROM (SELECT TARGET_DESCRIPTION,
                                   BRANCH_CODE,
                                   BRANCH_NAME,
                                   TARGET_MISC,
                                   ACHIVE_MISC,
                                   round(case TARGET_MISC
                                           when 0 then
                                            0
                                           else
                                            ACHIVE_MISC / TARGET_MISC * 100
                                         end,
                                         2) pct
                              FROM table(pkg_mis_rpt_ho.fn_get_courtcase_data(p_target_code))
                             where TARGET_MISC <> 0
                             order by round(case TARGET_MISC
                                              when 0 then
                                               0
                                              else
                                               ACHIVE_MISC / TARGET_MISC
                                            end,
                                            2) desc)
                     where rownum < 11) loop
          w_performance.Target_description := idx.target_description;
          w_performance.BRANCH_CODE        := idx.branch_code;
          w_performance.BRANCH_NAME        := idx.branch_name;
          w_performance.Target             := idx.target_misc;
          w_performance.Acheivment         := idx.achive_misc;
          w_performance.Acheivment_PCT     := idx.pct;
          pipe row(w_performance);
        end loop;
      
      else
        w_performance.title_desc := 'Least 10 Offices According to Performance';
        for idx in (SELECT *
                      FROM (SELECT TARGET_DESCRIPTION,
                                   BRANCH_CODE,
                                   BRANCH_NAME,
                                   TARGET_MISC,
                                   ACHIVE_MISC,
                                   round(case TARGET_MISC
                                           when 0 then
                                            0
                                           else
                                            ACHIVE_MISC / TARGET_MISC * 100
                                         end,
                                         2) pct
                              FROM table(pkg_mis_rpt_ho.fn_get_courtcase_data(p_target_code))
                             where TARGET_MISC <> 0
                             order by round(case TARGET_MISC
                                              when 0 then
                                               0
                                              else
                                               ACHIVE_MISC / TARGET_MISC
                                            end,
                                            2))
                     where rownum < 11) loop
          w_performance.Target_description := idx.target_description;
          w_performance.BRANCH_CODE        := idx.branch_code;
          w_performance.BRANCH_NAME        := idx.branch_name;
          w_performance.Target             := idx.target_misc;
          w_performance.Acheivment         := idx.achive_misc;
          w_performance.Acheivment_PCT     := idx.pct;
          pipe row(w_performance);
        end loop;
      end if;
    elsif p_report_type = 'ExecutionCCPerformance' then
      w_performance.performance_description := 'Court Case Settlement(Execution Case)';
      if performance_type = 'T' then
        w_performance.title_desc := 'Top 10 Offices According to Performance';
        for idx in (SELECT *
                      FROM (SELECT TARGET_DESCRIPTION,
                                   BRANCH_CODE,
                                   BRANCH_NAME,
                                   
                                   TARGET_EXECUTION,
                                   ACHIVE_EXECUTION,
                                   round(case TARGET_EXECUTION
                                           when 0 then
                                            0
                                           else
                                            ACHIVE_EXECUTION /
                                            TARGET_EXECUTION * 100
                                         end,
                                         2) pct
                              FROM table(pkg_mis_rpt_ho.fn_get_courtcase_data(p_target_code))
                             where TARGET_EXECUTION <> 0
                             order by round(case nvl(TARGET_EXECUTION, 0)
                                              when 0 then
                                               0
                                              else
                                               ACHIVE_EXECUTION /
                                               nvl(TARGET_EXECUTION, 0)
                                            end,
                                            2) desc)
                     where rownum < 11) loop
          w_performance.Target_description := idx.target_description;
          w_performance.BRANCH_CODE        := idx.branch_code;
          w_performance.BRANCH_NAME        := idx.branch_name;
          w_performance.Target             := idx.TARGET_EXECUTION;
          w_performance.Acheivment         := idx.ACHIVE_EXECUTION;
          w_performance.Acheivment_PCT     := idx.pct;
          pipe row(w_performance);
        end loop;
      
      else
        w_performance.title_desc := 'Least 10 Offices According to Performance';
        for idx in (SELECT *
                      FROM (SELECT TARGET_DESCRIPTION,
                                   BRANCH_CODE,
                                   BRANCH_NAME,
                                   
                                   TARGET_EXECUTION,
                                   ACHIVE_EXECUTION,
                                   round(case TARGET_EXECUTION
                                           when 0 then
                                            0
                                           else
                                            ACHIVE_EXECUTION /
                                            TARGET_EXECUTION * 100
                                         end,
                                         2) pct
                              FROM table(pkg_mis_rpt_ho.fn_get_courtcase_data(p_target_code))
                             where TARGET_EXECUTION <> 0
                             order by round(case nvl(TARGET_EXECUTION, 0)
                                              when 0 then
                                               0
                                              else
                                               ACHIVE_EXECUTION /
                                               nvl(TARGET_EXECUTION, 0)
                                            end,
                                            2))
                     where rownum < 11) loop
          w_performance.Target_description := idx.target_description;
          w_performance.BRANCH_CODE        := idx.branch_code;
          w_performance.BRANCH_NAME        := idx.branch_name;
          w_performance.Target             := idx.TARGET_EXECUTION;
          w_performance.Acheivment         := idx.ACHIVE_EXECUTION;
          w_performance.Acheivment_PCT     := idx.pct;
          pipe row(w_performance);
        end loop;
      end if;
    elsif p_report_type = 'PossesionKharidabariPerformance' then
      w_performance.performance_description := 'Kharidabari (Possesion)';
      if performance_type = 'T' then
        w_performance.title_desc := 'Top 10 Offices According to Performance';
      
        for idx in (SELECT *
                      FROM (SELECT TARGET_DESCRIPTION,
                                   BRANCH_CODE,
                                   BRANCH_NAME,
                                   
                                   TARGET_POSSESION,
                                   ACHIVE_POSSESION,
                                   round(case TARGET_POSSESION
                                           when 0 then
                                            0
                                           else
                                            ACHIVE_POSSESION /
                                            TARGET_POSSESION * 100
                                         end,
                                         2) pct
                              FROM table(pkg_mis_rpt_ho.fn_get_kharidabari_data(p_target_code))
                             where TARGET_POSSESION <> 0
                             order by round(case nvl(ACHIVE_POSSESION, 0)
                                              when 0 then
                                               0
                                              else
                                               ACHIVE_POSSESION /
                                               nvl(TARGET_POSSESION, 0)
                                            end,
                                            2) desc)
                     where rownum < 11) loop
          w_performance.Target_description := idx.target_description;
          w_performance.BRANCH_CODE        := idx.branch_code;
          w_performance.BRANCH_NAME        := idx.branch_name;
          w_performance.Target             := idx.TARGET_POSSESION;
          w_performance.Acheivment         := idx.ACHIVE_POSSESION;
          w_performance.Acheivment_PCT     := idx.pct;
          pipe row(w_performance);
        end loop;
      
      else
        w_performance.title_desc := 'Least 10 Offices According to Performance';
        for idx in (SELECT *
                      FROM (SELECT TARGET_DESCRIPTION,
                                   BRANCH_CODE,
                                   BRANCH_NAME,
                                   
                                   TARGET_POSSESION,
                                   ACHIVE_POSSESION,
                                   round(case TARGET_POSSESION
                                           when 0 then
                                            0
                                           else
                                            ACHIVE_POSSESION /
                                            TARGET_POSSESION * 100
                                         end,
                                         2) pct
                              FROM table(pkg_mis_rpt_ho.fn_get_kharidabari_data(p_target_code))
                             where TARGET_POSSESION <> 0
                             order by round(case nvl(ACHIVE_POSSESION, 0)
                                              when 0 then
                                               0
                                              else
                                               ACHIVE_POSSESION /
                                               nvl(TARGET_POSSESION, 0)
                                            end,
                                            2))
                     where rownum < 11) loop
          w_performance.Target_description := idx.target_description;
          w_performance.BRANCH_CODE        := idx.branch_code;
          w_performance.BRANCH_NAME        := idx.branch_name;
          w_performance.Target             := idx.TARGET_POSSESION;
          w_performance.Acheivment         := idx.ACHIVE_POSSESION;
          w_performance.Acheivment_PCT     := idx.pct;
          pipe row(w_performance);
        end loop;
      end if;
    elsif p_report_type = 'SaleKharidabariPerformance' then
      w_performance.performance_description := 'Kharidabari (Sale)';
      if performance_type = 'T' then
        w_performance.title_desc := 'Top 10 Offices According to Performance';
        for idx in (SELECT *
                      FROM (SELECT TARGET_DESCRIPTION,
                                   BRANCH_CODE,
                                   BRANCH_NAME,
                                   TARGET_SALE,
                                   ACHIVE_SALE,
                                   round(case TARGET_SALE
                                           when 0 then
                                            0
                                           else
                                            ACHIVE_SALE / TARGET_SALE * 100
                                         end,
                                         2) pct
                              FROM table(pkg_mis_rpt_ho.fn_get_kharidabari_data(p_target_code))
                             where TARGET_SALE <> 0
                             order by round(case nvl(TARGET_SALE, 0)
                                              when 0 then
                                               0
                                              else
                                               ACHIVE_SALE /
                                               nvl(TARGET_SALE, 0)
                                            end,
                                            2) desc)
                     where rownum < 11) loop
          w_performance.Target_description := idx.target_description;
          w_performance.BRANCH_CODE        := idx.branch_code;
          w_performance.BRANCH_NAME        := idx.branch_name;
          w_performance.Target             := idx.TARGET_SALE;
          w_performance.Acheivment         := idx.ACHIVE_SALE;
          w_performance.Acheivment_PCT     := idx.pct;
          pipe row(w_performance);
        end loop;
      
      else
        w_performance.title_desc := 'Least 10 Offices According to Performance';
        for idx in (SELECT *
                      FROM (SELECT TARGET_DESCRIPTION,
                                   BRANCH_CODE,
                                   BRANCH_NAME,
                                   TARGET_SALE,
                                   ACHIVE_SALE,
                                   round(case TARGET_SALE
                                           when 0 then
                                            0
                                           else
                                            ACHIVE_SALE / TARGET_SALE * 100
                                         end,
                                         2) pct
                              FROM table(pkg_mis_rpt_ho.fn_get_kharidabari_data(p_target_code))
                             where TARGET_SALE <> 0
                             order by round(case nvl(TARGET_SALE, 0)
                                              when 0 then
                                               0
                                              else
                                               ACHIVE_SALE /
                                               nvl(TARGET_SALE, 0)
                                            end,
                                            2))
                     where rownum < 11) loop
          w_performance.Target_description := idx.target_description;
          w_performance.BRANCH_CODE        := idx.branch_code;
          w_performance.BRANCH_NAME        := idx.branch_name;
          w_performance.Target             := idx.TARGET_SALE;
          w_performance.Acheivment         := idx.ACHIVE_SALE;
          w_performance.Acheivment_PCT     := idx.pct;
          pipe row(w_performance);
        end loop;
      end if;
    
    elsif p_report_type = 'commercialAuditPerformance' then
      w_performance.performance_description := 'Disposal of Audit Objection (Commercial)';
      if performance_type = 'T' then
        w_performance.title_desc := 'Top 10 Offices According to Performance';
        for idx in (SELECT *
                      FROM (SELECT TARGET_DESCRIPTION,
                                   BRANCH_CODE,
                                   BRANCH_NAME,
                                   TARGET_COMMERTIAL,
                                   ACHIVE_COMMERTIAL,
                                   round(case TARGET_COMMERTIAL
                                           when 0 then
                                            0
                                           else
                                            ACHIVE_COMMERTIAL /
                                            TARGET_COMMERTIAL * 100
                                         end,
                                         2) pct
                              FROM table(pkg_mis_rpt_ho.fn_get_AUDIT_data(p_target_code))
                             where TARGET_COMMERTIAL <> 0
                             order by round(case nvl(TARGET_COMMERTIAL, 0)
                                              when 0 then
                                               0
                                              else
                                               ACHIVE_COMMERTIAL /
                                               nvl(TARGET_COMMERTIAL, 0)
                                            end,
                                            2) desc)
                     where rownum < 11) loop
          w_performance.Target_description := idx.target_description;
          w_performance.BRANCH_CODE        := idx.branch_code;
          w_performance.BRANCH_NAME        := idx.branch_name;
          w_performance.Target             := idx.TARGET_COMMERTIAL;
          w_performance.Acheivment         := idx.ACHIVE_COMMERTIAL;
          w_performance.Acheivment_PCT     := idx.pct;
          pipe row(w_performance);
        end loop;
      
      else
        w_performance.title_desc := 'Least 10 Offices According to Performance';
        for idx in (SELECT *
                      FROM (SELECT TARGET_DESCRIPTION,
                                   BRANCH_CODE,
                                   BRANCH_NAME,
                                   TARGET_COMMERTIAL,
                                   ACHIVE_COMMERTIAL,
                                   round(case TARGET_COMMERTIAL
                                           when 0 then
                                            0
                                           else
                                            ACHIVE_COMMERTIAL /
                                            TARGET_COMMERTIAL * 100
                                         end,
                                         2) pct
                              FROM table(pkg_mis_rpt_ho.fn_get_AUDIT_data(p_target_code))
                             where TARGET_COMMERTIAL <> 0
                             order by round(case nvl(TARGET_COMMERTIAL, 0)
                                              when 0 then
                                               0
                                              else
                                               ACHIVE_COMMERTIAL /
                                               nvl(TARGET_COMMERTIAL, 0)
                                            end,
                                            2))
                     where rownum < 11) loop
          w_performance.Target_description := idx.target_description;
          w_performance.BRANCH_CODE        := idx.branch_code;
          w_performance.BRANCH_NAME        := idx.branch_name;
          w_performance.Target             := idx.TARGET_COMMERTIAL;
          w_performance.Acheivment         := idx.ACHIVE_COMMERTIAL;
          w_performance.Acheivment_PCT     := idx.pct;
          pipe row(w_performance);
        end loop;
      end if;
    
    elsif p_report_type = 'PostAuditPerformance' then
      w_performance.performance_description := 'Disposal of Audit Objection (Post Audit)';
      if performance_type = 'T' then
        w_performance.title_desc := 'Top 10 Offices According to Performance';
        for idx in (SELECT *
                      FROM (SELECT TARGET_DESCRIPTION,
                                   BRANCH_CODE,
                                   BRANCH_NAME,
                                   TARGET_POST_AUDIT,
                                   ACHIVE_POST_AUDIT,
                                   round(case TARGET_POST_AUDIT
                                           when 0 then
                                            0
                                           else
                                            ACHIVE_POST_AUDIT /
                                            TARGET_POST_AUDIT * 100
                                         end,
                                         2) pct
                              FROM table(pkg_mis_rpt_ho.fn_get_AUDIT_data(p_target_code))
                             where TARGET_POST_AUDIT <> 0
                             order by round(case nvl(TARGET_POST_AUDIT, 0)
                                              when 0 then
                                               0
                                              else
                                               ACHIVE_POST_AUDIT /
                                               nvl(TARGET_POST_AUDIT, 0)
                                            end,
                                            2) desc)
                     where rownum < 11) loop
          w_performance.Target_description := idx.target_description;
          w_performance.BRANCH_CODE        := idx.branch_code;
          w_performance.BRANCH_NAME        := idx.branch_name;
          w_performance.Target             := idx.TARGET_POST_AUDIT;
          w_performance.Acheivment         := idx.ACHIVE_POST_AUDIT;
          w_performance.Acheivment_PCT     := idx.pct;
          pipe row(w_performance);
        end loop;
      
      else
        w_performance.title_desc := 'Least 10 Offices According to Performance';
        for idx in (SELECT *
                      FROM (SELECT TARGET_DESCRIPTION,
                                   BRANCH_CODE,
                                   BRANCH_NAME,
                                   TARGET_POST_AUDIT,
                                   ACHIVE_POST_AUDIT,
                                   round(case TARGET_POST_AUDIT
                                           when 0 then
                                            0
                                           else
                                            ACHIVE_POST_AUDIT /
                                            TARGET_POST_AUDIT * 100
                                         end,
                                         2) pct
                              FROM table(pkg_mis_rpt_ho.fn_get_AUDIT_data(p_target_code))
                             where TARGET_POST_AUDIT <> 0
                             order by round(case nvl(TARGET_POST_AUDIT, 0)
                                              when 0 then
                                               0
                                              else
                                               ACHIVE_POST_AUDIT /
                                               nvl(TARGET_POST_AUDIT, 0)
                                            end,
                                            2))
                     where rownum < 11) loop
          w_performance.Target_description := idx.target_description;
          w_performance.BRANCH_CODE        := idx.branch_code;
          w_performance.BRANCH_NAME        := idx.branch_name;
          w_performance.Target             := idx.TARGET_POST_AUDIT;
          w_performance.Acheivment         := idx.ACHIVE_POST_AUDIT;
          w_performance.Acheivment_PCT     := idx.pct;
          pipe row(w_performance);
        end loop;
      end if;
    
    elsif p_report_type = 'LoanSanctionPerformance' then
      w_performance.performance_description := 'Loan Sanction';
      if performance_type = 'T' then
        w_performance.title_desc := 'Top 10 Offices According to Performance';
        for idx in (SELECT *
                      FROM (SELECT TARGET_DESCRIPTION,
                                   BRANCH_CODE,
                                   BRANCH_NAME,
                                   TARGET_LOAN_SANC,
                                   ACHIVE_LOAN_SANC,
                                   round(case TARGET_LOAN_SANC
                                           when 0 then
                                            0
                                           else
                                            ACHIVE_LOAN_SANC /
                                            TARGET_LOAN_SANC * 100
                                         end,
                                         2) pct
                              FROM table(pkg_mis_rpt_ho.fn_get_LOAN_data(p_target_code))
                             where TARGET_LOAN_SANC <> 0
                             order by round(case nvl(TARGET_LOAN_SANC, 0)
                                              when 0 then
                                               0
                                              else
                                               ACHIVE_LOAN_SANC /
                                               nvl(TARGET_LOAN_SANC, 0)
                                            end,
                                            2) desc)
                     where rownum < 11) loop
          w_performance.Target_description := idx.target_description;
          w_performance.BRANCH_CODE        := idx.branch_code;
          w_performance.BRANCH_NAME        := idx.branch_name;
          w_performance.Target             := idx.TARGET_LOAN_SANC;
          w_performance.Acheivment         := idx.ACHIVE_LOAN_SANC;
          w_performance.Acheivment_PCT     := idx.pct;
          pipe row(w_performance);
        end loop;
      
      else
        w_performance.title_desc := 'Least 10 Offices According to Performance';
        for idx in (SELECT *
                      FROM (SELECT TARGET_DESCRIPTION,
                                   BRANCH_CODE,
                                   BRANCH_NAME,
                                   TARGET_LOAN_SANC,
                                   ACHIVE_LOAN_SANC,
                                   round(case TARGET_LOAN_SANC
                                           when 0 then
                                            0
                                           else
                                            ACHIVE_LOAN_SANC /
                                            TARGET_LOAN_SANC * 100
                                         end,
                                         2) pct
                              FROM table(pkg_mis_rpt_ho.fn_get_LOAN_data(p_target_code))
                             where TARGET_LOAN_SANC <> 0
                             order by round(case nvl(TARGET_LOAN_SANC, 0)
                                              when 0 then
                                               0
                                              else
                                               ACHIVE_LOAN_SANC /
                                               nvl(TARGET_LOAN_SANC, 0)
                                            end,
                                            2))
                     where rownum < 11) loop
          w_performance.Target_description := idx.target_description;
          w_performance.BRANCH_CODE        := idx.branch_code;
          w_performance.BRANCH_NAME        := idx.branch_name;
          w_performance.Target             := idx.TARGET_LOAN_SANC;
          w_performance.Acheivment         := idx.ACHIVE_LOAN_SANC;
          w_performance.Acheivment_PCT     := idx.pct;
          pipe row(w_performance);
        end loop;
      end if;
    
    elsif p_report_type = 'LoanDisbursePerformance' then
      w_performance.performance_description := 'Loan Disburse';
    
      if performance_type = 'T' then
        w_performance.title_desc := 'Top 10 Offices According to Performance';
        for idx in (SELECT *
                      FROM (SELECT TARGET_DESCRIPTION,
                                   BRANCH_CODE,
                                   BRANCH_NAME,
                                   TARGET_LOAN_DISB,
                                   ACHIVE_LOAN_DISB,
                                   round(case TARGET_LOAN_DISB
                                           when 0 then
                                            0
                                           else
                                            ACHIVE_LOAN_DISB /
                                            TARGET_LOAN_DISB * 100
                                         end,
                                         2) pct
                              FROM table(pkg_mis_rpt_ho.fn_get_LOAN_data(p_target_code))
                             where TARGET_LOAN_DISB <> 0
                             order by round(case nvl(TARGET_LOAN_DISB, 0)
                                              when 0 then
                                               0
                                              else
                                               ACHIVE_LOAN_DISB /
                                               nvl(TARGET_LOAN_DISB, 0)
                                            end,
                                            2) desc)
                     where rownum < 11) loop
          w_performance.Target_description := idx.target_description;
          w_performance.BRANCH_CODE        := idx.branch_code;
          w_performance.BRANCH_NAME        := idx.branch_name;
          w_performance.Target             := idx.TARGET_LOAN_DISB;
          w_performance.Acheivment         := idx.ACHIVE_LOAN_DISB;
          w_performance.Acheivment_PCT     := idx.pct;
          pipe row(w_performance);
        end loop;
      
      else
        w_performance.title_desc := 'Least 10 Offices According to Performance';
        for idx in (SELECT *
                      FROM (SELECT TARGET_DESCRIPTION,
                                   BRANCH_CODE,
                                   BRANCH_NAME,
                                   TARGET_LOAN_DISB,
                                   ACHIVE_LOAN_DISB,
                                   round(case TARGET_LOAN_DISB
                                           when 0 then
                                            0
                                           else
                                            ACHIVE_LOAN_DISB /
                                            TARGET_LOAN_DISB * 100
                                         end,
                                         2) pct
                              FROM table(pkg_mis_rpt_ho.fn_get_LOAN_data(p_target_code))
                             where TARGET_LOAN_DISB <> 0
                             order by round(case nvl(TARGET_LOAN_DISB, 0)
                                              when 0 then
                                               0
                                              else
                                               ACHIVE_LOAN_DISB /
                                               nvl(TARGET_LOAN_DISB, 0)
                                            end,
                                            2))
                     where rownum < 11) loop
          w_performance.Target_description := idx.target_description;
          w_performance.BRANCH_CODE        := idx.branch_code;
          w_performance.BRANCH_NAME        := idx.branch_name;
          w_performance.Target             := idx.TARGET_LOAN_DISB;
          w_performance.Acheivment         := idx.ACHIVE_LOAN_DISB;
          w_performance.Acheivment_PCT     := idx.pct;
          pipe row(w_performance);
        end loop;
      end if;
    elsif p_report_type = 'DeedReturnPerformance' then
      w_performance.performance_description := 'Deed Return';
    
      if performance_type = 'T' then
        w_performance.title_desc := 'Top 10 Offices According to Performance';
        for idx in (SELECT *
                      FROM (SELECT TARGET_DESCRIPTION,
                                   BRANCH_CODE,
                                   BRANCH_NAME,
                                   TARGET_DEEDRETURN,
                                   ACHIVE_DEEDRETURN,
                                   round(case TARGET_DEEDRETURN
                                           when 0 then
                                            0
                                           else
                                            (ACHIVE_DEEDRETURN /
                                            TARGET_DEEDRETURN) * 100
                                         end,
                                         2) pct
                              FROM table(pkg_mis_rpt_ho.fn_get_deedreturn_data(p_target_code))
                             where TARGET_DEEDRETURN <> 0
                             order by round(case nvl(TARGET_DEEDRETURN, 0)
                                              when 0 then
                                               0
                                              else
                                               (ACHIVE_DEEDRETURN /
                                               nvl(TARGET_DEEDRETURN, 0))
                                            end,
                                            2) desc)
                     where rownum < 11) loop
          w_performance.Target_description := idx.target_description;
          w_performance.BRANCH_CODE        := idx.branch_code;
          w_performance.BRANCH_NAME        := idx.branch_name;
          w_performance.Target             := idx.TARGET_DEEDRETURN;
          w_performance.Acheivment         := idx.ACHIVE_DEEDRETURN;
          w_performance.Acheivment_PCT     := idx.pct;
          pipe row(w_performance);
        end loop;
      
      else
        w_performance.title_desc := 'Least 10 Offices According to Performance';
        for idx in (SELECT *
                      FROM (SELECT TARGET_DESCRIPTION,
                                   BRANCH_CODE,
                                   BRANCH_NAME,
                                   TARGET_DEEDRETURN,
                                   ACHIVE_DEEDRETURN,
                                   round(case TARGET_DEEDRETURN
                                           when 0 then
                                            0
                                           else
                                            ACHIVE_DEEDRETURN /
                                            TARGET_DEEDRETURN * 100
                                         end,
                                         2) pct
                              FROM table(pkg_mis_rpt_ho.fn_get_deedreturn_data(p_target_code))
                             where TARGET_DEEDRETURN <> 0
                             order by round(case nvl(TARGET_DEEDRETURN, 0)
                                              when 0 then
                                               0
                                              else
                                               ACHIVE_DEEDRETURN /
                                               nvl(TARGET_DEEDRETURN, 0)
                                            end,
                                            2))
                     where rownum < 11) loop
          w_performance.Target_description := idx.target_description;
          w_performance.BRANCH_CODE        := idx.branch_code;
          w_performance.BRANCH_NAME        := idx.branch_name;
          w_performance.Target             := idx.TARGET_DEEDRETURN;
          w_performance.Acheivment         := idx.ACHIVE_DEEDRETURN;
          w_performance.Acheivment_PCT     := idx.pct;
          pipe row(w_performance);
        end loop;
      end if;
    end if;
  
  end fn_get_performance_data;

begin
  null;
end pkg_mis_rpt_ho;
/
