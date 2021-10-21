-- Create table
create table AS_TRANSACTION_LIST
(
  entity_num       NUMBER(6) not null,
  orginated_branch VARCHAR2(10) not null,
  tran_date        DATE not null,
  batch_no         NUMBER(6) not null,
  transaction_type CHAR(1),
  remarks          VARCHAR2(100),
  dr_amount        NUMBER(18,2),
  cr_amount        NUMBER(18,2),
  enty_by          VARCHAR2(15),
  enty_on          DATE,
  check_by         VARCHAR2(15),
  check_on         DATE,
  auth_by          VARCHAR2(15),
  auth_on          DATE,
  rej_by           VARCHAR2(12),
  rej_on           DATE
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
alter table AS_TRANSACTION_LIST
  add primary key (ENTITY_NUM, ORGINATED_BRANCH, TRAN_DATE, BATCH_NO)
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
