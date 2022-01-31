-- Create table
create table APPLICATIONLOG
(
  logid        NUMBER not null,
  processtime  TIMESTAMP(6),
  requesttype  VARCHAR2(2000),
  data_object  VARCHAR2(2000),
  errorcode    NUMBER(5),
  errormessage BLOB
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
alter table APPLICATIONLOG
  add primary key (LOGID)
  using index 
  tablespace INNOVATION
  pctfree 10
  initrans 2
  maxtrans 255;
