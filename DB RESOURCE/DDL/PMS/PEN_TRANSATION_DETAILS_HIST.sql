-- Create table
create table PEN_TRANSATION_DETAILS_HIST
(
  entity_num         NUMBER(4) not null,
  bk_date            DATE not null,
  year               NUMBER(4) not null,
  month_code         NUMBER(6) not null,
  nothi_no           VARCHAR2(25) not null,
  emp_id             VARCHAR2(10),
  emp_name           VARCHAR2(50) not null,
  district           VARCHAR2(15),
  tran_sl            NUMBER(4) not null,
  acc_type           CHAR(1),
  designation        VARCHAR2(30),
  pension_basic      NUMBER(12,2),
  pension_arrear     NUMBER(12,2),
  pen_medical_alw    NUMBER(12,2),
  pen_medical_arear  NUMBER(12,2),
  pen_bonus          NUMBER(12,2),
  pen_bonus_arear    NUMBER(12,2),
  others_alw         NUMBER(12,2),
  remarks_others_alw VARCHAR2(4000),
  hb_ded_pct         NUMBER(6,2),
  hb_ded_amount      NUMBER(12,2),
  com_ded_amt        NUMBER(12,2),
  mot_ded_amt        NUMBER(12,2),
  others_ded_amt     NUMBER(12,2),
  remarks_others_ded VARCHAR2(4000),
  revnue             NUMBER(5,2),
  gross_amount       NUMBER(12,2),
  total_deduction    NUMBER(12,2),
  net_payment        NUMBER(12,2),
  bank_name          VARCHAR2(70),
  branch_name        VARCHAR2(80),
  bank_account       VARCHAR2(20),
  dearness           NUMBER(12,2),
  arr_dearness       NUMBER(12,2),
  noborsho           NUMBER(12,2),
  branch_location    VARCHAR2(100),
  sucessor_name      VARCHAR2(80),
  activation_type    CHAR(1),
  activationtype     CHAR(1)
)
tablespace INNOVATION
  pctfree 10
  initrans 1
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );
-- Create/Recreate primary, unique and foreign key constraints 
alter table PEN_TRANSATION_DETAILS_HIST
  add primary key (ENTITY_NUM, BK_DATE, YEAR, MONTH_CODE, NOTHI_NO, TRAN_SL)
  using index 
  tablespace INNOVATION
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );
