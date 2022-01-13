create or replace package pkg_closing is
procedure sp_After_Adjustment (p_date in date,p_Ho_branch in varchar2);
procedure sp_before_Adjustment(p_date in date,p_Ho_branch in varchar2);
end pkg_closing;
/
create or replace package body pkg_closing is
  procedure sp_Tds_transfer_to_ho(p_date in date,p_Ho_branch in varchar2) is
    v_batch_sl   number := 0;
    v_ho_batchSL number := 0;
    v_balance    number := 0;
    v_error      varchar2(100) := '';
    v_ho_gl_code varchar2(9) := '';
    v_br_gl_code varchar2(9) := '';
    
  begin
      for idx in(select *from prms_mbranch m where m.bran_cat_code in('B','E') )loop
            v_batch_sl:=pkg_autopost.fn_get_batch_SL(idx.brn_code, p_date); 
            v_ho_batchSL:= pkg_autopost.fn_get_batch_SL(p_Ho_branch, p_date);            
            SELECT m.glcode into v_ho_gl_code FROM as_br_gl_mapping m where m.branch_code = p_Ho_branch;   
            SELECT m.glcode into v_br_gl_code FROM as_br_gl_mapping m where m.branch_code = idx.brn_code;                       
            select (-1)*b.cur_bal into v_balance from as_glbalance b where b.branch=idx.brn_code and  b.glcode='190000000'; 
                 --branch part   
         if v_balance<>0 then  
                            
               insert into as_transaction(entity_num,branch,tran_date,glcode,tran_sl,dr_amount,cr_amount,batch_no,naration,chq_reference)
                      values(1,idx.brn_code,p_date,'190000000',1,0,v_balance,v_batch_sl,'AutoPost: TDS','');                                    
               insert into as_transaction(entity_num,branch,tran_date,glcode,tran_sl,dr_amount,cr_amount,batch_no,naration,chq_reference)
                      values(1,idx.brn_code,p_date,v_ho_gl_code,2,v_balance, 0,v_batch_sl,'AutoPost: TDS','');                          
               insert into as_transaction_list (entity_num, orginated_branch,tran_date,batch_no,transaction_type,remarks,dr_amount,cr_amount,enty_by,enty_on)
                      values(1,idx.brn_code,p_date,v_batch_sl,'V','AutoPost: TDS',v_balance, v_balance,'0001',trunc(sysdate));  
                    
               update as_batch_sl s set s.batch_sl = v_batch_sl
                      where s.branch_code = idx.brn_code and s.tran_date = p_date; 
               ---ho part
               insert into as_transaction(entity_num,branch,tran_date,glcode,tran_sl,dr_amount,cr_amount,batch_no,naration,chq_reference)
                      values(1,p_Ho_branch,p_date, v_br_gl_code,1,0,v_balance,v_ho_batchSL,'AutoPost: TDS','');                                    
               insert into as_transaction(entity_num,branch,tran_date,glcode,tran_sl,dr_amount,cr_amount,batch_no,naration,chq_reference)
                      values(1,p_Ho_branch,p_date,'190000000',2,v_balance, 0,v_ho_batchSL,'AutoPost: TDS','');                
               insert into as_transaction_list (entity_num, orginated_branch,tran_date,batch_no,transaction_type,remarks,dr_amount,cr_amount,enty_by,enty_on)
                      values(1,p_Ho_branch,p_date,v_ho_batchSL,'V','AutoPost: TDS',v_balance, v_balance,'0001',trunc(sysdate));    
               update as_batch_sl s set s.batch_sl = v_ho_batchSL
                   where s.branch_code = p_Ho_branch and s.tran_date = p_date;   
     
               dbms_output.put_line(v_batch_sl||'-'||v_ho_batchSL); 
               pkg_gas.sp_BatchAUthorize(idx.brn_code,p_date,v_batch_sl,'0001',v_error);
               pkg_gas.sp_BatchAUthorize(p_Ho_branch,p_date,v_ho_batchSL,'0001',v_error);
                 
               
       end if;        
                         
    end loop;
  end sp_Tds_transfer_to_ho;
  
  procedure sp_PriorYearAdhustment_to_ho(p_date in date,p_Ho_branch in varchar2) is
    v_batch_sl    number := 0;
    v_ho_batchSL  number :=0;
    v_balance number:=0;
    v_error   varchar2(100):='';
    v_ho_gl_code varchar2(9):='';
    v_br_gl_code varchar2(9):='';
    v_balance_unsign number:=0; 
  begin
       for idx in(select *from prms_mbranch m where m.bran_cat_code in('B','E') )loop
            v_batch_sl:=pkg_autopost.fn_get_batch_SL(idx.brn_code, p_date); 
            v_ho_batchSL:= pkg_autopost.fn_get_batch_SL(p_Ho_branch, p_date);            
            SELECT m.glcode into v_ho_gl_code FROM as_br_gl_mapping m where m.branch_code = p_Ho_branch;   
            SELECT m.glcode into v_br_gl_code FROM as_br_gl_mapping m where m.branch_code = idx.brn_code;                       
            select b.cur_bal into v_balance_unsign from as_glbalance b where b.branch=idx.brn_code and  b.glcode='180000000'; 
                 --branch part                                  
           if v_balance_unsign < 0 then
               v_balance:=v_balance_unsign*-1;
               insert into as_transaction(entity_num,branch,tran_date,glcode,tran_sl,dr_amount,cr_amount,batch_no,naration,chq_reference)
                      values(1,idx.brn_code,p_date,'180000000',1,0,v_balance,v_batch_sl,'AutoPost: Prior years Adjustment Account','');                   
               insert into as_transaction(entity_num,branch,tran_date,glcode,tran_sl,dr_amount,cr_amount,batch_no,naration,chq_reference)
                      values(1,idx.brn_code,p_date,v_ho_gl_code,2,v_balance, 0,v_batch_sl,'AutoPost: Prior years Adjustment Account','');      
               insert into as_transaction_list (entity_num, orginated_branch,tran_date,batch_no,transaction_type,remarks,dr_amount,cr_amount,enty_by,enty_on)
                      values(1,idx.brn_code,p_date,v_batch_sl,'V','AutoPost: Prior years Adjustment Account',v_balance, v_balance,'0001',trunc(sysdate));  
                update as_batch_sl s set s.batch_sl = v_batch_sl
                   where s.branch_code = idx.brn_code and s.tran_date = p_date; 
                   ---ho part
               insert into as_transaction(entity_num,branch,tran_date,glcode,tran_sl,dr_amount,cr_amount,batch_no,naration,chq_reference)
                      values(1,p_Ho_branch,p_date, v_br_gl_code,1,0,v_balance,v_ho_batchSL,'AutoPost: Prior years Adjustment Account','');                  
               insert into as_transaction(entity_num,branch,tran_date,glcode,tran_sl,dr_amount,cr_amount,batch_no,naration,chq_reference)
                      values(1,p_Ho_branch,p_date,'180000000',2,v_balance, 0,v_ho_batchSL,'AutoPost: Prior years Adjustment Account','');     
               insert into as_transaction_list (entity_num, orginated_branch,tran_date,batch_no,transaction_type,remarks,dr_amount,cr_amount,enty_by,enty_on)
                      values(1,p_Ho_branch,p_date,v_ho_batchSL,'V','AutoPost: Prior years Adjustment Account',v_balance, v_balance,'0001',trunc(sysdate));  
                update as_batch_sl s set s.batch_sl = v_ho_batchSL where s.branch_code = p_Ho_branch and s.tran_date = p_date;       
               
               dbms_output.put_line(v_batch_sl||'-'||v_ho_batchSL); 
               pkg_gas.sp_BatchAUthorize(idx.brn_code,p_date,v_batch_sl,'0001',v_error);
               pkg_gas.sp_BatchAUthorize(p_Ho_branch,p_date,v_ho_batchSL,'0001',v_error);
                
                
       elsif v_balance_unsign> 0 then
                  
               v_balance:=v_balance_unsign;          
               insert into as_transaction(entity_num,branch,tran_date,glcode,tran_sl,dr_amount,cr_amount,batch_no,naration,chq_reference)
                      values(1,idx.brn_code,p_date, v_ho_gl_code,1,0,v_balance,v_batch_sl,'AutoPost: Prior years Adjustment Account','');       
               insert into as_transaction(entity_num,branch,tran_date,glcode,tran_sl,dr_amount,cr_amount,batch_no,naration,chq_reference)
                      values(1,idx.brn_code,p_date,'180000000',2,v_balance, 0,v_batch_sl,'AutoPost: Prior years Adjustment Account','');  
               insert into as_transaction_list (entity_num, orginated_branch,tran_date,batch_no,transaction_type,remarks,dr_amount,cr_amount,enty_by,enty_on)
                      values(1,idx.brn_code,p_date,v_batch_sl,'V','AutoPost: Prior years Adjustment Account',v_balance, v_balance,'0001',trunc(sysdate));  
               update as_batch_sl s set s.batch_sl = v_batch_sl  where s.branch_code = idx.brn_code and s.tran_date = p_date; 
                   ---ho part
               insert into as_transaction(entity_num,branch,tran_date,glcode,tran_sl,dr_amount,cr_amount,batch_no,naration,chq_reference)
                      values(1,p_Ho_branch,p_date, '180000000',1,0,v_balance,v_ho_batchSL,'AutoPost: Prior years Adjustment Account','');            
               insert into as_transaction(entity_num,branch,tran_date,glcode,tran_sl,dr_amount,cr_amount,batch_no,naration,chq_reference)
                      values(1,p_Ho_branch,p_date, v_br_gl_code,2,v_balance, 0,v_ho_batchSL,'AutoPost: Prior years Adjustment Account','');      
               insert into as_transaction_list (entity_num, orginated_branch,tran_date,batch_no,transaction_type,remarks,dr_amount,cr_amount,enty_by,enty_on)
                      values(1,p_Ho_branch,p_date,v_ho_batchSL,'V','AutoPost: Prior years Adjustment Account',v_balance, v_balance,'0001',trunc(sysdate));  
               update as_batch_sl s set s.batch_sl = v_ho_batchSL where s.branch_code = p_Ho_branch and s.tran_date = p_date;   
     
               dbms_output.put_line(v_batch_sl||'-'||v_ho_batchSL); 
               pkg_gas.sp_BatchAUthorize(idx.brn_code,p_date,v_batch_sl,'0001',v_error);
               pkg_gas.sp_BatchAUthorize(p_Ho_branch,p_date,v_ho_batchSL,'0001',v_error);
                           
       end if;        
                         
    end loop;
  end sp_PriorYearAdhustment_to_ho;
  
  procedure sp_Expenditure_to_ho(p_date in date,p_Ho_branch in varchar2)is
        error_message    varchar2(200) := '';
        Batch_desc       varchar2(200) := '';
  begin
    for idx in(select *from prms_mbranch m where m.bran_cat_code in('B','E') )loop
        pkg_autopost.sp_autopost_expenditure(idx.brn_code,'171000000',p_date,p_Ho_branch,'0001',Batch_desc,error_message);
        dbms_output.put_line(idx.brn_code||'-'||Batch_desc||'-'||error_message);
    end loop;
  end sp_Expenditure_to_ho;
  
  procedure sp_ExpenditureZonal_to_ho(p_date in date,p_Ho_branch in varchar2)is
        error_message    varchar2(200) := '';
        Batch_desc       varchar2(200) := '';
  begin
    for idx in(select *from prms_mbranch m where m.bran_cat_code ='Z')loop
        pkg_autopost.sp_autopost_expenditure(substr(idx.brn_code,1,4),'172000000',p_date,p_Ho_branch,'0001',Batch_desc,error_message);
        dbms_output.put_line(idx.brn_code||'-'||Batch_desc||'-'||error_message);
    end loop;
  end sp_ExpenditureZonal_to_ho;
  
   procedure sp_ExpenditureRegional_to_ho(p_date in date,p_Ho_branch in varchar2)is
        error_message    varchar2(200) := '';
        Batch_desc       varchar2(200) := '';
  begin
    for idx in(select *from prms_mbranch m where m.bran_cat_code ='R')loop
        pkg_autopost.sp_autopost_expenditure(substr(idx.brn_code,1,4),'173000000',p_date,p_Ho_branch,'0001',Batch_desc,error_message);
        dbms_output.put_line(idx.brn_code||'-'||Batch_desc||'-'||error_message);
    end loop;
  end sp_ExpenditureRegional_to_ho;
  
  procedure sp_Income_to_ho(p_date in date,p_Ho_branch in varchar2)is
        error_message    varchar2(200) := '';
        Batch_desc       varchar2(200) := '';
  begin
    for idx in(select *from prms_mbranch m where m.bran_cat_code in('B','E') )loop
        pkg_autopost.sp_autopost_income(idx.brn_code,'160000000',p_date,p_Ho_branch,'0001',Batch_desc,error_message);
        dbms_output.put_line(idx.brn_code||'-'||Batch_desc||'-'||error_message);
    end loop;
  
  end sp_Income_to_ho;
  
   procedure sp_cost_ofFund_to_ho(p_date in date,p_Ho_branch in varchar2)is
      v_batch_sl    number := 0;
      v_ho_batchSL  number :=0;
      v_balance number:=0;
      v_error   varchar2(100):='';
      v_ho_gl_code varchar2(9):='';
      v_br_gl_code varchar2(9):='';
  begin
       for idx in(select *from prms_mbranch m where m.bran_cat_code in('B','E') )loop
              v_batch_sl:=pkg_autopost.fn_get_batch_SL(idx.brn_code, p_date); 
              v_ho_batchSL:= pkg_autopost.fn_get_batch_SL(p_Ho_branch, p_date);
              SELECT m.glcode into v_ho_gl_code FROM as_br_gl_mapping m where m.branch_code = p_Ho_branch;   
              SELECT m.glcode into v_br_gl_code FROM as_br_gl_mapping m where m.branch_code = idx.brn_code;       
              select (-1)*b.cur_bal into v_balance from as_glbalance b where b.branch=idx.brn_code and  b.glcode='175000000'; 
                 --branch part
        if v_balance<>0 then
                   
               insert into as_transaction(entity_num,branch,tran_date,glcode,tran_sl,dr_amount,cr_amount,batch_no,naration,chq_reference)
                      values(1,idx.brn_code,p_date,'175000000',1,0,v_balance,v_batch_sl,'AutoPost: Cost of Fund to HO','');                     
               insert into as_transaction(entity_num,branch,tran_date,glcode,tran_sl,dr_amount,cr_amount,batch_no,naration,chq_reference)
                      values(1,idx.brn_code,p_date,v_ho_gl_code,2,v_balance, 0,v_batch_sl,'AutoPost: Cost of Fund to HO','');            
               insert into as_transaction_list (entity_num, orginated_branch,tran_date,batch_no,transaction_type,remarks,dr_amount,cr_amount,enty_by,enty_on)
                      values(1,idx.brn_code,p_date,v_batch_sl,'V','AutoPost: Cost of Fund to HO',v_balance, v_balance,'0001',trunc(sysdate));  
               update as_batch_sl s set s.batch_sl = v_batch_sl
                   where s.branch_code = idx.brn_code and s.tran_date = p_date; 
                   ---ho part
               insert into as_transaction(entity_num,branch,tran_date,glcode,tran_sl,dr_amount,cr_amount,batch_no,naration,chq_reference)
                      values(1,p_Ho_branch,p_date, v_br_gl_code,1,0,v_balance,v_ho_batchSL,'AutoPost: Cost of Fund to HO','');                      
               insert into as_transaction(entity_num,branch,tran_date,glcode,tran_sl,dr_amount,cr_amount,batch_no,naration,chq_reference)
                      values(1,p_Ho_branch,p_date,'175000000',2,v_balance, 0,v_ho_batchSL,'AutoPost: Cost of Fund to HO','');        
               insert into as_transaction_list (entity_num, orginated_branch,tran_date,batch_no,transaction_type,remarks,dr_amount,cr_amount,enty_by,enty_on)
                      values(1,p_Ho_branch,p_date,v_ho_batchSL,'V','AutoPost: Cost of Fund to HO',v_balance, v_balance,'0001',trunc(sysdate));  
               update as_batch_sl s set s.batch_sl = v_ho_batchSL
                      where s.branch_code = p_Ho_branch and s.tran_date = p_date; 
                        
               dbms_output.put_line(v_batch_sl||'-'||v_ho_batchSL); 
               pkg_gas.sp_BatchAUthorize(idx.brn_code,p_date,v_batch_sl,'0001',v_error);
               pkg_gas.sp_BatchAUthorize(p_Ho_branch,p_date,v_ho_batchSL,'0001',v_error);
                               
       end if;        
                         
     end loop;
  end sp_cost_ofFund_to_ho;
  
  
   procedure sp_ho_Exp_ZonalHead_to_ho_Exp(p_date in date,p_Ho_branch in varchar2)is
      v_ho_batchSL  number :=0;
      v_balance number:=0;
      v_error   varchar2(100):='';
      v_sl         number:=1;
  begin
      v_ho_batchSL:= pkg_autopost.fn_get_batch_SL(p_Ho_branch, p_date); 
        dbms_output.put_line(v_ho_batchSL); 
              
        for idx in( SELECT l.glcode cr_gl,'171'||substr(l.glcode,4,6) dr_gl, l.glname,(-1)* b.cur_bal cur_bal
                      FROM as_glcodelist l
                      join as_glbalance b
                        on (b.glcode = l.glcode)
                     where b.branch = p_Ho_branch
                       and l.lvlcode1 = '172000000'
                       and l.tran_yn = 'Y'
                       and b.cur_bal<>0) loop
                       
                 v_balance:=v_balance+idx.cur_bal;          
                 insert into as_transaction(entity_num,branch,tran_date,glcode,tran_sl,dr_amount,cr_amount,batch_no,naration,chq_reference)
                        values(1,p_Ho_branch,p_date, idx.cr_gl,v_sl,0,idx.cur_bal,v_ho_batchSL,'AutoPost: HO Zonal Expenditure to HO Expenditure','');   
                      v_sl  :=v_sl+1;            
                 insert into as_transaction(entity_num,branch,tran_date,glcode,tran_sl,dr_amount,cr_amount,batch_no,naration,chq_reference)
                        values(1,p_Ho_branch,p_date,idx.dr_gl,v_sl,idx.cur_bal, 0,v_ho_batchSL,'AutoPost: HO Zonal Expenditure to HO Expenditure','');                            
                      v_sl  :=v_sl+1;     
        end loop;   
            
       insert into as_transaction_list (entity_num, orginated_branch,tran_date,batch_no,transaction_type,remarks,dr_amount,cr_amount,enty_by,enty_on)
             values(1,p_Ho_branch,p_date,v_ho_batchSL,'V','AutoPost: HO Zonal Expenditure to HO Expenditure',v_balance, v_balance,'0001',trunc(sysdate));    
       update as_batch_sl s set s.batch_sl = v_ho_batchSL
             where s.branch_code = p_Ho_branch and s.tran_date = p_date;   
       
       dbms_output.put_line(v_ho_batchSL); 
       pkg_gas.sp_BatchAUthorize(p_Ho_branch,p_date,v_ho_batchSL,'0001',v_error);
          
       
  end sp_ho_Exp_ZonalHead_to_ho_Exp;
    
  procedure sp_ho_Exp_RegionHead_to_ho_Exp(p_date in date,p_Ho_branch in varchar2)is
      v_ho_batchSL  number :=0;
      v_balance number:=0;
      v_error   varchar2(100):='';
      v_sl         number:=1;
  begin
       v_ho_batchSL:= pkg_autopost.fn_get_batch_SL(p_Ho_branch, p_date); 
        dbms_output.put_line(v_ho_batchSL); 
              
        for idx in( SELECT l.glcode cr_gl,'171'||substr(l.glcode,4,6) dr_gl, l.glname,(-1)* b.cur_bal cur_bal
                      FROM as_glcodelist l
                      join as_glbalance b
                        on (b.glcode = l.glcode)
                     where b.branch = p_Ho_branch
                       and l.lvlcode1 = '173000000'
                       and l.tran_yn = 'Y'
                       and b.cur_bal<>0) loop
                       
             v_balance:=v_balance+idx.cur_bal;        
             insert into as_transaction(entity_num,branch,tran_date,glcode,tran_sl,dr_amount,cr_amount,batch_no,naration,chq_reference)
                    values(1,p_Ho_branch,p_date, idx.cr_gl,v_sl,0,idx.cur_bal,v_ho_batchSL,'AutoPost: HO Zonal Expenditure to HO Expenditure','');   
                  v_sl  :=v_sl+1;            
             insert into as_transaction(entity_num,branch,tran_date,glcode,tran_sl,dr_amount,cr_amount,batch_no,naration,chq_reference)
                    values(1,p_Ho_branch,p_date,idx.dr_gl,v_sl,idx.cur_bal, 0,v_ho_batchSL,'AutoPost: HO Zonal Expenditure to HO Expenditure','');                            
                  v_sl  :=v_sl+1;     
        end loop;   
            
         insert into as_transaction_list (entity_num, orginated_branch,tran_date,batch_no,transaction_type,remarks,dr_amount,cr_amount,enty_by,enty_on)
               values(1,p_Ho_branch,p_date,v_ho_batchSL,'V','AutoPost: HO Zonal Expenditure to HO Expenditure',v_balance, v_balance,'0001',trunc(sysdate));  
                          
          update as_batch_sl s set s.batch_sl = v_ho_batchSL
               where s.branch_code = p_Ho_branch and s.tran_date = p_date;   
       
         dbms_output.put_line(v_ho_batchSL); 
         pkg_gas.sp_BatchAUthorize(p_Ho_branch,p_date,v_ho_batchSL,'0001',v_error);
         
                   
  end sp_ho_Exp_RegionHead_to_ho_Exp;
  
  procedure sp_IncomeTo_PL_AC(p_date in date,p_Ho_branch in varchar2) is
      v_ho_batchSL  number :=0;
      v_balance number:=0;
      v_error   varchar2(100):='';
      v_sl         number:=1;
    
  begin
        v_ho_batchSL:= pkg_autopost.fn_get_batch_SL(p_Ho_branch, p_date); 
        dbms_output.put_line(v_ho_batchSL);               
        for idx in( SELECT l.glcode dr_gl,'470000000' cr_gl, l.glname, b.cur_bal cur_bal,b.fin_year
                      FROM as_glcodelist l
                      join as_glbalance b
                        on (b.glcode = l.glcode)
                     where b.branch = p_Ho_branch
                       and l.mainhead = '160000000'
                       and l.tran_yn = 'Y'
                       and b.cur_bal<>0) loop
                       
                 v_balance:=v_balance+idx.cur_bal;
                 insert into as_transaction(entity_num,branch,tran_date,glcode,tran_sl,dr_amount,cr_amount,batch_no,naration,chq_reference)
                        values(1,p_Ho_branch,p_date, idx.cr_gl,v_sl,0,idx.cur_bal,v_ho_batchSL,'AutoPost: Income of the FY'||idx.fin_year||'  to PL A/C','');   
                  v_sl:=v_sl+1;           
                 insert into as_transaction(entity_num,branch,tran_date,glcode,tran_sl,dr_amount,cr_amount,batch_no,naration,chq_reference)
                        values(1,p_Ho_branch,p_date,idx.dr_gl,v_sl,idx.cur_bal, 0,v_ho_batchSL,'AutoPost: Income of the FY'||idx.fin_year||'  to PL A/C','');                            
                  v_sl:=v_sl+1;
                  
         end loop;   
        
         insert into as_transaction_list (entity_num, orginated_branch,tran_date,batch_no,transaction_type,remarks,dr_amount,cr_amount,enty_by,enty_on)
               values(1,p_Ho_branch,p_date,v_ho_batchSL,'V','AutoPost: Income of the FY2020-2021 to PL A/C',v_balance, v_balance,'0001',trunc(sysdate));  
                  
         update as_batch_sl s set s.batch_sl = v_ho_batchSL
               where s.branch_code = p_Ho_branch and s.tran_date = p_date;          
         dbms_output.put_line(v_ho_batchSL); 
         pkg_gas.sp_BatchAUthorize(p_Ho_branch,p_date,v_ho_batchSL,'0001',v_error);
         dbms_output.put_line(v_error);  
         
  end sp_IncomeTo_PL_AC;
  procedure sp_ExpenditureTo_PL_AC(p_date in date,p_Ho_branch in varchar2) is
      v_ho_batchSL  number :=0;
      v_balance number:=0;
      v_error   varchar2(100):='';
      v_sl         number:=1;
    
  begin
        v_ho_batchSL:= pkg_autopost.fn_get_batch_SL(p_Ho_branch, p_date); 
        dbms_output.put_line(v_ho_batchSL);               
        for idx in( SELECT l.glcode dr_gl,'470000000' cr_gl, l.glname, b.cur_bal cur_bal,b.fin_year
                      FROM as_glcodelist l
                      join as_glbalance b
                        on (b.glcode = l.glcode)
                     where b.branch = p_Ho_branch
                       and l.lvlcode1 = '171000000'
                       and l.tran_yn = 'Y'
                       and b.cur_bal<>0) loop
                       
                 v_balance:=v_balance+idx.cur_bal;
                 insert into as_transaction(entity_num,branch,tran_date,glcode,tran_sl,dr_amount,cr_amount,batch_no,naration,chq_reference)
                    values(1,p_Ho_branch,p_date, idx.cr_gl,v_sl,0,idx.cur_bal,v_ho_batchSL,'AutoPost: Expenditure of the FY'||idx.fin_year||' to PL A/C','');   
                 v_sl:=v_sl+1; 
                 insert into as_transaction(entity_num,branch,tran_date,glcode,tran_sl,dr_amount,cr_amount,batch_no,naration,chq_reference)
                    values(1,p_Ho_branch,p_date,idx.dr_gl,v_sl,idx.cur_bal, 0,v_ho_batchSL,'AutoPost: Expenditure of the FY'||idx.fin_year||' to PL A/C','');                           
                 v_sl:=v_sl+1;
                  
         end loop;   
        
         insert into as_transaction_list (entity_num, orginated_branch,tran_date,batch_no,transaction_type,remarks,dr_amount,cr_amount,enty_by,enty_on)
                   values(1,p_Ho_branch,p_date,v_ho_batchSL,'V','AutoPost: Expenditure of the FY2020-2021 to PL A/C',v_balance, v_balance,'0001',trunc(sysdate));  
                  
         update as_batch_sl s set s.batch_sl = v_ho_batchSL
               where s.branch_code = p_Ho_branch and s.tran_date = p_date;          
         dbms_output.put_line(v_ho_batchSL); 
         pkg_gas.sp_BatchAUthorize(p_Ho_branch,p_date,v_ho_batchSL,'0001',v_error);
         dbms_output.put_line(v_error);  
         
  end sp_ExpenditureTo_PL_AC;
  
  
  procedure sp_before_Adjustment(p_date in date,p_Ho_branch in varchar2)
  is
  begin
    sp_ExpenditureRegional_to_ho(p_date ,p_Ho_branch);
    sp_ExpenditureZonal_to_ho(p_date ,p_Ho_branch);
  end sp_before_Adjustment;
  
  
  procedure sp_After_Adjustment(p_date in date,p_Ho_branch in varchar2)
  is
  begin
    --Branch to HO Transfer
    sp_cost_ofFund_to_ho(p_date ,p_Ho_branch);
    sp_Tds_transfer_to_ho(p_date ,p_Ho_branch);
    sp_PriorYearAdhustment_to_ho(p_date ,p_Ho_branch);
    sp_Income_to_ho(p_date ,p_Ho_branch);
    sp_Expenditure_to_ho(p_date ,p_Ho_branch);
    
     --HO to HO Transfer
    sp_ho_Exp_RegionHead_to_ho_Exp(p_date ,p_Ho_branch);
    sp_ho_Exp_ZonalHead_to_ho_Exp(p_date ,p_Ho_branch);    
    sp_IncomeTo_PL_AC(p_date ,p_Ho_branch);
    sp_ExpenditureTo_PL_AC(p_date ,p_Ho_branch);
     
      
  end sp_After_Adjustment;
  
begin
  null;
end pkg_closing;
/
