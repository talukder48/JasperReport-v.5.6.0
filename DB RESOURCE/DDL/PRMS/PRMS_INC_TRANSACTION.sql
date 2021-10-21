-- Create table
create table PRMS_INC_TRANSACTION
(
  emp_id               VARCHAR2(10) not null,
  branch_code          VARCHAR2(10) not null,
  fin_year             VARCHAR2(12) not null,
  emp_name             VARCHAR2(80),
  designation          VARCHAR2(50),
  inc_basic            NUMBER(12,2),
  total_inc_amount     NUMBER(12,2),
  revenue              NUMBER(12,2),
  net_inc_pay          NUMBER(12,2),
  bank_account         VARCHAR2(20),
  incentive_pct        NUMBER(12,2),
  orderno              VARCHAR2(80),
  desig_code           NUMBER(4),
  desig_seniority_code NUMBER(5)
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
alter table PRMS_INC_TRANSACTION
  add primary key (EMP_ID, BRANCH_CODE, FIN_YEAR)
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
