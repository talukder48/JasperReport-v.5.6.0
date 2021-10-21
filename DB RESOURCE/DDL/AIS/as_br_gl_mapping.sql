create table as_br_gl_mapping(
    entity_num number(4),
    branch_code  varchar2(10),
    glcode       varchar2(15)
);
alter table as_br_gl_mapping add primary key(entity_num,branch_code,glcode);

