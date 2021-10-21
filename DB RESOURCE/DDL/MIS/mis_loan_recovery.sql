create table mis_loan_recovery
(branch_code  varchar2(10),
 entry_date   date,
 cl_recovery_amt number (12,2),
 uc_recovery_amt number (12,2)
 );
 alter table mis_loan_recovery add primary key (branch_code,entry_date);
