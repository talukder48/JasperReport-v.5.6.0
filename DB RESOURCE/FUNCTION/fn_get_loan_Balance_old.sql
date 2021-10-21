create or replace function fn_get_loan_Balance_old(p_branchCode     in varchar2,
                                               p_loanCode       in varchar2,
                                               p_product_nature in varchar2)
  return number is
  v_balance number := 0;
begin

  if p_product_nature = 'OLD' then
    select b.cum_prin_bal + b.cum_int_bal
      into v_balance
      from tmp_rpt_bal@olddb b
     where b.loc_code = p_branchCode
       and b.loan_code = p_loanCode;
 
  else
  
    select b.cum_prin_bal + b.cum_int_bal
      into v_balance
      from tmp_rpt_bal@govdb b
     where b.loc_code = p_branchCode
       and b.loan_code = p_loanCode;
  
  end if;

  return v_balance;
exception
  when others then
    return 0;
end fn_get_loan_Balance_old;
/
