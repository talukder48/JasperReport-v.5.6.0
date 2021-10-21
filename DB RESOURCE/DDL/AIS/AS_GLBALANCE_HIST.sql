-- Create table
create table AS_GLBALANCE_HIST
(
  entity_num    NUMBER(6) not null,
  fin_year      VARCHAR2(10) not null,
  branch        VARCHAR2(10) not null,
  glcode        VARCHAR2(10) not null,
  init_bal      NUMBER(18,2),
  cur_bal       NUMBER(18,2),
  cum_dr_bal    NUMBER(18,2),
  cum_cr_bal    NUMBER(18,2),
  unauth_dr_bal NUMBER(18,2),
  unauth_cr_bal NUMBER(18,2)
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
alter table AS_GLBALANCE_HIST
  add primary key (ENTITY_NUM, FIN_YEAR, BRANCH, GLCODE)
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
