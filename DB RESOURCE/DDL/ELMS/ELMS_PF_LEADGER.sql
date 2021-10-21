-- Create table
create table ELMS_PF_LEADGER
(
  entity_num          NUMBER(6) not null,
  emp_id              VARCHAR2(20) not null,
  pf_year             NUMBER(4) not null,
  pf_month_code       NUMBER(2) not null,
  vouchar_type        CHAR(3) not null,
  pf_sl               NUMBER(4) not null,
  real_date           DATE,
  pf_contribution_amt NUMBER(11,2),
  pf_adv_real_amt     NUMBER(11,2),
  pf_advance_amt      NUMBER(11,2),
  int_chg_amt         NUMBER(11,2),
  pf_balance          NUMBER(11,2),
  pf_adv1_bal         NUMBER(11,2),
  pf_adv2_bal         NUMBER(11,2),
  pf_adv3_bal         NUMBER(11,2),
  pf_tot_bal          NUMBER(11,2),
  entd_by             VARCHAR2(10),
  entd_on             DATE,
  pf_adv_dr_amt       NUMBER(13,2),
  pf_adv_cr_amt       NUMBER(13,2),
  real_type           VARCHAR2(4),
  voucher_dr          NUMBER(13,2),
  voucher_cr          NUMBER(13,2),
  adv1_ins            NUMBER(13,2),
  adv2_ins            NUMBER(13,2),
  adv3_ins            NUMBER(13,2),
  pf_adv_tot_ins      NUMBER(13,2)
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
alter table ELMS_PF_LEADGER
  add primary key (ENTITY_NUM, EMP_ID, PF_YEAR, PF_MONTH_CODE, VOUCHAR_TYPE, PF_SL)
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
