-- Create table
create table PEN_CALCULATION_DATA
(
  entity_num       NUMBER(6) not null,
  nothi_num        VARCHAR2(10) not null,
  pension_amt      NUMBER(13,2),
  pension_arear    NUMBER(13,2),
  medical_amt      NUMBER(13,2),
  medical_arr      NUMBER(13,2),
  bonus            NUMBER(13,2),
  bonus_arr        NUMBER(13,2),
  others_alw       NUMBER(13,2),
  remrks_other_alw VARCHAR2(3200),
  hb_pct           NUMBER(5,2),
  hb_ded           NUMBER(13,2),
  com_ded          NUMBER(13,2),
  mot_ded          NUMBER(13,2),
  others_ded       NUMBER(13,2),
  remrks_other_ded VARCHAR2(3200),
  revinue          NUMBER(4,2),
  noborsho         NUMBER(12,2),
  dearness         NUMBER(12,2),
  arr_dearness     NUMBER(12,2)
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
alter table PEN_CALCULATION_DATA
  add primary key (ENTITY_NUM, NOTHI_NUM)
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
