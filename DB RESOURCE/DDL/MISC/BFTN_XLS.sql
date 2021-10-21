-- Create table
create table BFTN_XLS
(
  account_type                VARCHAR2(50),
  debtor_reference            VARCHAR2(50),
  amount                      VARCHAR2(50),
  batch_no                    VARCHAR2(50),
  biller_business_segment     VARCHAR2(50),
  biller_type                 VARCHAR2(50),
  biller_name                 VARCHAR2(50),
  credit_bank_account_number  VARCHAR2(50),
  credit_bank_code            VARCHAR2(50),
  currency_credit_currency    VARCHAR2(50),
  currency_debit_currency     VARCHAR2(50),
  ddi_status                  VARCHAR2(50),
  ddi_status_code             VARCHAR2(50),
  debtor_account_number       VARCHAR2(50),
  debtor_bank_branch_code     VARCHAR2(50),
  debtor_bank_code            VARCHAR2(50),
  debtor_name                 VARCHAR2(50),
  ebsw_corp_id                VARCHAR2(50),
  particular                  VARCHAR2(50),
  payer_resident_status       VARCHAR2(50),
  return_code                 VARCHAR2(50),
  return_date                 VARCHAR2(50),
  return_reason               VARCHAR2(50),
  settlement_mode             VARCHAR2(50),
  transaction_sequence_number VARCHAR2(50),
  transaction_type            VARCHAR2(50),
  value_date                  DATE,
  payer_type                  VARCHAR2(50),
  loan_code                   VARCHAR2(13),
  insert_lot                  VARCHAR2(8),
  mig_date                    DATE
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
