-- Create table
create table PRMS_INCENTIVE_MASTER
(
  finyear         VARCHAR2(12) not null,
  order_no        VARCHAR2(80),
  no_of_incentive NUMBER(5,2)
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
alter table PRMS_INCENTIVE_MASTER
  add primary key (FINYEAR)
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
