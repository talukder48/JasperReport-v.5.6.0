
-- Create table
create table OFFICE_DESCRIPTION
(
  zone_code  VARCHAR2(2) not null,
  off_code   VARCHAR2(2) not null,
  loc_code   VARCHAR2(4) not null,
  loc_desc   VARCHAR2(100) not null,
  loc_add1   VARCHAR2(50),
  loc_add2   VARCHAR2(50),
  loc_add3   VARCHAR2(50),
  loc_phone  VARCHAR2(30),
  loc_desc_1 VARCHAR2(100)
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
