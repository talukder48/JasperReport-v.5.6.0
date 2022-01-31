CREATE OR REPLACE PACKAGE PKG_RPT IS

  TYPE DED_DATA IS RECORD(
    BRANCH_CODE    VARCHAR2(5),
    EMP_ID         PRMS_EMP_SAL.EMP_ID%TYPE,
    EMP_NAME       PRMS_EMPLOYEE.EMP_NAME%TYPE,
    DESIGNATION    PRMS_EMP_SAL.DESIG%TYPE,
    MONTH          PRMS_TRANSACTION.SAL_MONTH%TYPE,
    TIN_NO         PRMS_EMPLOYEE.TIN_NO%TYPE,
    DESIG_CODE     NUMBER(4),
    MONTH_YEAR     VARCHAR(10),
    MONTH_CODE     NUMBER(2),
    DEDUCTION_TYPE VARCHAR2(3),
    DEDUCTION_AMT  NUMBER(11, 2),
    COMPUTER_AMT   NUMBER(11, 2));
  TYPE V_DATA IS TABLE OF DED_DATA;
  FUNCTION FN_DED_DATA(P_ENTITY_NUMBER  IN NUMBER,
                       P_BRANCH_CODE    IN VARCHAR2,
                       P_YEAR           IN NUMBER,
                       P_MONTH_CODE     IN NUMBER,
                       P_DEDUCTION_TYPE IN VARCHAR2) RETURN V_DATA
    PIPELINED;

  type recovery is record(
    branch_code varchar2(5),
    branch_name location.loc_desc %type,
    No_of_AccCL number,
    No_of_AccUC number);
  type v_recovery is table of recovery;
  function fn_recovery(fin_year in varchar2) return v_data
    pipelined;

  type deduction is record(
    emp_branch_code    varchar2(10),
    emp_branch_name    varchar2(50),
    month_year         varchar2(10),
    emp_id             varchar2(10),
    emp_name           varchar2(50),
    emp_DESIG_CODE     NUMBER(4),
    emp_designation    varchar2(30),
    emp_deductionType  varchar2(5),
    emp_deductionAmt   number(12, 2),
    emp_Advance_DedAmt number(12, 2));
  type v_deduction is table of deduction;
  function fn_deduction(p_entity_num     in number,
                        p_year           in number,
                        p_month_code     in number,
                        p_deduction_type in varchar2) return v_deduction
    pipelined;

  type deduction_all is record(
    emp_branch_code     varchar2(10),
    emp_branch_name     varchar2(50),
    month_year          varchar2(10),
    emp_id              varchar2(10),
    emp_name            varchar2(50),
    emp_DESIG_CODE      NUMBER(4),
    emp_designation     varchar2(30),
    Pf_contribution_Amt number(12, 2),
    Pf_Advance_Amt      number(12, 2),
    Pension_amount      number(12, 2),
    WelFare             number(12, 2),
    hb_deduction        number(12, 2),
    motor_deduction     number(12, 2),
    computer_deduction  number(12, 2),
    Group_ins_Amount    number(12, 2),
    Gas_deduction_amt   number(12, 2),
    Water_deduction_amt number(12, 2),
    Elect_deduction_amt number(12, 2),
    News_paperDed_amt   number(12, 2));
  type v_deduction_all is table of deduction_all;

  function fn_deduction_all(p_entity_num in number,
                            p_year       in number,
                            p_month_code in number) return v_deduction_all
    pipelined;

  TYPE DATA IS RECORD(
    FIN_YEAR         VARCHAR2(10),
    DISBURSE_AMT     NUMBER(13, 2),
    DESIGNATION      VARCHAR2(40),
    INTEREST_RATE    NUMBER(5, 2),
    EMPLOYEE_ID      VARCHAR2(20),
    EMP_NAME         VARCHAR2(50),
    YEAR             NUMBER(4),
    MONTH_CODE       NUMBER(2),
    MONTH_NAME       VARCHAR2(15),
    REAL_TYPE        VARCHAR2(5),
    VOUCHER_TYPE     VARCHAR2(5),
    PF_ADV_DR_AMT    NUMBER(13, 2),
    PF_ADV_CR_AMT    NUMBER(13, 2),
    PF_VOU_DR_AMT    NUMBER(13, 2),
    PF_VOU_CR_AMT    NUMBER(13, 2),
    PF_COMTRIBUTION  NUMBER(13, 2),
    PF_ADV_REAL_AMT  NUMBER(13, 2),
    PF_INT_AMT       NUMBER(13, 2),
    PF_BALANCE       NUMBER(13, 2),
    PF_ADV1_AMT      NUMBER(13, 2),
    PF_ADV2_AMT      NUMBER(13, 2),
    PF_ADV3_AMT      NUMBER(13, 2),
    PF_ADV_AMT_TOTAL NUMBER(13, 2),
    ins_ADV1_AMT     NUMBER(13, 2),
    ins_ADV2_AMT     NUMBER(13, 2),
    ins_ADV3_AMT     NUMBER(13, 2));
  TYPE XV_DATA IS TABLE OF DATA;
  FUNCTION FN_PF_DATA(P_ENTITY      IN NUMBER,
                      P_BRANCH_CODE IN VARCHAR2,
                      P_EMP_ID      IN VARCHAR2,
                      P_FIN_YEAR    IN VARCHAR2) RETURN XV_DATA
    PIPELINED;

  type search_data is record(
    Office_code     varchar2(10),
    office_name     varchar2(30),
    loan_acc        varchar2(10),
    sanc_amt        number(12, 2),
    Borrower_name   varchar2(200),
    Fathers_name    varchar2(100),
    Site_address    varchar2(200),
    Mailing_address varchar2(200),
    NID             varchar2(40),
    TIN             varchar2(40));
  type v_search_data is table of search_data;

  function fn_data_searching(p1            in varchar2,
                             p2            in varchar2,
                             p3            in varchar2,
                             p4            in varchar2,
                             p5            in varchar2,
                             p6            in varchar2,
                             p7            in varchar2,
                             p8            in varchar2,
                             p9            in varchar2,
                             p10           in varchar2,
                             p_type        in varchar2,
                             p_report_type in varchar2) return v_search_data
    pipelined;

  type IncomeTaxData is record(
    empid           varchar2(10),
    emp_name        varchar2(50),
    emp_desig_code  number(4),
    emp_designation varchar2(50),
    month1_amt      number(12, 2),
    month2_amt      number(12, 2),
    month3_amt      number(12, 2));
  type v_IncomeTaxData is table of IncomeTaxData;
  function fn_QRT_Tax_Data(p_entity_num in number,
                           p_Branch     in varchar2,
                           p_year       in number,
                           p_month1     in number,
                           p_month2     in number,
                           p_month3     in number) return v_IncomeTaxData
    pipelined;

  type AdvanceIncomeTax is record(
    emp_id                varchar2(10),
    header1              varchar2(5000),
    footer1              varchar2(5000),
    total_amount_in_taka varchar2(400),
    BRANCH_CODE          varchar2(10),
    FIN_YEAR             varchar2(12),
    PAY_ORDER_NO         varchar2(20),
    PAY_ORDER_DATE       date,
    NAME_OF_BANK         varchar2(150),
    PAY_ORDER_AMOUNT     number(18, 2),
    REFERENCE_NUMBER     varchar2(100),
    REFERENCE_DATE       date
    
    );
  type v_AdvanceIncomeTax is table of AdvanceIncomeTax;
  function fn_get_advance_payment(p_branch_code in varchar2,
                                  p_fin_year    in varchar2)
    return v_AdvanceIncomeTax
    pipelined;
END PKG_RPT;
/
CREATE OR REPLACE PACKAGE BODY PKG_RPT IS
  function fn_recovery(fin_year in varchar2) return v_data
    pipelined is
  begin
    null;
  end fn_recovery;
  function fn_deduction_all(p_entity_num in number,
                            p_year       in number,
                            p_month_code in number) return v_deduction_all
    pipelined is
    w_deduction deduction_all;
  begin
    for idx in (select *
                  from prms_transaction t
                 where t.entity_number = p_entity_num
                   and t.sal_year = p_year
                   and t.month_code = p_month_code
                -- and t.branch_code like '%9999%'
                ) loop
      w_deduction.emp_id              := idx.emp_id;
      w_deduction.emp_branch_code     := idx.branch_code;
      w_deduction.month_year          := trim(idx.sal_month);
      w_deduction.Pension_amount      := idx.pension_allowance;
      w_deduction.Pf_contribution_Amt := idx.pf_deduction;
      w_deduction.WelFare             := idx.welfare_deduc;
      w_deduction.hb_deduction        := idx.hbadv_deduc +
                                         idx.hbadv_arrear_deduc;
      w_deduction.Pf_Advance_Amt      := idx.pfadv_deduc +
                                         idx.pfadv_arrear_deduc;
      w_deduction.motor_deduction     := idx.mcycle_deduc;
      w_deduction.computer_deduction  := idx.comp_deduc;
      w_deduction.Group_ins_Amount    := idx.gen_insurence;
      w_deduction.Gas_deduction_amt   := idx.gas_bill;
      w_deduction.Water_deduction_amt := idx.water_bill;
      w_deduction.Elect_deduction_amt := idx.electricity_bill;
      w_deduction.News_paperDed_amt   := idx.news_paper_deduc;
      begin
        select m.brn_name
          into w_deduction.emp_branch_name
          from prms_mbranch m
         where m.brn_code = idx.branch_code;
        select d.designation_desc, d.designation_code
          into w_deduction.emp_designation, w_deduction.emp_DESIG_CODE
          from prms_designation d
         where d.designation_code =
               (select h.desig_code
                  from prms_emp_sal h
                 where h.emp_id = idx.emp_id);
        select e.emp_name
          into w_deduction.emp_name
          from prms_employee e
         where e.emp_id = idx.emp_id;
      exception
        when others then
          null;
      end;
    
      pipe row(w_deduction);
    end loop;
  end fn_deduction_all;

  function fn_deduction(p_entity_num     in number,
                        p_year           in number,
                        p_month_code     in number,
                        p_deduction_type in varchar2) return v_deduction
    pipelined is
    w_deduction deduction;
  begin
    for idx in (select *
                  from prms_transaction t
                 where t.entity_number = p_entity_num
                   and t.sal_year = p_year
                   and t.month_code = p_month_code) loop
      w_deduction.emp_id            := idx.emp_id;
      w_deduction.emp_branch_code   := idx.branch_code;
      w_deduction.month_year        := idx.sal_month;
      w_deduction.emp_deductionType := p_deduction_type;
    
      select m.brn_name
        into w_deduction.emp_branch_name
        from prms_mbranch m
       where m.brn_code = idx.branch_code;
    
      select d.designation_desc, d.designation_code
        into w_deduction.emp_designation, w_deduction.emp_DESIG_CODE
        from prms_designation d
       where d.designation_code =
             (select h.desig_code
                from prms_emp_sal h
               where h.emp_id = idx.emp_id);
      select e.emp_name
        into w_deduction.emp_name
        from prms_employee e
       where e.emp_id = idx.emp_id;
    
      if p_deduction_type = 'PFC' and nvl(idx.pf_deduction, 0) > 0 then
        w_deduction.emp_deductionAmt   := nvl(idx.pf_deduction, 0);
        w_deduction.emp_Advance_DedAmt := nvl(idx.pfadv_deduc +
                                              idx.pfadv_arrear_deduc,
                                              0);
        pipe row(w_deduction);
      end if;
      if p_deduction_type = 'PEN' and nvl(idx.pension_allowance, 0) > 0 then
        w_deduction.emp_deductionAmt := nvl(idx.pension_allowance, 0);
        pipe row(w_deduction);
      end if;
      if p_deduction_type = 'WEL' and nvl(idx.welfare_deduc, 0) > 0 then
        w_deduction.emp_deductionAmt := nvl(idx.welfare_deduc, 0);
        pipe row(w_deduction);
      end if;
    
      if p_deduction_type = 'HBL' and nvl(idx.hbadv_deduc, 0) > 0 then
        w_deduction.emp_deductionAmt := nvl(idx.hbadv_deduc, 0);
        pipe row(w_deduction);
      end if;
    
      if p_deduction_type = 'MOT' and nvl(idx.mcycle_deduc, 0) > 0 then
        w_deduction.emp_deductionAmt := nvl(idx.mcycle_deduc, 0);
        pipe row(w_deduction);
      end if;
    
      if p_deduction_type = 'COM' and nvl(idx.comp_deduc, 0) > 0 then
        w_deduction.emp_deductionAmt := nvl(idx.comp_deduc, 0);
        pipe row(w_deduction);
      end if;
    
      if p_deduction_type = 'GAS' and nvl(idx.gas_bill, 0) > 0 then
        w_deduction.emp_deductionAmt := nvl(idx.gas_bill, 0);
        pipe row(w_deduction);
      end if;
      if p_deduction_type = 'WAT' and nvl(idx.water_bill, 0) > 0 then
        w_deduction.emp_deductionAmt := nvl(idx.water_bill, 0);
        pipe row(w_deduction);
      end if;
    
      if p_deduction_type = 'ELE' and nvl(idx.electricity_bill, 0) > 0 then
        w_deduction.emp_deductionAmt := nvl(idx.electricity_bill, 0);
        pipe row(w_deduction);
      end if;
    
    end loop;
  end fn_deduction;

  FUNCTION FN_DED_DATA(P_ENTITY_NUMBER  IN NUMBER,
                       P_BRANCH_CODE    IN VARCHAR2,
                       P_YEAR           IN NUMBER,
                       P_MONTH_CODE     IN NUMBER,
                       P_DEDUCTION_TYPE IN VARCHAR2) RETURN V_DATA
    PIPELINED IS
    V_DED_DATA DED_DATA;
  
  BEGIN
    IF P_DEDUCTION_TYPE = 'PFC' THEN
      FOR ID IN (SELECT *
                   FROM PRMS_TRANSACTION
                  WHERE ENTITY_NUMBER = P_ENTITY_NUMBER
                    AND BRANCH_CODE = P_BRANCH_CODE
                    AND SAL_YEAR = P_YEAR
                    AND MONTH_CODE = P_MONTH_CODE
                    AND PF_DEDUCTION > 0) LOOP
        SELECT D.DESIGNATION_DESC, D.DESIGNATION_CODE
          INTO V_DED_DATA.DESIGNATION, V_DED_DATA.DESIG_CODE
          FROM PRMS_DESIGNATION D
         WHERE D.DESIGNATION_CODE =
               (SELECT H.DESIG_CODE
                  FROM PRMS_EMP_SAL H
                 WHERE H.EMP_ID = ID.EMP_ID);
        select e.emp_name
          into V_DED_DATA.EMP_NAME
          from prms_employee e
         where e.emp_id = id.emp_id;
      
        V_DED_DATA.MONTH          := ID.SAL_MONTH;
        V_DED_DATA.BRANCH_CODE    := ID.BRANCH_CODE;
        V_DED_DATA.EMP_ID         := ID.EMP_ID;
        V_DED_DATA.MONTH_YEAR     := ID.SAL_YEAR;
        V_DED_DATA.DEDUCTION_TYPE := P_DEDUCTION_TYPE;
        V_DED_DATA.DEDUCTION_AMT  := ID.PF_DEDUCTION;
        PIPE ROW(V_DED_DATA);
      END LOOP;
    ELSIF P_DEDUCTION_TYPE = 'PFA' THEN
      FOR ID IN (SELECT *
                   FROM PRMS_TRANSACTION
                  WHERE ENTITY_NUMBER = P_ENTITY_NUMBER
                    AND BRANCH_CODE = P_BRANCH_CODE
                    AND SAL_YEAR = P_YEAR
                    AND MONTH_CODE = P_MONTH_CODE
                    AND PFADV_DEDUC > 0) LOOP
      
        SELECT D.DESIGNATION_DESC, D.DESIGNATION_CODE
          INTO V_DED_DATA.DESIGNATION, V_DED_DATA.DESIG_CODE
          FROM PRMS_DESIGNATION D
         WHERE D.DESIGNATION_CODE =
               (SELECT H.DESIG_CODE
                  FROM PRMS_EMP_SAL H
                 WHERE H.EMP_ID = ID.EMP_ID);
      
        select e.emp_name
          into V_DED_DATA.EMP_NAME
          from prms_employee e
         where e.emp_id = id.emp_id;
        V_DED_DATA.MONTH          := ID.SAL_MONTH;
        V_DED_DATA.BRANCH_CODE    := ID.BRANCH_CODE;
        V_DED_DATA.EMP_ID         := ID.EMP_ID;
        V_DED_DATA.MONTH_YEAR     := ID.SAL_YEAR;
        V_DED_DATA.DEDUCTION_TYPE := P_DEDUCTION_TYPE;
        V_DED_DATA.DEDUCTION_AMT  := ID.PFADV_DEDUC;
      
        PIPE ROW(V_DED_DATA);
      END LOOP;
    ELSIF P_DEDUCTION_TYPE = 'HBL' THEN
      FOR ID IN (SELECT *
                   FROM PRMS_TRANSACTION
                  WHERE ENTITY_NUMBER = P_ENTITY_NUMBER
                    AND BRANCH_CODE = P_BRANCH_CODE
                    AND SAL_YEAR = P_YEAR
                    AND MONTH_CODE = P_MONTH_CODE
                    AND HBADV_DEDUC > 0) LOOP
      
        SELECT D.DESIGNATION_DESC, D.DESIGNATION_CODE
          INTO V_DED_DATA.DESIGNATION, V_DED_DATA.DESIG_CODE
          FROM PRMS_DESIGNATION D
         WHERE D.DESIGNATION_CODE =
               (SELECT H.DESIG_CODE
                  FROM PRMS_EMP_SAL H
                 WHERE H.EMP_ID = ID.EMP_ID);
        select e.emp_name
          into V_DED_DATA.EMP_NAME
          from prms_employee e
         where e.emp_id = id.emp_id;
        V_DED_DATA.MONTH          := ID.SAL_MONTH;
        V_DED_DATA.BRANCH_CODE    := ID.BRANCH_CODE;
        V_DED_DATA.EMP_ID         := ID.EMP_ID;
        V_DED_DATA.MONTH_YEAR     := ID.SAL_YEAR;
        V_DED_DATA.MONTH_CODE     := ID.MONTH_CODE;
        V_DED_DATA.DEDUCTION_TYPE := P_DEDUCTION_TYPE;
        V_DED_DATA.DEDUCTION_AMT  := ID.HBADV_DEDUC;
        PIPE ROW(V_DED_DATA);
      END LOOP;
    ELSIF P_DEDUCTION_TYPE = 'MOT' THEN
      FOR ID IN (SELECT *
                   FROM PRMS_TRANSACTION
                  WHERE ENTITY_NUMBER = P_ENTITY_NUMBER
                    AND BRANCH_CODE = P_BRANCH_CODE
                    AND SAL_YEAR = P_YEAR
                    AND MONTH_CODE = P_MONTH_CODE
                    AND MCYCLE_DEDUC > 0) LOOP
      
        SELECT D.DESIGNATION_DESC, D.DESIGNATION_CODE
          INTO V_DED_DATA.DESIGNATION, V_DED_DATA.DESIG_CODE
          FROM PRMS_DESIGNATION D
         WHERE D.DESIGNATION_CODE =
               (SELECT H.DESIG_CODE
                  FROM PRMS_EMP_SAL H
                 WHERE H.EMP_ID = ID.EMP_ID);
        select e.emp_name
          into V_DED_DATA.EMP_NAME
          from prms_employee e
         where e.emp_id = id.emp_id;
        V_DED_DATA.MONTH          := ID.SAL_MONTH;
        V_DED_DATA.BRANCH_CODE    := ID.BRANCH_CODE;
        V_DED_DATA.EMP_ID         := ID.EMP_ID;
        V_DED_DATA.MONTH_YEAR     := ID.SAL_YEAR;
        V_DED_DATA.MONTH_CODE     := ID.MONTH_CODE;
        V_DED_DATA.DEDUCTION_TYPE := P_DEDUCTION_TYPE;
        V_DED_DATA.DEDUCTION_AMT  := ID.MCYCLE_DEDUC;
        PIPE ROW(V_DED_DATA);
      END LOOP;
    ELSIF P_DEDUCTION_TYPE = 'COM' THEN
      FOR ID IN (SELECT *
                   FROM PRMS_TRANSACTION
                  WHERE ENTITY_NUMBER = P_ENTITY_NUMBER
                    AND BRANCH_CODE = P_BRANCH_CODE
                    AND SAL_YEAR = P_YEAR
                    AND MONTH_CODE = P_MONTH_CODE
                    AND COMP_DEDUC > 0) LOOP
      
        SELECT D.DESIGNATION_DESC, D.DESIGNATION_CODE
          INTO V_DED_DATA.DESIGNATION, V_DED_DATA.DESIG_CODE
          FROM PRMS_DESIGNATION D
         WHERE D.DESIGNATION_CODE =
               (SELECT H.DESIG_CODE
                  FROM PRMS_EMP_SAL H
                 WHERE H.EMP_ID = ID.EMP_ID);
        select e.emp_name
          into V_DED_DATA.EMP_NAME
          from prms_employee e
         where e.emp_id = id.emp_id;
        V_DED_DATA.MONTH          := ID.SAL_MONTH;
        V_DED_DATA.BRANCH_CODE    := ID.BRANCH_CODE;
        V_DED_DATA.EMP_ID         := ID.EMP_ID;
        V_DED_DATA.MONTH_YEAR     := ID.SAL_YEAR;
        V_DED_DATA.MONTH_CODE     := ID.MONTH_CODE;
        V_DED_DATA.DEDUCTION_TYPE := P_DEDUCTION_TYPE;
        V_DED_DATA.DEDUCTION_AMT  := ID.COMP_DEDUC;
        PIPE ROW(V_DED_DATA);
      END LOOP;
    ELSIF P_DEDUCTION_TYPE = 'INC' THEN
      FOR ID IN (SELECT *
                   FROM PRMS_TRANSACTION t
                  WHERE ENTITY_NUMBER = P_ENTITY_NUMBER
                    AND BRANCH_CODE = P_BRANCH_CODE
                    AND SAL_YEAR = P_YEAR
                    AND MONTH_CODE = P_MONTH_CODE
                    AND t.income_tax > 0) LOOP
      
        SELECT D.DESIGNATION_DESC, D.DESIGNATION_CODE
          INTO V_DED_DATA.DESIGNATION, V_DED_DATA.DESIG_CODE
          FROM PRMS_DESIGNATION D
         WHERE D.DESIGNATION_CODE =
               (SELECT H.DESIG_CODE
                  FROM PRMS_EMP_SAL H
                 WHERE H.EMP_ID = ID.EMP_ID);
        select e.emp_name, e.tin_no
          into V_DED_DATA.EMP_NAME, V_DED_DATA.TIN_NO
          from prms_employee e
         where e.emp_id = id.emp_id;
        V_DED_DATA.MONTH          := ID.SAL_MONTH;
        V_DED_DATA.BRANCH_CODE    := ID.BRANCH_CODE;
        V_DED_DATA.EMP_ID         := ID.EMP_ID;
        V_DED_DATA.MONTH_YEAR     := ID.SAL_YEAR;
        V_DED_DATA.MONTH_CODE     := ID.MONTH_CODE;
        V_DED_DATA.DEDUCTION_TYPE := P_DEDUCTION_TYPE;
        V_DED_DATA.DEDUCTION_AMT  := ID.income_tax;
        PIPE ROW(V_DED_DATA);
      END LOOP;
    ELSIF P_DEDUCTION_TYPE = 'WEL' THEN
      FOR ID IN (SELECT *
                   FROM PRMS_TRANSACTION t
                  WHERE ENTITY_NUMBER = P_ENTITY_NUMBER
                    AND BRANCH_CODE = P_BRANCH_CODE
                    AND SAL_YEAR = P_YEAR
                    AND MONTH_CODE = P_MONTH_CODE
                    AND t.Welfare_Deduc > 0) LOOP
      
        SELECT D.DESIGNATION_DESC, D.DESIGNATION_CODE
          INTO V_DED_DATA.DESIGNATION, V_DED_DATA.DESIG_CODE
          FROM PRMS_DESIGNATION D
         WHERE D.DESIGNATION_CODE =
               (SELECT H.DESIG_CODE
                  FROM PRMS_EMP_SAL H
                 WHERE H.EMP_ID = ID.EMP_ID);
        select e.emp_name
          into V_DED_DATA.EMP_NAME
          from prms_employee e
         where e.emp_id = id.emp_id;
        V_DED_DATA.MONTH          := ID.SAL_MONTH;
        V_DED_DATA.BRANCH_CODE    := ID.BRANCH_CODE;
        V_DED_DATA.EMP_ID         := ID.EMP_ID;
        V_DED_DATA.MONTH_YEAR     := ID.SAL_YEAR;
        V_DED_DATA.MONTH_CODE     := ID.MONTH_CODE;
        V_DED_DATA.DEDUCTION_TYPE := P_DEDUCTION_TYPE;
        V_DED_DATA.DEDUCTION_AMT  := ID.Welfare_Deduc;
        V_DED_DATA.ComPuter_AMT   := nvl(id.news_paper_deduc, 0);
        PIPE ROW(V_DED_DATA);
      END LOOP;
    
    ELSIF P_DEDUCTION_TYPE = 'GEN' THEN
      FOR ID IN (SELECT *
                   FROM PRMS_TRANSACTION t
                  WHERE ENTITY_NUMBER = P_ENTITY_NUMBER
                    AND BRANCH_CODE = P_BRANCH_CODE
                    AND SAL_YEAR = P_YEAR
                    AND MONTH_CODE = P_MONTH_CODE
                    AND t.gen_insurence > 0) LOOP
      
        SELECT D.DESIGNATION_DESC, D.DESIGNATION_CODE
          INTO V_DED_DATA.DESIGNATION, V_DED_DATA.DESIG_CODE
          FROM PRMS_DESIGNATION D
         WHERE D.DESIGNATION_CODE =
               (SELECT H.DESIG_CODE
                  FROM PRMS_EMP_SAL H
                 WHERE H.EMP_ID = ID.EMP_ID);
        select e.emp_name
          into V_DED_DATA.EMP_NAME
          from prms_employee e
         where e.emp_id = id.emp_id;
        V_DED_DATA.MONTH          := ID.SAL_MONTH;
        V_DED_DATA.BRANCH_CODE    := ID.BRANCH_CODE;
        V_DED_DATA.EMP_ID         := ID.EMP_ID;
        V_DED_DATA.MONTH_YEAR     := ID.SAL_YEAR;
        V_DED_DATA.MONTH_CODE     := ID.MONTH_CODE;
        V_DED_DATA.DEDUCTION_TYPE := P_DEDUCTION_TYPE;
        V_DED_DATA.DEDUCTION_AMT  := ID.gen_insurence;
        PIPE ROW(V_DED_DATA);
      END LOOP;
    ELSIF P_DEDUCTION_TYPE = 'PEN' THEN
      FOR ID IN (SELECT *
                   FROM PRMS_TRANSACTION t
                  WHERE ENTITY_NUMBER = P_ENTITY_NUMBER
                    AND BRANCH_CODE = P_BRANCH_CODE
                    AND SAL_YEAR = P_YEAR
                    AND MONTH_CODE = P_MONTH_CODE
                    AND t.pension_deduc > 0) LOOP
      
        SELECT D.DESIGNATION_DESC, D.DESIGNATION_CODE
          INTO V_DED_DATA.DESIGNATION, V_DED_DATA.DESIG_CODE
          FROM PRMS_DESIGNATION D
         WHERE D.DESIGNATION_CODE =
               (SELECT H.DESIG_CODE
                  FROM PRMS_EMP_SAL H
                 WHERE H.EMP_ID = ID.EMP_ID);
        select e.emp_name
          into V_DED_DATA.EMP_NAME
          from prms_employee e
         where e.emp_id = id.emp_id;
        V_DED_DATA.MONTH          := ID.SAL_MONTH;
        V_DED_DATA.BRANCH_CODE    := ID.BRANCH_CODE;
        V_DED_DATA.EMP_ID         := ID.EMP_ID;
        V_DED_DATA.MONTH_YEAR     := ID.SAL_YEAR;
        V_DED_DATA.MONTH_CODE     := ID.MONTH_CODE;
        V_DED_DATA.DEDUCTION_TYPE := P_DEDUCTION_TYPE;
        V_DED_DATA.DEDUCTION_AMT  := ID.pension_deduc;
        PIPE ROW(V_DED_DATA);
      END LOOP;
    ELSIF P_DEDUCTION_TYPE = 'WAT' THEN
      FOR ID IN (SELECT *
                   FROM PRMS_TRANSACTION t
                  WHERE ENTITY_NUMBER = P_ENTITY_NUMBER
                    AND BRANCH_CODE = P_BRANCH_CODE
                    AND SAL_YEAR = P_YEAR
                    AND MONTH_CODE = P_MONTH_CODE
                    AND t.Water_Bill > 0) LOOP
      
        SELECT D.DESIGNATION_DESC, D.DESIGNATION_CODE
          INTO V_DED_DATA.DESIGNATION, V_DED_DATA.DESIG_CODE
          FROM PRMS_DESIGNATION D
         WHERE D.DESIGNATION_CODE =
               (SELECT H.DESIG_CODE
                  FROM PRMS_EMP_SAL H
                 WHERE H.EMP_ID = ID.EMP_ID);
        select e.emp_name
          into V_DED_DATA.EMP_NAME
          from prms_employee e
         where e.emp_id = id.emp_id;
        V_DED_DATA.MONTH          := ID.SAL_MONTH;
        V_DED_DATA.BRANCH_CODE    := ID.BRANCH_CODE;
        V_DED_DATA.EMP_ID         := ID.EMP_ID;
        V_DED_DATA.MONTH_YEAR     := ID.SAL_YEAR;
        V_DED_DATA.MONTH_CODE     := ID.MONTH_CODE;
        V_DED_DATA.DEDUCTION_TYPE := P_DEDUCTION_TYPE;
        V_DED_DATA.DEDUCTION_AMT  := ID.Water_Bill;
        PIPE ROW(V_DED_DATA);
      END LOOP;
    ELSIF P_DEDUCTION_TYPE = 'ELE' THEN
      FOR ID IN (SELECT *
                   FROM PRMS_TRANSACTION t
                  WHERE ENTITY_NUMBER = P_ENTITY_NUMBER
                    AND BRANCH_CODE = P_BRANCH_CODE
                    AND SAL_YEAR = P_YEAR
                    AND MONTH_CODE = P_MONTH_CODE
                    AND t.Electricity_Bill > 0) LOOP
      
        SELECT D.DESIGNATION_DESC, D.DESIGNATION_CODE
          INTO V_DED_DATA.DESIGNATION, V_DED_DATA.DESIG_CODE
          FROM PRMS_DESIGNATION D
         WHERE D.DESIGNATION_CODE =
               (SELECT H.DESIG_CODE
                  FROM PRMS_EMP_SAL H
                 WHERE H.EMP_ID = ID.EMP_ID);
        select e.emp_name
          into V_DED_DATA.EMP_NAME
          from prms_employee e
         where e.emp_id = id.emp_id;
        V_DED_DATA.MONTH          := ID.SAL_MONTH;
        V_DED_DATA.BRANCH_CODE    := ID.BRANCH_CODE;
        V_DED_DATA.EMP_ID         := ID.EMP_ID;
        V_DED_DATA.MONTH_YEAR     := ID.SAL_YEAR;
        V_DED_DATA.MONTH_CODE     := ID.MONTH_CODE;
        V_DED_DATA.DEDUCTION_TYPE := P_DEDUCTION_TYPE;
        V_DED_DATA.DEDUCTION_AMT  := ID.Electricity_Bill;
        PIPE ROW(V_DED_DATA);
      END LOOP;
    ELSIF P_DEDUCTION_TYPE = 'GAS' THEN
      FOR ID IN (SELECT *
                   FROM PRMS_TRANSACTION t
                  WHERE ENTITY_NUMBER = P_ENTITY_NUMBER
                    AND BRANCH_CODE = P_BRANCH_CODE
                    AND SAL_YEAR = P_YEAR
                    AND MONTH_CODE = P_MONTH_CODE
                    AND t.Gas_Bill > 0) LOOP
      
        SELECT D.DESIGNATION_DESC, D.DESIGNATION_CODE
          INTO V_DED_DATA.DESIGNATION, V_DED_DATA.DESIG_CODE
          FROM PRMS_DESIGNATION D
         WHERE D.DESIGNATION_CODE =
               (SELECT H.DESIG_CODE
                  FROM PRMS_EMP_SAL H
                 WHERE H.EMP_ID = ID.EMP_ID);
        select e.emp_name
          into V_DED_DATA.EMP_NAME
          from prms_employee e
         where e.emp_id = id.emp_id;
        V_DED_DATA.MONTH          := ID.SAL_MONTH;
        V_DED_DATA.BRANCH_CODE    := ID.BRANCH_CODE;
        V_DED_DATA.EMP_ID         := ID.EMP_ID;
        V_DED_DATA.MONTH_YEAR     := ID.SAL_YEAR;
        V_DED_DATA.MONTH_CODE     := ID.MONTH_CODE;
        V_DED_DATA.DEDUCTION_TYPE := P_DEDUCTION_TYPE;
        V_DED_DATA.DEDUCTION_AMT  := ID.Gas_Bill;
        PIPE ROW(V_DED_DATA);
      END LOOP;
    END IF;
  
  END FN_DED_DATA;
  FUNCTION FN_PF_DATA(P_ENTITY      IN NUMBER,
                      P_BRANCH_CODE IN VARCHAR2,
                      P_EMP_ID      IN VARCHAR2,
                      P_FIN_YEAR    IN VARCHAR2) RETURN XV_DATA
    PIPELINED IS
    V_LOAN_DATA     DATA;
    V_TO_MONTH_CODE NUMBER(2);
    V_TO_YEAR       NUMBER(4);
    Q_FROM_YEAR     VARCHAR2(4) := '';
    Q_TO_YEAR       VARCHAR2(4) := '';
    W_FROM_DATE     DATE;
    W_TO_DATE       DATE;
    V_YEAR          NUMBER(4);
    V_BF            varchar2(2) := 'Y';
    FUNCTION FN_DESIGNATION(P_EMP_ID IN VARCHAR2) RETURN VARCHAR2 IS
      V_DESIGNATION VARCHAR2(50) := '';
    BEGIN
      SELECT S.DESIG
        INTO V_DESIGNATION
        FROM PRMS_EMP_SAL S
       WHERE S.EMP_ID = P_EMP_ID;
      RETURN V_DESIGNATION;
    EXCEPTION
      WHEN OTHERS THEN
        RETURN V_DESIGNATION;
    END FN_DESIGNATION;
    FUNCTION FN_MONTH_NAME(P_MONTH_CODE IN NUMBER) RETURN VARCHAR2 IS
      V_MONTH_NAME VARCHAR2(10);
    BEGIN
      SELECT DECODE(P_MONTH_CODE,
                    1,
                    'JAN',
                    2,
                    'FEB',
                    3,
                    'MAR',
                    4,
                    'APR',
                    5,
                    'MAY',
                    6,
                    'JUN',
                    7,
                    'JUL',
                    8,
                    'AUG',
                    9,
                    'SEP',
                    10,
                    'OCT',
                    11,
                    'NOV',
                    12,
                    'DEC')
        INTO V_MONTH_NAME
        FROM DUAL;
      RETURN V_MONTH_NAME;
    END FN_MONTH_NAME;
  
  BEGIN
    IF P_FIN_YEAR IS NOT NULL THEN
      SELECT SUBSTR(P_FIN_YEAR, 1, INSTR(P_FIN_YEAR, '-') - 1),
             SUBSTR(P_FIN_YEAR, INSTR(P_FIN_YEAR, '-') + 1)
        INTO Q_FROM_YEAR, Q_TO_YEAR
        FROM DUAL;
    
    END IF;
  
    V_LOAN_DATA.FIN_YEAR := P_FIN_YEAR;
  
    if P_BRANCH_CODE is not null then
    
      for idx in (select *
                    from prms_emp_sal s
                   where s.emp_brn_code = P_BRANCH_CODE) loop
      
        for id in (SELECT *
                     FROM (SELECT EMP_ID,
                                  PF_YEAR,
                                  TO_NUMBER(DECODE(L.PF_MONTH_CODE,
                                                   '6',
                                                   '0',
                                                   PF_MONTH_CODE)) PF_MONTH_CODE,
                                  DECODE(L.PF_MONTH_CODE,
                                         '6',
                                         '',
                                         VOUCHAR_TYPE) VOUCHAR_TYPE,
                                  DECODE(L.PF_MONTH_CODE, '6', '', real_type) real_type,
                                  DECODE(L.PF_MONTH_CODE,
                                         '6',
                                         0,
                                         L.PF_ADV_DR_AMT) PF_ADV_DR_AMT,
                                  DECODE(L.PF_MONTH_CODE,
                                         '6',
                                         0,
                                         L.PF_ADV_CR_AMT) PF_ADV_CR_AMT,
                                  DECODE(VOUCHER_DR, '6', 0, L.VOUCHER_DR) VOUCHER_DR,
                                  DECODE(VOUCHER_CR, '6', 0, L.VOUCHER_CR) VOUCHER_CR,
                                  DECODE(L.PF_MONTH_CODE,
                                         '6',
                                         0,
                                         PF_ADV_REAL_AMT) PF_ADV_REAL_AMT,
                                  DECODE(L.PF_MONTH_CODE,
                                         '6',
                                         0,
                                         PF_CONTRIBUTION_AMT) PF_CONTRIBUTION_AMT,
                                  DECODE(L.PF_MONTH_CODE, '6', 0, INT_CHG_AMT) INT_CHG_AMT,
                                  PF_BALANCE,
                                  l.pf_adv1_bal ADV1,
                                  l.pf_adv2_bal ADV2,
                                  l.pf_adv3_bal ADV3,
                                  l.pf_adv1_bal + l.pf_adv2_bal +
                                  l.pf_adv3_bal TO_ADV,
                                  nvl(l.adv1_ins, 0) adv1_ins,
                                  nvl(l.adv2_ins, 0) adv2_ins,
                                  nvl(l.adv3_ins, 0) adv3_ins
                             FROM ELMS_PF_LEADGER L
                            WHERE L.EMP_ID = idx.emp_id
                              AND L.PF_YEAR = Q_FROM_YEAR
                              AND L.PF_MONTH_CODE > 5
                           UNION
                           SELECT EMP_ID,
                                  PF_YEAR,
                                  PF_MONTH_CODE,
                                  VOUCHAR_TYPE,
                                  real_type,
                                  L.PF_ADV_DR_AMT,
                                  L.PF_ADV_CR_AMT,
                                  nvl(VOUCHER_DR, 0) VOUCHER_DR,
                                  nvl(VOUCHER_CR, 0) VOUCHER_CR,
                                  PF_ADV_REAL_AMT,
                                  PF_CONTRIBUTION_AMT,
                                  INT_CHG_AMT,
                                  PF_BALANCE,
                                  l.pf_adv1_bal ADV1,
                                  l.pf_adv2_bal ADV2,
                                  l.pf_adv3_bal ADV3,
                                  l.pf_adv1_bal + l.pf_adv2_bal +
                                  l.pf_adv3_bal TO_ADV,
                                  nvl(l.adv1_ins, 0) adv1_ins,
                                  nvl(l.adv2_ins, 0) adv2_ins,
                                  nvl(l.adv3_ins, 0) adv3_ins
                             FROM ELMS_PF_LEADGER L
                            WHERE L.EMP_ID = idx.emp_id
                              AND L.PF_YEAR = Q_TO_YEAR
                              AND L.PF_MONTH_CODE < 7)
                    order by pf_year, PF_MONTH_CODE) loop
        
          V_LOAN_DATA.INTEREST_RATE := 13.00;
          V_LOAN_DATA.DESIGNATION   := FN_DESIGNATION(id.emp_id);
          V_LOAN_DATA.EMPLOYEE_ID   := id.emp_id;
          V_LOAN_DATA.YEAR          := id.pf_year;
          V_LOAN_DATA.MONTH_CODE    := id.pf_month_code;
          SELECT E.EMP_NAME
            INTO V_LOAN_DATA.EMP_NAME
            FROM PRMS_EMPLOYEE E
           WHERE E.EMP_ID = ID.EMP_ID;
        
          IF id.pf_month_code = 0 THEN
            V_LOAN_DATA.MONTH_NAME := 'B.F.';
          ELSE
            V_LOAN_DATA.MONTH_NAME := FN_MONTH_NAME(id.pf_month_code);
          END IF;
        
          V_LOAN_DATA.REAL_TYPE        := 'S';
          V_LOAN_DATA.VOUCHER_TYPE     := id.vouchar_type;
          V_LOAN_DATA.PF_ADV_DR_AMT    := id.pf_adv_dr_amt;
          V_LOAN_DATA.PF_ADV_CR_AMT    := id.pf_adv_cr_amt;
          V_LOAN_DATA.PF_COMTRIBUTION  := id.pf_contribution_amt;
          V_LOAN_DATA.PF_ADV_REAL_AMT  := ID.PF_ADV_REAL_AMT;
          V_LOAN_DATA.PF_INT_AMT       := ID.INT_CHG_AMT;
          V_LOAN_DATA.PF_BALANCE       := ID.PF_BALANCE;
          V_LOAN_DATA.PF_ADV1_AMT      := ID.ADV1;
          V_LOAN_DATA.PF_ADV2_AMt      := ID.ADV2;
          V_LOAN_DATA.PF_ADV3_AMT      := ID.ADV3;
          V_LOAN_DATA.PF_VOU_DR_AMT    := ID.VOUCHER_DR;
          V_LOAN_DATA.PF_VOU_CR_AMT    := ID.VOUCHER_CR;
          V_LOAN_DATA.ins_ADV1_AMT     := id.adv1_ins;
          V_LOAN_DATA.ins_ADV2_AMT     := id.adv2_ins;
          V_LOAN_DATA.ins_ADV3_AMT     := id.adv3_ins;
          V_LOAN_DATA.PF_ADV_AMT_TOTAL := ID.TO_ADV;
          PIPE ROW(V_LOAN_DATA);
        
        end loop;
      end loop;
    
    else
      for idx in (select *
                    from prms_emp_sal s
                  -- where s.emp_brn_code = P_BRANCH_CODE
                  ) loop
      
        for id in (SELECT *
                     FROM (SELECT EMP_ID,
                                  PF_YEAR,
                                  TO_NUMBER(DECODE(L.PF_MONTH_CODE,
                                                   '6',
                                                   '0',
                                                   PF_MONTH_CODE)) PF_MONTH_CODE,
                                  DECODE(L.PF_MONTH_CODE,
                                         '6',
                                         '',
                                         VOUCHAR_TYPE) VOUCHAR_TYPE,
                                  DECODE(L.PF_MONTH_CODE, '6', '', real_type) real_type,
                                  DECODE(L.PF_MONTH_CODE,
                                         '6',
                                         0,
                                         L.PF_ADV_DR_AMT) PF_ADV_DR_AMT,
                                  DECODE(L.PF_MONTH_CODE,
                                         '6',
                                         0,
                                         L.PF_ADV_CR_AMT) PF_ADV_CR_AMT,
                                  DECODE(VOUCHER_DR, '6', 0, L.VOUCHER_DR) VOUCHER_DR,
                                  DECODE(VOUCHER_CR, '6', 0, L.VOUCHER_CR) VOUCHER_CR,
                                  DECODE(L.PF_MONTH_CODE,
                                         '6',
                                         0,
                                         PF_ADV_REAL_AMT) PF_ADV_REAL_AMT,
                                  DECODE(L.PF_MONTH_CODE,
                                         '6',
                                         0,
                                         PF_CONTRIBUTION_AMT) PF_CONTRIBUTION_AMT,
                                  DECODE(L.PF_MONTH_CODE, '6', 0, INT_CHG_AMT) INT_CHG_AMT,
                                  PF_BALANCE,
                                  l.pf_adv1_bal ADV1,
                                  l.pf_adv2_bal ADV2,
                                  l.pf_adv3_bal ADV3,
                                  l.pf_adv1_bal + l.pf_adv2_bal +
                                  l.pf_adv3_bal TO_ADV,
                                  nvl(l.adv1_ins, 0) adv1_ins,
                                  nvl(l.adv2_ins, 0) adv2_ins,
                                  nvl(l.adv3_ins, 0) adv3_ins
                             FROM ELMS_PF_LEADGER L
                            WHERE L.EMP_ID = idx.emp_id
                              AND L.PF_YEAR = Q_FROM_YEAR
                              AND L.PF_MONTH_CODE > 5
                           UNION
                           SELECT EMP_ID,
                                  PF_YEAR,
                                  PF_MONTH_CODE,
                                  VOUCHAR_TYPE,
                                  real_type,
                                  L.PF_ADV_DR_AMT,
                                  L.PF_ADV_CR_AMT,
                                  nvl(VOUCHER_DR, 0) VOUCHER_DR,
                                  nvl(VOUCHER_CR, 0) VOUCHER_CR,
                                  PF_ADV_REAL_AMT,
                                  PF_CONTRIBUTION_AMT,
                                  INT_CHG_AMT,
                                  PF_BALANCE,
                                  l.pf_adv1_bal ADV1,
                                  l.pf_adv2_bal ADV2,
                                  l.pf_adv3_bal ADV3,
                                  l.pf_adv1_bal + l.pf_adv2_bal +
                                  l.pf_adv3_bal TO_ADV,
                                  nvl(l.adv1_ins, 0) adv1_ins,
                                  nvl(l.adv2_ins, 0) adv2_ins,
                                  nvl(l.adv3_ins, 0) adv3_ins
                             FROM ELMS_PF_LEADGER L
                            WHERE L.EMP_ID = idx.emp_id
                              AND L.PF_YEAR = Q_TO_YEAR
                              AND L.PF_MONTH_CODE < 7)
                    order by pf_year, PF_MONTH_CODE) loop
        
          V_LOAN_DATA.INTEREST_RATE := 13.00;
          V_LOAN_DATA.DESIGNATION   := FN_DESIGNATION(id.emp_id);
          V_LOAN_DATA.EMPLOYEE_ID   := id.emp_id;
          V_LOAN_DATA.YEAR          := id.pf_year;
          V_LOAN_DATA.MONTH_CODE    := id.pf_month_code;
          SELECT E.EMP_NAME
            INTO V_LOAN_DATA.EMP_NAME
            FROM PRMS_EMPLOYEE E
           WHERE E.EMP_ID = ID.EMP_ID;
        
          IF id.pf_month_code = 0 THEN
            V_LOAN_DATA.MONTH_NAME := 'B.F.';
          ELSE
            V_LOAN_DATA.MONTH_NAME := FN_MONTH_NAME(id.pf_month_code);
          END IF;
        
          V_LOAN_DATA.REAL_TYPE        := 'S';
          V_LOAN_DATA.VOUCHER_TYPE     := id.vouchar_type;
          V_LOAN_DATA.PF_ADV_DR_AMT    := id.pf_adv_dr_amt;
          V_LOAN_DATA.PF_ADV_CR_AMT    := id.pf_adv_cr_amt;
          V_LOAN_DATA.PF_COMTRIBUTION  := id.pf_contribution_amt;
          V_LOAN_DATA.PF_ADV_REAL_AMT  := ID.PF_ADV_REAL_AMT;
          V_LOAN_DATA.PF_INT_AMT       := ID.INT_CHG_AMT;
          V_LOAN_DATA.PF_BALANCE       := ID.PF_BALANCE;
          V_LOAN_DATA.PF_ADV1_AMT      := ID.ADV1;
          V_LOAN_DATA.PF_ADV2_AMt      := ID.ADV2;
          V_LOAN_DATA.PF_ADV3_AMT      := ID.ADV3;
          V_LOAN_DATA.PF_VOU_DR_AMT    := ID.VOUCHER_DR;
          V_LOAN_DATA.PF_VOU_CR_AMT    := ID.VOUCHER_CR;
          V_LOAN_DATA.ins_ADV1_AMT     := id.adv1_ins;
          V_LOAN_DATA.ins_ADV2_AMT     := id.adv2_ins;
          V_LOAN_DATA.ins_ADV3_AMT     := id.adv3_ins;
          V_LOAN_DATA.PF_ADV_AMT_TOTAL := ID.TO_ADV;
          PIPE ROW(V_LOAN_DATA);
        
        end loop;
      end loop;
    
    end if;
  
  END FN_PF_DATA;
  function fn_data_searching(p1            in varchar2,
                             p2            in varchar2,
                             p3            in varchar2,
                             p4            in varchar2,
                             p5            in varchar2,
                             p6            in varchar2,
                             p7            in varchar2,
                             p8            in varchar2,
                             p9            in varchar2,
                             p10           in varchar2,
                             p_type        in varchar2,
                             p_report_type in varchar2) return v_search_data
    pipelined is
    v_serach search_data;
  begin
    if p_type = 'NID' then
      null;
    elsif p_type = 'TIN' then
      null;
    else
      if p_report_type = 'ALL' then
        for idx in (select l.loc_code,
                           l.loan_type,
                           l.loan_acc,
                           l.loan_cat,
                           l.name1 || l.name2 Name,
                           l.f_name,
                           l.m_add1 || l.m_add2 || l.m_add3 maddress,
                           l.s_add1 || l.s_add2 || l.s_add3 saddress,
                           l.sanc_amt,
                           nid1 NID
                    
                      from lnaccount l
                     where upper(l.name1 || l.name2) like p1
                        or upper(l.name1 || l.name2) like p2
                        or upper(l.name1 || l.name2) like p3
                        or upper(l.name1 || l.name2) like p4
                        or upper(l.name1 || l.name2) like p5
                        or upper(l.name1 || l.name2) like p6
                        or upper(l.name1 || l.name2) like p7
                        or upper(l.name1 || l.name2) like p8
                        or upper(l.name1 || l.name2) like p9
                        or upper(l.name1 || l.name2) like p10) loop
          null;
          v_serach.Office_code := idx.loc_code;
        
          select l.loc_desc
            into v_serach.office_name
            from location l
           where l.loc_code = idx.loc_code;
        
          v_serach.loan_acc        := idx.loan_acc;
          v_serach.sanc_amt        := idx.sanc_amt;
          v_serach.Borrower_name   := idx.name;
          v_serach.Fathers_name    := idx.f_name;
          v_serach.Site_address    := idx.saddress;
          v_serach.Mailing_address := idx.maddress;
          v_serach.NID             := idx.nid;
          pipe row(v_serach);
        end loop;
      elsif p_report_type = 'BHBFC' then
        for idx in (select l.loc_code,
                           l.loan_type,
                           l.loan_acc,
                           l.loan_cat,
                           l.name1 || l.name2 Name,
                           l.f_name,
                           l.m_add1 || l.m_add2 || l.m_add3 maddress,
                           l.s_add1 || l.s_add2 || l.s_add3 saddress,
                           l.sanc_amt,
                           nid1 NID
                    
                      from lnaccount l
                     where (upper(l.name1 || l.name2) like p1 or
                           upper(l.name1 || l.name2) like p2 or
                           upper(l.name1 || l.name2) like p3 or
                           upper(l.name1 || l.name2) like p4 or
                           upper(l.name1 || l.name2) like p5 or
                           upper(l.name1 || l.name2) like p6 or
                           upper(l.name1 || l.name2) like p7 or
                           upper(l.name1 || l.name2) like p8 or
                           upper(l.name1 || l.name2) like p9 or
                           upper(l.name1 || l.name2) like p10)
                       and l.db_type not in
                           ('BHBFCFLAT', 'BHBFCOCR', 'BHBFCPRJ')) loop
          v_serach.Office_code := idx.loc_code;
          select l.loc_desc
            into v_serach.office_name
            from location l
           where l.loc_code = idx.loc_code;
          v_serach.loan_acc        := idx.loan_acc;
          v_serach.sanc_amt        := idx.sanc_amt;
          v_serach.Borrower_name   := idx.name;
          v_serach.Fathers_name    := idx.f_name;
          v_serach.Site_address    := idx.saddress;
          v_serach.Mailing_address := idx.maddress;
          v_serach.NID             := idx.nid;
          pipe row(v_serach);
        end loop;
      elsif p_report_type = 'BHBFCFLAT' then
        for idx in (select l.loc_code,
                           l.loan_type,
                           l.loan_acc,
                           l.loan_cat,
                           l.name1 || l.name2 Name,
                           l.f_name,
                           l.m_add1 || l.m_add2 || l.m_add3 maddress,
                           l.s_add1 || l.s_add2 || l.s_add3 saddress,
                           l.sanc_amt,
                           nid1 NID
                    
                      from lnaccount l
                     where (upper(l.name1 || l.name2) like p1 or
                           upper(l.name1 || l.name2) like p2 or
                           upper(l.name1 || l.name2) like p3 or
                           upper(l.name1 || l.name2) like p4 or
                           upper(l.name1 || l.name2) like p5 or
                           upper(l.name1 || l.name2) like p6 or
                           upper(l.name1 || l.name2) like p7 or
                           upper(l.name1 || l.name2) like p8 or
                           upper(l.name1 || l.name2) like p9 or
                           upper(l.name1 || l.name2) like p10)
                       and l.db_type = 'BHBFCFLAT') loop
          v_serach.Office_code := idx.loc_code;
          select l.loc_desc
            into v_serach.office_name
            from location l
           where l.loc_code = idx.loc_code;
          v_serach.loan_acc        := idx.loan_acc;
          v_serach.sanc_amt        := idx.sanc_amt;
          v_serach.Borrower_name   := idx.name;
          v_serach.Fathers_name    := idx.f_name;
          v_serach.Site_address    := idx.saddress;
          v_serach.Mailing_address := idx.maddress;
          v_serach.NID             := idx.nid;
          pipe row(v_serach);
        end loop;
      elsif p_report_type = 'BHBFCOCR' then
        for idx in (select l.loc_code,
                           l.loan_type,
                           l.loan_acc,
                           l.loan_cat,
                           l.name1 || l.name2 Name,
                           l.f_name,
                           l.m_add1 || l.m_add2 || l.m_add3 maddress,
                           l.s_add1 || l.s_add2 || l.s_add3 saddress,
                           l.sanc_amt,
                           nid1 NID
                    
                      from lnaccount l
                     where (upper(l.name1 || l.name2) like p1 or
                           upper(l.name1 || l.name2) like p2 or
                           upper(l.name1 || l.name2) like p3 or
                           upper(l.name1 || l.name2) like p4 or
                           upper(l.name1 || l.name2) like p5 or
                           upper(l.name1 || l.name2) like p6 or
                           upper(l.name1 || l.name2) like p7 or
                           upper(l.name1 || l.name2) like p8 or
                           upper(l.name1 || l.name2) like p9 or
                           upper(l.name1 || l.name2) like p10)
                       and l.db_type = 'BHBFCOCR') loop
          v_serach.Office_code := idx.loc_code;
          select l.loc_desc
            into v_serach.office_name
            from location l
           where l.loc_code = idx.loc_code;
          v_serach.loan_acc        := idx.loan_acc;
          v_serach.sanc_amt        := idx.sanc_amt;
          v_serach.Borrower_name   := idx.name;
          v_serach.Fathers_name    := idx.f_name;
          v_serach.Site_address    := idx.saddress;
          v_serach.Mailing_address := idx.maddress;
          v_serach.NID             := idx.nid;
          pipe row(v_serach);
        end loop;
      elsif p_report_type = 'BHBFCPRJ' then
        for idx in (select l.loc_code,
                           l.loan_type,
                           l.loan_acc,
                           l.loan_cat,
                           l.name1 || l.name2 Name,
                           l.f_name,
                           l.m_add1 || l.m_add2 || l.m_add3 maddress,
                           l.s_add1 || l.s_add2 || l.s_add3 saddress,
                           l.sanc_amt,
                           nid1 NID
                    
                      from lnaccount l
                     where (upper(l.name1 || l.name2) like p1 or
                           upper(l.name1 || l.name2) like p2 or
                           upper(l.name1 || l.name2) like p3 or
                           upper(l.name1 || l.name2) like p4 or
                           upper(l.name1 || l.name2) like p5 or
                           upper(l.name1 || l.name2) like p6 or
                           upper(l.name1 || l.name2) like p7 or
                           upper(l.name1 || l.name2) like p8 or
                           upper(l.name1 || l.name2) like p9 or
                           upper(l.name1 || l.name2) like p10)
                       and l.db_type = 'BHBFCPRJ') loop
          v_serach.Office_code := idx.loc_code;
          select l.loc_desc
            into v_serach.office_name
            from location l
           where l.loc_code = idx.loc_code;
          v_serach.loan_acc        := idx.loan_acc;
          v_serach.sanc_amt        := idx.sanc_amt;
          v_serach.Borrower_name   := idx.name;
          v_serach.Fathers_name    := idx.f_name;
          v_serach.Site_address    := idx.saddress;
          v_serach.Mailing_address := idx.maddress;
          v_serach.NID             := idx.nid;
          pipe row(v_serach);
        end loop;
      end if;
    end if;
  end fn_data_searching;
  function fn_QRT_Tax_Data(p_entity_num in number,
                           p_Branch     in varchar2,
                           p_year       in number,
                           p_month1     in number,
                           p_month2     in number,
                           p_month3     in number) return v_IncomeTaxData
    pipelined is
    w_IncomeTaxData IncomeTaxData;
  begin
    for idx in (select distinct t.emp_id
                  from prms_transaction t
                 where t.branch_code = p_Branch
                   and t.sal_year = p_year
                   and t.month_code in (p_month1, p_month2, p_month3)) loop
      null;
      w_IncomeTaxData.empid := idx.emp_id;
      select e.emp_name,
             s.desig_code,
             (select d.designation_desc
                from prms_designation d
               where d.designation_code = s.desig_code) designation
        into w_IncomeTaxData.emp_name,
             w_IncomeTaxData.emp_desig_code,
             w_IncomeTaxData.emp_designation
        from prms_emp_sal s
        join prms_employee e
          on (e.emp_id = s.emp_id)
       where s.emp_id = idx.emp_id
       order by s.desig_code, s.desig_seniority_code;
    
      select sum(t.income_tax)
        into w_IncomeTaxData.month1_amt
        from prms_transaction t
       where t.branch_code = p_Branch
         and t.emp_id = idx.emp_id
         and t.sal_year = p_year
         and t.month_code = p_month1; --,p_month2,p_month3
    
      select sum(t.income_tax)
        into w_IncomeTaxData.month2_amt
        from prms_transaction t
       where t.branch_code = p_Branch
         and t.emp_id = idx.emp_id
         and t.sal_year = p_year
         and t.month_code = p_month2; --,p_month2,p_month3                 
      select sum(t.income_tax)
        into w_IncomeTaxData.month3_amt
        from prms_transaction t
       where t.branch_code = p_Branch
         and t.emp_id = idx.emp_id
         and t.sal_year = p_year
         and t.month_code = p_month3; --,p_month2,p_month3
      pipe row(w_IncomeTaxData);
    end loop;
  end fn_QRT_Tax_Data;

  function fn_get_advance_payment(p_branch_code in varchar2,
                                  p_fin_year    in varchar2)
    return v_AdvanceIncomeTax
    pipelined is
    w_AdvanceIncomeTax AdvanceIncomeTax;
    v_year1 number:=0;
    v_year2 number:=0;
  begin
   v_year1:=to_number(substr(p_fin_year, 1, 4))+1;
   v_year2:=to_number(substr(p_fin_year, 6, 4))+1;
    for idx in (SELECT 'This is to certify that the amount of Taka =' ||
                       trim((select TO_CHAR(sum(i.pay_order_amount), '999,999,999.99')
                          from prms_tax_payment_info i
                         where i.branch_code = p_branch_code
                           and i.fin_year = p_fin_year)) || ' (' ||
                       (select (PRMS_AMOUNT_TO_WORDS(sum(i.pay_order_amount)))||' Taka '
                          from prms_tax_payment_info i
                         where i.branch_code = p_branch_code
                           and i.fin_year = p_fin_year) || ') ' ||
                       ' has been deducted from the taxable salary income of the employees working at '|| (select m.brn_name from prms_mbranch m where m.brn_code=p_branch_code)||' of BHBFC for the financial year '||p_fin_year||' (Tax year: '|| v_year1||'-'|| v_year2||').The pay orders of the  mentioned amount have been submitted to the Deputy Commissioner of Taxes, Tax Circle-32 (Salary), Tax Zone-2, Dhaka. The details have been given bellow :' Header1,
                       
                       EMP_ID,
                       trim((select TO_CHAR(sum(i.pay_order_amount),
                                       '999,999,999.99')
                          from prms_tax_payment_info i
                         where i.branch_code = p_branch_code
                           and i.fin_year = p_fin_year)) bhbfc_tax,
                       (select '(In Words: '||PRMS_AMOUNT_TO_WORDS(sum(i.pay_order_amount))||' Taka)'
                          from prms_tax_payment_info i
                         where i.branch_code = p_branch_code
                           and i.fin_year = p_fin_year) bhbfc_tax_in_words,
                       
                       'The amount of Taka =' ||
                       TO_CHAR(Case emp_id when '956'  then SUM(INCOME_TAX)+ 32000 else SUM(INCOME_TAX) end, '999,999.99') || ' (' ||
                       PRMS_AMOUNT_TO_WORDS(Case emp_id when '956'  then SUM(INCOME_TAX)+ 32000 else SUM(INCOME_TAX) end) || ' Taka) ' ||
                       'has been included in the above amount for ' ||
                       (SELECT E.EMP_NAME
                          FROM PRMS_EMPLOYEE E
                         WHERE E.EMP_ID = T.EMP_ID) || ', Designation: ' ||
                       (SELECT S.DESIG
                          FROM PRMS_EMP_SAL S
                         WHERE S.EMP_ID = T.EMP_ID) ||
                       ' (eTIN:'||(select e.tin_no from prms_employee e where e.emp_id=t.emp_id)||') as advance income tax for the financial year '||p_fin_year||' (Tax year: '|| v_year1||'-'|| v_year2||').' footer1
                
                  FROM (SELECT *
                          FROM PRMS_TRANSACTION
                         WHERE BRANCH_CODE = p_branch_code
                           AND SAL_YEAR = substr(p_fin_year, 1, 4)
                           AND MONTH_CODE > 6
                        UNION
                        SELECT *
                          FROM PRMS_TRANSACTION
                         WHERE BRANCH_CODE = p_branch_code
                           AND SAL_YEAR = substr(p_fin_year, 6, 4)
                           AND MONTH_CODE < 7) T
                 GROUP BY EMP_ID
                HAVING SUM(INCOME_TAX) > 0
                 ORDER BY EMP_ID) loop
    
      w_AdvanceIncomeTax.emp_id   := idx.emp_id;
      w_AdvanceIncomeTax.header1 := idx.header1;
      w_AdvanceIncomeTax.footer1 := idx.footer1;
      w_AdvanceIncomeTax.total_amount_in_taka:=trim(idx.bhbfc_tax_in_words);
      for in1 in (select *
                    from prms_tax_payment_info p
                   where p.branch_code = p_branch_code
                     and p.fin_year = p_fin_year) loop
        w_AdvanceIncomeTax.BRANCH_CODE      := in1.branch_code;
        w_AdvanceIncomeTax.FIN_YEAR         := in1.fin_year;
        w_AdvanceIncomeTax.PAY_ORDER_NO     := in1.pay_order_no;
        w_AdvanceIncomeTax.PAY_ORDER_DATE   := in1.pay_order_date;
        w_AdvanceIncomeTax.NAME_OF_BANK     := in1.name_of_bank;
        
        
        w_AdvanceIncomeTax.PAY_ORDER_AMOUNT := in1.pay_order_amount;
        
        
        w_AdvanceIncomeTax.REFERENCE_NUMBER := in1.reference_number;
        w_AdvanceIncomeTax.REFERENCE_DATE   := in1.reference_date;
      
        pipe row(w_AdvanceIncomeTax);
      end loop;
    
    end loop;
  
  end fn_get_advance_payment;

BEGIN
  NULL;
END PKG_RPT;
/
