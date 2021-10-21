-- Create table
create table LOAN_ACCOUNT
(
  loc_code         VARCHAR2(5) not null,
  loan_code        VARCHAR2(13) not null,
  borrower_name    VARCHAR2(60),
  borrower_f_name  VARCHAR2(60),
  borrower_m_name  VARCHAR2(60),
  site_location    VARCHAR2(150),
  mailing_location VARCHAR2(150),
  sanction_amount  NUMBER(13,2),
  sanction_date    DATE,
  ln_status        CHAR(1),
  nid              VARCHAR2(50),
  tin              VARCHAR2(50),
  principal_bal    NUMBER(13,2),
  interest_bal     NUMBER(13,2),
  total_bal        NUMBER(13,2),
  mail_id          VARCHAR2(80),
  mobile_no        VARCHAR2(30),
  product_nature   VARCHAR2(10) not null
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
alter table LOAN_ACCOUNT
  add primary key (LOC_CODE, LOAN_CODE, PRODUCT_NATURE)
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
