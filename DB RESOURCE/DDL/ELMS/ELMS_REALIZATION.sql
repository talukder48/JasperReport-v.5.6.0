-- Create table
create table ELMS_REALIZATION
(
  entity_num      NUMBER(6) not null,
  emp_id          VARCHAR2(20) not null,
  loan_type       VARCHAR2(3) not null,
  real_year       NUMBER(4) not null,
  real_month_code NUMBER(2) not null,
  rel_sl          NUMBER(4) not null,
  real_date       DATE,
  real_type       CHAR(1),
  dr_cr_type      CHAR(1),
  vouchar_type    CHAR(1),
  real_amount     NUMBER(9,2),
  entd_by         VARCHAR2(10),
  entd_on         DATE
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
alter table ELMS_REALIZATION
  add primary key (ENTITY_NUM, EMP_ID, LOAN_TYPE, REAL_YEAR, REAL_MONTH_CODE, REL_SL)
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
