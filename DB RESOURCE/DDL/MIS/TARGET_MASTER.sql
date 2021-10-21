-- Create table
create table TARGET_MASTER
(
  target_code        VARCHAR2(15) not null,
  start_date         DATE,
  end_date           DATE,
  target_description VARCHAR2(150)
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
alter table TARGET_MASTER
  add primary key (TARGET_CODE)
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
