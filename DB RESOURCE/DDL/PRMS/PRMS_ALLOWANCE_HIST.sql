-- Create table
create table PRMS_ALLOWANCE_HIST
(
  emp_id              VARCHAR2(20) not null,
  h_date              DATE not null,
  tel_allowance       VARCHAR2(15),
  trans_allowance     VARCHAR2(15),
  edu_allowance       NUMBER(7,2),
  wash_allowance      NUMBER(7,2),
  pension_allowance   NUMBER(9,2),
  entertain_allowance NUMBER(7,2),
  domes_allowance     NUMBER(9,2),
  other_allowance     NUMBER(9,2),
  arrear              NUMBER(9,2),
  remarks             VARCHAR2(200),
  hill_allwnc         NUMBER(7,2),
  hr_arear_alw        NUMBER(9,2)
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
alter table PRMS_ALLOWANCE_HIST
  add primary key (EMP_ID, H_DATE)
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
