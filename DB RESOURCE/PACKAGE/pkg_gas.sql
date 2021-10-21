create or replace package pkg_gas is

  -- author  : mosharraf hossain talukder
  -- created : 03-jan-21 3:07:53 pm
  -- purpose : general accounting system
  procedure sp_BatchAUthorize_test(p_branch_code in varchar2,
                                   p_date        in date,
                                   p_batch       in number,
                                   p_user_id     in varchar2,
                                   p_error       out varchar2);
  procedure sp_BatchAUthorize(p_branch_code in varchar2,
                              p_date        in date,
                              p_batch       in number,
                              p_user_id     in varchar2,
                              p_error       out varchar2);
  procedure sp_BatchAUthValidation(p_branch_code in varchar2,
                                   p_date        in date,
                                   p_batch       in number,
                                   p_user_id     in varchar2,
                                   p_error       out varchar2);
  /*  procedure sp_autopost_salary(p_branch_code in varchar2,
  p_user_Id     in varchar2,
  p_date        in date,
  p_batch       out number,
  p_error       out varchar2);*/
  procedure sp_BatchChecked(p_branch_code in varchar2,
                            p_date        in date,
                            p_batch       in number,
                            p_user_id     in varchar2,
                            p_error       out varchar2);
  procedure sp_BatchRejection(p_branch_code in varchar2,
                              p_date        in date,
                              p_batch       in number,
                              p_user_id     in varchar2,
                              p_error       out varchar2);

  type Advice is record(
    gl_code   VARCHAR2(15),
    dr_amount NUMBER(18, 2),
    cr_amount NUMBER(18, 2),
    fin_year  varchar2(20));
  type v_Advice is table of Advice;

  type tbalance is record(
    branch    varchar2(10),
    TranHead  char(1),
    gl_code   varchar2(15),
    dr_amount number(18, 2),
    cr_amount number(18, 2),
    fin_year  varchar2(20));
  type V_tbalance is table of tbalance;

  type glregister is record(
    branch    varchar2(10),
    gl_code   varchar2(15),
    TranHead  char(1),
    gl_group  varchar2(15),
    dr_amount number(18, 2),
    cr_amount number(18, 2),
    fin_year  varchar2(20),
    lvlcode0  varchar2(9),
    lvlcode1  varchar2(9),
    lvlcode2  varchar2(9),
    lvlcode3  varchar2(9),
    lvlcode4  varchar2(9),
    lvlcode5  varchar2(9));
  type v_glregister is table of glregister;

  type ledger_statement is record(
    branch    varchar2(10),
    TRAN_DATE date,
    BATCH_NO  number(4),
    transl    number(4),
    gl_code   varchar2(15),
    gl_name   varchar2(100),
    dr_amount number(18, 2),
    cr_amount number(18, 2),
    cqnumber  varchar2(100),
    cq_date   varchar2(20),
    cq_ref    varchar2(100),
    narration varchar2(2000),
    fin_year  varchar2(20),
    dr_cr     varchar2(3),
    Balance   number(18, 2));
  type V_ledger_statement is table of ledger_statement;

  function fn_get_trail_balance(p_branch_code in varchar2) return V_tbalance
    pipelined;
  function fn_get_trail_balance_Current(p_branch_code in varchar2)
    return V_tbalance
    pipelined;
  function fn_get_voucher(p_branch_code in varchar2, p_date in date)
    return v_Advice
    pipelined;
  function fn_get_item_voucher(p_branch_code in varchar2,
                               p_item_code   in varchar2,
                               p_tran_amount in number,
                               p_date        in date,
                               p_remarks     in varchar2) return v_Advice
    pipelined;
  procedure sp_auto_item_post(p_branch_code in varchar2,
                              p_item_code   in varchar2,
                              p_tran_amount in number,
                              p_date        in date,
                              p_chq_no      in varchar2,
                              p_chq_date    in date,
                              p_reference   in varchar2,
                              p_remarks     in varchar2,
                              p_userId      in varchar2,
                              p_batch       out number,
                              p_error       out varchar2);
  procedure sp_Opening_Balance(p_branch  in varchar2,
                               p_glcode  in varchar2,
                               p_dr_cr   in varchar2,
                               p_balance in number,
                               p_FinYear in varchar2,
                               p_error   out varchar2);
  /*  procedure sp_Opening_Balance_new(p_branch     in varchar2,
  p_glcode     in varchar2,
  p_dr_cr      in varchar2,
  p_balance    in number,
  p_entry_date in date,
  p_error      out varchar2);*/
  function fn_get_ledger_register_by_lvl(p_branch_code in varchar2,
                                         p_gl_code     in varchar2)
    return v_glregister
    pipelined;
  function fn_get_ledger_register(p_branch_code in varchar2,
                                  p_gl_code     in varchar2)
    return v_glregister
    pipelined;
  function fn_get_tb_consolidated(p_branch_code in varchar2)
    return V_tbalance
    pipelined;

  function fn_get_ledger_satement(p_branch_code in varchar2,
                                  p_gl_code     in varchar2)
    return V_ledger_statement
    pipelined;
  function fn_get_tb_consolidated_old(p_branch_code in varchar2)
    return V_tbalance
    pipelined;
  procedure sp_update_balance(p_branch    in varchar2,
                              p_glcode    in varchar2,
                              p_dr_amount in number,
                              p_cr_amount in number,
                              p_error     out varchar2);
  procedure sp_loan_recovery(p_branch    in varchar2,
                             p_fin_year  in varchar2,
                             p_glcode    in varchar2,
                             p_principal in number,
                             p_interest  in number,
                             P_error     out varchar2);

  procedure sp_loan_recoverable(p_branch       in varchar2,
                                p_fin_year     in varchar2,
                                p_glcode       in varchar2,
                                p_principal    in number,
                                p_interest     in number,
                                p_principle_fd in number,
                                p_interest_fd  in number,
                                P_error        out varchar2);
  procedure sp_transaction_Entity_Updation(p_branch    in varchar2,
                                           p_tran_date in date,
                                           p_batch     in number,
                                           p_entity_sl in number,
                                           p_glcode    in varchar2,
                                           P_cqnumber  in varchar2,
                                           p_cq_ref    in varchar2,
                                           p_cq_date   in varchar2,
                                           p_narration in varchar2,
                                           p_remarks   in varchar2,
                                           p_user_id   in varchar2,
                                           P_error     out varchar2);

end pkg_gas;
/
create or replace package body pkg_gas is
  procedure sp_update_balance(p_branch    in varchar2,
                              p_glcode    in varchar2,
                              p_dr_amount in number,
                              p_cr_amount in number,
                              p_error     out varchar2) is
  begin
    for id1 in (SELECT *
                  FROM as_glcodelist b
                 where b.entity_num = 1
                   and b.glcode = p_glcode) loop
    
      update AS_GLBALANCE b
         set b.CUR_BAL = B.CUR_BAL - p_dr_amount + p_cr_amount
       where b.entity_num = 1
         and b.branch = p_branch
         and b.glcode = id1.glcode;
    
      if id1.lvlcode5 is not null then
        update AS_GLBALANCE b
           set b.CUR_BAL = B.CUR_BAL - p_dr_amount + p_cr_amount
         where b.entity_num = 1
           and b.branch = p_branch
           and b.glcode = id1.lvlcode5;
      end if;
    
      if id1.lvlcode4 is not null then
        update AS_GLBALANCE b
           set b.CUR_BAL = B.CUR_BAL - p_dr_amount + p_cr_amount
         where b.entity_num = 1
           and b.branch = p_branch
           and b.glcode = id1.lvlcode4;
      end if;
    
      if id1.lvlcode3 is not null then
        update AS_GLBALANCE b
           set b.CUR_BAL = B.CUR_BAL - p_dr_amount + p_cr_amount
         where b.entity_num = 1
           and b.branch = p_branch
           and b.glcode = id1.lvlcode3;
      end if;
    
      if id1.lvlcode2 is not null then
        update AS_GLBALANCE_HIST b
           set b.CUR_BAL = B.CUR_BAL - p_dr_amount + p_cr_amount
         where b.entity_num = 1
           and b.branch = p_branch
           and b.glcode = id1.lvlcode2;
      end if;
    
      if id1.lvlcode1 is not null then
        update AS_GLBALANCE b
           set b.CUR_BAL = B.CUR_BAL - p_dr_amount + p_cr_amount
         where b.entity_num = 1
           and b.branch = p_branch
           and b.glcode = id1.lvlcode1;
      end if;
    
      if id1.mainhead is not null then
        update AS_GLBALANCE b
           set b.CUR_BAL = B.CUR_BAL - p_dr_amount + p_cr_amount
         where b.entity_num = 1
           and b.branch = p_branch
           and b.gLcode = id1.mainhead;
      end if;
    end loop;
  exception
    when others then
      p_error := 'Error in ' || sqlerrm;
  end sp_update_balance;

  procedure sp_BatchChecked(p_branch_code in varchar2,
                            p_date        in date,
                            p_batch       in number,
                            p_user_id     in varchar2,
                            p_error       out varchar2) is
    v_auth_by  varchar2(12);
    v_rej_by   varchar2(12);
    v_auth_on  date;
    v_rej_on   date;
    v_check_on date;
    v_exist    number := 0;
  begin
  
    SELECT count(*)
      into v_exist
      FROM as_transaction_list l
     where l.entity_num = 1
       and l.orginated_branch = p_branch_code
       and l.tran_date = p_date
       and l.batch_no = p_batch;
  
    if v_exist > 0 then
      SELECT l.auth_by, l.auth_on, l.rej_by, l.rej_on, l.check_on
        into v_auth_by, v_auth_on, v_rej_by, v_rej_on, v_check_on
        FROM as_transaction_list l
       where l.entity_num = 1
         and l.orginated_branch = p_branch_code
         and l.tran_date = p_date
         and l.batch_no = p_batch;
      if v_rej_on is null then
        if v_auth_on is null then
          if v_check_on is null then
          
            update as_transaction_list l
               set l.check_by = p_user_id, l.check_on = trunc(sysdate)
             where l.entity_num = 1
               and l.orginated_branch = p_branch_code
               and l.tran_date = p_date
               and l.batch_no = p_batch;
          else
            p_error := 'Transaction Batch is already Validated';
          end if;
        else
          p_error := 'Transaction Batch is already Authorized';
        end if;
      else
        p_error := 'Transaction Batch is already rejected';
      end if;
    else
      p_error := 'No Transaction Batch is Found';
    end if;
  end sp_BatchChecked;

  procedure sp_BatchRejection(p_branch_code in varchar2,
                              p_date        in date,
                              p_batch       in number,
                              p_user_id     in varchar2,
                              p_error       out varchar2) is
    v_auth_by  varchar2(12);
    v_rej_by   varchar2(12);
    v_auth_on  date;
    v_rej_on   date;
    v_check_on date;
    v_exist    number := 0;
  begin
  
    SELECT count(*)
      into v_exist
      FROM as_transaction_list l
     where l.entity_num = 1
       and l.orginated_branch = p_branch_code
       and l.tran_date = p_date
       and l.batch_no = p_batch;
  
    if v_exist > 0 then
      SELECT l.auth_by, l.auth_on, l.rej_by, l.rej_on, l.check_on
        into v_auth_by, v_auth_on, v_rej_by, v_rej_on, v_check_on
        FROM as_transaction_list l
       where l.entity_num = 1
         and l.orginated_branch = p_branch_code
         and l.tran_date = p_date
         and l.batch_no = p_batch;
      if v_rej_on is null then
        if v_auth_on is null then
        
          update as_transaction_list l
             set l.rej_by = p_user_id, l.rej_on = trunc(sysdate)
           where l.entity_num = 1
             and l.orginated_branch = p_branch_code
             and l.tran_date = p_date
             and l.batch_no = p_batch;
        else
          p_error := 'Transaction Batch is already Authorized';
        end if;
      else
        p_error := 'Transaction Batch is already rejected';
      end if;
    else
      p_error := 'No Transaction Batch is Found';
    end if;
  end sp_BatchRejection;

  procedure sp_BatchAUthValidation(p_branch_code in varchar2,
                                   p_date        in date,
                                   p_batch       in number,
                                   p_user_id     in varchar2,
                                   p_error       out varchar2) is
  
    v_exist      number := 0;
    v_start_date date;
    v_end_date   date;
    v_fin_year   varchar2(12);
  begin
  
    SELECT b.fin_year, b.start_date, b.end_date
      into v_fin_year, v_start_date, v_end_date
      FROM as_finyear b
     where b.activatation = 'Y';
  
    SELECT count(*)
      into v_exist
      FROM as_transaction_list l
     where l.entity_num = 1
       and l.orginated_branch = p_branch_code
       and l.tran_date = p_date
       and l.batch_no = p_batch;
    if v_exist > 0 then
      if p_date between v_start_date and v_end_date then
        p_error := 'OK';
      else
        p_error := 'Only Transaction for the Financial Year ' || v_fin_year ||
                   ' is Authorizable !!';
      end if;
    else
      p_error := 'No Transaction Batch is Found';
    end if;
  
  end sp_BatchAUthValidation;
  procedure sp_BatchAUthorize_test(p_branch_code in varchar2,
                                   p_date        in date,
                                   p_batch       in number,
                                   p_user_id     in varchar2,
                                   p_error       out varchar2) is
    v_auth_by varchar2(12);
    v_rej_by  varchar2(12);
    v_auth_on date;
    v_rej_on  date;
    v_exist   number := 0;
    v_error   varchar2(200) := '';
  begin
  
    SELECT count(*)
      into v_exist
      FROM as_transaction_list l
     where l.entity_num = 1
       and l.orginated_branch = p_branch_code
       and l.tran_date = p_date
       and l.batch_no = p_batch;
    if p_date between '' and '' then
      null;
    end if;
    if v_exist > 0 then
      SELECT l.auth_by, l.auth_on, l.rej_by, l.rej_on
        into v_auth_by, v_auth_on, v_rej_by, v_rej_on
        FROM as_transaction_list l
       where l.entity_num = 1
         and l.orginated_branch = p_branch_code
         and l.tran_date = p_date
         and l.batch_no = p_batch;
    
      if v_rej_on is null then
        if v_auth_on is not null then
          for idx in (select *
                        from as_transaction t
                       where t.entity_num = 1
                         and t.branch = p_branch_code
                         and t.tran_date = p_date
                         and t.batch_no = p_batch) loop
            sp_update_balance(idx.branch,
                              idx.glcode,
                              idx.dr_amount,
                              idx.cr_amount,
                              v_error);
          end loop;
          update as_transaction_list l
             set l.auth_by = p_user_id, l.auth_on = trunc(sysdate)
           where l.entity_num = 1
             and l.orginated_branch = p_branch_code
             and l.tran_date = p_date
             and l.batch_no = p_batch;
        else
          p_error := 'Transaction Batch is already Authorized';
        end if;
      else
        p_error := 'Transaction Batch is already rejected';
      end if;
    else
      p_error := 'No Transaction Batch is Found';
    end if;
  end sp_BatchAUthorize_test;
  procedure sp_BatchAUthorize(p_branch_code in varchar2,
                              p_date        in date,
                              p_batch       in number,
                              p_user_id     in varchar2,
                              p_error       out varchar2) is
    v_auth_by varchar2(12);
    v_rej_by  varchar2(12);
    v_auth_on date;
    v_rej_on  date;
    v_exist   number := 0;
    v_error   varchar2(200) := '';
  begin
  
    SELECT count(*)
      into v_exist
      FROM as_transaction_list l
     where l.entity_num = 1
       and l.orginated_branch = p_branch_code
       and l.tran_date = p_date
       and l.batch_no = p_batch;
    if p_date between '' and '' then
      null;
    end if;
    if v_exist > 0 then
      SELECT l.auth_by, l.auth_on, l.rej_by, l.rej_on
        into v_auth_by, v_auth_on, v_rej_by, v_rej_on
        FROM as_transaction_list l
       where l.entity_num = 1
         and l.orginated_branch = p_branch_code
         and l.tran_date = p_date
         and l.batch_no = p_batch;
    
      if v_rej_on is null then
        if v_auth_on is null then
          for idx in (select *
                        from as_transaction t
                       where t.entity_num = 1
                         and t.branch = p_branch_code
                         and t.tran_date = p_date
                         and t.batch_no = p_batch) loop
            sp_update_balance(idx.branch,
                              idx.glcode,
                              idx.dr_amount,
                              idx.cr_amount,
                              v_error);
          end loop;
          update as_transaction_list l
             set l.auth_by = p_user_id, l.auth_on = trunc(sysdate)
           where l.entity_num = 1
             and l.orginated_branch = p_branch_code
             and l.tran_date = p_date
             and l.batch_no = p_batch;
        else
          p_error := 'Transaction Batch is already Authorized';
        end if;
      else
        p_error := 'Transaction Batch is already rejected';
      end if;
    else
      p_error := 'No Transaction Batch is Found';
    end if;
  end sp_BatchAUthorize;

  /*procedure sp_autopost_salary(p_branch_code in varchar2,
                               p_user_Id     in varchar2,
                               p_date        in date,
                               p_batch       out number,
                               p_error       out varchar2) is
    v_month_code number := 0;
    v_year       number := 0;
    v_debit      number := 0;
    v_credit     number := 0;
    v_bank_cr    number := 0;
    v_batch_no   number := 0;
    v_tranExist  number := 0;
  begin
  
    SELECT count(*)
      into v_tranExist
      FROM as_transaction_list l
     where l.entity_num = 1
       and l.orginated_branch = p_branch_code
       and last_day(l.tran_date) = last_day(p_date)
       and l.transaction_type = 'S';
  
    if v_tranExist = 0 then
      select max(s.batch_sl) + 1 batch_no
        into v_batch_no
        from as_batch_sl s
       where s.branch_code = p_branch_code
         and s.tran_date = trunc(p_date);
      select to_number(to_char(to_date(p_date, 'dd-mon-yy'), 'mm'))
        into v_month_code
        from dual;
      select to_number(to_char(p_date, 'YYYY')) into v_year from dual;
    
      for idx in (select sum(t.basic_pay) basic_pay,
                         sum(nvl(t.arrear_basic, 0)) arrear_basic,
                         sum(nvl(t.house_rent_allowance, 0)) house_rent_allowance,
                         sum(nvl(t.arrear, 0)) arrear,
                         sum(nvl(t.tel_allowance, 0)) tel_allowance,
                         sum(nvl(t.trans_allowance, 0)) trans_allowance,
                         sum(nvl(t.edu_allowance, 0)) edu_allowance,
                         sum(nvl(t.wash_allowance, 0)) wash_allowance,
                         sum(nvl(t.entertainment, 0)) entertainment,
                         sum(nvl(t.domestic_allowance, 0)) domestic_allowance,
                         sum(nvl(t.hill_allwnc, 0)) hill_allwnc,
                         sum(t.other_allowance) other_allowance,
                         sum(t.pension_allowance) pension_allowance,
                         sum(t.medical_allowance) medical_allowance,
                         sum(t.tot_sal_allowance) tot_sal_allowance,
                         sum(t.gross_pay_amt) gross_pay_amt,
                         sum(t.pfadv_deduc) pfadv_deduc,
                         sum(t.pf_deduction) pf_deduction,
                         sum(t.pfadv_arrear_deduc) pfadv_arrear_deduc,
                         sum(t.hbadv_deduc) hbadv_deduc,
                         sum(t.hbadv_deduc_percent) hbadv_deduc_percent,
                         sum(t.hbadv_arrear_deduc) hbadv_arrear_deduc,
                         sum(t.welfare_deduc) welfare_deduc,
                         sum(t.mcycle_deduc) mcycle_deduc,
                         sum(t.bicycle_deduc) bicycle_deduc,
                         sum(t.comp_deduc) comp_deduc,
                         sum(t.carfare_deduc) carfare_deduc,
                         sum(t.caruse_deduc) caruse_deduc,
                         sum(t.gas_bill) gas_bill,
                         sum(t.water_bill) water_bill,
                         sum(t.electricity_bill) electricity_bill,
                         sum(t.news_paper_deduc) news_paper_deduc,
                         sum(t.tel_excess_bill) tel_excess_bill,
                         sum(t.gen_insurence) gen_insurence,
                         sum(t.other_deduc) other_deduc,
                         sum(t.revenue_deduc) revenue_deduc,
                         sum(t.sp_deduc) sp_deduc,
                         sum(t.pension_deduc) pension_deduc,
                         sum(nvl(t.net_ded_amt, 0)) net_ded_amt,
                         sum(nvl(t.net_pay_amt, 0)) net_pay_amt,
                         sum(income_tax) income_tax,
                         sum(income_tax_arr) income_tax_arr
                    from prms_transaction t
                   where entity_number = 1
                     and t.branch_code = p_branch_code
                     and sal_year = v_year
                     and month_code = v_month_code) loop
      
        if idx.basic_pay > 0 then
          insert into as_transaction
            (entity_num,
             orginated_branch,
             office_code,
             tran_date,
             glcode,
             dr_amount,
             cr_amount,
             batch_no,
             naration)
          values
            (1,
             p_branch_code,
             p_branch_code,
             p_date,
             '101101',
             idx.basic_pay,
             0,
             v_batch_no,
             'Auto posting from PRMS');
          v_debit := v_debit + idx.basic_pay;
        end if;
      
        if idx.medical_allowance > 0 then
          insert into a_transaction
            (entity_num,
             orginated_branch,
             office_code,
             tran_date,
             glcode,
             dr_amount,
             cr_amount,
             batch_no,
             naration)
          values
            (1,
             p_branch_code,
             p_branch_code,
             p_date,
             '101103',
             idx.medical_allowance,
             0,
             v_batch_no,
             'Auto posting from PRMS');
          v_debit := v_debit + idx.medical_allowance;
        end if;
      
        if idx.house_rent_allowance > 0 then
          insert into a_transaction
            (entity_num,
             orginated_branch,
             office_code,
             tran_date,
             glcode,
             dr_amount,
             cr_amount,
             batch_no,
             naration)
          values
            (1,
             p_branch_code,
             p_branch_code,
             p_date,
             '101104',
             idx.house_rent_allowance,
             0,
             v_batch_no,
             'Auto posting from PRMS');
          v_debit := v_debit + idx.house_rent_allowance;
        end if;
      
        if idx.edu_allowance > 0 then
          insert into a_transaction
            (entity_num,
             orginated_branch,
             office_code,
             tran_date,
             glcode,
             dr_amount,
             cr_amount,
             batch_no,
             naration)
          values
            (1,
             p_branch_code,
             p_branch_code,
             p_date,
             '101106',
             idx.edu_allowance,
             0,
             v_batch_no,
             'Auto posting from PRMS');
          v_debit := v_debit + idx.edu_allowance;
        end if;
      
        if idx.tel_allowance > 0 then
          insert into a_transaction
            (entity_num,
             orginated_branch,
             office_code,
             tran_date,
             glcode,
             dr_amount,
             cr_amount,
             batch_no,
             naration)
          values
            (1,
             p_branch_code,
             p_branch_code,
             p_date,
             '101109',
             idx.tel_allowance,
             0,
             v_batch_no,
             'Auto posting from PRMS');
          v_debit := v_debit + idx.tel_allowance;
        end if;
      
        if idx.pension_allowance > 0 then
          insert into a_transaction
            (entity_num,
             orginated_branch,
             office_code,
             tran_date,
             glcode,
             dr_amount,
             cr_amount,
             batch_no,
             naration)
          values
            (1,
             p_branch_code,
             p_branch_code,
             p_date,
             '101108',
             idx.pension_allowance,
             0,
             v_batch_no,
             'Auto posting from PRMS');
          v_debit := v_debit + idx.pension_allowance;
        end if;
      
        if idx.entertainment > 0 then
          insert into a_transaction
            (entity_num,
             orginated_branch,
             office_code,
             tran_date,
             glcode,
             dr_amount,
             cr_amount,
             batch_no,
             naration)
          values
            (1,
             p_branch_code,
             p_branch_code,
             p_date,
             '101107',
             idx.entertainment,
             0,
             v_batch_no,
             'Auto posting from PRMS');
          v_debit := v_debit + idx.entertainment;
        end if;
        if idx.hbadv_deduc > 0 then
          insert into a_transaction
            (entity_num,
             orginated_branch,
             office_code,
             tran_date,
             glcode,
             dr_amount,
             cr_amount,
             batch_no,
             naration)
          values
            (1,
             p_branch_code,
             p_branch_code,
             p_date,
             '102103',
             0,
             idx.hbadv_deduc,
             v_batch_no,
             'Auto posting from PRMS');
          v_credit := v_credit + idx.hbadv_deduc;
        end if;
      
        if idx.comp_deduc > 0 then
          insert into a_transaction
            (entity_num,
             orginated_branch,
             office_code,
             tran_date,
             glcode,
             dr_amount,
             cr_amount,
             batch_no,
             naration)
          values
            (1,
             p_branch_code,
             p_branch_code,
             p_date,
             '102105',
             0,
             idx.comp_deduc,
             v_batch_no,
             'Auto posting from PRMS');
          v_credit := v_credit + idx.comp_deduc;
        end if;
      
        if idx.mcycle_deduc > 0 then
          insert into a_transaction
            (entity_num,
             orginated_branch,
             office_code,
             tran_date,
             glcode,
             dr_amount,
             cr_amount,
             batch_no,
             naration)
          values
            (1,
             p_branch_code,
             p_branch_code,
             p_date,
             '102104',
             0,
             idx.mcycle_deduc,
             v_batch_no,
             'Auto posting from PRMS');
          v_credit := v_credit + idx.mcycle_deduc;
        end if;
      
        v_bank_cr := v_debit - v_credit;
        insert into a_transaction
          (entity_num,
           orginated_branch,
           office_code,
           tran_date,
           glcode,
           dr_amount,
           cr_amount,
           batch_no,
           naration)
        values
          (1,
           p_branch_code,
           p_branch_code,
           p_date,
           '102101',
           0,
           v_bank_cr,
           v_batch_no,
           'Auto posting from PRMS');
        v_credit := v_credit + v_bank_cr;
      
        update a_batch_sl s
           set s.batch_sl = v_batch_no
         where s.branch_code = p_branch_code
           and s.tran_date = trunc(p_date);
      
        insert into a_transaction_list
          (entity_num,
           orginated_branch,
           tran_date,
           batch_no,
           transaction_type,
           remarks,
           dr_amount,
           cr_amount,
           enty_by,
           enty_on)
        values
          (1,
           p_branch_code,
           trunc(p_date),
           v_batch_no,
           'S',
           'Auto posting from PRMS to General Accounts',
           v_debit,
           v_credit,
           'Auto',
           trunc(p_date));
      
      end loop;
    
    else
      p_error := 'Auto posting Already done for this month';
    end if;
    p_batch := v_batch_no;
  exception
    when others then
    
      p_error := 'Error in sp_autopost_salary';
  end sp_autopost_salary;*/

  procedure sp_auto_item_post(p_branch_code in varchar2,
                              p_item_code   in varchar2,
                              p_tran_amount in number,
                              p_date        in date,
                              p_chq_no      in varchar2,
                              p_chq_date    in date,
                              p_reference   in varchar2,
                              p_remarks     in varchar2,
                              p_userId      in varchar2,
                              p_batch       out number,
                              p_error       out varchar2) is
  
    v_batch_no number := 0;
    p_postType varchar2(4):='';
  begin
    
   pkg_param.sp_off_day_check(p_date,p_postType);
  
  if p_postType='Y' then
  
    select max(s.batch_sl) + 1 batch_no
      into v_batch_no
      from as_batch_sl s
     where s.branch_code = p_branch_code
       and s.tran_date = trunc(p_date);
    if v_batch_no is null then
      p_error := 'Day Begin Process is not Run';
    else
      for idx in (select *
                    from as_itemlist l
                   where l.entity = 1
                     and l.branch_code = p_branch_code
                     and l.item_code = p_item_code) loop
      
        insert into as_transaction
          (entity_num,
           branch,
           tran_date,
           glcode,
           tran_sl,
           dr_amount,
           cr_amount,
           batch_no,
           naration,
           pf_number,
           chq_number,
           chq_date,
           chq_reference)
        values
          (1,
           p_branch_code,
           p_date,
           idx.credit_gl,
           1,
           0,
           p_tran_amount,
           v_batch_no,
           'Credit for :' || idx.item_desc,
           '',
           p_chq_no,
           p_chq_date,
           p_reference);
      
        insert into as_transaction
          (entity_num,
           branch,
           tran_date,
           glcode,
           tran_sl,
           dr_amount,
           cr_amount,
           batch_no,
           naration,
           pf_number,
           chq_number,
           chq_date,
           chq_reference)
        values
          (1,
           p_branch_code,
           p_date,
           idx.debit_gl,
           2,
           p_tran_amount,
           0,
           v_batch_no,
           'Debit for :' || idx.item_desc,
           '',
           p_chq_no,
           p_chq_date,
           p_reference);
        insert into as_transaction_list
          (entity_num,
           orginated_branch,
           tran_date,
           batch_no,
           transaction_type,
           remarks,
           dr_amount,
           cr_amount,
           enty_by,
           enty_on)
        values
          (1,
           p_branch_code,
           trunc(p_date),
           v_batch_no,
           'V',
           p_remarks,
           p_tran_amount,
           p_tran_amount,
           p_userId,
           trunc(p_date));
      
        update as_batch_sl s
           set s.batch_sl = v_batch_no
         where s.branch_code = p_branch_code
           and s.tran_date = trunc(p_date);
      
      end loop;
      p_batch := v_batch_no;
    end if;
    
    else
      p_error:='This is is Holiday !! Transaction is open only for On Day';   
    end if;
  
  Exception
    When Others then
      p_error := 'Error in sp_auto_item_post' || sqlerrm;
  end sp_auto_item_post;

  function fn_get_trail_balance_Current(p_branch_code in varchar2)
    return V_tbalance
    pipelined is
  
    w_tbalance tbalance;
  
  begin
    for in1 in (SELECT b.*
                  FROM as_glbalance b, as_glcodelist l
                 where b.branch = p_branch_code
                   and b.glcode = l.glcode
                   AND L.TB_YN = 'Y'
                -- AND L.GLCODE NOT LIKE '161%'
                ) loop
    
      w_tbalance.gl_code  := in1.glcode;
      w_tbalance.fin_year := in1.fin_year;
      if in1.cur_bal >= 0 then
        w_tbalance.cr_amount := in1.cur_bal;
        w_tbalance.dr_amount := 0;
      else
        w_tbalance.cr_amount := 0;
        w_tbalance.dr_amount := -1 * in1.cur_bal;
      end if;
    
      pipe row(w_tbalance);
      --  if in1.cur_bal <> 0 then
    --   pipe row(w_tbalance);
    -- END IF;
    end loop;
  
    /*for in1 in (SELECT b.*
                  FROM a_glbalance b, a_glcodelist l
                 where b.gl_branch = p_branch_code
                   and b.gl_code = l.glcode
                   and l.sub_gl = '0'
                   and b.gl_cur_bal <> 0) loop
    
      if in1.gl_code = '220000000' or in1.gl_code = '380000000' or
         in1.gl_code = '410000000' then
      
        w_tbalance.gl_code := in1.gl_code;
        if in1.gl_cur_bal >= 0 then
          w_tbalance.cr_amount := in1.gl_cur_bal;
          w_tbalance.dr_amount := 0;
        else
          w_tbalance.cr_amount := 0;
          w_tbalance.dr_amount := -1 * in1.gl_cur_bal;
        end if;
      
        pipe row(w_tbalance);
      end if;
    end loop;*/
  
  end fn_get_trail_balance_Current;

  function fn_get_ledger_register_by_lvl(p_branch_code in varchar2,
                                         p_gl_code     in varchar2)
    return v_glregister
    pipelined is
    w_glregister glregister;
  
  begin
    for in1 in (SELECT b.glcode,
                       l.glname,
                       b.cur_bal,
                       l.tran_yn,
                       l.lvlcode5,
                       l.lvlcode4,
                       l.lvlcode3,
                       l.lvlcode2,
                       l.lvlcode1,
                       l.mainhead
                  FROM as_glbalance b
                  join as_glcodelist l
                    on (b.glcode = l.glcode)
                 where b.branch = p_branch_code
                   and l.mainhead = p_gl_code
                   and b.cur_bal <> 0) loop
      w_glregister.gl_code  := in1.glcode;
      w_glregister.fin_year := '2020-2021';
      w_glregister.lvlcode0 := in1.mainhead;
      w_glregister.lvlcode1 := in1.lvlcode1;
      w_glregister.lvlcode2 := in1.lvlcode2;
      w_glregister.lvlcode3 := in1.lvlcode3;
      w_glregister.lvlcode4 := in1.lvlcode4;
      w_glregister.lvlcode5 := in1.lvlcode5;
    
      if in1.cur_bal >= 0 then
        w_glregister.cr_amount := in1.cur_bal;
        w_glregister.dr_amount := 0;
      else
        w_glregister.cr_amount := 0;
        w_glregister.dr_amount := -1 * in1.cur_bal;
      end if;
      pipe row(w_glregister);
    end loop;
  
  end fn_get_ledger_register_by_lvl;

  function fn_get_ledger_register(p_branch_code in varchar2,
                                  p_gl_code     in varchar2)
    return v_glregister
    pipelined is
    w_glregister glregister;
    v_lvl1       number := 0;
    v_lvl2       number := 0;
    v_lvl3       number := 0;
    v_lvl4       number := 0;
  begin
    for in1 in (SELECT b.glcode,
                       l.glname,
                       b.cur_bal,
                       L.TRAN_YN,
                       l.lvlcode5,
                       l.lvlcode4,
                       l.lvlcode3,
                       l.lvlcode2,
                       l.lvlcode1,
                       l.mainhead
                  FROM as_glbalance b
                  join as_glcodelist l
                    on (b.glcode = l.glcode)
                 where b.branch = p_branch_code
                   and b.glcode = p_gl_code
                   and b.cur_bal <> 0) loop
      w_glregister.gl_code  := in1.glcode;
      w_glregister.TranHead := '0';
      w_glregister.fin_year := '2020-2021';
      w_glregister.lvlcode0 := p_gl_code;
      w_glregister.lvlcode1 := in1.lvlcode1;
      w_glregister.lvlcode2 := in1.lvlcode2;
      w_glregister.lvlcode3 := in1.lvlcode3;
      w_glregister.lvlcode4 := in1.lvlcode4;
      w_glregister.lvlcode5 := in1.lvlcode5;
    
      if in1.cur_bal >= 0 then
        w_glregister.cr_amount := in1.cur_bal;
        w_glregister.dr_amount := 0;
      else
        w_glregister.cr_amount := 0;
        w_glregister.dr_amount := -1 * in1.cur_bal;
      end if;
      pipe row(w_glregister);
    end loop;
  
    if p_gl_code = '172000000' or p_gl_code = '173000000' or
       p_gl_code = '171000000' then
      for in1 in (SELECT b.glcode,
                         l.glname,
                         b.cur_bal,
                         l.tran_yn,
                         l.lvlcode5,
                         l.lvlcode4,
                         l.lvlcode3,
                         l.lvlcode2,
                         l.lvlcode1,
                         l.mainhead
                    FROM as_glbalance b
                    join as_glcodelist l
                      on (b.glcode = l.glcode)
                   where b.branch = p_branch_code
                     and l.lvlcode1 = p_gl_code
                     and l.tran_yn = 'Y'
                     and b.cur_bal <> 0) loop
        w_glregister.gl_code  := in1.glcode;
        w_glregister.fin_year := '2020-2021';
        w_glregister.lvlcode0 := in1.mainhead;
        w_glregister.lvlcode1 := in1.lvlcode1;
        w_glregister.lvlcode2 := in1.lvlcode2;
        w_glregister.lvlcode3 := in1.lvlcode3;
        w_glregister.lvlcode4 := in1.lvlcode4;
        w_glregister.lvlcode5 := in1.lvlcode5;
      
        if in1.tran_yn = 'Y' then
          w_glregister.tranhead := '6';
        else
        
          SELECT count(*)
            into v_lvl1
            FROM as_glcodelist l
           where l.lvlcode1 = in1.glcode;
          if v_lvl1 > 0 then
            w_glregister.tranhead := '1';
          else
            SELECT count(*)
              into v_lvl2
              FROM as_glcodelist l
             where l.lvlcode2 = in1.glcode;
          
            if v_lvl2 > 0 then
              w_glregister.tranhead := '2';
            else
              SELECT count(*)
                into v_lvl3
                FROM as_glcodelist l
               where l.lvlcode3 = in1.glcode;
            
              if v_lvl3 > 0 then
                w_glregister.tranhead := '3';
              else
                SELECT count(*)
                  into v_lvl4
                  FROM as_glcodelist l
                 where l.lvlcode4 = in1.glcode;
                if v_lvl4 > 0 then
                  w_glregister.tranhead := '4';
                else
                  w_glregister.tranhead := '5';
                end if;
              
              end if;
            
            end if;
          
          end if;
        
        end if;
      
        if in1.cur_bal >= 0 then
          w_glregister.cr_amount := in1.cur_bal;
          w_glregister.dr_amount := 0;
        else
          w_glregister.cr_amount := 0;
          w_glregister.dr_amount := -1 * in1.cur_bal;
        end if;
        pipe row(w_glregister);
      end loop;
    else
      for in1 in (SELECT b.glcode,
                         l.glname,
                         b.cur_bal,
                         l.tran_yn,
                         l.lvlcode5,
                         l.lvlcode4,
                         l.lvlcode3,
                         l.lvlcode2,
                         l.lvlcode1,
                         l.mainhead
                  
                    FROM as_glbalance b
                    join as_glcodelist l
                      on (b.glcode = l.glcode)
                   where b.branch = p_branch_code
                     and l.mainhead = p_gl_code
                     and l.tran_yn = 'Y'
                     and b.cur_bal <> 0) loop
        w_glregister.gl_code  := in1.glcode;
        w_glregister.fin_year := '2020-2021';
        w_glregister.lvlcode0 := in1.mainhead;
        w_glregister.lvlcode1 := in1.lvlcode1;
        w_glregister.lvlcode2 := in1.lvlcode2;
        w_glregister.lvlcode3 := in1.lvlcode3;
        w_glregister.lvlcode4 := in1.lvlcode4;
        w_glregister.lvlcode5 := in1.lvlcode5;
      
        if in1.tran_yn = 'Y' then
          w_glregister.tranhead := '6';
        else
        
          SELECT count(*)
            into v_lvl1
            FROM as_glcodelist l
           where l.lvlcode1 = in1.glcode;
          if v_lvl1 > 0 then
            w_glregister.tranhead := '1';
          else
            SELECT count(*)
              into v_lvl2
              FROM as_glcodelist l
             where l.lvlcode2 = in1.glcode;
          
            if v_lvl2 > 0 then
              w_glregister.tranhead := '2';
            else
              SELECT count(*)
                into v_lvl3
                FROM as_glcodelist l
               where l.lvlcode3 = in1.glcode;
            
              if v_lvl3 > 0 then
                w_glregister.tranhead := '3';
              else
                SELECT count(*)
                  into v_lvl4
                  FROM as_glcodelist l
                 where l.lvlcode4 = in1.glcode;
                if v_lvl4 > 0 then
                  w_glregister.tranhead := '4';
                else
                  w_glregister.tranhead := '5';
                end if;
              
              end if;
            
            end if;
          
          end if;
        
        end if;
      
        if in1.cur_bal >= 0 then
          w_glregister.cr_amount := in1.cur_bal;
          w_glregister.dr_amount := 0;
        else
          w_glregister.cr_amount := 0;
          w_glregister.dr_amount := -1 * in1.cur_bal;
        end if;
        pipe row(w_glregister);
      end loop;
    end if;
  
  end fn_get_ledger_register;

  function fn_get_trail_balance(p_branch_code in varchar2) return V_tbalance
    pipelined is
  
    w_tbalance tbalance;
  
  begin
    /*for in1 in (SELECT b.*
                  FROM as_glbalance_hist b, as_glcodelist l
                 where b.branch = p_branch_code
                   and b.glcode = l.glcode
                  AND L.TB_YN='Y') loop
    
      w_tbalance.gl_code  := in1.glcode;
      w_tbalance.fin_year := '2020-2021';
      if in1.cur_bal >= 0 then
        w_tbalance.cr_amount := in1.cur_bal;
        w_tbalance.dr_amount := 0;
      else
        w_tbalance.cr_amount := 0;
        w_tbalance.dr_amount := -1 * in1.cur_bal;
      end if;
    
      pipe row(w_tbalance);
    end loop;*/
  
    for in1 in (SELECT b.*
                  FROM as_glbalance_hist b, as_glcodelist l
                 where b.branch = p_branch_code
                   and b.glcode = l.glcode
                   AND L.Tran_Yn = 'Y') loop
    
      w_tbalance.gl_code  := in1.glcode;
      w_tbalance.fin_year := '2019-2020';
      if in1.cur_bal >= 0 then
        w_tbalance.cr_amount := in1.cur_bal;
        w_tbalance.dr_amount := 0;
      else
        w_tbalance.cr_amount := 0;
        w_tbalance.dr_amount := -1 * in1.cur_bal;
      end if;
      if in1.cur_bal <> 0 then
        pipe row(w_tbalance);
      end if;
    end loop;
  
  end fn_get_trail_balance;

  function fn_get_tb_consolidated(p_branch_code in varchar2)
    return V_tbalance
    pipelined is
  
    w_tbalance tbalance;
  
  begin
    for in1 in (SELECT b.*
                  FROM as_glbalance b, as_glcodelist l
                 where b.glcode = l.glcode
                   and l.tb_yn = 'Y'
                --  and b.cur_bal <> 0
                
                ) loop
      w_tbalance.branch   := in1.branch;
      w_tbalance.gl_code  := in1.glcode;
      w_tbalance.fin_year := in1.fin_year;
      if in1.cur_bal >= 0 then
        w_tbalance.cr_amount := in1.cur_bal;
        w_tbalance.dr_amount := 0;
      else
        w_tbalance.cr_amount := 0;
        w_tbalance.dr_amount := -1 * in1.cur_bal;
      end if;
    
      pipe row(w_tbalance);
    end loop;
  end fn_get_tb_consolidated;

  function fn_get_tb_consolidated_old(p_branch_code in varchar2)
    return V_tbalance
    pipelined is
  
    w_tbalance tbalance;
  
  begin
    for in1 in (SELECT b.*
                  FROM as_glbalance_hist b, as_glcodelist l
                 where b.glcode = l.glcode
                   and l.tb_yn = 'Y'
                   and b.cur_bal <> 0
                   and b.branch in (p_branch_code)) loop
      w_tbalance.branch   := in1.branch;
      w_tbalance.gl_code  := in1.glcode;
      w_tbalance.fin_year := in1.fin_year;
      if in1.cur_bal >= 0 then
        w_tbalance.cr_amount := in1.cur_bal;
        w_tbalance.dr_amount := 0;
      else
        w_tbalance.cr_amount := 0;
        w_tbalance.dr_amount := -1 * in1.cur_bal;
      end if;
    
      pipe row(w_tbalance);
    end loop;
  end fn_get_tb_consolidated_old;
  function fn_get_item_voucher(p_branch_code in varchar2,
                               p_item_code   in varchar2,
                               p_tran_amount in number,
                               p_date        in date,
                               p_remarks     in varchar2) return v_Advice
    pipelined is
    w_Advice Advice;
  begin
  
    for idx in (select *
                  from as_itemlist l
                 where l.entity = 1
                   and l.branch_code = p_branch_code
                   and l.item_code = p_item_code) loop
      w_Advice.gl_code   := idx.debit_gl;
      w_Advice.dr_amount := p_tran_amount;
      w_Advice.cr_amount := 0;
      pipe row(w_Advice);
    
      w_Advice.gl_code   := idx.credit_gl;
      w_Advice.dr_amount := 0;
      w_Advice.cr_amount := p_tran_amount;
      pipe row(w_Advice);
      dbms_output.put_line(p_remarks);
    end loop;
  
  end fn_get_item_voucher;

  function fn_get_voucher(p_branch_code in varchar2, p_date in date)
    return v_Advice
    pipelined is
    w_Advice     Advice;
    v_month_code number := 0;
    v_year       number := 0;
    v_debit      number := 0;
    v_credit     number := 0;
    v_bank_cr    number := 0;
  begin
    select to_number(to_char(to_date(p_date, 'dd-mon-yy'), 'mm'))
      into v_month_code
      from dual;
    select to_number(to_char(p_date, 'YYYY')) into v_year from dual;
  
    for idx in (select sum(t.basic_pay) basic_pay,
                       sum(nvl(t.arrear_basic, 0)) arrear_basic,
                       sum(nvl(t.house_rent_allowance, 0)) house_rent_allowance,
                       sum(nvl(t.arrear, 0)) arrear,
                       sum(nvl(t.tel_allowance, 0)) tel_allowance,
                       sum(nvl(t.trans_allowance, 0)) trans_allowance,
                       sum(nvl(t.edu_allowance, 0)) edu_allowance,
                       sum(nvl(t.wash_allowance, 0)) wash_allowance,
                       sum(nvl(t.entertainment, 0)) entertainment,
                       sum(nvl(t.domestic_allowance, 0)) domestic_allowance,
                       sum(nvl(t.hill_allwnc, 0)) hill_allwnc,
                       sum(t.other_allowance) other_allowance,
                       sum(t.pension_allowance) pension_allowance,
                       sum(t.medical_allowance) medical_allowance,
                       sum(t.tot_sal_allowance) tot_sal_allowance,
                       sum(t.gross_pay_amt) gross_pay_amt,
                       sum(t.pfadv_deduc) pfadv_deduc,
                       sum(t.pf_deduction) pf_deduction,
                       sum(t.pfadv_arrear_deduc) pfadv_arrear_deduc,
                       sum(t.hbadv_deduc) hbadv_deduc,
                       sum(t.hbadv_deduc_percent) hbadv_deduc_percent,
                       sum(t.hbadv_arrear_deduc) hbadv_arrear_deduc,
                       sum(t.welfare_deduc) welfare_deduc,
                       sum(t.mcycle_deduc) mcycle_deduc,
                       sum(t.bicycle_deduc) bicycle_deduc,
                       sum(t.comp_deduc) comp_deduc,
                       sum(t.carfare_deduc) carfare_deduc,
                       sum(t.caruse_deduc) caruse_deduc,
                       sum(t.gas_bill) gas_bill,
                       sum(t.water_bill) water_bill,
                       sum(t.electricity_bill) electricity_bill,
                       sum(t.news_paper_deduc) news_paper_deduc,
                       sum(t.tel_excess_bill) tel_excess_bill,
                       sum(t.gen_insurence) gen_insurence,
                       sum(t.other_deduc) other_deduc,
                       sum(t.revenue_deduc) revenue_deduc,
                       sum(t.sp_deduc) sp_deduc,
                       sum(t.pension_deduc) pension_deduc,
                       sum(nvl(t.net_ded_amt, 0)) net_ded_amt,
                       sum(nvl(t.net_pay_amt, 0)) net_pay_amt,
                       sum(income_tax) income_tax,
                       sum(income_tax_arr) income_tax_arr
                  from prms_transaction t
                 where entity_number = 1
                   and t.branch_code = p_branch_code
                   and sal_year = v_year
                   and month_code = v_month_code) loop
    
      if idx.basic_pay > 0 then
        v_debit            := v_debit + idx.basic_pay;
        w_Advice.gl_code   := '101101';
        w_Advice.dr_amount := idx.basic_pay;
        w_Advice.cr_amount := 0;
        pipe row(w_Advice);
      end if;
    
      if idx.medical_allowance > 0 then
        v_debit            := v_debit + idx.medical_allowance;
        w_Advice.gl_code   := '101103';
        w_Advice.dr_amount := idx.medical_allowance;
        w_Advice.cr_amount := 0;
        pipe row(w_Advice);
      
      end if;
    
      if idx.house_rent_allowance > 0 then
        v_debit            := v_debit + idx.house_rent_allowance;
        w_Advice.gl_code   := '101104';
        w_Advice.dr_amount := idx.house_rent_allowance;
        w_Advice.cr_amount := 0;
        pipe row(w_Advice);
      
      end if;
    
      if idx.edu_allowance > 0 then
        v_debit            := v_debit + idx.edu_allowance;
        w_Advice.gl_code   := '101106';
        w_Advice.dr_amount := idx.edu_allowance;
        w_Advice.cr_amount := 0;
        pipe row(w_Advice);
      
      end if;
    
      if idx.tel_allowance > 0 then
        v_debit            := v_debit + idx.tel_allowance;
        w_Advice.gl_code   := '101109';
        w_Advice.dr_amount := idx.tel_allowance;
        w_Advice.cr_amount := 0;
        pipe row(w_Advice);
      end if;
    
      if idx.pension_allowance > 0 then
        v_debit            := v_debit + idx.pension_allowance;
        w_Advice.gl_code   := '101108';
        w_Advice.dr_amount := idx.pension_allowance;
        w_Advice.cr_amount := 0;
        pipe row(w_Advice);
      end if;
    
      if idx.entertainment > 0 then
        v_debit            := v_debit + idx.entertainment;
        w_Advice.gl_code   := '101107';
        w_Advice.dr_amount := idx.entertainment;
        w_Advice.cr_amount := 0;
        pipe row(w_Advice);
      end if;
      if idx.hbadv_deduc > 0 then
        v_credit           := v_credit + idx.hbadv_deduc;
        w_Advice.gl_code   := '102103';
        w_Advice.dr_amount := 0;
        w_Advice.cr_amount := idx.hbadv_deduc;
        pipe row(w_Advice);
      
      end if;
    
      if idx.comp_deduc > 0 then
        v_credit           := v_credit + idx.comp_deduc;
        w_Advice.gl_code   := '102105';
        w_Advice.dr_amount := 0;
        w_Advice.cr_amount := idx.comp_deduc;
        pipe row(w_Advice);
      end if;
    
      if idx.mcycle_deduc > 0 then
        v_credit           := v_credit + idx.mcycle_deduc;
        w_Advice.gl_code   := '102104';
        w_Advice.dr_amount := 0;
        w_Advice.cr_amount := idx.mcycle_deduc;
        pipe row(w_Advice);
      end if;
    
      v_bank_cr          := v_debit - v_credit;
      w_Advice.gl_code   := '102101';
      w_Advice.dr_amount := 0;
      w_Advice.cr_amount := v_bank_cr;
      v_credit           := v_credit + v_bank_cr;
      pipe row(w_Advice);
    
    end loop;
  end fn_get_voucher;

  procedure sp_Opening_Balance(p_branch  in varchar2,
                               p_glcode  in varchar2,
                               p_dr_cr   in varchar2,
                               p_balance in number,
                               p_FinYear in varchar2,
                               p_error   out varchar2) is
    v_balance number(12, 2) := 0;
  begin
    if p_dr_cr = 'D' then
      v_balance := -1 * p_balance;
    else
      v_balance := p_balance;
    end if;
    for id1 in (SELECT *
                  FROM AS_glcodelist l
                 where l.entity_num = 1
                   and l.glcode = p_glcode) loop
    
      update AS_GLBALANCE_HIST b
         set b.CUR_BAL = B.CUR_BAL + v_balance
       where b.entity_num = 1
         and b.branch = p_branch
         and b.glcode = id1.glcode
         and b.fin_year = p_FinYear;
    
      if id1.lvlcode5 is not null then
        update AS_GLBALANCE_HIST b
           set b.CUR_BAL = b.CUR_BAL + v_balance
         where b.entity_num = 1
           and b.branch = p_branch
           and b.glcode = id1.lvlcode5
           and b.fin_year = p_FinYear;
      end if;
    
      if id1.lvlcode4 is not null then
        update AS_GLBALANCE_HIST b
           set b.CUR_BAL = b.CUR_BAL + v_balance
         where b.entity_num = 1
           and b.branch = p_branch
           and b.glcode = id1.lvlcode4
           and b.fin_year = p_FinYear;
      end if;
    
      if id1.lvlcode3 is not null then
        update AS_GLBALANCE_HIST b
           set b.CUR_BAL = b.CUR_BAL + v_balance
         where b.entity_num = 1
           and b.branch = p_branch
           and b.glcode = id1.lvlcode3
           and b.fin_year = p_FinYear;
      end if;
    
      if id1.lvlcode2 is not null then
        update AS_GLBALANCE_HIST b
           set b.CUR_BAL = b.CUR_BAL + v_balance
         where b.entity_num = 1
           and b.branch = p_branch
           and b.glcode = id1.lvlcode2
           and b.fin_year = p_FinYear;
      end if;
    
      if id1.lvlcode1 is not null then
        update AS_GLBALANCE_HIST b
           set b.CUR_BAL = b.CUR_BAL + v_balance
         where b.entity_num = 1
           and b.branch = p_branch
           and b.glcode = id1.lvlcode1
           and b.fin_year = p_FinYear;
      end if;
    
      if id1.mainhead is not null then
        update AS_GLBALANCE_HIST b
           set b.CUR_BAL = b.CUR_BAL + v_balance
         where b.entity_num = 1
           and b.branch = p_branch
           and b.gLcode = id1.mainhead
           and b.fin_year = p_FinYear;
      end if;
    
    end loop;
  
  exception
    when others then
      p_error := 'Error in sp_Opening_Balance' || sqlerrm;
  end sp_Opening_Balance;
  /*procedure sp_Opening_Balance_new(p_branch     in varchar2,
                                   p_glcode     in varchar2,
                                   p_dr_cr      in varchar2,
                                   p_balance    in number,
                                   p_entry_date in date,
                                   p_error      out varchar2) is
    v_year     number(4) := 0;
    v_exist    number(4) := 0;
    v_count    number(4) := 0;
    v_prev_bal number(12, 2) := 0;
    v_balance  number(12, 2) := 0;
  begin
  
    if (p_dr_cr = 'D') then
      v_balance := nvl(p_balance, 0) * -1;
    else
      v_balance := nvl(p_balance, 0);
    end if;
  
    select to_number(to_char(p_entry_date, 'YYYY')) into v_year from dual;
  
    for idx in (SELECT * FROM as_glcodelist l where l.glcode = p_glcode) loop
    
      if idx.sub_gl = '1' then
        if idx.mainhead is not null then
          SELECT count(*)
            into v_exist
            FROM As_YR_GLBALANCE b
           where b.entity_num = 1
             and b.gl_branch = p_branch
             and b.fin_year = v_year - 1 || '-' || v_year
             and b.gl_code = p_glcode;
        
          if v_exist = 0 then
          
            SELECT b.gl_cur_bal
              into v_prev_bal
              FROM A_YR_GLBALANCE b
             where b.entity_num = 1
               and b.gl_branch = p_branch
               and b.fin_year = v_year - 1 || '-' || v_year
               and b.gl_code = p_glcode;
          
            update A_YR_GLBALANCE r
               set r.gl_cur_bal = nvl(v_balance, 0)
             where r.gl_branch = p_branch
               and r.fin_year = v_year - 1 || '-' || v_year
               and r.gl_code = p_glcode;
          
            update A_YR_GLBALANCE r
               set r.gl_cur_bal = r.gl_cur_bal - nvl(v_prev_bal, 0) +
                                  nvl(v_balance, 0)
             where r.gl_branch = p_branch
               and r.fin_year = v_year - 1 || '-' || v_year
               and r.gl_code = idx.head_glcode;
          
          else
            insert into A_YR_GLBALANCE
              (entity_num,
               gl_branch,
               fin_year,
               gl_code,
               gl_init_bal,
               gl_cur_bal)
            values
              (1,
               p_branch,
               v_year - 1 || '-' || v_year,
               p_glcode,
               0,
               v_balance);
            update A_YR_GLBALANCE r
               set r.gl_cur_bal = r.gl_cur_bal + nvl(v_balance, 0)
             where r.gl_branch = p_branch
               and r.fin_year = v_year - 1 || '-' || v_year
               and r.gl_code = idx.head_glcode;
          end if;
        else
          p_error := 'Head GL is not Found !!';
        end if;
      else
      
        SELECT count(*)
          into v_count
          FROM A_YR_GLBALANCE b
         where b.entity_num = 1
           and b.gl_branch = p_branch
           and b.fin_year = v_year - 1 || '-' || v_year
           and b.gl_code = p_glcode;
        if v_count = 0 then
          insert into A_YR_GLBALANCE
            (entity_num,
             gl_branch,
             fin_year,
             gl_code,
             gl_init_bal,
             gl_cur_bal)
          values
            (1,
             p_branch,
             v_year - 1 || '-' || v_year,
             p_glcode,
             0,
             v_balance);
        else
        
          update A_YR_GLBALANCE b
             set b.gl_init_bal = v_balance, b.gl_cur_bal = v_balance
           where b.entity_num = 1
             and b.gl_branch = p_branch
             and b.fin_year = v_year - 1 || '-' || v_year
             and b.gl_code = p_glcode;
        end if;
      end if;
    end loop;
  exception
    when others then
      p_error := 'Error in sp_Opening_Balance' || sqlerrm;
  end sp_Opening_Balance_new;*/

  function fn_get_ledger_satement(p_branch_code in varchar2,
                                  p_gl_code     in varchar2)
    return V_ledger_statement
    pipelined is
    w_ledger_statement ledger_statement;
    v_balance          number(18, 2) := 0;
    v_ck_balance       number(18, 2) := 0;
  begin
    begin
      select to_date('30-jun-2020'),
             '',
             b.glcode,
             0 /*to_number(decode(sign(b.cur_bal), -1, b.cur_bal * -1, 0))*/ Dr_amount,
             0 /*to_number(decode(sign(b.cur_bal), 1, b.cur_bal, 0))*/ CR_Amount,
             'BF',
             b.branch,
             '' CQ_no,
             '' CQ_date,
             '' cq_ref_name,
             (select l.glname from as_glcodelist l where l.glcode = b.glcode) gl_name,
             cur_bal bal
        into w_ledger_statement.TRAN_DATE,
             w_ledger_statement.BATCH_NO,
             w_ledger_statement.gl_code,
             w_ledger_statement.dr_amount,
             w_ledger_statement.cr_amount,
             w_ledger_statement.narration,
             w_ledger_statement.branch,
             w_ledger_statement.cqnumber,
             w_ledger_statement.cq_date,
             w_ledger_statement.cq_ref,
             w_ledger_statement.gl_name,
             v_ck_balance
        from as_Glbalance_hist b
       where b.branch = p_branch_code
         and b.glcode = p_gl_code;
    
    exception
      when others then
        v_ck_balance                 := 0;
        w_ledger_statement.TRAN_DATE := to_date('30-jun-2020');
        w_ledger_statement.BATCH_NO  := '';
        w_ledger_statement.gl_code   := p_gl_code;
        w_ledger_statement.dr_amount := 0;
        w_ledger_statement.cr_amount := 0;
        w_ledger_statement.narration := '';
        w_ledger_statement.branch    := p_branch_code;
        w_ledger_statement.cqnumber  := '';
        w_ledger_statement.cq_date   := '';
        w_ledger_statement.cq_ref    := '';
        select l.glname
          into w_ledger_statement.gl_name
          from as_glcodelist l
         where l.glcode = p_branch_code;
      
    end;
    if (v_ck_balance > 0) then
      w_ledger_statement.Balance := v_ck_balance;
    else
      w_ledger_statement.Balance := -1 * v_ck_balance;
    end if;
  
    if v_ck_balance >= 0 then
      w_ledger_statement.dr_cr := 'Cr.';
    else
      w_ledger_statement.dr_cr := 'Dr.';
    
    end if;
    w_ledger_statement.transl := 0;
    v_balance                 := v_ck_balance;
    pipe row(w_ledger_statement);
  
    for in1 in (select t.tran_date,
                       t.batch_no,
                       t.branch,
                       t.tran_sl,
                       t.dr_amount,
                       t.cr_amount,
                       t.naration,
                       t.glcode,
                       decode(t.chq_number, 'N/A', '', chq_number) chq_number,
                       decode(t.chq_date, 'N/A', '', chq_date) chq_date,
                       decode(t.chq_reference, 'N/A', '', chq_reference) chq_reference,
                       (select l.glname
                          from as_glcodelist l
                         where l.glcode = t.glcode) gl_name
                  from as_transaction t
                  join as_transaction_list k
                    on (t.entity_num = k.entity_num and
                       t.branch = k.orginated_branch and
                       t.tran_date = k.tran_date and
                       t.batch_no = k.batch_no)
                 where t.branch = p_branch_code
                   and k.auth_on is not null
                   and t.glcode = p_gl_code
                 order by t.tran_date, t.batch_no, t.tran_sl) loop
    
      v_balance := v_balance - in1.dr_amount + in1.cr_amount;
    
      w_ledger_statement.TRAN_DATE := in1.tran_date;
      w_ledger_statement.BATCH_NO  := in1.batch_no;
      w_ledger_statement.branch    := in1.branch;
      w_ledger_statement.dr_amount := in1.dr_amount;
      w_ledger_statement.cr_amount := in1.cr_amount;
      w_ledger_statement.narration := in1.naration;
      w_ledger_statement.cqnumber  := in1.chq_number;
      w_ledger_statement.cq_date   := in1.chq_date;
      w_ledger_statement.gl_name   := in1.gl_name;
      w_ledger_statement.cq_ref    := in1.chq_reference;
      w_ledger_statement.transl    := in1.tran_sl;
      if v_balance >= 0 then
        w_ledger_statement.Balance := v_balance;
        w_ledger_statement.dr_cr   := 'Cr.';
      else
        w_ledger_statement.dr_cr   := 'Dr.';
        w_ledger_statement.Balance := -1 * v_balance;
      end if;
    
      pipe row(w_ledger_statement);
    end loop;
  end fn_get_ledger_satement;

  procedure sp_loan_recovery(p_branch    in varchar2,
                             p_fin_year  in varchar2,
                             p_glcode    in varchar2,
                             p_principal in number,
                             p_interest  in number,
                             P_error     out varchar2) is
    v_exist number := 0;
  begin
    select count(*)
      into v_exist
      from as_loan_recovery i
     where i.branch_code = p_branch
       and i.finyear = p_fin_year
       and i.glcode = p_glcode;
  
    if v_exist = 0 then
      insert into as_loan_recovery
        (branch_code, finyear, glcode, principal_amt, interest_amt)
      values
        (p_branch, p_fin_year, p_glcode, p_principal, p_interest);
    else
      update as_loan_recovery i
         set i.principal_amt = p_principal, i.interest_amt = p_interest
       where i.branch_code = p_branch
         and i.finyear = p_fin_year
         and i.GLCODE = p_glcode;
    end if;
  exception
    when others then
      P_error := 'Error in sp_loan_recovery ' || sqlerrm;
    
  end sp_loan_recovery;

  procedure sp_transaction_Entity_Updation(p_branch    in varchar2,
                                           p_tran_date in date,
                                           p_batch     in number,
                                           p_entity_sl in number,
                                           p_glcode    in varchar2,
                                           P_cqnumber  in varchar2,
                                           p_cq_ref    in varchar2,
                                           p_cq_date   in varchar2,
                                           p_narration in varchar2,
                                           p_remarks   in varchar2,
                                           p_user_id   in varchar2,
                                           P_error     out varchar2) is
    v_Auth_check varchar2(20) := '';
    v_Rej_check  varchar2(20) := '';
  begin
  
    select l.auth_by, l.rej_by
      into v_Auth_check, v_Rej_check
      from as_transaction_list l
     where l.entity_num = 1
       and l.orginated_branch = p_branch
       and l.tran_date = p_tran_date
       and l.batch_no = p_batch;
  
    if v_Rej_check is null then
    
      if v_Auth_check is not null then
        update as_transaction t
           set t.naration      = p_narration,
               t.chq_number    = P_cqnumber,
               t.chq_date      = p_cq_date,
               t.chq_reference = p_cq_ref
         where t.entity_num = 1
           and t.branch = p_branch
           and t.tran_date = p_tran_date
           and t.batch_no = p_batch
           and t.tran_sl = p_entity_sl;
      else
        update as_transaction t
           set t.naration      = p_narration,
               t.glcode        = p_glcode,
               t.chq_number    = P_cqnumber,
               t.chq_date      = p_cq_date,
               t.chq_reference = p_cq_ref
         where t.entity_num = 1
           and t.branch = p_branch
           and t.tran_date = p_tran_date
           and t.batch_no = p_batch
           and t.tran_sl = p_entity_sl;
      end if;
         
      update as_transaction_list l
         set l.remarks = p_remarks,
             l.mod_by=p_user_id,
             l.mod_on=trunc(sysdate)
       where l.entity_num = 1
         and l.orginated_branch = p_branch
         and l.tran_date = p_tran_date
         and l.batch_no = p_batch;
    
    else
      P_error := 'Transaction Batch is already Rejected';
    end if;
  end sp_transaction_Entity_Updation;

  procedure sp_loan_recoverable(p_branch       in varchar2,
                                p_fin_year     in varchar2,
                                p_glcode       in varchar2,
                                p_principal    in number,
                                p_interest     in number,
                                p_principle_fd in number,
                                p_interest_fd  in number,
                                P_error        out varchar2) is
    v_exist number := 0;
  begin
    select count(*)
      into v_exist
      from AS_LOAN_RECOVERABLE i
     where i.branch_code = p_branch
       and i.finyear = p_fin_year
       and i.glcode = p_glcode;
  
    if v_exist = 0 then
      insert into AS_LOAN_RECOVERABLE
        (branch_code,
         finyear,
         glcode,
         principal_od_amt,
         interest_od_amt,
         principal_fd_amt,
         interest_fd_amt)
      values
        (p_branch,
         p_fin_year,
         p_glcode,
         p_principal,
         p_interest,
         p_principle_fd,
         p_interest_fd);
    else
      update AS_LOAN_RECOVERABLE i
         set i.principal_od_amt = p_principal,
             i.interest_od_amt  = p_interest,
             i.principal_fd_amt = p_principle_fd,
             i.interest_fd_amt  = p_interest_fd
       where i.branch_code = p_branch
         and i.glcode = p_glcode
         and i.finyear = p_fin_year;
    end if;
  exception
    when others then
      P_error := 'Error in sp_loan_recovery ' || sqlerrm;
    
  end sp_loan_recoverable;

begin
  null;
end pkg_gas;
/
