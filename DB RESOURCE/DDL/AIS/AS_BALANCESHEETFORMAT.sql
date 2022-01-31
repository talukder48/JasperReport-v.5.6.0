-- Create table
create table AS_BALANCESHEETFORMAT
(
  group_code             VARCHAR2(2),
  particular_code        VARCHAR2(3),
  particular_name        VARCHAR2(100),
  gl_code                VARCHAR2(9),
  rev_group_code         VARCHAR2(1),
  parent_particular_code VARCHAR2(3),
  calculation            VARCHAR2(1),
  sub_particular_code    VARCHAR2(3),
  visibility             VARCHAR2(1)
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
