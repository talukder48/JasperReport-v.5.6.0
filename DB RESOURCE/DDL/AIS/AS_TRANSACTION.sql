-- Create table
create table AS_TRANSACTION
(
  entity_num    NUMBER(6) not null,
  branch        VARCHAR2(10) not null,
  tran_date     DATE not null,
  glcode        VARCHAR2(15) not null,
  tran_sl       NUMBER(4) not null,
  dr_amount     NUMBER(18,2),
  cr_amount     NUMBER(18,2),
  batch_no      NUMBER(6) not null,
  naration      VARCHAR2(100),
  pf_number     VARCHAR2(10),
  chq_number    VARCHAR2(25),
  chq_date      VARCHAR2(20),
  chq_reference VARCHAR2(50)
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
alter table AS_TRANSACTION
  add primary key (ENTITY_NUM, BRANCH, TRAN_DATE, GLCODE, TRAN_SL, BATCH_NO)
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
