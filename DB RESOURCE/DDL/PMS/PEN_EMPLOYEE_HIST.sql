-- Create table
create table PEN_EMPLOYEE_HIST
(
  entity_num       NUMBER(6) not null,
  bk_date          DATE not null,
  nothi_num        VARCHAR2(10) not null,
  enothi_num       VARCHAR2(30),
  emp_id           VARCHAR2(20),
  emp_name         VARCHAR2(50),
  gender           VARCHAR2(1),
  tin_no           VARCHAR2(30),
  email            VARCHAR2(50),
  contact_no       VARCHAR2(12),
  dob              DATE,
  address          VARCHAR2(100),
  religion         CHAR(1),
  highest_degree   VARCHAR2(100),
  home_district    VARCHAR2(30),
  nid              VARCHAR2(20),
  entd_by          VARCHAR2(15),
  entd_on          DATE,
  mod_by           VARCHAR2(15),
  mod_on           DATE,
  prl_date         DATE,
  designation_code NUMBER(2),
  activation_type  CHAR(1),
  bank_name        VARCHAR2(40),
  branch_name      VARCHAR2(70),
  account_num      VARCHAR2(20),
  branch_district  VARCHAR2(20),
  praddress        VARCHAR2(200),
  pensioner_type   CHAR(1)
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
alter table PEN_EMPLOYEE_HIST
  add primary key (ENTITY_NUM, BK_DATE, NOTHI_NUM)
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
