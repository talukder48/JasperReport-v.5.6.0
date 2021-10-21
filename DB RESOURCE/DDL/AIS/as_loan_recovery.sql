create table as_loan_recovery
(branch_code varchar2(10),
finYear varchar2(10),
glcode  varchar2(13),
principal_amt number(18,2),
interest_amt  number(18,2));

alter table as_loan_recovery add primary key (branch_code,finYear,glcode);



