-- Create table
create table PEN_INHERITANCE
(
  entity_num      NUMBER(6) not null,
  nothi_num       VARCHAR2(10) not null,
  successor_sl    NUMBER(4) not null,
  relationtype    CHAR(1),
  succ_acc_active CHAR(1),
  benificiaryname VARCHAR2(60),
  district        VARCHAR2(15),
  email           VARCHAR2(50),
  contact_no      VARCHAR2(12),
  address         VARCHAR2(100),
  handicap        CHAR(1),
  highest_degree  VARCHAR2(100),
  home_district   VARCHAR2(30),
  nid             VARCHAR2(20),
  pension_pct     NUMBER(5,2),
  pension_amt     NUMBER(13,2),
  entd_by         VARCHAR2(15),
  entd_on         DATE,
  mod_by          VARCHAR2(15),
  mod_on          DATE,
  bank_name       VARCHAR2(25),
  branch_name     VARCHAR2(70),
  bank_account    VARCHAR2(20),
  dob             DATE,
  branch_district VARCHAR2(20),
  praddress       VARCHAR2(200)
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
alter table PEN_INHERITANCE
  add primary key (ENTITY_NUM, NOTHI_NUM, SUCCESSOR_SL)
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
