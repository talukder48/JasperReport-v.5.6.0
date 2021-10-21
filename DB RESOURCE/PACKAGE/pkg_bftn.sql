create or replace package pkg_bftn is

end pkg_bftn;
/
create or replace package body pkg_bftn is

  procedure sp_bftn_recipt(p_date in date) is
  begin
    insert into bftn_recipt
      (period,
       bank,
       loan_type,
       loan_acc,
       loan_cat,
       loc_code,
       memo_no,
       pay_date,
       pay_amt,
       purpose,
       entry_user,
       entry_date,
       ln_type_bk,
       error_code,
       idcp,
       loan_product,
       loan_code,
       insert_lot,
       mig_date)
      select rtrim(to_char(to_date(value_date, 'dd/mm/rrrr'), 'MON')) ||
             '-20-21' period,
             '999901' as bank,
             substr(debtor_reference, 7, 1) as loan_type,
             lpad(substr(debtor_reference, 8, 8), 8, '0') as loan_acc,
             substr(debtor_reference, 16, 2) as loan_cat,
             substr(debtor_reference, 2, 4) as loc_code,
             lpad(substr(transaction_sequence_number, 1, 3), 6, '0'),
             to_date(value_date, 'dd/mm/rrrr') as pay_date,
             amount as pay_amt,
             'M' as purpose,
             'BEFTN' entry_user,
             trunc(sysdate) entry_date,
             substr(debtor_reference, 7, 1) as ln_type_bk,
             '   ' error_code,
             'N' idcp,
             substr(debtor_reference, 19, 1) as loan_product,
             substr(debtor_reference, 7, 13) as loan_code,
             insert_lot,
             l.mig_date
        from bftn_xls l
       where l.mig_date = p_date
       order by insert_lot;
  end;
  procedure sp_bftn_process(p_date in date) is
  
    r_count  number := 0;
    db_count number := 0;
    Db_Type  varchar2(30) := '';
  begin
    for idx in (select * from bftn_recipt p where p.mig_date = p_date) loop
      begin
        select decode(a.db_type,
                      'BHBFCPRJ',
                      'ISF',
                      'BHBFCOCR',
                      'OCR',
                      'BHBFCFLAT',
                      'EMI',
                      'D=BHBFC819',
                      'OLD'),
               count(*)
          into Db_Type, db_count
          from lnaccount a
         where A.DB_TYPE in
               ('BHBFCPRJ', 'BHBFCOCR', 'BHBFCFLAT', 'D=BHBFC819')
           and a.loan_code = idx.loan_code
           and a.loc_code = idx.loc_code
         group by decode(a.db_type,
                         'BHBFCPRJ',
                         'ISF',
                         'BHBFCOCR',
                         'OCR',
                         'BHBFCFLAT',
                         'EMI',
                         'D=BHBFC819',
                         'OLD');
        if db_count > 0 then
          r_count := r_count + 1;
          update bftn_recipt r
             set r.prod_nature = Db_Type
           where r.loan_code = idx.loan_code
             and r.loc_code = idx.loc_code;
        else
          update bftn_recipt r
             set r.prod_nature = 'NF'
           where r.loan_code = idx.loan_code
             and r.loc_code = idx.loc_code;
        end if;
      end;
    end loop;
    dbms_output.put_line(r_count);
  end sp_bftn_process;
  procedure sp_select_data(p_date in date, p_type in varchar2) is
  begin
    for idx in (select PERIOD,
                       BANK,
                       LOAN_TYPE,
                       LOAN_ACC,
                       LOAN_CAT,
                       LOC_CODE,
                       MEMO_NO,
                       PAY_DATE,
                       PAY_AMT,
                       PURPOSE,
                       ENTRY_USER,
                       ENTRY_DATE,
                       UPDATE_USER,
                       UPDATE_DATE,
                       LN_TYPE_BK,
                       ERROR_CODE,
                       RECEPT_SEQ.NEXTVAL ENT_SL_NO,
                       PROCESSED,
                       ORG_LOC_CODE,
                       IDCP,
                       LOAN_PRODUCT,
                       ACTUAL_LOC_CODE,
                       ACTUAL_ERROR,
                       BRANCH_CODE
                  from bftn_recipt r
                 where r.prod_nature = p_type
                   and r.mig_date = p_date) loop
      null;
    end loop;
  end sp_select_data;
begin
  -- Initialization
  null;
end pkg_bftn;
/
