-- Create table
create table PRMS_DEDUC
(
  emp_id              VARCHAR2(20) not null,
  hb_adv_deduc        NUMBER(7,2),
  mcycle_deduc        NUMBER(7,2),
  pfadv_deduc         NUMBER(7,2),
  pension             NUMBER(7,2),
  revenue             NUMBER(5,2),
  welfare             NUMBER(7,2),
  car_fare            NUMBER(7,2),
  car_use             NUMBER(7,2),
  gas_bill            NUMBER(7,2),
  water_bill          NUMBER(7,2),
  elect_bill          NUMBER(7,2),
  house_rent          NUMBER(7,2),
  news_paper          NUMBER(5,2),
  hbadv_arrear        NUMBER(7,2),
  pfadv_arrear        NUMBER(7,2),
  tel_excess_bill     NUMBER(7,2),
  hbadv_deduc_percent NUMBER(6,2),
  gen_insurance       NUMBER(7,2),
  bcycle_deduc        NUMBER(7,2),
  pf_deduction        VARCHAR2(1),
  other_deduc         NUMBER(7,2),
  comp_deduc          NUMBER(9,2),
  income_tax          NUMBER(7,2),
  income_tax_arr      NUMBER(7,2),
  remarks             VARCHAR2(200),
  hr_arear_ded        NUMBER(9,2)
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
alter table PRMS_DEDUC
  add primary key (EMP_ID)
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
