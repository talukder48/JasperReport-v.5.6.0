create table mis_Audit_ob_disposal
(branch_code  varchar2(10),
 entry_date   date,
 commercial_obj number (4),
 Audit_obj number (4)
 );
 alter table mis_Audit_ob_disposal add primary key (branch_code,entry_date);
