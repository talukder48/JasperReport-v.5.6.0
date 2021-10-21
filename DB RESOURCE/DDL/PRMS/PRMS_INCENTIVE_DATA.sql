-- Create table
create table PRMS_INCENTIVE_DATA
(
  branch_code     VARCHAR2(10) not null,
  emp_id          VARCHAR2(8) not null,
  fin_year        VARCHAR2(10) not null,
  current_basic   NUMBER(12,2),
  incentive_basic NUMBER(12,2),
  incentive_pct   NUMBER(12,2),
  total_amount    NUMBER(12,2)
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
alter table PRMS_INCENTIVE_DATA
  add primary key (BRANCH_CODE, EMP_ID, FIN_YEAR)
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
