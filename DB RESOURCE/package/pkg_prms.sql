create or replace package pkg_prms is

  -- author  : mosharraf & rubel
  -- supervised by md. rokunuzzaman
  -- created : 17-feb-19 11:15:51 am
  -- purpose : salary generation.

  /*procedure sp_salary_calculation(p_entity_num in number,
  p_user_id    in varchar2,
  p_salcode    in varchar2,
  p_error_msg  out varchar2);*/

  procedure sp_init_values(p_msg out varchar2);
  procedure sp_salary_calculation_new(p_entity_num in number,
                                      p_user_id    in varchar2,
                                      p_salcode    in varchar2,
                                      p_error_msg  out varchar2);

  /*  procedure sp_sal_calc_incrmnt(p_entity_num in number,
  p_error_msg  out varchar2);*/

  procedure sp_employee_updation(p_emp_id         in varchar2,
                                 p_new_brn_code   in varchar2,
                                 p_new_basic      in number,
                                 p_new_desig_code in varchar2,
                                 p_effective_date in varchar2,
                                 p_msg            out varchar2);

  procedure sp_new_employee_insertion(p_employee_id    in varchar2,
                                      p_employee_name  in varchar2,
                                      p_branch_code    in varchar2,
                                      p_designation    in varchar2,
                                      p_joining_date   in varchar2,
                                      p_dept_code      in varchar2,
                                      p_gender_type    in varchar2,
                                      p_blood_grp      in varchar2,
                                      p_rhfactor       in varchar2,
                                      p_dob            in varchar2,
                                      p_contact_no     in varchar2,
                                      p_tin            in varchar2,
                                      p_email          in varchar2,
                                      p_seniority_code in varchar2,
                                      p_address        in varchar2,
                                      p_entd_by        in varchar2,
                                      p_religion       in char,
                                      p_degree         in varchar2,
                                      p_home_dist      in varchar2,
                                      p_nid_no         in varchar2,
                                      p_msg            out varchar2);

  procedure sp_bonus_cal(p_entity         in number,
                         p_user_id        in varchar2,
                         p_basic_year     in number,
                         p_basic_mon_code in number,
                         p_bonus_type     in varchar2,
                         p_bon_pct        in number,
                         p_bon_order_no   in varchar2,
                         p_msg            out varchar2);

  type tax_data is record(
    branch_code    varchar2(5),
    emp_id         prms_emp_sal.emp_id%type,
    designation    prms_emp_sal.desig%type,
    emp_name       prms_employee.emp_name%type,
    month_year     varchar(10),
    sal_year       prms_transaction.sal_year%type,
    month_code     number(2),
    basic_pay      number(9, 2),
    dom_allowance  number(9, 2),
    entertainment  number(9, 2),
    med_allowance  number(9, 2),
    hr_allowance   number(9, 2),
    edu_allowance  number(9, 2),
    pf_deduction   number(9, 2),
    welfare_deduc  number(9, 2),
    income_tax     number(9, 2),
    tel_allowance  number(9, 2),
    drns_allowance number(9, 2),
    gen_insurence  number(9, 2),
    festival_bonus number(9, 2));
  type v_data is table of tax_data;
  function fn_tax_stmt_data(p_entity_number in number,
                            p_branch_code   in varchar2,
                            p_year1         in varchar2) return v_data
    pipelined;
  procedure sp_data_backup(p_entity_num in number,
                           p_entry_date in date,
                           p_error      out varchar2);
  procedure sp_log_tracing(p_entity     in number,
                           p_user_id    in varchar2,
                           p_branch     in varchar2,
                           p_year       in number,
                           p_month_code in number,
                           p_message    in varchar2,
                           p_type       in varchar2,
                           p_error      out varchar2);
  procedure sp_emp_activation(p_emp_id          in varchar2,
                              p_activation_code in varchar2,
                              p_effect_date     in date,
                              p_attached_bran   in varchar2,
                              p_error           out varchar2);
  function fn_manual_sal_data(p_entity_number in number,
                              p_branch_code   in varchar2,
                              p_emp_id        in varchar2,
                              p_year          in number,
                              p_month_code    in number) return number;

  function fn_manual_sal_data_pf(p_entity_number in number,
                                 p_branch_code   in varchar2,
                                 p_emp_id        in varchar2,
                                 p_year          in number,
                                 p_month_code    in number) return number;
  procedure sp_fraction_salary_calculation(p_entity_num in number,
                                           p_emp_id     in varchar2,
                                           p_days       in number,
                                           p_days_month in number,
                                           p_manual_sal in varchar2,
                                           p_user_id    in varchar2,
                                           p_error_msg  out varchar2);
end pkg_prms;
/
create or replace package body pkg_prms is
  function get_hr_amt(p_hr_alwn1 in number, p_hr_alwn2 in number)
    return number is
  begin
    if p_hr_alwn1 > p_hr_alwn2 then
      return p_hr_alwn1;
    else
      return p_hr_alwn2;
    end if;
  end get_hr_amt;

  function get_min_amt(p_alwn1 in number, p_alwn2 in number) return number is
  begin
    if p_alwn1 < p_alwn2 then
      return p_alwn1;
    else
      return p_alwn2;
    end if;
  end get_min_amt;

  function fn_get_hr_alwnc(p_type             in number,
                           p_basic_amt        in number,
                           p_actual_basic_amt in number) return number is
    v_hr_alwnc     number(9, 2) := 0;
    v_min_hr_alwnc number(9, 2) := 0;
  begin
  
    select h.house_rent_pct * p_actual_basic_amt, h.min_hr_amt
      into v_hr_alwnc, v_min_hr_alwnc
      from prms_house_rent_master h
     where h.brn_type = p_type
       and h.basic_min_amt <= p_basic_amt
       and h.basic_max_amt >= p_basic_amt;
    if p_basic_amt <> p_actual_basic_amt then
      return v_hr_alwnc;
    else
      return get_hr_amt(v_hr_alwnc, v_min_hr_alwnc);
    end if;
  
  end fn_get_hr_alwnc;

  /*PROCEDURE SP_SALARY_CALCULATION(P_ENTITY_NUM IN NUMBER,
                                  P_USER_ID    IN VARCHAR2,
                                  P_SALCODE    IN VARCHAR2,
                                  P_ERROR_MSG  OUT VARCHAR2) IS
  
    V_BASIC_AMT           NUMBER(9, 2) := 0;
    V_HR_ALWNC_AMT        NUMBER(9, 2) := 0;
    V_PENSION_ALLOWANCE   NUMBER(9, 2) := 0;
    V_HBADV_DEDUC         NUMBER(9, 2) := 0;
    V_PF_DED_AMT          NUMBER(9, 2) := 0;
    V_DESIG_CATAGORY      NUMBER(2);
    V_MIN_WELFARE_DED_AMT NUMBER(9, 2) := 0;
    V_MIN_INS_DED_AMT     NUMBER(9, 2) := 0;
    V_CBD_LAST_DATE       DATE;
    V_CBD_LAST_DAY        NUMBER(2) := 0;
    T_LPR_DATE            DATE;
    T_LPR_DAY             NUMBER(2) := 0;
    V_EXCEPTION EXCEPTION;
    V_MONTH_CODE NUMBER(2);
    V_SAL_YEAR   NUMBER(4);
    V_SAL_MONTH  VARCHAR2(10) := '';
  
    V_MED_ALWNC_AMT      NUMBER(9, 2) := 0;
    V_TEL_ALWNC_AMT      NUMBER(9, 2) := 0;
    V_TRANS_ALLOWANCE    NUMBER(9, 2) := 0;
    V_EDU_ALLOWANCE      NUMBER(9, 2) := 0;
    V_WASH_ALLOWANCE     NUMBER(9, 2) := 0;
    V_ENTERTAINMENT      NUMBER(9, 2) := 0;
    V_DOMESTIC_ALLOWANCE NUMBER(9, 2) := 0;
    V_OTHER_ALLOWANCE    NUMBER(9, 2) := 0;
    V_DREANESS_ALLWNC    NUMBER(9, 2) := 0;
    V_HILL_ALLWNC        NUMBER(9, 2) := 0;
  
    V_MCYCLE_DEDUC        NUMBER(9, 2) := 0;
    V_BICYCLE_DEDUC       NUMBER(9, 2) := 0;
    V_PFADV_DEDUC         NUMBER(9, 2) := 0;
    V_HBADV_ARREAR_DEDUC  NUMBER(9, 2) := 0;
    V_PFADV_ARREAR_DEDUC  NUMBER(9, 2) := 0;
    V_TEL_EXCESS_BILL     NUMBER(9, 2) := 0;
    V_OTHER_DEDUC         NUMBER(9, 2) := 0;
    V_COMP_DEDUC          NUMBER(9, 2) := 0;
    V_PENSION_DEDUC       NUMBER(9, 2) := 0;
    V_REVENUE_DEDUC       NUMBER(9, 2) := 0;
    V_CARFARE_DEDUC       NUMBER(9, 2) := 0;
    V_CARUSE_DEDUC        NUMBER(9, 2) := 0;
    V_HBADV_DEDUC_PERCENT NUMBER(9, 2) := 0;
    V_GAS_BILL            NUMBER(9, 2) := 0;
    V_WATER_BILL          NUMBER(9, 2) := 0;
    V_ELECTRICITY_BILL    NUMBER(9, 2) := 0;
    V_HOUSE_RENT_DEDUC    NUMBER(9, 2) := 0;
    V_NEWS_PAPER_DEDUC    NUMBER(9, 2) := 0;
    V_WELFARE_DED_AMT     NUMBER(9, 2) := 0;
    V_INS_DED_AMT         NUMBER(9, 2) := 0;
    V_INCOME_TAX          NUMBER(9, 2) := 0;
    V_INCOME_TAX_ARR      NUMBER(9, 2) := 0;
    V_TOT_SAL_ALLOWANCE   NUMBER(9, 2) := 0;
    V_GROSS_PAY_AMT       NUMBER(9, 2) := 0;
    V_NET_PAY_AMT         NUMBER(9, 2) := 0;
    V_NET_DED_AMT         NUMBER(9, 2) := 0;
    V_ASON_DATE           DATE := TRUNC(SYSDATE);
    V_REMARKS_ALLOWANCE   VARCHAR2(100) := '';
    V_REMARKS_DEDUCTION   VARCHAR2(100) := '';
    PROCEDURE SP_SAL_CALC_INCRMNT(P_EMP_ID    IN VARCHAR2,
                                  P_BRN_TYPE  IN NUMBER,
                                  P_PRL_DAYS  IN NUMBER,
                                  P_ERROR_MSG OUT VARCHAR2) IS
    
      V_PREV_BASIC_TOTAL NUMBER(9, 2) := 0;
      V_PREV_BASIC_AMT   NUMBER(9, 2) := 0;
      V_CURR_BASIC_AMT   NUMBER(9, 2) := 0;
      V_DAYS_COUNT1      NUMBER(2) := 0;
      V_DAYS_COUNT2      NUMBER(2) := 0;
      V_DAYS_COUNT       NUMBER(2) := 0;
      V_HR_AMT1          NUMBER(9, 2) := 0;
      V_HR_AMT2          NUMBER(9, 2) := 0;
      V_BRN_TYPE         PRMS_MBRANCH.BRN_TYPE%TYPE;
      V_SQ_RESIDENCE     VARCHAR2(1) := '';
      V_PF_DED_AMT1      NUMBER(9, 2) := 0;
      V_PF_DED_AMT2      NUMBER(9, 2) := 0;
      V_PD_DED_PCT       NUMBER(9, 2) := 0;
      V_PF_LIEN          PRMS_EMP_SAL.PF_LIEN%TYPE;
      V_HBADV_DED        NUMBER(9, 2) := 0;
      V_PENSION_ALLN     NUMBER(9, 2) := 0;
      V_MONTH_CODE       NUMBER(2);
      V_SAL_YEAR         NUMBER(4);
      V_ASON_DATE        DATE := TRUNC(SYSDATE);
    BEGIN
      FOR IDX IN (SELECT * FROM PRMS_EMP_SAL S WHERE S.EMP_ID = P_EMP_ID) LOOP
      
        IF TO_DATE(LAST_DAY(IDX.TRANSFER_DATE)) =
           LAST_DAY(TRUNC(V_ASON_DATE)) THEN
          --TRANSFER OCCURED THIS MONTH
          SELECT EXTRACT(DAY FROM IDX.TRANSFER_DATE) - 1
            INTO V_DAYS_COUNT1
            FROM DUAL;
        
          SELECT EXTRACT(DAY FROM LAST_DAY(TRUNC(V_ASON_DATE)))
            INTO V_DAYS_COUNT
            FROM DUAL;
        
          IF P_PRL_DAYS > V_DAYS_COUNT1 THEN
            V_DAYS_COUNT2 := P_PRL_DAYS - V_DAYS_COUNT1;
          ELSE
            V_DAYS_COUNT2 := V_DAYS_COUNT - V_DAYS_COUNT1;
          END IF;
        
          SELECT NVL(H.NEW_BASIC, 0) + NVL(H.ARREAR_BASIC, 0),
                 SQ_RESIDENCE,
                 (SELECT M.BRN_TYPE
                    FROM PRMS_MBRANCH M
                   WHERE M.BRN_CODE = H.EMP_BRN_CODE) AS BRN_TYPE,
                 H.PF_LIEN,
                 H.PF_DEDUCTION_PCT
            INTO V_PREV_BASIC_TOTAL,
                 V_SQ_RESIDENCE,
                 V_BRN_TYPE,
                 V_PF_LIEN,
                 V_PD_DED_PCT
            FROM PRMS_EMP_SAL_HIST H
           WHERE H.EMP_ID = IDX.EMP_ID
             AND H.EFT_SERIAL =
                 (SELECT MAX(H.EFT_SERIAL) - 1
                    FROM PRMS_EMP_SAL_HIST H
                   WHERE H.EMP_ID = IDX.EMP_ID);
        
          V_PREV_BASIC_AMT := (V_PREV_BASIC_TOTAL * V_DAYS_COUNT1) /
                              V_DAYS_COUNT;
          V_CURR_BASIC_AMT := ((IDX.NEW_BASIC + IDX.ARREAR_BASIC) *
                              V_DAYS_COUNT2) / V_DAYS_COUNT;
        
          V_HR_AMT2 := FN_GET_HR_ALWNC(P_BRN_TYPE,
                                       (NVL(IDX.NEW_BASIC, 0) +
                                       NVL(IDX.ARREAR_BASIC, 0)),
                                       V_CURR_BASIC_AMT);
          V_HR_AMT1 := FN_GET_HR_ALWNC(V_BRN_TYPE,
                                       V_PREV_BASIC_TOTAL,
                                       V_PREV_BASIC_AMT);
        
          SELECT ROUND(((D.HBADV_DEDUC_PERCENT * (V_HR_AMT1 + V_HR_AMT2)) / 100),
                       2) + NVL(D.HB_ADV_DEDUC, 0)
            INTO V_HBADV_DED
            FROM PRMS_DEDUC D
           WHERE D.EMP_ID = IDX.EMP_ID;
        
          IF IDX.SQ_RESIDENCE = 'Y' THEN
            V_HR_AMT2 := 0;
          END IF;
        
          IF V_SQ_RESIDENCE = 'Y' THEN
            V_HR_AMT1 := 0;
          END IF;
        
          IF V_PF_LIEN = 'N' THEN
            V_PF_DED_AMT1 := 0;
          ELSE
            V_PF_DED_AMT1 := ROUND(V_PREV_BASIC_AMT * NVL(V_PD_DED_PCT, 0) / 100,
                                   2);
          END IF;
        
          IF IDX.PF_LIEN = 'N' THEN
            V_PF_DED_AMT2 := 0;
          ELSE
            V_PF_DED_AMT2 := ROUND(V_CURR_BASIC_AMT *
                                   NVL(IDX.PF_DEDUCTION_PCT, 0) / 100,
                                   2);
          END IF;
        
          V_PENSION_ALLN := NVL(ROUND((IDX.PEN_PCT *
                                      (V_CURR_BASIC_AMT + V_PREV_BASIC_AMT)) / 100,
                                      2),
                                0);
        
          SELECT TO_NUMBER(TO_CHAR(TO_DATE(V_ASON_DATE, 'dd-mon-yy'), 'mm'))
            INTO V_MONTH_CODE
            FROM DUAL;
          SELECT TO_NUMBER(TO_CHAR(V_ASON_DATE, 'YYYY'))
            INTO V_SAL_YEAR
            FROM DUAL;
        
          V_BASIC_AMT         := V_PREV_BASIC_AMT + V_CURR_BASIC_AMT;
          V_HR_ALWNC_AMT      := V_HR_AMT1 + V_HR_AMT2;
          V_PENSION_ALLOWANCE := V_PENSION_ALLN;
          V_PENSION_DEDUC     := V_PENSION_ALLOWANCE;
          V_HBADV_DEDUC       := V_HBADV_DED;
          V_PF_DED_AMT        := ROUND(V_PF_DED_AMT1 + V_PF_DED_AMT2);
        
          IF IDX.DESIG_CODE = '0' THEN
            V_HR_ALWNC_AMT      := 0;
            V_PENSION_ALLOWANCE := 0;
            V_PENSION_DEDUC     := 0;
          END IF;
        
        ELSE
          --NO TRANSFER OCCURED--
          V_BASIC_AMT := NVL(IDX.NEW_BASIC, 0) + NVL(IDX.ARREAR_BASIC, 0);
        
          V_HR_ALWNC_AMT := FN_GET_HR_ALWNC(P_BRN_TYPE,
                                            IDX.NEW_BASIC,
                                            V_BASIC_AMT);
          SELECT ROUND(((D.HBADV_DEDUC_PERCENT * V_HR_ALWNC_AMT) / 100), 2) +
                 NVL(D.HB_ADV_DEDUC, 0)
            INTO V_HBADV_DEDUC
            FROM PRMS_DEDUC D
           WHERE D.EMP_ID = IDX.EMP_ID;
        
          IF IDX.SQ_RESIDENCE <> 'Y' THEN
            NULL;
          ELSE
            V_HR_ALWNC_AMT := 0;
          END IF;
        
          BEGIN
            SELECT NVL(ROUND((PEN_PCT * V_BASIC_AMT) / 100, 2), 0)
              INTO V_PENSION_ALLOWANCE
              FROM PRMS_EMP_SAL
             WHERE EMP_ID = IDX.EMP_ID;
            V_PENSION_DEDUC := V_PENSION_ALLOWANCE;
          END;
          IF IDX.DESIG_CODE = '0' THEN
            V_HR_ALWNC_AMT      := 0;
            V_PENSION_ALLOWANCE := 0;
            V_PENSION_DEDUC     := 0;
          END IF;
        
          IF IDX.PF_LIEN = 'N' THEN
            V_PF_DED_AMT := 0;
          ELSE
            V_PF_DED_AMT := ROUND(V_BASIC_AMT *
                                  NVL(IDX.PF_DEDUCTION_PCT, 0) / 100,
                                  2);
          END IF;
        
        END IF;
      
      END LOOP;
    EXCEPTION
      WHEN OTHERS THEN
        P_ERROR_MSG := 'ERROR IN SP_SAL_CALC_INCRMNT: ' || SQLERRM;
    END SP_SAL_CALC_INCRMNT;
  
  BEGIN
    --- DBMS_OUTPUT.PUT_LINE('SALARY CALCULATED');
  
    SELECT LAST_DAY(TRUNC(SYSDATE)) INTO V_CBD_LAST_DATE FROM DUAL;
    SELECT EXTRACT(DAY FROM V_CBD_LAST_DATE) INTO V_CBD_LAST_DAY FROM DUAL;
  
    SELECT UPPER(TO_CHAR(V_ASON_DATE, 'Month')) INTO V_SAL_MONTH FROM DUAL;
    SELECT TO_NUMBER(TO_CHAR(TO_DATE(V_ASON_DATE, 'dd-mon-yy'), 'mm'))
      INTO V_MONTH_CODE
      FROM DUAL;
    SELECT TO_NUMBER(TO_CHAR(V_ASON_DATE, 'YYYY'))
      INTO V_SAL_YEAR
      FROM DUAL;
    ----------------DELETE CURRENT MONTH SALARY FOR RE-GENERATING IT.
    DELETE FROM PRMS_TRANSACTION T
     WHERE T.ENTITY_NUMBER = 1
       AND T.SAL_YEAR = V_SAL_YEAR
       AND T.MONTH_CODE = V_MONTH_CODE;
    ----------------DELETE CURRENT MONTH SALARY FOR RE-GENERATING IT.
  
    --MAIN LOOP--
    FOR ID IN (SELECT *
                 FROM PRMS_EMP_SAL S
                 JOIN PRMS_MBRANCH B
                   ON (S.EMP_BRN_CODE = B.BRN_CODE)
                WHERE TRIM(S.ACC_NO_ACTIVE) <> 'N'
                     -- AND S.EMP_ID = '913'
                  AND (SELECT PRMS_EMPLOYEE.DOB
                         FROM PRMS_EMPLOYEE
                        WHERE PRMS_EMPLOYEE.EMP_ID = S.EMP_ID) IS NOT NULL) LOOP
    
      IF ID.DESIG_CODE = '0' THEN
        V_MIN_WELFARE_DED_AMT := 0;
        V_MIN_INS_DED_AMT     := 0;
      ELSIF ID.DESIG_CODE = '1' THEN
        V_MIN_WELFARE_DED_AMT := 50;
        V_MIN_INS_DED_AMT     := 0;
      ELSE
        V_MIN_WELFARE_DED_AMT := 50;
        V_MIN_INS_DED_AMT     := 40;
      END IF;
      BEGIN
        SELECT ADD_MONTHS(DOB, 59 * 12)
          INTO T_LPR_DATE
          FROM PRMS_EMPLOYEE
         WHERE EMP_ID = ID.EMP_ID;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          T_LPR_DATE := ID.LPR_LAST_DATE;
      END;
    
      ---ALWOANCE
    
      V_MED_ALWNC_AMT := ID.MEDICAL_ALLOWANCE;
    
      BEGIN
        SELECT A.TEL_ALLOWANCE,
               A.TRANS_ALLOWANCE,
               A.EDU_ALLOWANCE,
               A.WASH_ALLOWANCE,
               A.DOMES_ALLOWANCE,
               A.HILL_ALLWNC,
               A.ENTERTAIN_ALLOWANCE,
               A.OTHER_ALLOWANCE,
               A.REMARKS
          INTO V_TEL_ALWNC_AMT,
               V_TRANS_ALLOWANCE,
               V_EDU_ALLOWANCE,
               V_WASH_ALLOWANCE,
               V_DOMESTIC_ALLOWANCE,
               V_HILL_ALLWNC,
               V_ENTERTAINMENT,
               V_OTHER_ALLOWANCE,
               V_REMARKS_ALLOWANCE
        
          FROM PRMS_ALLOWANCE A
         WHERE A.EMP_ID = ID.EMP_ID;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          DBMS_OUTPUT.PUT_LINE('NO ALLOWANCE DATA FOUND FOR THIS EMPLOYEE: ' ||
                               ID.EMP_ID);
          --RAISE V_EXCEPTION;
      END;
    
      IF LAST_DAY(T_LPR_DATE) = V_CBD_LAST_DATE THEN
      
        SELECT EXTRACT(DAY FROM T_LPR_DATE) INTO T_LPR_DAY FROM DUAL;
      
        SP_SAL_CALC_INCRMNT(ID.EMP_ID, ID.BRN_TYPE, T_LPR_DAY, P_ERROR_MSG);
        V_MIN_WELFARE_DED_AMT := (V_MIN_WELFARE_DED_AMT * T_LPR_DAY) /
                                 V_CBD_LAST_DAY;
        V_MIN_INS_DED_AMT     := (V_MIN_INS_DED_AMT * T_LPR_DAY) /
                                 V_CBD_LAST_DAY;
        V_BASIC_AMT           := (V_BASIC_AMT * T_LPR_DAY) / V_CBD_LAST_DAY;
        V_MED_ALWNC_AMT       := (V_MED_ALWNC_AMT * T_LPR_DAY) /
                                 V_CBD_LAST_DAY;
        V_TRANS_ALLOWANCE     := (V_TRANS_ALLOWANCE * T_LPR_DAY) /
                                 V_CBD_LAST_DAY;
        V_EDU_ALLOWANCE       := (V_EDU_ALLOWANCE * T_LPR_DAY) /
                                 V_CBD_LAST_DAY;
        V_WASH_ALLOWANCE      := (V_WASH_ALLOWANCE * T_LPR_DAY) /
                                 V_CBD_LAST_DAY;
        V_DOMESTIC_ALLOWANCE  := (V_DOMESTIC_ALLOWANCE * T_LPR_DAY) /
                                 V_CBD_LAST_DAY;
        V_CARFARE_DEDUC       := (V_CARFARE_DEDUC * T_LPR_DAY) /
                                 V_CBD_LAST_DAY;
        V_NEWS_PAPER_DEDUC    := (V_NEWS_PAPER_DEDUC * T_LPR_DAY) /
                                 V_CBD_LAST_DAY;
      
      ELSE
        SP_SAL_CALC_INCRMNT(ID.EMP_ID, ID.BRN_TYPE, 0, P_ERROR_MSG);
      END IF;
    
      -------------------------------------------------------------------------------------------------------------
      --                              PRL ARENA
      -------------------------------------------------------------------------------------------------------------
      \*IF T_LPR_DATE < V_CBD_LAST_DATE THEN
        --IF '25-FEB-2019' < '28-FEB-2019' THEN
        SELECT EXTRACT(DAY FROM T_LPR_DATE) INTO T_LPR_DAY FROM DUAL;
      
      
        --  V_HR_ALWNC_AMT := (V_HR_ALWNC_AMT * T_LPR_DAY) / V_CBD_LAST_DAY;
      END IF;*\
      -------------------------------------------------------------------------------------------------------------
    
      ---DEDUCTION
      BEGIN
        SELECT D.MCYCLE_DEDUC,
               D.BCYCLE_DEDUC,
               D.PFADV_DEDUC,
               D.REVENUE,
               D.CAR_FARE,
               D.CAR_USE,
               D.GAS_BILL,
               D.WATER_BILL,
               D.ELECT_BILL,
               D.NEWS_PAPER,
               D.HBADV_ARREAR,
               D.PFADV_ARREAR,
               D.TEL_EXCESS_BILL,
               D.OTHER_DEDUC,
               D.REMARKS,
               D.COMP_DEDUC,
               D.HBADV_DEDUC_PERCENT,
               D.INCOME_TAX,
               D.INCOME_TAX_ARR
          INTO V_MCYCLE_DEDUC,
               V_BICYCLE_DEDUC,
               V_PFADV_DEDUC,
               V_REVENUE_DEDUC,
               V_CARFARE_DEDUC,
               V_CARUSE_DEDUC,
               V_GAS_BILL,
               V_WATER_BILL,
               V_ELECTRICITY_BILL,
               V_NEWS_PAPER_DEDUC,
               V_HBADV_ARREAR_DEDUC,
               V_PFADV_ARREAR_DEDUC,
               V_TEL_EXCESS_BILL,
               V_OTHER_DEDUC,
               V_REMARKS_DEDUCTION,
               V_COMP_DEDUC,
               V_HBADV_DEDUC_PERCENT,
               V_INCOME_TAX,
               V_INCOME_TAX_ARR
          FROM PRMS_DEDUC D
         WHERE D.EMP_ID = ID.EMP_ID;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          DBMS_OUTPUT.PUT_LINE('NO DEDUCTION DATA FOUND FOR THIS EMPLOYEE: ' ||
                               ID.EMP_ID);
          --RAISE V_EXCEPTION;
      END;
    
      SELECT D.DESIGNATION_CATEGORY
        INTO V_DESIG_CATAGORY
        FROM PRMS_DESIGNATION D
       WHERE D.DESIGNATION_CODE = ID.DESIG_CODE;
    
      V_WELFARE_DED_AMT := GET_MIN_AMT(ROUND(V_BASIC_AMT * 0.01, 2),
                                       V_MIN_WELFARE_DED_AMT);
    
      IF V_DESIG_CATAGORY <> 1 THEN
        V_INS_DED_AMT := 0;
      ELSE
      
        V_INS_DED_AMT := GET_MIN_AMT(ROUND(V_BASIC_AMT * 0.007, 2),
                                     V_MIN_INS_DED_AMT);
      END IF;
    
      IF P_SALCODE = 'SPECIAL' THEN
        V_HBADV_DEDUC   := 0;
        V_MCYCLE_DEDUC  := 0;
        V_BICYCLE_DEDUC := 0;
        V_PFADV_DEDUC   := 0;
        V_COMP_DEDUC    := 0;
      END IF;
    
      V_TOT_SAL_ALLOWANCE := NVL(V_BASIC_AMT, 0) + NVL(V_MED_ALWNC_AMT, 0) +
                             NVL(V_HR_ALWNC_AMT, 0) +
                             NVL(V_TEL_ALWNC_AMT, 0) +
                             NVL(V_TRANS_ALLOWANCE, 0) +
                             NVL(V_EDU_ALLOWANCE, 0) +
                             NVL(V_WASH_ALLOWANCE, 0) +
                             NVL(V_ENTERTAINMENT, 0) +
                             NVL(V_DOMESTIC_ALLOWANCE, 0) +
                             NVL(V_OTHER_ALLOWANCE, 0) +
                             NVL(V_DREANESS_ALLWNC, 0) +
                             NVL(V_HILL_ALLWNC, 0);
    
      V_GROSS_PAY_AMT := V_TOT_SAL_ALLOWANCE + V_PENSION_ALLOWANCE;
    
      V_NET_DED_AMT := NVL(V_HBADV_DEDUC, 0) + NVL(V_MCYCLE_DEDUC, 0) +
                       NVL(V_BICYCLE_DEDUC, 0) + NVL(V_PFADV_DEDUC, 0) +
                       NVL(V_HBADV_ARREAR_DEDUC, 0) +
                       NVL(V_PFADV_ARREAR_DEDUC, 0) +
                       NVL(V_TEL_EXCESS_BILL, 0) + NVL(V_OTHER_DEDUC, 0) +
                       NVL(V_COMP_DEDUC, 0) + NVL(V_REVENUE_DEDUC, 0) +
                       NVL(V_CARFARE_DEDUC, 0) + NVL(V_CARUSE_DEDUC, 0) +
                       NVL(V_GAS_BILL, 0) + NVL(V_WATER_BILL, 0) +
                       NVL(V_ELECTRICITY_BILL, 0) +
                       NVL(V_HOUSE_RENT_DEDUC, 0) +
                       NVL(V_NEWS_PAPER_DEDUC, 0) +
                       NVL(V_WELFARE_DED_AMT, 0) + NVL(V_INS_DED_AMT, 0) +
                       NVL(V_PF_DED_AMT, 0) + NVL(V_INCOME_TAX, 0) +
                       NVL(V_INCOME_TAX_ARR, 0);
      V_NET_PAY_AMT := V_TOT_SAL_ALLOWANCE - V_NET_DED_AMT;
      ---------------------------INSERTION INTO TRANSACTION TABLE-------------------------------
      INSERT INTO PRMS_TRANSACTION
        (ENTITY_NUMBER,
         BRANCH_CODE,
         EMP_ID,
         SAL_YEAR,
         MONTH_CODE,
         SAL_MONTH,
         BASIC_PAY,
         MEDICAL_ALLOWANCE,
         HOUSE_RENT_ALLOWANCE,
         TEL_ALLOWANCE,
         TRANS_ALLOWANCE,
         EDU_ALLOWANCE,
         WASH_ALLOWANCE,
         PENSION_ALLOWANCE,
         ENTERTAINMENT,
         DOMESTIC_ALLOWANCE,
         OTHER_ALLOWANCE,
         GROSS_PAY_AMT,
         HBADV_DEDUC,
         MCYCLE_DEDUC,
         BICYCLE_DEDUC,
         PFADV_DEDUC,
         PENSION_DEDUC,
         REVENUE_DEDUC,
         WELFARE_DEDUC,
         CARFARE_DEDUC,
         CARUSE_DEDUC,
         GAS_BILL,
         WATER_BILL,
         ELECTRICITY_BILL,
         HOUSE_RENT_DEDUC,
         NEWS_PAPER_DEDUC,
         PF_DEDUCTION,
         NET_DED_AMT,
         NET_PAY_AMT,
         HBADV_ARREAR_DEDUC,
         PFADV_ARREAR_DEDUC,
         TEL_EXCESS_BILL,
         GEN_INSURENCE,
         \*SP_DEDUC,
         SP_DESCRIPTION,
         TREMARKS,*\
         ARREAR,
         OTHER_DEDUC,
         HBADV_DEDUC_PERCENT,
         TOT_SAL_ALLOWANCE,
         ARREAR_BASIC,
         \*  INSTL_AMT_TLO,
         INSTL_AMT_TLR,
         INSTL_AMT_INS,
         INSTL_AMT_INC,
         OFFICE_CODE,*\
         COMP_DEDUC,
         DEARNESS_ALLOWANCE,
         GENERATED_BY,
         GENERATED_ON,
         INCOME_TAX,
         INCOME_TAX_ARR,
         HILL_ALLWNC,
         ACTUAL_BASIC,
         DEDUCTION_REMARKS,
         ALLOWANCE_REMARKS)
      VALUES
        (P_ENTITY_NUM,
         ID.EMP_BRN_CODE,
         ID.EMP_ID,
         V_SAL_YEAR,
         V_MONTH_CODE,
         V_SAL_MONTH,
         ID.NEW_BASIC,
         V_MED_ALWNC_AMT,
         NVL(V_HR_ALWNC_AMT, 0),
         NVL(V_TEL_ALWNC_AMT, 0),
         NVL(V_TRANS_ALLOWANCE, 0),
         NVL(V_EDU_ALLOWANCE, 0),
         NVL(V_WASH_ALLOWANCE, 0),
         NVL(V_PENSION_ALLOWANCE, 0),
         NVL(V_ENTERTAINMENT, 0),
         NVL(V_DOMESTIC_ALLOWANCE, 0),
         NVL(V_OTHER_ALLOWANCE, 0),
         V_GROSS_PAY_AMT,
         NVL(V_HBADV_DEDUC, 0),
         NVL(V_MCYCLE_DEDUC, 0),
         NVL(V_BICYCLE_DEDUC, 0),
         NVL(V_PFADV_DEDUC, 0),
         NVL(V_PENSION_DEDUC, 0),
         NVL(V_REVENUE_DEDUC, 0),
         NVL(V_WELFARE_DED_AMT, 0),
         NVL(V_CARFARE_DEDUC, 0),
         NVL(V_CARUSE_DEDUC, 0),
         NVL(V_GAS_BILL, 0),
         NVL(V_WATER_BILL, 0),
         NVL(V_ELECTRICITY_BILL, 0),
         NVL(V_HOUSE_RENT_DEDUC, 0),
         NVL(V_NEWS_PAPER_DEDUC, 0),
         NVL(V_PF_DED_AMT, 0),
         V_NET_DED_AMT,
         V_NET_PAY_AMT,
         NVL(V_HBADV_ARREAR_DEDUC, 0),
         NVL(V_PFADV_ARREAR_DEDUC, 0),
         NVL(V_TEL_EXCESS_BILL, 0),
         NVL(V_INS_DED_AMT, 0),
         0, -----AREAR OTHER
         NVL(V_OTHER_DEDUC, 0),
         NVL(V_HBADV_DEDUC_PERCENT, 0),
         V_TOT_SAL_ALLOWANCE,
         NVL(ID.ARREAR_BASIC, 0),
         NVL(V_COMP_DEDUC, 0),
         NVL(V_DREANESS_ALLWNC, 0),
         P_USER_ID,
         V_ASON_DATE,
         NVL(V_INCOME_TAX, 0),
         NVL(V_INCOME_TAX_ARR, 0),
         NVL(V_HILL_ALLWNC, 0),
         ID.NEW_BASIC,
         V_REMARKS_DEDUCTION,
         V_REMARKS_ALLOWANCE);
      --EXCEPTION WHEN OTHERS
    
    END LOOP;
  
  EXCEPTION
    WHEN OTHERS THEN
      P_ERROR_MSG := 'ERROR IN SP_SALARY_CALCULATION: ' || SQLERRM;
      ROLLBACK;
  END SP_SALARY_CALCULATION;*/

  procedure sp_fraction_salary_calculation(p_entity_num in number,
                                           p_emp_id     in varchar2,
                                           p_days       in number,
                                           p_days_month in number,
                                           p_manual_sal in varchar2,
                                           p_user_id    in varchar2,
                                           p_error_msg  out varchar2) is
    v_days_count          number := 0;
    v_fraction_basic      number(9, 2) := 0;
    v_fraction_hr         number(9, 2) := 0;
    v_fraction_medical    number(9, 2) := 0;
    v_bran_type           varchar2(1) := '';
    v_pf_deduction        number(9, 2) := 0;
    v_pension_ded         number(9, 2) := 0;
    v_min_welfare_ded_amt number(9, 2) := 0;
    v_min_ins_ded_amt     number(9, 2) := 0;
    v_fract_welfare_amt   number(9, 2) := 0;
    v_fract_ins_ded_amt   number(9, 2) := 0;
    v_income_tax          number(9, 2) := 0;
    V_total_ded           number(9, 2) := 0;
    v_total_sal           number(9, 2) := 0;
    v_gross_sal           number(9, 2) := 0;
    v_net_pay             number(9, 2) := 0;
    v_revinue             number(9, 2) := 0;
    v_sal_year            number := 0;
    v_month_code          number := 0;
    v_sal_month           varchar2(10) := '';
    v_care_fare           number(9, 2) := 0;
    v_others_alw          number(9, 2) := 0;
    v_education           number(9, 2) := 0;
    v_others_alw_remarks  varchar2(200) := '';
    v_others_ded          number(9, 2) := 0;
    v_others_ded_remarks  varchar2(200) := '';
    v_desig_catagory      char(1) := '';
  begin
    v_days_count := p_days_month;
    select upper(to_char(sysdate, 'Month')) into v_sal_month from dual;
    select to_number(to_char(to_date(sysdate, 'dd-mon-yy'), 'mm'))
      into v_month_code
      from dual;
    select to_number(to_char(sysdate, 'YYYY')) into v_sal_year from dual;
    ----------------delete current month salary for re-generating it.
  
    if p_manual_sal = 'C' then
      delete from prms_transaction t
       where t.entity_number = p_entity_num
         and t.sal_year = v_sal_year
         and t.month_code = v_month_code
         and t.emp_id = p_emp_id;
    else
    
      delete from prms_transaction t
       where t.entity_number = p_entity_num
         and t.sal_year = v_sal_year
         and t.month_code = v_month_code
         and t.emp_id = p_emp_id;
      for idx in (select * from prms_emp_sal s where s.emp_id = p_emp_id) loop
      
        select welfare,
               nvl(gen_insurance, 0),
               nvl(d.revenue, 0),
               nvl(d.income_tax, 0),
               nvl(d.car_fare, 0),
               nvl(d.other_deduc, 0),
               d.remarks
          into v_min_welfare_ded_amt,
               v_min_ins_ded_amt,
               v_revinue,
               v_income_tax,
               v_care_fare,
               v_others_ded,
               v_others_ded_remarks
          from prms_deduc d
         where d.emp_id = idx.emp_id;
      
        select nvl(d.other_allowance, 0),
               d.remarks,
               nvl(d.edu_allowance, 0)
          into v_others_alw, v_others_alw_remarks, v_education
          from prms_allowance d
         where d.emp_id = idx.emp_id;
      
        if idx.desig_code = '0' then
          v_min_welfare_ded_amt := 0;
          v_min_ins_ded_amt     := 0;
        elsif idx.desig_code = '1' then
          v_min_welfare_ded_amt := v_min_welfare_ded_amt;
          v_min_ins_ded_amt     := 0;
        else
          v_min_welfare_ded_amt := v_min_welfare_ded_amt;
          v_min_ins_ded_amt     := v_min_ins_ded_amt;
        end if;
      
        select d.designation_category
          into v_desig_catagory
          from prms_designation d
         where d.designation_code = idx.desig_code;
      
        if v_desig_catagory <> '1' then
          v_min_ins_ded_amt := 0;
        
        end if;
      
        select m.brn_type
          into v_bran_type
          from prms_mbranch m
         where m.brn_code = idx.emp_brn_code;
      
        v_fraction_basic   := round(idx.new_basic * (p_days / v_days_count),
                                    2);
        v_fraction_hr      := round(fn_get_hr_alwnc(v_bran_type,
                                                    nvl(idx.new_basic, 0),
                                                    nvl(idx.new_basic, 0)) *
                                    (p_days / v_days_count),
                                    2);
        v_fraction_medical := round(idx.medical_allowance *
                                    (p_days / v_days_count),
                                    2);
      
        if idx.sq_residence = 'Y' then
          v_fraction_hr := 0;
        
        end if;
      
        v_pf_deduction := round((v_fraction_basic * idx.pf_deduction_pct) / 100,
                                2);
        v_pension_ded  := round((v_fraction_basic * idx.pen_pct) / 100, 2);
      
        v_fract_welfare_amt := round(v_min_welfare_ded_amt *
                                     (p_days / v_days_count),
                                     2);
        v_fract_ins_ded_amt := round(v_min_ins_ded_amt *
                                     (p_days / v_days_count),
                                     2);
      
        v_education := round(v_education * (p_days / v_days_count), 2);
        v_total_sal := round(v_fraction_basic + v_fraction_hr +
                             v_fraction_medical + v_others_alw +
                             v_education,
                             2);
        v_gross_sal := round(v_total_sal + v_pension_ded, 2);
      
        V_total_ded := round(v_pf_deduction + v_fract_welfare_amt +
                             nvl(v_care_fare, 0) + nvl(v_others_ded, 0) +
                             v_fract_ins_ded_amt + v_revinue + v_income_tax,
                             2);
        v_net_pay   := round(v_total_sal - V_total_ded, 2);
      
        insert into prms_transaction
          (entity_number,
           branch_code,
           emp_id,
           sal_year,
           month_code,
           sal_month,
           basic_pay,
           medical_allowance,
           house_rent_allowance,
           tel_allowance,
           trans_allowance,
           edu_allowance,
           wash_allowance,
           pension_allowance,
           entertainment,
           domestic_allowance,
           other_allowance,
           gross_pay_amt,
           hbadv_deduc,
           mcycle_deduc,
           bicycle_deduc,
           pfadv_deduc,
           pension_deduc,
           revenue_deduc,
           welfare_deduc,
           carfare_deduc,
           caruse_deduc,
           gas_bill,
           water_bill,
           electricity_bill,
           house_rent_deduc,
           news_paper_deduc,
           pf_deduction,
           net_ded_amt,
           net_pay_amt,
           hbadv_arrear_deduc,
           pfadv_arrear_deduc,
           tel_excess_bill,
           gen_insurence,
           arrear,
           other_deduc,
           hbadv_deduc_percent,
           tot_sal_allowance,
           arrear_basic,
           comp_deduc,
           dearness_allowance,
           generated_by,
           generated_on,
           income_tax,
           income_tax_arr,
           hill_allwnc,
           actual_basic,
           deduction_remarks,
           allowance_remarks,
           manual_sal,
           desig_code,
           desig_seniority_code)
        values
          (p_entity_num,
           decode(idx.acc_no_active,
                  'S',
                  (select l.attached_branch
                     from prms_suspend_list l
                    where l.entity_num = p_entity_num
                      and l.emp_id = idx.emp_id
                      and l.suspend_sl =
                          (select max(l.suspend_sl)
                             from prms_suspend_list l
                            where l.entity_num = p_entity_num
                              and l.emp_id = idx.emp_id)),
                  idx.emp_brn_code),
           idx.emp_id,
           v_sal_year,
           v_month_code,
           v_sal_month,
           v_fraction_basic,
           v_fraction_medical,
           nvl(v_fraction_hr, 0),
           nvl(0, 0),
           nvl(0, 0),
           nvl(v_education, 0),
           nvl(0, 0),
           nvl(v_pension_ded, 0),
           nvl(0, 0),
           nvl(0, 0),
           nvl(v_others_alw, 0),
           v_gross_sal,
           nvl(0, 0),
           nvl(0, 0),
           nvl(0, 0),
           nvl(0, 0),
           nvl(v_pension_ded, 0),
           nvl(v_revinue, 0),
           nvl(v_fract_welfare_amt, 0),
           nvl(v_care_fare, 0),
           nvl(0, 0),
           nvl(0, 0),
           nvl(0, 0),
           nvl(0, 0),
           nvl(0, 0),
           nvl(0, 0),
           nvl(v_pf_deduction, 0),
           V_total_ded,
           v_net_pay,
           nvl(0, 0),
           nvl(0, 0),
           nvl(0, 0),
           nvl(v_fract_ins_ded_amt, 0),
           0, -----arear other 
           nvl(v_others_ded, 0),
           nvl(0, 0),
           v_total_sal,
           nvl(0, 0),
           nvl(0, 0),
           nvl(0, 0),
           p_user_id,
           trunc(sysdate),
           nvl(v_income_tax, 0),
           0,
           0,
           v_fraction_basic,
           v_others_ded_remarks,
           v_others_alw_remarks,
           'F',
           idx.desig_code,
           idx.desig_seniority_code);
      end loop;
    
    end if;
  
  exception
    when others then
      p_error_msg := 'Error in sp_fraction_salary_calculation > ' ||
                     sqlerrm;
  end sp_fraction_salary_calculation;

  procedure sp_salary_calculation_new(p_entity_num in number,
                                      p_user_id    in varchar2,
                                      p_salcode    in varchar2,
                                      p_error_msg  out varchar2) is
  
    v_basic_amt           number(9, 2) := 0;
    v_arearbasic_amt      number(9, 2) := 0;
    v_hr_alwnc_amt        number(9, 2) := 0;
    v_pension_allowance   number(9, 2) := 0;
    v_hbadv_deduc         number(9, 2) := 0;
    v_pf_ded_amt          number(9, 2) := 0;
    v_fraction_amt        number(5, 2) := 0;
    v_desig_catagory      number(2);
    v_min_welfare_ded_amt number(9, 2) := 0;
    v_min_ins_ded_amt     number(9, 2) := 0;
    v_cbd_last_date       date;
    v_cbd_last_day        number(2) := 0;
    t_lpr_date            date;
    t_lpr_day             number(2) := 0;
    v_exception exception;
    v_month_code number(2);
    v_sal_year   number(4);
    v_sal_month  varchar2(10) := '';
  
    v_med_alwnc_amt      number(9, 2) := 0;
    v_tel_alwnc_amt      number(9, 2) := 0;
    v_trans_allowance    number(9, 2) := 0;
    v_edu_allowance      number(9, 2) := 0;
    v_wash_allowance     number(9, 2) := 0;
    v_entertainment      number(9, 2) := 0;
    v_domestic_allowance number(9, 2) := 0;
    v_other_allowance    number(9, 2) := 0;
    v_dreaness_allwnc    number(9, 2) := 0;
    v_hill_allwnc        number(9, 2) := 0;
  
    v_mcycle_deduc        number(9, 2) := 0;
    v_bicycle_deduc       number(9, 2) := 0;
    v_pfadv_deduc         number(9, 2) := 0;
    v_hbadv_arrear_deduc  number(9, 2) := 0;
    v_pfadv_arrear_deduc  number(9, 2) := 0;
    v_tel_excess_bill     number(9, 2) := 0;
    v_other_deduc         number(9, 2) := 0;
    v_comp_deduc          number(9, 2) := 0;
    v_pension_deduc       number(9, 2) := 0;
    v_revenue_deduc       number(9, 2) := 0;
    v_carfare_deduc       number(9, 2) := 0;
    v_caruse_deduc        number(9, 2) := 0;
    v_hbadv_deduc_percent number(9, 2) := 0;
    v_gas_bill            number(9, 2) := 0;
    v_water_bill          number(9, 2) := 0;
    v_electricity_bill    number(9, 2) := 0;
    v_house_rent_deduc    number(9, 2) := 0;
    v_news_paper_deduc    number(9, 2) := 0;
    v_welfare_ded_amt     number(9, 2) := 0;
    v_ins_ded_amt         number(9, 2) := 0;
    v_income_tax          number(9, 2) := 0;
    v_income_tax_arr      number(9, 2) := 0;
    v_tot_sal_allowance   number(9, 2) := 0;
    v_gross_pay_amt       number(9, 2) := 0;
    v_net_pay_amt         number(9, 2) := 0;
    v_net_ded_amt         number(9, 2) := 0;
    v_ason_date           date := trunc(sysdate);
    v_remarks_allowance   varchar2(100) := '';
    v_remarks_deduction   varchar2(100) := '';
    v_hr_arrear_alw       number(9, 2) := 0;
    v_hr_arrear_ded       number(9, 2) := 0;
  
    procedure sp_sal_calc_incrmnt(p_emp_id    in varchar2,
                                  p_brn_type  in number,
                                  p_prl_days  in number,
                                  p_error_msg out varchar2) is
    
      v_prev_basic_total number(9, 2) := 0;
      v_prev_basic_amt   number(9, 2) := 0;
      v_curr_basic_amt   number(9, 2) := 0;
      v_days_count1      number(2) := 0;
      v_days_count2      number(2) := 0;
      v_days_count       number(2) := 0;
      v_hr_amt1          number(9, 2) := 0;
      v_hr_amt2          number(9, 2) := 0;
      v_brn_type         prms_mbranch.brn_type%type;
      v_sq_residence     varchar2(1) := '';
      v_pf_ded_amt1      number(9) := 0;
      v_pf_ded_amt2      number(9) := 0;
      v_pd_ded_pct       number(9, 2) := 0;
      v_pf_lien          prms_emp_sal.pf_lien%type;
      v_hbadv_ded        number(9, 2) := 0;
      v_pension_alln     number(9, 2) := 0;
      v_month_code       number(2);
      v_sal_year         number(4);
      v_ason_date        date := trunc(sysdate);
    
      w_hr_arrear_alw number(9, 2) := 0;
      w_hr_arrear_ded number(9, 2) := 0;
    begin
      for idx in (select * from prms_emp_sal s where s.emp_id = p_emp_id) loop
      
        if to_date(last_day(idx.transfer_date)) =
           last_day(trunc(v_ason_date)) then
          --transfer occured this month
          select extract(day from idx.transfer_date) - 1
            into v_days_count1
            from dual;
        
          select extract(day from last_day(trunc(v_ason_date)))
            into v_days_count
            from dual;
        
          if p_prl_days > v_days_count1 then
            v_days_count2 := p_prl_days - v_days_count1;
          else
            v_days_count2 := v_days_count - v_days_count1;
          end if;
          select nvl(h.new_basic, 0),
                 sq_residence,
                 (select m.brn_type
                    from prms_mbranch m
                   where m.brn_code = h.emp_brn_code) as brn_type,
                 h.pf_lien,
                 h.pf_deduction_pct
            into v_prev_basic_total,
                 v_sq_residence,
                 v_brn_type,
                 v_pf_lien,
                 v_pd_ded_pct
            from prms_emp_sal_hist h
           where h.emp_id = idx.emp_id
             and h.eft_serial =
                 (select max(h.eft_serial) - 1
                    from prms_emp_sal_hist h
                   where h.emp_id = idx.emp_id);
        
          v_prev_basic_amt := (v_prev_basic_total * v_days_count1) /
                              v_days_count;
          v_curr_basic_amt := ((idx.new_basic) * v_days_count2) /
                              v_days_count;
        
          v_hr_amt2 := fn_get_hr_alwnc(p_brn_type,
                                       nvl(idx.new_basic, 0),
                                       v_curr_basic_amt);
          v_hr_amt1 := fn_get_hr_alwnc(v_brn_type,
                                       v_prev_basic_total,
                                       v_prev_basic_amt);
        
          select nvl(d.hr_arear_ded, 0)
            into w_hr_arrear_ded
            from prms_deduc d
           where d.emp_id = idx.emp_id;
          select nvl(a.hr_arear_alw, 0)
            into w_hr_arrear_alw
            from prms_allowance a
           where a.emp_id = idx.emp_id;
        
          if idx.sq_residence = 'Y' then
            v_hr_amt2 := 0;
          end if;
        
          if v_sq_residence = 'Y' then
            v_hr_amt1 := 0;
          end if;
        
          if idx.pf_lien = 'N' then
            v_pf_ded_amt2 := 0;
            v_pf_ded_amt1 := 0;
          else
            v_pf_ded_amt1 := (v_prev_basic_amt * nvl(v_pd_ded_pct, 0) / 100);
            v_pf_ded_amt2 := ((v_curr_basic_amt + idx.arrear_basic) *
                             nvl(idx.pf_deduction_pct, 0) / 100);
          end if;
        
          select to_number(to_char(to_date(v_ason_date, 'dd-mon-yy'), 'mm'))
            into v_month_code
            from dual;
          select to_number(to_char(v_ason_date, 'YYYY'))
            into v_sal_year
            from dual;
          v_basic_amt      := v_prev_basic_amt + v_curr_basic_amt;
          v_arearbasic_amt := nvl(idx.arrear_basic, 0);
          v_hr_alwnc_amt   := v_hr_amt1 + v_hr_amt2 + w_hr_arrear_alw -
                              w_hr_arrear_ded;
        
          v_pension_alln := nvl(round((idx.pen_pct * v_basic_amt) / 100, 2),
                                0);
        
          select round(((d.hbadv_deduc_percent * v_hr_alwnc_amt) / 100), 2) +
                 nvl(d.hb_adv_deduc, 0)
            into v_hbadv_ded
            from prms_deduc d
           where d.emp_id = idx.emp_id;
        
          v_pension_allowance := v_pension_alln;
          v_pension_deduc     := v_pension_allowance;
          v_hbadv_deduc       := v_hbadv_ded;
          v_pf_ded_amt        := round((v_pf_ded_amt1 + v_pf_ded_amt2), 2);
        
          if idx.desig_code = '0' then
            v_hr_alwnc_amt      := 0;
            v_pension_allowance := 0;
            v_pension_deduc     := 0;
          end if;
        
        else
          --no transfer occured--
          select nvl(d.hr_arear_ded, 0)
            into w_hr_arrear_ded
            from prms_deduc d
           where d.emp_id = idx.emp_id;
          select nvl(a.hr_arear_alw, 0)
            into w_hr_arrear_alw
            from prms_allowance a
           where a.emp_id = idx.emp_id;
        
          v_basic_amt      := nvl(idx.new_basic, 0);
          v_arearbasic_amt := nvl(idx.arrear_basic, 0);
          --  v_arrar_basic:= nvl(idx.arrear_basic, 0) ;    
          -- v_arrar_basic:=nvl(idx.arrear_basic, 0);
          v_hr_alwnc_amt := fn_get_hr_alwnc(p_brn_type,
                                            idx.new_basic,
                                            idx.new_basic) +
                            w_hr_arrear_alw - w_hr_arrear_ded;
        
          select round(((d.hbadv_deduc_percent * (v_hr_alwnc_amt)) / 100),
                       2) + nvl(d.hb_adv_deduc, 0)
            into v_hbadv_deduc
            from prms_deduc d
           where d.emp_id = idx.emp_id;
        
          if idx.sq_residence <> 'Y' then
            null;
          else
            v_hr_alwnc_amt := 0;
          
          end if;
        
          if idx.acc_no_active = 'K' then
            v_hr_alwnc_amt := round(v_basic_amt * 0.45, 2);
          end if;
        
          if idx.acc_no_active = 'S' or idx.acc_no_active = 'K' then
            v_basic_amt := round(v_basic_amt * 0.5, 2);
          end if;
        
          begin
            select nvl(round((pen_pct * (v_basic_amt + v_arearbasic_amt)) / 100,
                             2),
                       0)
              into v_pension_allowance
              from prms_emp_sal
             where emp_id = idx.emp_id;
            v_pension_deduc := v_pension_allowance;
          end;
          if idx.desig_code = '0' then
            v_hr_alwnc_amt      := 0;
            v_pension_allowance := 0;
            v_pension_deduc     := 0;
          end if;
        
          if idx.pf_lien = 'N' then
            v_pf_ded_amt := 0;
          else
            v_pf_ded_amt := round((v_basic_amt + v_arearbasic_amt) *
                                  nvl(idx.pf_deduction_pct, 0) / 100,
                                  2);
          end if;
        end if;
      
      end loop;
    exception
      when others then
        p_error_msg := 'ERROR IN SP_SAL_CALC_INCRMNT: ' || sqlerrm;
    end sp_sal_calc_incrmnt;
  
  begin
    --- dbms_output.put_line('SALARY CALCULATED');
  
    select last_day(trunc(sysdate)) into v_cbd_last_date from dual;
    select extract(day from v_cbd_last_date) into v_cbd_last_day from dual;
  
    select upper(to_char(v_ason_date, 'Month')) into v_sal_month from dual;
    select to_number(to_char(to_date(v_ason_date, 'dd-mon-yy'), 'mm'))
      into v_month_code
      from dual;
    select to_number(to_char(v_ason_date, 'YYYY'))
      into v_sal_year
      from dual;
    ----------------delete current month salary for re-generating it.
    delete from prms_transaction t
     where t.entity_number = 1
       and t.sal_year = v_sal_year
       and t.month_code = v_month_code
       and t.manual_sal = 'P';
    ----------------delete current month salary for re-generating it.
  
    --main loop--
    for id in (select *
                 from prms_emp_sal s
                 join prms_mbranch b
                   on (s.emp_brn_code = b.brn_code)
                where trim(s.acc_no_active) <> 'N'
                     --  and s.emp_id <> '1396'
                  and (select prms_employee.dob
                         from prms_employee
                        where prms_employee.emp_id = s.emp_id) is not null) loop
    
      select welfare, gen_insurance
        into v_min_welfare_ded_amt, v_min_ins_ded_amt
        from prms_deduc d
       where d.emp_id = id.emp_id;
    
      if id.desig_code = '0' then
        v_min_welfare_ded_amt := 0;
        v_min_ins_ded_amt     := 0;
      elsif id.desig_code = '1' then
        v_min_welfare_ded_amt := 150;
        v_min_ins_ded_amt     := v_min_ins_ded_amt;
      elsif id.desig_code = '2' then
        v_min_welfare_ded_amt := 150;
        v_min_ins_ded_amt     := v_min_ins_ded_amt;
      else
        v_min_welfare_ded_amt := v_min_welfare_ded_amt;
        v_min_ins_ded_amt     := v_min_ins_ded_amt;
      end if;
      begin
        select add_months(dob, 60 * 12)
          into t_lpr_date
          from prms_employee
         where emp_id = id.emp_id;
      exception
        when no_data_found then
          t_lpr_date := '';
      end;
    
      ---alwoance
    
      v_med_alwnc_amt := id.medical_allowance;
    
      begin
        select a.tel_allowance,
               a.trans_allowance,
               a.edu_allowance,
               a.wash_allowance,
               a.domes_allowance,
               a.hill_allwnc,
               a.entertain_allowance,
               a.other_allowance,
               a.remarks,
               nvl(a.hr_arear_alw, 0)
          into v_tel_alwnc_amt,
               v_trans_allowance,
               v_edu_allowance,
               v_wash_allowance,
               v_domestic_allowance,
               v_hill_allwnc,
               v_entertainment,
               v_other_allowance,
               v_remarks_allowance,
               v_hr_arrear_alw
          from prms_allowance a
         where a.emp_id = id.emp_id;
      exception
        when no_data_found then
          dbms_output.put_line('NO ALLOWANCE DATA FOUND FOR THIS EMPLOYEE: ' ||
                               id.emp_id);
          --raise v_exception;
      end;
    
      if to_char(last_day(t_lpr_date)) = to_char(v_cbd_last_date) then
      
        select extract(day from t_lpr_date) - 1 into t_lpr_day from dual;
      
        sp_sal_calc_incrmnt(id.emp_id, id.brn_type, t_lpr_day, p_error_msg);
        /* v_min_welfare_ded_amt := (v_min_welfare_ded_amt * t_lpr_day) /
                                 v_cbd_last_day;
        v_min_ins_ded_amt     := (v_min_ins_ded_amt * t_lpr_day) /
                                 v_cbd_last_day;*/
        v_hr_alwnc_amt       := (v_hr_alwnc_amt * t_lpr_day) /
                                v_cbd_last_day;
        v_basic_amt          := (v_basic_amt * t_lpr_day) / v_cbd_last_day;
        v_med_alwnc_amt      := (v_med_alwnc_amt * t_lpr_day) /
                                v_cbd_last_day;
        v_trans_allowance    := (v_trans_allowance * t_lpr_day) /
                                v_cbd_last_day;
        v_edu_allowance      := (v_edu_allowance * t_lpr_day) /
                                v_cbd_last_day;
        v_wash_allowance     := (v_wash_allowance * t_lpr_day) /
                                v_cbd_last_day;
        v_domestic_allowance := (v_domestic_allowance * t_lpr_day) /
                                v_cbd_last_day;
        v_carfare_deduc      := (v_carfare_deduc * t_lpr_day) /
                                v_cbd_last_day;
        v_news_paper_deduc   := (v_news_paper_deduc * t_lpr_day) /
                                v_cbd_last_day;
      
        v_pension_allowance := (v_pension_allowance * t_lpr_day) /
                               v_cbd_last_day;
        v_pension_deduc     := v_pension_allowance;
        v_hbadv_deduc       := (v_hbadv_deduc * t_lpr_day) / v_cbd_last_day;
        v_pf_ded_amt        := round((v_pf_ded_amt * t_lpr_day) /
                                     v_cbd_last_day,
                                     0);
      
      else
        sp_sal_calc_incrmnt(id.emp_id, id.brn_type, 0, p_error_msg);
      end if;
    
      /*pf fraction issue*/
      v_fraction_amt := v_pf_ded_amt - trunc(v_pf_ded_amt, 0);
    
      if v_fraction_amt < 0.50 then
        v_pf_ded_amt := trunc(v_pf_ded_amt);
      else
        v_pf_ded_amt := trunc(v_pf_ded_amt) + 1.00;
      end if;
    
      -----------------------------------deduction------------------
      begin
        select d.mcycle_deduc,
               d.bcycle_deduc,
               d.pfadv_deduc,
               d.revenue,
               d.car_fare,
               d.car_use,
               d.gas_bill,
               d.water_bill,
               d.elect_bill,
               d.news_paper,
               d.hbadv_arrear,
               d.pfadv_arrear,
               d.tel_excess_bill,
               d.other_deduc,
               d.remarks,
               d.comp_deduc,
               d.hbadv_deduc_percent,
               d.income_tax,
               d.income_tax_arr,
               nvl(d.hr_arear_ded, 0)
          into v_mcycle_deduc,
               v_bicycle_deduc,
               v_pfadv_deduc,
               v_revenue_deduc,
               v_carfare_deduc,
               v_caruse_deduc,
               v_gas_bill,
               v_water_bill,
               v_electricity_bill,
               v_news_paper_deduc,
               v_hbadv_arrear_deduc,
               v_pfadv_arrear_deduc,
               v_tel_excess_bill,
               v_other_deduc,
               v_remarks_deduction,
               v_comp_deduc,
               v_hbadv_deduc_percent,
               v_income_tax,
               v_income_tax_arr,
               v_hr_arrear_ded
          from prms_deduc d
         where d.emp_id = id.emp_id;
      exception
        when no_data_found then
          dbms_output.put_line('NO DEDUCTION DATA FOUND FOR THIS EMPLOYEE: ' ||
                               id.emp_id);
          --raise v_exception;
      end;
    
      select d.designation_category
        into v_desig_catagory
        from prms_designation d
       where d.designation_code = id.desig_code;
    
      /* v_welfare_ded_amt := get_min_amt(round(v_basic_amt * 0.01, 2),
      v_min_welfare_ded_amt);*/
      v_welfare_ded_amt := v_min_welfare_ded_amt;
      if v_desig_catagory <> 1 then
        v_ins_ded_amt := 0;
      else
      
        /* v_ins_ded_amt := get_min_amt(round(v_basic_amt * 0.007, 2),
        v_min_ins_ded_amt);*/
        v_ins_ded_amt := v_min_ins_ded_amt;
      end if;
    
      if p_salcode = 'SPECIAL' then
        v_hbadv_deduc   := 0;
        v_mcycle_deduc  := 0;
        v_bicycle_deduc := 0;
        v_pfadv_deduc   := 0;
        v_comp_deduc    := 0;
      end if;
    
      --  v_hr_alwnc_amt := v_hr_alwnc_amt + v_hr_arrear_alw - v_hr_arrear_ded;
    
      v_tot_sal_allowance := nvl(v_basic_amt, 0) + nvl(v_arearbasic_amt, 0) +
                             nvl(v_med_alwnc_amt, 0) +
                             nvl(v_hr_alwnc_amt, 0) +
                             nvl(v_tel_alwnc_amt, 0) +
                             nvl(v_trans_allowance, 0) +
                             nvl(v_edu_allowance, 0) +
                             nvl(v_wash_allowance, 0) +
                             nvl(v_entertainment, 0) +
                             nvl(v_domestic_allowance, 0) +
                             nvl(v_other_allowance, 0) +
                             nvl(v_dreaness_allwnc, 0) +
                             nvl(v_hill_allwnc, 0);
    
      v_gross_pay_amt := v_tot_sal_allowance + v_pension_allowance;
    
      v_net_ded_amt := nvl(v_hbadv_deduc, 0) + nvl(v_mcycle_deduc, 0) +
                       nvl(v_bicycle_deduc, 0) + nvl(v_pfadv_deduc, 0) +
                       nvl(v_hbadv_arrear_deduc, 0) +
                       nvl(v_pfadv_arrear_deduc, 0) +
                       nvl(v_tel_excess_bill, 0) + nvl(v_other_deduc, 0) +
                       nvl(v_comp_deduc, 0) + nvl(v_revenue_deduc, 0) +
                       nvl(v_carfare_deduc, 0) + nvl(v_caruse_deduc, 0) +
                       nvl(v_gas_bill, 0) + nvl(v_water_bill, 0) +
                       nvl(v_electricity_bill, 0) +
                       nvl(v_house_rent_deduc, 0) +
                       nvl(v_news_paper_deduc, 0) +
                       nvl(v_welfare_ded_amt, 0) + nvl(v_ins_ded_amt, 0) +
                       nvl(v_pf_ded_amt, 0) + nvl(v_income_tax, 0) +
                       nvl(v_income_tax_arr, 0);
      v_net_pay_amt := v_tot_sal_allowance - v_net_ded_amt;
      ---------------------------insertion into transaction table-------------------------------
      insert into prms_transaction
        (entity_number,
         branch_code,
         emp_id,
         sal_year,
         month_code,
         sal_month,
         basic_pay,
         medical_allowance,
         house_rent_allowance,
         tel_allowance,
         trans_allowance,
         edu_allowance,
         wash_allowance,
         pension_allowance,
         entertainment,
         domestic_allowance,
         other_allowance,
         gross_pay_amt,
         hbadv_deduc,
         mcycle_deduc,
         bicycle_deduc,
         pfadv_deduc,
         pension_deduc,
         revenue_deduc,
         welfare_deduc,
         carfare_deduc,
         caruse_deduc,
         gas_bill,
         water_bill,
         electricity_bill,
         house_rent_deduc,
         news_paper_deduc,
         pf_deduction,
         net_ded_amt,
         net_pay_amt,
         hbadv_arrear_deduc,
         pfadv_arrear_deduc,
         tel_excess_bill,
         gen_insurence,
         /*sp_deduc,
         sp_description,
         tremarks,*/
         arrear,
         other_deduc,
         hbadv_deduc_percent,
         tot_sal_allowance,
         arrear_basic,
         /*  instl_amt_tlo,
         instl_amt_tlr,
         instl_amt_ins,
         instl_amt_inc,
         office_code,*/
         comp_deduc,
         dearness_allowance,
         generated_by,
         generated_on,
         income_tax,
         income_tax_arr,
         hill_allwnc,
         actual_basic,
         deduction_remarks,
         allowance_remarks,
         manual_sal,
         desig_code,
         desig_seniority_code)
      values
        (p_entity_num,
         decode(id.acc_no_active,
                'S',
                (select l.attached_branch
                   from prms_suspend_list l
                  where l.entity_num = p_entity_num
                    and l.emp_id = id.emp_id
                    and l.suspend_sl =
                        (select max(l.suspend_sl)
                           from prms_suspend_list l
                          where l.entity_num = p_entity_num
                            and l.emp_id = id.emp_id)),
                id.emp_brn_code),
         id.emp_id,
         v_sal_year,
         v_month_code,
         v_sal_month,
         v_basic_amt,
         v_med_alwnc_amt,
         nvl(v_hr_alwnc_amt, 0),
         nvl(v_tel_alwnc_amt, 0),
         nvl(v_trans_allowance, 0),
         nvl(v_edu_allowance, 0),
         nvl(v_wash_allowance, 0),
         nvl(v_pension_allowance, 0),
         nvl(v_entertainment, 0),
         nvl(v_domestic_allowance, 0),
         nvl(v_other_allowance, 0),
         v_gross_pay_amt,
         nvl(v_hbadv_deduc, 0),
         nvl(v_mcycle_deduc, 0),
         nvl(v_bicycle_deduc, 0),
         nvl(v_pfadv_deduc, 0),
         nvl(v_pension_deduc, 0),
         nvl(v_revenue_deduc, 0),
         nvl(v_welfare_ded_amt, 0),
         nvl(v_carfare_deduc, 0),
         nvl(v_caruse_deduc, 0),
         nvl(v_gas_bill, 0),
         nvl(v_water_bill, 0),
         nvl(v_electricity_bill, 0),
         nvl(v_house_rent_deduc, 0),
         nvl(v_news_paper_deduc, 0),
         nvl(v_pf_ded_amt, 0),
         v_net_ded_amt,
         v_net_pay_amt,
         nvl(v_hbadv_arrear_deduc, 0),
         nvl(v_pfadv_arrear_deduc, 0),
         nvl(v_tel_excess_bill, 0),
         nvl(v_ins_ded_amt, 0),
         0, -----arear other 
         nvl(v_other_deduc, 0),
         nvl(v_hbadv_deduc_percent, 0),
         v_tot_sal_allowance,
         nvl(v_arearbasic_amt, 0),
         nvl(v_comp_deduc, 0),
         nvl(v_dreaness_allwnc, 0),
         p_user_id,
         v_ason_date,
         nvl(v_income_tax, 0),
         nvl(v_income_tax_arr, 0),
         nvl(v_hill_allwnc, 0),
         v_basic_amt,
         v_remarks_deduction,
         v_remarks_allowance,
         'P',
         id.desig_code,
         id.desig_seniority_code);
      --exception when others
    
    end loop;
  
  exception
    when others then
      p_error_msg := 'ERROR IN SP_SALARY_CALCULATION: ' || sqlerrm;
      rollback;
  end sp_salary_calculation_new;

  procedure sp_emp_activation(p_emp_id          in varchar2,
                              p_activation_code in varchar2,
                              p_effect_date     in date,
                              p_attached_bran   in varchar2,
                              p_error           out varchar2) is
    v_sl number := '';
  begin
  
    if p_activation_code = 'N' or p_activation_code = 'Y' then
      update prms_emp_sal s
         set s.acc_no_active = p_activation_code
       where s.emp_id = p_emp_id;
    elsif p_activation_code = 'S' then
    
      update prms_emp_sal s
         set s.acc_no_active = p_activation_code
       where s.emp_id = p_emp_id;
    
      select nvl(max(l.suspend_sl), 0) + 1
        into v_sl
        from prms_suspend_list l
       where l.entity_num = 1
         and l.emp_id = p_emp_id;
      insert into prms_suspend_list
        (entity_num,
         emp_id,
         suspend_sl,
         suspend_date,
         suspend_branch,
         attached_branch,
         remarks)
      values
        (1,
         p_emp_id,
         v_sl,
         p_effect_date,
         (select s.emp_brn_code
            from prms_emp_sal s
           where s.emp_id = p_emp_id),
         p_attached_bran,
         '');
    elsif p_activation_code = 'T' then
      pkg_prms.SP_EMPLOYEE_UPDATION(p_emp_id,
                                    p_attached_bran,
                                    0,
                                    'NA',
                                    p_effect_date,
                                    p_error);
    elsif p_activation_code = 'QY' then
      update prms_emp_sal s
         set s.sq_residence = 'Y'
       where s.emp_id = p_emp_id;
    
    elsif p_activation_code = 'QN' then
      update prms_emp_sal s
         set s.sq_residence = 'N'
       where s.emp_id = p_emp_id;
    end if;
  exception
    when others then
      p_error := '';
  end sp_emp_activation;

  procedure sp_data_backup(p_entity_num in number,
                           p_entry_date in date,
                           p_error      out varchar2) is
    v_month_code number(2);
    v_sal_year   number(4);
  begin
  
    select to_number(to_char(to_date(p_entry_date, 'dd-mon-yy'), 'mm'))
      into v_month_code
      from dual;
    select to_number(to_char(p_entry_date, 'YYYY'))
      into v_sal_year
      from dual;
  
    delete from PRMS_TRANSACTION_HIST_data d
     where d.bk_date = p_entry_date;
    delete from prms_allowance_hist h where h.h_date = p_entry_date;
    delete from prms_deduc_hist h where h.h_date = p_entry_date;
  
    delete from prms_transaction_hist h
     where h.entity_number = p_entity_num
       and h.sal_year = v_sal_year
       and h.month_code = v_month_code;
  
    insert into prms_transaction_hist
      select *
        from prms_transaction p
       where p.sal_year = v_sal_year
         and p.month_code = v_month_code;
  
    insert into prms_transaction_hist_data
      select p_entry_date, p.*
        from prms_transaction p
       where p.sal_year = v_sal_year
         and p.month_code = v_month_code;
  
    insert into prms_allowance_hist
      select emp_id,
             p_entry_date,
             tel_allowance,
             trans_allowance,
             edu_allowance,
             wash_allowance,
             pension_allowance,
             entertain_allowance,
             domes_allowance,
             other_allowance,
             arrear,
             remarks,
             hill_allwnc,
             hr_arear_alw,
             p.enty_by,
             p.enty_on,
             p.mod_by,
             p.mod_on
        from prms_allowance p;
  
    insert into prms_deduc_hist
      select emp_id,
             p_entry_date,
             hb_adv_deduc,
             mcycle_deduc,
             pfadv_deduc,
             pension,
             revenue,
             welfare,
             car_fare,
             car_use,
             gas_bill,
             water_bill,
             elect_bill,
             house_rent,
             news_paper,
             hbadv_arrear,
             pfadv_arrear,
             tel_excess_bill,
             hbadv_deduc_percent,
             gen_insurance,
             bcycle_deduc,
             pf_deduction,
             other_deduc,
             comp_deduc,
             income_tax,
             income_tax_arr,
             remarks,
             hr_arear_ded,
             p.enty_by,
             p.enty_on,
             p.mod_by,
             p.mod_on
        from prms_deduc p;
  exception
    when others then
      p_error := 'Error in sp_data_backup :' || sqlerrm;
  end sp_data_backup;
  procedure sp_log_tracing(p_entity     in number,
                           p_user_id    in varchar2,
                           p_branch     in varchar2,
                           p_year       in number,
                           p_month_code in number,
                           p_message    in varchar2,
                           p_type       in varchar2,
                           p_error      out varchar2) is
  begin
    if p_type = 'RPT' then
      insert into rpt_logging
        (entity,
         user_id,
         branch_code,
         Year,
         month_code,
         message_type,
         messege_desc,
         enty_date)
      values
        (p_entity,
         p_user_id,
         p_branch,
         p_year,
         p_month_code,
         p_type,
         p_message,
         trunc(sysdate));
    end if;
  exception
    when others then
      p_error := 'Error in sp_log_tracing' || sqlerrm;
  end sp_log_tracing;
  procedure sp_init_values(p_msg out varchar2) is
  
    v_day_of_mon number := 0;
  begin
    select extract(day from sysdate) into v_day_of_mon from dual;
    --v_day_of_mon := 1;
    if (v_day_of_mon <= 9) then
    
      update prms_deduc d
         set car_use         = 0,
             elect_bill      = 0,
             hbadv_arrear    = 0,
             pfadv_arrear    = 0,
             tel_excess_bill = 0,
             d.hr_arear_ded  = 0,
             d.remarks       = '';
    
      update prms_emp_sal set arrear_basic = 0;
      update prms_allowance a
         set arrear            = 0,
             a.other_allowance = 0,
             a.hr_arear_alw    = 0,
             a.remarks         = '';
      p_msg := 'SUCCESS';
    else
      p_msg := 'EXPIRED';
    end if;
  
  exception
    when others then
      p_msg := 'Error in SP_INIT_VALUES ' || sqlerrm;
  end sp_init_values;

  procedure sp_employee_updation(p_emp_id         in varchar2,
                                 p_new_brn_code   in varchar2,
                                 p_new_basic      in number,
                                 p_new_desig_code in varchar2,
                                 p_effective_date in varchar2,
                                 p_msg            out varchar2) is
    v_max_sl         number(5) := 0;
    v_desig_desc     prms_designation.designation_desc%type;
    v_effective_date date;
    v_exist          number := 0;
  begin
  
    select to_date(p_effective_date /*to_date(p_effective_date, 'YYYY-MM-DD')*/,
                   'DD-Mon-YYYY')
      into v_effective_date
      from dual;
    ----------------------------updation------------------------
  
    if (p_new_brn_code <> 'NA') then
      update prms_emp_sal
         set emp_brn_code  = p_new_brn_code,
             transfer_date = v_effective_date
       where emp_id = p_emp_id;
    
      begin
        SELECT count(*)
          into v_exist
          FROM erp_user u
         where u.user_id = p_emp_id;
        if v_exist = 1 then
          update erp_user r
             set r.user_branch = p_new_brn_code
           where r.user_id = p_emp_id;
        end if;
      end;
    end if;
  
    if (nvl(p_new_basic, 0) > 0) then
      update prms_emp_sal
         set new_basic = p_new_basic
       where emp_id = p_emp_id;
    end if;
  
    if (p_new_desig_code <> 'NA') then
    
      select d.designation_desc
        into v_desig_desc
        from prms_designation d
       where d.designation_code = p_new_desig_code;
      update prms_emp_sal
         set prms_emp_sal.desig      = v_desig_desc,
             prms_emp_sal.desig_code = p_new_desig_code
       where emp_id = p_emp_id;
    end if;
  
    --w_query := 'UPDATE PRMS_EMP_SAL SET(' || w_update_col ||') WHERE EMP_ID = P_EMP_ID';
    -----------------insertion: into hist table-----------------
  
    select max(eft_serial) + 1
      into v_max_sl
      from prms_emp_sal_hist
     where emp_id = p_emp_id;
  
    begin
      insert into prms_emp_sal_hist
        (effective_date,
         eft_serial,
         emp_id,
         emp_brn_code,
         desig_code,
         desig,
         desig_seniority_code,
         status_code,
         pf_deduction_pct,
         medical_allowance,
         sq_residence,
         pf_lien,
         payment_bank,
         acc_no_active,
         emp_category,
         bank_acc,
         dearness_pct,
         pen_pct,
         arrear_basic,
         new_basic,
         bonus_yn,
         hbfc_own,
         entd_by,
         entd_on,
         mod_by,
         mod_on,
         transfer_date,
         emp_dept_code,
         Scale,
         Grade)
        select v_effective_date, v_max_sl, s.*
          from prms_emp_sal s
         where s.emp_id = p_emp_id;
    end;
  exception
    when others then
      p_msg := sqlerrm;
      rollback;
  end sp_employee_updation;
  procedure sp_new_employee_insertion(p_employee_id    in varchar2,
                                      p_employee_name  in varchar2,
                                      p_branch_code    in varchar2,
                                      p_designation    in varchar2,
                                      p_joining_date   in varchar2,
                                      p_dept_code      in varchar2,
                                      p_gender_type    in varchar2,
                                      p_blood_grp      in varchar2,
                                      p_rhfactor       in varchar2,
                                      p_dob            in varchar2,
                                      p_contact_no     in varchar2,
                                      p_tin            in varchar2,
                                      p_email          in varchar2,
                                      p_seniority_code in varchar2,
                                      p_address        in varchar2,
                                      p_entd_by        in varchar2,
                                      p_religion       in char,
                                      p_degree         in varchar2,
                                      p_home_dist      in varchar2,
                                      p_nid_no         in varchar2,
                                      p_msg            out varchar2) is
  
    v_exist  number(2) := 0;
    v_max_sl number(4) := 0;
  begin
  
    select nvl(count(e.emp_id), 0)
      into v_exist
      from prms_employee e
     where e.emp_id = p_employee_id;
  
    if v_exist = 0 then
      insert into prms_employee
        (emp_id,
         emp_name,
         joining_desig,
         joining_date,
         gender,
         blood_grp,
         rhfactor,
         tin_no,
         email,
         contact_no,
         dob,
         address,
         religion,
         entd_by,
         entd_on,
         mod_by,
         mod_on,
         highest_degree,
         home_district,
         nid)
      values
        (p_employee_id,
         p_employee_name,
         p_designation,
         to_date(p_joining_date, 'DD-Mon-YYYY'),
         p_gender_type,
         p_blood_grp,
         p_rhfactor,
         p_tin,
         lower(p_email),
         p_contact_no,
         to_date(p_dob, 'DD-Mon-YYYY'),
         p_address,
         p_religion,
         p_entd_by,
         sysdate,
         '',
         '',
         p_degree,
         p_home_dist,
         p_nid_no);
    
      insert into prms_emp_sal
        (emp_id,
         emp_brn_code,
         desig_code,
         desig,
         desig_seniority_code,
         acc_no_active,
         emp_category,
         new_basic,
         bonus_yn,
         entd_by,
         entd_on,
         mod_by,
         mod_on,
         -- transfer_date,
         emp_dept_code,
         medical_allowance,
         pen_pct,
         sq_residence)
      values
        (p_employee_id,
         p_branch_code,
         p_designation,
         (select prms_designation.designation_desc
            from prms_designation
           where prms_designation.designation_code = p_designation),
         p_seniority_code,
         'Y', --acc_no_active,
         (select prms_designation.designation_category
            from prms_designation
           where prms_designation.designation_code = p_designation), --emp_category,
         decode(p_designation,
                '41',
                22000,
                '42',
                22000,
                '43',
                22000,
                '50',
                16000,
                '51',
                16000), --new_basic,
         'Y', --bonus_yn,
         p_entd_by, --entd_by,
         sysdate, --entd_on,
         '', --mod_by,
         '', --mod_on,
         --   to_date(to_date(p_joining_date, 'YYYY-MM-DD'), 'DD-Mon-YYYY'), --transfer_date,
         p_dept_code, --emp_dept_code
         1500,
         55,
         'N');
      insert into prms_emp_sal_hist
        (emp_id,
         effective_date,
         eft_serial,
         emp_brn_code,
         desig_code,
         desig,
         desig_seniority_code,
         acc_no_active,
         emp_category,
         new_basic,
         bonus_yn,
         entd_by,
         entd_on,
         mod_by,
         mod_on,
         --  transfer_date,
         emp_dept_code,
         medical_allowance,
         pen_pct,
         sq_residence)
      values
        (p_employee_id,
         to_date(p_joining_date, 'DD-Mon-YYYY'),
         1,
         p_branch_code,
         p_designation,
         (select prms_designation.designation_desc
            from prms_designation
           where prms_designation.designation_code = p_designation),
         p_seniority_code,
         'Y', --acc_no_active,
         (select prms_designation.designation_category
            from prms_designation
           where prms_designation.designation_code = p_designation), --emp_category,
         decode(p_designation,
                '41',
                22000,
                '42',
                22000,
                '43',
                22000,
                '50',
                16000,
                '51',
                16000), --new_basic,
         'Y', --bonus_yn,
         p_entd_by, --entd_by,
         sysdate, --entd_on,
         '', --mod_by,
         '', --mod_on,
         --  to_date(to_date(p_joining_date, 'YYYY-MM-DD'), 'DD-Mon-YYYY'), --transfer_date,
         p_dept_code, --emp_dept_code
         1500,
         55,
         'N');
    
      insert into prms_allowance (emp_id) values (p_employee_id);
      insert into prms_deduc
        (emp_id, welfare, gen_insurance, revenue)
      values
        (p_employee_id, 50, 40, 10);
    else
      select nvl(max(h.eft_serial), 0)
        into v_max_sl
        from prms_emp_sal_hist h
       where h.emp_id = p_employee_id;
      update prms_employee
         set emp_name       = p_employee_name,
             joining_desig  = p_designation,
             joining_date   = to_date(p_joining_date, 'DD-Mon-YYYY'),
             gender         = p_gender_type,
             blood_grp      = p_blood_grp,
             rhfactor       = p_rhfactor,
             tin_no         = p_tin,
             email          = lower(p_email),
             contact_no     = p_contact_no,
             dob            = to_date(p_dob, 'DD-Mon-YYYY'),
             address        = p_address,
             religion       = p_religion,
             mod_by         = p_entd_by,
             mod_on         = sysdate,
             highest_degree = p_degree,
             home_district  = p_home_dist,
             nid            = p_nid_no
       where emp_id = p_employee_id;
    
      update prms_emp_sal s
         set emp_brn_code         = p_branch_code,
             desig_code           = p_designation,
             desig               =
             (select prms_designation.designation_desc
                from prms_designation
               where prms_designation.designation_code = p_designation),
             desig_seniority_code = p_seniority_code,
             emp_category        =
             (select prms_designation.designation_category
                from prms_designation
               where prms_designation.designation_code = p_designation),
             mod_by               = p_entd_by,
             mod_on               = sysdate,
             emp_dept_code        = p_dept_code
       where s.emp_id = p_employee_id;
    
      update prms_emp_sal_hist s
         set emp_brn_code         = p_branch_code,
             desig_code           = p_designation,
             desig               =
             (select prms_designation.designation_desc
                from prms_designation
               where prms_designation.designation_code = p_designation),
             desig_seniority_code = p_seniority_code,
             emp_category        =
             (select prms_designation.designation_category
                from prms_designation
               where prms_designation.designation_code = p_designation),
             mod_by               = p_entd_by,
             mod_on               = sysdate,
             emp_dept_code        = p_dept_code
       where s.emp_id = p_employee_id
         and s.eft_serial = v_max_sl;
    end if;
  
  exception
    when others then
      p_msg := sqlerrm;
      rollback;
  end sp_new_employee_insertion;

  procedure sp_bonus_cal(p_entity         in number,
                         p_user_id        in varchar2,
                         p_basic_year     in number,
                         p_basic_mon_code in number,
                         p_bonus_type     in varchar2,
                         p_bon_pct        in number,
                         p_bon_order_no   in varchar2,
                         p_msg            out varchar2) is
    v_bon_desc    varchar2(100) := 'Bonus For ';
    v_revenue     number(9, 2) := 10;
    v_basic_amt   number(9, 2) := 0;
    v_bon_amt     number(9, 2) := 0;
    v_net_bon_amt number(9, 2) := 0;
    v_month_code  number(2);
    v_sal_year    number(4);
    v_sal_month   varchar2(10) := '';
    v_ason_date   date := trunc(sysdate);
    v_emp_rel     char(1) := 'A';
  begin
    if p_bonus_type = 'EIDFT' then
      v_bon_desc := v_bon_desc || 'Eid-Ul-Fitr';
      v_emp_rel  := 'M';
    elsif p_bonus_type = 'EIDAH' then
      v_bon_desc := v_bon_desc || 'Eid-Ul-Adha';
      v_emp_rel  := 'M';
    elsif p_bonus_type = 'NEWYR' then
      v_bon_desc := v_bon_desc || 'Nabobarsho';
      -- v_emp_rel  := 'A';
    elsif p_bonus_type = 'DURGA' then
      v_bon_desc := v_bon_desc || 'Durga Puja';
      v_emp_rel  := 'H';
    elsif p_bonus_type = 'INCTV' then
      v_bon_desc := 'Incentive Bonus';
      --   v_emp_rel  := 'A';
    end if;
    select upper(to_char(v_ason_date, 'Month')) into v_sal_month from dual;
    select to_number(to_char(to_date(v_ason_date, 'dd-mon-yy'), 'mm'))
      into v_month_code
      from dual;
    select to_number(to_char(v_ason_date, 'YYYY'))
      into v_sal_year
      from dual;
    -----------------delete on modify-----------------
    delete from prms_bonus_transaction t
     where t.entity_num = p_entity
       and t.sal_year = v_sal_year
       and t.month_code = v_month_code
       and t.bonus_type = p_bonus_type;
    -----------------delete on modify-----------------
  
    if v_emp_rel <> 'A' then
      for id in (select s.*, religion, b.brn_code
                   from prms_emp_sal s
                   join prms_employee e
                     on (e.emp_id = s.emp_id)
                   join prms_mbranch b
                     on (s.emp_brn_code = b.brn_code)
                  where s.acc_no_active <> 'N'
                    and s.desig_code <> 0
                    and (select prms_employee.dob
                           from prms_employee
                          where prms_employee.emp_id = s.emp_id) is not null
                    and decode(e.religion, 'M', 'M', 'O', 'M', 'H') =
                        v_emp_rel) loop
      
        begin
          begin
            select nvl(t.incremented_basic, 0)
              into v_basic_amt
              from prms_transaction_manual t
             where t.entity_number = p_entity
               and t.emp_id = id.emp_id
               and t.sal_year = p_basic_year
               and t.month_code = p_basic_mon_code;
          exception
            when no_data_found then
              select nvl(t.basic_pay, 0)
                into v_basic_amt
                from prms_transaction t
               where t.entity_number = p_entity
                 and t.emp_id = id.emp_id
                 and t.sal_year = p_basic_year
                 and t.month_code = p_basic_mon_code;
          end;
        
          select c.revenue
            into v_revenue
            from prms_deduc c
           where c.emp_id = id.emp_id;
        
        exception
          when others then
            v_basic_amt := nvl(id.new_basic, 0);
        end;
      
        v_bon_amt := nvl(v_basic_amt, 0) *
                     round((nvl(p_bon_pct, 0) / 100), 2);
      
        /*
        if id.emp_id='1569' or id.emp_id='1589' then
           v_bon_amt     := nvl(v_basic_amt, 0) *
                          round((nvl(p_bon_pct/2, 0) / 100), 2);
        else
           v_bon_amt     := nvl(v_basic_amt, 0) *
                          round((nvl(p_bon_pct, 0) / 100), 2);
        end if;
        */
        v_net_bon_amt := nvl(v_bon_amt, 0) - nvl(v_revenue, 0);
      
        insert into prms_bonus_transaction
          (entity_num,
           branch_code,
           emp_id,
           sal_year,
           month_code,
           sal_month,
           bonus_type,
           bonus_description,
           revenue,
           religion,
           bonus_order_no,
           basic_amt,
           bonus_amount,
           net_bon_amt,
           entd_by,
           entd_on)
        values
          (p_entity,
           decode(id.acc_no_active,
                  'S',
                  (select l.attached_branch
                     from prms_suspend_list l
                    where l.entity_num = p_entity
                      and l.emp_id = id.emp_id
                      and l.suspend_sl =
                          (select max(l.suspend_sl)
                             from prms_suspend_list l
                            where l.entity_num = p_entity
                              and l.emp_id = id.emp_id)),
                  id.emp_brn_code),
           id.emp_id,
           v_sal_year,
           v_month_code,
           v_sal_month,
           p_bonus_type,
           v_bon_desc,
           v_revenue,
           (select religion from prms_employee e where e.emp_id = id.emp_id),
           p_bon_order_no,
           v_basic_amt,
           v_bon_amt,
           v_net_bon_amt,
           p_user_id,
           sysdate);
      end loop;
    else
      for id in (select s.*, e.religion, b.brn_code
                   from prms_emp_sal s
                   join prms_employee e
                     on (e.emp_id = s.emp_id)
                   join prms_mbranch b
                     on (s.emp_brn_code = b.brn_code)
                  where s.acc_no_active <> 'N'
                    and s.desig_code <> 0
                    and (select prms_employee.dob
                           from prms_employee
                          where prms_employee.emp_id = s.emp_id) is not null) loop
      
        begin
          begin
            select nvl(t.incremented_basic, 0)
              into v_basic_amt
              from prms_transaction_manual t
             where t.entity_number = p_entity
               and t.emp_id = id.emp_id
               and t.sal_year = p_basic_year
               and t.month_code = p_basic_mon_code;
          exception
            when no_data_found then
              select nvl(t.basic_pay, 0)
                into v_basic_amt
                from prms_transaction t
               where t.entity_number = p_entity
                 and t.emp_id = id.emp_id
                 and t.sal_year = p_basic_year
                 and t.month_code = p_basic_mon_code;
          end;
        
          select c.revenue
            into v_revenue
            from prms_deduc c
           where c.emp_id = id.emp_id;
        
        exception
          when others then
            v_basic_amt := nvl(id.new_basic, 0);
        end;
      
        --  v_basic_amt   := nvl(id.new_basic, 0);
        v_bon_amt := nvl(v_basic_amt, 0) *
                     round((nvl(p_bon_pct, 0) / 100), 2);
      
        v_net_bon_amt := nvl(v_bon_amt, 0) - nvl(v_revenue, 0);
      
        insert into prms_bonus_transaction
          (entity_num,
           branch_code,
           emp_id,
           sal_year,
           month_code,
           sal_month,
           bonus_type,
           bonus_description,
           revenue,
           religion,
           bonus_order_no,
           basic_amt,
           bonus_amount,
           net_bon_amt,
           entd_by,
           entd_on)
        values
          (p_entity,
           decode(id.acc_no_active,
                  'S',
                  (select l.attached_branch
                     from prms_suspend_list l
                    where l.entity_num = p_entity
                      and l.emp_id = id.emp_id
                      and l.suspend_sl =
                          (select max(l.suspend_sl)
                             from prms_suspend_list l
                            where l.entity_num = p_entity
                              and l.emp_id = id.emp_id)),
                  id.emp_brn_code),
           id.emp_id,
           v_sal_year,
           v_month_code,
           v_sal_month,
           p_bonus_type,
           v_bon_desc,
           v_revenue,
           (select religion from prms_employee e where e.emp_id = id.emp_id),
           p_bon_order_no,
           v_basic_amt,
           v_bon_amt,
           v_net_bon_amt,
           p_user_id,
           sysdate);
      end loop;
    end if;
  exception
    when others then
      rollback;
      p_msg := sqlerrm;
  end sp_bonus_cal;
  function fn_manual_sal_data(p_entity_number in number,
                              p_branch_code   in varchar2,
                              p_emp_id        in varchar2,
                              p_year          in number,
                              p_month_code    in number) return number is
    v_arear_basic number := 0;
  begin
  
    begin
      select nvl(b.arrear_basic, 0)
        into v_arear_basic
        from prms_transaction_manual b
       where entity_number = p_entity_number
         and branch_code = p_branch_code
         and b.sal_year = p_year
         and b.emp_id = p_emp_id
         and b.month_code = p_month_code;
    
    exception
      when no_data_found then
        v_arear_basic := 0;
    end;
  
    return v_arear_basic;
  end fn_manual_sal_data;

  function fn_manual_sal_data_pf(p_entity_number in number,
                                 p_branch_code   in varchar2,
                                 p_emp_id        in varchar2,
                                 p_year          in number,
                                 p_month_code    in number) return number is
    v_pf_arear number := 0;
  begin
  
    begin
      select nvl(b.pf_deduction, 0)
        into v_pf_arear
        from prms_transaction_manual b
       where entity_number = p_entity_number
         and branch_code = p_branch_code
         and b.sal_year = p_year
         and b.emp_id = p_emp_id
         and b.month_code = p_month_code;
    
    exception
      when no_data_found then
        v_pf_arear := 0;
    end;
  
    return v_pf_arear;
  end fn_manual_sal_data_pf;

  function fn_tax_stmt_data(p_entity_number in number,
                            p_branch_code   in varchar2,
                            p_year1         in varchar2) return v_data
    pipelined is
    v_tax_data       tax_data;
    v_branch_code    varchar2(5);
    v_designation    prms_emp_sal.desig%type;
    v_emp_name       prms_employee.emp_name%type;
    v_month_year     varchar(10);
    v_sal_year       prms_transaction.sal_year%type;
    v_month_code     number(2);
    v_basic_pay      number(9, 2);
    v_dom_allowance  number(9, 2);
    v_entertainment  number(9, 2);
    v_med_allowance  number(9, 2);
    v_hr_allowance   number(9, 2);
    v_edu_allowance  number(9, 2);
    v_pf_deduction   number(9, 2);
    v_welfare_deduc  number(9, 2);
    v_income_tax     number(9, 2);
    v_tel_allowance  number(9, 2);
    v_drns_allowance number(9, 2);
    v_gen_insurence  number(9, 2);
    v_festival_bonus number(9, 2);
  
  begin
    for idx in (select s.emp_id
                  from prms_emp_sal s
                 where s.emp_brn_code = p_branch_code) loop
      begin
        select (select s.desig
                  from prms_emp_sal s
                 where s.emp_id = idx.emp_id) designation,
               (select e.emp_name
                  from prms_employee e
                 where e.emp_id = idx.emp_id) emp_name,
               substr(t.sal_month, 1, 3) || '-' || t.sal_year month_year,
               t.sal_year,
               t.month_code,
               nvl(t.basic_pay + t.arrear_basic, 0) basic_pay,
               nvl(t.domestic_allowance, 0) domestic_allowance,
               nvl(t.entertainment, 0) entertainment,
               nvl(t.medical_allowance, 0) medical_allowance,
               nvl(t.house_rent_allowance, 0) house_rent_allowance,
               nvl(t.edu_allowance, 0) edu_allowance,
               nvl(t.pf_deduction, 0) pf_deduction,
               nvl(t.welfare_deduc, 0) welfare_deduc,
               nvl(t.income_tax + t.income_tax_arr, 0) income_tax,
               nvl(t.tel_allowance, 0) tel_allowance,
               nvl(t.dearness_allowance, 0) dearness_allowance,
               nvl(t.gen_insurence, 0) gen_insurence
          into v_designation,
               v_emp_name,
               v_month_year,
               v_sal_year,
               v_month_code,
               v_basic_pay,
               v_dom_allowance,
               v_entertainment,
               v_med_allowance,
               v_hr_allowance,
               v_edu_allowance,
               v_pf_deduction,
               v_welfare_deduc,
               v_income_tax,
               v_tel_allowance,
               v_drns_allowance,
               v_gen_insurence
          from prms_transaction t
         where t.entity_number = p_entity_number
           and t.emp_id = idx.emp_id
           and t.sal_year = p_year1
           and t.month_code > 6;
      end;
    
      select nvl(b.bonus_amount, 0), b.month_code
        into v_festival_bonus, v_month_code
        from prms_bonus_transaction b
       where b.entity_num = 1
         and b.branch_code = p_branch_code
         and b.bonus_type in ('EIDFT', 'EIDAH', 'DURGA')
         and b.emp_id = idx.emp_id;
    
      v_tax_data.branch_code    := v_branch_code;
      v_tax_data.emp_id         := idx.emp_id;
      v_tax_data.designation    := v_designation;
      v_tax_data.emp_name       := v_emp_name;
      v_tax_data.month_year     := v_month_year;
      v_tax_data.sal_year       := v_sal_year;
      v_tax_data.month_code     := v_month_year;
      v_tax_data.basic_pay      := v_basic_pay;
      v_tax_data.dom_allowance  := v_dom_allowance;
      v_tax_data.entertainment  := v_entertainment;
      v_tax_data.med_allowance  := v_med_allowance;
      v_tax_data.hr_allowance   := v_hr_allowance;
      v_tax_data.edu_allowance  := v_edu_allowance;
      v_tax_data.pf_deduction   := v_pf_deduction;
      v_tax_data.welfare_deduc  := v_welfare_deduc;
      v_tax_data.income_tax     := v_income_tax;
      v_tax_data.tel_allowance  := v_tel_allowance;
      v_tax_data.drns_allowance := v_drns_allowance;
      v_tax_data.gen_insurence  := v_gen_insurence;
      v_tax_data.festival_bonus := v_festival_bonus;
      pipe row(v_tax_data);
    end loop;
  end fn_tax_stmt_data;

begin
  NULL;
end pkg_prms;
/
