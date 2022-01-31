-- Create table
create table ERP_USER
(
  user_id       VARCHAR2(15) not null,
  user_name     VARCHAR2(50),
  user_password VARCHAR2(500),
  user_branch   VARCHAR2(6),
  user_role     CHAR(1),
  check_role    CHAR(1),
  auth_role     CHAR(1),
  entd_by       VARCHAR2(15),
  entd_on       DATE,
  mod_by        VARCHAR2(15),
  mod_on        DATE
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
alter table ERP_USER
  add primary key (USER_ID)
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
