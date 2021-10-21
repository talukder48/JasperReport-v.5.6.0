-- Create table
create table ELMS_LN_SUMMARY
(
  entity_num   NUMBER(6) not null,
  emp_id       VARCHAR2(20) not null,
  loan_type    VARCHAR2(3) not null,
  prin_balance NUMBER(9,2),
  int_balance  NUMBER(9,2),
  tot_balance  NUMBER(9,2)
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
alter table ELMS_LN_SUMMARY
  add primary key (ENTITY_NUM, EMP_ID, LOAN_TYPE)
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
