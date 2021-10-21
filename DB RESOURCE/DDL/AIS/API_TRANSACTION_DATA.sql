-- Create table
create table API_TRANSACTION_DATA
(
  receive_id         NUMBER not null,
  branch_code        VARCHAR2(4),
  customer_mobile    VARCHAR2(11),
  loan_code          VARCHAR2(13),
  memo_no            VARCHAR2(15),
  prossing_date_time TIMESTAMP(6),
  purpose_code       VARCHAR2(2),
  transaction_id     VARCHAR2(16),
  txn_amount         NUMBER(12,2),
  txn_date           DATE,
  txn_receiver       VARCHAR2(10),
  vat_amount         NUMBER(12,2),
  reference_number   VARCHAR2(30),
  loan_bal           NUMBER(18,2),
  sms_body           VARCHAR2(400)
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
alter table API_TRANSACTION_DATA
  add primary key (RECEIVE_ID)
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
