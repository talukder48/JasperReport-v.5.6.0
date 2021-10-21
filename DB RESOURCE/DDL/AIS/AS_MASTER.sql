-- Create table
create table AS_MASTER
(
  finyear    VARCHAR2(10),
  start_date DATE,
  end_date   DATE,
  remarks    VARCHAR2(100)
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
