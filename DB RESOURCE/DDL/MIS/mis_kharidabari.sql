create table mis_kharidabari
(branch_code  varchar2(10),
 entry_date   date,
 procession number (4),
 sale number (4)
 );
 alter table mis_kharidabari add primary key (branch_code,entry_date);
