-- Create table
create table ZONAL_BRANCH_MAPPING
(
  zonal_off_code  VARCHAR2(10) not null,
  branch_off_code VARCHAR2(10) not null
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
alter table ZONAL_BRANCH_MAPPING
  add primary key (ZONAL_OFF_CODE, BRANCH_OFF_CODE)
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
