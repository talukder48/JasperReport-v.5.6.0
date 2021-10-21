CREATE TABLE ELMS_PF_ADVANCE(
      ENTITY_NUM          NUMBER (4),
      EMP_ID              VARCHAR2(20) NOT NULL, 
      ADV_SL_NO           NUMBER(3),     
      PF_ADV_AMT_1        NUMBER(9,2),
      PF_ADV_INS_AMT_1    NUMBER(9,2),
      PF_ADV_AMT_2        NUMBER(9,2),
      PF_ADV_INS_AMT_2    NUMBER(9,2),
      PF_ADV_AMT_3        NUMBER(9,2),  
      PF_ADV_INS_AMT_3    NUMBER(9,2),
      ENTY_BY             VARCHAR2(20),
      ENTY_ON             DATE,
      MODY_BY             VARCHAR2(20),
      MODE_ON             DATE      
);
ALTER TABLE ELMS_PF_ADVANCE ADD PRIMARY KEY (ENTITY_NUM,EMP_ID,ADV_SL_NO);
