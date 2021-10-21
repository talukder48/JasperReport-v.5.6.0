-- Create table
create table AS_FINYEAR
(
  entity_num   NUMBER(4) not null,
  fin_year     VARCHAR2(12) not null,
  start_date   DATE,
  end_date     DATE,
  activatation VARCHAR2(1),
  entry_serial number(4)  
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
alter table AS_FINYEAR
  add primary key (ENTITY_NUM, FIN_YEAR)
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
