create or replace package pkg_bftn is
  procedure sp_bftn_recipt(p_date in date);
  procedure sp_bftn_process(p_date in date);
  procedure sp_data_posting(p_date in date);
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
             '-21-22' period,
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
  
    r_count number := 0;
    Db_Type varchar2(30) := '';
  begin
    for idx in (select * from bftn_recipt p where p.mig_date = p_date) loop
      begin
        select a.product_nature
          into Db_Type
          from loan_account a
         where a.loan_code = idx.loan_code
           and a.loc_code = idx.loc_code;
        update bftn_recipt r
           set r.prod_nature = Db_Type
         where r.loan_code = idx.loan_code
           and r.loc_code = idx.loc_code;
      exception
        when others then
          update bftn_recipt r
             set r.prod_nature = 'NF'
           where r.loan_code = idx.loan_code
             and r.loc_code = idx.loc_code;
        
      end;
    end loop;
    dbms_output.put_line(r_count);
  end sp_bftn_process;

  procedure sp_data_posting(p_date in date) is
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
                 where r.prod_nature = 'EMI'
                   AND R.MIG_DATE = p_date) loop
    
      insert into tmp_receipt@emidb
        (PERIOD,
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
         ENT_SL_NO,
         PROCESSED,
         ORG_LOC_CODE,
         IDCP,
         LOAN_PRODUCT,
         ACTUAL_LOC_CODE,
         ACTUAL_ERROR,
         BRANCH_CODE)
      values
        (idx.PERIOD,
         idx.BANK,
         idx.LOAN_TYPE,
         idx.LOAN_ACC,
         idx.LOAN_CAT,
         idx.LOC_CODE,
         idx.MEMO_NO,
         idx.PAY_DATE,
         idx.PAY_AMT,
         idx.PURPOSE,
         idx.ENTRY_USER,
         idx.ENTRY_DATE,
         idx.UPDATE_USER,
         idx.UPDATE_DATE,
         idx.LN_TYPE_BK,
         idx.ERROR_CODE,
         idx.ENT_SL_NO,
         idx.PROCESSED,
         idx.ORG_LOC_CODE,
         idx.IDCP,
         idx.LOAN_PRODUCT,
         idx.ACTUAL_LOC_CODE,
         idx.ACTUAL_ERROR,
         idx.BRANCH_CODE);
    
    end loop;
  
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
                 where r.prod_nature = 'ISF'
                   AND R.MIG_DATE = p_date) loop
    
      insert into tmp_receipt@isfdb
        (PERIOD,
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
         ENT_SL_NO,
         PROCESSED,
         ORG_LOC_CODE,
         IDCP,
         LOAN_PRODUCT,
         ACTUAL_LOC_CODE,
         ACTUAL_ERROR,
         BRANCH_CODE)
      values
        (idx.PERIOD,
         idx.BANK,
         idx.LOAN_TYPE,
         idx.LOAN_ACC,
         idx.LOAN_CAT,
         idx.LOC_CODE,
         idx.MEMO_NO,
         idx.PAY_DATE,
         idx.PAY_AMT,
         idx.PURPOSE,
         idx.ENTRY_USER,
         idx.ENTRY_DATE,
         idx.UPDATE_USER,
         idx.UPDATE_DATE,
         idx.LN_TYPE_BK,
         idx.ERROR_CODE,
         idx.ENT_SL_NO,
         idx.PROCESSED,
         idx.ORG_LOC_CODE,
         idx.IDCP,
         idx.LOAN_PRODUCT,
         idx.ACTUAL_LOC_CODE,
         idx.ACTUAL_ERROR,
         idx.BRANCH_CODE);
    
    end loop;
  
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
                 where r.prod_nature = 'OCR'
                   AND R.MIG_DATE = p_date) loop
    
      insert into tmp_receipt@ocrdb
        (PERIOD,
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
         ENT_SL_NO,
         PROCESSED,
         ORG_LOC_CODE,
         IDCP,
         LOAN_PRODUCT,
         ACTUAL_LOC_CODE,
         ACTUAL_ERROR,
         BRANCH_CODE)
      values
        (idx.PERIOD,
         idx.BANK,
         idx.LOAN_TYPE,
         idx.LOAN_ACC,
         idx.LOAN_CAT,
         idx.LOC_CODE,
         idx.MEMO_NO,
         idx.PAY_DATE,
         idx.PAY_AMT,
         idx.PURPOSE,
         idx.ENTRY_USER,
         idx.ENTRY_DATE,
         idx.UPDATE_USER,
         idx.UPDATE_DATE,
         idx.LN_TYPE_BK,
         idx.ERROR_CODE,
         idx.ENT_SL_NO,
         idx.PROCESSED,
         idx.ORG_LOC_CODE,
         idx.IDCP,
         idx.LOAN_PRODUCT,
         idx.ACTUAL_LOC_CODE,
         idx.ACTUAL_ERROR,
         idx.BRANCH_CODE);
    
    end loop;
  
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
                 where r.prod_nature = 'OLD'
                   AND R.MIG_DATE = p_date) loop
    
      insert into tmp_receipt@OLDDB
        (PERIOD,
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
         ENT_SL_NO,
         PROCESSED,
         ORG_LOC_CODE,
         IDCP,
         ACTUAL_LOC_CODE,
         ACTUAL_ERROR,
         BRANCH_CODE)
      values
        (idx.PERIOD,
         idx.BANK,
         idx.LOAN_TYPE,
         idx.LOAN_ACC,
         idx.LOAN_CAT,
         idx.LOC_CODE,
         idx.MEMO_NO,
         idx.PAY_DATE,
         idx.PAY_AMT,
         idx.PURPOSE,
         idx.ENTRY_USER,
         idx.ENTRY_DATE,
         idx.UPDATE_USER,
         idx.UPDATE_DATE,
         idx.LN_TYPE_BK,
         idx.ERROR_CODE,
         idx.ENT_SL_NO,
         idx.PROCESSED,
         idx.ORG_LOC_CODE,
         idx.IDCP,
         idx.ACTUAL_LOC_CODE,
         idx.ACTUAL_ERROR,
         idx.BRANCH_CODE);
    
    end loop;
    /*select *from   tmp_receipt@EMIDB d where d.period like '%-21-22' and ENTRY_USER='BEFTN' ;
    select *from   tmp_receipt@ISFDB d where d.period like '%-21-22' and ENTRY_USER='BEFTN' ;
    select *from   tmp_receipt@OCRDB d where d.period like '%-21-22' and ENTRY_USER='BEFTN' ;
    select *from   tmp_receipt@OLDDB d where d.period like '%-21-22' and ENTRY_USER='BEFTN' ;*/
  end sp_data_posting;
begin
  -- Initialization
  null;
end pkg_bftn;
/
