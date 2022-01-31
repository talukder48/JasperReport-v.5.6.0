CREATE OR REPLACE PACKAGE PKG_ELMS IS
  -- AUTHOR  : RUBEL & MOSHARRAF
  -- CREATED : 08-MAY-19 2:44:59 PM
  -- PURPOSE : EMPLOYEE LOAN MANAGEMENT
  PROCEDURE SP_LOAN_REALIZATION(P_ENTITY_NUM   IN NUMBER,
                                P_EMP_ID       IN VARCHAR2,
                                P_LOAN_TYPE    IN VARCHAR2,
                                P_YEAR         IN NUMBER,
                                P_MONTH_CODE   IN NUMBER,
                                P_REAL_DATE    IN DATE,
                                P_REAL_TYPE    IN CHAR,
                                P_DR_CR_TYPE   IN CHAR,
                                P_VOUCHAR_TYPE IN CHAR,
                                P_REAL_AMOUNT  IN NUMBER,
                                P_ENTD_BY      IN VARCHAR2,
                                P_ERROR        OUT VARCHAR2);

  PROCEDURE SP_DISBURSE_LOAN(P_ENTITY_NUM IN NUMBER,
                             P_EMP_ID     IN VARCHAR2,
                             P_LOAN_TYPE  IN VARCHAR2,
                             P_DISB_DATE  IN DATE,
                             P_DISB_AMT   IN NUMBER,
                             P_INT_RATE   IN NUMBER,
                             P_ENTD_BY    IN VARCHAR2,
                             P_ERROR      OUT VARCHAR2);
  PROCEDURE SP_ACCRUAL_PROCESS(P_ENTITY_NUM IN NUMBER,
                               P_YEAR       IN NUMBER,
                               P_MONTH_CODE IN NUMBER,
                               P_LOAN_TYPE  IN VARCHAR2,
                               P_ERROR      OUT VARCHAR2);
  PROCEDURE SP_LOAN_REAL_FROM_SALARY_OLD(P_ENTITY_NUM IN NUMBER,
                                         P_YEAR       IN NUMBER,
                                         P_MONTH_CODE IN NUMBER,
                                         P_REAL_DATE  IN DATE,
                                         P_ENTY_BY    IN VARCHAR2,
                                         P_ERROR      OUT VARCHAR2);
  PROCEDURE SP_LOAN_REAL_FROM_SALARY(P_ENTITY_NUM IN NUMBER,
                                     P_YEAR       IN NUMBER,
                                     P_MONTH_CODE IN NUMBER,
                                     P_TYPE       IN VARCHAR2,
                                     P_REAL_DATE  IN DATE,
                                     P_ENTY_BY    IN VARCHAR2,
                                     P_ERROR      OUT VARCHAR2);
  PROCEDURE SP_LOAN_REAL_BY_MANUAL(P_ENTITY_NUM   IN NUMBER,
                                   P_EMP_ID       IN VARCHAR2,
                                   P_LOAN_TYPE    IN VARCHAR2,
                                   P_REAL_TYPE    IN CHAR,
                                   P_DRCR_TYPE    IN CHAR,
                                   P_VOUCHER_TYPE IN CHAR,
                                   P_REAL_DATE    IN DATE,
                                   P_REAL_AMT     IN NUMBER,
                                   P_ENTD_BY      IN VARCHAR2,
                                   P_ERROR        OUT VARCHAR2);

  TYPE DATA IS RECORD(
    FIN_YEAR      VARCHAR2(10),
    DISBURSE_AMT  NUMBER(13, 2),
    DESIGNATION   VARCHAR2(40),
    INTEREST_RATE NUMBER(5, 2),
    EMPLOYEE_ID   VARCHAR2(20),
    YEAR          NUMBER(4),
    MONTH_CODE    NUMBER(2),
    MONTH_NAME    VARCHAR2(15),
    REAL_DATE     DATE,
    REAL_TYPE     CHAR(1),
    DR_CR_TYPE    CHAR(1),
    VOUCHAR_TYPE  CHAR(1),
    REAL_AMT      NUMBER(13, 2),
    PRIN_BAL      NUMBER(13, 2),
    INT_CHARGED   NUMBER(13, 2),
    INT_BAL       NUMBER(13, 2),
    TOT_BAL       NUMBER(13, 2));
  TYPE V_DATA IS TABLE OF DATA;
  FUNCTION FN_LOAN_DATA(P_ENTITY      IN NUMBER,
                        P_BRANCH_CODE IN VARCHAR2,
                        P_EMP_ID      IN VARCHAR2,
                        P_LOAN_TYPE   IN VARCHAR2,
                        P_FIN_YEAR    IN VARCHAR2,
                        P_TO_DATE     IN DATE) RETURN V_DATA
    PIPELINED;
  PROCEDURE SP_PF_PROCESS(P_ENTITY_NUM IN NUMBER,
                          P_YEAR       IN NUMBER,
                          P_MONTH_CODE IN NUMBER,
                          P_ERROR      OUT VARCHAR2);
   procedure sp_accrual_process_new(p_entity_num in number,
                               p_year       in number,
                               p_month_code in number,
                               p_loan_type  in varchar2,
                               p_error      out varchar2);                        
END PKG_ELMS;
/
CREATE OR REPLACE PACKAGE BODY PKG_ELMS IS
  PROCEDURE SP_DISBURSE_LOAN(P_ENTITY_NUM IN NUMBER,
                             P_EMP_ID     IN VARCHAR2,
                             P_LOAN_TYPE  IN VARCHAR2,
                             P_DISB_DATE  IN DATE,
                             P_DISB_AMT   IN NUMBER,
                             P_INT_RATE   IN NUMBER,
                             P_ENTD_BY    IN VARCHAR2,
                             P_ERROR      OUT VARCHAR2) IS
  
    V_DISB_SL          NUMBER(2) := 0;
    V_CURR_DISB_AMT    NUMBER(2) := 0;
    V_FIRST_REPAY_DATE DATE NULL;
    V_LOAN_TYPE        VARCHAR2(3) := '';
    V_MONTH_CODE       NUMBER(2);
    V_YEAR             NUMBER(4);
    V_SL               NUMBER(4) := 0;
  
  BEGIN
  
    SELECT DECODE(P_LOAN_TYPE, '1', 'HBL', '2', 'COM', '3', 'MOT')
      INTO V_LOAN_TYPE
      FROM DUAL;
  
    SELECT TO_NUMBER(TO_CHAR(TO_DATE(P_DISB_DATE, 'dd-mon-yy'), 'mm'))
      INTO V_MONTH_CODE
      FROM DUAL;
    SELECT TO_NUMBER(TO_CHAR(P_DISB_DATE, 'YYYY')) INTO V_YEAR FROM DUAL;
  
    BEGIN
      IF P_LOAN_TYPE = 'HBL' THEN
        SELECT TO_CHAR(ADD_MONTHS(P_DISB_DATE, 19), 'DD-MON-YYYY')
          INTO V_FIRST_REPAY_DATE
          FROM DUAL;
      ELSE
        SELECT TO_CHAR(ADD_MONTHS(P_DISB_DATE, 2), 'DD-MON-YYYY')
          INTO V_FIRST_REPAY_DATE
          FROM DUAL;
      END IF;
    
      SELECT NVL(MAX(D.DISB_SL), 0) + 1
        INTO V_DISB_SL
        FROM ELMS_DISBURSE D
       WHERE D.ENTITY_NUM = P_ENTITY_NUM
         AND D.EMP_ID = P_EMP_ID
         AND D.LOAN_TYPE = P_LOAN_TYPE;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        V_DISB_SL := 1;
    END;
  
    INSERT INTO ELMS_DISBURSE
      (ENTITY_NUM,
       EMP_ID,
       LOAN_TYPE,
       DISB_SL,
       DISB_DATE,
       DISB_AMOUNT,
       INT_RATE,
       FIRST_REPAY_DATE,
       CURR_DISB_AMT,
       ENTD_BY,
       ENTD_ON)
    VALUES
      (P_ENTITY_NUM,
       P_EMP_ID,
       V_LOAN_TYPE,
       V_DISB_SL,
       P_DISB_DATE, --TO_DATE(P_DISB_DATE, 'DD-Mon-YYYY'),
       P_DISB_AMT,
       P_INT_RATE,
       V_FIRST_REPAY_DATE,
       V_CURR_DISB_AMT,
       P_ENTD_BY,
       TRUNC(SYSDATE));
  
    SELECT NVL(MAX(R.REL_SL), 0) + 1
      INTO V_SL
      FROM ELMS_REALIZATION R
     WHERE R.ENTITY_NUM = P_ENTITY_NUM
       AND R.EMP_ID = P_EMP_ID
       AND R.LOAN_TYPE = V_LOAN_TYPE
       AND R.REAL_YEAR = V_YEAR
       AND R.REAL_MONTH_CODE = V_MONTH_CODE;
  
    INSERT INTO ELMS_REALIZATION
      (ENTITY_NUM,
       EMP_ID,
       LOAN_TYPE,
       REAL_YEAR,
       REAL_MONTH_CODE,
       REL_SL,
       REAL_DATE,
       REAL_TYPE,
       DR_CR_TYPE,
       VOUCHAR_TYPE,
       REAL_AMOUNT,
       ENTD_BY,
       ENTD_ON)
    VALUES
      (P_ENTITY_NUM,
       P_EMP_ID,
       V_LOAN_TYPE,
       V_YEAR,
       V_MONTH_CODE,
       V_SL,
       P_DISB_DATE,
       'P',
       'D',
       'D',
       P_DISB_AMT,
       P_ENTD_BY,
       TRUNC(SYSDATE));
  
    /* IF V_DISB_SL > 1 THEN
        INSERT INTO ELMS_LN_LEDGER
          (ENTITY_NUM,
           EMP_ID,
           LOAN_TYPE,
           REAL_YEAR,
           REAL_MONTH_CODE,
           REL_SL,
           REAL_DATE,
           REAL_TYPE,
           DR_CR_TYPE,
           VOUCHAR_TYPE,
           REAL_AMOUNT,
           PRIN_BALANCE,
           INT_CHARGED,
           INT_BALANCE,
           TOT_BALANCE,
           ENTD_BY,
           ENTD_ON)
        VALUES
          (P_ENTITY_NUM,
           P_EMP_ID,
           V_LOAN_TYPE,
           V_YEAR,
           V_MONTH_CODE,
           V_SL,
           P_DISB_DATE,
           'P',
           'D',
           'D',
           P_DISB_AMT,
           P_DISB_AMT,
           0,
           0,
           P_DISB_AMT,
           P_ENTD_BY,
           TRUNC(SYSDATE));
      END IF;
    */
  
  EXCEPTION
    WHEN OTHERS THEN
      P_ERROR := 'ERROR IN SP_SAVE_LOAN_DATA ' || SQLERRM;
  END SP_DISBURSE_LOAN;
PROCEDURE SP_PF_REALIZATION(P_ENTITY_NUM      IN NUMBER,
                            P_EMP_ID          IN VARCHAR2,
                            P_YEAR            IN NUMBER,
                            P_MONTH_CODE      IN NUMBER,
                            P_PF_CONT_AMT     IN NUMBER,
                            P_ADV_REAL_TYPE   IN VARCHAR2,
                            P_ADV_CR_AMT      IN NUMBER,
                            P_ADV_DR_AMT      IN NUMBER,
                            P_ADV_INSTALLMENT IN NUMBER,
                            P_VOUCHER_TYPE    IN VARCHAR2,
                            P_VOU_DR_AMT      IN NUMBER,
                            P_VOU_CR_AMT      IN NUMBER,
                            P_ERROR           OUT VARCHAR2) IS
  V_CHECK_EXIST NUMBER := 0;
BEGIN

  BEGIN
    SELECT NVL(COUNT(R.ENTITY_NUM), 0)
      INTO V_CHECK_EXIST
      FROM ELMS_PF_REALIZATION R
     WHERE R.ENTITY_NUM = P_ENTITY_NUM
       AND R.EMP_ID = P_EMP_ID
       AND R.REAL_YEAR = P_YEAR
       AND R.REAL_MONTH_CODE = P_MONTH_CODE;
  END;
  IF V_CHECK_EXIST > 0 THEN
    UPDATE ELMS_PF_REALIZATION X
       SET X.PF_ADV_CR_AMT = P_ADV_DR_AMT,
           X.PF_REAL_TYPE  = P_ADV_REAL_TYPE,
           X.VOUCHER_TYPE  = P_VOUCHER_TYPE,
           X.VOUCHER_DR    = P_VOU_DR_AMT,
           X.VOUCHER_CR    = P_VOU_CR_AMT
     WHERE X.ENTITY_NUM = P_ENTITY_NUM
       AND X.EMP_ID = P_EMP_ID
       AND X.REAL_YEAR = P_YEAR
       AND X.REAL_MONTH_CODE = P_MONTH_CODE;
  ELSE
    INSERT INTO ELMS_PF_REALIZATION
      (ENTITY_NUM,
       EMP_ID,
       REAL_YEAR,
       REAL_MONTH_CODE,
       REL_SL,
       PF_CONTRIBUTION_AMT,
       PF_ADVANCE_REAL_AMT,
       PF_REAL_TYPE,
       PF_ADV_DR_AMT,
       PF_ADV_CR_AMT,
       VOUCHER_TYPE,
       VOUCHER_DR,
       VOUCHER_CR)
    VALUES
      (P_ENTITY_NUM,
       P_EMP_ID,
       P_YEAR,
       P_MONTH_CODE,
       '1',
       P_PF_CONT_AMT,
       P_ADV_CR_AMT,
       '',
       P_ADV_DR_AMT,
       P_ADV_CR_AMT,
       P_VOUCHER_TYPE,
       P_VOU_DR_AMT,
       P_VOU_CR_AMT);
  
    IF NVL(P_ADV_DR_AMT, 0) > 0 THEN
    
      INSERT INTO ELMS_PF_ADVANCE
        (entity_num,
         emp_id,
         pf_adv_year,
         pf_adv_month_code,
         pf_adv_sl,
         pf_adv_amt,
         pf_adv_ins,
         enty_by,
         enty_on)
      VALUES
        (P_ENTITY_NUM,
         P_EMP_ID,
         P_YEAR,
         P_MONTH_CODE,
         '1',
         P_ADV_DR_AMT,
         P_ADV_INSTALLMENT,
         '',
         TRUNC(SYSDATE));
    
    END IF;
  
  END IF;

END SP_PF_REALIZATION;
  PROCEDURE SP_LOAN_REALIZATION(P_ENTITY_NUM   IN NUMBER,
                                P_EMP_ID       IN VARCHAR2,
                                P_LOAN_TYPE    IN VARCHAR2,
                                P_YEAR         IN NUMBER,
                                P_MONTH_CODE   IN NUMBER,
                                P_REAL_DATE    IN DATE,
                                P_REAL_TYPE    IN CHAR,
                                P_DR_CR_TYPE   IN CHAR,
                                P_VOUCHAR_TYPE IN CHAR,
                                P_REAL_AMOUNT  IN NUMBER,
                                P_ENTD_BY      IN VARCHAR2,
                                P_ERROR        OUT VARCHAR2) IS
    V_SL NUMBER(4) := 0;
  BEGIN
  
    SELECT NVL(MAX(R.REL_SL), 0) + 1
      INTO V_SL
      FROM ELMS_REALIZATION R
     WHERE R.ENTITY_NUM = P_ENTITY_NUM
       AND R.EMP_ID = P_EMP_ID
       AND R.LOAN_TYPE = P_LOAN_TYPE
       AND R.REAL_YEAR = P_YEAR
       AND R.REAL_MONTH_CODE = P_MONTH_CODE;
  
    INSERT INTO ELMS_REALIZATION T
      (ENTITY_NUM,
       EMP_ID,
       LOAN_TYPE,
       REAL_YEAR,
       REAL_MONTH_CODE,
       REL_SL,
       REAL_DATE,
       REAL_TYPE,
       DR_CR_TYPE,
       VOUCHAR_TYPE,
       REAL_AMOUNT,
       ENTD_BY,
       ENTD_ON)
    VALUES
      (P_ENTITY_NUM,
       P_EMP_ID,
       P_LOAN_TYPE,
       P_YEAR,
       P_MONTH_CODE,
       V_SL,
       P_REAL_DATE,
       P_REAL_TYPE,
       P_DR_CR_TYPE,
       P_VOUCHAR_TYPE,
       P_REAL_AMOUNT,
       P_ENTD_BY,
       TRUNC(SYSDATE));
  EXCEPTION
    WHEN OTHERS THEN
      P_ERROR := 'ERROR IN SP_LOAN_DATA_INSERTION ' || SQLERRM;
  END SP_LOAN_REALIZATION;
  PROCEDURE SP_LOAN_REAL_BY_MANUAL(P_ENTITY_NUM   IN NUMBER,
                                   P_EMP_ID       IN VARCHAR2,
                                   P_LOAN_TYPE    IN VARCHAR2,
                                   P_REAL_TYPE    IN CHAR,
                                   P_DRCR_TYPE    IN CHAR,
                                   P_VOUCHER_TYPE IN CHAR,
                                   P_REAL_DATE    IN DATE,
                                   P_REAL_AMT     IN NUMBER,
                                   P_ENTD_BY      IN VARCHAR2,
                                   P_ERROR        OUT VARCHAR2) IS
  
    V_MONTH_CODE NUMBER(2);
    V_YEAR       NUMBER(4);
    V_ERROR      VARCHAR2(400) := '';
  BEGIN
    SELECT TO_NUMBER(TO_CHAR(TO_DATE(P_REAL_DATE, 'dd-mon-yy'), 'mm'))
      INTO V_MONTH_CODE
      FROM DUAL;
    SELECT TO_NUMBER(TO_CHAR(P_REAL_DATE, 'YYYY')) INTO V_YEAR FROM DUAL;
    BEGIN
      SP_LOAN_REALIZATION(P_ENTITY_NUM,
                          P_EMP_ID,
                          P_LOAN_TYPE,
                          V_YEAR,
                          V_MONTH_CODE,
                          P_REAL_DATE,
                          P_REAL_TYPE,
                          P_DRCR_TYPE,
                          P_VOUCHER_TYPE,
                          P_REAL_AMT,
                          P_ENTD_BY,
                          V_ERROR);
    END;
    P_ERROR := V_ERROR;
  END SP_LOAN_REAL_BY_MANUAL;
  PROCEDURE SP_LOAN_REAL_FROM_SALARY_OLD(P_ENTITY_NUM IN NUMBER,
                                         P_YEAR       IN NUMBER,
                                         P_MONTH_CODE IN NUMBER,
                                         P_REAL_DATE  IN DATE,
                                         P_ENTY_BY    IN VARCHAR2,
                                         P_ERROR      OUT VARCHAR2) IS
    V_REAL_DATE DATE;
    V_ERROR     VARCHAR2(100) := '';
  
    FUNCTION FN_CHECK_LOAN_BY_EMP(P_ENTITY_NUM IN NUMBER,
                                  P_EMP_ID     IN VARCHAR2,
                                  P_LOAN_TYPE  IN VARCHAR2) RETURN BOOLEAN
    
     IS
      V_ROW NUMBER(1) := 0;
    BEGIN
      BEGIN
        SELECT NVL(COUNT(B.ENTITY_NUM), 0)
          INTO V_ROW
          FROM ELMS_DISBURSE B
         WHERE B.ENTITY_NUM = P_ENTITY_NUM
           AND B.EMP_ID = P_EMP_ID
           AND B.LOAN_TYPE = P_LOAN_TYPE
           AND B.DISB_SL = (SELECT MAX(B.DISB_SL)
                              FROM ELMS_DISBURSE B
                             WHERE B.ENTITY_NUM = P_ENTITY_NUM
                               AND B.EMP_ID = P_EMP_ID
                               AND B.LOAN_TYPE = P_LOAN_TYPE);
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          RETURN FALSE;
      END;
      IF NVL(V_ROW, 0) <> 0 THEN
        RETURN TRUE;
      ELSE
        RETURN FALSE;
      END IF;
    END FN_CHECK_LOAN_BY_EMP;
  BEGIN
    --  SELECT TO_DATE(P_REAL_DATE, 'DD-Mon-YYYY') INTO V_REAL_DATE FROM DUAL;
    V_REAL_DATE := P_REAL_DATE;
    FOR ID IN (SELECT T.BRANCH_CODE,
                      T.EMP_ID,
                      T.SAL_YEAR,
                      T.MONTH_CODE,
                      T.HBADV_DEDUC,
                      T.MCYCLE_DEDUC,
                      T.COMP_DEDUC,
                      T.PFADV_DEDUC,
                      T.PF_DEDUCTION
                 FROM PRMS_TRANSACTION T
                WHERE T.ENTITY_NUMBER = P_ENTITY_NUM
                  AND T.SAL_YEAR = P_YEAR
                     --  AND T.EMP_ID = '1455'
                  AND T.MONTH_CODE = P_MONTH_CODE) LOOP
    
      IF FN_CHECK_LOAN_BY_EMP(P_ENTITY_NUM, ID.EMP_ID, 'HBL') THEN
        PKG_ELMS.SP_LOAN_REALIZATION(P_ENTITY_NUM,
                                     ID.EMP_ID,
                                     'HBL',
                                     ID.SAL_YEAR,
                                     ID.MONTH_CODE,
                                     V_REAL_DATE,
                                     'P',
                                     'C',
                                     'N',
                                     NVL(ID.HBADV_DEDUC, 0),
                                     P_ENTY_BY,
                                     V_ERROR);
      END IF;
    
      IF FN_CHECK_LOAN_BY_EMP(P_ENTITY_NUM, ID.EMP_ID, 'MOT') THEN
        PKG_ELMS.SP_LOAN_REALIZATION(P_ENTITY_NUM,
                                     ID.EMP_ID,
                                     'MOT',
                                     ID.SAL_YEAR,
                                     ID.MONTH_CODE,
                                     V_REAL_DATE,
                                     'P',
                                     'C',
                                     'N',
                                     NVL(ID.MCYCLE_DEDUC, 0),
                                     P_ENTY_BY,
                                     V_ERROR);
      END IF;
    
      IF FN_CHECK_LOAN_BY_EMP(P_ENTITY_NUM, ID.EMP_ID, 'COM') THEN
        PKG_ELMS.SP_LOAN_REALIZATION(P_ENTITY_NUM,
                                     ID.EMP_ID,
                                     'COM',
                                     ID.SAL_YEAR,
                                     ID.MONTH_CODE,
                                     V_REAL_DATE,
                                     'P',
                                     'C',
                                     'N',
                                     ID.COMP_DEDUC,
                                     P_ENTY_BY,
                                     V_ERROR);
      END IF;
    
      IF ID.PFADV_DEDUC > 0 THEN
        PKG_ELMS.SP_LOAN_REALIZATION(P_ENTITY_NUM,
                                     ID.EMP_ID,
                                     'PFA',
                                     ID.SAL_YEAR,
                                     ID.MONTH_CODE,
                                     V_REAL_DATE,
                                     'P',
                                     'C',
                                     'N',
                                     ID.PFADV_DEDUC,
                                     P_ENTY_BY,
                                     V_ERROR);
      
      END IF;
    
      IF ID.PF_DEDUCTION > 0 THEN
        PKG_ELMS.SP_LOAN_REALIZATION(P_ENTITY_NUM,
                                     ID.EMP_ID,
                                     'PFC',
                                     ID.SAL_YEAR,
                                     ID.MONTH_CODE,
                                     V_REAL_DATE,
                                     'P',
                                     'C',
                                     'N',
                                     ID.PF_DEDUCTION,
                                     P_ENTY_BY,
                                     V_ERROR);
      
      END IF;
    
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      P_ERROR := '';
  END SP_LOAN_REAL_FROM_SALARY_OLD;
  PROCEDURE SP_LOAN_REAL_FROM_SALARY(P_ENTITY_NUM IN NUMBER,
                                     P_YEAR       IN NUMBER,
                                     P_MONTH_CODE IN NUMBER,
                                     P_TYPE       IN VARCHAR2,
                                     P_REAL_DATE  IN DATE,
                                     P_ENTY_BY    IN VARCHAR2,
                                     P_ERROR      OUT VARCHAR2) IS
    V_REAL_DATE DATE;
    V_ERROR     VARCHAR2(100) := '';
  
    FUNCTION FN_CHECK_LOAN_BY_EMP(P_ENTITY_NUM IN NUMBER,
                                  P_EMP_ID     IN VARCHAR2,
                                  P_LOAN_TYPE  IN VARCHAR2) RETURN BOOLEAN
    
     IS
      V_ROW NUMBER(1) := 0;
    BEGIN
      BEGIN
        SELECT NVL(COUNT(B.ENTITY_NUM), 0)
          INTO V_ROW
          FROM ELMS_DISBURSE B
         WHERE B.ENTITY_NUM = P_ENTITY_NUM
           AND B.EMP_ID = P_EMP_ID
           AND B.LOAN_TYPE = P_LOAN_TYPE
           AND B.DISB_SL = (SELECT MAX(B.DISB_SL)
                              FROM ELMS_DISBURSE B
                             WHERE B.ENTITY_NUM = P_ENTITY_NUM
                               AND B.EMP_ID = P_EMP_ID
                               AND B.LOAN_TYPE = P_LOAN_TYPE);
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          RETURN FALSE;
      END;
      IF NVL(V_ROW, 0) <> 0 THEN
        RETURN TRUE;
      ELSE
        RETURN FALSE;
      END IF;
    END FN_CHECK_LOAN_BY_EMP;
  BEGIN
    --  SELECT TO_DATE(P_REAL_DATE, 'DD-Mon-YYYY') INTO V_REAL_DATE FROM DUAL;
    V_REAL_DATE := P_REAL_DATE;
    DELETE FROM ELMS_REALIZATION R
     WHERE R.ENTITY_NUM = P_ENTITY_NUM
       AND R.LOAN_TYPE = P_TYPE
       AND R.REAL_YEAR = P_YEAR
       AND R.REAL_MONTH_CODE = P_MONTH_CODE;
    FOR ID IN (SELECT T.BRANCH_CODE,
                      T.EMP_ID,
                      T.SAL_YEAR,
                      T.MONTH_CODE,
                      T.HBADV_DEDUC,
                      T.MCYCLE_DEDUC,
                      T.COMP_DEDUC,
                      T.PFADV_DEDUC,
                      T.PF_DEDUCTION
                 FROM PRMS_TRANSACTION T
                WHERE T.ENTITY_NUMBER = P_ENTITY_NUM
                  AND T.SAL_YEAR = P_YEAR
                     -- AND T.EMP_ID = '1179'
                  AND T.MONTH_CODE = P_MONTH_CODE) LOOP
    
      IF P_TYPE = 'HBL' THEN
        IF FN_CHECK_LOAN_BY_EMP(P_ENTITY_NUM, ID.EMP_ID, 'HBL') THEN
          PKG_ELMS.SP_LOAN_REALIZATION(P_ENTITY_NUM,
                                       ID.EMP_ID,
                                       'HBL',
                                       ID.SAL_YEAR,
                                       ID.MONTH_CODE,
                                       V_REAL_DATE,
                                       'P',
                                       'C',
                                       'S',
                                       NVL(ID.HBADV_DEDUC, 0),
                                       P_ENTY_BY,
                                       V_ERROR);
        END IF;
      END IF;
      IF P_TYPE = 'MOT' THEN
        IF FN_CHECK_LOAN_BY_EMP(P_ENTITY_NUM, ID.EMP_ID, 'MOT') THEN
          PKG_ELMS.SP_LOAN_REALIZATION(P_ENTITY_NUM,
                                       ID.EMP_ID,
                                       'MOT',
                                       ID.SAL_YEAR,
                                       ID.MONTH_CODE,
                                       V_REAL_DATE,
                                       'P',
                                       'C',
                                       'S',
                                       NVL(ID.MCYCLE_DEDUC, 0),
                                       P_ENTY_BY,
                                       V_ERROR);
        END IF;
      END IF;
      IF P_TYPE = 'COM' THEN
        IF FN_CHECK_LOAN_BY_EMP(P_ENTITY_NUM, ID.EMP_ID, 'COM') THEN
          PKG_ELMS.SP_LOAN_REALIZATION(P_ENTITY_NUM,
                                       ID.EMP_ID,
                                       'COM',
                                       ID.SAL_YEAR,
                                       ID.MONTH_CODE,
                                       V_REAL_DATE,
                                       'P',
                                       'C',
                                       'S',
                                       ID.COMP_DEDUC,
                                       P_ENTY_BY,
                                       V_ERROR);
        END IF;
      END IF;
      IF ID.PFADV_DEDUC > 0 THEN
        PKG_ELMS.SP_LOAN_REALIZATION(P_ENTITY_NUM,
                                     ID.EMP_ID,
                                     'PFA',
                                     ID.SAL_YEAR,
                                     ID.MONTH_CODE,
                                     V_REAL_DATE,
                                     'P',
                                     'C',
                                     'S',
                                     ID.PFADV_DEDUC,
                                     P_ENTY_BY,
                                     V_ERROR);
      
      END IF;
      IF P_TYPE = 'PFC' THEN
        IF ID.PF_DEDUCTION > 0 THEN
          PKG_ELMS.SP_LOAN_REALIZATION(P_ENTITY_NUM,
                                       ID.EMP_ID,
                                       'PFC',
                                       ID.SAL_YEAR,
                                       ID.MONTH_CODE,
                                       V_REAL_DATE,
                                       'P',
                                       'C',
                                       'S',
                                       ID.PF_DEDUCTION,
                                       P_ENTY_BY,
                                       V_ERROR);
        
        END IF;
      
        IF ID.PFADV_DEDUC > 0 THEN
          PKG_ELMS.SP_LOAN_REALIZATION(P_ENTITY_NUM,
                                       ID.EMP_ID,
                                       'PFA',
                                       ID.SAL_YEAR,
                                       ID.MONTH_CODE,
                                       V_REAL_DATE,
                                       'P',
                                       'C',
                                       'S',
                                       ID.PFADV_DEDUC,
                                       P_ENTY_BY,
                                       V_ERROR);
        
        END IF;
      END IF;
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      P_ERROR := '';
  END SP_LOAN_REAL_FROM_SALARY;

  function month_day(p_month_code in number, p_year in number) return number is
    v_days number := 0;
  begin
    if p_month_code = 2 then
      if remainder(p_year, 400) = 0 then
        v_days := 29;
      elsif (remainder(p_year, 4)) = 0 then
        if (remainder(p_year, 100)) <> 0 then
          v_days := 29;
        end if;
      else
        v_days := 28;
      end if;
    elsif p_month_code = 1 or p_month_code = 3 or p_month_code = 5 or
          p_month_code = 7 or p_month_code = 8 or p_month_code = 10 or
          p_month_code = 12 then
      v_days := 31;
    else
      v_days := 30;
    end if;
    return v_days;
  end;
  procedure sp_pf_process(p_entity_num in number,
                          p_year       in number,
                          p_month_code in number,
                          p_error      out varchar2) is
  
    v_prv_balance     number(13, 2) := 0;
    v_cur_balance     number(13, 2) := 0;
    v_prv_adv1_bal    number(13, 2) := 0;
    v_prv_adv2_bal    number(13, 2) := 0;
    v_prv_adv3_bal    number(13, 2) := 0;
    v_ins_adv1_bal    number(13, 2) := 0;
    v_ins_adv2_bal    number(13, 2) := 0;
    v_ins_adv3_bal    number(13, 2) := 0;
    v_int_chg_amt     number(13, 2) := 0;
    v_pf_adv_amt      number(13, 2) := 0;
    v_year            number := 0;
    v_mon             number := 0;
    v_days            number := 0;
    v_days_count      number := 0;
    v_int_rate        number := 0.13;
    v_cum_sum         number := 0;
    v_new_installment number := 0;
    v_event           number := 0;
    function get_cum_int_amt(p_entity_num in number,
                             p_year       in number,
                             p_month_code in number,
                             p_emp_id     in varchar2) return number is
      v_cum_int_amt number(13, 2) := 0;
    begin
    
      if p_month_code = 6 then
        select nvl(sum(r.int_chg_amt), 0)
          into v_cum_int_amt
          from elms_pf_leadger r
         where r.entity_num = p_entity_num
           and r.emp_id = p_emp_id
           and r.pf_year = p_year
           and r.pf_month_code <= p_month_code;
      elsif p_month_code = 12 then
        select nvl(sum(r.int_chg_amt), 0)
          into v_cum_int_amt
          from elms_pf_leadger r
         where r.entity_num = p_entity_num
           and r.emp_id = p_emp_id
           and r.pf_year = p_year
           and r.pf_month_code <= p_month_code
           and r.pf_month_code > 6;
      end if;
      return v_cum_int_amt;
    end get_cum_int_amt;
  begin
    if remainder(p_year, 400) = 0 then
      v_days := 366;
    elsif (remainder(p_year, 4)) = 0 then
      if (remainder(p_year, 100)) <> 0 then
        v_days := 366;
      end if;
    else
      v_days := 365;
    end if;
    for id in (select *
                 from elms_pf_realization r
                where entity_num = p_entity_num
                  and real_year = p_year
                  and real_month_code = p_month_code
                 -- and  emp_id in ('864')
                order by emp_id) loop
    
      /* advanced related issue*/
      v_cum_sum := 0;
      select s.pf_balance,
             s.pf_adv1_bal,
             s.pf_adv2_bal,
             s.pf_adv3_bal,
             s.adv_ins1_amt,
             s.adv_ins2_amt,
             s.adv_ins3_amt
        into v_prv_balance,
             v_prv_adv1_bal,
             v_prv_adv2_bal,
             v_prv_adv3_bal,
             v_ins_adv1_bal,
             v_ins_adv2_bal,
             v_ins_adv3_bal
        from elms_pf_summary s
       where s.entity_num = id.entity_num
         and s.emp_id = id.emp_id;
    
      v_days_count := month_day(id.real_month_code, id.real_year);
    
      v_int_chg_amt := round((((v_prv_balance + nvl(id.pf_adv_cr_amt, 0) -
                             nvl(id.pf_adv_dr_amt, 0) -
                             nvl(id.voucher_dr, 0) +
                             nvl(id.voucher_cr, 0)) * v_days_count) /
                             v_days) * v_int_rate,
                             2);
    
      if p_month_code = 6 or p_month_code = 12 then
      
        v_cum_sum := get_cum_int_amt(p_entity_num,
                                     p_year,
                                     p_month_code,
                                     id.emp_id);
      
        v_cur_balance := round((v_prv_balance + id.pf_contribution_amt +
                               v_cum_sum + v_int_chg_amt +                               
                               nvl(id.pf_adv_dr_amt, 0) +
                               nvl(id.pf_adv_cr_amt, 0) -
                               nvl(id.voucher_dr, 0) +
                               nvl(id.voucher_cr, 0)),
                               2);
      else
        v_cur_balance := round((v_prv_balance + id.pf_contribution_amt -
                               nvl(id.pf_adv_dr_amt, 0) +
                               nvl(id.pf_adv_cr_amt, 0) -
                               nvl(id.voucher_dr, 0) +
                               nvl(id.voucher_cr, 0)),
                               2);
      end if;
      v_event := 1;
      /* installment calculation */
      if nvl(id.pf_adv_cr_amt, 0) > 0 or nvl(id.pf_adv_dr_amt, 0) > 0  then
      
        if nvl(id.pf_adv_cr_amt, 0) > 0 or
           nvl(id.pf_adv_dr_amt, 0) > 0 then
        
          if nvl(id.pf_adv_dr_amt, 0) > 0 then
            
            select a.pf_adv_ins
              into v_new_installment
              from elms_pf_advance a
             where a.entity_num = 1
               and a.emp_id = id.emp_id
               and a.pf_adv_year = id.real_year
               and a.pf_adv_month_code = id.real_month_code
               and a.pf_adv_amt = id.pf_adv_dr_amt;
          
            if (nvl(v_prv_adv1_bal, 0) <= 0 and nvl(v_prv_adv2_bal, 0) <= 0 and
               nvl(v_prv_adv3_bal, 0) <= 0) or
               (nvl(v_prv_adv1_bal, 0) <= 0 and nvl(v_prv_adv2_bal, 0) <= 0 and
               nvl(v_prv_adv3_bal, 0) > 0) or
               (nvl(v_prv_adv1_bal, 0) <= 0 and nvl(v_prv_adv2_bal, 0) > 0 and
               nvl(v_prv_adv3_bal, 0) > 0) then
              /*position no: (1st)*/
              v_prv_adv1_bal := nvl(id.pf_adv_dr_amt, 0);
              v_ins_adv1_bal := v_new_installment;
            
            elsif (nvl(v_prv_adv1_bal, 0) > 0 and
                  nvl(v_prv_adv2_bal, 0) <= 0 and
                  nvl(v_prv_adv3_bal, 0) <= 0) or
                  (nvl(v_prv_adv1_bal, 0) > 0 and
                  nvl(v_prv_adv2_bal, 0) <= 0 and
                  nvl(v_prv_adv3_bal, 0) > 0) then
              /*position no: (2nd)*/
              v_prv_adv2_bal := nvl(id.pf_adv_dr_amt, 0);
              v_ins_adv2_bal := v_new_installment;
            
            elsif (nvl(v_prv_adv1_bal, 0) > 0 and
                  nvl(v_prv_adv2_bal, 0) > 0 and
                  nvl(v_prv_adv3_bal, 0) <= 0) or
                  (nvl(v_prv_adv1_bal, 0) <= 0 and
                  nvl(v_prv_adv2_bal, 0) > 0 and
                  nvl(v_prv_adv3_bal, 0) <= 0) then
              /*position no: (3rd)*/
              v_prv_adv3_bal := nvl(id.pf_adv_dr_amt, 0);
              v_ins_adv3_bal := v_new_installment;
            end if;
          end if;
        
          if nvl(id.pf_adv_cr_amt, 0) > 0 then
          
            if v_event = 1 then
              if nvl(v_prv_adv1_bal, 0) - nvl(id.pf_adv_cr_amt, 0) >= 0 then
                v_prv_adv1_bal := v_prv_adv1_bal -
                                  nvl(id.pf_adv_cr_amt, 0);
                v_event        := 0;
              elsif nvl(v_prv_adv1_bal, 0) - nvl(id.pf_adv_cr_amt, 0) < 0 then
                v_prv_adv2_bal := v_prv_adv2_bal -
                                  (nvl(id.pf_adv_cr_amt, 0) -
                                  nvl(v_prv_adv1_bal, 0));
                v_prv_adv1_bal := 0;
                v_event        := 0;
              end if;
            end if;
          
            if v_event = 1 then
              if nvl(v_prv_adv2_bal, 0) - nvl(id.pf_adv_cr_amt, 0) >= 0 then
                v_prv_adv2_bal := v_prv_adv2_bal -
                                  nvl(id.pf_adv_cr_amt, 0);
                v_event        := 0;
              elsif nvl(v_prv_adv2_bal, 0) - nvl(id.pf_adv_cr_amt, 0) < 0 then
                v_prv_adv3_bal := v_prv_adv3_bal -
                                  (nvl(id.pf_adv_cr_amt, 0) -
                                  nvl(v_prv_adv2_bal, 0));
                v_prv_adv2_bal := 0;
                v_event        := 0;
              end if;
            end if;
          
            if v_event = 1 then
              if nvl(v_prv_adv3_bal, 0) - nvl(id.pf_adv_cr_amt, 0) >= 0 then
                v_prv_adv3_bal := v_prv_adv3_bal -
                                  nvl(id.pf_adv_cr_amt, 0);
                v_event        := 0;
              elsif nvl(v_prv_adv3_bal, 0) - nvl(id.pf_adv_cr_amt, 0) < 0 then
                v_prv_adv1_bal := v_prv_adv1_bal -
                                  (nvl(id.pf_adv_cr_amt, 0) -
                                  nvl(v_prv_adv3_bal, 0));
                v_prv_adv3_bal := 0;
                v_event        := 0;
              end if;
            end if;
          end if;
        
        end if;
      end if;
    
      update elms_pf_summary s
         set s.cum_int_chg_amt = v_int_chg_amt,
             s.pf_balance      = v_cur_balance,
             s.pf_adv1_bal     = v_prv_adv1_bal,
             s.pf_adv2_bal     = v_prv_adv2_bal,
             s.pf_adv3_bal     = v_prv_adv3_bal,
             s.adv_ins1_amt    = v_ins_adv1_bal,
             s.adv_ins2_amt    = v_ins_adv2_bal,
             s.adv_ins3_amt    = v_ins_adv3_bal
       where s.entity_num = p_entity_num
         and s.emp_id = id.emp_id;
      insert into elms_pf_leadger
        (entity_num,
         emp_id,
         pf_year,
         pf_month_code,
         vouchar_type,
         pf_sl,
         real_type,
         pf_contribution_amt,
         pf_adv_real_amt,
         pf_adv_dr_amt,
         pf_adv_cr_amt,
         voucher_dr,
         voucher_cr,
         int_chg_amt,
         pf_balance,
         pf_adv1_bal,
         pf_adv2_bal,
         pf_adv3_bal,
         pf_tot_bal,
         adv1_ins,
         adv2_ins,
         adv3_ins,
         entd_by,
         entd_on)
      values
        (p_entity_num,
         id.emp_id,
         id.real_year,
         id.real_month_code,
         id.voucher_type,
         id.rel_sl,
         id.pf_real_type,
         id.pf_contribution_amt,
         nvl(id.pf_adv_cr_amt, 0),
         nvl(id.pf_adv_dr_amt, 0),
         nvl(id.pf_adv_cr_amt, 0),
         nvl(id.voucher_dr, 0),
         nvl(id.voucher_cr, 0),
         v_int_chg_amt,
         v_cur_balance,
         v_prv_adv1_bal,
         v_prv_adv2_bal,
         v_prv_adv3_bal,
         v_prv_adv1_bal + v_prv_adv2_bal + v_prv_adv3_bal,
         v_ins_adv1_bal,
         v_ins_adv2_bal,
         v_ins_adv3_bal,
         'AUTO',
         trunc(sysdate));
    
    end loop;
    /*for id in (select *
                 from elms_realization r
                where loan_type = 'PFA'
                  and entity_num = p_entity_num
                  and real_year = p_year
                  and real_month_code = p_month_code
               -- and emp_id = '776'
                order by emp_id) loop
      select s.pf_balance, s.pf_adv1_bal, s.pf_adv2_bal, s.pf_adv3_bal
        into v_prv_balance, v_prv_adv1_bal, v_prv_adv2_bal, v_prv_adv3_bal
        from elms_pf_summary s
       where s.entity_num = id.entity_num
         and s.emp_id = id.emp_id;
    
    \*
             *     need to fix  pf advanced ration info
             *
             *
             *
             *\
    
    end loop;*/
  end sp_pf_process;
  
  procedure sp_accrual_process_new(p_entity_num in number,
                               p_year       in number,
                               p_month_code in number,
                               p_loan_type  in varchar2,
                               p_error      out varchar2) is
    v_int_rate         number(13, 2) := 0.05;
    v_prev_prin_bal    number(13, 2) := 0;
    v_prev_int_bal     number(13, 2) := 0;
    v_temp_bal         number(13, 2) := 0;
    v_curr_prin_bal    number(13, 2) := 0;
    v_curr_intr_bal    number(13, 2) := 0;
    v_intr_chg_on_prin number(13, 2) := 0;
    v_tot_intr_bal     number(13, 2) := 0;
    v_tot_bal          number(13, 2) := 0;
    v_days_count1      number := 0;
    v_days_count2      number := 0;
    v_days_count       number := 0;
    v_year             number := 0;
    v_mon              number := 0;
    v_days             number := 0;
    v_row_count        number := 0;
    v_row_sl           number := 0;
    temp_days          number := 0;
    v_real_type        char(1) := '';
    
  function fn_int_calculation(p_principle in number,p_int_rate in number,p_days in number,p_tot_days in number)  return number is
  v_int_charge number :=0;  
  begin
    v_int_charge := (p_principle * p_int_rate *p_days )/ p_tot_days;
    return v_int_charge;
  end fn_int_calculation;
     
  begin
    for idx in (select *
                  from elms_realization r
                 where r.entity_num = p_entity_num
                   and r.real_year = p_year
                   and r.real_month_code = p_month_code
                   and r.loan_type = p_loan_type
                      -- and r.emp_id = '900'
                   and r.rel_sl = 1
                 order by r.emp_id) loop
    
      v_prev_prin_bal    := 0;
      v_prev_int_bal     := 0;
      v_temp_bal         := 0;
      v_curr_prin_bal    := 0;
      v_curr_intr_bal    := 0;
      v_intr_chg_on_prin := 0;
      v_tot_intr_bal     := 0;
      v_tot_bal          := 0;
      v_days_count1      := 0;
      v_days_count2      := 0;
      v_days_count       := 0;
      v_days             := 0;
      v_row_count        := 0;
      temp_days          := 0;
    v_row_sl:=0;
      if p_month_code = 1 then
        v_year := p_year - 1;
        v_mon  := 12;
      else
        v_year := p_year;
        v_mon  := p_month_code - 1;
      end if;
      if remainder(p_year, 400) = 0 then
        v_days := 366;
      elsif (remainder(p_year, 4)) = 0 then
        if (remainder(p_year, 100)) <> 0 then
          v_days := 366;
        end if;
      else
        v_days := 365;
      end if;
    
      select count(r.entity_num)
        into v_row_count
        from elms_realization r
       where r.entity_num = idx.entity_num
         and r.real_year = idx.real_year
         and r.real_month_code = idx.real_month_code
         and r.loan_type = idx.loan_type
         and r.emp_id = idx.emp_id;
    
      if nvl(v_row_count, 0) > 1 then
        /*for multiple adjustment in a month*/
        for id in (select *
                     from elms_realization r
                    where r.entity_num = idx.entity_num
                      and r.real_year = idx.real_year
                      and r.real_month_code = idx.real_month_code
                      and r.loan_type = idx.loan_type
                      and r.emp_id = idx.emp_id
                    order by r.real_date) loop
        v_row_sl:=v_row_sl+1;
          begin
            select nvl(r.prin_balance, 0), nvl(r.int_balance, 0)
              into v_prev_prin_bal, v_prev_int_bal
              from elms_ln_summary r
             where r.entity_num = p_entity_num
               and r.emp_id = id.emp_id
               and r.loan_type = id.loan_type;
          exception
            when others then
              v_prev_prin_bal := 0;
              v_prev_int_bal  := 0;
          end;
          
          if v_row_sl = v_row_count then
            
              select extract(day from id.real_date) - 1
                into v_days_count1
                from dual;
              v_days_count1 := v_days_count1 - temp_days;
              select extract(day from last_day(trunc(id.real_date)))
                into v_days_count
                from dual;
              v_days_count2 := v_days_count - (v_days_count1 + temp_days);
            else
              select extract(day from id.real_date) - 1
                into v_days_count1
                from dual;
              v_days_count1 := v_days_count1 - temp_days;
              v_days_count2 := 0;
            end if;
          
            temp_days := temp_days + v_days_count1;
          
           /* if nvl(v_prev_prin_bal, 0) = 0 and nvl(v_prev_int_bal, 0) = 0 then
              v_days_count1 := 0;
              v_days_count2 := 0;
            end if;*/

          if nvl(id.real_amount,0)>0 or nvl(v_prev_prin_bal+v_prev_int_bal,0)>0 then
                        
             if id.dr_cr_type = 'C' then               
                if nvl(v_prev_prin_bal,0)-nvl(id.real_amount,0) >=0 then
                   v_real_type := 'P';
                   v_curr_prin_bal := round((v_prev_prin_bal - nvl(id.real_amount, 0)), 2);
                   /* interest apply */
                        if nvl(id.real_amount,0)>0 then                   
                         v_intr_chg_on_prin:=round(fn_int_calculation(v_prev_prin_bal,v_int_rate,v_days_count1,v_days),2)+
                                            round(fn_int_calculation(v_curr_prin_bal,v_int_rate,v_days_count2,v_days),2); 
                        else
                          v_intr_chg_on_prin:=round(fn_int_calculation(v_prev_prin_bal,v_int_rate,v_days_count1+v_days_count2,v_days),2);   
                        end if;  
                                        
                    v_curr_intr_bal  :=round(v_prev_int_bal+v_intr_chg_on_prin,2);
                    
                elsif nvl(v_prev_prin_bal,0)-nvl(id.real_amount,0)< 0 then
                  
                    if nvl(v_prev_prin_bal,0)>0 then
                     v_real_type := 'B'; 
                     v_temp_bal      := round((nvl(id.real_amount, 0) -
                                         nvl(v_prev_prin_bal, 0)),
                                         2);
                     v_curr_prin_bal := 0;
                     /* interest apply */
                        if nvl(id.real_amount,0)>0 then                   
                         v_intr_chg_on_prin:=round(fn_int_calculation(v_prev_prin_bal,v_int_rate,v_days_count1,v_days),2)+
                                            round(fn_int_calculation(v_curr_prin_bal,v_int_rate,v_days_count2,v_days),2); 
                        else
                          v_intr_chg_on_prin:=round(fn_int_calculation(v_prev_prin_bal,v_int_rate,v_days_count1+v_days_count2,v_days),2);   
                        end if;  
                     v_curr_intr_bal := round(v_prev_int_bal-v_temp_bal+v_intr_chg_on_prin,2);
                     
                    else
                     v_real_type := 'I';                      
                        if nvl(id.real_amount,0)>0 then                   
                         v_intr_chg_on_prin:=round(fn_int_calculation(v_prev_prin_bal,v_int_rate,v_days_count1,v_days),2)+
                                            round(fn_int_calculation(v_curr_prin_bal,v_int_rate,v_days_count2,v_days),2); 
                        else
                          v_intr_chg_on_prin:=round(fn_int_calculation(v_prev_prin_bal,v_int_rate,v_days_count1+v_days_count2,v_days),2);   
                        end if;  
                    v_curr_intr_bal := round((v_prev_int_bal+v_intr_chg_on_prin -nvl(id.real_amount, 0)), 2);
                    end if;                            
                end if;
             else
                     v_curr_prin_bal := round((v_prev_prin_bal + nvl(id.real_amount, 0)), 2);
                    
                     v_intr_chg_on_prin:=round(fn_int_calculation(v_prev_prin_bal,v_int_rate,v_days_count1,v_days),2)+
                               round(fn_int_calculation(v_curr_prin_bal,v_int_rate,v_days_count2,v_days),2);                     
                     v_curr_intr_bal :=v_prev_int_bal+v_intr_chg_on_prin;
             end if;
             
            v_tot_bal      := round(v_curr_intr_bal + v_curr_prin_bal, 2);
            
            begin
              insert into elms_ln_ledger
                (entity_num,
                 emp_id,
                 loan_type,
                 real_year,
                 real_month_code,
                 rel_sl,
                 real_date,
                 real_type,
                 dr_cr_type,
                 vouchar_type,
                 real_amount,
                 prin_balance,
                 int_charged,
                 int_balance,
                 tot_balance,
                 entd_by,
                 entd_on)
              values
                (id.entity_num,
                 id.emp_id,
                 id.loan_type,
                 id.real_year,
                 id.real_month_code,
                 id.rel_sl,
                 id.real_date,
                 v_real_type,
                 id.dr_cr_type,
                 id.vouchar_type,
                 id.real_amount,
                 v_curr_prin_bal,
                 v_intr_chg_on_prin,
                 v_curr_intr_bal,
                 v_tot_bal,
                 id.entd_by,
                 id.entd_on);
            
              update elms_ln_summary s
                 set s.prin_balance = v_curr_prin_bal,
                     s.int_balance  = v_curr_intr_bal,
                     s.tot_balance  = v_tot_bal
               where s.entity_num = p_entity_num
                 and s.emp_id = idx.emp_id
                 and s.loan_type = p_loan_type;
            exception
              when others then
                dbms_output.put_line('inserting error for ' || idx.emp_id || '-' ||
                                     idx.loan_type || '-' || idx.real_date);
            end;
          end if;
        end loop;
      else
        /*for single adjustment in a month*/
        for id in (select *
                     from elms_realization r
                    where r.entity_num = idx.entity_num
                      and r.real_year = idx.real_year
                      and r.real_month_code = idx.real_month_code
                      and r.loan_type = idx.loan_type
                      and r.emp_id = idx.emp_id
                    order by r.real_date) loop
                    
          begin
            select nvl(r.prin_balance, 0), nvl(r.int_balance, 0)
              into v_prev_prin_bal, v_prev_int_bal
              from elms_ln_summary r
             where r.entity_num = p_entity_num
               and r.emp_id = id.emp_id
               and r.loan_type = id.loan_type;
          exception
            when others then
              v_prev_prin_bal := 0;
              v_prev_int_bal  := 0;
          end;
        
        select extract(day from id.real_date) - 1
                into v_days_count1
                from dual;
                                                                                                                 
        select extract(day from last_day(trunc(id.real_date)))
                into v_days_count
                from dual;
         v_days_count2 := v_days_count - v_days_count1;  
                               
          /*  if nvl(v_prev_prin_bal, 0) = 0 and nvl(v_prev_int_bal, 0) = 0 then
              v_days_count1 := 0;
              v_days_count2 := 0;
            end if;
           */
          if nvl(id.real_amount,0)>0 or nvl(v_prev_prin_bal+v_prev_int_bal,0)>0 then
                        
             if id.dr_cr_type = 'C' then               
                if nvl(v_prev_prin_bal,0)-nvl(id.real_amount,0) >=0 then
                   v_real_type := 'P';
                   v_curr_prin_bal := round((v_prev_prin_bal - nvl(id.real_amount, 0)), 2);
                   /* interest apply */
                      
                   if nvl(id.real_amount,0)>0 then                   
                     v_intr_chg_on_prin:=round(fn_int_calculation(v_prev_prin_bal,v_int_rate,v_days_count1,v_days),2)+
                                        round(fn_int_calculation(v_curr_prin_bal,v_int_rate,v_days_count2,v_days),2); 
                    else
                      v_intr_chg_on_prin:=round(fn_int_calculation(v_prev_prin_bal,v_int_rate,v_days_count1+v_days_count2,v_days),2);   
                    end if;  
                                               
                    v_curr_intr_bal  :=round(v_prev_int_bal+v_intr_chg_on_prin,2);
                    
                elsif nvl(v_prev_prin_bal,0)-nvl(id.real_amount,0)< 0 then
                  
                    if nvl(v_prev_prin_bal,0)>0 then
                     v_real_type := 'B'; 
                     v_temp_bal      := round((nvl(id.real_amount, 0) -
                                         nvl(v_prev_prin_bal, 0)),
                                         2);
                     v_curr_prin_bal := 0;
                     /* interest apply */
                       if nvl(id.real_amount,0)>0 then                   
                       v_intr_chg_on_prin:=round(fn_int_calculation(v_prev_prin_bal,v_int_rate,v_days_count1,v_days),2)+
                                          round(fn_int_calculation(v_curr_prin_bal,v_int_rate,v_days_count2,v_days),2); 
                       else
                        v_intr_chg_on_prin:=round(fn_int_calculation(v_prev_prin_bal,v_int_rate,v_days_count1+v_days_count2,v_days),2);   
                       end if;    
                      
                     v_curr_intr_bal := round((v_prev_int_bal+v_intr_chg_on_prin-nvl(v_temp_bal, 0)),2);
                     
                    else
                     v_real_type := 'I';                      
                      if nvl(id.real_amount,0)>0 then                   
                       v_intr_chg_on_prin:=round(fn_int_calculation(v_prev_prin_bal,v_int_rate,v_days_count1,v_days),2)+
                                          round(fn_int_calculation(v_curr_prin_bal,v_int_rate,v_days_count2,v_days),2); 
                      else
                        v_intr_chg_on_prin:=round(fn_int_calculation(v_prev_prin_bal,v_int_rate,v_days_count1+v_days_count2,v_days),2);   
                      end if;  
                    
                     v_curr_intr_bal := round((v_prev_int_bal+v_intr_chg_on_prin -nvl(id.real_amount, 0)), 2);
                    end if;                            
                end if;
             else
                    v_curr_prin_bal := round((v_prev_prin_bal + nvl(id.real_amount, 0)), 2);
                    
                     v_intr_chg_on_prin:=round(fn_int_calculation(v_prev_prin_bal,v_int_rate,v_days_count1,v_days),2)+
                               round(fn_int_calculation(v_curr_prin_bal,v_int_rate,v_days_count2,v_days),2);                     
                     v_curr_intr_bal :=v_prev_int_bal+v_intr_chg_on_prin;
             end if;
             
            v_tot_bal      := round(v_curr_intr_bal + v_curr_prin_bal, 2);
            
            begin
              insert into elms_ln_ledger
                (entity_num,
                 emp_id,
                 loan_type,
                 real_year,
                 real_month_code,
                 rel_sl,
                 real_date,
                 real_type,
                 dr_cr_type,
                 vouchar_type,
                 real_amount,
                 prin_balance,
                 int_charged,
                 int_balance,
                 tot_balance,
                 entd_by,
                 entd_on)
              values
                (id.entity_num,
                 id.emp_id,
                 id.loan_type,
                 id.real_year,
                 id.real_month_code,
                 id.rel_sl,
                 id.real_date,
                 v_real_type,
                 id.dr_cr_type,
                 id.vouchar_type,
                 id.real_amount,
                 v_curr_prin_bal,
                 v_intr_chg_on_prin,
                 v_curr_intr_bal,
                 v_tot_bal,
                 id.entd_by,
                 id.entd_on);
            
              update elms_ln_summary s
                 set s.prin_balance = v_curr_prin_bal,
                     s.int_balance  = v_curr_intr_bal,
                     s.tot_balance  = v_tot_bal
               where s.entity_num = p_entity_num
                 and s.emp_id = idx.emp_id
                 and s.loan_type = p_loan_type;
            exception
              when others then
                dbms_output.put_line('inserting error for ' || idx.emp_id || '-' ||
                                     idx.loan_type || '-' || idx.real_date);
            end;
          end if;
        
          
        end loop;
      end if;
    
    end loop;
  exception
    when others then
      p_error := '';
  end sp_accrual_process_new;
  
  
  PROCEDURE SP_ACCRUAL_PROCESS(P_ENTITY_NUM IN NUMBER,
                               P_YEAR       IN NUMBER,
                               P_MONTH_CODE IN NUMBER,
                               P_LOAN_TYPE  IN VARCHAR2,
                               P_ERROR      OUT VARCHAR2) IS
    V_INT_RATE         NUMBER(13, 2) := 0.05;
    V_PREV_PRIN_BAL    NUMBER(13, 2) := 0;
    V_PREV_INT_BAL     NUMBER(13, 2) := 0;
    V_TEMP_BAL         NUMBER(13, 2) := 0;
    V_CURR_PRIN_BAL    NUMBER(13, 2) := 0;
    V_CURR_INTR_BAL    NUMBER(13, 2) := 0;
    V_INTR_CHG_ON_PRIN NUMBER(13, 2) := 0;
    V_TOT_INTR_BAL     NUMBER(13, 2) := 0;
    V_TOT_BAL          NUMBER(13, 2) := 0;
    V_DAYS_COUNT1      NUMBER := 0;
    V_DAYS_COUNT2      NUMBER := 0;
    V_DAYS_COUNT       NUMBER := 0;
    V_YEAR             NUMBER := 0;
    V_MON              NUMBER := 0;
    V_DAYS             NUMBER := 0;
    V_ROW_COUNT        NUMBER := 0;
    V_ROW_SL           NUMBER := 0;
    TEMP_DAYS          NUMBER := 0;
    V_REAL_TYPE        CHAR(1) := '';
  BEGIN
    FOR IDX IN (SELECT *
                  FROM ELMS_REALIZATION R
                 WHERE R.ENTITY_NUM = P_ENTITY_NUM
                   AND R.REAL_YEAR = P_YEAR
                   AND R.REAL_MONTH_CODE = P_MONTH_CODE
                   AND R.LOAN_TYPE = P_LOAN_TYPE
                       AND R.EMP_ID = '1198'
                   AND R.REL_SL = 1
                 ORDER BY R.EMP_ID) LOOP
    
      V_PREV_PRIN_BAL    := 0;
      V_PREV_INT_BAL     := 0;
      V_TEMP_BAL         := 0;
      V_CURR_PRIN_BAL    := 0;
      V_CURR_INTR_BAL    := 0;
      V_INTR_CHG_ON_PRIN := 0;
      V_TOT_INTR_BAL     := 0;
      V_TOT_BAL          := 0;
      V_DAYS_COUNT1      := 0;
      V_DAYS_COUNT2      := 0;
      V_DAYS_COUNT       := 0;
      V_DAYS             := 0;
      V_ROW_COUNT        := 0;
      TEMP_DAYS          := 0;
    V_ROW_SL:=0;
      IF P_MONTH_CODE = 1 THEN
        V_YEAR := P_YEAR - 1;
        V_MON  := 12;
      ELSE
        V_YEAR := P_YEAR;
        V_MON  := P_MONTH_CODE - 1;
      END IF;
      IF REMAINDER(P_YEAR, 400) = 0 THEN
        V_DAYS := 366;
      ELSIF (REMAINDER(P_YEAR, 4)) = 0 THEN
        IF (REMAINDER(P_YEAR, 100)) <> 0 THEN
          V_DAYS := 366;
        END IF;
      ELSE
        V_DAYS := 365;
      END IF;
    
      SELECT COUNT(R.ENTITY_NUM)
        INTO V_ROW_COUNT
        FROM ELMS_REALIZATION R
       WHERE R.ENTITY_NUM = IDX.ENTITY_NUM
         AND R.REAL_YEAR = IDX.REAL_YEAR
         AND R.REAL_MONTH_CODE = IDX.REAL_MONTH_CODE
         AND R.LOAN_TYPE = IDX.LOAN_TYPE
         AND R.EMP_ID = IDX.EMP_ID;
    
      IF NVL(V_ROW_COUNT, 0) > 1 THEN
        /*FOR MULTIPLE ADJUSTMENT IN A MONTH*/
        FOR ID IN (SELECT *
                     FROM ELMS_REALIZATION R
                    WHERE R.ENTITY_NUM = IDX.ENTITY_NUM
                      AND R.REAL_YEAR = IDX.REAL_YEAR
                      AND R.REAL_MONTH_CODE = IDX.REAL_MONTH_CODE
                      AND R.LOAN_TYPE = IDX.LOAN_TYPE
                      AND R.EMP_ID = IDX.EMP_ID
                    ORDER BY R.REAL_DATE) LOOP
        V_ROW_SL:=V_ROW_SL+1;
          BEGIN
            SELECT NVL(R.PRIN_BALANCE, 0), NVL(R.INT_BALANCE, 0)
              INTO V_PREV_PRIN_BAL, V_PREV_INT_BAL
              FROM ELMS_LN_SUMMARY R
             WHERE R.ENTITY_NUM = P_ENTITY_NUM
               AND R.EMP_ID = ID.EMP_ID
               AND R.LOAN_TYPE = ID.LOAN_TYPE;
          EXCEPTION
            WHEN OTHERS THEN
              V_PREV_PRIN_BAL := 0;
              V_PREV_INT_BAL  := 0;
          END;
        
          IF (V_PREV_PRIN_BAL + V_PREV_INT_BAL) > 0 OR ID.REAL_AMOUNT > 0 THEN
            IF (NVL(V_PREV_PRIN_BAL, 0) > 0 AND  NVL(V_PREV_PRIN_BAL, 0) - NVL(ID.REAL_AMOUNT, 0) > 0) THEN
              /*REALIZATION FOR ONLY PRINCIPAL*/
              V_REAL_TYPE := 'P';
              IF ID.DR_CR_TYPE = 'C' THEN
                V_CURR_PRIN_BAL := ROUND((V_PREV_PRIN_BAL -
                                         NVL(ID.REAL_AMOUNT, 0)),
                                         2);
              ELSE
                V_CURR_PRIN_BAL := ROUND((V_PREV_PRIN_BAL +
                                         NVL(ID.REAL_AMOUNT, 0)),
                                         2);
              END IF;
            
            ELSIF (NVL(V_PREV_PRIN_BAL, 0) > 0 AND
                  NVL(V_PREV_PRIN_BAL, 0) - NVL(ID.REAL_AMOUNT, 0) < 0) THEN
              V_REAL_TYPE := 'B';
              /*REALIZATION FOR PRINCIPAL & INTEREST*/
              IF ID.DR_CR_TYPE = 'C' THEN
                V_TEMP_BAL      := ROUND((NVL(ID.REAL_AMOUNT, 0) -
                                         NVL(V_PREV_PRIN_BAL, 0)),
                                         2);
                V_CURR_PRIN_BAL := 0;
                V_CURR_INTR_BAL := ROUND((V_PREV_INT_BAL -
                                         NVL(V_TEMP_BAL, 0)),
                                         2);
              ELSE
                V_CURR_PRIN_BAL := ROUND((V_PREV_PRIN_BAL +
                                         NVL(ID.REAL_AMOUNT, 0)),
                                         2);
              END IF;
            
            ELSIF (NVL(V_PREV_PRIN_BAL, 0) = 0 AND
                  NVL(V_PREV_INT_BAL, 0) - NVL(ID.REAL_AMOUNT, 0) > 0) THEN
              /*REALIZATION FOR ONLY INTEREST*/
              V_REAL_TYPE := 'I';
              IF ID.DR_CR_TYPE = 'C' THEN
                V_CURR_INTR_BAL := ROUND((V_PREV_INT_BAL -
                                         NVL(ID.REAL_AMOUNT, 0)),
                                         2);
              ELSE
                V_CURR_PRIN_BAL := ROUND((V_CURR_PRIN_BAL +
                                         NVL(ID.REAL_AMOUNT, 0)),
                                         2);
              END IF;
            
            ELSIF NVL(V_PREV_PRIN_BAL, 0) = 0 AND
                  ((NVL(V_PREV_INT_BAL, 0) = 0 OR
                   NVL(V_PREV_INT_BAL, 0) - NVL(ID.REAL_AMOUNT, 0) < 0)) THEN
              /*NEITHER PRINCIPLE NOR INTEREST*/
              V_REAL_TYPE := 'X';
              IF ID.DR_CR_TYPE = 'C' THEN
              
                V_CURR_PRIN_BAL := ROUND((V_CURR_PRIN_BAL -
                                         NVL(ID.REAL_AMOUNT, 0)),
                                         2);
              ELSE
                V_CURR_INTR_BAL := V_PREV_INT_BAL;
                V_CURR_PRIN_BAL := ROUND((V_CURR_PRIN_BAL +
                                         NVL(ID.REAL_AMOUNT, 0)),
                                         2);
              END IF;
            END IF;
            
           -- V_CURR_INTR_BAL:=V_PREV_INT_BAL;

            IF V_ROW_SL = V_ROW_COUNT THEN
              V_DAYS_COUNT1 := V_DAYS_COUNT1 - TEMP_DAYS;
              SELECT EXTRACT(DAY FROM LAST_DAY(TRUNC(ID.REAL_DATE)))
                INTO V_DAYS_COUNT
                FROM DUAL;
              V_DAYS_COUNT2 := V_DAYS_COUNT - (V_DAYS_COUNT1 + TEMP_DAYS);
            ELSE
              SELECT EXTRACT(DAY FROM ID.REAL_DATE) - 1
                INTO V_DAYS_COUNT1
                FROM DUAL;
              V_DAYS_COUNT1 := V_DAYS_COUNT1 - TEMP_DAYS;
              V_DAYS_COUNT2 := 0;
            END IF;
          
            TEMP_DAYS := TEMP_DAYS + V_DAYS_COUNT1;
          
            IF NVL(V_PREV_PRIN_BAL, 0) = 0 AND NVL(V_PREV_INT_BAL, 0) = 0 THEN
              V_DAYS_COUNT1 := 0;
            END IF;
          
            V_INTR_CHG_ON_PRIN := ROUND((ROUND(((V_PREV_PRIN_BAL *
                                               V_INT_RATE) *
                                               (V_DAYS_COUNT1 / V_DAYS)),
                                               2) +
                                        ROUND(((V_CURR_PRIN_BAL *
                                               V_INT_RATE) *
                                               (V_DAYS_COUNT2 / V_DAYS)),
                                               2)),
                                        2);
          
            IF V_REAL_TYPE ='B' OR V_REAL_TYPE='I' THEN
              V_TOT_INTR_BAL := ROUND(V_INTR_CHG_ON_PRIN + V_CURR_INTR_BAL, 2);
            ELSE
              
            V_TOT_INTR_BAL := ROUND(V_INTR_CHG_ON_PRIN + V_PREV_INT_BAL, 2);
            END IF;
            V_TOT_BAL      := ROUND(V_TOT_INTR_BAL + V_CURR_PRIN_BAL, 2);
            BEGIN
              INSERT INTO ELMS_LN_LEDGER
                (ENTITY_NUM,
                 EMP_ID,
                 LOAN_TYPE,
                 REAL_YEAR,
                 REAL_MONTH_CODE,
                 REL_SL,
                 REAL_DATE,
                 REAL_TYPE,
                 DR_CR_TYPE,
                 VOUCHAR_TYPE,
                 REAL_AMOUNT,
                 PRIN_BALANCE,
                 INT_CHARGED,
                 INT_BALANCE,
                 TOT_BALANCE,
                 ENTD_BY,
                 ENTD_ON)
              VALUES
                (ID.ENTITY_NUM,
                 ID.EMP_ID,
                 ID.LOAN_TYPE,
                 ID.REAL_YEAR,
                 ID.REAL_MONTH_CODE,
                 ID.REL_SL,
                 ID.REAL_DATE,
                 V_REAL_TYPE,
                 ID.DR_CR_TYPE,
                 ID.VOUCHAR_TYPE,
                 ID.REAL_AMOUNT,
                 V_CURR_PRIN_BAL,
                 V_INTR_CHG_ON_PRIN,
                 V_TOT_INTR_BAL,
                 V_TOT_BAL,
                 ID.ENTD_BY,
                 ID.ENTD_ON);
            
              UPDATE ELMS_LN_SUMMARY S
                 SET S.PRIN_BALANCE = V_CURR_PRIN_BAL,
                     S.INT_BALANCE  = V_TOT_INTR_BAL,
                     S.TOT_BALANCE  = V_TOT_BAL
               WHERE S.ENTITY_NUM = P_ENTITY_NUM
                 AND S.EMP_ID = IDX.EMP_ID
                 AND S.LOAN_TYPE = P_LOAN_TYPE;
            EXCEPTION
              WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('inserting error for ' || IDX.EMP_ID || '-' ||
                                     IDX.LOAN_TYPE || '-' || IDX.REAL_DATE);
            END;
          END IF;
        END LOOP;
      ELSE
        /*FOR SINGLE ADJUSTMENT IN A MONTH*/
        FOR ID IN (SELECT *
                     FROM ELMS_REALIZATION R
                    WHERE R.ENTITY_NUM = IDX.ENTITY_NUM
                      AND R.REAL_YEAR = IDX.REAL_YEAR
                      AND R.REAL_MONTH_CODE = IDX.REAL_MONTH_CODE
                      AND R.LOAN_TYPE = IDX.LOAN_TYPE
                      AND R.EMP_ID = IDX.EMP_ID
                    ORDER BY R.REAL_DATE) LOOP
        
          BEGIN
            SELECT NVL(R.PRIN_BALANCE, 0), NVL(R.INT_BALANCE, 0)
              INTO V_PREV_PRIN_BAL, V_PREV_INT_BAL
              FROM ELMS_LN_SUMMARY R
             WHERE R.ENTITY_NUM = P_ENTITY_NUM
               AND R.EMP_ID = ID.EMP_ID
               AND R.LOAN_TYPE = ID.LOAN_TYPE;
          EXCEPTION
            WHEN OTHERS THEN
              V_PREV_PRIN_BAL := 0;
              V_PREV_INT_BAL  := 0;
          END;
        
          IF (V_PREV_PRIN_BAL + V_PREV_INT_BAL) > 0 OR ID.REAL_AMOUNT > 0 THEN
            
            IF (NVL(V_PREV_PRIN_BAL, 0) > 0 AND  NVL(V_PREV_PRIN_BAL, 0) - NVL(ID.REAL_AMOUNT, 0) > 0) THEN
              /*REALIZATION FOR ONLY PRINCIPAL*/
              V_REAL_TYPE := 'P';
              IF ID.DR_CR_TYPE = 'C' THEN
                V_CURR_PRIN_BAL := ROUND((V_PREV_PRIN_BAL - NVL(ID.REAL_AMOUNT, 0)), 2);
              ELSE
                V_CURR_PRIN_BAL := ROUND((V_PREV_PRIN_BAL +NVL(ID.REAL_AMOUNT, 0)), 2);
              END IF;
            
            ELSIF (NVL(V_PREV_PRIN_BAL, 0) > 0 AND
                  NVL(V_PREV_PRIN_BAL, 0) - NVL(ID.REAL_AMOUNT, 0) < 0) THEN
              V_REAL_TYPE := 'B';
              /*REALIZATION FOR PRINCIPAL & INTEREST*/
              IF ID.DR_CR_TYPE = 'C' THEN
                V_TEMP_BAL      := ROUND((NVL(ID.REAL_AMOUNT, 0) -
                                         NVL(V_PREV_PRIN_BAL, 0)),
                                         2);
                V_CURR_PRIN_BAL := 0;
                V_CURR_INTR_BAL := ROUND((V_PREV_INT_BAL -
                                         NVL(V_TEMP_BAL, 0)),
                                         2);
              ELSE
                V_CURR_PRIN_BAL := ROUND((V_PREV_PRIN_BAL +
                                         NVL(ID.REAL_AMOUNT, 0)),
                                         2);
              END IF;
            
            ELSIF (NVL(V_PREV_PRIN_BAL, 0) = 0 AND
                  NVL(V_PREV_INT_BAL, 0) - NVL(ID.REAL_AMOUNT, 0) > 0) THEN
              /*REALIZATION FOR ONLY INTEREST*/
              V_REAL_TYPE := 'I';
              IF ID.DR_CR_TYPE = 'C' THEN
                V_CURR_INTR_BAL := ROUND((V_PREV_INT_BAL -
                                         NVL(ID.REAL_AMOUNT, 0)),
                                         2);
              ELSE
                V_CURR_PRIN_BAL := ROUND((V_CURR_PRIN_BAL +
                                         NVL(ID.REAL_AMOUNT, 0)),
                                         2);
              END IF;
            
            ELSIF NVL(V_PREV_PRIN_BAL, 0) = 0 AND
                  (NVL(V_PREV_INT_BAL, 0) = 0 OR
                   NVL(V_PREV_INT_BAL, 0) - NVL(ID.REAL_AMOUNT, 0) < 0) THEN
              /*NEITHER PRINCIPLE NOR INTEREST*/
              V_REAL_TYPE := 'X';
              IF ID.DR_CR_TYPE = 'C' THEN
                V_CURR_PRIN_BAL := ROUND((V_CURR_PRIN_BAL -
                                         NVL(ID.REAL_AMOUNT, 0)),
                                         2);
              ELSE
                V_CURR_INTR_BAL := V_PREV_INT_BAL;
                V_CURR_PRIN_BAL := ROUND((V_CURR_PRIN_BAL +
                                         NVL(ID.REAL_AMOUNT, 0)),
                                         2);
              END IF;
            END IF;
          
            IF ID.REL_SL = V_ROW_COUNT THEN
              SELECT EXTRACT(DAY FROM ID.REAL_DATE) - 1
                INTO V_DAYS_COUNT1
                FROM DUAL;
              V_DAYS_COUNT1 := V_DAYS_COUNT1 - TEMP_DAYS;
              SELECT EXTRACT(DAY FROM LAST_DAY(TRUNC(ID.REAL_DATE)))
                INTO V_DAYS_COUNT
                FROM DUAL;
              V_DAYS_COUNT2 := V_DAYS_COUNT - (V_DAYS_COUNT1 + TEMP_DAYS);
            ELSE
              SELECT EXTRACT(DAY FROM ID.REAL_DATE) - 1
                INTO V_DAYS_COUNT1
                FROM DUAL;
              V_DAYS_COUNT1 := V_DAYS_COUNT1 - TEMP_DAYS;
              V_DAYS_COUNT2 := 0;
            END IF;
          
            TEMP_DAYS := TEMP_DAYS + V_DAYS_COUNT1;
          
            IF NVL(V_PREV_PRIN_BAL, 0) = 0 AND NVL(V_PREV_INT_BAL, 0) = 0 THEN
              V_DAYS_COUNT1 := 0;
            END IF;
          
            V_INTR_CHG_ON_PRIN := ROUND((ROUND((V_PREV_PRIN_BAL *
                                               V_INT_RATE) *
                                               (V_DAYS_COUNT1 / V_DAYS),
                                               2) +
                                        ROUND((V_CURR_PRIN_BAL *
                                               V_INT_RATE) *
                                               (V_DAYS_COUNT2 / V_DAYS),
                                               2)),
                                        2);
          
            IF V_INTR_CHG_ON_PRIN = 0 THEN
              V_TOT_INTR_BAL := V_CURR_INTR_BAL;
            ELSE
              V_TOT_INTR_BAL := ROUND((V_INTR_CHG_ON_PRIN + V_PREV_INT_BAL),
                                      2);
            END IF;
          
            V_TOT_BAL := ROUND((V_TOT_INTR_BAL + V_CURR_PRIN_BAL), 2);
          
            BEGIN
              INSERT INTO ELMS_LN_LEDGER
                (ENTITY_NUM,
                 EMP_ID,
                 LOAN_TYPE,
                 REAL_YEAR,
                 REAL_MONTH_CODE,
                 REL_SL,
                 REAL_DATE,
                 REAL_TYPE,
                 DR_CR_TYPE,
                 VOUCHAR_TYPE,
                 REAL_AMOUNT,
                 PRIN_BALANCE,
                 INT_CHARGED,
                 INT_BALANCE,
                 TOT_BALANCE,
                 ENTD_BY,
                 ENTD_ON)
              VALUES
                (ID.ENTITY_NUM,
                 ID.EMP_ID,
                 ID.LOAN_TYPE,
                 ID.REAL_YEAR,
                 ID.REAL_MONTH_CODE,
                 ID.REL_SL,
                 ID.REAL_DATE,
                 V_REAL_TYPE,
                 ID.DR_CR_TYPE,
                 ID.VOUCHAR_TYPE,
                 ID.REAL_AMOUNT,
                 V_CURR_PRIN_BAL,
                 V_INTR_CHG_ON_PRIN,
                 V_TOT_INTR_BAL,
                 V_TOT_BAL,
                 ID.ENTD_BY,
                 ID.ENTD_ON);
            
              UPDATE ELMS_LN_SUMMARY S
                 SET S.PRIN_BALANCE = V_CURR_PRIN_BAL,
                     S.INT_BALANCE  = V_TOT_INTR_BAL,
                     S.TOT_BALANCE  = V_TOT_BAL
               WHERE S.ENTITY_NUM = P_ENTITY_NUM
                 AND S.EMP_ID = IDX.EMP_ID
                 AND S.LOAN_TYPE = P_LOAN_TYPE;
            EXCEPTION
              WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('inserting error for ' || IDX.EMP_ID || '-' ||
                                     IDX.LOAN_TYPE || '-' || IDX.REAL_DATE);
            END;
          END IF;
        END LOOP;
      END IF;
    
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      P_ERROR := '';
  END SP_ACCRUAL_PROCESS;

  /*
  
  SELECT MONTH_NAME,
       TO_CHAR(REAL_DATE) REAL_DATE,
       DECODE(REAL_TYPE, 'P', 'Principle', 'I', 'Interest', '') REAL_TYPE,
       DECODE(DR_CR_TYPE, 'D', 'Debit', 'C', 'Credit', '') DR_CR_TYPE,
       DECODE(VOUCHAR_TYPE, 'V', 'Voucher', 'D','Disburse','N','Normal') VOUCHAR_TYPE,
       REAL_AMT,
       PRIN_BAL,
       INT_CHARGED,
       INT_BAL,
       TOT_BAL
  FROM TABLE(PKG_ELMS.FN_LOAN_DATA(1, '979', 'HBL', '2017-2018', '30-JUN-2019'))
  
  
  */
  FUNCTION FN_LOAN_DISB_AMT(P_ENTITY    IN NUMBER,
                            P_EMP_ID    IN VARCHAR2,
                            P_LOAN_TYPE IN VARCHAR2) RETURN NUMBER IS
    V_DISB_AMT NUMBER(13, 2) := 0;
  BEGIN
    SELECT NVL(SUM(D.DISB_AMOUNT), 0)
      INTO V_DISB_AMT
      FROM ELMS_DISBURSE D
     WHERE D.ENTITY_NUM = P_ENTITY
       AND D.EMP_ID = P_EMP_ID
       AND D.LOAN_TYPE = P_LOAN_TYPE;
  
    RETURN V_DISB_AMT;
  END FN_LOAN_DISB_AMT;
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

  FUNCTION FN_LOAN_INT_RATE(P_ENTITY    IN NUMBER,
                            P_EMP_ID    IN VARCHAR2,
                            P_LOAN_TYPE IN VARCHAR2) RETURN NUMBER IS
    V_INT_RATE NUMBER(5, 2) := 0;
  BEGIN
  
    SELECT D.INT_RATE
      INTO V_INT_RATE
      FROM ELMS_DISBURSE D
     WHERE D.ENTITY_NUM = P_ENTITY
       AND D.EMP_ID = P_EMP_ID
       AND D.LOAN_TYPE = P_LOAN_TYPE
       AND D.DISB_SL = (SELECT MAX(D.DISB_SL)
                          FROM ELMS_DISBURSE D
                         WHERE D.ENTITY_NUM = P_ENTITY
                           AND D.EMP_ID = P_EMP_ID
                           AND D.LOAN_TYPE = P_LOAN_TYPE);
    RETURN V_INT_RATE;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN V_INT_RATE;
  END FN_LOAN_INT_RATE;
  FUNCTION FN_LOAN_DATA(P_ENTITY      IN NUMBER,
                        P_BRANCH_CODE IN VARCHAR2,
                        P_EMP_ID      IN VARCHAR2,
                        P_LOAN_TYPE   IN VARCHAR2,
                        P_FIN_YEAR    IN VARCHAR2,
                        P_TO_DATE     IN DATE) RETURN V_DATA
    PIPELINED IS
    V_LOAN_DATA     DATA;
    V_TO_MONTH_CODE NUMBER(2);
    V_TO_YEAR       NUMBER(4);
    V_FROM_DATE     VARCHAR2(20) := '01-JUL-';
    V_TO_DATE       VARCHAR2(20) := '30-JUN-';
    Q_FROM_YEAR     VARCHAR2(4) := '';
    Q_TO_YEAR       VARCHAR2(4) := '';
    W_FROM_DATE     DATE;
    W_TO_DATE       DATE;
    V_YEAR          NUMBER(4);
    V_BF            BOOLEAN := TRUE;
  
    FUNCTION FN_MONTH_NAME(P_MONTH_CODE IN NUMBER) RETURN VARCHAR2 IS
      V_MONTH_NAME VARCHAR2(10);
    BEGIN
      SELECT DECODE(P_MONTH_CODE,
                    1,
                    'JANUARY',
                    2,
                    'FEBRUARY',
                    3,
                    'MARCH',
                    4,
                    'APRIL',
                    5,
                    'MAY',
                    6,
                    'JUNE',
                    7,
                    'JULY',
                    8,
                    'AUGUST',
                    9,
                    'SEPTEMBER',
                    10,
                    'OCTOBER',
                    11,
                    'NOVEMBER',
                    12,
                    'DECEMBER')
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
      V_FROM_DATE := V_FROM_DATE || Q_FROM_YEAR;
      V_TO_DATE   := V_TO_DATE || Q_TO_YEAR;
    
      W_FROM_DATE := TO_DATE(V_FROM_DATE);
      W_TO_DATE   := TO_DATE(V_TO_DATE);
    ELSE
      SELECT TO_NUMBER(TO_CHAR(TO_DATE(P_TO_DATE, 'dd-mon-yy'), 'mm'))
        INTO V_TO_MONTH_CODE
        FROM DUAL;
      SELECT TO_NUMBER(TO_CHAR(P_TO_DATE, 'YYYY'))
        INTO V_TO_YEAR
        FROM DUAL;
    
      IF V_TO_MONTH_CODE > 6 THEN
        V_YEAR := V_TO_YEAR;
      ELSE
        V_YEAR := V_TO_YEAR - 1;
      END IF;
    
      V_FROM_DATE := V_FROM_DATE || (V_YEAR);
      W_FROM_DATE := TO_DATE(V_FROM_DATE);
      W_TO_DATE   := P_TO_DATE;
    END IF;
    V_LOAN_DATA.FIN_YEAR := P_FIN_YEAR;
    IF P_EMP_ID IS NULL THEN
      FOR ID IN (SELECT *
                   FROM ELMS_LN_LEDGER R
                  WHERE R.ENTITY_NUM = P_ENTITY
                       --  AND R.EMP_ID = P_EMP_ID
                    AND R.LOAN_TYPE = P_LOAN_TYPE
                    AND R.REAL_DATE BETWEEN W_FROM_DATE AND W_TO_DATE) LOOP
      
        V_LOAN_DATA.EMPLOYEE_ID   := ID.EMP_ID;
        V_LOAN_DATA.DISBURSE_AMT  := FN_LOAN_DISB_AMT(P_ENTITY,
                                                      ID.EMP_ID,
                                                      P_LOAN_TYPE);
        V_LOAN_DATA.YEAR          := ID.REAL_YEAR;
        V_LOAN_DATA.INTEREST_RATE := FN_LOAN_INT_RATE(P_ENTITY,
                                                      ID.EMP_ID,
                                                      P_LOAN_TYPE);
        V_LOAN_DATA.DESIGNATION   := FN_DESIGNATION(ID.EMP_ID);
      
        IF V_BF = TRUE THEN
          V_LOAN_DATA.MONTH_NAME := 'BF';
          SELECT L.PRIN_BALANCE, L.INT_BALANCE, L.TOT_BALANCE
            INTO V_LOAN_DATA.PRIN_BAL,
                 V_LOAN_DATA.INT_BAL,
                 V_LOAN_DATA.TOT_BAL
            FROM ELMS_LN_LEDGER L
           WHERE L.ENTITY_NUM = P_ENTITY
             AND L.EMP_ID = ID.EMP_ID
             AND L.LOAN_TYPE = ID.LOAN_TYPE
             AND L.REAL_YEAR = Q_FROM_YEAR
             AND L.REAL_MONTH_CODE = 6;
          PIPE ROW(V_LOAN_DATA);
          V_BF := FALSE;
        END IF;
      
        V_LOAN_DATA.FIN_YEAR     := P_FIN_YEAR;
        V_LOAN_DATA.MONTH_CODE   := ID.REAL_MONTH_CODE;
        V_LOAN_DATA.MONTH_NAME   := FN_MONTH_NAME(ID.REAL_MONTH_CODE);
        V_LOAN_DATA.DR_CR_TYPE   := ID.DR_CR_TYPE;
        V_LOAN_DATA.REAL_TYPE    := ID.REAL_TYPE;
        V_LOAN_DATA.VOUCHAR_TYPE := ID.VOUCHAR_TYPE;
        V_LOAN_DATA.REAL_DATE    := ID.REAL_DATE;
        V_LOAN_DATA.REAL_AMT     := ID.REAL_AMOUNT;
        V_LOAN_DATA.PRIN_BAL     := ID.PRIN_BALANCE;
        V_LOAN_DATA.INT_CHARGED  := ID.INT_CHARGED;
        V_LOAN_DATA.INT_BAL      := ID.INT_BALANCE;
        V_LOAN_DATA.TOT_BAL      := ID.TOT_BALANCE;
      
        PIPE ROW(V_LOAN_DATA);
      END LOOP;
    ELSE
      FOR ID IN (SELECT *
                   FROM ELMS_LN_LEDGER R
                  WHERE R.ENTITY_NUM = P_ENTITY
                    AND R.EMP_ID = P_EMP_ID
                    AND R.LOAN_TYPE = P_LOAN_TYPE
                    AND R.REAL_DATE BETWEEN W_FROM_DATE AND W_TO_DATE) LOOP
      
        V_LOAN_DATA.EMPLOYEE_ID   := ID.EMP_ID;
        V_LOAN_DATA.DISBURSE_AMT  := FN_LOAN_DISB_AMT(P_ENTITY,
                                                      ID.EMP_ID,
                                                      P_LOAN_TYPE);
        V_LOAN_DATA.YEAR          := ID.REAL_YEAR;
        V_LOAN_DATA.INTEREST_RATE := FN_LOAN_INT_RATE(P_ENTITY,
                                                      ID.EMP_ID,
                                                      P_LOAN_TYPE);
        V_LOAN_DATA.DESIGNATION   := FN_DESIGNATION(ID.EMP_ID);
      
        IF V_BF = TRUE THEN
          V_LOAN_DATA.MONTH_NAME := 'BF';
          SELECT L.PRIN_BALANCE, L.INT_BALANCE, L.TOT_BALANCE
            INTO V_LOAN_DATA.PRIN_BAL,
                 V_LOAN_DATA.INT_BAL,
                 V_LOAN_DATA.TOT_BAL
            FROM ELMS_LN_LEDGER L
           WHERE L.ENTITY_NUM = P_ENTITY
             AND L.EMP_ID = ID.EMP_ID
             AND L.LOAN_TYPE = ID.LOAN_TYPE
             AND L.REAL_YEAR = Q_FROM_YEAR
             AND L.REAL_MONTH_CODE = 6;
          PIPE ROW(V_LOAN_DATA);
          V_BF := FALSE;
        END IF;
      
        IF ID.REAL_YEAR || '-' || ID.REAL_MONTH_CODE <>
           Q_FROM_YEAR || '-' || 6 THEN
          V_LOAN_DATA.FIN_YEAR     := P_FIN_YEAR;
          V_LOAN_DATA.MONTH_CODE   := ID.REAL_MONTH_CODE;
          V_LOAN_DATA.MONTH_NAME   := FN_MONTH_NAME(ID.REAL_MONTH_CODE);
          V_LOAN_DATA.DR_CR_TYPE   := ID.DR_CR_TYPE;
          V_LOAN_DATA.REAL_TYPE    := ID.REAL_TYPE;
          V_LOAN_DATA.VOUCHAR_TYPE := ID.VOUCHAR_TYPE;
          V_LOAN_DATA.REAL_DATE    := ID.REAL_DATE;
          V_LOAN_DATA.REAL_AMT     := ID.REAL_AMOUNT;
          V_LOAN_DATA.PRIN_BAL     := ID.PRIN_BALANCE;
          V_LOAN_DATA.INT_CHARGED  := ID.INT_CHARGED;
          V_LOAN_DATA.INT_BAL      := ID.INT_BALANCE;
          V_LOAN_DATA.TOT_BAL      := ID.TOT_BALANCE;
        
          PIPE ROW(V_LOAN_DATA);
        END IF;
      END LOOP;
    END IF;
  END FN_LOAN_DATA;
BEGIN
  -- INITIALIZATION
  NULL;
END PKG_ELMS;
/
