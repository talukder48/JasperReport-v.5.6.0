create or replace package pkg_dashBoard is

  type AIS_voucher is record(
    branch_code        varchar2(10),
    Branch_name        varchar2(50),
    voucher_no         number(10),
    record_no          number(10),
    v_last_entry_month varchar2(12));
  type v_AIS_voucher is table of AIS_voucher;
  function fn_get_ais_voucher_summary return v_AIS_voucher
    pipelined;

  TYPE AIS_record IS RECORD(
    branch_code varchar2(10),
    Branch_name varchar2(50),
    JUL         NUMBER(10),
    AUG         NUMBER(10),
    SEP         NUMBER(10),
    OCT         NUMBER(10),
    NOV         NUMBER(10),
    DEC         NUMBER(10),
    JAN         NUMBER(10),
    FEB         NUMBER(10),
    MAR         NUMBER(10),
    APR         NUMBER(10),
    MAY         NUMBER(10),
    JUN         NUMBER(10));
  TYPE V_AIS_record IS TABLE OF AIS_record;
  function fn_get_ais_voucher_details(p_finYear in varchar2) return V_AIS_record
    pipelined;

end pkg_dashBoard;
/
create or replace package body pkg_dashBoard is

  function fn_get_ais_voucher_summary return v_AIS_voucher
    pipelined is
    w_AIS_voucher AIS_voucher;
  begin
    null;
    for id in (SELECT *
                 FROM prms_mbranch b
                where b.brn_code not in ('8888', '0401', '0405')
                  and b.bran_cat_code in ('B', 'H', 'E')) loop
      w_AIS_voucher.branch_code := id.brn_code;
      w_AIS_voucher.Branch_name := id.brn_name;
    
      SELECT count(*)
        into w_AIS_voucher.voucher_no
        FROM as_transaction_list l
       where l.rej_by is null
         and l.orginated_branch = id.brn_code;
    
      select count(*)
        into w_AIS_voucher.record_no
        from as_transaction t
        join as_transaction_list k
          on (t.entity_num = k.entity_num and t.branch = k.orginated_branch and
             t.tran_date = k.tran_date and t.batch_no = k.batch_no)
       where t.entity_num = 1
         and k.rej_on is null
         and t.branch = id.brn_code;
    
      SELECT upper(to_char(MAX(B.Tran_Date), 'Month'))
        into w_AIS_voucher.v_last_entry_month
        FROM as_transaction_list B
       WHERE B.ORGINATED_BRANCH = id.brn_code;
    
      pipe row(w_AIS_voucher);
    end loop;
  
  end fn_get_ais_voucher_summary;

  function fn_get_ais_voucher_details(p_finYear in varchar2) return V_AIS_record
    pipelined is
    w_AIS_record AIS_record;
    v_year1 varchar2(4):='';
    v_year2 varchar2(4):='';
  begin
   v_year1:=substr(p_finYear,1,4);
   v_year2:=substr(p_finYear,6,4);
   dbms_output.put_line(v_year1||'-'||v_year2);
   
    for id in (SELECT *
                 FROM prms_mbranch b
                where b.brn_code not in ('8888', '0401', '0405')
                  and b.bran_cat_code in ('B', 'H', 'E')) loop
      w_AIS_record.branch_code := id.brn_code;
      w_AIS_record.Branch_name := id.brn_name;
    
      select count(*)
        into w_AIS_record.JUL
        from as_transaction t
        join as_transaction_list k
          on (t.entity_num = k.entity_num and t.branch = k.orginated_branch and
             t.tran_date = k.tran_date and t.batch_no = k.batch_no)
       where t.entity_num = 1
         and k.rej_on is null
         and t.branch = id.brn_code
         and t.tran_date between '01-jul-'||v_year1 and '31-jul-'||v_year1;
    
      select count(*)
        into w_AIS_record.AUG
        from as_transaction t
        join as_transaction_list k
          on (t.entity_num = k.entity_num and t.branch = k.orginated_branch and
             t.tran_date = k.tran_date and t.batch_no = k.batch_no)
       where t.entity_num = 1
         and k.rej_on is null
         and t.branch = id.brn_code
         and t.tran_date between '01-aug-'||v_year1 and '31-aug-'||v_year1;
    
      select count(*)
        into w_AIS_record.SEP
        from as_transaction t
        join as_transaction_list k
          on (t.entity_num = k.entity_num and t.branch = k.orginated_branch and
             t.tran_date = k.tran_date and t.batch_no = k.batch_no)
       where t.entity_num = 1
         and k.rej_on is null
         and t.branch = id.brn_code
         and t.tran_date between '01-sep-'||v_year1 and '30-sep-'||v_year1;
    
      select count(*)
        into w_AIS_record.OCT
        from as_transaction t
        join as_transaction_list k
          on (t.entity_num = k.entity_num and t.branch = k.orginated_branch and
             t.tran_date = k.tran_date and t.batch_no = k.batch_no)
       where t.entity_num = 1
         and k.rej_on is null
         and t.branch = id.brn_code
         and t.tran_date between '01-oct-'||v_year1 and '31-oct-'||v_year1;
    
      select count(*)
        into w_AIS_record.NOV
        from as_transaction t
        join as_transaction_list k
          on (t.entity_num = k.entity_num and t.branch = k.orginated_branch and
             t.tran_date = k.tran_date and t.batch_no = k.batch_no)
       where t.entity_num = 1
         and k.rej_on is null
         and t.branch = id.brn_code
         and t.tran_date between '01-nov-'||v_year1 and '30-nov-'||v_year1;
    
      select count(*)
        into w_AIS_record.DEC
        from as_transaction t
        join as_transaction_list k
          on (t.entity_num = k.entity_num and t.branch = k.orginated_branch and
             t.tran_date = k.tran_date and t.batch_no = k.batch_no)
       where t.entity_num = 1
         and k.rej_on is null
         and t.branch = id.brn_code
         and t.tran_date between '01-dec-'||v_year1 and '31-dec-'||v_year1;
    
      select count(*)
        into w_AIS_record.JAN
        from as_transaction t
        join as_transaction_list k
          on (t.entity_num = k.entity_num and t.branch = k.orginated_branch and
             t.tran_date = k.tran_date and t.batch_no = k.batch_no)
       where t.entity_num = 1
         and k.rej_on is null
         and t.branch = id.brn_code
         and t.tran_date between '01-jan-'||v_year2 and '31-jan-'||v_year2;
    
      select count(*)
        into w_AIS_record.FEB
        from as_transaction t
        join as_transaction_list k
          on (t.entity_num = k.entity_num and t.branch = k.orginated_branch and
             t.tran_date = k.tran_date and t.batch_no = k.batch_no)
       where t.entity_num = 1
         and k.rej_on is null
         and t.branch = id.brn_code
         and t.tran_date between '01-feb-'||v_year2 and '28-feb-'||v_year2;
    
      select count(*)
        into w_AIS_record.MAR
        from as_transaction t
        join as_transaction_list k
          on (t.entity_num = k.entity_num and t.branch = k.orginated_branch and
             t.tran_date = k.tran_date and t.batch_no = k.batch_no)
       where t.entity_num = 1
         and k.rej_on is null
         and t.branch = id.brn_code
         and t.tran_date between '01-mar-'||v_year2 and '31-mar-'||v_year2;
    
      select count(*)
        into w_AIS_record.APR
        from as_transaction t
        join as_transaction_list k
          on (t.entity_num = k.entity_num and t.branch = k.orginated_branch and
             t.tran_date = k.tran_date and t.batch_no = k.batch_no)
       where t.entity_num = 1
         and k.rej_on is null
         and t.branch = id.brn_code
         and t.tran_date between '01-apr-'||v_year2 and '30-apr-'||v_year2;
    
      select count(*)
        into w_AIS_record.MAY
        from as_transaction t
        join as_transaction_list k
          on (t.entity_num = k.entity_num and t.branch = k.orginated_branch and
             t.tran_date = k.tran_date and t.batch_no = k.batch_no)
       where t.entity_num = 1
         and k.rej_on is null
         and t.branch = id.brn_code
         and t.tran_date between '01-may-'||v_year2 and '31-may-'||v_year2;
    
      select count(*)
        into w_AIS_record.JUN
        from as_transaction t
        join as_transaction_list k
          on (t.entity_num = k.entity_num and t.branch = k.orginated_branch and
             t.tran_date = k.tran_date and t.batch_no = k.batch_no)
       where t.entity_num = 1
         and k.rej_on is null
         and t.branch = id.brn_code
         and t.tran_date between '01-jun-'||v_year2 and '30-jun-'||v_year2;
    
      pipe row(w_AIS_record);
    end loop;
  
  end fn_get_ais_voucher_details;

begin
  null;
end pkg_dashBoard;
/
