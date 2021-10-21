-- Create table
create table AS_BR_COLLECTIONGL_MAP
(
  entity_num  NUMBER(4) not null,
  branch_code VARCHAR2(10) not null,
  glcode      VARCHAR2(15) not null
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
alter table AS_BR_COLLECTIONGL_MAP
  add primary key (ENTITY_NUM, BRANCH_CODE, GLCODE)
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
