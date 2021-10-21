-- Create table
create table ELMS_PF_REALIZATION
(
  entity_num          NUMBER(4) not null,
  emp_id              VARCHAR2(20) not null,
  real_year           NUMBER(4) not null,
  real_month_code     NUMBER(2) not null,
  rel_sl              NUMBER(4) not null,
  pf_contribution_amt NUMBER(9,2),
  pf_advance_real_amt NUMBER(9,2),
  pf_real_type        CHAR(1),
  pf_adv_dr_amt       NUMBER(13,2),
  pf_adv_cr_amt       NUMBER(13,2),
  voucher_type        VARCHAR2(2),
  voucher_dr          NUMBER(13,2),
  voucher_cr          NUMBER(13,2),
  enty_by             VARCHAR2(20),
  enty_on             DATE,
  mod_by              VARCHAR2(20),
  mod_on              DATE,
  voucher_date        DATE,
  real_date           DATE
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
alter table ELMS_PF_REALIZATION
  add primary key (ENTITY_NUM, EMP_ID, REAL_YEAR, REAL_MONTH_CODE, REL_SL)
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
