-- Create table
create table ELMS_PF_SUMMARY
(
  entity_num      NUMBER(6) not null,
  emp_id          VARCHAR2(20) not null,
  cum_int_chg_amt NUMBER(11,2),
  pf_balance      NUMBER(11,2),
  pf_adv1_bal     NUMBER(11,2),
  pf_adv2_bal     NUMBER(11,2),
  pf_adv3_bal     NUMBER(11,2),
  pf_tot_bal      NUMBER(11,2),
  adv_ins1_amt    NUMBER(13,2),
  adv_ins2_amt    NUMBER(13,2),
  adv_ins3_amt    NUMBER(13,2),
  pf_adv_tot_ins  NUMBER(13,2)
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
alter table ELMS_PF_SUMMARY
  add primary key (ENTITY_NUM, EMP_ID)
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
