-- Create table
create table SS_LOANACC_DATA
(
  loc_code      VARCHAR2(4),
  loan_case     VARCHAR2(10),
  ln_catagory   VARCHAR2(2),
  loan_code     VARCHAR2(13),
  borrower_name VARCHAR2(100),
  ln_type       CHAR(1),
  prod_nature   VARCHAR2(5),
  site_add      VARCHAR2(200),
  address       VARCHAR2(200),
  email_id      VARCHAR2(50),
  phone_number  VARCHAR2(15)
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
