create table mis_loan_sanction_disburse
(branch_code  varchar2(10),
 entry_date   date,
 zero_eq_sanction_amt number (12,2),
 oth_prd_sanction_amt number (12,2),
 zero_eq_disburse_amt number (12,2),
 oth_prd_disburse_amt number (12,2)
 );
 alter table mis_loan_sanction_disburse add primary key (branch_code,entry_date);
