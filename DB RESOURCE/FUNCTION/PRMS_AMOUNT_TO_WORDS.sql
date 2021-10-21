CREATE OR REPLACE FUNCTION PRMS_AMOUNT_TO_WORDS(P_AMOUNT IN NUMBER) RETURN VARCHAR2 IS

  -------------------------------------
  -- INDEX BY TABLES TO STORE WORD LIST
  -------------------------------------
  TYPE TYP_WORD_LIST IS TABLE OF VARCHAR2(200) INDEX BY BINARY_INTEGER;
  T_TYP_WORD_LIST TYP_WORD_LIST;
  TYPE TYP_WORD_GAP IS TABLE OF VARCHAR2(200) INDEX BY BINARY_INTEGER;
  T_TYP_WORD_GAP TYP_WORD_GAP;
  ------------------
  -- LOCAL VARIABLES
  ------------------
  V_AMOUNT        NUMBER := P_AMOUNT;
  V_AMOUNT_LENGTH NUMBER;
  V_WORDS         VARCHAR2(10000);
  V_POINT_FOUND   VARCHAR2(1) := 'N';
  V_POINT_VALUE   NUMBER;
BEGIN
  /*GETTING VALUE AFTER POINT IF FOUND */
  V_POINT_VALUE := SUBSTR(V_AMOUNT, (INSTR(V_AMOUNT, '.', 1) + 1), 2);

  /*CHECKING WHETHER AMOUNT HAS ANY SCALE VALUE ALSO */
  V_POINT_FOUND := CASE
                     WHEN (INSTR(V_AMOUNT, '.', 1)) = 0 THEN
                      'N'
                     WHEN (INSTR(V_AMOUNT, '.', 1)) > 0 THEN
                      'Y'
                   END;
  /*CONVERTING AMOUNT INTO PURE NUMERIC FORMAT */
  V_AMOUNT := FLOOR(ABS(V_AMOUNT));

  --
  V_AMOUNT_LENGTH := LENGTH(V_AMOUNT);
  --
  T_TYP_WORD_GAP(2) := 'and Paisa';
  T_TYP_WORD_GAP(3) := 'Hundred';
  T_TYP_WORD_GAP(4) := 'Thousand';
  T_TYP_WORD_GAP(6) := 'Lakh';
  T_TYP_WORD_GAP(8) := 'Crore';
  T_TYP_WORD_GAP(10) := 'Arab';
  --
  FOR I IN 1 .. 99 LOOP
    T_TYP_WORD_LIST(I) := TO_CHAR(TO_DATE(I, 'J'), 'Jsp');
  END LOOP;
  --
  IF V_AMOUNT_LENGTH <= 2 THEN
    /* CONVERSION 1 TO 99 DIGITS */
    V_WORDS := T_TYP_WORD_LIST(V_AMOUNT);
  ELSIF V_AMOUNT_LENGTH = 3 THEN
    /* CONVERSION FOR 3 DIGITS TILL 999 */
    V_WORDS := T_TYP_WORD_LIST(SUBSTR(V_AMOUNT, 1, 1)) || ' ' ||
               T_TYP_WORD_GAP(3);
    V_WORDS := V_WORDS || ' ' || T_TYP_WORD_LIST(SUBSTR(V_AMOUNT, 2, 2));
  ELSIF V_AMOUNT_LENGTH = 4 THEN
    /* CONVERSION FOR 4 DIGITS TILL 9999 */
    V_WORDS := T_TYP_WORD_LIST(SUBSTR(V_AMOUNT, 1, 1)) || ' ' ||
               T_TYP_WORD_GAP(4);
    IF SUBSTR(V_AMOUNT, 2, 1) != 0 THEN
      V_WORDS := V_WORDS || ' ' || T_TYP_WORD_LIST(SUBSTR(V_AMOUNT, 2, 1)) || ' ' ||
                 T_TYP_WORD_GAP(3);
    END IF;
    IF SUBSTR(V_AMOUNT, 3, 2) != 0 THEN
      V_WORDS := V_WORDS || ' ' || T_TYP_WORD_LIST(SUBSTR(V_AMOUNT, 3, 2));
    END IF;
  ELSIF V_AMOUNT_LENGTH = 5 THEN
    /* CONVERSION FOR 5 DIGITS TILL 99999 */
    V_WORDS := T_TYP_WORD_LIST(SUBSTR(V_AMOUNT, 1, 2)) || ' ' ||
               T_TYP_WORD_GAP(4);
    IF SUBSTR(V_AMOUNT, 3, 1) != 0 THEN
      V_WORDS := V_WORDS || ' ' || T_TYP_WORD_LIST(SUBSTR(V_AMOUNT, 3, 1)) || ' ' ||
                 T_TYP_WORD_GAP(3);
    END IF;
    IF SUBSTR(V_AMOUNT, 4, 2) != 0 THEN
      V_WORDS := V_WORDS || ' ' || T_TYP_WORD_LIST(SUBSTR(V_AMOUNT, 4, 2));
    END IF;

  ELSIF V_AMOUNT_LENGTH = 6 THEN
    /* CONVERSION FOR 6 DIGITS TILL 999999 */
    V_WORDS := T_TYP_WORD_LIST(SUBSTR(V_AMOUNT, 1, 1)) || ' ' ||
               T_TYP_WORD_GAP(6);
    IF SUBSTR(V_AMOUNT, 2, 2) != 0 THEN
      V_WORDS := V_WORDS || ' ' || T_TYP_WORD_LIST(SUBSTR(V_AMOUNT, 2, 2)) || ' ' ||
                 T_TYP_WORD_GAP(4);
    END IF;
    IF SUBSTR(V_AMOUNT, 4, 1) != 0 THEN
      V_WORDS := V_WORDS || ' ' || T_TYP_WORD_LIST(SUBSTR(V_AMOUNT, 4, 1)) || ' ' ||
                 T_TYP_WORD_GAP(3);
    END IF;
    IF SUBSTR(V_AMOUNT, 5, 2) != 0 THEN
      V_WORDS := V_WORDS || ' ' || T_TYP_WORD_LIST(SUBSTR(V_AMOUNT, 5, 2));
    END IF;
  ELSIF V_AMOUNT_LENGTH = 7 THEN
    /* CONVERSION FOR 7 DIGITS TILL 9999999 */
    V_WORDS := T_TYP_WORD_LIST(SUBSTR(V_AMOUNT, 1, 2)) || ' ' ||
               T_TYP_WORD_GAP(6);
    IF SUBSTR(V_AMOUNT, 3, 2) != 0 THEN
      V_WORDS := V_WORDS || ' ' || T_TYP_WORD_LIST(SUBSTR(V_AMOUNT, 3, 2)) || ' ' ||
                 T_TYP_WORD_GAP(4);
    END IF;
    IF SUBSTR(V_AMOUNT, 5, 1) != 0 THEN
      V_WORDS := V_WORDS || ' ' || T_TYP_WORD_LIST(SUBSTR(V_AMOUNT, 5, 1)) || ' ' ||
                 T_TYP_WORD_GAP(3);
    END IF;
    IF SUBSTR(V_AMOUNT, 6, 2) != 0 THEN
      V_WORDS := V_WORDS || ' ' || T_TYP_WORD_LIST(SUBSTR(V_AMOUNT, 6, 2));
    END IF;
  ELSIF V_AMOUNT_LENGTH = 8 THEN
    /* CONVERSION FOR 8 DIGITS TILL 99999999 */
    V_WORDS := T_TYP_WORD_LIST(SUBSTR(V_AMOUNT, 1, 1)) || ' ' ||
               T_TYP_WORD_GAP(8);
    IF SUBSTR(V_AMOUNT, 2, 2) != 0 THEN
      V_WORDS := V_WORDS || ' ' || T_TYP_WORD_LIST(SUBSTR(V_AMOUNT, 2, 2)) || ' ' ||
                 T_TYP_WORD_GAP(6);
    END IF;
    IF SUBSTR(V_AMOUNT, 4, 2) != 0 THEN
      V_WORDS := V_WORDS || ' ' || T_TYP_WORD_LIST(SUBSTR(V_AMOUNT, 4, 2)) || ' ' ||
                 T_TYP_WORD_GAP(4);
    END IF;
    IF SUBSTR(V_AMOUNT, 6, 1) != 0 THEN
      V_WORDS := V_WORDS || ' ' || T_TYP_WORD_LIST(SUBSTR(V_AMOUNT, 6, 1)) || ' ' ||
                 T_TYP_WORD_GAP(3);
    END IF;
    IF SUBSTR(V_AMOUNT, 7, 2) != 0 THEN
      V_WORDS := V_WORDS || ' ' || T_TYP_WORD_LIST(SUBSTR(V_AMOUNT, 7, 2));
    END IF;
  ELSIF V_AMOUNT_LENGTH = 9 THEN
    /* CONVERSION FOR 9 DIGITS TILL 999999999 */
    V_WORDS := T_TYP_WORD_LIST(SUBSTR(V_AMOUNT, 1, 2)) || ' ' ||
               T_TYP_WORD_GAP(8);
    IF SUBSTR(V_AMOUNT, 3, 2) != 0 THEN
      V_WORDS := V_WORDS || ' ' || T_TYP_WORD_LIST(SUBSTR(V_AMOUNT, 3, 2)) || ' ' ||
                 T_TYP_WORD_GAP(6);
    END IF;
    IF SUBSTR(V_AMOUNT, 5, 2) != 0 THEN
      V_WORDS := V_WORDS || ' ' || T_TYP_WORD_LIST(SUBSTR(V_AMOUNT, 5, 2)) || ' ' ||
                 T_TYP_WORD_GAP(4);
    END IF;
    IF SUBSTR(V_AMOUNT, 7, 1) != 0 THEN
      V_WORDS := V_WORDS || ' ' || T_TYP_WORD_LIST(SUBSTR(V_AMOUNT, 7, 1)) || ' ' ||
                 T_TYP_WORD_GAP(3);
    END IF;
    IF SUBSTR(V_AMOUNT, 8, 2) != 0 THEN
      V_WORDS := V_WORDS || ' ' || T_TYP_WORD_LIST(SUBSTR(V_AMOUNT, 8, 2));
    END IF;
  ELSIF V_AMOUNT_LENGTH = 10 THEN
    /* CONVERSION FOR 10 DIGITS TILL 9999999999 */
    V_WORDS := T_TYP_WORD_LIST(SUBSTR(V_AMOUNT, 1, 1)) || ' ' ||
               T_TYP_WORD_GAP(10);
    IF SUBSTR(V_AMOUNT, 2, 2) != 0 THEN
      V_WORDS := V_WORDS || ' ' || T_TYP_WORD_LIST(SUBSTR(V_AMOUNT, 2, 2)) || ' ' ||
                 T_TYP_WORD_GAP(8);
    END IF;
    IF SUBSTR(V_AMOUNT, 4, 2) != 0 THEN
      V_WORDS := V_WORDS || ' ' || T_TYP_WORD_LIST(SUBSTR(V_AMOUNT, 4, 2)) || ' ' ||
                 T_TYP_WORD_GAP(6);
    END IF;
    IF SUBSTR(V_AMOUNT, 6, 2) != 0 THEN
      V_WORDS := V_WORDS || ' ' || T_TYP_WORD_LIST(SUBSTR(V_AMOUNT, 6, 2)) || ' ' ||
                 T_TYP_WORD_GAP(4);
    END IF;
    IF SUBSTR(V_AMOUNT, 8, 1) != 0 THEN
      V_WORDS := V_WORDS || ' ' || T_TYP_WORD_LIST(SUBSTR(V_AMOUNT, 8, 1)) || ' ' ||
                 T_TYP_WORD_GAP(3);
    END IF;
    IF SUBSTR(V_AMOUNT, 9, 2) != 0 THEN
      V_WORDS := V_WORDS || ' ' || T_TYP_WORD_LIST(SUBSTR(V_AMOUNT, 9, 2));
    END IF;
  END IF;
  --
  IF V_POINT_FOUND = 'Y' THEN
    IF V_POINT_VALUE != 0 THEN
      V_WORDS := V_WORDS || ' ' || T_TYP_WORD_GAP(2) || ' ' ||
                 T_TYP_WORD_LIST(CASE
                                   WHEN LENGTH(SUBSTR(P_AMOUNT, (INSTR(P_AMOUNT, '.', 1) + 1), 2)) = 1 THEN
                                    SUBSTR(P_AMOUNT, (INSTR(P_AMOUNT, '.', 1) + 1), 2) || '0'
                                   WHEN LENGTH(SUBSTR(P_AMOUNT, (INSTR(P_AMOUNT, '.', 1) + 1), 2)) = 2 THEN
                                    SUBSTR(P_AMOUNT, (INSTR(P_AMOUNT, '.', 1) + 1), 2)
                                 END);
    END IF;
  END IF;
  --
  IF P_AMOUNT < 0 THEN
    V_WORDS := 'Minus ' || V_WORDS;
  ELSIF P_AMOUNT = 0 THEN
    V_WORDS := 'Zero';
  END IF;
  IF LENGTH(V_AMOUNT) > 10 THEN
    V_WORDS := 'Value larger than specified precision allowed to convert into words. Maximum 10 digits allowed for precision.';
  END IF;
  RETURN(V_WORDS);

END PRMS_AMOUNT_TO_WORDS;
/
