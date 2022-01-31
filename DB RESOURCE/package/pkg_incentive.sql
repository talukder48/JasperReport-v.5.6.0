create or replace package pkg_incentive is
  procedure sp_get_incentivedata(p_branch          in varchar2,
                                 p_emp_id          in varchar2,
                                 p_fin_year        in varchar2,
                                 p_current_basic   out varchar2,
                                 p_incentive_basic out varchar2,
                                 p_total_incentive out varchar2,
                                 p_emp_name        out varchar2,
                                 p_incentive_pct   out varchar2,
                                 p_error           out varchar2);
  procedure sp_update_incentivce_Data(p_empId           in varchar2,
                                      p_branch          in varchar2,
                                      p_finyear         in varchar2,
                                      p_incentive_basic in number,
                                      p_incentive_pct   in number,
                                      p_error           out varchar2);
  procedure sp_incentive_process(p_fin_year     in varchar2,
                                 p_branch_code  in varchar2,
                                 p_bonus_pct    in number,
                                 p_office_order in varchar2,
                                 p_error        out varchar2);
  procedure sp_incentive_process_by_branch(p_fin_year    in varchar2,
                                           p_branch_code in varchar2,
                                           p_error       out varchar2);
  procedure sp_DataUpdate_by_branch(p_branch  in varchar2,
                                    p_finyear in varchar2,
                                    p_year    IN NUMBER,
                                    P_month   in number,
                                    p_error   out varchar2);                                         
end pkg_incentive;
/
create or replace package body pkg_incentive is
  procedure sp_incentive_process_by_branch(p_fin_year    in varchar2,
                                           p_branch_code in varchar2,
                                           p_error       out varchar2) is
    v_error varchar2(200) := '';
  begin
    if trunc(sysdate) <= '19-DEC-2021' then
      for id in (SELECT *
                   FROM prms_incentive_master m
                  where m.finyear = p_fin_year) loop
        sp_incentive_process(p_fin_year,
                             p_branch_code,
                             id.no_of_incentive,
                             id.order_no,
                             v_error);
      
      end loop;
      p_error := v_error;
    end if;
  end sp_incentive_process_by_branch;

  procedure sp_incentive_process(p_fin_year     in varchar2,
                                 p_branch_code  in varchar2,
                                 p_bonus_pct    in number,
                                 p_office_order in varchar2,
                                 p_error        out varchar2) is
    v_total_amount number := 0;
    v_net_amount   number := 0;
    v_revenue      number := 0;
  begin
  
    delete from PRMS_INC_TRANSACTION t
     where t.branch_code = p_branch_code
       and t.fin_year = p_fin_year;
    for id in (SELECT *
                 FROM PRMS_INCENTIVE_DATA d
                where branch_code = p_branch_code
                  and d.fin_year = p_fin_year
                  and d.incentive_basic > 0) loop
    
      SELECT k.revenue
        into v_revenue
        FROM prms_deduc k
       where k.emp_id = id.emp_id;
      v_total_amount := round(id.incentive_basic *
                              (id.incentive_pct * p_bonus_pct),
                              2);
      v_net_amount   := round(v_total_amount - v_revenue, 2);
    
      insert into PRMS_INC_TRANSACTION
        (emp_id,
         branch_code,
         fin_year,
         emp_name,
         designation,
         inc_basic,
         total_inc_amount,
         revenue,
         net_inc_pay,
         bank_account,
         incentive_pct,
         ORDERNO,
         desig_code,
         desig_seniority_code)
      values
        (id.emp_id,
         id.branch_code,
         id.fin_year,
         (SELECT e.emp_name FROM prms_employee e where e.emp_id = id.emp_id),
         (SELECT (SELECT d.designation_desc
                    FROM prms_designation d
                   where d.designation_code = s.desig_code) designation
            FROM prms_emp_sal s
           where s.emp_id = id.emp_id),
         id.incentive_basic,
         v_total_amount,
         v_revenue,
         v_net_amount,
         (SELECT s.bank_acc FROM prms_emp_sal s where s.emp_id = id.emp_id),
         p_bonus_pct,
         p_office_order,
         (SELECT s.desig_code FROM prms_emp_sal s where s.emp_id = id.emp_id),
         (SELECT s.desig_seniority_code
            FROM prms_emp_sal s
           where s.emp_id = id.emp_id));
    end loop;
  exception
    when others then
      p_error := 'Error in sp_incentive_process' || sqlerrm;
  end sp_incentive_process;
  procedure sp_get_incentivedata(p_branch          in varchar2,
                                 p_emp_id          in varchar2,
                                 p_fin_year        in varchar2,
                                 p_current_basic   out varchar2,
                                 p_incentive_basic out varchar2,
                                 p_total_incentive out varchar2,
                                 p_emp_name        out varchar2,
                                 p_incentive_pct   out varchar2,
                                 p_error           out varchar2) is
    v_exist      number := 0;
    v_branch_chk number := 0;
    v_yr2        varchar2(4) := substr(p_fin_year, 6, 4);
  begin
    for idx in (SELECT *
                  FROM PRMS_INCENTIVE_DATA d
                 where d.branch_code = p_branch
                   and d.fin_year = p_fin_year
                   and d.emp_id = p_emp_id) loop
      v_exist := 1;
    
      p_incentive_basic := idx.incentive_basic;
      p_total_incentive := idx.total_amount;
      p_incentive_pct   := idx.incentive_pct;
    end loop;
  
    SELECT count(*)
      into v_branch_chk
      FROM prms_emp_sal s
     where s.emp_id = p_emp_id
       and s.emp_brn_code = p_branch;
  
    if v_branch_chk = 0 then
      p_error := 'Employee does not belong to the branch ';
    else
    
      SELECT e.emp_name
        into p_emp_name
        FROM prms_employee e
       where e.emp_id = p_emp_id;
    
      SELECT s.new_basic
        into p_current_basic
        FROM prms_emp_sal s
       where s.emp_id = p_emp_id;
    
      if v_exist = 0 then
        begin
          SELECT t.basic_pay
            into p_incentive_basic
            FROM prms_transaction t
           where t.emp_id = p_emp_id
             and t.sal_year = v_yr2
             and t.month_code = 6;
        exception
          when others then
            p_incentive_basic := 0;
        end;
      
        p_total_incentive := 0;
        p_incentive_pct   := 1;
      end if;
    
    end if;
  exception
    when others then
    
      p_error := 'Error in ' || sqlerrm;
    
  end sp_get_incentivedata;

  procedure sp_update_incentivce_Data(p_empId           in varchar2,
                                      p_branch          in varchar2,
                                      p_finyear         in varchar2,
                                      p_incentive_basic in number,
                                      p_incentive_pct   in number,
                                      p_error           out varchar2) is
    v_exist number := 0;
  begin
    SELECT count(*)
      into v_exist
      FROM PRMS_INCENTIVE_DATA d
     where d.branch_code = p_branch
       and d.fin_year = p_finyear
       and d.emp_id = p_empId;
  
    if v_exist <> 0 then
      update PRMS_INCENTIVE_DATA d
         set d.incentive_basic = p_incentive_basic,
             d.incentive_pct   = round(p_incentive_pct,4)
       where d.branch_code = p_branch
         and d.emp_id = p_empId
         and d.fin_year = p_finyear;
    else
      insert into PRMS_INCENTIVE_DATA
        (branch_code,
         emp_id,
         fin_year,
         current_basic,
         incentive_basic,
         incentive_pct)
      values
        (p_branch,
         p_empId,
         p_finyear,
         0,
         p_incentive_basic,
         round(p_incentive_pct,4));
    end if;
  
  exception
    when others then
      p_error := 'Error in sp_update_incentivce_Data' || sqlerrm;
  end sp_update_incentivce_Data;

  procedure sp_DataUpdate_by_branch(p_branch  in varchar2,
                                    p_finyear in varchar2,
                                    p_year    IN NUMBER,
                                    P_month   in number,
                                    p_error   out varchar2) is
    v_exist number := 0;
    v_basic number := 0;
  
  begin
  
   delete from PRMS_INCENTIVE_DATA d where d.branch_code=p_branch
   and d.fin_year=p_finyear;
    for id in (SELECT * FROM prms_emp_sal s where s.emp_brn_code = p_branch
      and s.acc_no_active<>'N') loop
    
     begin
      SELECT t.basic_pay
        into v_basic
        FROM prms_transaction t
       where t.emp_id = id.emp_id
         and t.sal_year = p_year
         and t.month_code = P_month;
     exception when others then 
       v_basic:=0;           
     end ;

        insert into PRMS_INCENTIVE_DATA
          (branch_code,
           emp_id,
           fin_year,
           current_basic,
           incentive_basic,
           incentive_pct)
        values
          (p_branch, id.emp_id, p_finyear, 0, v_basic, 1);

    end loop;
  exception
    when others then
      p_error := 'Error in sp_update_incentivce_Data' || sqlerrm;
  end sp_DataUpdate_by_branch;

begin
  null;
end pkg_incentive;
/
