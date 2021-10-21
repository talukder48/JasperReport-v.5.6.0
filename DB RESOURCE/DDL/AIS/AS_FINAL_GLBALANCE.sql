-- Create table
create table AS_FINAL_GLBALANCE
(
  entity_num NUMBER(6) not null,
  fin_year   VARCHAR2(10) not null,
  branch     VARCHAR2(10) not null,
  glcode     VARCHAR2(15) not null,
  tb_type    CHAR(1) not null,
  init_bal   NUMBER(18,2),
  cur_bal    NUMBER(18,2)
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
alter table AS_FINAL_GLBALANCE
  add primary key (ENTITY_NUM, FIN_YEAR, BRANCH, GLCODE, TB_TYPE)
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
