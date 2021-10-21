create or replace package pkg_ln_Closing is
  procedure sp_data_migration(p_ln_type in varchar2, p_year in number);
  procedure sp_ln_init(p_year in number,p_type in varchar2);
  procedure sp_ln_blank_month(p_year in number,p_month_code in number,p_date in date, p_type in varchar2);
  procedure sp_disburse_to_realization(p_type  in varchar2,p_date1 in date,p_date2 in date);
  procedure sp_ln_closing(p_year in number, p_type in varchar2);
  procedure sp_accrual_process(p_entity_num in number,
                               p_year       in number,
                               p_month_code in number,
                               p_loan_type  in varchar2,
                               p_error      out varchar2);
end pkg_ln_Closing;
/
create or replace package body pkg_ln_Closing is
  procedure sp_data_migration(p_ln_type in varchar2, p_year in number) is
  begin
    if p_ln_type = 'MOTK' then
      insert into elms_realization
        select 1 entity,
               d.acc_no emp_id,
               'MOT' type,
               decode(d.month_code,
                      '7',
                      p_year,
                      '8',
                      p_year,
                      '9',
                      p_year,
                      '10',
                      p_year,
                      '11',
                      p_year,
                      '12',
                      p_year,
                      p_year + 1) year,
               d.month_code,
               1 sl,
               d.salary_date real_date,
               'M' real_type,
               'C' dr_cr_type,
               'N' vou_type,
               d.dedu_amount,
               'MIG',
               trunc(sysdate)
          from bhbfc.motor_hb_mon_ded d
         where month_code in ('1',
                              '2',
                              '3',
                              '4',
                              '5',
                              '6',
                              '7',
                              '8',
                              '9',
                              '10',
                              '11',
                              '12');
    
    elsif p_ln_type = 'MOT' then  
        
      delete from elms_ln_summary s where s.loan_type = p_ln_type;
      delete from elms_ln_ledger d where d.loan_type = p_ln_type;    
      insert into elms_ln_summary
        select 1 ENTITY_NUM,
               t.acc_no EMP_ID,
               'MOT' LOAN_TYPE,
               t.prin_bal PRIN_BALANCE,
               t.int_bal,
               t.prin_bal + t.int_bal TOT_BALANCE
          from bhbfc.motor_HBADV_CL2 t
         where t.fin_year = '2019-2020';
    
      insert into elms_ln_ledger
        select 1 ENTITY_NUM,
               t.acc_no EMP_ID,
               'MOT' LOAN_TYPE,
               p_year REAL_YEAR,
               6 REAL_MONTH_CODE,
               1 REL_SL,
               '30-jun-2019' REAL_DATE,
               'B' REAL_TYPE,
               '' DR_CR_TYPE,
               '' VOUCHAR_TYPE,
               0 REAL_AMOUNT,
               t.prin_bal PRIN_BALANCE,
               0 INT_CHARGED,
               t.int_bal,
               t.prin_bal + t.int_bal TOT_BALANCE,
               'MIG' ENTD_BY,
               trunc(sysdate)
          from bhbfc.motor_HBADV_CL2 t
         where t.fin_year = '2019-2020';
    
    end if;
  
  end sp_data_migration;

  procedure sp_ln_init(p_year in number,p_type in varchar2) is
  begin
    delete from elms_ln_summary p where p.loan_type=p_type;
    insert into elms_ln_summary
      SELECT vl.entity_num,
             vl.emp_id,
             vl.loan_type,
             vl.prin_balance,
             vl.int_balance,
             vl.tot_balance
        FROM elms_ln_ledger vl
       where vl.real_year = p_year
         and vl.loan_type=p_type
         and vl.real_month_code = '6';
         
    delete from elms_ln_ledger r
     where r.real_year = p_year
      and r.loan_type=p_type
       and r.real_month_code > 6;
    delete from elms_ln_ledger r where  r.loan_type=p_type and r.real_year = p_year + 1;
  end sp_ln_init;

procedure sp_disburse_to_realization(p_type  in varchar2,p_date1 in date,p_date2 in date) is
begin
  declare
    v_error      varchar2(100) := '';
    v_month_code number(2);
    v_year       number(4);
  begin
    for d in (select *
                from elms_disburse d
               where d.disb_date between p_date1 and p_date2
                 and d.loan_type = p_type) loop
      select to_number(to_char(to_date(d.disb_date, 'dd-mon-yy'), 'mm'))
        into v_month_code
        from dual;
      select to_number(to_char(d.disb_date, 'YYYY')) into v_year from dual;
      pkg_elms.sp_loan_realization(1,
                                   d.emp_id,
                                   d.loan_type,
                                   v_year,
                                   v_month_code,
                                   d.disb_date,
                                   'P',
                                   'D',
                                   'D',
                                   d.disb_amount,
                                   d.entd_by,
                                   v_error);
    end loop;
  end sp_disburse_to_realization;

end;



procedure sp_ln_blank_month(p_year in number,p_month_code in number,p_date in date, p_type in varchar2) is
begin
  for idx in (select distinct l.emp_id
                from elms_ln_ledger l
               where l.loan_type= p_type) loop
    begin
      insert into elms_realization v
      values
        (1,
         idx.emp_id,
         p_type,
         p_year,
         p_month_code,
         1,
         p_date,
         'M',
         'C',
         'N',
         0,
         'AUTO',
         trunc(sysdate));
    exception
      when others then
        dbms_output.put_line('exist the record');
    end; 
 end loop;
end sp_ln_blank_month;

procedure sp_accrual_process(p_entity_num in number,
                               p_year       in number,
                               p_month_code in number,
                               p_loan_type  in varchar2,
                               p_error      out varchar2) is
    v_int_rate         number(13, 2) := 0.05;
    v_prev_prin_bal    number(13, 2) := 0;
    v_prev_int_bal     number(13, 2) := 0;
    v_temp_bal         number(13, 2) := 0;
    v_curr_prin_bal    number(13, 2) := 0;
    v_curr_intr_bal    number(13, 2) := 0;
    v_intr_chg_on_prin number(13, 2) := 0;
    v_tot_intr_bal     number(13, 2) := 0;
    v_tot_bal          number(13, 2) := 0;
    v_days_count1      number := 0;
    v_days_count2      number := 0;
    v_days_count       number := 0;
    v_year             number := 0;
    v_mon              number := 0;
    v_days             number := 0;
    v_row_count        number := 0;
    v_row_sl           number := 0;
    temp_days          number := 0;
    v_real_type        char(1) := '';
  begin
    for idx in (select *
                  from elms_realization r
                 where r.entity_num = p_entity_num
                   and r.real_year = p_year
                   and r.real_month_code = p_month_code
                   and r.loan_type = p_loan_type
                     --  and r.emp_id = '99'
                   and r.rel_sl = 1
                 order by r.emp_id) loop
    
      v_prev_prin_bal    := 0;
      v_prev_int_bal     := 0;
      v_temp_bal         := 0;
      v_curr_prin_bal    := 0;
      v_curr_intr_bal    := 0;
      v_intr_chg_on_prin := 0;
      v_tot_intr_bal     := 0;
      v_tot_bal          := 0;
      v_days_count1      := 0;
      v_days_count2      := 0;
      v_days_count       := 0;
      v_days             := 0;
      v_row_count        := 0;
      temp_days          := 0;
    v_row_sl:=0;
      if p_month_code = 1 then
        v_year := p_year - 1;
        v_mon  := 12;
      else
        v_year := p_year;
        v_mon  := p_month_code - 1;
      end if;
      if remainder(p_year, 400) = 0 then
        v_days := 366;
      elsif (remainder(p_year, 4)) = 0 then
        if (remainder(p_year, 100)) <> 0 then
          v_days := 366;
        end if;
      else
        v_days := 365;
      end if;
    
      select count(r.entity_num)
        into v_row_count
        from elms_realization r
       where r.entity_num = idx.entity_num
         and r.real_year = idx.real_year
         and r.real_month_code = idx.real_month_code
         and r.loan_type = idx.loan_type
         and r.emp_id = idx.emp_id;
    
      if nvl(v_row_count, 0) > 1 then
        /*for multiple adjustment in a month*/
        for id in (select *
                     from elms_realization r
                    where r.entity_num = idx.entity_num
                      and r.real_year = idx.real_year
                      and r.real_month_code = idx.real_month_code
                      and r.loan_type = idx.loan_type
                      and r.emp_id = idx.emp_id
                    order by r.real_date) loop
        v_row_sl:=v_row_sl+1;
          begin
            select nvl(r.prin_balance, 0), nvl(r.int_balance, 0)
              into v_prev_prin_bal, v_prev_int_bal
              from elms_ln_summary r
             where r.entity_num = p_entity_num
               and r.emp_id = id.emp_id
               and r.loan_type = id.loan_type;
          exception
            when others then
              v_prev_prin_bal := 0;
              v_prev_int_bal  := 0;
          end;
        
          if (v_prev_prin_bal + v_prev_int_bal) > 0 or id.real_amount > 0 then
            if (nvl(v_prev_prin_bal, 0) > 0 and  nvl(v_prev_prin_bal, 0) - nvl(id.real_amount, 0) > 0) then
              /*realization for only principal*/
              v_real_type := 'P';
              if id.dr_cr_type = 'C' then
                v_curr_prin_bal := round((v_prev_prin_bal -
                                         nvl(id.real_amount, 0)),
                                         2);
              else
                v_curr_prin_bal := round((v_prev_prin_bal +
                                         nvl(id.real_amount, 0)),
                                         2);
              end if;
            
            elsif (nvl(v_prev_prin_bal, 0) > 0 and  nvl(v_prev_prin_bal, 0) - nvl(id.real_amount, 0) < 0) then
              v_real_type := 'B';
              /*realization for principal & interest*/
              if id.dr_cr_type = 'C' then
                v_temp_bal      := round((nvl(id.real_amount, 0) -
                                         nvl(v_prev_prin_bal, 0)),
                                         2);
                v_curr_prin_bal := 0;
                v_curr_intr_bal := round((v_prev_int_bal -
                                         nvl(v_temp_bal, 0)),
                                         2);
              else
                v_curr_prin_bal := round((v_prev_prin_bal +
                                         nvl(id.real_amount, 0)),
                                         2);
              end if;
            
            elsif (nvl(v_prev_prin_bal, 0) = 0 and
                  nvl(v_prev_int_bal, 0) - nvl(id.real_amount, 0) > 0) then
              /*realization for only interest*/
              v_real_type := 'I';
              if id.dr_cr_type = 'C' then
                v_curr_intr_bal := round((v_prev_int_bal -
                                         nvl(id.real_amount, 0)),
                                         2);
              else
                v_curr_prin_bal := round((v_curr_prin_bal +
                                         nvl(id.real_amount, 0)),
                                         2);
              end if;
            
            elsif nvl(v_prev_prin_bal, 0) = 0 and
                  ((nvl(v_prev_int_bal, 0) = 0 or
                   nvl(v_prev_int_bal, 0) - nvl(id.real_amount, 0) < 0)) then
              /*neither principle nor interest*/
              v_real_type := 'X';
              if id.dr_cr_type = 'C' then
              
                v_curr_prin_bal := round((v_curr_prin_bal -
                                         nvl(id.real_amount, 0)),
                                         2);
              else
                v_curr_intr_bal := v_prev_int_bal;
                v_curr_prin_bal := round((v_curr_prin_bal +
                                         nvl(id.real_amount, 0)),
                                         2);
              end if;
            end if;
            
           -- v_curr_intr_bal:=v_prev_int_bal;

            if v_row_sl = v_row_count then
              select extract(day from id.real_date) - 1
                into v_days_count1
                from dual;
              v_days_count1 := v_days_count1 - temp_days;
              select extract(day from last_day(trunc(id.real_date)))
                into v_days_count
                from dual;
              v_days_count2 := v_days_count - (v_days_count1 + temp_days);
            else
              select extract(day from id.real_date) - 1
                into v_days_count1
                from dual;
              v_days_count1 := v_days_count1 - temp_days;
              v_days_count2 := 0;
            end if;
          
            temp_days := temp_days + v_days_count1;
          
            if nvl(v_prev_prin_bal, 0) = 0 and nvl(v_prev_int_bal, 0) = 0 then
              v_days_count1 := 0;
            end if;
          
            v_intr_chg_on_prin := round((v_prev_prin_bal *v_int_rate *v_days_count1) / v_days,2)+
                                  round((v_curr_prin_bal *v_int_rate *v_days_count2) /  v_days,2);
          
            if v_real_type ='B' or v_real_type='I' then
              v_tot_intr_bal := round(v_intr_chg_on_prin + v_curr_intr_bal, 2);
            else
              
            v_tot_intr_bal := round(v_intr_chg_on_prin + v_prev_int_bal, 2);
            end if;
            
            v_tot_bal      := round(v_tot_intr_bal + v_curr_prin_bal, 2);
            begin
              insert into elms_ln_ledger
                (entity_num,
                 emp_id,
                 loan_type,
                 real_year,
                 real_month_code,
                 rel_sl,
                 real_date,
                 real_type,
                 dr_cr_type,
                 vouchar_type,
                 real_amount,
                 prin_balance,
                 int_charged,
                 int_balance,
                 tot_balance,
                 entd_by,
                 entd_on)
              values
                (id.entity_num,
                 id.emp_id,
                 id.loan_type,
                 id.real_year,
                 id.real_month_code,
                 id.rel_sl,
                 id.real_date,
                 v_real_type,
                 id.dr_cr_type,
                 id.vouchar_type,
                 id.real_amount,
                 v_curr_prin_bal,
                 v_intr_chg_on_prin,
                 v_tot_intr_bal,
                 v_tot_bal,
                 id.entd_by,
                 id.entd_on);
            
              update elms_ln_summary s
                 set s.prin_balance = v_curr_prin_bal,
                     s.int_balance  = v_tot_intr_bal,
                     s.tot_balance  = v_tot_bal
               where s.entity_num = p_entity_num
                 and s.emp_id = idx.emp_id
                 and s.loan_type = p_loan_type;
            exception
              when others then
                dbms_output.put_line('inserting error for ' || idx.emp_id || '-' ||
                                     idx.loan_type || '-' || idx.real_date);
            end;
          end if;
        end loop;
      else
        /*for single adjustment in a month*/
        for id in (select *
                     from elms_realization r
                    where r.entity_num = idx.entity_num
                      and r.real_year = idx.real_year
                      and r.real_month_code = idx.real_month_code
                      and r.loan_type = idx.loan_type
                      and r.emp_id = idx.emp_id
                    order by r.real_date) loop
        
          begin
            select nvl(r.prin_balance, 0), nvl(r.int_balance, 0)
              into v_prev_prin_bal, v_prev_int_bal
              from elms_ln_summary r
             where r.entity_num = p_entity_num
               and r.emp_id = id.emp_id
               and r.loan_type = id.loan_type;
          exception
            when others then
              v_prev_prin_bal := 0;
              v_prev_int_bal  := 0;
          end;
        
          if (v_prev_prin_bal + v_prev_int_bal) > 0 or id.real_amount > 0 then
            
            if (nvl(v_prev_prin_bal, 0) > 0 and  nvl(v_prev_prin_bal, 0) - nvl(id.real_amount, 0) > 0) then
              /*realization for only principal*/
              v_real_type := 'P';
              if id.dr_cr_type = 'C' then
                v_curr_prin_bal := round((v_prev_prin_bal - nvl(id.real_amount, 0)), 2);
              else
                v_curr_prin_bal := round((v_prev_prin_bal +nvl(id.real_amount, 0)), 2);
              end if;
            
            elsif (nvl(v_prev_prin_bal, 0) > 0 and
                  nvl(v_prev_prin_bal, 0) - nvl(id.real_amount, 0) < 0) then
              v_real_type := 'B';
              /*realization for principal & interest*/
              if id.dr_cr_type = 'C' then
                v_temp_bal      := round((nvl(id.real_amount, 0) -
                                         nvl(v_prev_prin_bal, 0)),
                                         2);
                v_curr_prin_bal := 0;
                v_curr_intr_bal := round((v_prev_int_bal -
                                         nvl(v_temp_bal, 0)),
                                         2);
              else
                v_curr_prin_bal := round((v_prev_prin_bal +
                                         nvl(id.real_amount, 0)),
                                         2);
              end if;
            
            elsif (nvl(v_prev_prin_bal, 0) = 0 and
                  nvl(v_prev_int_bal, 0) - nvl(id.real_amount, 0) > 0) then
              /*realization for only interest*/
              v_real_type := 'I';
              if id.dr_cr_type = 'C' then
                v_curr_intr_bal := round((v_prev_int_bal -
                                         nvl(id.real_amount, 0)),
                                         2);
              else
                v_curr_prin_bal := round((v_curr_prin_bal +
                                         nvl(id.real_amount, 0)),
                                         2);
              end if;
            
            elsif nvl(v_prev_prin_bal, 0) = 0 and
                  (nvl(v_prev_int_bal, 0) = 0 or
                   nvl(v_prev_int_bal, 0) - nvl(id.real_amount, 0) < 0) then
              /*neither principle nor interest*/
              v_real_type := 'X';
              if id.dr_cr_type = 'C' then
                v_curr_prin_bal := round((v_curr_prin_bal -
                                         nvl(id.real_amount, 0)),
                                         2);
              else
                v_curr_intr_bal := v_prev_int_bal;
                v_curr_prin_bal := round((v_curr_prin_bal +
                                         nvl(id.real_amount, 0)),
                                         2);
              end if;
            end if;
          
            if id.rel_sl = v_row_count then
              select extract(day from id.real_date) - 1
                into v_days_count1
                from dual;
              v_days_count1 := v_days_count1 - temp_days;
              select extract(day from last_day(trunc(id.real_date)))
                into v_days_count
                from dual;
              v_days_count2 := v_days_count - (v_days_count1 + temp_days);
              
             if id.real_amount=0 then
               v_days_count1:=v_days_count;
               v_days_count2 := 0;
             end if; 
            else
              select extract(day from id.real_date) - 1
                into v_days_count1
                from dual;
              v_days_count1 := v_days_count1 - temp_days;
              v_days_count2 := 0;
            end if;
          
            temp_days := temp_days + v_days_count1;
          
            if nvl(v_prev_prin_bal, 0) = 0 and nvl(v_prev_int_bal, 0) = 0 then
              v_days_count1 := 0;
            end if;
          
         /*   v_intr_chg_on_prin := round((round((v_prev_prin_bal *
                                               v_int_rate) *
                                               (v_days_count1 / v_days),
                                               2) +
                                        round((v_curr_prin_bal *
                                               v_int_rate) *
                                               (v_days_count2 / v_days),
                                               2)),
                                        2);*/
           
                                        
          
           v_intr_chg_on_prin := round((v_prev_prin_bal *v_int_rate *v_days_count1) / v_days,2)+
                                  round((v_curr_prin_bal *v_int_rate *v_days_count2) /  v_days,2);
          
           if v_real_type ='B' or v_real_type='I' then
              v_tot_intr_bal := round(v_intr_chg_on_prin + v_curr_intr_bal, 2);
            else              
            v_tot_intr_bal := round(v_intr_chg_on_prin + v_prev_int_bal, 2);
            end if;
          
            v_tot_bal := round((v_tot_intr_bal + v_curr_prin_bal), 2);
          
            begin
              insert into elms_ln_ledger
                (entity_num,
                 emp_id,
                 loan_type,
                 real_year,
                 real_month_code,
                 rel_sl,
                 real_date,
                 real_type,
                 dr_cr_type,
                 vouchar_type,
                 real_amount,
                 prin_balance,
                 int_charged,
                 int_balance,
                 tot_balance,
                 entd_by,
                 entd_on)
              values
                (id.entity_num,
                 id.emp_id,
                 id.loan_type,
                 id.real_year,
                 id.real_month_code,
                 id.rel_sl,
                 id.real_date,
                 v_real_type,
                 id.dr_cr_type,
                 id.vouchar_type,
                 id.real_amount,
                 v_curr_prin_bal,
                 v_intr_chg_on_prin,
                 v_tot_intr_bal,
                 v_tot_bal,
                 id.entd_by,
                 id.entd_on);
            
              update elms_ln_summary s
                 set s.prin_balance = v_curr_prin_bal,
                     s.int_balance  = v_tot_intr_bal,
                     s.tot_balance  = v_tot_bal
               where s.entity_num = p_entity_num
                 and s.emp_id = idx.emp_id
                 and s.loan_type = p_loan_type;
            exception
              when others then
                dbms_output.put_line('inserting error for ' || idx.emp_id || '-' ||
                                     idx.loan_type || '-' || idx.real_date);
            end;
          end if;
        end loop;
      end if;
    
    end loop;
  exception
    when others then
      p_error := '';
  end sp_accrual_process;

procedure sp_ln_closing(p_year in number, p_type in varchar2) is
  c1      number := 7;
  c2      number := 1;
  v_error varchar2(400) := '';
begin
  loop
    if c1 > 12 and c2 > 6 then
      exit;
    end if;
  
    if c1 < 13 then
     -- dbms_output.put_line(c1 || '-' || v_year);
      SP_ACCRUAL_PROCESS(1, p_year, c1, p_type, v_error);
      c1 := c1 + 1;
    end if;
  
    if c1 > 12 then
     -- dbms_output.put_line(c2 || '-' || to_char(v_year + 1));
      SP_ACCRUAL_PROCESS(1, p_year + 1, c2, p_type, v_error);
      c2 := c2 + 1;
    end if;
  
  end loop;
end sp_ln_closing;
begin
  null;
end pkg_ln_Closing;
/
