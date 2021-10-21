create or replace package pkg_Pf_Closing is
  procedure sp_pf_init(p_year in number);
  procedure sp_pf_closing(p_year in number);
  procedure sp_insert_blank_month(p_type in varchar2,p_year in number);
  procedure sp_data_migration(p_ln_type in varchar2, p_year in number);
  procedure sp_final_pf_closing(p_year in number);
  procedure manual_blank_month;
  procedure sp_pf_process(p_entity_num in number,
                          p_year       in number,
                          p_month_code in number,
                          p_error      out varchar2);
end pkg_Pf_Closing;
/
create or replace package body pkg_Pf_Closing is
  procedure sp_data_migration(p_ln_type in varchar2, p_year in number) is
  
  begin    
    if p_ln_type = 'PF' then             

      delete from elms_pf_realization p
       where p.real_year = p_year
         and p.real_month_code > 6;
      delete from elms_pf_realization p
       where p.real_year = p_year + 1
         and p.real_month_code < 7;
      insert into elms_pf_realization
        select 1,
               t.emp_id,t.sal_year ,t.month_code,
               1,
               t.pf_deduction,
               t.pfadv_deduc,
               'S',
               0,
               t.pfadv_deduc,
               'N',
               0,
               0,
               'AUTO',
               trunc(sysdate),
               '',
               '',
               trunc(sysdate),
               ''
          from prms_transaction t where t.sal_year=p_year and t.month_code>6;
          
           insert into elms_pf_realization
        select 1,
               t.emp_id,t.sal_year ,t.month_code,
               1,
               t.pf_deduction,
               t.pfadv_deduc,
               'S',
               0,
               t.pfadv_deduc,
               'N',
               0,
               0,
               'AUTO',
               trunc(sysdate),
               '',
               '',
               trunc(sysdate),
               ''
          from prms_transaction t where t.sal_year=p_year+1 and t.month_code<7;
      
   end if;

  end sp_data_migration;
procedure sp_insert_blank_month(p_type in varchar2,p_year in number) is
  v_count number := 0;
  c1      number := 7;
  c2      number := 1;
begin
  begin
    for idx in (select * FROM elms_pf_summary) loop
      select count(*)
        into v_count
        from (select *
                from elms_pf_realization r
               where r.entity_num = 1
                 and r.real_year = p_year
                 and r.real_month_code > 6
              union
              select *
                from elms_pf_realization r
               where r.entity_num = 1
                 and r.real_year = p_year+1
                 and r.real_month_code < 7)
       where emp_id = idx.emp_id;
      if v_count < 12 then
          c1 := 7;
          c2 := 1;       
       loop
          if c1 > 12 and c2 > 6 then
            exit;
          end if;
        
          if c1 < 13 then
            begin
             insert into elms_pf_realization values(1,idx.emp_id,p_year,c1,1,0,0,'S',0,0,'N',0,0,'AUTO',trunc(sysdate),'','','','');
            exception when others then
              dbms_output.put_line('no insert');
            end;
            c1 := c1 + 1;
          end if;
        
          if c1 > 12 then
            begin          
              insert into elms_pf_realization values(1,idx.emp_id,p_year+1,c2,1,0,0,'S',0,0,'N',0,0,'AUTO',trunc(sysdate),'','','','');
            exception when others then
              dbms_output.put_line('no insert');
            end;
            c2 := c2 + 1;
          end if;        
        end loop;
      end if;
    end loop;
  end;

end sp_insert_blank_month;

  procedure sp_pf_init(p_year in number) is
  begin
    delete from ELMS_PF_SUMMARY;
    insert into ELMS_PF_SUMMARY
      SELECT vl.entity_num,
             vl.emp_id,
             0,
             vl.pf_balance,
             vl.pf_adv1_bal,
             vl.pf_adv2_bal,
             vl.pf_adv3_bal,
             vl.pf_tot_bal,
             vl.adv1_ins,
             vl.adv2_ins,
             vl.adv3_ins,
             vl.pf_adv_tot_ins
        FROM elms_pf_leadger vl
       where vl.pf_year = p_year
         and vl.pf_month_code = '6';
  
    delete from elms_pf_leadger r
     where r.pf_year = p_year
       and r.pf_month_code > 6;
    delete from elms_pf_leadger r where r.pf_year = p_year + 1;
    /* new pf opening balance */
    for idx in (    select *from((select s.emp_id
                  from prms_emp_sal s
                minus
                select s.emp_id
                  from elms_pf_summary s)
                  
                  union
           ( select distinct s.emp_id
                  from elms_pf_realization s
                minus
                select s.emp_id
                  from elms_pf_summary s))) loop
    
      insert into elms_pf_leadger
        (entity_num,
         emp_id,
         pf_year,
         pf_month_code,
         vouchar_type,
         pf_sl,
         pf_balance,
         pf_adv1_bal,
         pf_adv2_bal,
         pf_adv3_bal,
         pf_tot_bal,
         entd_by,
         entd_on)
      values
        (1,
         idx.emp_id,
         p_year,
         '6',
         'PFC',
         '1',
         0,
         0,
         0,
         0,
         0,
         'AUTO',
         trunc(sysdate));
      insert into elms_pf_summary
        (entity_num,
         emp_id,
         pf_balance,
         pf_adv1_bal,
         pf_adv2_bal,
         pf_adv3_bal,
         pf_tot_bal)
      values
        (1, idx.emp_id, 0, 0, 0, 0, 0);
    end loop;
  end sp_pf_init;

  

procedure sp_final_pf_closing(p_year in number) is
begin
  sp_pf_init(p_year);
  sp_insert_blank_month('PF',p_year);
  sp_pf_closing(p_year);
end sp_final_pf_closing;


procedure manual_blank_month is 
c1 number := 7;
  c2 number := 1;
  v_exist number:=0;
  v_period varchar2(9);
  function fn_decode(p1 in number) return varchar2 is
  begin
    if p1 = 1 then
      return 'JAN-19-20';
    elsif p1 = 2 then
      return 'FEB-19-20';
    elsif p1 = 3 then
      return 'MAR-19-20';
    elsif p1 = 4 then
      return 'APR-19-20';
    elsif p1 = 5 then
      return 'MAY-19-20';
    elsif p1 = 6 then
      return 'JUN-19-20';
    elsif p1 = 7 then
      return 'JUL-19-20';
    elsif p1 = 8 then
      return 'AUG-19-20';
    elsif p1 = 9 then
      return 'SEP-19-20';
    elsif p1 = 10 then
      return 'OCT-19-20';
    elsif p1 = 11 then
      return 'NOV-19-20';
    elsif p1 = 12 then
      return 'DEC-19-20';
    else return 'YY';
    end if;
  
  end fn_decode;
begin

  for idx in ( select *from bhbfc.pf/*select acc_no, count(*)
                from bhbfc.pfcont
               group by acc_no
              having count(*) < 12*/) loop            
    c1 := 7;
    c2 := 1;
   
    loop
    
      if c1 > 12 and c2 > 6 then
        exit;
      end if;
    
      if c1 < 13 then
        v_period:=fn_decode(c1);
      select count(*) into v_exist from bhbfc.pfcont t 
             where t.period=v_period
             and t.acc_no=idx.acc_no;
        if v_exist=0 then
            insert into bhbfc.pfcont  values ('001',v_period,idx.acc_no,0,0,'','',trunc(sysdate),'2020-2021','','Q') ;        
        end if;        
        c1 := c1 + 1;
      end if;
    
      if c1 > 12 then
         v_period:=fn_decode(c2);
      select count(*) into v_exist from bhbfc.pfcont t 
             where t.period=v_period
                    and t.acc_no=idx.acc_no;
        if v_exist=0 then
          --null;
            insert into bhbfc.pfcont  values ('001',v_period,idx.acc_no,0,0,'','',trunc(sysdate),'2020-2021','','Q') ;        
        end if;        
        c2 := c2 + 1;
      end if;
    end loop;
   
  end loop;  
end manual_blank_month;
function month_day(p_month_code in number, p_year in number) return number is
    v_days number := 0;
  begin
    if p_month_code = 2 then
      if remainder(p_year, 400) = 0 then
        v_days := 29;
      elsif (remainder(p_year, 4)) = 0 then
        if (remainder(p_year, 100)) <> 0 then
          v_days := 29;
        end if;
      else
        v_days := 28;
      end if;
    elsif p_month_code = 1 or p_month_code = 3 or p_month_code = 5 or
          p_month_code = 7 or p_month_code = 8 or p_month_code = 10 or
          p_month_code = 12 then
      v_days := 31;
    else
      v_days := 30;
    end if;
    return v_days;
  end;
procedure sp_pf_process(p_entity_num in number,
                          p_year       in number,
                          p_month_code in number,
                          p_error      out varchar2) is
  
    v_prv_balance     number(13, 2) := 0;
    v_cur_balance     number(13, 2) := 0;
    v_prv_adv1_bal    number(13, 2) := 0;
    v_prv_adv2_bal    number(13, 2) := 0;
    v_prv_adv3_bal    number(13, 2) := 0;
    v_ins_adv1_bal    number(13, 2) := 0;
    v_ins_adv2_bal    number(13, 2) := 0;
    v_ins_adv3_bal    number(13, 2) := 0;
    v_int_chg_amt     number(13, 2) := 0;        
    v_pf_adv_amt      number(13, 2) := 0;
    v_year            number := 0;
    v_mon             number := 0;
    v_days            number := 0;
    v_days_count      number := 0;
    v_int_rate        number := 0.13;
    v_cum_sum         number := 0;
    v_new_installment number := 0;
    v_event           number := 0;
    v_days_count1     number := 0;
    v_days_count2     number := 0;
    v_status          varchar2(5):='';
    
    function get_cum_int_amt(p_entity_num in number,
                             p_year       in number,
                             p_month_code in number,
                             p_emp_id     in varchar2) return number is
      v_cum_int_amt number(13, 2) := 0;
    begin
    
      if p_month_code = 6 then
        select nvl(sum(r.int_chg_amt), 0)
          into v_cum_int_amt
          from elms_pf_leadger r
         where r.entity_num = p_entity_num
           and r.emp_id = p_emp_id
           and r.pf_year = p_year
           and r.pf_month_code <= p_month_code;
      elsif p_month_code = 12 then
        select nvl(sum(r.int_chg_amt), 0)
          into v_cum_int_amt
          from elms_pf_leadger r
         where r.entity_num = p_entity_num
           and r.emp_id = p_emp_id
           and r.pf_year = p_year
           and r.pf_month_code <= p_month_code
           and r.pf_month_code > 6;
      end if;
      return v_cum_int_amt;
    end get_cum_int_amt;
  begin
    if remainder(p_year, 400) = 0 then
      v_days := 366;
    elsif (remainder(p_year, 4)) = 0 then
      if (remainder(p_year, 100)) <> 0 then
        v_days := 366;
      end if;
    else
      v_days := 365;
    end if;
    for id in (select *
                 from elms_pf_realization r
                where entity_num = p_entity_num
                  and real_year = p_year
                  and real_month_code = p_month_code
                --  and  emp_id in ('918')
                order by emp_id) loop    
      /* advanced related issue*/    
        
      select s.status_code into v_status  from prms_emp_sal s where s.emp_id=id.emp_id;  
                      
      v_cum_sum := 0;
      select s.pf_balance,
             s.pf_adv1_bal,
             s.pf_adv2_bal,
             s.pf_adv3_bal,
             s.adv_ins1_amt,
             s.adv_ins2_amt,
             s.adv_ins3_amt
        into v_prv_balance,
             v_prv_adv1_bal,
             v_prv_adv2_bal,
             v_prv_adv3_bal,
             v_ins_adv1_bal,
             v_ins_adv2_bal,
             v_ins_adv3_bal
        from elms_pf_summary s
       where s.entity_num = id.entity_num
         and s.emp_id = id.emp_id;
    
    --  v_days_count := month_day(id.real_month_code, id.real_year);                          
            --to do work
      if (nvl(id.voucher_cr, 0)+nvl(id.voucher_dr, 0))>0 then
        /*  select extract(day from id.voucher_date) - 1
                    into v_days_count1
                    from dual;*/
                    
          select extract(day from last_day(trunc(id.voucher_date)))
            into v_days_count
            from dual;
            
          v_days_count2:=v_days_count;  --making 2nd slab days =0
          v_days_count1 := v_days_count - v_days_count2 ;
        
        
          v_int_chg_amt := round((((v_prv_balance-nvl(id.pf_adv_dr_amt, 0))*v_int_rate*v_days_count1)/v_days
                                +((v_prv_balance-nvl(id.pf_adv_dr_amt, 0)+nvl(id.voucher_cr, 0)-nvl(id.voucher_dr, 0)
                                 )*v_int_rate*v_days_count2)/v_days),2);
                 
      else
      select extract(day from last_day(trunc(id.voucher_date)))
            into v_days_count
            from dual;
            
         v_int_chg_amt := round((((v_prv_balance  -nvl(id.pf_adv_dr_amt, 0)) * v_days_count) /
                             v_days) * v_int_rate,
                             2);
      end if;
      if v_int_chg_amt<0 then v_int_chg_amt:=0; end if;
      if v_status ='NAK' then
        v_int_chg_amt:=0;
      end if;
      if p_month_code = 6 or p_month_code = 12 then      
        v_cum_sum := get_cum_int_amt(p_entity_num,
                                     p_year,
                                     p_month_code,
                                     id.emp_id);     
        v_cur_balance := round((v_prv_balance + id.pf_contribution_amt +
                               v_cum_sum + v_int_chg_amt +                               
                               nvl(id.pf_adv_dr_amt, 0) +
                               nvl(id.pf_adv_cr_amt, 0) -
                               nvl(id.voucher_dr, 0) +
                               nvl(id.voucher_cr, 0)),  2);
      else
        v_cur_balance := round((v_prv_balance + id.pf_contribution_amt -
                               nvl(id.pf_adv_dr_amt, 0) +
                               nvl(id.pf_adv_cr_amt, 0) -
                               nvl(id.voucher_dr, 0) +
                               nvl(id.voucher_cr, 0)),
                               2);
      end if;
      v_event := 1;
      
      /* installment calculation  for new advance & Dynamic no of Advance selection */
      if nvl(id.pf_adv_cr_amt, 0) > 0 or nvl(id.pf_adv_dr_amt, 0) > 0 then        
          if nvl(id.pf_adv_dr_amt, 0) > 0 then
            
            select a.pf_adv_ins
              into v_new_installment
              from elms_pf_advance a
             where a.entity_num = 1
               and a.emp_id = id.emp_id
               and a.pf_adv_year = id.real_year
               and a.pf_adv_month_code = id.real_month_code
               and a.pf_adv_amt = id.pf_adv_dr_amt;
          
            if (nvl(v_prv_adv1_bal, 0) <= 0 and nvl(v_prv_adv2_bal, 0) <= 0 and
               nvl(v_prv_adv3_bal, 0) <= 0) or
               (nvl(v_prv_adv1_bal, 0) <= 0 and nvl(v_prv_adv2_bal, 0) <= 0 and
               nvl(v_prv_adv3_bal, 0) > 0) or
               (nvl(v_prv_adv1_bal, 0) <= 0 and nvl(v_prv_adv2_bal, 0) > 0 and
               nvl(v_prv_adv3_bal, 0) > 0) then
              /*position no: (1st)*/
              v_prv_adv1_bal := nvl(id.pf_adv_dr_amt, 0);
              v_ins_adv1_bal := v_new_installment;
            
            elsif (nvl(v_prv_adv1_bal, 0) > 0 and
                  nvl(v_prv_adv2_bal, 0) <= 0 and
                  nvl(v_prv_adv3_bal, 0) <= 0) or
                  (nvl(v_prv_adv1_bal, 0) > 0 and
                  nvl(v_prv_adv2_bal, 0) <= 0 and
                  nvl(v_prv_adv3_bal, 0) > 0) then
              /*position no: (2nd)*/
              v_prv_adv2_bal := nvl(id.pf_adv_dr_amt, 0);
              v_ins_adv2_bal := v_new_installment;
            
            elsif (nvl(v_prv_adv1_bal, 0) > 0 and
                  nvl(v_prv_adv2_bal, 0) > 0 and
                  nvl(v_prv_adv3_bal, 0) <= 0) or
                  (nvl(v_prv_adv1_bal, 0) <= 0 and
                  nvl(v_prv_adv2_bal, 0) > 0 and
                  nvl(v_prv_adv3_bal, 0) <= 0) then
              /*position no: (3rd)*/
              v_prv_adv3_bal := nvl(id.pf_adv_dr_amt, 0);
              v_ins_adv3_bal := v_new_installment;
            end if;
          end if;
        
          if nvl(id.pf_adv_cr_amt, 0) > 0 then           
            if v_prv_adv1_bal> 0 and v_prv_adv2_bal >0  and v_prv_adv3_bal>0  then 
              -----if 3 advances exist   a,b,c                          
               v_prv_adv1_bal:=v_prv_adv1_bal-v_ins_adv1_bal;
               v_prv_adv2_bal:=v_prv_adv2_bal-v_ins_adv2_bal;
               v_prv_adv3_bal:=v_prv_adv3_bal-v_ins_adv3_bal;
              -----if 2 advances  exist  
            elsif v_prv_adv1_bal<= 0 and v_prv_adv2_bal >0  and v_prv_adv3_bal>0 then
              --b,c
              if nvl(id.pf_adv_cr_amt, 0)> v_prv_adv2_bal then
                null;
                v_prv_adv3_bal:=v_prv_adv3_bal-(nvl(id.pf_adv_cr_amt, 0)-v_prv_adv2_bal);
                v_prv_adv2_bal:=0;                
              else
               v_prv_adv2_bal:=v_prv_adv2_bal-v_ins_adv2_bal;
               v_prv_adv3_bal:=v_prv_adv3_bal-v_ins_adv3_bal;  
              end if;  
            elsif v_prv_adv1_bal> 0 and v_prv_adv2_bal <=0  and v_prv_adv3_bal>0 then
              --c,a
                 if nvl(id.pf_adv_cr_amt, 0)> v_prv_adv3_bal then
                   v_prv_adv3_bal:=v_prv_adv3_bal-(nvl(id.pf_adv_cr_amt, 0)-v_prv_adv1_bal);
                   v_prv_adv1_bal:=0;
                 else                     
                   v_prv_adv1_bal:=v_prv_adv1_bal-v_ins_adv1_bal;
                   v_prv_adv3_bal:=v_prv_adv3_bal-v_ins_adv3_bal;
                 end if;    
            elsif v_prv_adv1_bal> 0 and v_prv_adv2_bal >0  and v_prv_adv3_bal<=0 then   
              --a,b
              
              if nvl(id.pf_adv_cr_amt, 0)> v_prv_adv1_bal then
                   v_prv_adv2_bal:=v_prv_adv2_bal-(nvl(id.pf_adv_cr_amt, 0)-v_prv_adv1_bal);
                   v_prv_adv1_bal:=0;
                 else                     
                    v_prv_adv1_bal:=v_prv_adv1_bal-v_ins_adv1_bal;
                    v_prv_adv2_bal:=v_prv_adv2_bal-v_ins_adv2_bal; 
                 end if;    
               
             -----if 1 advance  exist      
            elsif v_prv_adv1_bal> 0 and v_prv_adv2_bal <=0  and v_prv_adv3_bal<=0 then  
              --a 
              v_prv_adv1_bal:=v_prv_adv1_bal-nvl(id.pf_adv_cr_amt, 0);
            elsif v_prv_adv1_bal<= 0 and v_prv_adv2_bal >0  and v_prv_adv3_bal<=0 then  
              --b 
              v_prv_adv2_bal:=v_prv_adv2_bal-nvl(id.pf_adv_cr_amt, 0); 
            elsif v_prv_adv1_bal<= 0 and v_prv_adv2_bal <=0  and v_prv_adv3_bal>0 then  
              --c   
               v_prv_adv3_bal:=v_prv_adv3_bal-nvl(id.pf_adv_cr_amt, 0);                        
            end if;
            
            
                                               
          /*  if v_event = 1 then
              if nvl(v_prv_adv1_bal, 0) - nvl(id.pf_adv_cr_amt, 0) >= 0 then
                v_prv_adv1_bal := v_prv_adv1_bal -
                                  nvl(id.pf_adv_cr_amt, 0);
                v_event        := 0;
              elsif nvl(v_prv_adv1_bal, 0) - nvl(id.pf_adv_cr_amt, 0) < 0 then
                v_prv_adv2_bal := v_prv_adv2_bal -
                                  (nvl(id.pf_adv_cr_amt, 0) -
                                  nvl(v_prv_adv1_bal, 0));
                v_prv_adv1_bal := 0;
                v_event        := 0;
              end if;
            end if;
          
            if v_event = 1 then
              if nvl(v_prv_adv2_bal, 0) - nvl(id.pf_adv_cr_amt, 0) >= 0 then
                v_prv_adv2_bal := v_prv_adv2_bal -
                                  nvl(id.pf_adv_cr_amt, 0);
                v_event        := 0;
              elsif nvl(v_prv_adv2_bal, 0) - nvl(id.pf_adv_cr_amt, 0) < 0 then
                v_prv_adv3_bal := v_prv_adv3_bal -
                                  (nvl(id.pf_adv_cr_amt, 0) -
                                  nvl(v_prv_adv2_bal, 0));
                v_prv_adv2_bal := 0;
                v_event        := 0;
              end if;
            end if;
          
            if v_event = 1 then
              if nvl(v_prv_adv3_bal, 0) - nvl(id.pf_adv_cr_amt, 0) >= 0 then
                v_prv_adv3_bal := v_prv_adv3_bal -
                                  nvl(id.pf_adv_cr_amt, 0);
                v_event        := 0;
              elsif nvl(v_prv_adv3_bal, 0) - nvl(id.pf_adv_cr_amt, 0) < 0 then
                v_prv_adv1_bal := v_prv_adv1_bal -
                                  (nvl(id.pf_adv_cr_amt, 0) -
                                  nvl(v_prv_adv3_bal, 0));
                v_prv_adv3_bal := 0;
                v_event        := 0;
              end if;
            end if;*/
          end if;        
        end if;
    
      update elms_pf_summary s
         set s.cum_int_chg_amt = v_int_chg_amt,
             s.pf_balance      = v_cur_balance,
             s.pf_adv1_bal     = v_prv_adv1_bal,
             s.pf_adv2_bal     = v_prv_adv2_bal,
             s.pf_adv3_bal     = v_prv_adv3_bal,
             s.adv_ins1_amt    = v_ins_adv1_bal,
             s.adv_ins2_amt    = v_ins_adv2_bal,
             s.adv_ins3_amt    = v_ins_adv3_bal
       where s.entity_num = p_entity_num
         and s.emp_id = id.emp_id;
      insert into elms_pf_leadger
        (entity_num,
         emp_id,
         pf_year,
         pf_month_code,
         vouchar_type,
         pf_sl,
         real_type,
         pf_contribution_amt,
         pf_adv_real_amt,
         pf_adv_dr_amt,
         pf_adv_cr_amt,
         voucher_dr,
         voucher_cr,
         int_chg_amt,
         pf_balance,
         pf_adv1_bal,
         pf_adv2_bal,
         pf_adv3_bal,
         pf_tot_bal,
         adv1_ins,
         adv2_ins,
         adv3_ins,
         entd_by,
         entd_on)
      values
        (p_entity_num,
         id.emp_id,
         id.real_year,
         id.real_month_code,
         id.voucher_type,
         id.rel_sl,
         id.pf_real_type,
         id.pf_contribution_amt,
         nvl(id.pf_adv_cr_amt, 0),
         nvl(id.pf_adv_dr_amt, 0),
         nvl(id.pf_adv_cr_amt, 0),
         nvl(id.voucher_dr, 0),
         nvl(id.voucher_cr, 0),
         v_int_chg_amt,
         v_cur_balance,
         v_prv_adv1_bal,
         v_prv_adv2_bal,
         v_prv_adv3_bal,
         v_prv_adv1_bal + v_prv_adv2_bal + v_prv_adv3_bal,
         v_ins_adv1_bal,
         v_ins_adv2_bal,
         v_ins_adv3_bal,
         'AUTO',
         trunc(sysdate));
    
    end loop;
    /*for id in (select *
                 from elms_realization r
                where loan_type = 'PFA'
                  and entity_num = p_entity_num
                  and real_year = p_year
                  and real_month_code = p_month_code
               -- and emp_id = '776'
                order by emp_id) loop
      select s.pf_balance, s.pf_adv1_bal, s.pf_adv2_bal, s.pf_adv3_bal
        into v_prv_balance, v_prv_adv1_bal, v_prv_adv2_bal, v_prv_adv3_bal
        from elms_pf_summary s
       where s.entity_num = id.entity_num
         and s.emp_id = id.emp_id;
    
    \*
             *     need to fix  pf advanced ration info
             *
             *
             *
             *\
    
    end loop;*/
  end sp_pf_process;
procedure sp_pf_closing(p_year in number) is
    c1      number := 7;
    c2      number := 1;
    v_error varchar2(400) := '';
  begin
    loop
      if c1 > 12 and c2 > 6 then
        exit;
      end if;
    
      if c1 < 13 then
        dbms_output.put_line(c1 || '-' || p_year);
        SP_PF_PROCESS(1, p_year, c1, v_error);

        c1 := c1 + 1;
      end if;
    
      if c1 > 12 then
        dbms_output.put_line(c2 || '-' || to_char(p_year + 1));
        SP_PF_PROCESS(1, p_year + 1, c2, v_error);
        c2 := c2 + 1;
      end if;
    
    end loop;
  end sp_pf_closing;
begin
  null;
end pkg_Pf_Closing;
/
