create or replace package pkg_mis_entry is
  procedure sp_loan_disburse(p_branch_code     in varchar2,
                             p_entry_date      in date,
                             p_gov_ln_disburse in number,
                             p_zr_ln_disburse  in number,
                             p_ot_ln_disburse  in number,
                             p_error           out varchar2);
  procedure sp_loan_recovery(p_branch_code in varchar2,
                             p_entry_date  in date,
                             p_cl_amount   in number,
                             p_uc_amount   in number,
                             p_error       out varchar2);
  procedure sp_loan_audit_objection(p_branch_code    in varchar2,
                                    p_entry_date     in date,
                                    commercial_audit in number,
                                    post_audit       in number,
                                    p_error          out varchar2);
  procedure sp_loan_kharidabari(p_branch_code in varchar2,
                                p_entry_date  in date,
                                p_procession  in number,
                                p_sale        in number,
                                p_error       out varchar2);
  procedure sp_cc_settlement(p_branch_code    in varchar2,
                             p_entry_date     in date,
                             p_executive_case in number,
                             p_misc_case      in number,
                             p_error          out varchar2);

  procedure sp_deed_return_fl(p_branch_code   in varchar2,
                              p_entry_date    in date,
                              loan_case_count in number,
                              p_error         out varchar2);
end pkg_mis_entry;
/
create or replace package body pkg_mis_entry is

  procedure sp_loan_disburse(p_branch_code     in varchar2,
                             p_entry_date      in date,
                             p_gov_ln_disburse in number,
                             p_zr_ln_disburse  in number,
                             p_ot_ln_disburse  in number,
                             p_error           out varchar2) is
    v_exist number := 0;
    timmer  number := 0;
  begin
    select count(*)
      into v_exist
      from mis_loan_sanction_disburse d
     where d.branch_code = p_branch_code
       and d.entry_date = p_entry_date;
  
    if v_exist = 0 then
      insert into mis_loan_sanction_disburse l
        (branch_code,
         entry_date,
         zero_eq_disburse_amt,
         oth_prd_disburse_amt,
         gov_loan_disb)
      values
        (p_branch_code,
         p_entry_date,
         p_zr_ln_disburse,
         p_ot_ln_disburse,
         p_gov_ln_disburse);
    else
    
      select trunc(sysdate) - d.entry_date
        into timmer
        from mis_loan_sanction_disburse d
       where d.branch_code = p_branch_code
         and d.entry_date = p_entry_date;
    
      if timmer < 60 then
        update mis_loan_sanction_disburse b
           set b.zero_eq_disburse_amt = p_zr_ln_disburse,
               b.oth_prd_disburse_amt = p_ot_ln_disburse,
               b.gov_loan_disb        = p_gov_ln_disburse
         where b.branch_code = p_branch_code
           and b.entry_date = p_entry_date;
      else
        p_error := 'Time Expired for Modification the record';
      end if;
    end if;
  
  end sp_loan_disburse;

  procedure sp_loan_recovery(p_branch_code in varchar2,
                             p_entry_date  in date,
                             p_cl_amount   in number,
                             p_uc_amount   in number,
                             p_error       out varchar2) is
    v_exist number := 0;
    timmer  number := 0;
  begin
    select count(*)
      into v_exist
      from mis_loan_recovery d
     where d.branch_code = p_branch_code
       and d.entry_date = p_entry_date;
  
    if v_exist = 0 then
      insert into mis_loan_recovery
        (branch_code, entry_date, cl_recovery_amt, uc_recovery_amt)
      values
        (p_branch_code, p_entry_date, p_cl_amount, p_uc_amount);
    else
    
      select trunc(sysdate) - d.entry_date
        into timmer
        from mis_loan_recovery d
       where d.branch_code = p_branch_code
         and d.entry_date = p_entry_date;
      if timmer < 60 then
        update mis_loan_recovery b
           set cl_recovery_amt = p_cl_amount, uc_recovery_amt = p_uc_amount
         where b.branch_code = p_branch_code
           and b.entry_date = p_entry_date;
      else
        p_error := 'Time Expired for Modification the record';
      end if;
    
    end if;
  end sp_loan_recovery;

  procedure sp_loan_audit_objection(p_branch_code    in varchar2,
                                    p_entry_date     in date,
                                    commercial_audit in number,
                                    post_audit       in number,
                                    p_error          out varchar2) is
    v_exist number := 0;
    timmer  number := 0;
  begin
    select count(*)
      into v_exist
      from mis_audit_ob_disposal d
     where d.branch_code = p_branch_code
       and d.entry_date = p_entry_date;
  
    if v_exist = 0 then
      insert into mis_audit_ob_disposal
        (branch_code, entry_date, commercial_obj, audit_obj)
      values
        (p_branch_code, p_entry_date, commercial_audit, post_audit);
    else
    
      select trunc(sysdate) - d.entry_date
        into timmer
        from mis_audit_ob_disposal d
       where d.branch_code = p_branch_code
         and d.entry_date = p_entry_date;
     if timmer < 60 then
      update mis_audit_ob_disposal b
         set commercial_obj = commercial_audit, audit_obj = post_audit
       where b.branch_code = p_branch_code
         and b.entry_date = p_entry_date;
     else
        p_error := 'Time Expired for Modification the record';
      end if;
    end if;
  end sp_loan_audit_objection;

  procedure sp_loan_kharidabari(p_branch_code in varchar2,
                                p_entry_date  in date,
                                p_procession  in number,
                                p_sale        in number,
                                p_error       out varchar2) is
    v_exist number := 0;
    timmer  number := 0;
  begin
    select count(*)
      into v_exist
      from mis_kharidabari d
     where d.branch_code = p_branch_code
       and d.entry_date = p_entry_date;
  
    if v_exist = 0 then
      insert into mis_kharidabari
        (branch_code, entry_date, procession, sale)
      values
        (p_branch_code, p_entry_date, p_procession, p_sale);
    else
      select trunc(sysdate) - d.entry_date
        into timmer
        from mis_kharidabari d
       where d.branch_code = p_branch_code
         and d.entry_date = p_entry_date;
    if timmer < 60 then
      update mis_kharidabari b
         set procession = p_procession, sale = p_sale
       where b.branch_code = p_branch_code
         and b.entry_date = p_entry_date;
    else
        p_error := 'Time Expired for Modification the record';
      end if;
    end if;
  end sp_loan_kharidabari;

  procedure sp_cc_settlement(p_branch_code    in varchar2,
                             p_entry_date     in date,
                             p_executive_case in number,
                             p_misc_case      in number,
                             p_error          out varchar2) is
    v_exist number := 0;
    timmer  number := 0;
  begin
    select count(*)
      into v_exist
      from mis_court_case_settle d
     where d.branch_code = p_branch_code
       and d.entry_date = p_entry_date;
  
    if v_exist = 0 then
      insert into mis_court_case_settle
        (branch_code, entry_date, executive_case, misc_cse)
      values
        (p_branch_code, p_entry_date, p_executive_case, p_misc_case);
    else
    
      select trunc(sysdate) - d.entry_date
        into timmer
        from mis_court_case_settle d
       where d.branch_code = p_branch_code
         and d.entry_date = p_entry_date;
    if timmer < 60 then
      update mis_court_case_settle b
         set executive_case = p_executive_case, misc_cse = p_misc_case
       where b.branch_code = p_branch_code
         and b.entry_date = p_entry_date;
         
       else
        p_error := 'Time Expired for Modification the record';
      end if;   
    end if;
  end sp_cc_settlement;

  procedure sp_deed_return_fl(p_branch_code   in varchar2,
                              p_entry_date    in date,
                              loan_case_count in number,
                              p_error         out varchar2) is
    v_exist number := 0;
    timmer  number := 0;
  begin
    select count(*)
      into v_exist
      from mis_faulty_ln_case d
     where d.branch_code = p_branch_code
       and d.entry_date = p_entry_date;
  
    if v_exist = 0 then
      insert into mis_faulty_ln_case
        (branch_code, entry_date, loan_account_no)
      values
        (p_branch_code, p_entry_date, loan_case_count);
    else
    
      select trunc(sysdate) - d.entry_date
        into timmer
        from mis_faulty_ln_case d
       where d.branch_code = p_branch_code
         and d.entry_date = p_entry_date;
     if timmer < 60 then
      update mis_faulty_ln_case
         set loan_account_no = loan_case_count
       where branch_code = p_branch_code
         and entry_date = p_entry_date;
         
       else
        p_error := 'Time Expired for Modification the record';
      end if;   
    end if;
  end sp_deed_return_fl;

begin
  null;
end pkg_mis_entry;
/
