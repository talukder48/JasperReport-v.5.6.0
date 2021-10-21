-- Create table
create table MIS_COURT_CASE_SETTLE
(
  branch_code    VARCHAR2(10) not null,
  entry_date     DATE not null,
  executive_case NUMBER(4),
  misc_cse       NUMBER(4)
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
alter table MIS_COURT_CASE_SETTLE
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
