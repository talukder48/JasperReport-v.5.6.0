create or replace package pkg_Report_LMS is
  type OBSI is record(
    product_nature varchar2(10),
    loc_code       varchar2(10),
    loc_name       varchar2(50),
    obsi_amount    number(18, 6),
    is_defered     number(18, 6),
    is_recoverable number(18, 6));
  type v_OBSI is table of OBSI;

  function fn_obsi(p_fin_year in varchar2, p_branch_code in varchar2)
    return v_OBSI
    pipelined;

  type rec_data is record(
    product_nature varchar2(10),
    loc_code       varchar2(10),
    loc_name       varchar2(50),
    cl_account     number(10),
    cl_balance     number(18, 6),
    uc_account     number(10),
    uc_balance     number(18, 6),
    cl_overdue     number(18, 6),
    uc_overdue     number(18, 6),
    cl_falldue     number(18, 6),
    uc_falldue     number(18, 6),
    cl_recovery    number(18, 6),
    uc_recovery    number(18, 6));

  type v_data is table of rec_data;

  function fn_loan_recovery_data(p_fin_year    in varchar2,
                                 p_branch_code in varchar2) return v_data
    pipelined;

  type expired_loan is record(
    product_nature varchar2(10),
    LOC_CODE       varchar2(10),
    loc_name       varchar2(50),
    LOAN_CODE      varchar2(13),
    NAME1          varchar2(100),
    SANC_DATE      date,
    SANC_AMT       number(18, 6),
    INT_RATE       number(5, 2),
    REPAY_DATE     date,
    LOAN_PERIOD    number(5),
    ln_criteria    varchar2(5),
    balance        number(18, 6),
    overdue        number(18, 6),
    recovery       number(18, 6));
  type v_expired_loan is table of expired_loan;
  function fn_loan_expired_data(p_fin_year    in varchar2,
                                p_branch_code in varchar2)
    return v_expired_loan
    pipelined;

  type Collection is record(
    product_nature  varchar2(10),
    PERIOD          VARCHAR2(10),
    BANK            VARCHAR2(10),
    LOAN_TYPE       VARCHAR2(2),
    LOAN_ACC        VARCHAR2(10),
    LOAN_CAT        VARCHAR2(2),
    LOC_CODE        VARCHAR2(5),
    MEMO_NO         VARCHAR2(10),
    PAY_Date        Date,
    PAY_AMT         NUMBER(12, 2),
    ENTRY_USER      VARCHAR2(20),
    LOAN_PRODUCT    VARCHAR2(4),
    BRANCH_CODE     VARCHAR2(5),
    ACTUAL_LOC_CODE VARCHAR2(5));
  type v_Collection is table of Collection;
  function fn_Collection(p_fin_year    in varchar2,
                         p_branch_code in varchar2,
                         p_loan_code   in varchar2) return v_Collection
    pipelined;
  function fn_Collection_beftn(p_fromDate    in date,
                               p_toDate      in date,
                               p_branch_code in varchar2) return v_Collection
    pipelined;
  function fn_activeLoan_data(p_fin_year    in varchar2,
                              p_branch_code in varchar2)
    return v_expired_loan
    pipelined;
  function fn_activeLoan_data_previous(p_fin_year    in varchar2,
                                       p_branch_code in varchar2)
    return v_expired_loan
    pipelined;
  type slab_data is record(
    product_nature varchar2(10),
    loc_code       varchar2(10),
    loc_name       varchar2(50),
    prin_balance   number(18, 6),
    int_balance    number(18, 6),
    prin_overdue   number(18, 6),
    int_overdue    number(18, 6),
    prin_falldue   number(18, 6),
    int_falldue    number(18, 6),
    prin_recovery  number(18, 6),
    int_recovery   number(18, 6));
  type v_slab_data is table of slab_data;

  function fn_loan_recovery_slab_data(p_fin_year    in varchar2,
                                      p_branch_code in varchar2)
    return v_slab_data
    pipelined;

  TYPE Ledger IS RECORD(
    Serial               number,
    LOAN_CODE            VARCHAR2(13),
    LOAN_RESC            VARCHAR2(2),
    LEGAL_ACT            VARCHAR2(2),
    LOC_CODE             VARCHAR2(4),
    SANC_DATE            date,
    SANC_AMT             number,
    Disburse_AMT         number,
    PRIN_INST            number,
    INT_INST             number,
    total_INST           number,
    REPAY_DATE           date,
    INT_RATE             number,
    NAME                 VARCHAR2(100),
    ADDRESS              VARCHAR2(150),
    LOAN_PERIOD          VARCHAR2(13),
    LN_CRITERIA          VARCHAR2(13),
    PRL_OR_LPR_DATE      date,
    gracePeriod          number,
    int_amt_by_gov       number,
    int_rate_by_gov      number,
    BK_CODE              VARCHAR2(6),
    TRANS_TYPE           VARCHAR2(3),
    REF_NO               VARCHAR2(10),
    TRANS_DATE           DATE,
    REAL_AMT             NUMBER,
    month                VARCHAR2(3),
    PRIN_REAL            NUMBER,
    PRIN_DRCR            NUMBER,
    ADJ_PRIN_BAL         NUMBER,
    INT_CHARGED          NUMBER,
    PEN_INT_AMT          NUMBER,
    INT_DRCR             NUMBER,
    INT_REAL             NUMBER,
    ADJ_INT_BAL          NUMBER,
    Prin_Inst_ov         NUMBER,
    INT_INST_OV          NUMBER,
    total                NUMBER,
    PREV_CUM_PRIN_BAL    NUMBER,
    PREV_CUM_PEN_INT_AMT NUMBER,
    PREV_CUM_INT_BAL     NUMBER,
    prev_Prin_Inst_ov    NUMBER,
    prev_INT_INST_OV     NUMBER,
    prev_total           NUMBER,
    gov_poreal_amt       number,
    client_poreal_amt    number,
    CUR_PRIN_REAL        number,
    CUR_INT_REAL         number,
    CUR_LUMP_REAL        number,
    CUR_PEN_REAL         number,
    CUR_INT_CHARGE       number,
    CUR_PEN_CHARGED      number,
    CUR_IDCP_AMT         number,
    CUM_PRIN_INST_NO_OV  number,
    CUM_PRIN_INST_OV     number,
    CUM_INT_INST_NO_OV   number,
    CUM_INT_INST_OV      number,
    CUM_LUMP_INST        number,
    CUR_PRIN_DR          number,
    CUR_PRIN_CR          number,
    CUR_INT_DR           number,
    CUR_INT_CR           number,
    CUM_PRIN_BAL         number,
    CUM_INT_BAL          number);
  type V_Ledger is table of Ledger;

  TYPE LoanLedger IS RECORD(
    particular_code number,
    Serial          number,
    particuars      varchar2(40),
    code            varchar2(20),
    Principal_dr    number(18, 2),
    Principal_cr    number(18, 2),
    Principal_Bal   number(18, 2),
    Interest_dr     number(18, 2),
    Interest_cr     number(18, 2),
    Interest_Bal    number(18, 2),
    Total_bal       number(18, 2));
  type V_LoanLedger is table of LoanLedger;

  function fn_get_personal_ledger_stmt(p_loc_code    in varchar2,
                                       p_loan_code   in varchar2,
                                       p_fin_year    in varchar2,
                                       p_report_type in varchar2)
    return V_Ledger
    pipelined;
  function fn_get_loan_ledger(p_branch_code in varchar2,
                              p_loan_type   in varchar2,
                              p_fin_year    in varchar2,
                              p_report_type in varchar2) return V_LoanLedger
    pipelined;
end pkg_Report_LMS;
/
create or replace package body pkg_Report_LMS is

  function fn_obsi(p_fin_year in varchar2, p_branch_code in varchar2)
    return v_OBSI
    pipelined is
    w_OBSI OBSI;
  begin
    w_OBSI.product_nature := 'OLD';
    for id in (select *
                 from prms_mbranch m
                where m.bran_cat_code = 'B'
                  and m.brn_code like p_branch_code) loop
      w_OBSI.loc_code := id.brn_code;
      w_OBSI.loc_name := id.brn_name;
      select nvl(sum(CUR_INTCRGDEF_B), 0) OBSI,
             nvl(SUM(CUR_INTSUSDEF_F), 0) Interest_suspence_def,
             nvl(sum(CUR_INTSUSREC_G), 0) Interest_suspence_recoverable
        into w_OBSI.obsi_amount, w_OBSI.is_defered, w_OBSI.is_recoverable
        from yr_end_bal@olddb
       where fin_year = p_fin_year
         and loc_code = id.brn_code;
      pipe row(w_OBSI);
    end loop;
  
    w_OBSI.product_nature := 'GOV';
    for id in (select *
                 from prms_mbranch m
                where m.bran_cat_code = 'B'
                  and m.brn_code like p_branch_code) loop
      w_OBSI.loc_code := id.brn_code;
      w_OBSI.loc_name := id.brn_name;
      select nvl(sum(CUR_INTCRGDEF_B), 0) OBSI,
             nvl(SUM(CUR_INTSUSDEF_F), 0) Interest_suspence_def,
             nvl(sum(CUR_INTSUSREC_G), 0) Interest_suspence_recoverable
        into w_OBSI.obsi_amount, w_OBSI.is_defered, w_OBSI.is_recoverable
        from yr_end_bal@GOVDB
       where fin_year = p_fin_year
         and loc_code = id.brn_code;
      pipe row(w_OBSI);
    end loop;
  
  end fn_obsi;

  function fn_loan_expired_data(p_fin_year    in varchar2,
                                p_branch_code in varchar2)
    return v_expired_loan
    pipelined is
    w_expired_loan expired_loan;
  begin
    select m.brn_name
      into w_expired_loan.loc_name
      from prms_mbranch m
     where m.bran_cat_code = 'B'
       and m.brn_code = p_branch_code;
    w_expired_loan.product_nature := 'OLD';
    for idx in (SELECT LOC_CODE,
                       LOAN_CODE,
                       NAME1,
                       SANC_DATE,
                       SANC_AMT,
                       INT_RATE,
                       repay_date,
                       loan_period
                  FROM loan_mas@olddb m
                 where m.loc_code = p_branch_code
                   and ADD_MONTHS(m.repay_date, m.loan_period) between
                       '01-jul-' || substr(p_fin_year, 1, 4) and
                       '30-jun-' || substr(p_fin_year, 6, 4)
                   and m.loan_active = 'Y') loop
    
      w_expired_loan.LOC_CODE    := idx.loc_code;
      w_expired_loan.LOAN_CODE   := idx.LOAN_CODE;
      w_expired_loan.NAME1       := idx.NAME1;
      w_expired_loan.SANC_DATE   := idx.SANC_DATE;
      w_expired_loan.SANC_AMT    := idx.SANC_AMT;
      w_expired_loan.INT_RATE    := idx.INT_RATE;
      w_expired_loan.REPAY_DATE  := idx.REPAY_DATE;
      w_expired_loan.LOAN_PERIOD := idx.LOAN_PERIOD;
      pipe row(w_expired_loan);
    end loop;
  
    w_expired_loan.product_nature := 'EMI';
    for idx in (SELECT LOC_CODE,
                       LOAN_CODE,
                       NAME1,
                       SANC_DATE,
                       SANC_AMT,
                       INT_RATE,
                       repay_date,
                       loan_period
                  FROM loan_mas@emidb m
                 where m.loc_code = p_branch_code
                   and ADD_MONTHS(m.repay_date, m.loan_period) between
                       '01-jul-' || substr(p_fin_year, 1, 4) and
                       '30-jun-' || substr(p_fin_year, 6, 4)
                   and m.loan_active = 'Y') loop
    
      w_expired_loan.LOC_CODE    := idx.loc_code;
      w_expired_loan.LOAN_CODE   := idx.LOAN_CODE;
      w_expired_loan.NAME1       := idx.NAME1;
      w_expired_loan.SANC_DATE   := idx.SANC_DATE;
      w_expired_loan.SANC_AMT    := idx.SANC_AMT;
      w_expired_loan.INT_RATE    := idx.INT_RATE;
      w_expired_loan.REPAY_DATE  := idx.REPAY_DATE;
      w_expired_loan.LOAN_PERIOD := idx.LOAN_PERIOD;
      pipe row(w_expired_loan);
    end loop;
  
  end fn_loan_expired_data;

  function fn_activeLoan_data_previous(p_fin_year    in varchar2,
                                       p_branch_code in varchar2)
    return v_expired_loan
    pipelined is
    w_expired_loan expired_loan;
  begin
    /* select m.brn_name
     into w_expired_loan.loc_name
     from prms_mbranch m
    where m.bran_cat_code = 'B'
      and m.brn_code = p_branch_code;*/
    w_expired_loan.product_nature := 'OLD';
    for idx in (SELECT m.LOC_CODE,
                       m.LOAN_CODE,
                       NAME1,
                       SANC_DATE,
                       SANC_AMT,
                       m.INT_RATE,
                       m.repay_date,
                       loan_period,
                       b.cum_prin_inst_ov + b.cum_n_int_inst_ov overdue,
                       b.cum_prin_bal + b.cum_int_bal total_bal,
                       b.LN_CRITERIA
                  from loan_mas@olddb m
                  join yr_end_bal@olddb b
                    on (m.loc_code = b.loc_code and
                       m.loan_code = b.loan_code)
                 where m.loc_code like p_branch_code
                   and b.fin_year = p_fin_year
                   and m.loan_active = 'Y') loop
    
      w_expired_loan.LOC_CODE    := idx.loc_code;
      w_expired_loan.LOAN_CODE   := idx.LOAN_CODE;
      w_expired_loan.NAME1       := idx.NAME1;
      w_expired_loan.SANC_DATE   := idx.SANC_DATE;
      w_expired_loan.SANC_AMT    := idx.SANC_AMT;
      w_expired_loan.INT_RATE    := idx.INT_RATE;
      w_expired_loan.REPAY_DATE  := idx.REPAY_DATE;
      w_expired_loan.LOAN_PERIOD := idx.LOAN_PERIOD;
      w_expired_loan.ln_criteria := idx.LN_CRITERIA;
      w_expired_loan.balance     := idx.total_bal;
      w_expired_loan.overdue     := idx.overdue;
      pipe row(w_expired_loan);
    end loop;
  
    w_expired_loan.product_nature := 'EMI';
    for idx in (SELECT m.LOC_CODE,
                       m.LOAN_CODE,
                       NAME1,
                       SANC_DATE,
                       SANC_AMT,
                       m.INT_RATE,
                       m.repay_date,
                       loan_period,
                       b.cum_prin_inst_ov + b.cum_n_int_inst_ov overdue,
                       b.cum_prin_bal + b.cum_int_bal total_bal,
                       b.LN_CRITERIA
                  from loan_mas@emidb m
                  join yr_end_bal@emidb b
                    on (m.loc_code = b.loc_code and
                       m.loan_code = b.loan_code)
                 where m.loc_code like p_branch_code
                   and b.fin_year = p_fin_year
                   and m.loan_active = 'Y') loop
    
      w_expired_loan.LOC_CODE    := idx.loc_code;
      w_expired_loan.LOAN_CODE   := idx.LOAN_CODE;
      w_expired_loan.NAME1       := idx.NAME1;
      w_expired_loan.SANC_DATE   := idx.SANC_DATE;
      w_expired_loan.SANC_AMT    := idx.SANC_AMT;
      w_expired_loan.INT_RATE    := idx.INT_RATE;
      w_expired_loan.REPAY_DATE  := idx.REPAY_DATE;
      w_expired_loan.LOAN_PERIOD := idx.LOAN_PERIOD;
      w_expired_loan.ln_criteria := idx.LN_CRITERIA;
      w_expired_loan.balance     := idx.total_bal;
      w_expired_loan.overdue     := idx.overdue;
      pipe row(w_expired_loan);
    end loop;
  
    w_expired_loan.product_nature := 'ISF';
    for idx in (SELECT m.LOC_CODE,
                       m.LOAN_CODE,
                       NAME1,
                       SANC_DATE,
                       SANC_AMT,
                       m.INT_RATE,
                       m.repay_date,
                       loan_period,
                       b.cum_prin_inst_ov + b.cum_n_int_inst_ov overdue,
                       b.cum_prin_bal + b.cum_int_bal total_bal,
                       b.LN_CRITERIA
                  from loan_mas@isfdb m
                  join yr_end_bal@isfdb b
                    on (m.loc_code = b.loc_code and
                       m.loan_code = b.loan_code)
                 where m.loc_code like p_branch_code
                   and b.fin_year = p_fin_year
                   and m.loan_active = 'Y') loop
    
      w_expired_loan.LOC_CODE    := idx.loc_code;
      w_expired_loan.LOAN_CODE   := idx.LOAN_CODE;
      w_expired_loan.NAME1       := idx.NAME1;
      w_expired_loan.SANC_DATE   := idx.SANC_DATE;
      w_expired_loan.SANC_AMT    := idx.SANC_AMT;
      w_expired_loan.INT_RATE    := idx.INT_RATE;
      w_expired_loan.REPAY_DATE  := idx.REPAY_DATE;
      w_expired_loan.LOAN_PERIOD := idx.LOAN_PERIOD;
      w_expired_loan.ln_criteria := idx.LN_CRITERIA;
      w_expired_loan.balance     := idx.total_bal;
      w_expired_loan.overdue     := idx.overdue;
      pipe row(w_expired_loan);
    end loop;
  
    w_expired_loan.product_nature := 'OCR';
    for idx in (SELECT m.LOC_CODE,
                       m.LOAN_CODE,
                       NAME1,
                       SANC_DATE,
                       SANC_AMT,
                       m.INT_RATE,
                       m.repay_date,
                       loan_period,
                       b.cum_prin_inst_ov + b.cum_n_int_inst_ov overdue,
                       b.cum_prin_bal + b.cum_int_bal total_bal,
                       b.LN_CRITERIA
                  from loan_mas@ocrdb m
                  join yr_end_bal@ocrdb b
                    on (m.loc_code = b.loc_code and
                       m.loan_code = b.loan_code)
                 where m.loc_code like p_branch_code
                   and b.fin_year = p_fin_year
                   and m.loan_active = 'Y') loop
    
      w_expired_loan.LOC_CODE    := idx.loc_code;
      w_expired_loan.LOAN_CODE   := idx.LOAN_CODE;
      w_expired_loan.NAME1       := idx.NAME1;
      w_expired_loan.SANC_DATE   := idx.SANC_DATE;
      w_expired_loan.SANC_AMT    := idx.SANC_AMT;
      w_expired_loan.INT_RATE    := idx.INT_RATE;
      w_expired_loan.REPAY_DATE  := idx.REPAY_DATE;
      w_expired_loan.LOAN_PERIOD := idx.LOAN_PERIOD;
      w_expired_loan.ln_criteria := idx.LN_CRITERIA;
      w_expired_loan.balance     := idx.total_bal;
      w_expired_loan.overdue     := idx.overdue;
      pipe row(w_expired_loan);
    end loop;
  
    w_expired_loan.product_nature := 'GOV';
    for idx in (SELECT m.LOC_CODE,
                       m.LOAN_CODE,
                       NAME1,
                       SANC_DATE,
                       SANC_AMT,
                       m.INT_RATE,
                       m.repay_date,
                       loan_period,
                       b.cum_prin_inst_ov + b.cum_n_int_inst_ov overdue,
                       b.cum_prin_bal + b.cum_int_bal total_bal,
                       b.LN_CRITERIA
                  from loan_mas@govdb m
                  join yr_end_bal@govdb b
                    on (m.loc_code = b.loc_code and
                       m.loan_code = b.loan_code)
                 where m.loc_code like p_branch_code
                   and b.fin_year = p_fin_year
                   and m.loan_active = 'Y') loop
    
      w_expired_loan.LOC_CODE    := idx.loc_code;
      w_expired_loan.LOAN_CODE   := idx.LOAN_CODE;
      w_expired_loan.NAME1       := idx.NAME1;
      w_expired_loan.SANC_DATE   := idx.SANC_DATE;
      w_expired_loan.SANC_AMT    := idx.SANC_AMT;
      w_expired_loan.INT_RATE    := idx.INT_RATE;
      w_expired_loan.REPAY_DATE  := idx.REPAY_DATE;
      w_expired_loan.LOAN_PERIOD := idx.LOAN_PERIOD;
      w_expired_loan.ln_criteria := idx.LN_CRITERIA;
      w_expired_loan.balance     := idx.total_bal;
      w_expired_loan.overdue     := idx.overdue;
      pipe row(w_expired_loan);
    end loop;
  
  end fn_activeLoan_data_previous;

  function fn_activeLoan_data(p_fin_year    in varchar2,
                              p_branch_code in varchar2)
    return v_expired_loan
    pipelined is
    w_expired_loan expired_loan;
  begin
    /* select m.brn_name
     into w_expired_loan.loc_name
     from prms_mbranch m
    where m.bran_cat_code = 'B'
      and m.brn_code = p_branch_code;*/
    w_expired_loan.product_nature := 'OLD';
    for idx in (SELECT m.LOC_CODE,
                       m.LOAN_CODE,
                       NAME1,
                       SANC_DATE,
                       SANC_AMT,
                       m.INT_RATE,
                       m.repay_date,
                       loan_period,
                       b.cum_prin_inst_ov + b.cum_n_int_inst_ov overdue,
                       b.cum_prin_bal + b.cum_int_bal total_bal,
                       b.LN_CRITERIA
                  from loan_mas@olddb m
                  join tmp_rpt_bal@olddb b
                    on (m.loc_code = b.loc_code and
                       m.loan_code = b.loan_code)
                 where m.loc_code like p_branch_code
                   and m.loan_active = 'Y') loop
    
      w_expired_loan.LOC_CODE    := idx.loc_code;
      w_expired_loan.LOAN_CODE   := idx.LOAN_CODE;
      w_expired_loan.NAME1       := idx.NAME1;
      w_expired_loan.SANC_DATE   := idx.SANC_DATE;
      w_expired_loan.SANC_AMT    := idx.SANC_AMT;
      w_expired_loan.INT_RATE    := idx.INT_RATE;
      w_expired_loan.REPAY_DATE  := idx.REPAY_DATE;
      w_expired_loan.LOAN_PERIOD := idx.LOAN_PERIOD;
      w_expired_loan.ln_criteria := idx.LN_CRITERIA;
      w_expired_loan.balance     := idx.total_bal;
      w_expired_loan.overdue     := idx.overdue;
      select sum(nvl(k.pay_amt, 0))
        into w_expired_loan.recovery
        from tmp_receipt@olddb k
       where k.ln_type_bk = substr(idx.loan_code, 1, 1)
         and k.loan_acc = substr(idx.loan_code, 2, 8)
         and k.loc_code = idx.loc_code
         and k.period like '%-21-22';
    
      pipe row(w_expired_loan);
    end loop;
  
    w_expired_loan.product_nature := 'EMI';
    for idx in (SELECT m.LOC_CODE,
                       m.LOAN_CODE,
                       NAME1,
                       SANC_DATE,
                       SANC_AMT,
                       m.INT_RATE,
                       m.repay_date,
                       loan_period,
                       b.cum_prin_inst_ov + b.cum_n_int_inst_ov overdue,
                       b.cum_prin_bal + b.cum_int_bal total_bal,
                       b.LN_CRITERIA
                  from loan_mas@emidb m
                  join tmp_rpt_bal@emidb b
                    on (m.loc_code = b.loc_code and
                       m.loan_code = b.loan_code)
                 where m.loc_code like p_branch_code
                   and m.loan_active = 'Y') loop
    
      w_expired_loan.LOC_CODE    := idx.loc_code;
      w_expired_loan.LOAN_CODE   := idx.LOAN_CODE;
      w_expired_loan.NAME1       := idx.NAME1;
      w_expired_loan.SANC_DATE   := idx.SANC_DATE;
      w_expired_loan.SANC_AMT    := idx.SANC_AMT;
      w_expired_loan.INT_RATE    := idx.INT_RATE;
      w_expired_loan.REPAY_DATE  := idx.REPAY_DATE;
      w_expired_loan.LOAN_PERIOD := idx.LOAN_PERIOD;
      w_expired_loan.ln_criteria := idx.LN_CRITERIA;
      w_expired_loan.balance     := idx.total_bal;
      w_expired_loan.overdue     := idx.overdue;
    
      select sum(nvl(k.pay_amt, 0))
        into w_expired_loan.recovery
        from tmp_receipt@emidb k
       where k.ln_type_bk = substr(idx.loan_code, 1, 1)
         and k.loan_acc = substr(idx.loan_code, 2, 8)
         and k.loc_code = idx.loc_code
         and k.period like '%-21-22';
      pipe row(w_expired_loan);
    
    end loop;
  
    w_expired_loan.product_nature := 'ISF';
    for idx in (SELECT m.LOC_CODE,
                       m.LOAN_CODE,
                       NAME1,
                       SANC_DATE,
                       SANC_AMT,
                       m.INT_RATE,
                       m.repay_date,
                       loan_period,
                       b.cum_prin_inst_ov + b.cum_n_int_inst_ov overdue,
                       b.cum_prin_bal + b.cum_int_bal total_bal,
                       b.LN_CRITERIA
                  from loan_mas@isfdb m
                  join tmp_rpt_bal@isfdb b
                    on (m.loc_code = b.loc_code and
                       m.loan_code = b.loan_code)
                 where m.loc_code like p_branch_code
                   and m.loan_active = 'Y') loop
    
      w_expired_loan.LOC_CODE    := idx.loc_code;
      w_expired_loan.LOAN_CODE   := idx.LOAN_CODE;
      w_expired_loan.NAME1       := idx.NAME1;
      w_expired_loan.SANC_DATE   := idx.SANC_DATE;
      w_expired_loan.SANC_AMT    := idx.SANC_AMT;
      w_expired_loan.INT_RATE    := idx.INT_RATE;
      w_expired_loan.REPAY_DATE  := idx.REPAY_DATE;
      w_expired_loan.LOAN_PERIOD := idx.LOAN_PERIOD;
      w_expired_loan.ln_criteria := idx.LN_CRITERIA;
      w_expired_loan.balance     := idx.total_bal;
      w_expired_loan.overdue     := idx.overdue;
    
      select sum(nvl(k.pay_amt, 0))
        into w_expired_loan.recovery
        from tmp_receipt@isfdb k
       where k.ln_type_bk = substr(idx.loan_code, 1, 1)
         and k.loan_acc = substr(idx.loan_code, 2, 8)
         and k.loc_code = idx.loc_code
         and k.period like '%-21-22';
    
      pipe row(w_expired_loan);
    end loop;
  
    w_expired_loan.product_nature := 'OCR';
    for idx in (SELECT m.LOC_CODE,
                       m.LOAN_CODE,
                       NAME1,
                       SANC_DATE,
                       SANC_AMT,
                       m.INT_RATE,
                       m.repay_date,
                       loan_period,
                       b.cum_prin_inst_ov + b.cum_n_int_inst_ov overdue,
                       b.cum_prin_bal + b.cum_int_bal total_bal,
                       b.LN_CRITERIA
                  from loan_mas@ocrdb m
                  join tmp_rpt_bal@ocrdb b
                    on (m.loc_code = b.loc_code and
                       m.loan_code = b.loan_code)
                 where m.loc_code like p_branch_code
                   and m.loan_active = 'Y') loop
    
      w_expired_loan.LOC_CODE    := idx.loc_code;
      w_expired_loan.LOAN_CODE   := idx.LOAN_CODE;
      w_expired_loan.NAME1       := idx.NAME1;
      w_expired_loan.SANC_DATE   := idx.SANC_DATE;
      w_expired_loan.SANC_AMT    := idx.SANC_AMT;
      w_expired_loan.INT_RATE    := idx.INT_RATE;
      w_expired_loan.REPAY_DATE  := idx.REPAY_DATE;
      w_expired_loan.LOAN_PERIOD := idx.LOAN_PERIOD;
      w_expired_loan.ln_criteria := idx.LN_CRITERIA;
      w_expired_loan.balance     := idx.total_bal;
      w_expired_loan.overdue     := idx.overdue;
    
      select sum(nvl(k.pay_amt, 0))
        into w_expired_loan.recovery
        from tmp_receipt@ocrdb k
       where k.ln_type_bk = substr(idx.loan_code, 1, 1)
         and k.loan_acc = substr(idx.loan_code, 2, 8)
         and k.loc_code = idx.loc_code
         and k.period like '%-21-22';
    
      pipe row(w_expired_loan);
    end loop;
  
    w_expired_loan.product_nature := 'GOV';
    for idx in (SELECT m.LOC_CODE,
                       m.LOAN_CODE,
                       NAME1,
                       SANC_DATE,
                       SANC_AMT,
                       m.INT_RATE,
                       m.repay_date,
                       loan_period,
                       b.cum_prin_inst_ov + b.cum_n_int_inst_ov overdue,
                       b.cum_prin_bal + b.cum_int_bal total_bal,
                       b.LN_CRITERIA
                  from loan_mas@govdb m
                  join tmp_rpt_bal@govdb b
                    on (m.loc_code = b.loc_code and
                       m.loan_code = b.loan_code)
                 where m.loc_code like p_branch_code
                   and m.loan_active = 'Y') loop
    
      w_expired_loan.LOC_CODE    := idx.loc_code;
      w_expired_loan.LOAN_CODE   := idx.LOAN_CODE;
      w_expired_loan.NAME1       := idx.NAME1;
      w_expired_loan.SANC_DATE   := idx.SANC_DATE;
      w_expired_loan.SANC_AMT    := idx.SANC_AMT;
      w_expired_loan.INT_RATE    := idx.INT_RATE;
      w_expired_loan.REPAY_DATE  := idx.REPAY_DATE;
      w_expired_loan.LOAN_PERIOD := idx.LOAN_PERIOD;
      w_expired_loan.ln_criteria := idx.LN_CRITERIA;
      w_expired_loan.balance     := idx.total_bal;
      w_expired_loan.overdue     := idx.overdue;
    
      select sum(nvl(k.pay_amt, 0))
        into w_expired_loan.recovery
        from tmp_receipt@govdb k
       where k.ln_type_bk = substr(idx.loan_code, 1, 1)
         and k.loan_acc = substr(idx.loan_code, 2, 8)
         and k.loc_code = idx.loc_code
         and k.period like '%-21-22';
    
      pipe row(w_expired_loan);
    end loop;
  
  end fn_activeLoan_data;

  function fn_loan_recovery_data(p_fin_year    in varchar2,
                                 p_branch_code in varchar2) return v_data
    pipelined is
    w_data rec_data;
  
  begin
    for id in (select *
                 from prms_mbranch m
                where m.bran_cat_code = 'B'
                  and m.brn_code like p_branch_code) loop
      w_data.product_nature := 'OCR';
      w_data.loc_code       := id.brn_code;
      w_data.loc_name       := id.brn_name;
      pkg_lms_report.sp_loan_recovery_data@ocrdb(p_fin_year,
                                                 id.brn_code,
                                                 w_data.cl_balance,
                                                 w_data.uc_balance,
                                                 w_data.cl_overdue,
                                                 w_data.uc_overdue,
                                                 w_data.cl_falldue,
                                                 w_data.uc_falldue,
                                                 w_data.cl_recovery,
                                                 w_data.uc_recovery,
                                                 w_data.cl_account,
                                                 w_data.uc_account);
      pipe row(w_data);
    
    end loop;
    for id in (select *
                 from prms_mbranch m
                where m.bran_cat_code = 'B'
                  and m.brn_code like p_branch_code) loop
      w_data.product_nature := 'EMI';
      w_data.loc_code       := id.brn_code;
      w_data.loc_name       := id.brn_name;
      pkg_lms_report.sp_loan_recovery_data@emidb(p_fin_year,
                                                 id.brn_code,
                                                 w_data.cl_balance,
                                                 w_data.uc_balance,
                                                 w_data.cl_overdue,
                                                 w_data.uc_overdue,
                                                 w_data.cl_falldue,
                                                 w_data.uc_falldue,
                                                 w_data.cl_recovery,
                                                 w_data.uc_recovery,
                                                 w_data.cl_account,
                                                 w_data.uc_account);
      pipe row(w_data);
    end loop;
    for id in (select *
                 from prms_mbranch m
                where m.bran_cat_code = 'B'
                  and m.brn_code like p_branch_code) loop
      w_data.product_nature := 'ISF';
      w_data.loc_code       := id.brn_code;
      w_data.loc_name       := id.brn_name;
      pkg_lms_report.sp_loan_recovery_data@isfdb(p_fin_year,
                                                 id.brn_code,
                                                 w_data.cl_balance,
                                                 w_data.uc_balance,
                                                 w_data.cl_overdue,
                                                 w_data.uc_overdue,
                                                 w_data.cl_falldue,
                                                 w_data.uc_falldue,
                                                 w_data.cl_recovery,
                                                 w_data.uc_recovery,
                                                 w_data.cl_account,
                                                 w_data.uc_account);
      pipe row(w_data);
    end loop;
    for id in (select *
                 from prms_mbranch m
                where m.bran_cat_code = 'B'
                  and m.brn_code like p_branch_code) loop
      w_data.product_nature := 'OLD';
      w_data.loc_code       := id.brn_code;
      w_data.loc_name       := id.brn_name;
      pkg_lms_report.sp_loan_recovery_data@olddb(p_fin_year,
                                                 id.brn_code,
                                                 w_data.cl_balance,
                                                 w_data.uc_balance,
                                                 w_data.cl_overdue,
                                                 w_data.uc_overdue,
                                                 w_data.cl_falldue,
                                                 w_data.uc_falldue,
                                                 w_data.cl_recovery,
                                                 w_data.uc_recovery,
                                                 w_data.cl_account,
                                                 w_data.uc_account);
      pipe row(w_data);
    
    end loop;
    for id in (select *
                 from prms_mbranch m
                where m.bran_cat_code = 'B'
                  and m.brn_code like p_branch_code) loop
      w_data.product_nature := 'GOV';
      w_data.loc_code       := id.brn_code;
      w_data.loc_name       := id.brn_name;
      pkg_lms_report.sp_loan_recovery_data@govdb(p_fin_year,
                                                 id.brn_code,
                                                 w_data.cl_balance,
                                                 w_data.uc_balance,
                                                 w_data.cl_overdue,
                                                 w_data.uc_overdue,
                                                 w_data.cl_falldue,
                                                 w_data.uc_falldue,
                                                 w_data.cl_recovery,
                                                 w_data.uc_recovery,
                                                 w_data.cl_account,
                                                 w_data.uc_account);
      pipe row(w_data);
    
    end loop;
  
  end fn_loan_recovery_data;

  function fn_loan_recovery_slab_data(p_fin_year    in varchar2,
                                      p_branch_code in varchar2)
    return v_slab_data
    pipelined is
    w_slab_data slab_data;
  
  begin
    for id in (select *
                 from prms_mbranch m
                where m.bran_cat_code = 'B'
                  and m.brn_code like p_branch_code) loop
      w_slab_data.product_nature := 'OCR';
      w_slab_data.loc_code       := id.brn_code;
      w_slab_data.loc_name       := id.brn_name;
      pkg_lms_report.sp_loan_recovery_Data_slab@ocrdb(p_fin_year,
                                                      id.brn_code,
                                                      w_slab_data.prin_balance,
                                                      w_slab_data.int_balance,
                                                      w_slab_data.prin_overdue,
                                                      w_slab_data.int_overdue,
                                                      w_slab_data.prin_falldue,
                                                      w_slab_data.int_falldue,
                                                      w_slab_data.prin_recovery,
                                                      w_slab_data.int_recovery);
      pipe row(w_slab_data);
    end loop;
  
    for id in (select *
                 from prms_mbranch m
                where m.bran_cat_code = 'B'
                  and m.brn_code like p_branch_code) loop
      w_slab_data.product_nature := 'ISF';
      w_slab_data.loc_code       := id.brn_code;
      w_slab_data.loc_name       := id.brn_name;
      pkg_lms_report.sp_loan_recovery_Data_slab@isfdb(p_fin_year,
                                                      id.brn_code,
                                                      w_slab_data.prin_balance,
                                                      w_slab_data.int_balance,
                                                      w_slab_data.prin_overdue,
                                                      w_slab_data.int_overdue,
                                                      w_slab_data.prin_falldue,
                                                      w_slab_data.int_falldue,
                                                      w_slab_data.prin_recovery,
                                                      w_slab_data.int_recovery);
      pipe row(w_slab_data);
    end loop;
  
    for id in (select *
                 from prms_mbranch m
                where m.bran_cat_code = 'B'
                  and m.brn_code like p_branch_code) loop
      w_slab_data.product_nature := 'EMI';
      w_slab_data.loc_code       := id.brn_code;
      w_slab_data.loc_name       := id.brn_name;
      pkg_lms_report.sp_loan_recovery_Data_slab@emidb(p_fin_year,
                                                      id.brn_code,
                                                      w_slab_data.prin_balance,
                                                      w_slab_data.int_balance,
                                                      w_slab_data.prin_overdue,
                                                      w_slab_data.int_overdue,
                                                      w_slab_data.prin_falldue,
                                                      w_slab_data.int_falldue,
                                                      w_slab_data.prin_recovery,
                                                      w_slab_data.int_recovery);
      pipe row(w_slab_data);
    end loop;
  
    for id in (select *
                 from prms_mbranch m
                where m.bran_cat_code = 'B'
                  and m.brn_code like p_branch_code) loop
      w_slab_data.product_nature := 'GOV';
      w_slab_data.loc_code       := id.brn_code;
      w_slab_data.loc_name       := id.brn_name;
      pkg_lms_report.sp_loan_recovery_Data_slab@govdb(p_fin_year,
                                                      id.brn_code,
                                                      w_slab_data.prin_balance,
                                                      w_slab_data.int_balance,
                                                      w_slab_data.prin_overdue,
                                                      w_slab_data.int_overdue,
                                                      w_slab_data.prin_falldue,
                                                      w_slab_data.int_falldue,
                                                      w_slab_data.prin_recovery,
                                                      w_slab_data.int_recovery);
      pipe row(w_slab_data);
    end loop;
  
    for id in (select *
               
                 from prms_mbranch m
                where m.bran_cat_code = 'B'
                  and m.brn_code like p_branch_code) loop
      w_slab_data.product_nature := 'OLD';
      w_slab_data.loc_code       := id.brn_code;
      w_slab_data.loc_name       := id.brn_name;
      pkg_lms_report.sp_loan_recovery_Data_slab@olddb(p_fin_year,
                                                      id.brn_code,
                                                      w_slab_data.prin_balance,
                                                      w_slab_data.int_balance,
                                                      w_slab_data.prin_overdue,
                                                      w_slab_data.int_overdue,
                                                      w_slab_data.prin_falldue,
                                                      w_slab_data.int_falldue,
                                                      w_slab_data.prin_recovery,
                                                      w_slab_data.int_recovery);
      pipe row(w_slab_data);
    end loop;
  
  end fn_loan_recovery_slab_data;

  function fn_Collection_beftn(p_fromDate    in date,
                               p_toDate      in date,
                               p_branch_code in varchar2) return v_Collection
    pipelined is
    w_Collection Collection;
  
  begin
    w_collection.product_nature := 'OCR';
    for idx in (select PERIOD,
                       BANK,
                       LOAN_TYPE,
                       LOAN_ACC,
                       LOAN_CAT,
                       LOC_CODE,
                       MEMO_NO,
                       PAY_DATE,
                       PAY_AMT,
                       ENTRY_USER,
                       ENTRY_DATE,
                       LOAN_PRODUCT,
                       BRANCH_CODE,
                       ACTUAL_LOC_CODE
                  from tmp_receipt@ocrdb d
                 where d.ENTRY_USER = 'BEFTN'
                   and LOC_CODE like p_branch_code
                   and PAY_DATE between p_fromDate and p_toDate) loop
    
      w_collection.PERIOD          := idx.PERIOD;
      w_collection.BANK            := idx.BANK;
      w_collection.LOAN_TYPE       := idx.LOAN_TYPE;
      w_collection.LOAN_ACC        := idx.LOAN_ACC;
      w_collection.LOAN_CAT        := idx.LOAN_CAT;
      w_collection.LOC_CODE        := idx.LOC_CODE;
      w_collection.MEMO_NO         := idx.MEMO_NO;
      w_collection.PAY_DATE        := idx.PAY_DATE;
      w_collection.PAY_AMT         := idx.PAY_AMT;
      w_collection.ENTRY_USER      := idx.ENTRY_USER;
      w_collection.LOAN_PRODUCT    := idx.LOAN_PRODUCT;
      w_collection.BRANCH_CODE     := idx.BRANCH_CODE;
      w_collection.ACTUAL_LOC_CODE := idx.ACTUAL_LOC_CODE;
      pipe row(w_Collection);
    end loop;
    w_collection.product_nature := 'ISF';
    for idx in (select PERIOD,
                       BANK,
                       LOAN_TYPE,
                       LOAN_ACC,
                       LOAN_CAT,
                       LOC_CODE,
                       MEMO_NO,
                       PAY_DATE,
                       PAY_AMT,
                       ENTRY_USER,
                       ENTRY_DATE,
                       LOAN_PRODUCT,
                       BRANCH_CODE,
                       ACTUAL_LOC_CODE
                  from tmp_receipt@isfdb d
                 where d.ENTRY_USER = 'BEFTN'
                   and LOC_CODE like p_branch_code
                   and PAY_DATE between p_fromDate and p_toDate) loop
    
      w_collection.PERIOD          := idx.PERIOD;
      w_collection.BANK            := idx.BANK;
      w_collection.LOAN_TYPE       := idx.LOAN_TYPE;
      w_collection.LOAN_ACC        := idx.LOAN_ACC;
      w_collection.LOAN_CAT        := idx.LOAN_CAT;
      w_collection.LOC_CODE        := idx.LOC_CODE;
      w_collection.MEMO_NO         := idx.MEMO_NO;
      w_collection.PAY_DATE        := idx.PAY_DATE;
      w_collection.PAY_AMT         := idx.PAY_AMT;
      w_collection.ENTRY_USER      := idx.ENTRY_USER;
      w_collection.LOAN_PRODUCT    := idx.LOAN_PRODUCT;
      w_collection.BRANCH_CODE     := idx.BRANCH_CODE;
      w_collection.ACTUAL_LOC_CODE := idx.ACTUAL_LOC_CODE;
      pipe row(w_Collection);
    end loop;
    w_collection.product_nature := 'EMI';
    for idx in (select PERIOD,
                       BANK,
                       LOAN_TYPE,
                       LOAN_ACC,
                       LOAN_CAT,
                       LOC_CODE,
                       MEMO_NO,
                       PAY_DATE,
                       PAY_AMT,
                       ENTRY_USER,
                       ENTRY_DATE,
                       LOAN_PRODUCT,
                       BRANCH_CODE,
                       ACTUAL_LOC_CODE
                  from tmp_receipt@emidb d
                 where d.ENTRY_USER = 'BEFTN'
                   and LOC_CODE like p_branch_code
                   and PAY_DATE between p_fromDate and p_toDate) loop
    
      w_collection.PERIOD          := idx.PERIOD;
      w_collection.BANK            := idx.BANK;
      w_collection.LOAN_TYPE       := idx.LOAN_TYPE;
      w_collection.LOAN_ACC        := idx.LOAN_ACC;
      w_collection.LOAN_CAT        := idx.LOAN_CAT;
      w_collection.LOC_CODE        := idx.LOC_CODE;
      w_collection.MEMO_NO         := idx.MEMO_NO;
      w_collection.PAY_DATE        := idx.PAY_DATE;
      w_collection.PAY_AMT         := idx.PAY_AMT;
      w_collection.ENTRY_USER      := idx.ENTRY_USER;
      w_collection.LOAN_PRODUCT    := idx.LOAN_PRODUCT;
      w_collection.BRANCH_CODE     := idx.BRANCH_CODE;
      w_collection.ACTUAL_LOC_CODE := idx.ACTUAL_LOC_CODE;
      pipe row(w_Collection);
    end loop;
    w_collection.product_nature := 'GOV';
    for idx in (select PERIOD,
                       BANK,
                       LOAN_TYPE,
                       LOAN_ACC,
                       LOAN_CAT,
                       LOC_CODE,
                       MEMO_NO,
                       PAY_DATE,
                       PAY_AMT,
                       ENTRY_USER,
                       ENTRY_DATE,
                       8 LOAN_PRODUCT,
                       BRANCH_CODE,
                       ACTUAL_LOC_CODE
                  from tmp_receipt@govdb d
                 where d.ENTRY_USER = 'BEFTN'
                   and LOC_CODE like p_branch_code
                   and PAY_DATE between p_fromDate and p_toDate) loop
    
      w_collection.PERIOD          := idx.PERIOD;
      w_collection.BANK            := idx.BANK;
      w_collection.LOAN_TYPE       := idx.LOAN_TYPE;
      w_collection.LOAN_ACC        := idx.LOAN_ACC;
      w_collection.LOAN_CAT        := idx.LOAN_CAT;
      w_collection.LOC_CODE        := idx.LOC_CODE;
      w_collection.MEMO_NO         := idx.MEMO_NO;
      w_collection.PAY_DATE        := idx.PAY_DATE;
      w_collection.PAY_AMT         := idx.PAY_AMT;
      w_collection.ENTRY_USER      := idx.ENTRY_USER;
      w_collection.LOAN_PRODUCT    := idx.LOAN_PRODUCT;
      w_collection.BRANCH_CODE     := idx.BRANCH_CODE;
      w_collection.ACTUAL_LOC_CODE := idx.ACTUAL_LOC_CODE;
      pipe row(w_Collection);
    end loop;
  
    w_collection.product_nature := 'OLD';
    for idx in (select PERIOD,
                       BANK,
                       LOAN_TYPE,
                       LOAN_ACC,
                       LOAN_CAT,
                       LOC_CODE,
                       MEMO_NO,
                       PAY_DATE,
                       PAY_AMT,
                       ENTRY_USER,
                       ENTRY_DATE,
                       8 LOAN_PRODUCT,
                       BRANCH_CODE,
                       ACTUAL_LOC_CODE
                  from tmp_receipt@olddb d
                 where d.ENTRY_USER = 'BEFTN'
                   and LOC_CODE like p_branch_code
                   and PAY_DATE between p_fromDate and p_toDate) loop
    
      w_collection.PERIOD          := idx.PERIOD;
      w_collection.BANK            := idx.BANK;
      w_collection.LOAN_TYPE       := idx.LOAN_TYPE;
      w_collection.LOAN_ACC        := idx.LOAN_ACC;
      w_collection.LOAN_CAT        := idx.LOAN_CAT;
      w_collection.LOC_CODE        := idx.LOC_CODE;
      w_collection.MEMO_NO         := idx.MEMO_NO;
      w_collection.PAY_DATE        := idx.PAY_DATE;
      w_collection.PAY_AMT         := idx.PAY_AMT;
      w_collection.ENTRY_USER      := idx.ENTRY_USER;
      w_collection.LOAN_PRODUCT    := idx.LOAN_PRODUCT;
      w_collection.BRANCH_CODE     := idx.BRANCH_CODE;
      w_collection.ACTUAL_LOC_CODE := idx.ACTUAL_LOC_CODE;
      pipe row(w_Collection);
    end loop;
  end fn_Collection_beftn;
  function fn_Collection(p_fin_year    in varchar2,
                         p_branch_code in varchar2,
                         p_loan_code   in varchar2) return v_Collection
    pipelined is
    w_Collection Collection;
  
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
                       ENTRY_USER,
                       ENTRY_DATE,
                       LOAN_PRODUCT,
                       BRANCH_CODE,
                       ACTUAL_LOC_CODE
                  from tmp_receipt@ocrdb d
                 where d.loan_acc = substr(p_loan_code, 2, 8)
                   and decode(ACTUAL_LOC_CODE, '', LOC_CODE, ACTUAL_LOC_CODE) =
                       p_branch_code
                   and d.period like '%-' || substr(p_fin_year, 3, 2) || '-' ||
                       substr(p_fin_year, 8, 2)) loop
    
      w_collection.PERIOD          := idx.PERIOD;
      w_collection.BANK            := idx.BANK;
      w_collection.LOAN_TYPE       := idx.LOAN_TYPE;
      w_collection.LOAN_ACC        := idx.LOAN_ACC;
      w_collection.LOAN_CAT        := idx.LOAN_CAT;
      w_collection.LOC_CODE        := idx.LOC_CODE;
      w_collection.MEMO_NO         := idx.MEMO_NO;
      w_collection.PAY_DATE        := idx.PAY_DATE;
      w_collection.PAY_AMT         := idx.PAY_AMT;
      w_collection.ENTRY_USER      := idx.ENTRY_USER;
      w_collection.LOAN_PRODUCT    := idx.LOAN_PRODUCT;
      w_collection.BRANCH_CODE     := idx.BRANCH_CODE;
      w_collection.ACTUAL_LOC_CODE := idx.ACTUAL_LOC_CODE;
      pipe row(w_Collection);
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
                       ENTRY_USER,
                       ENTRY_DATE,
                       LOAN_PRODUCT,
                       BRANCH_CODE,
                       ACTUAL_LOC_CODE
                  from tmp_receipt@isfdb d
                 where d.loan_acc = substr(p_loan_code, 2, 8)
                   and decode(ACTUAL_LOC_CODE, '', LOC_CODE, ACTUAL_LOC_CODE) =
                       p_branch_code
                   and d.period like '%-' || substr(p_fin_year, 3, 2) || '-' ||
                       substr(p_fin_year, 8, 2)) loop
    
      w_collection.PERIOD          := idx.PERIOD;
      w_collection.BANK            := idx.BANK;
      w_collection.LOAN_TYPE       := idx.LOAN_TYPE;
      w_collection.LOAN_ACC        := idx.LOAN_ACC;
      w_collection.LOAN_CAT        := idx.LOAN_CAT;
      w_collection.LOC_CODE        := idx.LOC_CODE;
      w_collection.MEMO_NO         := idx.MEMO_NO;
      w_collection.PAY_DATE        := idx.PAY_DATE;
      w_collection.PAY_AMT         := idx.PAY_AMT;
      w_collection.ENTRY_USER      := idx.ENTRY_USER;
      w_collection.LOAN_PRODUCT    := idx.LOAN_PRODUCT;
      w_collection.BRANCH_CODE     := idx.BRANCH_CODE;
      w_collection.ACTUAL_LOC_CODE := idx.ACTUAL_LOC_CODE;
      pipe row(w_Collection);
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
                       ENTRY_USER,
                       ENTRY_DATE,
                       LOAN_PRODUCT,
                       BRANCH_CODE,
                       ACTUAL_LOC_CODE
                  from tmp_receipt@emidb d
                 where d.loan_acc = substr(p_loan_code, 2, 8)
                   and decode(ACTUAL_LOC_CODE, '', LOC_CODE, ACTUAL_LOC_CODE) =
                       p_branch_code
                   and d.period like '%-' || substr(p_fin_year, 3, 2) || '-' ||
                       substr(p_fin_year, 8, 2)) loop
    
      w_collection.PERIOD          := idx.PERIOD;
      w_collection.BANK            := idx.BANK;
      w_collection.LOAN_TYPE       := idx.LOAN_TYPE;
      w_collection.LOAN_ACC        := idx.LOAN_ACC;
      w_collection.LOAN_CAT        := idx.LOAN_CAT;
      w_collection.LOC_CODE        := idx.LOC_CODE;
      w_collection.MEMO_NO         := idx.MEMO_NO;
      w_collection.PAY_DATE        := idx.PAY_DATE;
      w_collection.PAY_AMT         := idx.PAY_AMT;
      w_collection.ENTRY_USER      := idx.ENTRY_USER;
      w_collection.LOAN_PRODUCT    := idx.LOAN_PRODUCT;
      w_collection.BRANCH_CODE     := idx.BRANCH_CODE;
      w_collection.ACTUAL_LOC_CODE := idx.ACTUAL_LOC_CODE;
      pipe row(w_Collection);
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
                       ENTRY_USER,
                       ENTRY_DATE,
                       8 LOAN_PRODUCT,
                       BRANCH_CODE,
                       ACTUAL_LOC_CODE
                  from tmp_receipt@govdb d
                 where d.loan_acc = substr(p_loan_code, 2, 8)
                   and decode(ACTUAL_LOC_CODE, '', LOC_CODE, ACTUAL_LOC_CODE) =
                       p_branch_code
                   and d.period like '%-' || substr(p_fin_year, 3, 2) || '-' ||
                       substr(p_fin_year, 8, 2)) loop
    
      w_collection.PERIOD          := idx.PERIOD;
      w_collection.BANK            := idx.BANK;
      w_collection.LOAN_TYPE       := idx.LOAN_TYPE;
      w_collection.LOAN_ACC        := idx.LOAN_ACC;
      w_collection.LOAN_CAT        := idx.LOAN_CAT;
      w_collection.LOC_CODE        := idx.LOC_CODE;
      w_collection.MEMO_NO         := idx.MEMO_NO;
      w_collection.PAY_DATE        := idx.PAY_DATE;
      w_collection.PAY_AMT         := idx.PAY_AMT;
      w_collection.ENTRY_USER      := idx.ENTRY_USER;
      w_collection.LOAN_PRODUCT    := idx.LOAN_PRODUCT;
      w_collection.BRANCH_CODE     := idx.BRANCH_CODE;
      w_collection.ACTUAL_LOC_CODE := idx.ACTUAL_LOC_CODE;
      pipe row(w_Collection);
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
                       ENTRY_USER,
                       ENTRY_DATE,
                       0 LOAN_PRODUCT,
                       BRANCH_CODE,
                       ACTUAL_LOC_CODE
                  from tmp_receipt@olddb d
                 where d.loan_acc = substr(p_loan_code, 2, 8)
                   and decode(ACTUAL_LOC_CODE, '', LOC_CODE, ACTUAL_LOC_CODE) =
                       p_branch_code
                   and d.period like '%-' || substr(p_fin_year, 3, 2) || '-' ||
                       substr(p_fin_year, 8, 2)) loop
    
      w_collection.PERIOD          := idx.PERIOD;
      w_collection.BANK            := idx.BANK;
      w_collection.LOAN_TYPE       := idx.LOAN_TYPE;
      w_collection.LOAN_ACC        := idx.LOAN_ACC;
      w_collection.LOAN_CAT        := idx.LOAN_CAT;
      w_collection.LOC_CODE        := idx.LOC_CODE;
      w_collection.MEMO_NO         := idx.MEMO_NO;
      w_collection.PAY_DATE        := idx.PAY_DATE;
      w_collection.PAY_AMT         := idx.PAY_AMT;
      w_collection.ENTRY_USER      := idx.ENTRY_USER;
      w_collection.LOAN_PRODUCT    := idx.LOAN_PRODUCT;
      w_collection.BRANCH_CODE     := idx.BRANCH_CODE;
      w_collection.ACTUAL_LOC_CODE := idx.ACTUAL_LOC_CODE;
      pipe row(w_Collection);
    end loop;
  end fn_Collection;

  function fn_get_personal_ledger_stmt(p_loc_code    in varchar2,
                                       p_loan_code   in varchar2,
                                       p_fin_year    in varchar2,
                                       p_report_type in varchar2)
    return V_Ledger
    pipelined is
    w_Ledger Ledger;
  
  begin
    select LOAN_CODE,
           LOAN_RESC,
           LEGAL_ACT,
           LOC_CODE,
           SANC_DATE,
           SANC_AMT,
           PRIN_INST,
           INT_INST,
           PRIN_INST + INT_INST,
           REPAY_DATE,
           INT_RATE,
           NAME1 || NAME2 Name,
           M_ADD1 || M_ADD2 || M_ADD3 Address,
           LOAN_PERIOD,
           PRL_OR_LPR_DATE,
           GS_PERIOD_MONTH,
           GS_INT_AMT,
           GS_INT_RATE
    
      into w_Ledger.LOAN_CODE,
           w_Ledger.LOAN_RESC,
           w_Ledger.LEGAL_ACT,
           w_Ledger.LOC_CODE,
           w_Ledger.SANC_DATE,
           w_Ledger.SANC_AMT,
           w_Ledger.PRIN_INST,
           w_Ledger.INT_INST,
           w_Ledger.total_INST,
           w_Ledger.REPAY_DATE,
           w_Ledger.INT_RATE,
           w_Ledger.NAME,
           w_Ledger.ADDRESS,
           w_Ledger.LOAN_PERIOD,
           w_Ledger.PRL_OR_LPR_DATE,
           w_Ledger.gracePeriod,
           w_Ledger.int_amt_by_gov,
           w_Ledger.int_rate_by_gov
      from loan_mas@govdb b
     where b.loc_code = p_loc_code
       and b.loan_code = p_loan_code;
  
    select sum(disb_amt)
      into w_Ledger.Disburse_AMT
      from disburse@govdb k
     where k.loc_code = p_loc_code
       and k.loan_code = p_loan_code;
  
    if p_report_type = 'F' then
    
      begin
        select 0,
               'BF',
               CUM_PRIN_BAL,
               CUM_INT_BAL,
               CUM_PRIN_INST_OV * (-1),
               CUM_INT_INST_OV * (-1),
               (CUM_PRIN_INST_OV + CUM_INT_INST_OV) * (-1) Total
          into w_Ledger.Serial,
               w_Ledger.month,
               w_Ledger.ADJ_PRIN_BAL,
               w_Ledger.ADJ_INT_BAL,
               w_Ledger.PRIN_INST_OV,
               w_Ledger.INT_INST_OV,
               w_Ledger.TOTAL
          from yr_end_bal@govdb b
         where b.loan_code = p_loan_code
           and b.fin_year = SUBSTR(p_fin_year, 1, 4) - 1 || '-' ||
               SUBSTR(p_fin_year, 1, 4)
           and loc_code = p_loc_code;
      
      exception
        when others then
          w_Ledger.Serial       := 0;
          w_Ledger.month        := 'BF';
          w_Ledger.ADJ_PRIN_BAL := 0;
          w_Ledger.ADJ_INT_BAL  := 0;
          w_Ledger.PRIN_INST_OV := 0;
          w_Ledger.INT_INST_OV  := 0;
          w_Ledger.TOTAL        := 0;
        
      end;
    
      select CUR_PRIN_REAL,
             CUR_INT_REAL,
             CUR_LUMP_REAL,
             CUR_PEN_REAL,
             CUR_INT_CHARGE,
             CUR_PEN_CHARGED,
             CUR_IDCP_AMT,
             CUM_PRIN_INST_NO_OV * (-1),
             CUM_PRIN_INST_OV * (-1),
             CUM_INT_INST_NO_OV * (-1),
             CUM_INT_INST_OV * (-1),
             CUM_LUMP_INST * (-1),
             CUR_PRIN_DR,
             CUR_PRIN_CR,
             CUR_INT_DR,
             CUR_INT_CR,
             CUM_PRIN_BAL,
             CUM_INT_BAL,
             LN_CRITERIA
      
        into w_Ledger.CUR_PRIN_REAL,
             w_Ledger.CUR_INT_REAL,
             w_Ledger.CUR_LUMP_REAL,
             w_Ledger.CUR_PEN_REAL,
             w_Ledger.CUR_INT_CHARGE,
             w_Ledger.CUR_PEN_CHARGED,
             w_Ledger.CUR_IDCP_AMT,
             w_Ledger.CUM_PRIN_INST_NO_OV,
             w_Ledger.CUM_PRIN_INST_OV,
             w_Ledger.CUM_INT_INST_NO_OV,
             w_Ledger.CUM_INT_INST_OV,
             w_Ledger.CUM_LUMP_INST,
             w_Ledger.CUR_PRIN_DR,
             w_Ledger.CUR_PRIN_CR,
             w_Ledger.CUR_INT_DR,
             w_Ledger.CUR_INT_CR,
             w_Ledger.CUM_PRIN_BAL,
             w_Ledger.CUM_INT_BAL,
             w_Ledger.LN_CRITERIA
        from yr_end_bal@govdb b
       where b.loan_code = p_loan_code
         and b.fin_year = p_fin_year
         and loc_code = p_loc_code;
      pipe row(w_Ledger);
    
      for idx in (SELECT TRANS_ID,
                         r.BK_CODE,
                         r.PUR_CODE TRANS_TYPE,
                         r.REF_NO,
                         r.TRANS_DATE,
                         r.REAL_AMT, --r.,
                         SUBSTR(r.PERIOD, 1, 3) MONTH,
                         r.PRIN_REAL,
                         r.PRIN_DRCR,
                         r.ADJ_PRIN_BAL,
                         r.INT_CHARGED,
                         r.PEN_INT_AMT,
                         r.INT_DRCR,
                         r.INT_REAL,
                         r.ADJ_INT_BAL,
                         r.PRIN_INST_OV * -1 AS Prin_Inst_ov,
                         r.INT_INST_OV * -1 AS INT_INST_OV,
                         (NVL(r.PRIN_INST_OV, 0) + NVL(r.INT_INST_OV, 0)) * (-1) AS total,
                         y.PREV_CUM_PRIN_BAL,
                         y.PREV_CUM_PEN_INT_AMT,
                         y.PREV_CUM_INT_BAL,
                         y.PREV_CUM_PRIN_INST_OV * -1 AS prev_Prin_Inst_ov,
                         y.PREV_CUM_INT_INST_OV * -1 AS prev_INT_INST_OV,
                         (NVL(y.PREV_CUM_PRIN_INST_OV, 0) +
                         NVL(y.PREV_CUM_INT_INST_OV, 0)) * (-1) AS prev_total,
                         R.GOVT_POR_REAL_AMT,
                         R.CLIENT_POR_INT_REAL_AMT
                  
                    FROM TRANSACTION@GOVDB r, YR_END_BAL@GOVDB y
                   WHERE r.loan_code = y.LOAN_CODE
                     AND r.loc_code = y.Loc_code
                     AND y.FIN_YEAR = p_fin_year
                     AND r.FIN_YEAR = p_fin_year
                     AND r.loc_code = p_loc_code
                     AND r.loan_code = p_loan_code
                   ORDER BY r.TRANS_ID, r.TRANS_DATE) loop
        w_Ledger.Serial               := idx.trans_id;
        w_Ledger.BK_CODE              := idx.BK_CODE;
        w_Ledger.TRANS_TYPE           := idx.TRANS_TYPE;
        w_Ledger.REF_NO               := idx.REF_NO;
        w_Ledger.TRANS_DATE           := idx.TRANS_DATE;
        w_Ledger.REAL_AMT             := idx.REAL_AMT;
        w_Ledger.MONTH                := idx.MONTH;
        w_Ledger.PRIN_REAL            := idx.PRIN_REAL;
        w_Ledger.PRIN_DRCR            := idx.PRIN_DRCR;
        w_Ledger.ADJ_PRIN_BAL         := idx.ADJ_PRIN_BAL;
        w_Ledger.INT_CHARGED          := idx.INT_CHARGED;
        w_Ledger.PEN_INT_AMT          := idx.PEN_INT_AMT;
        w_Ledger.INT_DRCR             := idx.INT_DRCR;
        w_Ledger.INT_REAL             := idx.INT_REAL;
        w_Ledger.ADJ_INT_BAL          := idx.ADJ_INT_BAL;
        w_Ledger.PRIN_INST_OV         := idx.PRIN_INST_OV;
        w_Ledger.INT_INST_OV          := idx.INT_INST_OV;
        w_Ledger.TOTAL                := idx.TOTAL;
        w_Ledger.PREV_CUM_PRIN_BAL    := idx.PREV_CUM_PRIN_BAL;
        w_Ledger.PREV_CUM_PEN_INT_AMT := idx.PREV_CUM_PEN_INT_AMT;
        w_Ledger.PREV_CUM_INT_BAL     := idx.PREV_CUM_INT_BAL;
        w_Ledger.PREV_PRIN_INST_OV    := idx.PREV_PRIN_INST_OV;
        w_Ledger.PREV_INT_INST_OV     := idx.PREV_INT_INST_OV;
        w_Ledger.PREV_TOTAL           := idx.PREV_TOTAL;
        w_Ledger.GOV_POREAL_AMT       := idx.GOVT_POR_REAL_AMT;
        w_Ledger.CLIENT_POREAL_AMT    := idx.CLIENT_POR_INT_REAL_AMT;
        pipe row(w_Ledger);
      
      end loop;
    else
      begin
        select 0,
               'BF',
               CUM_PRIN_BAL,
               CUM_INT_BAL,
               CUM_PRIN_INST_OV * (-1),
               CUM_INT_INST_OV * (-1),
               (CUM_PRIN_INST_OV + CUM_INT_INST_OV) * (-1) Total
          into w_Ledger.Serial,
               w_Ledger.month,
               w_Ledger.ADJ_PRIN_BAL,
               w_Ledger.ADJ_INT_BAL,
               w_Ledger.PRIN_INST_OV,
               w_Ledger.INT_INST_OV,
               w_Ledger.TOTAL
          from yr_end_bal@govdb b
         where b.loan_code = p_loan_code
           and b.fin_year = SUBSTR(p_fin_year, 1, 4) - 1 || '-' ||
               SUBSTR(p_fin_year, 1, 4)
           and loc_code = p_loc_code;
      
      exception
        when others then
          w_Ledger.Serial       := 0;
          w_Ledger.month        := 'BF';
          w_Ledger.ADJ_PRIN_BAL := 0;
          w_Ledger.ADJ_INT_BAL  := 0;
          w_Ledger.PRIN_INST_OV := 0;
          w_Ledger.INT_INST_OV  := 0;
          w_Ledger.TOTAL        := 0;
        
      end;
      select LN_CRITERIA
        into w_Ledger.LN_CRITERIA
        from tmp_rpt_bal@govdb b
       where b.loan_code = p_loan_code
         and b.fin_year = p_fin_year
         and loc_code = p_loc_code;
    
      select CUR_PRIN_REAL,
             CUR_INT_REAL,
             CUR_LUMP_REAL,
             CUR_PEN_REAL,
             CUR_INT_CHARGE,
             CUR_PEN_CHARGED,
             CUR_IDCP_AMT,
             CUM_PRIN_INST_NO_OV * (-1),
             CUM_PRIN_INST_OV * (-1),
             CUM_INT_INST_NO_OV * (-1),
             CUM_INT_INST_OV * (-1),
             CUM_LUMP_INST * (-1),
             CUR_PRIN_DR,
             CUR_PRIN_CR,
             CUR_INT_DR,
             CUR_INT_CR,
             CUM_PRIN_BAL,
             CUM_INT_BAL
        into w_Ledger.CUR_PRIN_REAL,
             w_Ledger.CUR_INT_REAL,
             w_Ledger.CUR_LUMP_REAL,
             w_Ledger.CUR_PEN_REAL,
             w_Ledger.CUR_INT_CHARGE,
             w_Ledger.CUR_PEN_CHARGED,
             w_Ledger.CUR_IDCP_AMT,
             w_Ledger.CUM_PRIN_INST_NO_OV,
             w_Ledger.CUM_PRIN_INST_OV,
             w_Ledger.CUM_INT_INST_NO_OV,
             w_Ledger.CUM_INT_INST_OV,
             w_Ledger.CUM_LUMP_INST,
             w_Ledger.CUR_PRIN_DR,
             w_Ledger.CUR_PRIN_CR,
             w_Ledger.CUR_INT_DR,
             w_Ledger.CUR_INT_CR,
             w_Ledger.CUM_PRIN_BAL,
             w_Ledger.CUM_INT_BAL
      
        from tmp_rpt_bal@govdb b
       where b.loan_code = p_loan_code
         and b.fin_year = p_fin_year
         and loc_code = p_loc_code;
    
      pipe row(w_Ledger);
    
      for idx in (SELECT TRANS_ID,
                         r.BK_CODE,
                         r.PUR_CODE TRANS_TYPE,
                         r.REF_NO,
                         r.TRANS_DATE,
                         r.REAL_AMT, --r.,
                         SUBSTR(r.PERIOD, 1, 3) MONTH,
                         r.PRIN_REAL,
                         r.PRIN_DRCR,
                         r.ADJ_PRIN_BAL,
                         r.INT_CHARGED,
                         r.PEN_INT_AMT,
                         r.INT_DRCR,
                         r.INT_REAL,
                         r.ADJ_INT_BAL,
                         r.PRIN_INST_OV * -1 AS Prin_Inst_ov,
                         r.INT_INST_OV * -1 AS INT_INST_OV,
                         (NVL(r.PRIN_INST_OV, 0) + NVL(r.INT_INST_OV, 0)) * (-1) AS total,
                         y.PREV_CUM_PRIN_BAL,
                         y.PREV_CUM_PEN_INT_AMT,
                         y.PREV_CUM_INT_BAL,
                         y.PREV_CUM_PRIN_INST_OV * -1 AS prev_Prin_Inst_ov,
                         y.PREV_CUM_INT_INST_OV * -1 AS prev_INT_INST_OV,
                         (NVL(y.PREV_CUM_PRIN_INST_OV, 0) +
                         NVL(y.PREV_CUM_INT_INST_OV, 0)) * (-1) AS prev_total,
                         nvl(R.GOVT_POR_REAL_AMT, 0) GOVT_POR_REAL_AMT,
                         nvl(R.CLIENT_POR_INT_REAL_AMT, 0) CLIENT_POR_INT_REAL_AMT
                  
                    FROM rpt_to_date@GOVDB r, tmp_rpt_bal@GOVDB y
                   WHERE r.loan_code = y.LOAN_CODE
                     AND r.loc_code = y.Loc_code
                     AND y.FIN_YEAR = p_fin_year
                     AND r.FIN_YEAR = p_fin_year
                     AND r.loc_code = p_loc_code
                     AND r.loan_code = p_loan_code
                   ORDER BY r.TRANS_ID, r.TRANS_DATE) loop
        w_Ledger.Serial               := idx.trans_id;
        w_Ledger.BK_CODE              := idx.BK_CODE;
        w_Ledger.TRANS_TYPE           := idx.TRANS_TYPE;
        w_Ledger.REF_NO               := idx.REF_NO;
        w_Ledger.TRANS_DATE           := idx.TRANS_DATE;
        w_Ledger.REAL_AMT             := idx.REAL_AMT;
        w_Ledger.MONTH                := idx.MONTH;
        w_Ledger.PRIN_REAL            := idx.PRIN_REAL;
        w_Ledger.PRIN_DRCR            := idx.PRIN_DRCR;
        w_Ledger.ADJ_PRIN_BAL         := idx.ADJ_PRIN_BAL;
        w_Ledger.INT_CHARGED          := idx.INT_CHARGED;
        w_Ledger.PEN_INT_AMT          := idx.PEN_INT_AMT;
        w_Ledger.INT_DRCR             := idx.INT_DRCR;
        w_Ledger.INT_REAL             := idx.INT_REAL;
        w_Ledger.ADJ_INT_BAL          := idx.ADJ_INT_BAL;
        w_Ledger.PRIN_INST_OV         := idx.PRIN_INST_OV;
        w_Ledger.INT_INST_OV          := idx.INT_INST_OV;
        w_Ledger.TOTAL                := idx.TOTAL;
        w_Ledger.PREV_CUM_PRIN_BAL    := idx.PREV_CUM_PRIN_BAL;
        w_Ledger.PREV_CUM_PEN_INT_AMT := idx.PREV_CUM_PEN_INT_AMT;
        w_Ledger.PREV_CUM_INT_BAL     := idx.PREV_CUM_INT_BAL;
        w_Ledger.PREV_PRIN_INST_OV    := idx.PREV_PRIN_INST_OV;
        w_Ledger.PREV_INT_INST_OV     := idx.PREV_INT_INST_OV;
        w_Ledger.PREV_TOTAL           := idx.PREV_TOTAL;
        w_Ledger.GOV_POREAL_AMT       := idx.GOVT_POR_REAL_AMT;
        w_Ledger.CLIENT_POREAL_AMT    := idx.CLIENT_POR_INT_REAL_AMT;
        pipe row(w_Ledger);
      
      end loop;
    end if;
  end fn_get_personal_ledger_stmt;

  function fn_get_loan_ledger(p_branch_code in varchar2,
                              p_loan_type   in varchar2,
                              p_fin_year    in varchar2,
                              p_report_type in varchar2) return V_LoanLedger
    pipelined is
    w_LoanLedger LoanLedger;
    V_TRANSL     NUMBER := 1;
  begin
    ----------------------BF Correction ---------------------------
    w_LoanLedger.particuars      := 'B.F.';
    w_LoanLedger.particular_code := 1;
    for idx in (SELECT sum(PRINCIPAL_CR) PRINCIPAL_CR,
                       sum(PRINCIPAL_DR) PRINCIPAL_DR,
                       sum(NORMAL_CR) NORMAL_CR,
                       sum(NORMAL_DR) NORMAL_DR,
                       sum(LUMP_CR) LUMP_CR,
                       sum(LUMP_DR) LUMP_DR,
                       sum(IDIP_CR) IDIP_CR,
                       sum(IDIP_DR) IDIP_DR
                  FROM (select case SIGN(yr.cum_prin_bal)
                                 when -1 then
                                  yr.cum_prin_bal
                                 else
                                  0
                               end principal_cr,
                               case SIGN(yr.cum_prin_bal)
                                 when 1 then
                                  yr.cum_prin_bal
                                 else
                                  0
                               end principal_dr,
                               
                               case SIGN(yr.cum_N_int_amt)
                                 when -1 then
                                  yr.cum_N_int_amt
                                 else
                                  0
                               end Normal_cr,
                               
                               case SIGN(yr.cum_N_int_amt)
                                 when 1 then
                                  yr.cum_N_int_amt
                                 else
                                  0
                               end Normal_dr,
                               
                               case SIGN(yr.cum_LUMP_inst)
                                 when -1 then
                                  yr.cum_LUMP_inst
                                 else
                                  0
                               end lump_cr,
                               
                               case SIGN(yr.cum_LUMP_inst)
                                 when 1 then
                                  yr.cum_LUMP_inst
                                 else
                                  0
                               end lump_dr,
                               case SIGN(yr.Cum_Pen_Int_amt)
                                 when -1 then
                                  yr.Cum_Pen_Int_amt
                                 else
                                  0
                               end IDIP_cr,
                               
                               case SIGN(yr.Cum_Pen_Int_amt)
                                 when 1 then
                                  yr.Cum_Pen_Int_amt
                                 else
                                  0
                               end IDIP_dr
                        
                          from yr_end_bal@govdb yr, loan_mas@govdb
                         WHERE loan_mas.loc_code = p_branch_code
                           and loan_mas.loc_code = yr.loc_code
                           and loan_mas.loan_type = p_loan_type
                           and loan_mas.loan_code = yr.loan_code
                           and loan_mas.loan_active = 'Y'
                           and yr.fin_year = SUBSTR(p_fin_year, 1, 4) - 1 || '-' ||
                               SUBSTR(p_fin_year, 1, 4))) loop
    
      w_LoanLedger.Serial        := V_TRANSL;
      w_LoanLedger.code          := 'PRINCIPAL';
      w_LoanLedger.Principal_dr  := IDX.PRINCIPAL_DR;
      w_LoanLedger.Principal_cr  := IDX.PRINCIPAL_CR;
      w_LoanLedger.Principal_Bal := IDX.PRINCIPAL_DR + IDX.PRINCIPAL_CR;
      w_LoanLedger.Interest_dr   := 0;
      w_LoanLedger.Interest_cr   := 0;
      w_LoanLedger.Interest_Bal  := 0;
      w_LoanLedger.Total_bal     := IDX.PRINCIPAL_DR + IDX.PRINCIPAL_CR;
      pipe row(w_LoanLedger);
    
      V_TRANSL                   := V_TRANSL + 1;
      w_LoanLedger.Serial        := V_TRANSL;
      w_LoanLedger.code          := 'NORMAL';
      w_LoanLedger.Principal_dr  := 0;
      w_LoanLedger.Principal_cr  := 0;
      w_LoanLedger.Principal_Bal := 0;
      w_LoanLedger.Interest_dr   := idx.normal_dr;
      w_LoanLedger.Interest_cr   := idx.normal_cr;
      w_LoanLedger.Interest_Bal  := idx.normal_dr + idx.normal_cr;
      w_LoanLedger.Total_bal     := idx.normal_dr + idx.normal_cr;
      pipe row(w_LoanLedger);
    
      V_TRANSL                   := V_TRANSL + 1;
      w_LoanLedger.Serial        := V_TRANSL;
      w_LoanLedger.code          := 'LUMP';
      w_LoanLedger.Principal_dr  := 0;
      w_LoanLedger.Principal_cr  := 0;
      w_LoanLedger.Principal_Bal := 0;
      w_LoanLedger.Interest_dr   := idx.lump_dr;
      w_LoanLedger.Interest_cr   := idx.lump_cr;
      w_LoanLedger.Interest_Bal  := idx.lump_dr + idx.lump_cr;
      w_LoanLedger.Total_bal     := idx.lump_dr + idx.lump_cr;
      pipe row(w_LoanLedger);
    
      V_TRANSL                   := V_TRANSL + 1;
      w_LoanLedger.Serial        := V_TRANSL;
      w_LoanLedger.code          := 'IDIP';
      w_LoanLedger.Principal_dr  := 0;
      w_LoanLedger.Principal_cr  := 0;
      w_LoanLedger.Principal_Bal := 0;
      w_LoanLedger.Interest_dr   := idx.idip_dr;
      w_LoanLedger.Interest_cr   := idx.idip_cr;
      w_LoanLedger.Interest_Bal  := idx.idip_dr + idx.idip_cr;
      w_LoanLedger.Total_bal     := idx.idip_dr + idx.idip_cr;
      pipe row(w_LoanLedger);
    end loop;
    ------------------------------Disburse---------------------------------------
  
    if p_report_type = 'F' then
    
      w_LoanLedger.particuars      := 'DISBURSE';
      w_LoanLedger.particular_code := 2;
      SELECT sum(r.prin_dr), sum(r.prin_dr), sum(r.prin_dr)
        into w_LoanLedger.Principal_dr,
             w_LoanLedger.Principal_Bal,
             w_LoanLedger.Total_bal
        FROM transaction@govdb r, loan_mas@govdb
       WHERE loan_mas.loc_code = p_branch_code
         and loan_mas.loc_code = r.loc_code
         and loan_mas.loan_type = p_loan_type
         and loan_mas.loan_code = r.loan_code
         and loan_mas.loan_active = 'Y'
         and r.fin_year = p_fin_year
         and r.trans_type = 'D';
    
      V_TRANSL                  := V_TRANSL + 1;
      w_LoanLedger.Serial       := V_TRANSL;
      w_LoanLedger.code         := 'DISBURSE';
      w_LoanLedger.Principal_cr := 0;
      w_LoanLedger.Interest_dr  := 0;
      w_LoanLedger.Interest_cr  := 0;
      w_LoanLedger.Interest_Bal := 0;
      pipe row(w_LoanLedger);
    
      w_LoanLedger.particuars      := 'VOUCHER';
      w_LoanLedger.particular_code := 3;
      for id1 in (SELECT r.trans_type,
                         pur_code,
                         decode(trans_type, 'V', sum(nvl(r.prin_dr, 0)), 0) as prin_dr,
                         sum(nvl(r.prin_cr, 0)) as prin_cr,
                         (sum(nvl(r.prin_dr, 0)) - sum(nvl(r.prin_cr, 0))) as prin_bal,
                         sum(nvl(r.int_dr, 0)) as int_dr,
                         sum(nvl(r.int_cr, 0)) as int_cr,
                         (sum(nvl(r.int_dr, 0)) - sum(nvl(r.int_cr, 0))) as int_bal
                  
                    FROM transaction@govdb r, loan_mas@govdb
                   WHERE loan_mas.loc_code = p_branch_code
                     and loan_mas.loc_code = r.loc_code
                     and loan_mas.loan_type = p_loan_type
                     and loan_mas.loan_code = r.loan_code
                     and loan_mas.loan_active = 'Y'
                     and r.fin_year = p_fin_year
                     and r.trans_type = 'V'
                   group by r.trans_type, r.pur_code
                   order by trans_type desc) loop
      
        V_TRANSL                   := V_TRANSL + 1;
        w_LoanLedger.Serial        := V_TRANSL;
        w_LoanLedger.code          := id1.pur_code;
        w_LoanLedger.Principal_dr  := id1.prin_dr;
        w_LoanLedger.Principal_cr  := id1.prin_cr;
        w_LoanLedger.Principal_Bal := id1.prin_bal;
        w_LoanLedger.Interest_dr   := id1.int_dr;
        w_LoanLedger.Interest_cr   := id1.int_cr;
        w_LoanLedger.Interest_Bal  := id1.int_bal;
        w_LoanLedger.Total_bal     := id1.prin_bal + id1.int_bal;
        pipe row(w_LoanLedger);
      
      end loop;
    
      w_LoanLedger.particuars      := 'MEMO';
      w_LoanLedger.particular_code := 4;
      for idx in (SELECT sum(nvl(r.prin_real, 0)) as memo_pricipal,
                         sum(nvl(r.int_real, 0)) as memo_NI,
                         sum(nvl(r.lump_real, 0)) as memo_LI,
                         sum(nvl(r.pen_real, 0)) as memo_PI,
                         sum(nvl(r.govt_por_real_amt, 0)) govt_por_real_amt,
                         sum(nvl(r.client_por_int_real_amt, 0)) client_por_int_real_amt
                    FROM transaction@govdb r, loan_mas@govdb
                   WHERE loan_mas.loc_code = p_branch_code
                     and loan_mas.loc_code = r.loc_code
                     and loan_mas.loan_type = p_loan_type
                     and loan_mas.loan_code = r.loan_code
                     and loan_mas.loan_active = 'Y'
                     and r.fin_year = p_fin_year
                     and r.trans_type = 'M') loop
      
        V_TRANSL                   := V_TRANSL + 1;
        w_LoanLedger.Serial        := V_TRANSL;
        w_LoanLedger.code          := 'PRINCIPAL';
        w_LoanLedger.Principal_dr  := 0;
        w_LoanLedger.Principal_cr  := idx.memo_pricipal;
        w_LoanLedger.Principal_Bal := -1 * idx.memo_pricipal;
      
        w_LoanLedger.Interest_dr  := 0;
        w_LoanLedger.Interest_cr  := 0;
        w_LoanLedger.Interest_Bal := 0;
        w_LoanLedger.Total_bal    := -1 * idx.memo_pricipal;
        pipe row(w_LoanLedger);
      
       
        V_TRANSL                   := V_TRANSL + 1;
        w_LoanLedger.Serial        := V_TRANSL;
        w_LoanLedger.code          := 'NI';
        w_LoanLedger.Principal_dr  := 0;
        w_LoanLedger.Principal_cr  := 0;
        w_LoanLedger.Principal_Bal := 0;
        w_LoanLedger.Interest_dr   := 0;
        w_LoanLedger.Interest_cr   := idx.client_por_int_real_amt;
        w_LoanLedger.Interest_Bal  := -1 * idx.client_por_int_real_amt;
        w_LoanLedger.Total_bal     := -1 * idx.client_por_int_real_amt;
        pipe row(w_LoanLedger);
        
        
        V_TRANSL                   := V_TRANSL + 1;
        w_LoanLedger.Serial        := V_TRANSL;
        w_LoanLedger.code          := 'LI';
        w_LoanLedger.Principal_dr  := 0;
        w_LoanLedger.Principal_cr  := 0;
        w_LoanLedger.Principal_Bal := 0;
        w_LoanLedger.Interest_dr   := 0;
        w_LoanLedger.Interest_cr   := idx.memo_li;
        w_LoanLedger.Interest_Bal  := -1 * idx.memo_li;
        w_LoanLedger.Total_bal     := -1 * idx.memo_li;
        pipe row(w_LoanLedger);
      
       
      
      
        V_TRANSL                   := V_TRANSL + 1;
        w_LoanLedger.Serial        := V_TRANSL;
        w_LoanLedger.code          := 'GS';
        w_LoanLedger.Principal_dr  := 0;
        w_LoanLedger.Principal_cr  := 0;
        w_LoanLedger.Principal_Bal := 0;
        w_LoanLedger.Interest_dr   := 0;
        w_LoanLedger.Interest_cr   := idx.govt_por_real_amt;
        w_LoanLedger.Interest_Bal  := -1 * idx.govt_por_real_amt;
        w_LoanLedger.Total_bal     := -1 * idx.govt_por_real_amt;
      
        pipe row(w_LoanLedger);
      
      end loop;
      w_LoanLedger.particuars      := 'INTEREST CHARGED';
      w_LoanLedger.particular_code := 5;
      for idx in (select sum(yr_end_bal.cur_int_charge) as int_charg_normal,
                         sum(yr_end_bal.cur_idcp_amt) as int_charg_idcp,
                         sum(yr_end_bal.cur_pen_charged) as int_charg_pi
                    from yr_end_bal@govdb, loan_mas@govdb
                   where yr_end_bal.loc_code = p_branch_code
                     and yr_end_bal.loc_code = loan_mas.loc_code
                     and substr(yr_end_bal.loan_code, 1, 1) = p_loan_type
                     and yr_end_bal.loan_code = loan_mas.loan_code
                     and yr_end_bal.fin_year = p_fin_year) loop
      
        V_TRANSL                   := V_TRANSL + 1;
        w_LoanLedger.Serial        := V_TRANSL;
        w_LoanLedger.code          := 'NORMAL';
        w_LoanLedger.Principal_dr  := 0;
        w_LoanLedger.Principal_cr  := 0;
        w_LoanLedger.Principal_Bal := 0;
        w_LoanLedger.Interest_dr   := idx.int_charg_normal;
        w_LoanLedger.Interest_cr   := 0;
        w_LoanLedger.Interest_Bal  := idx.int_charg_normal;
        w_LoanLedger.Total_bal     := idx.int_charg_normal;
        pipe row(w_LoanLedger);
      
        V_TRANSL                   := V_TRANSL + 1;
        w_LoanLedger.Serial        := V_TRANSL;
        w_LoanLedger.code          := 'IDCP';
        w_LoanLedger.Principal_dr  := 0;
        w_LoanLedger.Principal_cr  := 0;
        w_LoanLedger.Principal_Bal := 0;
        w_LoanLedger.Interest_dr   := idx.int_charg_idcp;
        w_LoanLedger.Interest_cr   := 0;
        w_LoanLedger.Interest_Bal  := idx.int_charg_idcp;
        w_LoanLedger.Total_bal     := idx.int_charg_idcp;
        pipe row(w_LoanLedger);
      
        V_TRANSL                   := V_TRANSL + 1;
        w_LoanLedger.Serial        := V_TRANSL;
        w_LoanLedger.code          := 'PI';
        w_LoanLedger.Principal_dr  := 0;
        w_LoanLedger.Principal_cr  := 0;
        w_LoanLedger.Principal_Bal := 0;
        w_LoanLedger.Interest_dr   := idx.int_charg_pi;
        w_LoanLedger.Interest_cr   := 0;
        w_LoanLedger.Interest_Bal  := idx.int_charg_pi;
        w_LoanLedger.Total_bal     := idx.int_charg_pi;
        pipe row(w_LoanLedger);
      
      end loop;
    else
    
      w_LoanLedger.particuars      := 'DISBURSE';
      w_LoanLedger.particular_code := 2;
      SELECT sum(r.prin_dr), sum(r.prin_dr), sum(r.prin_dr)
        into w_LoanLedger.Principal_dr,
             w_LoanLedger.Principal_Bal,
             w_LoanLedger.Total_bal
        FROM rpt_to_date@govdb r, loan_mas@govdb
       WHERE loan_mas.loc_code = p_branch_code
         and loan_mas.loc_code = r.loc_code
         and loan_mas.loan_type = p_loan_type
         and loan_mas.loan_code = r.loan_code
         and loan_mas.loan_active = 'Y'
         and r.fin_year = p_fin_year
         and r.trans_type = 'D';
    
      V_TRANSL                  := V_TRANSL + 1;
      w_LoanLedger.Serial       := V_TRANSL;
      w_LoanLedger.code         := 'DISBURSE';
      w_LoanLedger.Principal_cr := 0;
      w_LoanLedger.Interest_dr  := 0;
      w_LoanLedger.Interest_cr  := 0;
      w_LoanLedger.Interest_Bal := 0;
      pipe row(w_LoanLedger);
    
      w_LoanLedger.particuars      := 'VOUCHER';
      w_LoanLedger.particular_code := 3;
      for id1 in (SELECT r.trans_type,
                         pur_code,
                         decode(trans_type, 'V', sum(nvl(r.prin_dr, 0)), 0) as prin_dr,
                         sum(nvl(r.prin_cr, 0)) as prin_cr,
                         (sum(nvl(r.prin_dr, 0)) - sum(nvl(r.prin_cr, 0))) as prin_bal,
                         sum(nvl(r.int_dr, 0)) as int_dr,
                         sum(nvl(r.int_cr, 0)) as int_cr,
                         (sum(nvl(r.int_dr, 0)) - sum(nvl(r.int_cr, 0))) as int_bal
                  
                    FROM rpt_to_date@govdb r, loan_mas@govdb
                   WHERE loan_mas.loc_code = p_branch_code
                     and loan_mas.loc_code = r.loc_code
                     and loan_mas.loan_type = p_loan_type
                     and loan_mas.loan_code = r.loan_code
                     and loan_mas.loan_active = 'Y'
                     and r.fin_year = p_fin_year
                     and r.trans_type = 'V'
                   group by r.trans_type, r.pur_code
                   order by trans_type desc) loop
      
        V_TRANSL                   := V_TRANSL + 1;
        w_LoanLedger.Serial        := V_TRANSL;
        w_LoanLedger.code          := id1.pur_code;
        w_LoanLedger.Principal_dr  := id1.prin_dr;
        w_LoanLedger.Principal_cr  := id1.prin_cr;
        w_LoanLedger.Principal_Bal := id1.prin_bal;
        w_LoanLedger.Interest_dr   := id1.int_dr;
        w_LoanLedger.Interest_cr   := id1.int_cr;
        w_LoanLedger.Interest_Bal  := id1.int_bal;
        w_LoanLedger.Total_bal     := id1.prin_bal + id1.int_bal;
        pipe row(w_LoanLedger);
      
      end loop;
    
      w_LoanLedger.particuars      := 'MEMO';
      w_LoanLedger.particular_code := 4;
      for idx in (SELECT sum(nvl(r.prin_real, 0)) as memo_pricipal,
                         sum(nvl(r.int_real, 0)) as memo_NI,
                         sum(nvl(r.lump_real, 0)) as memo_LI,
                         sum(nvl(r.pen_real, 0)) as memo_PI,
                         sum(nvl(r.govt_por_real_amt, 0)) govt_por_real_amt,
                         sum(nvl(r.client_por_int_real_amt, 0)) client_por_int_real_amt
                    FROM rpt_to_date@govdb r, loan_mas@govdb
                   WHERE loan_mas.loc_code = p_branch_code
                     and loan_mas.loc_code = r.loc_code
                     and loan_mas.loan_type = p_loan_type
                     and loan_mas.loan_code = r.loan_code
                     and loan_mas.loan_active = 'Y'
                     and r.fin_year = p_fin_year
                     and r.trans_type = 'M') loop
      
        V_TRANSL                   := V_TRANSL + 1;
        w_LoanLedger.Serial        := V_TRANSL;
        w_LoanLedger.code          := 'PRINCIPAL';
        w_LoanLedger.Principal_dr  := 0;
        w_LoanLedger.Principal_cr  := idx.memo_pricipal;
        w_LoanLedger.Principal_Bal := -1 * idx.memo_pricipal;
      
        w_LoanLedger.Interest_dr  := 0;
        w_LoanLedger.Interest_cr  := 0;
        w_LoanLedger.Interest_Bal := 0;
        w_LoanLedger.Total_bal    := -1 * idx.memo_pricipal;
        pipe row(w_LoanLedger);
      
        V_TRANSL                   := V_TRANSL + 1;
        w_LoanLedger.Serial        := V_TRANSL;
        w_LoanLedger.code          := 'NI';
        w_LoanLedger.Principal_dr  := 0;
        w_LoanLedger.Principal_cr  := 0;
        w_LoanLedger.Principal_Bal := 0;
        w_LoanLedger.Interest_dr   := 0;
        w_LoanLedger.Interest_cr   := idx.client_por_int_real_amt;
        w_LoanLedger.Interest_Bal  := -1 * idx.client_por_int_real_amt;
        w_LoanLedger.Total_bal     := -1 * idx.client_por_int_real_amt;
        pipe row(w_LoanLedger);
      
      
        V_TRANSL                   := V_TRANSL + 1;
        w_LoanLedger.Serial        := V_TRANSL;
        w_LoanLedger.code          := 'LI';
        w_LoanLedger.Principal_dr  := 0;
        w_LoanLedger.Principal_cr  := 0;
        w_LoanLedger.Principal_Bal := 0;
        w_LoanLedger.Interest_dr   := 0;
        w_LoanLedger.Interest_cr   := idx.memo_li;
        w_LoanLedger.Interest_Bal  := -1 * idx.memo_li;
        w_LoanLedger.Total_bal     := -1 * idx.memo_li;
        pipe row(w_LoanLedger);
      
      
        V_TRANSL                   := V_TRANSL + 1;
        w_LoanLedger.Serial        := V_TRANSL;
        w_LoanLedger.code          := 'PI';
        w_LoanLedger.Principal_dr  := 0;
        w_LoanLedger.Principal_cr  := 0;
        w_LoanLedger.Principal_Bal := 0;
        w_LoanLedger.Interest_dr   := 0;
        w_LoanLedger.Interest_cr   := idx.memo_pi;
        w_LoanLedger.Interest_Bal  := -1 * idx.memo_pi;
        w_LoanLedger.Total_bal     := -1 * idx.memo_pi;
        pipe row(w_LoanLedger);
      
        V_TRANSL                   := V_TRANSL + 1;
        w_LoanLedger.Serial        := V_TRANSL;
        w_LoanLedger.code          := 'GS';
        w_LoanLedger.Principal_dr  := 0;
        w_LoanLedger.Principal_cr  := 0;
        w_LoanLedger.Principal_Bal := 0;
        w_LoanLedger.Interest_dr   := 0;
        w_LoanLedger.Interest_cr   := idx.govt_por_real_amt;
        w_LoanLedger.Interest_Bal  := -1 * idx.govt_por_real_amt;
        w_LoanLedger.Total_bal     := -1 * idx.govt_por_real_amt;
      
        pipe row(w_LoanLedger);
      
      end loop;
      w_LoanLedger.particuars      := 'INTEREST CHARGED';
      w_LoanLedger.particular_code := 5;
      for idx in (select sum(yr_end_bal.cur_int_charge) as int_charg_normal,
                         sum(yr_end_bal.cur_idcp_amt) as int_charg_idcp,
                         sum(yr_end_bal.cur_pen_charged) as int_charg_pi
                    from tmp_rpt_bal@govdb yr_end_bal, loan_mas@govdb
                   where yr_end_bal.loc_code = p_branch_code
                     and yr_end_bal.loc_code = loan_mas.loc_code
                     and substr(yr_end_bal.loan_code, 1, 1) = p_loan_type
                     and yr_end_bal.loan_code = loan_mas.loan_code
                     and yr_end_bal.fin_year = p_fin_year) loop
      
        V_TRANSL                   := V_TRANSL + 1;
        w_LoanLedger.Serial        := V_TRANSL;
        w_LoanLedger.code          := 'NORMAL';
        w_LoanLedger.Principal_dr  := 0;
        w_LoanLedger.Principal_cr  := 0;
        w_LoanLedger.Principal_Bal := 0;
        w_LoanLedger.Interest_dr   := idx.int_charg_normal;
        w_LoanLedger.Interest_cr   := 0;
        w_LoanLedger.Interest_Bal  := idx.int_charg_normal;
        w_LoanLedger.Total_bal     := idx.int_charg_normal;
        pipe row(w_LoanLedger);
      
        V_TRANSL                   := V_TRANSL + 1;
        w_LoanLedger.Serial        := V_TRANSL;
        w_LoanLedger.code          := 'IDCP';
        w_LoanLedger.Principal_dr  := 0;
        w_LoanLedger.Principal_cr  := 0;
        w_LoanLedger.Principal_Bal := 0;
        w_LoanLedger.Interest_dr   := idx.int_charg_idcp;
        w_LoanLedger.Interest_cr   := 0;
        w_LoanLedger.Interest_Bal  := idx.int_charg_idcp;
        w_LoanLedger.Total_bal     := idx.int_charg_idcp;
        pipe row(w_LoanLedger);
      
        V_TRANSL                   := V_TRANSL + 1;
        w_LoanLedger.Serial        := V_TRANSL;
        w_LoanLedger.code          := 'PI';
        w_LoanLedger.Principal_dr  := 0;
        w_LoanLedger.Principal_cr  := 0;
        w_LoanLedger.Principal_Bal := 0;
        w_LoanLedger.Interest_dr   := idx.int_charg_pi;
        w_LoanLedger.Interest_cr   := 0;
        w_LoanLedger.Interest_Bal  := idx.int_charg_pi;
        w_LoanLedger.Total_bal     := idx.int_charg_pi;
        pipe row(w_LoanLedger);
      end loop;
    end if;
  end fn_get_loan_ledger;

begin
  null;
end pkg_Report_LMS;
/
