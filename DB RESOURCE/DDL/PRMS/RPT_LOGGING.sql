-- Create table
create table RPT_LOGGING
(
  entity       NUMBER(4),
  user_id      VARCHAR2(10),
  branch_code  VARCHAR2(10),
  year         NUMBER(4),
  month_code   NUMBER(8),
  enty_date    DATE,
  message_type VARCHAR2(3),
  messege_desc VARCHAR2(1000)
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
