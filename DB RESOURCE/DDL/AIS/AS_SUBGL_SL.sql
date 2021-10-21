-- Create table
create table AS_SUBGL_SL
(
  enitiy_num  NUMBER(4) not null,
  branch_code VARCHAR2(10) not null,
  gl_code     VARCHAR2(15) not null,
  sl_no       NUMBER(4) not null
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
alter table AS_SUBGL_SL
  add primary key (ENITIY_NUM, BRANCH_CODE, GL_CODE)
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
