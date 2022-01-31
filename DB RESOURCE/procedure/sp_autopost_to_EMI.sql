create or replace procedure sp_autopost_to_EMI(p_branch_code     in varchar2,
                                  p_loan_code       in varchar2,
                                  p_memo_no         in varchar2,
                                  p_txn_amount      in varchar2,
                                  p_txn_date        in varchar2,
                                  p_txn_receiver    in varchar2,
                                  p_product_nature  in varchar2,
                                  p_error_message   out varchar2
                                  ) is
   begin
     
    if p_product_nature = 'EMI' then
          insert into tmp_receipt@emidb
            (period, bank,loan_type, loan_acc, loan_cat, loc_code, memo_no, pay_date,pay_amt, purpose, entry_user, entry_date, ln_type_bk, error_code, ent_sl_no, idcp, loan_product, actual_loc_code, actual_error, branch_code)
          values
            (rtrim(to_char(to_date(p_txn_date, 'dd/mm/rrrr'), 'MON')) ||'-21-22','666601', substr(p_loan_code, 1, 1), substr(p_loan_code, 2, 8),'00', p_branch_code,p_memo_no,p_txn_date,p_txn_amount,'M',p_txn_receiver,trunc(sysdate), substr(p_loan_code, 1, 1), '', p_memo_no, 'N', substr(p_loan_code, 13, 1), p_branch_code,   '', p_branch_code);
        elsif p_product_nature = 'ISF' then
           insert into tmp_receipt@isfdb
            (period, bank,loan_type, loan_acc, loan_cat, loc_code, memo_no, pay_date,pay_amt, purpose, entry_user, entry_date, ln_type_bk, error_code, ent_sl_no, idcp, loan_product, actual_loc_code, actual_error, branch_code)
          values
            (rtrim(to_char(to_date(p_txn_date, 'dd/mm/rrrr'), 'MON')) ||'-21-22','666601', substr(p_loan_code, 1, 1), substr(p_loan_code, 2, 8),'00', p_branch_code,p_memo_no,p_txn_date,p_txn_amount,'M',p_txn_receiver,  trunc(sysdate), substr(p_loan_code, 1, 1), '', p_memo_no, 'N', substr(p_loan_code, 13, 1), p_branch_code,   '', p_branch_code);
        elsif p_product_nature = 'OCR' then
           insert into tmp_receipt@ocrdb
            (period, bank,loan_type, loan_acc, loan_cat, loc_code, memo_no, pay_date,pay_amt, purpose, entry_user, entry_date, ln_type_bk, error_code, ent_sl_no, idcp, loan_product, actual_loc_code, actual_error, branch_code)
          values
            (rtrim(to_char(to_date(p_txn_date, 'dd/mm/rrrr'), 'MON')) ||'-21-22','666601', substr(p_loan_code, 1, 1), substr(p_loan_code, 2, 8),'00', p_branch_code,p_memo_no,p_txn_date,p_txn_amount,'M',p_txn_receiver,  trunc(sysdate), substr(p_loan_code, 1, 1), '', p_memo_no, 'N', substr(p_loan_code, 13, 1), p_branch_code,   '', p_branch_code);
       end if;
   exception when others then 
      p_error_message:='sp_autopost_to_EMI'||sqlerrm;
           
   end sp_autopost_to_EMI;
/
