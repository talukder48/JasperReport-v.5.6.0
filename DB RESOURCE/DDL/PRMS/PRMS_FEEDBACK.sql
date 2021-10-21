-- Create table
create table PRMS_FEEDBACK
(
  eitity_num  NUMBER(6),
  branch_code VARCHAR2(6),
  sal_year    NUMBER(4),
  month_code  NUMBER(2),
  status      VARCHAR2(1),
  enty_by     VARCHAR2(15),
  enty_on     DATE,
  remarks     VARCHAR2(300)
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
