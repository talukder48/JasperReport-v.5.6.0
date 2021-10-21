create or replace package pkg_autopost is

  procedure sp_autopost_api(p_branch_code     in varchar2,
                            p_customer_mobile in varchar2,
                            p_loan_code       in varchar2,
                            p_memo_no         in varchar2,
                            p_purpose_code    in varchar2,
                            p_transaction_id  in varchar2,
                            p_txn_amount      in varchar2,
                            p_txn_date        in varchar2,
                            p_txn_receiver    in varchar2,
                            p_vat_amount      in varchar2,
                            p_reference       out varchar2,
                            p_balance         out number,
                            p_sms             out varchar2,
                            p_error_message   out varchar2);
  procedure sp_autopost_prms(p_branch    in varchar2,
                             p_tran_date in date,
                             p_advice    in varchar2,
                             p_remarks   in varchar2,
                             p_user_id   in varchar2,
                             p_batch     out varchar2,
                             p_error     out varchar2);
  procedure sp_autopost_expenditure(p_branch    in varchar2,
                                    p_glcode    in varchar2,
                                    p_tran_date in date,
                                    p_remarks   in varchar2,
                                    p_user_id   in varchar2,
                                    p_batch     out varchar2,
                                    p_error     out varchar2);
  procedure sp_autopost_income(p_branch    in varchar2,
                               p_glcode    in varchar2,
                               p_tran_date in date,
                               p_remarks   in varchar2,
                               p_user_id   in varchar2,
                               p_batch     out varchar2,
                               p_error     out varchar2);

end pkg_autopost;
/
create or replace package body pkg_autopost is
  function fn_get_db_tye(p_branch_code in varchar2,
                         p_loan_code   in varchar2) return varchar2
  
   is
    v_db_type varchar2(5) := '';
  begin
  
    select a.product_nature
      into v_db_type
      from loan_account a
     where a.loc_code = p_branch_code
       and a.loan_code = p_loan_code;
  
    return v_db_type;
  end fn_get_db_tye;

  function fn_get_batch_SL(p_branch_code in varchar2, p_txn_date in date)
    return number is
    v_batch_number number := 0;
  begin
    for idx in (select *
                  from as_batch_sl b
                 where b.branch_code = p_branch_code
                   and b.tran_date = p_txn_date) loop
      v_batch_number := idx.batch_sl + 1;   
    end loop;
    return v_batch_number;  
  end fn_get_batch_SL;

  procedure sp_autopost_api(p_branch_code     in varchar2,
                            p_customer_mobile in varchar2,
                            p_loan_code       in varchar2,
                            p_memo_no         in varchar2,
                            p_purpose_code    in varchar2,
                            p_transaction_id  in varchar2,
                            p_txn_amount      in varchar2,
                            p_txn_date        in varchar2,
                            p_txn_receiver    in varchar2,
                            p_vat_amount      in varchar2,
                            p_reference       out varchar2,
                            p_balance         out number,
                            p_sms             out varchar2,
                            p_error_message   out varchar2) is
  
    v_batch_sl       number := 0;
    v_ho_batch_sl    number := 0;
    v_dbType         varchar2(5) := '';
    v_Remarks        as_transaction_list.remarks%type := '';
    v_narration      as_transaction.naration%type := '';
    v_reference      as_transaction.chq_reference%type := '';
    v_borrower_name  loan_account.borrower_name%type := '';
    v_branch_gl_code varchar2(13) := '';
    v_error          varchar2(100) := '';
  begin
    v_batch_sl    := fn_get_batch_SL(p_branch_code, p_txn_date);
    v_ho_batch_sl := fn_get_batch_SL('9999', p_txn_date);
    v_dbType      := fn_get_db_tye(p_branch_code, p_loan_code);
    v_reference   := 'Txnid:' || p_transaction_id;
    begin
      select a.borrower_name
        into v_borrower_name
        from loan_account a
       where a.loc_code = p_branch_code
         and a.loan_code = p_loan_code;
    
    exception
      when others then
        v_borrower_name := '';
      
    end;
    v_Remarks   := 'Autopost By Sonali Bank API. Borrower Name: ' ||
                   trim(v_borrower_name) || ' & Depositor Mobile : ' ||
                   p_customer_mobile;
    v_narration := 'Autopost  ->Deposited By Loancode:' || p_loan_code ||
                   ' Memo No: ' || p_memo_no;
    select m.glcode
      into v_branch_gl_code
      from AS_BR_COLLECTIONGL_MAP m
     where m.branch_code = p_branch_code;
  
    if v_batch_sl <> 0 and v_ho_batch_sl <> 0 then
      for idx in (select *
                    from as_purpose_param p
                   where p.purpose_code = p_purpose_code) loop
      
        -- HO Voucher Part ; 
      
        BEGIN
        
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
             chq_reference)
          values
            (1,
             '9999',
             p_txn_date,
             '9999152100003',
             1,
             p_txn_amount,
             0,
             v_ho_batch_sl,
             v_narration,
             v_reference);
        
          if p_vat_amount <> 0 then
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
               chq_reference)
            values
              (1,
               '9999',
               p_txn_date,
               '9999152100004',
               3,
               p_vat_amount,
               0,
               v_ho_batch_sl,
               v_narration,
               v_reference);
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
               chq_reference)
            values
              (1,
               '9999',
               p_txn_date,
               '520000000',
               4,
               0,
               p_vat_amount,
               v_ho_batch_sl,
               v_narration,
               v_reference);
          
          end if;
        
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
             chq_reference)
          values
            (1,
             '9999',
             p_txn_date,
             v_branch_gl_code,
             2,
             0,
             p_txn_amount,
             v_ho_batch_sl,
             v_narration,
             v_reference);
        
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
             enty_on,
             check_by,
             check_on,
             auth_by,
             auth_on)
          values
            (1,
             '9999',
             p_txn_date,
             v_ho_batch_sl,
             'V',
             v_Remarks || ' for ' || idx.purpose_desc,
             p_txn_amount + p_vat_amount,
             p_txn_amount + p_vat_amount,
             'API',
             trunc(sysdate),
             'API',
             trunc(sysdate),
             'API',
             trunc(sysdate));
        
          --Branch Voucher Part;  
        
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
             chq_reference)
          values
            (1,
             p_branch_code,
             p_txn_date,
             '500000001',
             1,
             p_txn_amount,
             0,
             v_batch_sl,
             v_narration,
             v_reference);
        
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
             chq_reference)
          values
            (1,
             p_branch_code,
             p_txn_date,
             idx.gl_code,
             2,
             0,
             p_txn_amount,
             v_batch_sl,
             v_narration,
             v_reference);
        
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
             enty_on,
             check_by,
             check_on,
             auth_by,
             auth_on)
          values
            (1,
             p_branch_code,
             p_txn_date,
             v_batch_sl,
             'V',
             v_Remarks,
             p_txn_amount,
             p_txn_amount,
             'API',
             trunc(sysdate),
             'API',
             trunc(sysdate),
             'API',
             trunc(sysdate));
        
          update as_batch_sl s
             set s.batch_sl = v_batch_sl
           where s.branch_code = p_branch_code
             and s.tran_date = p_txn_date;
        
          update as_batch_sl s
             set s.batch_sl = v_ho_batch_sl
           where s.branch_code = '9999'
             and s.tran_date = p_txn_date;
        
          p_reference := p_txn_date || '=[' || '9999' || ',' ||
                         p_branch_code || ']-[' || v_ho_batch_sl || ',' ||
                         v_batch_sl || ']';
        
        Exception
          when others then
            p_error_message := 'GAS: Error' || sqlerrm;
          
        END;
      
        if idx.purpose_code = '11' then
          if p_error_message is null then
            if v_dbType = 'EMI' or v_dbType = 'ISF' or v_dbType = 'OCR' then
              sp_autopost_to_EMI(p_branch_code,
                                 p_loan_code,
                                 p_memo_no,
                                 p_txn_amount,
                                 p_txn_date,
                                 p_txn_receiver,
                                 v_dbType,
                                 v_error);
              p_balance := fn_get_loan_Balance(p_branch_code,
                                               p_loan_code,
                                               v_dbType) - p_txn_amount;
            
            else
              sp_autopost_to_DEF(p_branch_code,
                                 p_loan_code,
                                 p_memo_no,
                                 p_txn_amount,
                                 p_txn_date,
                                 p_txn_receiver,
                                 v_dbType,
                                 v_error);
              p_balance := fn_get_loan_Balance_old(p_branch_code,
                                                   p_loan_code,
                                                   v_dbType) - p_txn_amount;
            
            end if;
          
            p_sms := 'BDT ' || p_txn_amount || ' has credited to A/C(' ||
                     substr(p_loan_code, 1, 2) || '***' ||
                     substr(p_loan_code, 10, 4) || ')' || 'dated on ' ||
                     p_txn_date || '.Txn id:' || p_transaction_id ||
                     '.Current Balance is BDT ' || p_balance || '.';
          end if;
        else
          p_sms := 'BDT ' || p_txn_amount || ' has credited to A/C(' ||
                   substr(p_loan_code, 1, 2) || '***' ||
                   substr(p_loan_code, 10, 4) || ')' || 'dated on ' ||
                   p_txn_date || '.Txn id:' || p_transaction_id || '.';
        
        end if;
      end loop;
    else
      p_error_message := 'Must Run Day begin process !!';
    end if;
  
  exception
    when others then
      p_error_message := 'Error in sp_autopost_api' || sqlerrm;
  end sp_autopost_api;

  procedure sp_autopost_prms(p_branch    in varchar2,
                             p_tran_date in date,
                             p_advice    in varchar2,
                             p_remarks   in varchar2,
                             p_user_id   in varchar2,
                             p_batch     out varchar2,
                             p_error     out varchar2) is
  
  begin
    null;
  end sp_autopost_prms;

  procedure sp_autopost_expenditure(p_branch    in varchar2,
                                    p_glcode    in varchar2,
                                    p_tran_date in date,
                                    p_remarks   in varchar2,
                                    p_user_id   in varchar2,
                                    p_batch     out varchar2,
                                    p_error     out varchar2) is
    v_ho_glcode  varchar2(15);
    v_br_glcode  varchar2(15);
    v_ho_batch   number := 0;
    v_br_batch   number := 0;
    v_batch_sum  number := 0;
    v_batch_sl   number := 0;
    v_tmp_dr_amt number := 0;
    v_tmp_cr_amt number := 0;
    v_totalBal   number := 0;
    v_ho_code    varchar2(10);
    V_balance    number(18, 2);
    V_EXCEPTION EXCEPTION;
  begin
  
    SELECT b.cur_bal
      into V_balance
      FROM as_glbalance b
     where b.branch = p_branch
       and b.glcode = p_glcode;
    if V_balance <> 0 then
      SELECT nvl(max(b.batch_sl), 0) + 1
        into v_br_batch
        FROM as_batch_sl b
       where b.branch_code = p_branch
         and b.tran_date = p_tran_date;
    
      SELECT nvl(max(b.batch_sl), 0) + 1
        into v_ho_batch
        FROM as_batch_sl b
       where b.branch_code = '9999'
         and b.tran_date = p_tran_date;
    
      SELECT m.glcode
        into v_ho_glcode
        FROM as_br_gl_mapping m
       where m.branch_code = '9999';
    
      SELECT m.glcode
        into v_br_glcode
        FROM as_br_gl_mapping m
       where m.branch_code = p_branch;
    
      IF p_glcode = '172000000' OR p_glcode = '173000000' THEN
        for idx in (SELECT l.glcode, l.glname, b.cur_bal
                      FROM as_glcodelist l
                      join as_glbalance b
                        on (b.glcode = l.glcode)
                     where b.branch = p_branch
                       and l.lvlcode1 = p_glcode
                       and l.tran_yn = 'Y'
                       and b.cur_bal <> 0) loop
          v_batch_sum := v_batch_sum + idx.cur_bal;
          v_batch_sl  := v_batch_sl + 1;
        
          if idx.cur_bal > 0 then
            v_tmp_dr_amt := idx.cur_bal;
            v_tmp_cr_amt := 0;
          else
            v_tmp_dr_amt := 0;
            v_tmp_cr_amt := -1 * idx.cur_bal;
          end if;
        
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
             p_branch,
             p_tran_date,
             idx.glcode,
             v_batch_sl,
             v_tmp_dr_amt,
             v_tmp_cr_amt,
             v_br_batch,
             'Autopost: ' || idx.glname || ' to Head office',
             '',
             '',
             '',
             '');
        
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
             '9999',
             p_tran_date,
             idx.glcode,
             v_batch_sl,
             v_tmp_cr_amt,
             v_tmp_dr_amt,
             v_ho_batch,
             'Autopost: ' || idx.glname || ' from Branch',
             '',
             '',
             '',
             p_branch || ':' ||
             (SELECT m.brn_name
                FROM prms_mbranch m
               where brn_code = p_branch));
        
        end loop;
        if v_batch_sum <> 0 then
          v_batch_sl := v_batch_sl + 1;
          if v_batch_sum > 0 then
            v_tmp_dr_amt := 0;
            v_tmp_cr_amt := v_batch_sum;
          else
            v_tmp_dr_amt := -1 * v_batch_sum;
            v_tmp_cr_amt := 0;
          end if;
        
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
             p_branch,
             p_tran_date,
             v_ho_glcode,
             v_batch_sl,
             v_tmp_dr_amt,
             v_tmp_cr_amt,
             v_br_batch,
             'Auto post: Transfer  to Head office',
             '',
             '',
             '',
             '');
        
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
             '9999',
             p_tran_date,
             v_br_glcode,
             v_batch_sl,
             v_tmp_cr_amt,
             v_tmp_dr_amt,
             v_ho_batch,
             'Auto post:' || p_branch || ':' ||
             (SELECT m.brn_name
                FROM prms_mbranch m
               where brn_code = p_branch) || ' Transfer  to Head office',
             '',
             '',
             '',
             '');
        
          if v_batch_sum > 0 then
            v_totalBal := v_batch_sum;
          else
            v_totalBal := -1 * v_batch_sum;
          end if;
        
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
             p_branch,
             p_tran_date,
             v_br_batch,
             'V',
             p_remarks,
             v_totalBal,
             v_totalBal,
             p_user_id,
             trunc(sysdate));
        
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
             '9999',
             p_tran_date,
             v_ho_batch,
             'V',
             p_remarks || '(Autopost:> from ' || p_branch || ':' ||
             (SELECT m.brn_name
                FROM prms_mbranch m
               where brn_code = p_branch) || ') to Head Office',
             v_totalBal,
             v_totalBal,
             '0001',
             trunc(sysdate));
        
          update as_batch_sl s
             set s.batch_sl = v_br_batch
           where s.branch_code = p_branch
             and s.tran_date = p_tran_date;
        
          update as_batch_sl s
             set s.batch_sl = v_ho_batch
           where s.branch_code = '9999'
             and s.tran_date = p_tran_date;
        
          p_batch := 'Branch Batch-' || v_br_batch || ' HO Batch -' ||
                     v_ho_batch;
        end if;
      
      END IF;
    else
      p_error := 'No balance Found';
    end if;
  
  EXCEPTION
    WHEN OTHERS THEN
      p_error := '';
  end sp_autopost_expenditure;

  procedure sp_autopost_income(p_branch    in varchar2,
                               p_glcode    in varchar2,
                               p_tran_date in date,
                               p_remarks   in varchar2,
                               p_user_id   in varchar2,
                               p_batch     out varchar2,
                               p_error     out varchar2) is
    v_ho_glcode  varchar2(15);
    v_br_glcode  varchar2(15);
    v_ho_batch   number := 0;
    v_br_batch   number := 0;
    v_batch_sum  number := 0;
    v_batch_sl   number := 0;
    v_tmp_dr_amt number := 0;
    v_tmp_cr_amt number := 0;
    v_totalBal   number := 0;
    v_ho_code    varchar2(10);
    V_balance    number(18, 2);
    V_EXCEPTION EXCEPTION;
  begin
  
    SELECT b.cur_bal
      into V_balance
      FROM as_glbalance b
     where b.branch = p_branch
       and b.glcode = p_glcode;
    if V_balance <> 0 then
      SELECT nvl(max(b.batch_sl), 0) + 1
        into v_br_batch
        FROM as_batch_sl b
       where b.branch_code = p_branch
         and b.tran_date = p_tran_date;
    
      SELECT nvl(max(b.batch_sl), 0) + 1
        into v_ho_batch
        FROM as_batch_sl b
       where b.branch_code = '9999'
         and b.tran_date = p_tran_date;
    
      SELECT m.glcode
        into v_ho_glcode
        FROM as_br_gl_mapping m
       where m.branch_code = '9999';
    
      SELECT m.glcode
        into v_br_glcode
        FROM as_br_gl_mapping m
       where m.branch_code = p_branch;
    
      IF p_glcode = '160000000' THEN
        for idx in (SELECT l.glcode, l.glname, b.cur_bal
                      FROM as_glcodelist l
                      join as_glbalance b
                        on (b.glcode = l.glcode)
                     where b.branch = p_branch
                       and l.mainhead = p_glcode
                       and l.tran_yn = 'Y'
                       and b.cur_bal <> 0) loop
          v_batch_sum := v_batch_sum + idx.cur_bal;
          v_batch_sl  := v_batch_sl + 1;
        
          if idx.cur_bal > 0 then
            v_tmp_dr_amt := idx.cur_bal;
            v_tmp_cr_amt := 0;
          else
            v_tmp_dr_amt := 0;
            v_tmp_cr_amt := -1 * idx.cur_bal;
          end if;
        
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
             p_branch,
             p_tran_date,
             idx.glcode,
             v_batch_sl,
             v_tmp_dr_amt,
             v_tmp_cr_amt,
             v_br_batch,
             'Autopost: ' || idx.glname || ' to Head office',
             '',
             '',
             '',
             '');
        
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
             '9999',
             p_tran_date,
             '161' || substr(idx.glcode, 3, 6),
             v_batch_sl,
             v_tmp_cr_amt,
             v_tmp_dr_amt,
             v_ho_batch,
             'Autopost: ' || idx.glname || ' from Branch',
             '',
             '',
             '',
             p_branch || ':' ||
             (SELECT m.brn_name
                FROM prms_mbranch m
               where brn_code = p_branch));
        
        end loop;
        if v_batch_sum <> 0 then
          v_batch_sl := v_batch_sl + 1;
          if v_batch_sum > 0 then
            v_tmp_dr_amt := 0;
            v_tmp_cr_amt := v_batch_sum;
          else
            v_tmp_dr_amt := -1 * v_batch_sum;
            v_tmp_cr_amt := 0;
          end if;
        
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
             p_branch,
             p_tran_date,
             v_ho_glcode,
             v_batch_sl,
             v_tmp_dr_amt,
             v_tmp_cr_amt,
             v_br_batch,
             'Auto post: Transfer  to Head office',
             '',
             '',
             '',
             '');
        
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
             '9999',
             p_tran_date,
             v_br_glcode,
             v_batch_sl,
             v_tmp_cr_amt,
             v_tmp_dr_amt,
             v_ho_batch,
             'Auto post:' || p_branch || ':' ||
             (SELECT m.brn_name
                FROM prms_mbranch m
               where brn_code = p_branch) || ' Transfer  to Head office',
             '',
             '',
             '',
             '');
        
          if v_batch_sum > 0 then
            v_totalBal := v_batch_sum;
          else
            v_totalBal := -1 * v_batch_sum;
          end if;
        
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
             p_branch,
             p_tran_date,
             v_br_batch,
             'V',
             p_remarks,
             v_totalBal,
             v_totalBal,
             p_user_id,
             trunc(sysdate));
        
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
             '9999',
             p_tran_date,
             v_ho_batch,
             'V',
             p_remarks || '(Autopost:> from ' || p_branch || ':' ||
             (SELECT m.brn_name
                FROM prms_mbranch m
               where brn_code = p_branch) || ') to Head Office',
             v_totalBal,
             v_totalBal,
             '0001',
             trunc(sysdate));
        
          update as_batch_sl s
             set s.batch_sl = v_br_batch
           where s.branch_code = p_branch
             and s.tran_date = p_tran_date;
        
          update as_batch_sl s
             set s.batch_sl = v_ho_batch
           where s.branch_code = '9999'
             and s.tran_date = p_tran_date;
        
          p_batch := 'Branch Batch-' || v_br_batch || ' HO Batch -' ||
                     v_ho_batch;
        end if;
      
      END IF;
    else
      p_error := 'No balance Found';
    end if;
  
  EXCEPTION
    WHEN OTHERS THEN
      p_error := '';
  end sp_autopost_income;

begin
  null;
end pkg_autopost;
/
