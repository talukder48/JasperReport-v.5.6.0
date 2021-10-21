-- Create table
create table AS_BATCH_SL
(
  branch_code VARCHAR2(10) not null,
  tran_date   DATE not null,
  batch_sl    NUMBER(6),
  user_id     VARCHAR2(15)
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
alter table AS_BATCH_SL
  add primary key (BRANCH_CODE, TRAN_DATE)
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
