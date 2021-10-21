-- Create table
create table MIS_GOAL_SETUP
(
  target_code            VARCHAR2(20) not null,
  branch_code            VARCHAR2(10) not null,
  zero_eq_sanction       NUMBER(18,2),
  oths_pd_sanction       NUMBER(18,2),
  zero_eq_disburse       NUMBER(18,2),
  oths_pd_disburse       NUMBER(18,2),
  loan_uc_recovery       NUMBER(18,2),
  loan_cl_recovery       NUMBER(18,2),
  audit_commercial       NUMBER(5),
  audit_post_audit       NUMBER(5),
  kharidabari_procession NUMBER(5),
  kharidabari_sale       NUMBER(5),
  settle_executive_case  NUMBER(5),
  settle_writ_case       NUMBER(5),
  deed_return_fl         NUMBER(5)
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
alter table MIS_GOAL_SETUP
  add primary key (TARGET_CODE, BRANCH_CODE)
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
