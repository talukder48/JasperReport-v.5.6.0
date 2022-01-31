-- Create table
create table OMS_PROPERTIES
(
  id         VARCHAR2(5) not null,
  name       VARCHAR2(100),
  reportpath VARCHAR2(200),
  ipaddress  VARCHAR2(25)
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
alter table OMS_PROPERTIES
  add primary key (ID)
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
