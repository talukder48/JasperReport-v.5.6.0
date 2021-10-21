-- Create table
create table PRMS_SUSPEND_LIST
(
  entity_num      NUMBER(4) not null,
  emp_id          VARCHAR2(10) not null,
  suspend_sl      NUMBER(4) not null,
  suspend_date    DATE,
  suspend_branch  VARCHAR2(10),
  attached_branch VARCHAR2(10),
  remarks         VARCHAR2(1000)
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
alter table PRMS_SUSPEND_LIST
  add primary key (ENTITY_NUM, EMP_ID, SUSPEND_SL)
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
