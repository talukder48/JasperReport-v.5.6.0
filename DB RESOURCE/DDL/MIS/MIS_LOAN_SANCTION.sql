-- Create table
create table MIS_LOAN_SANCTION
(
  branch_code          VARCHAR2(10) not null,
  entry_date           DATE not null,
  zero_eq_sanction_amt NUMBER(12,2),
  oth_prd_sanction_amt NUMBER(12,2)
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
alter table MIS_LOAN_SANCTION
  add primary key (BRANCH_CODE, ENTRY_DATE)
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
