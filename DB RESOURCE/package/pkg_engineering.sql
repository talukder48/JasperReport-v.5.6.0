create or replace package pkg_engineering is
  type log is record(
    Item        varchar2(20),
    Item_desc   varchar2(200),
    Item_result varchar2(100));
  type v_log is table of log;

  function fn_get_System_status(p_finYear in varchar2) return v_log
    pipelined;
  procedure sp_auth_batch_engineering(p_branch    in varchar2,
                                      p_from_date in date,
                                      p_to_date   in date,
                                      p_message   out varchar2);
  procedure sp_balance_engineering(p_branch_code  in varchar2,
                                   p_old_fin_year in varchar2,
                                   p_finyear      in varchar2,
                                   p_message      out varchar2);
  procedure sp_missing_gl_engineering(p_finyear in varchar2,
                                      p_message out varchar2);
end pkg_engineering;
/
create or replace package body pkg_engineering is
  function fn_get_System_status(p_finYear in varchar2) return v_log
    pipelined is
    w_log        log;
    V_flag       number := 0;
    v_start_date date;
    v_end_date   date;
  begin
    select a.start_date, a.end_date
      into v_start_date, v_end_date
      from as_finyear a
     where a.fin_year = p_finYear;
  
    w_log.Item := 'Cash Book';
    select nvl(sum(sum(t.DR_AMOUNT) - sum(t.CR_AMOUNT)), 0)
      into V_flag
      from as_transaction t
      join as_transaction_list k
        on (t.entity_num = k.entity_num and t.branch = k.orginated_branch and
           t.tran_date = k.tran_date and t.batch_no = k.batch_no)
     where t.entity_num = 1
       and k.rej_on is null
     group by t.branch
    having sum(t.DR_AMOUNT) - sum(t.CR_AMOUNT) > 0;
    if V_flag = 0 then
      w_log.Item_desc   := 'All office: No Cashbook Difference found ';
      w_log.Item_result := '200';
    else
      w_log.Item_desc   := 'All office:  Cashbook Difference found ';
      w_log.Item_result := '201';
    end if;
    pipe row(w_log);
  
    w_log.Item := 'Cash Book';
    SELECT sum(DT_CR - SUM_CR)
      into V_flag
      FROM ((SELECT l.orginated_branch,
                    sum(DR_AMOUNT) dt_dr,
                    sum(CR_AMOUNT) dt_cr
               from as_transaction_list l
              where l.entity_num = 1
                and l.rej_by is null
              group by l.orginated_branch) kk join
            (select branch, sum(t.DR_AMOUNT) sum_dr, sum(t.CR_AMOUNT) sum_cr
               from as_transaction t
               join as_transaction_list k
                 on (t.entity_num = k.entity_num and
                    t.branch = k.orginated_branch and
                    t.tran_date = k.tran_date and t.batch_no = k.batch_no)
              where t.entity_num = 1
                and k.rej_on is null
              group by t.branch) k on(k.branch = kk.orginated_branch))
     order by ORGINATED_BRANCH;
    if V_flag = 0 then
      w_log.Item_desc   := 'All office: Cashbook summary & Details OK ';
      w_log.Item_result := '200';
    else
      w_log.Item_desc   := 'All office:  Cashbook summary & Details not OK  ';
      w_log.Item_result := '201';
    end if;
    pipe row(w_log);
  
    w_log.Item := 'Trail Balance';
  
    SELECT SUM(DR_AMOUNT - CR_AMOUNT)
      into V_flag
      FROM table(pkg_gas.fn_get_tb_consolidated('9999'));
    if V_flag = 0 then
      w_log.Item_desc   := 'All office: No TB Difference found ';
      w_log.Item_result := '200';
    else
      w_log.Item_desc   := 'All office:  TB Difference found ';
      w_log.Item_result := '201';
    end if;
    pipe row(w_log);
  
    w_log.Item := 'Transaction';
  
    SELECT count(*)
      into V_flag
      FROM as_transaction_list l
     where l.rej_by is null
       and l.tran_date between v_start_date and v_end_date
       and l.auth_on is null;
    if V_flag = 0 then
      w_log.Item_desc   := 'All office: No Un-Auth Batch Found';
      w_log.Item_result := '200';
    else
      w_log.Item_desc   := 'All office:  Un-Auth Batch Found And Numbered: ' ||
                           V_flag;
      w_log.Item_result := '201';
    end if;
    pipe row(w_log);
    w_log.Item := 'Balance Gap';
    select count(*)
      into V_flag
      from table(pkg_gas_report.get_branch_matrix('%', '2021-2022'))
     where color_flag = 'R';
    if V_flag = 0 then
      w_log.Item_desc   := 'All office: No Balance Gap Found';
      w_log.Item_result := '200';
    else
      w_log.Item_desc   := 'All office:  Balance Gap Found ';
      w_log.Item_result := '201';
    end if;
    pipe row(w_log);
  
    w_log.Item := 'Head Balance';
  
    for idx in (select *
                  from as_glcodelist l
                 where l.mainhead is null
                   and l.tran_yn <> 'Y'
                   and l.slot_yn = 'N'
                   and l.glcode not in
                       ('140000000', '150000000', '120000000')) loop
      select sum(bal)
        into V_flag
        from (select a.branch, sum(a.cur_bal) bal, 'T' Type
                from as_glcodelist l
                join as_glbalance a
                  on (l.glcode = a.glcode)
               where l.glcode like substr(idx.glcode, 1, 2) || '%'
                 and length(l.glcode) = 9
                 and l.tran_yn = 'Y'
               group by a.branch
              union
              select a.branch, -1 * sum(a.cur_bal) bal, 'M' Type
                from as_glcodelist l
                join as_glbalance a
                  on (l.glcode = a.glcode)
               where l.glcode like substr(idx.glcode, 1, 2) || '%'
                 and l.tb_yn = 'Y'
               group by a.branch);
      if V_flag = 0 then
        w_log.Item_desc   := idx.glname || ':    Match With Sub Head';
        w_log.Item_result := '200';
      else
        w_log.Item_desc   := idx.glname || ':    Not Match With Sub Head';
        w_log.Item_result := '201';
      end if;
      pipe row(w_log);
    end loop;
  
  end fn_get_System_status;

  procedure sp_auth_batch_engineering(p_branch    in varchar2,
                                      p_from_date in date,
                                      p_to_date   in date,
                                      p_message   out varchar2) is
  begin
    for idx in (select *
                  from as_transaction_list l
                 where l.orginated_branch = p_branch
                   and l.auth_on is not null
                   and l.tran_date between p_from_date and p_to_date) loop
      pkg_gas.sp_batchauthorize_test(idx.orginated_branch,
                                     idx.tran_date,
                                     idx.batch_no,
                                     idx.auth_by,
                                     p_message);
    end loop;
  
  exception
    when others then
      p_message := 'Error in sp_auth_batch_engineering:' || sqlerrm;
  end sp_auth_batch_engineering;

  procedure sp_missing_gl_engineering(p_finyear in varchar2,
                                      p_message out varchar2) is
    exist number := 0;
  begin
    for idx in (select * from as_glcodelist b where length(b.glcode) = 9) loop
      for idy in (select *
                    from prms_mbranch m
                   where m.bran_cat_code in ('B', 'H', 'E')) loop
        select count(*)
          into exist
          from as_glbalance z
         where z.branch = idy.brn_code
           and z.glcode = idx.glcode;
        if exist = 0 then
          insert into as_glbalance
            (entity_num, branch, fin_year, glcode, init_bal, cur_bal)
          values
            (1, idy.brn_code, p_finyear, idx.glcode, 0, 0);
        end if;
      end loop;
    end loop;
  
  exception
    when others then
      p_message := 'Error in sp_missing_gl_engineering:' || sqlerrm;
  end sp_missing_gl_engineering;

  procedure sp_balance_engineering(p_branch_code  in varchar2,
                                   p_old_fin_year in varchar2,
                                   p_finyear      in varchar2,
                                   p_message      out varchar2) is
    exist number := 0;
  begin
    delete from as_glbalance z
     where z.branch = p_branch_code
       and z.fin_year = p_finyear;
    for idx in (select entity_num,
                       fin_year,
                       branch,
                       glcode,
                       init_bal,
                       cur_bal
                  from as_final_glbalance k
                 where k.fin_year = p_old_fin_year
                   and k.tb_type = 'A'
                   and k.branch = p_branch_code) loop
      insert into as_glbalance
        (entity_num, fin_year, branch, glcode, init_bal, cur_bal)
      values
        (idx.entity_num,
         p_finyear,
         idx.branch,
         idx.glcode,
         idx.init_bal,
         idx.cur_bal);
    end loop;
    for idx in (select *
                  from as_glcodelist b
                 where length(b.glcode) > 9
                   and b.glcode like p_branch_code || '%') loop
      select count(*)
        into exist
        from as_glbalance z
       where z.branch = p_branch_code
         and z.glcode = idx.glcode
         and z.fin_year = p_finyear;
      if exist = 0 then
        insert into as_glbalance
          (entity_num, branch, fin_year, glcode, init_bal, cur_bal)
        values
          (1, p_branch_code, p_finyear, idx.glcode, 0, 0);
      end if;
    end loop;
  exception
    when others then
      p_message := 'Error in sp_balance_engineering:' || sqlerrm;
  end sp_balance_engineering;
begin
  null;
end pkg_engineering;
/
