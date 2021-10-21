-- Create table
create table BFTN_RECIPT
(
  period          VARCHAR2(9),
  bank            VARCHAR2(6) not null,
  loan_type       VARCHAR2(1) not null,
  loan_acc        VARCHAR2(8) not null,
  loan_cat        VARCHAR2(2) not null,
  loc_code        VARCHAR2(4) not null,
  memo_no         VARCHAR2(7),
  pay_date        DATE not null,
  pay_amt         NUMBER(13,2) not null,
  purpose         VARCHAR2(2) not null,
  entry_user      VARCHAR2(20),
  entry_date      DATE,
  update_user     VARCHAR2(20),
  update_date     DATE,
  ln_type_bk      VARCHAR2(1),
  error_code      VARCHAR2(200),
  ent_sl_no       NUMBER(15),
  processed       CHAR(2),
  org_loc_code    VARCHAR2(4),
  idcp            CHAR(1) not null,
  loan_product    VARCHAR2(15),
  actual_loc_code VARCHAR2(4),
  actual_error    VARCHAR2(200),
  branch_code     VARCHAR2(4),
  loan_code       VARCHAR2(13) not null,
  prod_nature     VARCHAR2(3),
  insert_lot      VARCHAR2(8),
  mig_date        DATE
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
