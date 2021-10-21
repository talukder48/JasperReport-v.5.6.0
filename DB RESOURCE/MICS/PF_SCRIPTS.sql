select *from bhbfc.bkpf2_to_date_1718 b where b.period='JUN-17-18' and b.acc_no=940;
/*
insert into elms_pf_leadger
select 1, b.acc_no,2018,6,'PFC',1,'30-jun-2017',b.cont,0,0,b.int_charged,
b.adj_bal,b.adj_adv1_bal,b.adj_adv2_bal,b.adj_adv3_bal,b.tot_adj_adv_bal,
'MIG', trunc(sysdate),0,0,'',0,0,b.adj_adv1_ins,b.adj_adv2_ins,b.adj_adv3_ins ,b.adj_adv1_ins+b.adj_adv2_ins+b.adj_adv3_ins from bhbfc.bkpf2_to_date_1718 b where b.period='JUN-17-18' ;

insert into elms_pf_summary
select 1, b.acc_no,b.int_charged,
b.adj_bal,b.adj_adv1_bal,b.adj_adv2_bal,b.adj_adv3_bal,b.tot_adj_adv_bal,B.ADJ_ADV1_INS,B.ADJ_ADV2_INS,B.ADJ_ADV3_INS,B.ADJ_ADV1_INS+B.ADJ_ADV2_INS+B.ADJ_ADV3_INS
from bhbfc.bkpf2_to_date_1718 b where b.period='JUN-17-18';
*/

insert into elms_pf_leadger

select 1, b.acc_no,2019,6,'PFC',1,'30-jun-2018',b.cont,0,0,b.int_charged,
b.adj_bal,b.adj_adv1_bal,b.adj_adv2_bal,b.adj_adv3_bal,b.tot_adj_adv_bal,
'MIG', trunc(sysdate),0,0,'',0,0,b.adj_adv1_ins,b.adj_adv2_ins,b.adj_adv3_ins ,b.adj_adv1_ins+b.adj_adv2_ins+b.adj_adv3_ins from 
bhbfc.Pf2_To_Date b where b.period='JUN-18-19'
AND ACC_NO NOT IN ('951','940','947','1115','1117','916','921','824') ;

insert into elms_pf_summary

select 1, b.acc_no,b.int_charged,
b.adj_bal,b.adj_adv1_bal,b.adj_adv2_bal,b.adj_adv3_bal,b.tot_adj_adv_bal,B.ADJ_ADV1_INS,B.ADJ_ADV2_INS,B.ADJ_ADV3_INS,B.ADJ_ADV1_INS+B.ADJ_ADV2_INS+B.ADJ_ADV3_INS
from bhbfc.Pf2_To_Date b where b.period='JUN-18-19'
AND  ACC_NO NOT IN ('951','940','947','1115','1117','916','921','824') ;

SELECT *FROM elms_pf_leadger WHERE EMP_ID NOT IN ('951','940','947','1115','1117','916','921','824') ;
SELECT *FROM ELMS_PF_SUMMARY WHERE EMP_ID NOT IN ('951','940','947','1115','1117','916','921','824') ;


 
 SELECT *FROM elms_pf_leadger L WHERE L.EMP_ID=947
 
 declare
  c1        number := 7;
  c2        number := 1;
  v_year    number := 2018;
  v_error   varchar2(400) := '';
  
begin
  loop
    if c1 > 12 and c2 > 6 then
      exit;
    end if;
  
    if c1 < 13 then
      dbms_output.put_line(c1 || '-' || v_year);
      pkg_elms.SP_PF_PROCESS(1, v_year, c1, v_error);
      c1 := c1 + 1;
    end if;
  
    if c1 > 12 then
      dbms_output.put_line(c2 || '-' || to_char(v_year + 1));
      pkg_elms.SP_PF_PROCESS(1, v_year + 1, c2, v_error);
      c2 := c2 + 1;
    end if;
  
  end loop;

end;


SELECT *
  FROM ELMS_PF_LEADGER L
 WHERE L.EMP_ID = 947
 ORDER BY L.PF_YEAR, L.PF_MONTH_CODE;
 
 SELECT *FROM TABLE (PKG_RPT.FN_PF_DATA(1,9999,'','2018-2019')) WHERE EMPLOYEE_ID IN('951','940','947','1115','1117','916','921','824'*/)







BEGIN

  FOR IDX IN (SELECT S.EMP_ID
                FROM PRMS_EMP_SAL S
              MINUS
              SELECT S.EMP_ID
                FROM ELMS_PF_SUMMARY S) LOOP
  
    INSERT INTO elms_pf_leadger
      (entity_num,
       emp_id,
       pf_year,
       pf_month_code,
       vouchar_type	,			
       pf_sl	,			
       pf_balance,
       pf_adv1_bal,
       pf_adv2_bal,
       pf_adv3_bal,
       pf_tot_bal,
       entd_by,
       entd_on)
    VALUES
      (1, IDX.emp_id, 2019, '6','PFC','1',0, 0, 0, 0, 0, 'MIG', TRUNC(SYSDATE));
    INSERT INTO Elms_Pf_Summary
      (entity_num,
       emp_id,
       pf_balance,
       pf_adv1_bal,
       pf_adv2_bal,
       pf_adv3_bal,
       pf_tot_bal)
    VALUES
      (1, IDX.emp_id, 0, 0, 0, 0, 0);
  END LOOP;

END;







select *from elms_pf_realization r where r.emp_id=947
 
 
 
 
 
 
   select P.PERIOD,p.advance, p.instl,p.interest --into m_advance, m_instl,m_interest
      from BHBFC.pfadv p
      where p.acc_no=947;
      
        select p.vch_debit, p.vch_credit --into m_vch_debit,m_vch_credit
     from BHBFC.pfvoucher p
      where p.acc_no=947;
      
      
      select *from elms_pf_advance d FOR UPDATE ;
      
       select acc_no, pf.adv1_bal, pf.adv2_bal, pf.adv3_bal,
          pf.adv1_ins, pf.adv2_ins, pf.adv3_ins    
      from BHBFC.pf
             where pf.acc_no IN('947' ,'951','940','947','1115','1117','916','921','824')                    
        select q.amount 
       from BHBFC.pfadv_pay q
           WHERE q.acc_no = 947;
           
           select v.cont, v.ad_ded
       from BHBFC.pfarrear v
         where 
          v.acc_no = '947';;
          
          select *from elms_pf_leadger

