create or replace package pkg_param is

  procedure sp_day_begin(p_user_id in varchar2,
                         p_date    in date,
                         p_error   out varchar2);
  procedure sp_item_creation(p_branch_code  in varchar2,
                             p_item_code    in varchar2,
                             p_item_name    in varchar2,
                             p_dr_gl        in varchar2,
                             p_cr_gl        in varchar2,
                             p_item_enty    in date,
                             p_item_remarks in varchar2,
                             p_user_id      in varchar2,
                             p_error        out varchar2);
  procedure sp_gl_setup(p_glcode      in varchar2,
                        p_glname      in varchar2,
                        p_gltype      in char,
                        p_subgl       in char,
                        p_head_glcode in char,
                        p_exp_type    in char,
                        p_inc_type    in char,
                        p_enty_date   date,
                        p_remarks     in varchar2,
                        p_user_id     in varchar2,
                        p_error       out varchar2);
  procedure sp_branch_ledger_opening(p_branch     in varchar2,
                                     p_head_gl    in varchar2,
                                     p_gl_name    in varchar2,
                                     p_remarks    in varchar2,
                                     p_enty_date  in date,
                                     p_user_id    in varchar2,
                                     p_newgl_code out varchar2,
                                     p_error      out varchar2);
  procedure sp_branch_balance_init(p_branch   in varchar2,
                                   p_fin_year in varchar2,
                                   p_error    out varchar2);
  procedure sp_branch_zero_balance_setup(p_branch in varchar2,
                                         p_error  out varchar2);
  type gldata is record(
    glcode varchar2(10),
    glname varchar2(120));
  type v_gldata is table of gldata;

  type gl_record is record(
    gl_group    varchar2(15),
    hl_grp_name varchar2(200),
    glcode      varchar2(15),
    sub_gl      char(1),
    tran_gl     char(1),
    glname      varchar2(200));
  type v_gl_record is table of gl_record;

  function fn_get_list(p_branch in varchar2) return v_gldata
    pipelined;
  function fn_glcode(p_branch in varchar2) return v_gl_record
    pipelined;
  procedure sp_branch_ledger_serial_setup(p_branch in varchar2,
                                          p_error  out varchar2);
  function fn_transaction_head(p_branch in varchar2) return v_gl_record
    pipelined;
  function fn_get_glcode(p_branch in varchar2) return v_gl_record
    pipelined;
  function fn_get_glcode_statement(p_branch in varchar2) return v_gl_record
  
    pipelined;
  function fn_get_glcode_reconciliation(p_branch in varchar2)
    return v_gl_record
    pipelined;
  function fn_get_branch_glcode(p_branch in varchar2)
    return v_gl_record pipelined;
    function fn_misc_data(p_branch in varchar2) return v_gl_record
    pipelined;  
    procedure sp_application_log(p_RequestType  varchar2,
                               p_DataObject   varchar2,
                               p_ErrorMessage    in varchar2,
                               p_Error_code in varchar2);
     procedure sp_DaySetUp(p_user_id in varchar2,
                        p_date    in date,
                        p_postType   in varchar2,
                        p_remarks    in varchar2,
                        p_error   out varchar2);
  procedure sp_off_day_check(p_date    in date ,
                             P_postType    out varchar2);                                                 
end pkg_param;
/
create or replace package body pkg_param is
  procedure sp_off_day_check(p_date    in date ,
                             P_postType    out varchar2)is 
  begin
    
     select a.transactionpost into P_postType from as_working_days a where a.transactiondate=p_date;
     
  exception when others then 
    P_postType:='N';
  end sp_off_day_check;                          
    
  procedure sp_DaySetUp(p_user_id in varchar2,
                        p_date    in date,
                        p_postType   in varchar2,
                        p_remarks    in varchar2,
                        p_error   out varchar2) is 
   v_exist number := 0;  
   v_error varchar2(100):='';                    
  begin
   select count(*)
      into v_exist
      from as_working_days a
     where a.transactiondate = p_date;
  
  if v_exist<>0 then
    update as_working_days k set k.transactionpost=p_postType,
                           k.remarks=p_remarks
          where k.transactiondate= p_date;                
  else
    insert into as_working_days (transactiondate,transactionpost,remarks,entry_by,entry_on)
            values(p_date,p_postType,p_remarks,p_user_id,trunc(sysdate));
            
     pkg_param.sp_day_begin(p_user_id,p_date,v_error);             
  end if;
  end  sp_DaySetUp;                     
 
  procedure sp_day_begin(p_user_id in varchar2,
                         p_date    in date,
                         p_error   out varchar2) is
    v_exist number := 0;
  begin
    select count(*)
      into v_exist
      from as_batch_sl a
     where a.tran_date = p_date;
    if v_exist = 0 then
      for idx in (select *
                    from prms_mbranch m
                   where m.brn_code not like '%Z'
                     and m.brn_code not like '%R') loop
        insert into as_batch_sl
          (branch_code, tran_date, batch_sl, user_id)
        values
          (idx.brn_code, p_date, 0, p_user_id);
      end loop;
    else
      p_error := 'Day Begin process already Done';
    end if;
  
  end sp_day_begin;
  procedure sp_item_creation(p_branch_code  in varchar2,
                             p_item_code    in varchar2,
                             p_item_name    in varchar2,
                             p_dr_gl        in varchar2,
                             p_cr_gl        in varchar2,
                             p_item_enty    in date,
                             p_item_remarks in varchar2,
                             p_user_id      in varchar2,
                             p_error        out varchar2) is
    v_exist number := 0;
  begin
    select count(*)
      into v_exist
      from as_itemlist u
     where u.branch_code = p_branch_code
       and u.item_code = p_item_code;
    if v_exist = 0 then
      insert into as_itemlist
        (entity,
         branch_code,
         item_code,
         item_desc,
         debit_gl,
         credit_gl,
         enty_by,
         enty_date,
         remarks)
      values
        (1,
         p_branch_code,
         p_item_code,
         p_item_name,
         p_dr_gl,
         p_cr_gl,
         p_user_id,
         p_item_enty,
         p_item_remarks);
    
    else
      update as_itemlist l
         set item_desc = p_item_name,
             debit_gl  = p_dr_gl,
             credit_gl = p_cr_gl,
             enty_by   = p_user_id,
             enty_date = p_item_enty,
             remarks   = p_item_remarks
       where l.entity = 1
         and l.branch_code = p_branch_code
         and l.item_code = p_item_code;
    end if;
  
  exception
    when others then
      p_error := 'Error in sp_item_creation' || sqlerrm;
  end sp_item_creation;

  procedure sp_gl_setup(p_glcode      in varchar2,
                        p_glname      in varchar2,
                        p_gltype      in char,
                        p_subgl       in char,
                        p_head_glcode in char,
                        p_exp_type    in char,
                        p_inc_type    in char,
                        p_enty_date   date,
                        p_remarks     in varchar2,
                        p_user_id     in varchar2,
                        p_error       out varchar2) is
    v_exist number := 0;
  begin
    select count(*)
      into v_exist
      from as_glcodelist u
     where u.entity_num = 1
       and u.glcode = p_glcode;
    if v_exist = 0 then
      null;
    
      insert into as_glcodelist
        (entity_num,
         glcode,
         glname,
         gl_type,
         sub_gl,
         mainhead,
         inc_exp,
         cap_rev,
         remarks,
         enty_by,
         enty_on)
      values
        (1,
         p_glcode,
         p_glname,
         p_gltype,
         p_subgl,
         p_head_glcode,
         p_inc_type,
         p_exp_type,
         p_remarks,
         p_user_id,
         trunc(p_enty_date));
    
    else
      update as_glcodelist l
         set l.glname   = p_glname,
             l.gl_type  = p_gltype,
             l.sub_gl   = p_subgl,
             l.mainhead = p_head_glcode,
             l.inc_exp  = p_inc_type,
             l.inc_exp  = p_exp_type,
             l.remarks  = p_remarks,
             l.mod_by   = p_user_id,
             l.mod_on   = trunc(p_enty_date)
       where l.entity_num = 1
         and l.glcode = p_glcode;
    end if;
  exception
    when others then
      p_error := 'Error in sp_gl_setup' || sqlerrm;
    
  end sp_gl_setup;
  procedure sp_branch_ledger_opening(p_branch     in varchar2,
                                     p_head_gl    in varchar2,
                                     p_gl_name    in varchar2,
                                     p_remarks    in varchar2,
                                     p_enty_date  in date,
                                     p_user_id    in varchar2,
                                     p_newgl_code out varchar2,
                                     p_error      out varchar2) is
    v_count     number := 0;
    v_main_head varchar2(15) := '';
    v_lvl_code1 varchar2(15) := '';
    v_lvl_code2 varchar2(15) := '';
    v_lvl_code3 varchar2(15) := '';
    v_lvl_code4 varchar2(15) := '';
    v_lvl_code5 varchar2(15) := '';
  
    v_date1    date;
    v_date2    date;
    V_fin_year varchar2(12) := '';
  
  begin
  
    SELECT m.start_date, m.end_date, m.fin_year
      into v_date1, v_date2, V_fin_year
      FROM as_finyear  m where m.activatation='Y';
      
      
    select b.sl_no + 1
      into v_count
      from as_subgl_sl b
     where b.enitiy_num = 1
       and b.branch_code = p_branch
       and b.gl_code = p_head_gl;
  
    p_newgl_code := p_branch || '' || substr(p_head_gl, 1, 7) ||
                    lpad(v_count, 2, 0);
  
    for id in (select *
                 from as_glcodelist l
                where l.entity_num = 1
                  and l.glcode = p_head_gl) loop
    
      if id.mainhead is null then
        v_main_head := p_head_gl;
      else
        v_main_head := id.mainhead;
        if id.lvlcode1 is null then
          v_lvl_code1 := p_head_gl;
        else
          v_lvl_code1 := id.lvlcode1;
          if id.lvlcode2 is null then
            v_lvl_code2 := p_head_gl;
          else
            v_lvl_code2 := id.lvlcode2;
          
            if id.lvlcode3 is null then
              v_lvl_code3 := p_head_gl;
            else
              v_lvl_code3 := id.lvlcode3;
              if id.lvlcode4 is null then
                v_lvl_code4 := p_head_gl;
              else
                v_lvl_code4 := id.lvlcode4;
                v_lvl_code5 := p_head_gl;
              end if;
            end if;
          end if;
        end if;
      end if;
    
      insert into as_glcodelist
        (entity_num,
         glcode,
         glname,
         remarks,
         sub_gl,
         lvlcode5,
         lvlcode4,
         lvlcode3,
         lvlcode2,
         lvlcode1,
         mainhead,
         slot_yn,
         tran_yn,
         br_ho,
         gl_type,
         inc_exp,
         cap_rev,
         enty_by,
         enty_on)
      values
        (1,
         p_newgl_code,
         id.glname || '_' || p_gl_name,
         p_remarks,
         '1',
         v_lvl_code5,
         v_lvl_code4,
         v_lvl_code3,
         v_lvl_code2,
         v_lvl_code1,
         v_main_head,
         'N',
         'Y',
         'B',
         '',
         '',
         '',
         p_user_id,
         trunc(p_enty_date));
    
    end loop;
  
    update as_subgl_sl b
       set b.sl_no = v_count
     where b.enitiy_num = 1
       and b.branch_code = p_branch
       and b.gl_code = p_head_gl;
  
      insert into as_glbalance
        (entity_num, branch, fin_year, glcode, init_bal, cur_bal)
      values
        (1, p_branch, V_fin_year, p_newgl_code, 0, 0);
        
  exception
    when others then
      p_error := 'Error in sp_branch_ledger_Opening' || sqlerrm;
  end sp_branch_ledger_opening;

  function fn_get_list(p_branch in varchar2) return v_gldata
    pipelined is
    w_gldata gldata;
  begin
    for idx in (select *
                  from as_glcodelist g
                 where g.glcode like '%' || p_branch || '15%') loop
      w_gldata.glcode := idx.glcode;
      w_gldata.glname := idx.glname;
      pipe row(w_gldata);
    
    end loop;
  
    for idx in (select *
                  from as_glcodelist g
                 where g.tran_yn = 'Y'
                   and g.mainhead not like '15%') loop
      w_gldata.glcode := idx.glcode;
      w_gldata.glname := idx.glname;
      pipe row(w_gldata);
    
    end loop;
  
  end fn_get_list;

  function fn_transaction_head(p_branch in varchar2) return v_gl_record
    pipelined is
    w_gldata gl_record;
    v_br_cat char(1);
    v_zn_cat char(1);
    v_rm_cat char(1);
  begin
  
    select b.bran_cat_code
      into v_br_cat
      from prms_mbranch b
     where b.brn_code = p_branch;
  
    begin
      select b.bran_cat_code
        into v_rm_cat
        from prms_mbranch b
       where b.brn_code = p_branch || 'R';
    exception
      when others then
        v_rm_cat := 'X';
    end;
  
    begin
      select b.bran_cat_code
        into v_zn_cat
        from prms_mbranch b
       where b.brn_code = p_branch || 'Z';
    exception
      when others then
        v_zn_cat := 'X';
    end;
  
    if v_rm_cat = 'R' then
      for idx in (select *
                    from as_glcodelist g
                   where g.tran_yn = 'Y'
                     and g.slot_yn <> 'Y'
                     and g.glcode like '173%') loop
        w_gldata.gl_group := substr(idx.glcode, 1, 3) || '000000';
        select l.glname
          into w_gldata.hl_grp_name
          from glcodelist l
         where l.glcode = substr(idx.glcode, 1, 3) || '000000';
        w_gldata.sub_gl  := idx.sub_gl;
        w_gldata.glcode  := idx.glcode;
        w_gldata.tran_gl := idx.tran_yn;
        w_gldata.glname  := idx.glname;
        pipe row(w_gldata);
      end loop;
    end if;
  
    if v_zn_cat = 'Z' then
      for idx in (select *
                    from as_glcodelist g
                   where g.tran_yn = 'Y'
                     and g.slot_yn <> 'Y'
                     and g.glcode like '172%') loop
        w_gldata.gl_group := substr(idx.glcode, 1, 3) || '000000';
        select l.glname
          into w_gldata.hl_grp_name
          from glcodelist l
         where l.glcode = substr(idx.glcode, 1, 3) || '000000';
        w_gldata.sub_gl  := idx.sub_gl;
        w_gldata.glcode  := idx.glcode;
        w_gldata.tran_gl := idx.tran_yn;
        w_gldata.glname  := idx.glname;
        pipe row(w_gldata);
      end loop;
    end if;
  
    if v_br_cat = 'H' then
      for idx in (select *
                    from as_glcodelist g
                   where g.tran_yn = 'Y'
                     and g.glcode like '173%') loop
        w_gldata.gl_group := substr(idx.glcode, 1, 3) || '000000';
        select l.glname
          into w_gldata.hl_grp_name
          from glcodelist l
         where l.glcode = substr(idx.glcode, 1, 3) || '000000';
        w_gldata.sub_gl  := idx.sub_gl;
        w_gldata.glcode  := idx.glcode;
        w_gldata.tran_gl := idx.tran_yn;
        w_gldata.glname  := idx.glname;
        pipe row(w_gldata);
      end loop;
    
      for idx in (select *
                    from as_glcodelist g
                   where g.tran_yn = 'Y'
                     and g.glcode like '172%') loop
        w_gldata.gl_group := substr(idx.glcode, 1, 3) || '000000';
        select l.glname
          into w_gldata.hl_grp_name
          from glcodelist l
         where l.glcode = substr(idx.glcode, 1, 3) || '000000';
        w_gldata.sub_gl  := idx.sub_gl;
        w_gldata.glcode  := idx.glcode;
        w_gldata.tran_gl := idx.tran_yn;
        w_gldata.glname  := idx.glname;
        pipe row(w_gldata);
      end loop;
    
      for idx in (select *
                    from as_glcodelist g
                   where g.tran_yn = 'Y'
                     and g.gl_visible in ('A', 'M')
                     and g.glcode not like '172%'
                     and g.glcode not like '173%'
                     and g.ho_ecs = 'H') loop
        w_gldata.gl_group := substr(idx.glcode, 1, 3) || '000000';
        select l.glname
          into w_gldata.hl_grp_name
          from glcodelist l
         where l.glcode = substr(idx.glcode, 1, 3) || '000000';
        w_gldata.sub_gl  := idx.sub_gl;
        w_gldata.glcode  := idx.glcode;
        w_gldata.tran_gl := idx.tran_yn;
        w_gldata.glname  := idx.glname;
        pipe row(w_gldata);
      end loop;
    
     for idx in (select *
                    from as_glcodelist g
                   where g.tran_yn = 'Y'
                     and g.gl_visible in ('M')                  
                     and g.ho_ecs = 'B') loop
        w_gldata.gl_group := substr(idx.glcode, 1, 3) || '000000';
        select l.glname
          into w_gldata.hl_grp_name
          from glcodelist l
         where l.glcode = substr(idx.glcode, 1, 3) || '000000';
        w_gldata.sub_gl  := idx.sub_gl;
        w_gldata.glcode  := idx.glcode;
        w_gldata.tran_gl := idx.tran_yn;
        w_gldata.glname  := idx.glname;
        pipe row(w_gldata);
      end loop;
    
    
    elsif v_br_cat = 'E' then
    
      for idx in (select *
                    from as_glcodelist g
                   where g.tran_yn = 'Y'
                     and g.slot_yn <> 'Y'
                     and g.gl_visible in ('A', 'M')
                     and g.glcode not like '172%'
                     and g.glcode not like '173%'
                     and g.ho_ecs = 'E') loop
        w_gldata.gl_group := substr(idx.glcode, 1, 3) || '000000';
        select l.glname
          into w_gldata.hl_grp_name
          from glcodelist l
         where l.glcode = substr(idx.glcode, 1, 3) || '000000';
        w_gldata.sub_gl  := idx.sub_gl;
        w_gldata.glcode  := idx.glcode;
        w_gldata.tran_gl := idx.tran_yn;
        w_gldata.glname  := idx.glname;
        pipe row(w_gldata);
      
      end loop;
      
      for idx in (select *
                    from as_glcodelist g
                   where g.tran_yn = 'Y'
                     and g.gl_visible in ('M')                  
                     and g.ho_ecs = 'B') loop
        w_gldata.gl_group := substr(idx.glcode, 1, 3) || '000000';
        select l.glname
          into w_gldata.hl_grp_name
          from glcodelist l
         where l.glcode = substr(idx.glcode, 1, 3) || '000000';
        w_gldata.sub_gl  := idx.sub_gl;
        w_gldata.glcode  := idx.glcode;
        w_gldata.tran_gl := idx.tran_yn;
        w_gldata.glname  := idx.glname;
        pipe row(w_gldata);
      end loop;
    
    else
      for idx in (select *
                    from as_glcodelist g
                   where g.tran_yn = 'Y'
                     and g.slot_yn <> 'Y'
                     and g.gl_visible in ('A', 'B')
                     and g.glcode not like '172%'
                     and g.glcode not like '173%') loop
        w_gldata.gl_group := substr(idx.glcode, 1, 3) || '000000';
        select l.glname
          into w_gldata.hl_grp_name
          from glcodelist l
         where l.glcode = substr(idx.glcode, 1, 3) || '000000';
        w_gldata.sub_gl  := idx.sub_gl;
        w_gldata.glcode  := idx.glcode;
        w_gldata.tran_gl := idx.tran_yn;
        w_gldata.glname  := idx.glname;
        pipe row(w_gldata);
      end loop;
    end if;
  
    for idx in (select *
                  from as_glcodelist g
                 where g.tran_yn = 'Y'
                   and g.glcode like p_branch || '%') loop
      w_gldata.gl_group := substr(idx.glcode, 1, 3) || '000000';
      select l.glname
        into w_gldata.hl_grp_name
        from glcodelist l
       where l.glcode = substr(idx.glcode, 1, 3) || '000000';
      w_gldata.sub_gl  := idx.sub_gl;
      w_gldata.glcode  := idx.glcode;
      w_gldata.tran_gl := idx.tran_yn;
      w_gldata.glname  := idx.glname;
      pipe row(w_gldata);
    end loop;
  
  end fn_transaction_head;

  function fn_get_glcode(p_branch in varchar2) return v_gl_record
    pipelined is
    w_gldata gl_record;
    v_br_cat char(1);
    v_zn_cat char(1);
    v_rm_cat char(1);
  begin
    select b.bran_cat_code
      into v_br_cat
      from prms_mbranch b
     where b.brn_code = p_branch;
  
    begin
      select b.bran_cat_code
        into v_rm_cat
        from prms_mbranch b
       where b.brn_code = p_branch || 'R';
    exception
      when others then
        v_rm_cat := 'X';
    end;
  
    begin
      select b.bran_cat_code
        into v_zn_cat
        from prms_mbranch b
       where b.brn_code = p_branch || 'Z';
    exception
      when others then
        v_zn_cat := 'X';
    end;
  
    IF v_br_cat = 'B' THEN
      for idx in (select *
                    from as_glcodelist g
                   where g.TRAN_YN = 'Y'
                     AND G.SLOT_YN = 'N'
                     and g.gl_visible = 'A'
                     AND G.GLCODE NOT LIKE '172%'
                     AND G.GLCODE NOT LIKE '173%'
                     AND G.GLCODE NOT LIKE '500%'
                     and length(g.glcode) < 10) loop
        w_gldata.sub_gl  := idx.sub_gl;
        w_gldata.glcode  := idx.glcode;
        w_gldata.tran_gl := idx.tran_yn;
        w_gldata.glname  := idx.glname;
        pipe row(w_gldata);
      end loop;
    
      for idx in (select *
                    from as_glcodelist g
                   where g.TRAN_YN = 'Y'
                     AND G.SLOT_YN = 'N'
                     and g.gl_visible = 'B'
                     AND G.GLCODE NOT LIKE '172%'
                     AND G.GLCODE NOT LIKE '173%'
                     AND G.GLCODE NOT LIKE '500%'
                     and length(g.glcode) < 10) loop
        w_gldata.sub_gl  := idx.sub_gl;
        w_gldata.glcode  := idx.glcode;
        w_gldata.tran_gl := idx.tran_yn;
        w_gldata.glname  := idx.glname;
        pipe row(w_gldata);
      end loop;
    
      IF v_zn_cat = 'Z' THEN
      
        for idx in (select *
                      from as_glcodelist g
                     where g.TRAN_YN = 'Y'
                       AND G.SLOT_YN = 'N'
                       AND G.GLCODE LIKE '172%'
                       and length(g.glcode) < 10) loop
          w_gldata.sub_gl  := idx.sub_gl;
          w_gldata.glcode  := idx.glcode;
          w_gldata.tran_gl := idx.tran_yn;
          w_gldata.glname  := idx.glname;
          pipe row(w_gldata);
        END LOOP;
      END IF;
      IF v_rm_cat = 'R' THEN
      
        for idx in (select *
                      from as_glcodelist g
                     where g.TRAN_YN = 'Y'
                       AND G.SLOT_YN = 'N'
                       AND G.GLCODE LIKE '173%'
                       and length(g.glcode) < 10) loop
          w_gldata.sub_gl  := idx.sub_gl;
          w_gldata.glcode  := idx.glcode;
          w_gldata.tran_gl := idx.tran_yn;
          w_gldata.glname  := idx.glname;
          pipe row(w_gldata);
        END LOOP;
      
      END IF;
    ELSIF v_br_cat = 'H' THEN
      for idx in (select *
                    from as_glcodelist g
                   where g.TRAN_YN = 'Y'
                     AND G.SLOT_YN = 'N'
                     and g.gl_visible = 'A'
                     AND G.GLCODE NOT LIKE '500%'
                        --AND G.GLCODE NOT LIKE '172%'
                        --  AND G.GLCODE NOT LIKE '173%'
                     and length(g.glcode) < 10) loop
        w_gldata.sub_gl  := idx.sub_gl;
        w_gldata.glcode  := idx.glcode;
        w_gldata.tran_gl := idx.tran_yn;
        w_gldata.glname  := idx.glname;
        pipe row(w_gldata);
      end loop;
      for idx in (select *
                    from as_glcodelist g
                   where g.TRAN_YN = 'Y'
                     AND G.SLOT_YN = 'N'
                     and g.gl_visible = 'M'
                     AND G.HO_ECS IN ('H', 'B')
                     AND G.GLCODE NOT LIKE '172%'
                     AND G.GLCODE NOT LIKE '173%'
                     AND G.GLCODE NOT LIKE '500%'
                     and length(g.glcode) < 10) loop
        w_gldata.sub_gl  := idx.sub_gl;
        w_gldata.glcode  := idx.glcode;
        w_gldata.tran_gl := idx.tran_yn;
        w_gldata.glname  := idx.glname;
        pipe row(w_gldata);
      END LOOP;
    
    ELSIF v_br_cat = 'E' THEN
    
      for idx in (select *
                    from as_glcodelist g
                   where g.TRAN_YN = 'Y'
                     AND G.SLOT_YN = 'N'
                     AND G.GLCODE = '210010000') loop
        w_gldata.sub_gl  := idx.sub_gl;
        w_gldata.glcode  := idx.glcode;
        w_gldata.tran_gl := idx.tran_yn;
        w_gldata.glname  := idx.glname;
        pipe row(w_gldata);
      end loop;
    
      for idx in (select *
                    from as_glcodelist g
                   where g.TRAN_YN = 'Y'
                     AND G.SLOT_YN = 'N'
                     and g.gl_visible = 'A'
                     AND G.GLCODE NOT LIKE '172%'
                     AND G.GLCODE NOT LIKE '173%'
                     AND G.GLCODE NOT LIKE '210%'
                     AND G.GLCODE NOT LIKE '500%'
                     and length(g.glcode) < 10) loop
        w_gldata.sub_gl  := idx.sub_gl;
        w_gldata.glcode  := idx.glcode;
        w_gldata.tran_gl := idx.tran_yn;
        w_gldata.glname  := idx.glname;
        pipe row(w_gldata);
      end loop;
    
      for idx in (select *
                    from as_glcodelist g
                   where g.TRAN_YN = 'Y'
                     AND G.SLOT_YN = 'N'
                     and g.gl_visible = 'M'
                     AND G.HO_ECS IN ('E', 'B')
                     AND G.GLCODE NOT LIKE '172%'
                     AND G.GLCODE NOT LIKE '173%'
                      AND G.GLCODE NOT LIKE '500%'
                     and length(g.glcode) < 10) loop
        w_gldata.sub_gl  := idx.sub_gl;
        w_gldata.glcode  := idx.glcode;
        w_gldata.tran_gl := idx.tran_yn;
        w_gldata.glname  := idx.glname;
        pipe row(w_gldata);
      END LOOP;
    END IF;
  
    for idx in (select *
                  from as_glcodelist g
                 where g.TRAN_YN = 'Y'
                   AND G.SLOT_YN = 'N'
                   and G.GLCODE LIKE p_branch || '%'
                   and length(g.glcode) > 9) loop
      w_gldata.sub_gl  := idx.sub_gl;
      w_gldata.glcode  := idx.glcode;
      w_gldata.tran_gl := idx.tran_yn;
      w_gldata.glname  := idx.glname;
      pipe row(w_gldata);
    END LOOP;
  
  end fn_get_glcode;

  function fn_get_glcode_statement(p_branch in varchar2) return v_gl_record
    pipelined is
    w_gldata gl_record;
  
  begin
    for idx in (SELECT distinct glcode
                          FROM (SELECT distinct t.glcode
                                  FROM as_transaction t
                                 where t.branch = p_branch
                                union
                                SELECT distinct b.glcode
                                  FROM as_glbalance b
                                 where b.branch = p_branch
                                   and b.cur_bal <> 0
                                   and (SELECT l.tran_yn
                                          FROM as_glcodelist l
                                         where l.glcode = b.glcode) = 'Y')) loop
                                         
      SELECT g.sub_gl into w_gldata.sub_gl FROM  as_glcodelist g where g.glcode=idx.glcode;                                
      w_gldata.glcode  := idx.glcode;
      w_gldata.tran_gl := 'Y';
      SELECT g.glname into w_gldata.glname FROM  as_glcodelist g where g.glcode=idx.glcode;   
      pipe row(w_gldata);
    END LOOP;
  
  end fn_get_glcode_statement;

  function fn_get_glcode_reconciliation(p_branch in varchar2)
    return v_gl_record
    pipelined is
    w_gldata gl_record;
  
  begin
    for idx in (SELECT l.branch_code, l.glcode
                  FROM as_br_gl_mapping l
                 where l.branch_code = p_branch) loop
      w_gldata.sub_gl  := '1';
      w_gldata.glcode  := idx.glcode;
      w_gldata.tran_gl := 'Y';
    
      SELECT L.GLNAME
        INTO w_gldata.glname
        FROM AS_GLCODELIST L
       WHERE L.ENTITY_NUM = 1
         AND L.GLCODE = idx.glcode;
    
      pipe row(w_gldata);
    END LOOP;
  
  end fn_get_glcode_reconciliation;
  
  function fn_get_branch_glcode(p_branch in varchar2)
    return v_gl_record
    pipelined is
    w_gldata gl_record;
  
  begin
    for idx in (SELECT * FROM as_glcodelist l where l.glcode like '210%' and l.tran_yn='Y') loop
      w_gldata.sub_gl  := idx.sub_gl;
      w_gldata.glcode  := idx.glcode;
      w_gldata.tran_gl := idx.tran_yn;
    
      SELECT L.GLNAME
        INTO w_gldata.glname
        FROM AS_GLCODELIST L
       WHERE L.ENTITY_NUM = 1
         AND L.GLCODE = idx.glcode;
    
      pipe row(w_gldata);
    END LOOP;
  
  end fn_get_branch_glcode;

  function fn_glcode(p_branch in varchar2) return v_gl_record
    pipelined is
    w_gldata gl_record;
  begin
    for idx in (select *
                  from as_glcodelist g
                 where g.TRAN_YN = 'Y'
                   and length(g.glcode) < 10) loop
      w_gldata.gl_group := substr(idx.glcode, 1, 3) || '000000';
      select l.glname
        into w_gldata.hl_grp_name
        from glcodelist l
       where l.glcode = substr(idx.glcode, 1, 3) || '000000';
      w_gldata.sub_gl  := idx.sub_gl;
      w_gldata.glcode  := idx.glcode;
      w_gldata.tran_gl := idx.tran_yn;
      w_gldata.glname  := idx.glname;
      pipe row(w_gldata);
    
    end loop;
  
    /*for idx in (select *
                  from as_glcodelist g
                 where G.TRAN_YN='Y'
                   and g.glcode like p_branch || '%') loop
      w_gldata.gl_group := substr(idx.glcode, 1, 3) || '000000';
      select l.glname
        into w_gldata.hl_grp_name
        from glcodelist l
       where l.glcode = substr(idx.glcode, 1, 3) || '000000';
      w_gldata.sub_gl  := idx.sub_gl;
      w_gldata.glcode  := idx.glcode;
      w_gldata.tran_gl := idx.tran_yn;
      w_gldata.glname  := idx.glname;
      pipe row(w_gldata);
    
    end loop;*/
  
  end fn_glcode;
  
  function fn_misc_data(p_branch in varchar2) return v_gl_record
    pipelined is
    w_gldata gl_record;
  begin
    for idx in (select *
  from as_glcodelist g
 where g.TRAN_YN = 'Y'
   and g.glcode like '110201%'
union

select *
  from as_glcodelist g
 where g.TRAN_YN = 'Y'
   and g.glcode like '110100%'
   union
   select *
  from as_glcodelist g
 where g.TRAN_YN = 'Y'
   and g.glcode like '110101%') loop
      w_gldata.gl_group := substr(idx.glcode, 1, 3) || '000000';
      select l.glname
        into w_gldata.hl_grp_name
        from glcodelist l
       where l.glcode = substr(idx.glcode, 1, 3) || '000000';
      w_gldata.sub_gl  := idx.sub_gl;
      w_gldata.glcode  := idx.glcode;
      w_gldata.tran_gl := idx.tran_yn;
      w_gldata.glname  := idx.glname;
      pipe row(w_gldata);
    
    end loop;

  
  end fn_misc_data;
  
  procedure sp_branch_ledger_serial_setup(p_branch in varchar2,
                                          p_error  out varchar2) is
    v_exist number(6) := 0;
  begin
  
    select count(*)
      into v_exist
      from as_subgl_sl t
     where t.branch_code = p_branch
       and t.gl_code in
           (select g.glcode from as_glcodelist g where g.slot_yn = 'Y')
       and t.sl_no <> 0;
  
    if v_exist = 0 then
      delete from as_subgl_sl b where b.branch_code = p_branch;
      for id in (select * from as_glcodelist g where g.slot_yn = 'Y') loop
        insert into as_subgl_sl
          (enitiy_num, branch_code, gl_code, sl_no)
        values
          (1, p_branch, id.glcode, 0);
      end loop;
    else
      p_error := 'Branch Ledger Serial Opening Already Done for :' ||
                 p_branch;
    end if;
  end sp_branch_ledger_serial_setup;

  procedure sp_branch_zero_balance_setup(p_branch in varchar2,
                                         p_error  out varchar2) is
    v_exist number := 0;
  begin
    select count(*)
      into v_exist
      from as_glbalance_hist a
     where a.entity_num = 1
       and a.branch = p_branch
       and a.fin_year = '2019-2020'
       and a.cur_bal <> 0;
  
    if v_exist = 0 then
      delete from as_glbalance_hist a
       where a.entity_num = 1
         and a.branch = p_branch
         and a.fin_year = '2019-2020';
    
      for idx in (select * from as_glcodelist b where length(b.glcode) < 10) loop
        insert into as_glbalance_hist
          (entity_num, branch, fin_year, glcode, init_bal, cur_bal)
        values
          (1, p_branch, '2019-2020', idx.glcode, 0, 0);
      end loop;
    
      for idx in (select *
                    from as_glcodelist b
                   where length(b.glcode) > 10
                     and b.glcode like p_branch || '%') loop
        insert into as_glbalance_hist
          (entity_num, branch, fin_year, glcode, init_bal, cur_bal)
        values
          (1, p_branch, '2019-2020', idx.glcode, 0, 0);
      end loop;
    
    else
      p_error := 'Zero Balance can not be Updated : Balance Already Posted';
    end if;
  exception
    when others then
      p_error := 'Error in Zero Balance Setup ' || p_branch || ' : ' ||
                 sqlerrm;
  end sp_branch_zero_balance_setup;

  procedure sp_branch_balance_init(p_branch   in varchar2,
                                   p_fin_year in varchar2,
                                   p_error    out varchar2) is
    v_exist       number(6) := 0;
    v_new_finyear varchar2(15) := '2020-2021';
  begin
  
    select count(*)
      into v_exist
      from as_transaction t
     where t.branch = p_branch
       and t.glcode in
           (select b.glcode from as_glbalance b where b.branch = p_branch);
  
    if v_exist = 0 then
      delete from as_glbalance a
       where a.entity_num = 1
         and a.branch = p_branch;
      for id in (select *
                   from as_glbalance_hist b
                  where b.entity_num = 1
                    and b.branch = p_branch
                    and b.fin_year = p_fin_year) loop
      
        insert into as_glbalance
          (entity_num, fin_year, branch, glcode, init_bal, cur_bal)
        values
          (id.entity_num,
           v_new_finyear,
           id.branch,
           id.glcode,
           id.cur_bal,
           id.cur_bal);
      end loop;
    else
      p_error := 'Transaction Already Made for Fin Year: ' || p_fin_year ||
                 ' and Branch Code: ' || p_branch;
    end if;
  end sp_branch_balance_init;
  procedure sp_application_log(p_RequestType  varchar2,
                               p_DataObject   varchar2,
                               p_ErrorMessage    in varchar2,
                               p_Error_code in varchar2) is
  begin
    insert into applicationlog
      (logid,
       processtime,
       requesttype,
       data_object,
       errorcode,
       errormessage)
    values
      (applogId.Nextval,
       sysdate,
       p_RequestType,
       p_DataObject,
       1,
       p_ErrorMessage);
  end sp_application_log;
begin
  null;
end pkg_param;
/
