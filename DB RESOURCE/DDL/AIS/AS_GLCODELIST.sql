-- Create table
create table AS_GLCODELIST
(
  entity_num NUMBER(6) not null,
  glcode     VARCHAR2(15) not null,
  glname     VARCHAR2(100),
  remarks    VARCHAR2(100),
  sub_gl     CHAR(1),
  lvlcode5   VARCHAR2(10),
  lvlcode4   VARCHAR2(10),
  lvlcode3   VARCHAR2(10),
  lvlcode2   VARCHAR2(10),
  lvlcode1   VARCHAR2(10),
  mainhead   VARCHAR2(10),
  slot_yn    CHAR(1),
  tran_yn    CHAR(1),
  br_ho      CHAR(1),
  gl_type    CHAR(1),
  inc_exp    CHAR(1),
  cap_rev    CHAR(1),
  enty_by    VARCHAR2(15),
  enty_on    DATE,
  mod_by     VARCHAR2(15),
  mod_on     DATE,
  gl_visible CHAR(1),
  ho_ecs     CHAR(1),
  tb_yn      CHAR(1)
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
alter table AS_GLCODELIST
  add primary key (ENTITY_NUM, GLCODE)
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
