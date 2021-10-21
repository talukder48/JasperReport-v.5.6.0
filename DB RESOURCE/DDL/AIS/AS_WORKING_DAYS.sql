-- Create table
create table AS_WORKING_DAYS
(
  transactiondate DATE not null,
  transactionpost VARCHAR2(1),
  remarks         VARCHAR2(40),
  entry_by        VARCHAR2(10),
  entry_on        DATE
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
alter table AS_WORKING_DAYS
  add primary key (TRANSACTIONDATE)
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
