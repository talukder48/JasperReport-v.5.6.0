-- Create table
create table AS_ITEMLIST
(
  entity      NUMBER(6) not null,
  branch_code VARCHAR2(8) not null,
  item_code   VARCHAR2(4) not null,
  item_desc   VARCHAR2(100),
  debit_gl    VARCHAR2(15),
  credit_gl   VARCHAR2(15),
  enty_by     VARCHAR2(12),
  enty_date   DATE,
  remarks     VARCHAR2(100)
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
alter table AS_ITEMLIST
  add primary key (ENTITY, BRANCH_CODE, ITEM_CODE)
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
