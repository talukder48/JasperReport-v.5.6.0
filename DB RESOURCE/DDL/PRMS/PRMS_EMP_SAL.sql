-- Create table
create table PRMS_EMP_SAL
(
  emp_id               VARCHAR2(20) not null,
  emp_brn_code         VARCHAR2(5),
  desig_code           NUMBER(2),
  desig                VARCHAR2(30),
  desig_seniority_code NUMBER(3),
  status_code          VARCHAR2(3),
  pf_deduction_pct     NUMBER(5,2),
  medical_allowance    NUMBER(7,2),
  sq_residence         VARCHAR2(1),
  pf_lien              VARCHAR2(1),
  payment_bank         VARCHAR2(1),
  acc_no_active        VARCHAR2(1),
  emp_category         NUMBER(1),
  bank_acc             VARCHAR2(25),
  dearness_pct         NUMBER(5,2),
  pen_pct              NUMBER(5,2),
  arrear_basic         NUMBER(9,2),
  new_basic            NUMBER(9,2),
  bonus_yn             VARCHAR2(1),
  hbfc_own             VARCHAR2(1),
  entd_by              VARCHAR2(15),
  entd_on              DATE,
  mod_by               VARCHAR2(15),
  mod_on               DATE,
  transfer_date        DATE,
  emp_dept_code        NUMBER(3)
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
alter table PRMS_EMP_SAL
  add primary key (EMP_ID)
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
