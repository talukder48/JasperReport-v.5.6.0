create table mis_faulty_ln_case
(branch_code  varchar2(10),
 entry_date   date,
 loan_account_NO number (4)
 );
 alter table mis_faulty_ln_case add primary key (branch_code,entry_date);
