
 SELECT * FROM AS_BATCH_SL ;
 SELECT * FROM AS_SUBGL_SL ;
 SELECT * FROM AS_GLBALANCE ;
 SELECT * FROM AS_GLBALANCE_HIST ;
 SELECT * FROM AS_GLCODELIST;
 SELECT * FROM AS_TRANSACTION;
 SELECT * FROM AS_TRANSACTION_LIST ;
 SELECT * FROM As_ITEMLIST ;
 SELECT * FROM as_master;
 
-----------------BRANCH WISE VOUCHER LIST---------------------------------------------
 SELECT l.orginated_branch||': '||(SELECT m.brn_name FROM prms_mbranch m where m.brn_code=l.orginated_branch)office_name, count(*)
  FROM as_transaction_list l
 where l.rej_by is null
 group by l.orginated_branch
 order by count(*)
 
 -----------------BRANCH WISE VOUCHER LIST-CURRENT DATE--------------------------------------------
SELECT l.orginated_branch||': '||(SELECT m.brn_name FROM prms_mbranch m where m.brn_code=l.orginated_branch)office_name, count(*)
  FROM as_transaction_list l
 where l.rej_by is null
 and l.enty_on=trunc(sysdate) 
 group by l.orginated_branch

-----------------ALL OFFICE CASH BOOK DIFFERENCE-------------------------------------
select branch||': '||(SELECT m.brn_name FROM prms_mbranch m where m.brn_code=t.branch)office_name,
  sum(t.DR_AMOUNT), sum(t.CR_AMOUNT), sum(t.DR_AMOUNT)- sum(t.CR_AMOUNT) DIFFERENCE
  from as_transaction t join as_transaction_list k
  on(t.entity_num=k.entity_num
  and t.branch=k.orginated_branch
  and t.tran_date=k.tran_date
  and t.batch_no=k.batch_no)
 where t.entity_num = 1
 and k.rej_on is null
   group by t.branch    
   
     ---cash book detail and summary comparison----------
   SELECT ORGINATED_BRANCH || ': ' ||
       (SELECT m.brn_name
          FROM prms_mbranch m
         where m.brn_code = orginated_branch) office_name
  FROM ((SELECT l.orginated_branch,
                sum(DR_AMOUNT) dt_dr,
                sum(CR_AMOUNT) dt_cr
           from as_transaction_list l
          where l.entity_num = 1
            and l.rej_by is null
          group by l.orginated_branch) kk join
        (select branch, sum(t.DR_AMOUNT) sum_dr, sum(t.CR_AMOUNT) sum_cr
           from as_transaction t
           join as_transaction_list k
             on (t.entity_num = k.entity_num and
                t.branch = k.orginated_branch and t.tran_date = k.tran_date and
                t.batch_no = k.batch_no)
          where t.entity_num = 1
            and k.rej_on is null
          group by t.branch) k on(k.branch = kk.orginated_branch))
 where DT_CR - SUM_CR <> 0
 order by ORGINATED_BRANCH

     ---cash book detail and summary comparison by branch
 
   
SELECT * FROM AS_TRANSACTION_LIST L WHERE L.ORGINATED_BRANCH||'|'||L.TRAN_DATE||'|'||L.BATCH_NO IN(
SELECT DT_BATCH FROM (
(SELECT t.branch || '|' || t.tran_date || '|' || t.batch_no DT_BATCH,
       sum(t.dr_amount) DT_DR,
       sum(t.cr_amount)DT_CR
  FROM as_transaction t
 where t.branch = '0602'
 group by t.branch || '|' || t.tran_date || '|' || t.batch_no)K1

JOIN (
SELECT K.ORGINATED_BRANCH || '|' || K.TRAN_DATE || '|' || K.BATCH_NO SUM_BATCH,
       K.DR_AMOUNT SUM_DR,
       K.CR_AMOUNT SUM_CR
  FROM As_Transaction_List K
 WHERE K.ORGINATED_BRANCH = '0602')K2
 ON(K2.SUM_BATCH=K1.DT_BATCH))
 WHERE DT_DR-SUM_DR<>0)  
  


   
 ----------------CONSOLIDATE TB-----------------------------------------------------
 SELECT SUM(DR_AMOUNT-CR_AMOUNT) FROM table (pkg_gas.fn_get_tb_consolidated('9999'))  
 
 SELECT gl_code,(SELECT l.glname FROM as_glcodelist l where l.glcode=gl_code)gl_name,nvl(-1*decode(sign(balance),-1,balance),0)dr_amount ,nvl(decode(sign(balance),1,balance),0)cr_amount FROM (
SELECT gl_code,sum(-1*dr_amount+cr_amount) balance FROM table (pkg_gas.fn_get_tb_consolidated('9999'))  group by gl_code)
order by gl_code

-----------------------branch TB diff----------------------------
   
SELECT branch ||':'||(SELECT m.brn_name FROM prms_mbranch m where m.brn_code=branch)Branch_name , sum(DR_AMOUNT)  -sum(CR_AMOUNT)
        FROM table(pkg_gas.fn_get_tb_consolidated('9999'))
group by branch;

-----------------------CONSOLIDATE TB previous---------------------------------------------------------------

 SELECT SUM(DR_AMOUNT-CR_AMOUNT) FROM table (pkg_gas.fn_get_tb_consolidated_old('9999'))  
 
 SELECT gl_code,(SELECT l.glname FROM as_glcodelist l where l.glcode=gl_code)gl_name,nvl(-1*decode(sign(balance),-1,balance),0)dr_amount ,nvl(decode(sign(balance),1,balance),0)cr_amount FROM (
SELECT gl_code,sum(-1*dr_amount+cr_amount) balance FROM table (pkg_gas.fn_get_tb_consolidated_old('9999'))  group by gl_code)
order by gl_code;

  
-------------------------------bank----------------------------------------------
 begin
 for idx in (select *
                    from as_glcodelist b
                   where length(b.glcode) > 10
                     and b.glcode like '0900%') loop
        insert into as_glbalance_hist
          (entity_num, branch, fin_year, glcode, init_bal, cur_bal)
        values
          (1, '0900', '2019-2020', idx.glcode, 0, 0);
      end loop;
   end ;   
      
  SELECT * FROM as_glbalance_hist b where b.glcode like '0900%' FOR UPDATE ;
  SELECT * FROM as_glbalance_hist b where b.branch='0900' and b.glcode like '15%' FOR UPDATE ;
-------------------------------manual gl------------------------------------------------  
   begin
  for idx in (select *
                from prms_mbranch m
               where m.brn_code not like '%Z'
                 and m.brn_code not like '%R') loop
    insert into as_glbalance
      (entity_num, fin_year, branch, glcode, init_bal, cur_bal)
    values
      (1, '2020-2021', idx.brn_code, '172216003', 0, 0);
  end loop;

end;

SELECT * FROM as_glbalance b where b.glcode='172216003'
--------------------------------------------------------
   