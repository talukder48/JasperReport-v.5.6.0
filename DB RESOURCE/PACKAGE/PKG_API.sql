create or replace package PKG_API is
  procedure sp_transaction_post(p_branch_code     in varchar2,
                                p_customer_mobile in varchar2,
                                p_loan_code       in varchar2,
                                p_memo_no         in varchar2,
                                p_purpose_code    in varchar2,
                                p_transaction_id  in varchar2,
                                p_txn_amount      in varchar2,
                                p_txn_date        in varchar2,
                                p_txn_receiver    in varchar2,
                                p_vat_amount      in varchar2,
                                p_status_code     out varchar2,
                                p_status_message  out varchar2,
                                p_ref             out varchar2,
                                p_balance         out varchar2,
                                p_rspSms          out varchar2);
  procedure sp_loan_account_info(p_office_code    in varchar2,
                                 p_loan_code      in varchar2,
                                 p_product_nature in varchar2,
                                 p_BorrowerName   in varchar2,
                                 p_FathersName    in varchar2,
                                 p_lnstatus       in varchar2,
                                 p_MailAddress    in varchar2,
                                 p_PhoneNumber    in varchar2,
                                 p_SiteLocation   in varchar2,
                                 p_Address        in varchar2,
                                 p_NID            in varchar2,
                                 p_TIN            in varchar2,
                                 p_error          out varchar2);
end PKG_API;
/
create or replace package body PKG_API is
  procedure sp_transaction_post(p_branch_code     in varchar2,
                                p_customer_mobile in varchar2,
                                p_loan_code       in varchar2,
                                p_memo_no         in varchar2,
                                p_purpose_code    in varchar2,
                                p_transaction_id  in varchar2,
                                p_txn_amount      in varchar2,
                                p_txn_date        in varchar2,
                                p_txn_receiver    in varchar2,
                                p_vat_amount      in varchar2,
                                p_status_code     out varchar2,
                                p_status_message  out varchar2,
                                p_ref             out varchar2,
                                p_balance         out varchar2,
                                p_rspSms          out varchar2) is
    v_account_not_found      exception;
    v_transaction_data_exist exception;
    v_Transaction_error      exception;
    pragma exception_init(v_account_not_found, -1001);
    pragma exception_init(v_transaction_data_exist, -1002);
    pragma exception_init(v_Transaction_error, -1003);
    v_account_exist_check     number := 0;
    v_transaction_exist_check number := 0;
    v_reference               varchar2(40) := '';
    v_Error_check             varchar2(200) := '';
    v_SMS                     varchar2(200) := '';
    v_balance                 number := 0;
  
  begin
    p_ref     := 'N/A';
    p_balance := 'N/A';
    p_rspSms  := 'N/A';
    select count(*)
      into v_account_exist_check
      from loan_account a
     where a.loc_code = p_branch_code
       and a.loan_code = p_loan_code;
    select count(*)
      into v_transaction_exist_check
      from API_TRANSACTION_DATA a
     where a.transaction_id = p_transaction_id;
  
    if v_account_exist_check = 0 then
      raise v_account_not_found;
    else
      if v_transaction_exist_check = 0 then
      
        begin
          pkg_autopost.sp_autopost_api(p_branch_code,
                                       p_customer_mobile,
                                       p_loan_code,
                                       p_memo_no,
                                       p_purpose_code,
                                       p_transaction_id,
                                       p_txn_amount,
                                       p_txn_date,
                                       p_txn_receiver,
                                       p_vat_amount,
                                       v_reference,
                                       v_balance,
                                       v_SMS,
                                       v_Error_check);
        
        exception
          when others then
            raise v_Transaction_error;
        end;
        if v_Error_check is null then
          if p_purpose_code <> '11' then
            p_balance := 'N/A';
          else
            p_balance := v_balance;
          end if;
        
          p_rspSms := v_SMS;
        
          insert into API_TRANSACTION_DATA
            (receive_id,
             branch_code,
             customer_mobile,
             loan_code,
             memo_no,
             prossing_date_time,
             purpose_code,
             transaction_id,
             txn_amount,
             txn_date,
             txn_receiver,
             vat_amount,
             reference_number,
             loan_bal,
             sms_body)
          valueS
            (TRAN_RECIVE_ID.NEXTVAL,
             p_branch_code,
             p_customer_mobile,
             p_loan_code,
             p_memo_no,
             SYSDATE,
             p_purpose_code,
             p_transaction_id,
             TO_NUMBER(p_txn_amount),
             to_date(p_txn_date, 'DD-MON-YYYY'),
             p_txn_receiver,
             TO_NUMBER(p_vat_amount),
             v_reference,
             v_balance,
             v_SMS);
        
          p_status_code    := '200';
          p_status_message := 'Sucess';
          p_ref            := v_reference;
        
        else
          raise v_Transaction_error;
        end if;
      else
        select a.sms_body,a.reference_number,a.loan_bal
          into p_rspSms, p_ref    ,  p_balance
          from API_TRANSACTION_DATA a
         where a.transaction_id = p_transaction_id;
        /*To do here*/
        raise v_transaction_data_exist;
      end if;
    end if;
  
  exception
    when v_account_not_found then
      p_status_code    := '202';
      p_status_message := 'Transaction Account not found!!';
    
    when v_transaction_data_exist then
      p_status_code    := '200';
      p_status_message := 'Sucess';
    
    when v_Transaction_error then
      p_status_code    := '203';
      p_status_message := 'Transaction Fail!!' || sqlerrm;
    
    when others then
      p_status_code    := '203';
      p_status_message := 'Transaction Fail!!' || sqlerrm;
    
  end sp_transaction_post;

  procedure sp_loan_account_info(p_office_code    in varchar2,
                                 p_loan_code      in varchar2,
                                 p_product_nature in varchar2,
                                 p_BorrowerName   in varchar2,
                                 p_FathersName    in varchar2,
                                 p_lnstatus       in varchar2,
                                 p_MailAddress    in varchar2,
                                 p_PhoneNumber    in varchar2,
                                 p_SiteLocation   in varchar2,
                                 p_Address        in varchar2,
                                 p_NID            in varchar2,
                                 p_TIN            in varchar2,
                                 p_error          out varchar2) is
  
    v_exist number := 0;
  begin
    select count(*)
      into v_exist
      from loan_account a
     where a.loc_code = p_office_code
       and a.loan_code = p_loan_code
       and a.product_nature = p_product_nature;
  
    if v_exist > 0 then
      update loan_account a
         set borrower_name    = p_BorrowerName,
             borrower_f_name  = p_FathersName,
             site_location    = p_SiteLocation,
             mailing_location = p_Address,
             ln_status        = p_lnstatus,
             nid              = p_NID,
             tin              = p_TIN,
             mail_id          = p_MailAddress,
             mobile_no        = p_PhoneNumber
       where a.loc_code = p_office_code
         and a.loan_code = p_loan_code
         and a.product_nature = p_product_nature;
    else
      insert into loan_account
        (loc_code,
         loan_code,
         borrower_name,
         borrower_f_name,
         site_location,
         mailing_location,
         ln_status,
         nid,
         tin,
         mail_id,
         mobile_no,
         product_nature)
      values
        (p_office_code,
         p_loan_code,
         p_BorrowerName,
         p_FathersName,
         p_SiteLocation,
         p_Address,
         p_lnstatus,
         p_NID,
         p_TIN,
         p_MailAddress,
         p_PhoneNumber,
         p_product_nature);
    end if;
  end sp_loan_account_info;

begin
  NULL;
end PKG_API;
/
