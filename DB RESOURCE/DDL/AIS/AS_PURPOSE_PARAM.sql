-- Create table
create table AS_PURPOSE_PARAM
(
  purpose_code   VARCHAR2(2) not null,
  purpose_desc   VARCHAR2(50),
  vat_applicable CHAR(1),
  gl_code        VARCHAR2(9),
  remarks        VARCHAR2(100)
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
alter table AS_PURPOSE_PARAM
  add primary key (PURPOSE_CODE)
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
