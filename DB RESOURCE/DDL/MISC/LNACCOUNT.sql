-- Create table
create table LNACCOUNT
(
  loan_code     VARCHAR2(13) not null,
  loan_type     VARCHAR2(1),
  loan_acc      VARCHAR2(8) not null,
  loan_cat      VARCHAR2(2) not null,
  loan_resc     VARCHAR2(2) not null,
  loc_code      VARCHAR2(4) not null,
  open_date     DATE,
  sanc_date     DATE,
  sanc_amt      NUMBER(13,2),
  total_disb    NUMBER(13,2),
  idcp_amt      NUMBER(13,2),
  prin_inst     NUMBER(13,2),
  int_inst      NUMBER(13,2),
  repay_date    DATE,
  int_rate      NUMBER(5,2) not null,
  name1         VARCHAR2(50) not null,
  name2         VARCHAR2(50),
  f_name        VARCHAR2(50),
  m_add1        VARCHAR2(50),
  m_add2        VARCHAR2(50),
  m_add3        VARCHAR2(50),
  s_add1        VARCHAR2(50),
  s_add2        VARCHAR2(50),
  s_add3        VARCHAR2(50),
  loan_period   NUMBER(3),
  loan_class    VARCHAR2(2),
  ln_criteria   VARCHAR2(2),
  loan_active   VARCHAR2(1),
  old_loan_code VARCHAR2(13),
  h_name        VARCHAR2(50),
  phone_res     VARCHAR2(20),
  phone_off     VARCHAR2(20),
  cell_no       VARCHAR2(20),
  email         VARCHAR2(40),
  loc_code_old  VARCHAR2(4),
  nid1          VARCHAR2(17),
  nid2          VARCHAR2(17),
  loan_product  VARCHAR2(1),
  db_type       VARCHAR2(20)
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
-- Grant/Revoke object privileges 
grant select on LNACCOUNT to ICT_OPERATION;
