create or replace package pkg_gas_report is

  type branchIErecord is record(
    HEARDER_LINE varchar2(200),
    FIN_YEAR     varchar2(10),
    BRANCH       varchar2(50),
    BRANCH_NAME  varchar2(80),
    GLCODE       varchar2(14),
    GLNAME       varchar2(100),
    CUR_BAL      number(18, 2));
  type V_branchIErecord is table of branchIErecord;
  function fn_branchwise_getIncome_Exp(p_finyear  in varchar2,
                                       p_glprefix in varchar2)
    return V_branchIErecord
    pipelined;
  type tbalance is record(
    adjustment varchar2(100),
    branch     varchar2(10),
    gl_code    varchar2(15),
    dr_amount  number(18, 2),
    cr_amount  number(18, 2),
    fin_year   varchar2(20));
  type V_tbalance is table of tbalance;
  type pl_data is record(
    branch      varchar2(10),
    branch_name varchar2(80),
    gl_group    varchar2(20),
    fin_year    varchar2(40),
    serial      varchar2(20),
    glcode      varchar2(15),
    glname      char(150),
    balance     number(18, 2),
    sub_gl      char(1));
  type v_pl_data is table of pl_data;

  type glregister is record(
    branch    varchar2(10),
    gl_code   varchar2(15),
    TranHead  char(1),
    gl_group  varchar2(15),
    dr_amount number(18, 2),
    cr_amount number(18, 2),
    fin_year  varchar2(20),
    lvlcode0  varchar2(9),
    lvlcode1  varchar2(9),
    lvlcode2  varchar2(9),
    lvlcode3  varchar2(9),
    lvlcode4  varchar2(9),
    lvlcode5  varchar2(9));
  type v_glregister is table of glregister;

  type IncomeRecord is record(
    gl_code    varchar2(15),
    HO_income  number(18, 2),
    ECS_income number(18, 2),
    BR_income1 number(18, 2),
    BR_income2 number(18, 2),
    fin_year   varchar2(20));
  type v_IncomeRecord is table of IncomeRecord;
  function fn_get_income(p_finyear in varchar2) return v_IncomeRecord
    pipelined;
  type ExpenditureRecord is record(
    gl_code         varchar2(15),
    HO_Expenditure  number(18, 2),
    ECS_Expenditure number(18, 2),
    ZO_Expenditure  number(18, 2),
    RO_Expenditure  number(18, 2),
    BR_Expenditure1 number(18, 2),
    BR_Expenditure2 number(18, 2),
    fin_year        varchar2(20));
  type v_ExpenditiureRecord is table of ExpenditureRecord;
  function fn_get_expenditure(p_finyear in varchar2)
    return v_ExpenditiureRecord
    pipelined;
  type CapitalExpenditureRecord is record(
    gl_code         varchar2(15),
    HO_Expenditure  number(18, 2),
    ECS_Expenditure number(18, 2),
    BR_Expenditure  number(18, 2),
    fin_year        varchar2(20));
  type v_CapitalExpenditureRecord is table of CapitalExpenditureRecord;

  type InterOfficeMatrix is record(
    branch_code   varchar2(10),
    Branch_name   varchar2(100),
    br_bal_dr_cr  varchar2(4),
    branch_bal    number(18, 2),
    gl_code       varchar2(15),
    gl_name       varchar2(120),
    own_dr_cr     varchar2(4),
    Own_balance   number(18, 2),
    oth_dr_cr     varchar2(4),
    Othes_balance number(18, 2),
    diff_dr_cr    varchar2(4),
    Bal_diff      number(18, 2),
    Color_flag    varchar2(1));
  type v_InterOfficeMatrix is table of InterOfficeMatrix;

  function get_branch_matrix(p_branch_code in varchar2,
                             p_finYear     in varchar2)
    return v_InterOfficeMatrix
    pipelined;

  function fn_get_ledger_report(p_branch_code in varchar2,
                                p_gl_code     in varchar2,
                                p_fin_year    in varchar2,
                                p_tb_type     in varchar2)
    return v_glregister
    pipelined;
  function fn_Profit_Loss_stmt(p_branch in varchar2) return v_pl_data
    pipelined;
  function fn_get_trail_balance(p_branch_code in varchar2,
                                p_fin_year    in varchar2,
                                p_tb_type     in varchar2) return V_tbalance
    pipelined;
  function fn_get_tb_consolidated(p_branch_code in varchar2,
                                  p_finyear     in varchar2)
    return V_tbalance
    pipelined;
  function fn_get_capital_expenditure(p_finyear in varchar2)
    return v_CapitalExpenditureRecord
    pipelined;

  type balancesheet is record(
    adjustment          varchar2(100),
    Group_type          varchar2(5),
    GROUP_CODE          as_balancesheetFormat.Group_Code%type,
    PARTICULAR_CODE     as_balancesheetFormat.Particular_Code%type,
    PARTICULAR_NAME     as_balancesheetFormat.Particular_Name%type,
    PAR_PARTICULAR_CODE as_balancesheetFormat.Parent_Particular_Code%type,
    VISIBILITY          as_balancesheetFormat.VISIBILITY%type,
    CalculationType     as_balancesheetformat.calculation%type,
    Balance             number(18, 2),
    Sum_Balance         number(18, 2),
    Obsi_name           as_balancesheetFormat.Particular_Name%type,
    Obsi_Balance        number(18, 2));
  type v_balancesheet is table of balancesheet;

  function fn_get_balancesheet(p_branch_code in varchar2,
                               p_fin_year    in varchar2)
    return v_balancesheet
    pipelined;
  function fn_get_balancesheet_final(p_branch_code     in varchar2,
                                     p_fin_year        in varchar2,
                                     p_adjustment_type in varchar2)
    return v_balancesheet
    pipelined;
  function fn_get_tb_consolidated_final(p_adjustment_type in varchar2,
                                        p_finyear         in varchar2)
    return V_tbalance
    pipelined;
  function fn_Consolidated_bs_final(p_fin_year        in varchar2,
                                    p_adjustment_type in varchar2)
    return v_balancesheet
    pipelined;
   function fn_Consolidated_bs(p_fin_year in varchar2) return v_balancesheet
    pipelined;   
end pkg_gas_report;
/
create or replace package body pkg_gas_report is

  function get_branch_matrix(p_branch_code in varchar2,
                             p_finYear     in varchar2)
    return v_InterOfficeMatrix
    pipelined is
    v_glcode            varchar2(15) := '';
    v_balance           number := 0;
    v_br_balance        number(18, 2) := 0;
    w_InterOfficeMatrix InterOfficeMatrix;
  begin
  
    for index1 in (SELECT *
                     FROM prms_mbranch m
                    where m.bran_cat_code in ('B', 'H', 'E')
                      and m.brn_code like p_branch_code
                    order by m.brn_code) loop
      SELECT b.cur_bal
        into v_br_balance
        FROM as_glbalance b
        join as_glcodelist l
          on (b.glcode = l.glcode)
       where b.branch = index1.brn_code
         and b.glcode = '210000000';
    
      if v_br_balance >= 0 then
        w_InterOfficeMatrix.br_bal_dr_cr := 'Cr.';
        w_InterOfficeMatrix.branch_bal   := v_br_balance;
      else
        w_InterOfficeMatrix.br_bal_dr_cr := 'Dr.';
        w_InterOfficeMatrix.branch_bal   := -1 * v_br_balance;
      end if;
    
      SELECT m.brn_name
        into w_InterOfficeMatrix.Branch_name
        FROM prms_mbranch m
       where m.brn_code = index1.brn_code;
      w_InterOfficeMatrix.branch_code := index1.brn_code;
    
      for idx in (SELECT b.glcode, b.cur_bal, b.branch, l.glname
                    FROM as_glbalance b
                    join as_glcodelist l
                      on (b.glcode = l.glcode)
                   where b.branch = index1.brn_code
                     and b.glcode like '210%'
                     and b.cur_bal <> 0
                     and l.tran_yn = 'Y') loop
      
        w_InterOfficeMatrix.gl_code := idx.glcode;
        w_InterOfficeMatrix.gl_name := idx.glname;
        if idx.cur_bal >= 0 then
          w_InterOfficeMatrix.own_dr_cr   := 'Cr.';
          w_InterOfficeMatrix.Own_balance := idx.cur_bal;
        else
          w_InterOfficeMatrix.own_dr_cr   := 'Dr.';
          w_InterOfficeMatrix.Own_balance := -1 * idx.cur_bal;
        end if;
      
        SELECT m.glcode
          into v_glcode
          FROM as_br_gl_mapping m
         where m.branch_code = idx.branch;
      
        for in1 in (SELECT m.branch_code
                      FROM as_br_gl_mapping m
                     where m.glcode = idx.glcode) loop
        
          SELECT nvl(b.cur_bal, 0)
            into v_balance
            FROM as_glbalance b
           where b.branch = in1.branch_code
             and b.glcode = v_glcode;
        
          if v_balance >= 0 then
            w_InterOfficeMatrix.oth_dr_cr     := 'Cr.';
            w_InterOfficeMatrix.Othes_balance := v_balance;
          else
            w_InterOfficeMatrix.oth_dr_cr     := 'Dr.';
            w_InterOfficeMatrix.Othes_balance := -1 * v_balance;
          end if;
        
          if v_balance + idx.cur_bal >= 0 then
            w_InterOfficeMatrix.diff_dr_cr := 'Cr.';
            w_InterOfficeMatrix.Bal_diff   := (v_balance + idx.cur_bal);
          else
            w_InterOfficeMatrix.diff_dr_cr := 'Dr.';
            w_InterOfficeMatrix.Bal_diff   := -1 *
                                              (v_balance + idx.cur_bal);
          end if;
        
          if (v_balance + idx.cur_bal) <> 0 then
            w_InterOfficeMatrix.Color_flag := 'R';
          else
            w_InterOfficeMatrix.Color_flag := 'N';
          end if;
          -- dbms_output.put_line(index1.brn_code);
          pipe row(w_InterOfficeMatrix);
          -- dbms_output.put_line(index1.brn_code);
        end loop;
      end loop;
    end loop;
  end get_branch_matrix;

  function fn_Profit_Loss_stmt(p_branch in varchar2) return v_pl_data
    pipelined is
    w_pl_data pl_data;
  begin
    for idx in (SELECT * FROM prms_mbranch m where m.brn_code like p_branch) loop
      for id in (SELECT *
                   FROM (SELECT substr(b.glcode, 1, 3) glgroup,
                                '(A)' serial,
                                b.glcode,
                                b.cur_bal,
                                l.sub_gl,
                                b.fin_year
                           FROM as_glbalance b
                           join as_glcodelist l
                             on (b.glcode = l.glcode)
                          where b.branch = idx.brn_code
                            and l.tb_yn = 'Y'
                            and l.inc_exp = 'I'
                            and b.cur_bal <> 0
                         union
                         SELECT substr(b.glcode, 1, 3) glgroup,
                                '(B)' serial,
                                b.glcode,
                                b.cur_bal,
                                l.sub_gl,
                                b.fin_year
                           FROM as_glbalance b
                           join as_glcodelist l
                             on (b.glcode = l.glcode)
                          where b.branch = idx.brn_code
                            and l.tb_yn = 'Y'
                            and l.inc_exp = 'E'
                            and b.cur_bal <> 0
                         
                         union
                         
                         SELECT '999' glgroup,
                                '(C=A-B)' serial,
                                'Total',
                                sum(b.cur_bal),
                                '0' sub_gl,
                                b.fin_year
                           FROM as_glbalance b
                           join as_glcodelist l
                             on (b.glcode = l.glcode)
                          where b.branch = idx.brn_code
                            and l.tb_yn = 'Y'
                            and l.inc_exp in ('I', 'E')
                            and b.cur_bal <> 0
                          group by b.fin_year
                         
                         union
                         
                         SELECT substr(b.glcode, 1, 3) glgroup,
                                '' Serial,
                                b.glcode,
                                b.cur_bal,
                                l.sub_gl,
                                b.fin_year
                           FROM as_glbalance b
                           join as_glcodelist l
                             on (b.glcode = l.glcode)
                          where b.branch = idx.brn_code
                            and l.tran_yn = 'Y'
                            and l.inc_exp = 'I'
                            and b.cur_bal <> 0
                         
                         union
                         SELECT substr(b.glcode, 1, 3) glgroup,
                                '' Serial,
                                b.glcode,
                                b.cur_bal,
                                l.sub_gl,
                                b.fin_year
                           FROM as_glbalance b
                           join as_glcodelist l
                             on (b.glcode = l.glcode)
                          where b.branch = idx.brn_code
                            and l.tran_yn = 'Y'
                            and l.inc_exp = 'E'
                            and b.cur_bal <> 0
                         
                         )
                  order by glcode) loop
        w_pl_data.gl_group    := id.glgroup;
        w_pl_data.serial      := id.serial;
        w_pl_data.glcode      := id.glcode;
        w_pl_data.fin_year    := 'FInancial Year: ' || id.fin_year;
        w_pl_data.branch      := idx.brn_code;
        w_pl_data.branch_name := idx.brn_name;
        if id.cur_bal < 0 then
          w_pl_data.balance := -1 * id.cur_bal;
        else
          w_pl_data.balance := id.cur_bal;
        end if;
      
        begin
          SELECT l.glname
            into w_pl_data.glname
            FROM as_glcodelist l
           where l.glcode = id.glcode;
        exception
          when others then
            w_pl_data.glname := 'Profit & Loss';
        end;
      
        w_pl_data.sub_gl := id.sub_gl;
        pipe row(w_pl_data);
      end loop;
    end loop;
  end fn_Profit_Loss_stmt;

  function fn_get_trail_balance(p_branch_code in varchar2,
                                p_fin_year    in varchar2,
                                p_tb_type     in varchar2) return V_tbalance
    pipelined is
  
    w_tbalance tbalance;
  
  begin
    if p_tb_type = 'B' then
      w_tbalance.adjustment := 'Before Adjustment';
    else
      w_tbalance.adjustment := 'After Adjustment';
    end if;
  
    for in1 in (SELECT b.*
                  FROM AS_Final_GLBALANCE b, as_glcodelist l
                 where b.glcode = l.glcode
                   and l.tb_yn = 'Y'
                   and b.cur_bal <> 0
                   and b.fin_year = p_fin_year
                   and b.tb_type = p_tb_type
                   and b.branch = p_branch_code) loop
      w_tbalance.branch   := in1.branch;
      w_tbalance.gl_code  := in1.glcode;
      w_tbalance.fin_year := p_fin_year;
      if in1.cur_bal >= 0 then
        w_tbalance.cr_amount := in1.cur_bal;
        w_tbalance.dr_amount := 0;
      else
        w_tbalance.cr_amount := 0;
        w_tbalance.dr_amount := -1 * in1.cur_bal;
      end if;
    
      pipe row(w_tbalance);
    end loop;
  end fn_get_trail_balance;
  function fn_get_ledger_report(p_branch_code in varchar2,
                                p_gl_code     in varchar2,
                                p_fin_year    in varchar2,
                                p_tb_type     in varchar2)
    return v_glregister
    pipelined is
    w_glregister glregister;
    v_lvl1       number := 0;
    v_lvl2       number := 0;
    v_lvl3       number := 0;
    v_lvl4       number := 0;
    v_lvl5       number := 0;
  begin
    for in1 in (SELECT b.glcode,
                       l.glname,
                       b.cur_bal,
                       L.TRAN_YN,
                       l.lvlcode5,
                       l.lvlcode4,
                       l.lvlcode3,
                       l.lvlcode2,
                       l.lvlcode1,
                       l.mainhead
                  FROM AS_Final_GLBALANCE b
                  join as_glcodelist l
                    on (b.glcode = l.glcode)
                 where b.branch = p_branch_code
                   and b.glcode = p_gl_code
                   and b.fin_year = p_fin_year
                   and b.tb_type = p_tb_type
                   and b.cur_bal <> 0) loop
      w_glregister.gl_code  := in1.glcode;
      w_glregister.TranHead := '0';
      w_glregister.fin_year := p_fin_year;
      w_glregister.lvlcode0 := p_gl_code;
      w_glregister.lvlcode1 := in1.lvlcode1;
      w_glregister.lvlcode2 := in1.lvlcode2;
      w_glregister.lvlcode3 := in1.lvlcode3;
      w_glregister.lvlcode4 := in1.lvlcode4;
      w_glregister.lvlcode5 := in1.lvlcode5;
    
      if in1.cur_bal >= 0 then
        w_glregister.cr_amount := in1.cur_bal;
        w_glregister.dr_amount := 0;
      else
        w_glregister.cr_amount := 0;
        w_glregister.dr_amount := -1 * in1.cur_bal;
      end if;
      pipe row(w_glregister);
    end loop;
  
    if p_gl_code = '172000000' or p_gl_code = '173000000' or
       p_gl_code = '171000000' then
      for in1 in (SELECT b.glcode,
                         l.glname,
                         b.cur_bal,
                         l.tran_yn,
                         l.lvlcode5,
                         l.lvlcode4,
                         l.lvlcode3,
                         l.lvlcode2,
                         l.lvlcode1,
                         l.mainhead
                    FROM AS_Final_GLBALANCE b
                    join as_glcodelist l
                      on (b.glcode = l.glcode)
                   where b.branch = p_branch_code
                     and l.lvlcode1 = p_gl_code
                     and b.fin_year = p_fin_year
                     and b.tb_type = p_tb_type
                     and l.tran_yn = 'Y'
                     and b.cur_bal <> 0) loop
        w_glregister.gl_code  := in1.glcode;
        w_glregister.fin_year := p_fin_year;
        w_glregister.lvlcode0 := in1.mainhead;
        w_glregister.lvlcode1 := in1.lvlcode1;
        w_glregister.lvlcode2 := in1.lvlcode2;
        w_glregister.lvlcode3 := in1.lvlcode3;
        w_glregister.lvlcode4 := in1.lvlcode4;
        w_glregister.lvlcode5 := in1.lvlcode5;
      
        if in1.tran_yn = 'Y' then
          w_glregister.tranhead := '6';
        else
        
          SELECT count(*)
            into v_lvl1
            FROM as_glcodelist l
           where l.lvlcode1 = in1.glcode;
          if v_lvl1 > 0 then
            w_glregister.tranhead := '1';
          else
            SELECT count(*)
              into v_lvl2
              FROM as_glcodelist l
             where l.lvlcode2 = in1.glcode;
          
            if v_lvl2 > 0 then
              w_glregister.tranhead := '2';
            else
              SELECT count(*)
                into v_lvl3
                FROM as_glcodelist l
               where l.lvlcode3 = in1.glcode;
            
              if v_lvl3 > 0 then
                w_glregister.tranhead := '3';
              else
                SELECT count(*)
                  into v_lvl4
                  FROM as_glcodelist l
                 where l.lvlcode4 = in1.glcode;
                if v_lvl4 > 0 then
                  w_glregister.tranhead := '4';
                else
                  w_glregister.tranhead := '5';
                end if;
              
              end if;
            
            end if;
          
          end if;
        
        end if;
      
        if in1.cur_bal >= 0 then
          w_glregister.cr_amount := in1.cur_bal;
          w_glregister.dr_amount := 0;
        else
          w_glregister.cr_amount := 0;
          w_glregister.dr_amount := -1 * in1.cur_bal;
        end if;
        pipe row(w_glregister);
      end loop;
    else
      for in1 in (SELECT b.glcode,
                         l.glname,
                         b.cur_bal,
                         l.tran_yn,
                         l.lvlcode5,
                         l.lvlcode4,
                         l.lvlcode3,
                         l.lvlcode2,
                         l.lvlcode1,
                         l.mainhead
                  
                    FROM AS_Final_GLBALANCE b
                    join as_glcodelist l
                      on (b.glcode = l.glcode)
                   where b.branch = p_branch_code
                     and l.mainhead = p_gl_code
                     and b.fin_year = p_fin_year
                     and b.tb_type = p_tb_type
                     and l.tran_yn = 'Y'
                     and b.cur_bal <> 0) loop
        w_glregister.gl_code  := in1.glcode;
        w_glregister.fin_year := p_fin_year;
        w_glregister.lvlcode0 := in1.mainhead;
        w_glregister.lvlcode1 := in1.lvlcode1;
        w_glregister.lvlcode2 := in1.lvlcode2;
        w_glregister.lvlcode3 := in1.lvlcode3;
        w_glregister.lvlcode4 := in1.lvlcode4;
        w_glregister.lvlcode5 := in1.lvlcode5;
      
        if in1.tran_yn = 'Y' then
          w_glregister.tranhead := '6';
        else
        
          SELECT count(*)
            into v_lvl1
            FROM as_glcodelist l
           where l.lvlcode1 = in1.glcode;
          if v_lvl1 > 0 then
            w_glregister.tranhead := '1';
          else
            SELECT count(*)
              into v_lvl2
              FROM as_glcodelist l
             where l.lvlcode2 = in1.glcode;
          
            if v_lvl2 > 0 then
              w_glregister.tranhead := '2';
            else
              SELECT count(*)
                into v_lvl3
                FROM as_glcodelist l
               where l.lvlcode3 = in1.glcode;
            
              if v_lvl3 > 0 then
                w_glregister.tranhead := '3';
              else
                SELECT count(*)
                  into v_lvl4
                  FROM as_glcodelist l
                 where l.lvlcode4 = in1.glcode;
                if v_lvl4 > 0 then
                  w_glregister.tranhead := '4';
                else
                  w_glregister.tranhead := '5';
                end if;
              
              end if;
            
            end if;
          
          end if;
        
        end if;
      
        if in1.cur_bal >= 0 then
          w_glregister.cr_amount := in1.cur_bal;
          w_glregister.dr_amount := 0;
        else
          w_glregister.cr_amount := 0;
          w_glregister.dr_amount := -1 * in1.cur_bal;
        end if;
        pipe row(w_glregister);
      end loop;
    end if;
  
  end fn_get_ledger_report;
  function fn_get_tb_consolidated_final(p_adjustment_type in varchar2,
                                        p_finyear         in varchar2)
    return V_tbalance
    pipelined is
  
    w_tbalance tbalance;
  begin
  
    if p_adjustment_type = 'B' then
      w_tbalance.adjustment := 'Before Adjustment';
    else
      w_tbalance.adjustment := 'After Adjustment';
    end if;
    for in1 in (SELECT b.glcode, b.fin_year, sum(b.cur_bal) cur_bal
                  FROM as_final_glbalance b, as_glcodelist l
                 where b.glcode = l.glcode
                   and l.tb_yn = 'Y'
                   and b.tb_type = p_adjustment_type
                   and b.fin_year = p_finyear
                 group by b.glcode, b.fin_year) loop
      w_tbalance.gl_code  := in1.glcode;
      w_tbalance.fin_year := in1.fin_year;
      if in1.cur_bal >= 0 then
        w_tbalance.cr_amount := in1.cur_bal;
        w_tbalance.dr_amount := 0;
      else
        w_tbalance.cr_amount := 0;
        w_tbalance.dr_amount := -1 * in1.cur_bal;
      end if;
    
      pipe row(w_tbalance);
    end loop;
  
  end fn_get_tb_consolidated_final;

  function fn_get_tb_consolidated(p_branch_code in varchar2,
                                  p_finyear     in varchar2)
    return V_tbalance
    pipelined is
  
    w_tbalance tbalance;
  begin
  
    for in1 in (SELECT b.*
                  FROM as_glbalance b, as_glcodelist l
                 where b.glcode = l.glcode
                   and l.tb_yn = 'Y'
                      
                   and b.fin_year = p_finyear) loop
      w_tbalance.branch   := in1.branch;
      w_tbalance.gl_code  := in1.glcode;
      w_tbalance.fin_year := in1.fin_year;
      if in1.cur_bal >= 0 then
        w_tbalance.cr_amount := in1.cur_bal;
        w_tbalance.dr_amount := 0;
      else
        w_tbalance.cr_amount := 0;
        w_tbalance.dr_amount := -1 * in1.cur_bal;
      end if;
    
      pipe row(w_tbalance);
    end loop;
  
  end fn_get_tb_consolidated;

  function fn_get_income(p_finyear in varchar2) return v_IncomeRecord
    pipelined is
    w_IncomeRecord IncomeRecord;
    v_act_type     varchar2(10) := '';
  begin
  
    SELECT f.activatation
      into v_act_type
      FROM as_finyear f
     where f.entity_num = 1
       and f.fin_year = p_finyear;
  
    for idx in (SELECT *
                  FROM as_glcodelist l
                 where l.mainhead = '160000000'
                   and l.tran_yn = 'Y') loop
      w_IncomeRecord.gl_code  := idx.glcode;
      w_IncomeRecord.fin_year := p_finyear;
      if v_act_type = 'Y' then
        SELECT sum(b.cur_bal)
          into w_IncomeRecord.HO_income
          FROM as_glbalance b
         where b.glcode = idx.glcode
           and b.branch in (SELECT m.brn_code
                              FROM prms_mbranch m
                             where m.bran_cat_code = 'H');
      
        SELECT sum(b.cur_bal)
          into w_IncomeRecord.ECS_income
          FROM as_glbalance b
         where b.glcode = idx.glcode
           and b.branch in (SELECT m.brn_code
                              FROM prms_mbranch m
                             where m.bran_cat_code = 'E');
      
        SELECT sum(nvl(b.cur_bal,0))
          into w_IncomeRecord.BR_income1
          FROM as_glbalance b
         where b.glcode = idx.glcode
           and b.branch in (SELECT m.brn_code
                              FROM prms_mbranch m
                             where m.bran_cat_code = 'B');
      
        SELECT nvl(sum(b.cur_bal),0)
          into w_IncomeRecord.BR_income2
          FROM as_glbalance b
         where b.glcode = '161' || substr(idx.glcode, 4, 6);
      
      else
        SELECT sum(b.cur_bal)
          into w_IncomeRecord.HO_income
          FROM as_final_glbalance b
         where b.glcode = idx.glcode
           and b.fin_year = p_finyear
           and b.tb_type = 'B'
           and b.branch in (SELECT m.brn_code
                              FROM prms_mbranch m
                             where m.bran_cat_code = 'H');
      
        SELECT sum(b.cur_bal)
          into w_IncomeRecord.ECS_income
          FROM as_final_glbalance b
         where b.glcode = idx.glcode
           and b.fin_year = p_finyear
           and b.tb_type = 'B'
           and b.branch in (SELECT m.brn_code
                              FROM prms_mbranch m
                             where m.bran_cat_code = 'E');
      
        SELECT nvl(sum(b.cur_bal),0)
          into w_IncomeRecord.BR_income1
          FROM as_final_glbalance b
         where b.glcode = idx.glcode
           and b.fin_year = p_finyear
           and b.tb_type = 'B'
           and b.branch in (SELECT m.brn_code
                              FROM prms_mbranch m
                             where m.bran_cat_code = 'B');
      
        SELECT nvl(sum(b.cur_bal),0)
          into w_IncomeRecord.BR_income2
          FROM as_final_glbalance b
         where b.glcode = '161' || substr(idx.glcode, 4, 6)
           and b.fin_year = p_finyear
           and b.tb_type = 'B'
           and b.branch in (SELECT m.brn_code
                              FROM prms_mbranch m
                             where m.bran_cat_code = 'B');
      end if;
      pipe row(w_IncomeRecord);
    end loop;
  
  end fn_get_income;
  function fn_get_expenditure(p_finyear in varchar2)
    return v_ExpenditiureRecord
    pipelined is
    w_ExpenditiureRecord ExpenditureRecord;
    v_act_type           varchar2(10) := '';
  begin
  
    SELECT f.activatation
      into v_act_type
      FROM as_finyear f
     where f.entity_num = 1
       and f.fin_year = p_finyear;
    w_ExpenditiureRecord.fin_year := p_finyear;
    for idx in (SELECT *
                  FROM as_glcodelist l
                 where l.lvlcode1 = '171000000'
                   and l.tran_yn = 'Y') loop
    
      w_ExpenditiureRecord.gl_code := idx.glcode;
    
      if v_act_type = 'Y' then
      
        SELECT sum(-1 * b.cur_bal)
          into w_ExpenditiureRecord.HO_Expenditure
          FROM as_glbalance b
         where b.glcode = idx.glcode
           and b.branch in (SELECT m.brn_code
                              FROM prms_mbranch m
                             where m.bran_cat_code = 'H');
      
        SELECT sum(-1 * b.cur_bal)
          into w_ExpenditiureRecord.ECS_Expenditure
          FROM as_glbalance b
         where b.glcode = idx.glcode
           and b.branch in (SELECT m.brn_code
                              FROM prms_mbranch m
                             where m.bran_cat_code = 'E');
        SELECT sum(-1 * b.cur_bal)
          into w_ExpenditiureRecord.BR_Expenditure1
          FROM as_glbalance b
         where b.glcode = idx.glcode
           and b.branch in (SELECT m.brn_code
                              FROM prms_mbranch m
                             where m.bran_cat_code = 'B');
      
        SELECT nvl(sum(-1 * b.cur_bal), 0)
          into w_ExpenditiureRecord.ZO_Expenditure
          FROM as_glbalance b
         where b.glcode = '172' || substr(idx.glcode, 4, 6);
      
        SELECT nvl(sum(-1 * b.cur_bal), 0)
          into w_ExpenditiureRecord.RO_Expenditure
          FROM as_glbalance b
         where b.glcode = '173' || substr(idx.glcode, 4, 6);
      
        SELECT sum(-1 * b.cur_bal)
          into w_ExpenditiureRecord.BR_Expenditure2
          FROM as_glbalance b
         where b.glcode = '174' || substr(idx.glcode, 4, 6);
      
      else
      
        SELECT sum(-1 * b.cur_bal)
          into w_ExpenditiureRecord.HO_Expenditure
          FROM as_final_glbalance b
         where b.glcode = idx.glcode
           and b.fin_year = p_finyear
           and b.tb_type = 'B'
           and b.branch in (SELECT m.brn_code
                              FROM prms_mbranch m
                             where m.bran_cat_code = 'H');
      
        SELECT sum(-1 * b.cur_bal)
          into w_ExpenditiureRecord.ECS_Expenditure
          FROM as_final_glbalance b
         where b.glcode = idx.glcode
           and b.fin_year = p_finyear
           and b.tb_type = 'B'
           and b.branch in (SELECT m.brn_code
                              FROM prms_mbranch m
                             where m.bran_cat_code = 'E');
        SELECT sum(-1 * b.cur_bal)
          into w_ExpenditiureRecord.BR_Expenditure1
          FROM as_final_glbalance b
         where b.glcode = idx.glcode
           and b.fin_year = p_finyear
           and b.tb_type = 'B'
           and b.branch in (SELECT m.brn_code
                              FROM prms_mbranch m
                             where m.bran_cat_code = 'B');
      
        SELECT nvl(sum(-1 * b.cur_bal), 0)
          into w_ExpenditiureRecord.ZO_Expenditure
          FROM as_final_glbalance b
         where b.glcode = '172' || substr(idx.glcode, 4, 6)
           and b.fin_year = p_finyear
           and b.tb_type = 'B';
      
        SELECT nvl(sum(-1 * b.cur_bal), 0)
          into w_ExpenditiureRecord.RO_Expenditure
          FROM as_final_glbalance b
         where b.glcode = '173' || substr(idx.glcode, 4, 6)
           and b.fin_year = p_finyear
           and b.tb_type = 'B';
      
        SELECT sum(-1 * b.cur_bal)
          into w_ExpenditiureRecord.BR_Expenditure2
          FROM as_final_glbalance b
         where b.glcode = '174' || substr(idx.glcode, 4, 6)
           and b.fin_year = p_finyear
           and b.tb_type = 'B';
      end if;
    
      pipe row(w_ExpenditiureRecord);
    end loop;
  end fn_get_expenditure;

  function fn_get_capital_expenditure(p_finyear in varchar2)
    return v_CapitalExpenditureRecord
    pipelined is
    w_CapitalExpenditureRecord CapitalExpenditureRecord;
    v_act_type                 varchar2(10) := '';
  begin
  
    SELECT f.activatation
      into v_act_type
      FROM as_finyear f
     where f.entity_num = 1
       and f.fin_year = p_finyear;
    w_CapitalExpenditureRecord.fin_year := p_finyear;
    for idx in (SELECT *
                  FROM as_glcodelist l
                 where l.mainhead = '140000000'
                   and l.tran_yn = 'Y') loop
    
      w_CapitalExpenditureRecord.gl_code := idx.glcode;
    
      if v_act_type = 'Y' then
      
        SELECT sum(-1 * b.cur_bal)
          into w_CapitalExpenditureRecord.HO_Expenditure
          FROM as_glbalance b
         where b.glcode = idx.glcode
           and b.branch in (SELECT m.brn_code
                              FROM prms_mbranch m
                             where m.bran_cat_code = 'H');
      
        SELECT sum(-1 * b.cur_bal)
          into w_CapitalExpenditureRecord.ECS_Expenditure
          FROM as_glbalance b
         where b.glcode = idx.glcode
           and b.branch in (SELECT m.brn_code
                              FROM prms_mbranch m
                             where m.bran_cat_code = 'E');
      
        SELECT sum(-1 * b.cur_bal)
          into w_CapitalExpenditureRecord.BR_Expenditure
          FROM as_glbalance b
         where b.glcode = idx.glcode
           and b.branch in (SELECT m.brn_code
                              FROM prms_mbranch m
                             where m.bran_cat_code = 'B');
      
      else
      
        SELECT sum(-1 * b.cur_bal)
          into w_CapitalExpenditureRecord.HO_Expenditure
          FROM as_final_glbalance b
         where b.glcode = idx.glcode
           and b.fin_year = p_finyear
           and b.tb_type = 'A'
           and b.branch in (SELECT m.brn_code
                              FROM prms_mbranch m
                             where m.bran_cat_code = 'H');
      
        SELECT sum(-1 * b.cur_bal)
          into w_CapitalExpenditureRecord.ECS_Expenditure
          FROM as_final_glbalance b
         where b.glcode = idx.glcode
           and b.fin_year = p_finyear
           and b.tb_type = 'A'
           and b.branch in (SELECT m.brn_code
                              FROM prms_mbranch m
                             where m.bran_cat_code = 'E');
      
        SELECT sum(-1 * b.cur_bal)
          into w_CapitalExpenditureRecord.BR_Expenditure
          FROM as_final_glbalance b
         where b.glcode = idx.glcode
           and b.fin_year = p_finyear
           and b.tb_type = 'A'
           and b.branch in (SELECT m.brn_code
                              FROM prms_mbranch m
                             where m.bran_cat_code = 'B');
      
      end if;
    
      pipe row(w_CapitalExpenditureRecord);
    end loop;
  end fn_get_capital_expenditure;

  function fn_branchwise_getIncome_Exp(p_finyear  in varchar2,
                                       p_glprefix in varchar2)
    return V_branchIErecord
    pipelined is
    w_branchIErecord branchIErecord;
    v_act_type       varchar2(10) := '';
  begin
  
    if p_glprefix = '160' then
      w_branchIErecord.HEARDER_LINE := 'Report on Branch Wise Income Statement';
    elsif p_glprefix = '171' then
      w_branchIErecord.HEARDER_LINE := 'Report on Branch Wise Expenditure Statement';
    end if;
  
    SELECT f.activatation
      into v_act_type
      FROM as_finyear f
     where f.entity_num = 1
       and f.fin_year = p_finyear;
    if v_act_type = 'Y' then
      for idx in (select b.fin_year,
                         b.branch,
                         (select m.brn_name
                            from prms_mbranch m
                           where m.brn_code = b.branch) branch_name,
                         b.glcode,
                         l.glname,
                         b.cur_bal
                    from as_glbalance b
                    join as_glcodelist l
                      on (b.glcode = l.glcode)
                   where b.cur_bal <> 0
                     and l.tran_yn = 'Y'
                     and l.glcode like p_glprefix || '%'
                   order by b.branch, l.glcode) loop
        w_branchIErecord.FIN_YEAR    := p_finyear;
        w_branchIErecord.BRANCH      := idx.branch;
        w_branchIErecord.BRANCH_NAME := idx.branch_name;
        w_branchIErecord.GLCODE      := idx.glcode;
        w_branchIErecord.GLNAME      := idx.glname;
        w_branchIErecord.CUR_BAL     := idx.cur_bal;
        pipe row(w_branchIErecord);
      end loop;
    else
      for idx in (select b.fin_year,
                         b.branch,
                         (select m.brn_name
                            from prms_mbranch m
                           where m.brn_code = b.branch) branch_name,
                         b.glcode,
                         l.glname,
                         b.cur_bal
                    from as_final_glbalance b
                    join as_glcodelist l
                      on (b.glcode = l.glcode)
                   where b.cur_bal <> 0
                     and l.tran_yn = 'Y'
                     and b.fin_year = p_finyear
                     and b.tb_type = 'B'
                     and l.glcode like p_glprefix || '%'
                   order by b.branch, l.glcode) loop
        w_branchIErecord.FIN_YEAR    := p_finyear;
        w_branchIErecord.BRANCH      := idx.branch;
        w_branchIErecord.BRANCH_NAME := idx.branch_name;
        w_branchIErecord.GLCODE      := idx.glcode;
        w_branchIErecord.GLNAME      := idx.glname;
        w_branchIErecord.CUR_BAL     := idx.cur_bal;
        pipe row(w_branchIErecord);
      end loop;
    end if;
  
  end fn_branchwise_getIncome_Exp;

  function fn_get_balancesheet(p_branch_code in varchar2,
                               p_fin_year    in varchar2)
    return v_balancesheet
    pipelined is
    w_balancesheet                 balancesheet;
    V_balance                      number(18, 2) := 0;
    v_Classified_balance           number(18, 2) := 0;
    V_abandon_Property_balance     number(18, 2) := 0;
    V_offbalancesheet_item_balance number(18, 2) := 0;
    V_loanAndAdvance_balance       number(18, 2) := 0;
  
  begin
  
    if p_branch_code not in ('9999', '9998') then
      select ((select nvl(sum(cum_prin_bal + cum_int_bal), 0)
                 from tmp_rpt_bal@olddb
                where fin_year = p_fin_year
                  and loc_code = p_branch_code
                  and ln_criteria <> 'UC') +
             (select nvl(sum(cum_prin_bal + cum_int_bal), 0)
                 from tmp_rpt_bal@emidb
                where fin_year = p_fin_year
                  and ln_criteria <> 'UC'
                  and loc_code = p_branch_code) +
             (select nvl(sum(cum_prin_bal + cum_int_bal), 0)
                 from tmp_rpt_bal@ocrdb
                where fin_year = p_fin_year
                  and ln_criteria <> 'UC'
                  and loc_code = p_branch_code) +
             (select nvl(sum(cum_prin_bal + cum_int_bal), 0)
                 from tmp_rpt_bal@isfdb
                where fin_year = p_fin_year
                  and ln_criteria <> 'UC'
                  and loc_code = p_branch_code) +
             (select nvl(sum(cum_prin_bal + cum_int_bal), 0)
                 from tmp_rpt_bal@govdb
                where fin_year = p_fin_year
                  and ln_criteria <> 'UC'
                  and loc_code = p_branch_code)) * -1 CL_balance
      
        into v_Classified_balance
        from dual;
    end if;
    select b.cur_bal
      into V_offbalancesheet_item_balance
      from as_glbalance b
     where b.branch = p_branch_code
       and b.glcode = '300000000';
    w_balancesheet.Obsi_name    := 'Off-Balance Sheet Item: Deferred Interest on Unclassified Loan';
    w_balancesheet.Obsi_Balance := V_offbalancesheet_item_balance;
    select b.cur_bal
      into V_loanAndAdvance_balance
      from as_glbalance b
     where b.branch = p_branch_code
       and b.glcode = '110000000';
  
    select b.cur_bal
      into V_abandon_Property_balance
      from as_glbalance b
     where b.branch = p_branch_code
       and b.glcode = '330000000';
  
    for idx in (select *
                  from as_balancesheetFormat x
                 where x.calculation = 'F') loop
    
      w_balancesheet.GROUP_CODE          := idx.group_code;
      w_balancesheet.PARTICULAR_CODE     := idx.particular_code;
      w_balancesheet.PARTICULAR_NAME     := idx.particular_name;
      w_balancesheet.PAR_PARTICULAR_CODE := idx.particular_code;
      w_balancesheet.VISIBILITY          := idx.visibility;
      w_balancesheet.CalculationType     := idx.calculation;
    
      if idx.particular_code = '10' then
        w_balancesheet.Balance     := V_loanAndAdvance_balance +
                                      V_abandon_Property_balance +
                                      V_offbalancesheet_item_balance;
        w_balancesheet.Sum_Balance := V_loanAndAdvance_balance +
                                      V_abandon_Property_balance +
                                      V_offbalancesheet_item_balance;
      elsif idx.particular_code = '11' then
        w_balancesheet.Balance     := (V_loanAndAdvance_balance +
                                      V_abandon_Property_balance -
                                      V_abandon_Property_balance -
                                      v_Classified_balance);
        w_balancesheet.Sum_Balance := 0;
      elsif idx.particular_code = '12' then
        w_balancesheet.Balance     := -1 * V_offbalancesheet_item_balance;
        w_balancesheet.Sum_Balance := 0;
      elsif idx.particular_code = '13' then
        w_balancesheet.Balance     := V_loanAndAdvance_balance +
                                      V_abandon_Property_balance -
                                      (v_Classified_balance +
                                      V_abandon_Property_balance) +
                                      V_offbalancesheet_item_balance;
        w_balancesheet.Sum_Balance := 0;
      elsif idx.particular_code = '14' then
        w_balancesheet.Balance     := (V_abandon_Property_balance +
                                      v_Classified_balance);
        w_balancesheet.Sum_Balance := 0;
      else
        w_balancesheet.Balance     := 0;
        w_balancesheet.Sum_Balance := 0;
      end if;
    
      if w_balancesheet.Balance < 0 then
        w_balancesheet.Group_type := 'A';
        if idx.group_code in ('H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P') then
          w_balancesheet.GROUP_CODE := 'F';
        end if;
      else
        if idx.group_code in ('A', 'B', 'C', 'D', 'E', 'F') then
          w_balancesheet.GROUP_CODE := 'P';
        end if;
        w_balancesheet.Group_type := 'L';
      end if;
    
      pipe row(w_balancesheet);
    end loop;
  
    for idx in (select *
                  from as_balancesheetFormat x
                 where x.calculation = 'K') loop
    
      w_balancesheet.GROUP_CODE          := idx.group_code;
      w_balancesheet.PARTICULAR_CODE     := idx.particular_code;
      w_balancesheet.PARTICULAR_NAME     := idx.particular_name;
      w_balancesheet.PAR_PARTICULAR_CODE := idx.particular_code;
      w_balancesheet.VISIBILITY          := idx.visibility;
      w_balancesheet.CalculationType     := idx.calculation;
      BEGIN
        select b.cur_bal, b.cur_bal
          into w_balancesheet.Balance, w_balancesheet.Sum_Balance
          from as_glbalance b
         where b.branch = p_branch_code
           and b.glcode = idx.gl_code;
      EXCEPTION
        WHEN OTHERS THEN
          w_balancesheet.Balance     := 0;
          w_balancesheet.Sum_Balance := 0;
      END;
    
      if w_balancesheet.Balance < 0 then
        w_balancesheet.Group_type := 'A';
        if idx.group_code in ('H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P') then
          w_balancesheet.GROUP_CODE := 'F';
        end if;
      else
        if idx.group_code in ('A', 'B', 'C', 'D', 'E', 'F') then
          w_balancesheet.GROUP_CODE := 'P';
        end if;
        w_balancesheet.Group_type := 'L';
      end if;
    
      pipe row(w_balancesheet);
    end loop;
  
    for idx in (select *
                  from as_balancesheetFormat x
                 where x.calculation = 'C') loop
    
      w_balancesheet.GROUP_CODE          := idx.group_code;
      w_balancesheet.PARTICULAR_CODE     := idx.particular_code;
      w_balancesheet.PARTICULAR_NAME     := idx.particular_name;
      w_balancesheet.PAR_PARTICULAR_CODE := idx.particular_code;
      w_balancesheet.VISIBILITY          := idx.visibility;
      w_balancesheet.CalculationType     := idx.calculation;
      BEGIN
        select nvl(sum(b.cur_bal), 0), nvl(sum(b.cur_bal), 0)
          into w_balancesheet.Balance, w_balancesheet.Sum_Balance
          from as_glbalance b
         where b.branch = p_branch_code
           and b.glcode in
               (select x.gl_code
                  from as_balancesheetFormat x
                 where x.sub_particular_code = idx.particular_code);
      EXCEPTION
        WHEN OTHERS THEN
          w_balancesheet.Balance     := 0;
          w_balancesheet.Sum_Balance := 0;
      END;
    
      if w_balancesheet.Balance < 0 then
        w_balancesheet.Group_type := 'A';
        if idx.group_code in ('H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P') then
          w_balancesheet.GROUP_CODE := 'F';
        end if;
      else
        if idx.group_code in ('A', 'B', 'C', 'D', 'E', 'F') then
          w_balancesheet.GROUP_CODE := 'P';
        end if;
        w_balancesheet.Group_type := 'L';
      end if;
    
      pipe row(w_balancesheet);
    end loop;
  
    for idx in (select *
                  from as_balancesheetFormat x
                 where x.calculation = 'V') loop
    
      w_balancesheet.GROUP_CODE          := idx.group_code;
      w_balancesheet.PARTICULAR_CODE     := idx.particular_code;
      w_balancesheet.PARTICULAR_NAME     := idx.particular_name;
      w_balancesheet.PAR_PARTICULAR_CODE := idx.particular_code;
      w_balancesheet.VISIBILITY          := idx.visibility;
      w_balancesheet.CalculationType     := idx.calculation;
      BEGIN
        select b.cur_bal, 0
          into w_balancesheet.Balance, w_balancesheet.Sum_Balance
          from as_glbalance b
         where b.branch = p_branch_code
           and b.glcode = idx.gl_code;
      EXCEPTION
        WHEN OTHERS THEN
          w_balancesheet.Balance     := 0;
          w_balancesheet.Sum_Balance := 0;
      END;
      if w_balancesheet.Balance < 0 then
        w_balancesheet.Group_type := 'A';
        if idx.group_code in ('H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P') then
          w_balancesheet.GROUP_CODE := 'F';
        end if;
      else
        if idx.group_code in ('A', 'B', 'C', 'D', 'E', 'F') then
          w_balancesheet.GROUP_CODE := 'P';
        end if;
        w_balancesheet.Group_type := 'L';
      end if;
    
      pipe row(w_balancesheet);
    end loop;
  
    for idx in (select *
                  from as_balancesheetFormat x
                 where x.calculation = 'Q') loop
      w_balancesheet.CalculationType     := idx.calculation;
      w_balancesheet.GROUP_CODE          := idx.group_code;
      w_balancesheet.PARTICULAR_CODE     := idx.particular_code;
      w_balancesheet.PARTICULAR_NAME     := idx.particular_name;
      w_balancesheet.PAR_PARTICULAR_CODE := idx.particular_code;
      w_balancesheet.VISIBILITY          := idx.visibility;
    
      BEGIN
        select SUM(b.cur_bal), SUM(b.cur_bal)
          into w_balancesheet.Balance, w_balancesheet.Sum_Balance
          from as_glbalance b
         where b.branch = p_branch_code
           and b.glcode IN ('160000000',
                            '161000000',
                            '170000000',
                            '470000000',
                            '175000000');
      EXCEPTION
        WHEN OTHERS THEN
          w_balancesheet.Balance     := 0;
          w_balancesheet.Sum_Balance := 0;
      END;
    
      w_balancesheet.Group_type := 'L';
      w_balancesheet.GROUP_CODE := 'P';
    
      /*if w_balancesheet.Balance < 0 then
        w_balancesheet.Group_type := 'A';
        if idx.group_code in ('H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P') then
          w_balancesheet.GROUP_CODE := 'F';
        end if;
      else
        if idx.group_code in ('A', 'B', 'C', 'D', 'E', 'F') then
          w_balancesheet.GROUP_CODE := 'P';
        end if;
        w_balancesheet.Group_type := 'L';
      end if;*/
    
      pipe row(w_balancesheet);
    end loop;
  
  end fn_get_balancesheet;

  function fn_Consolidated_bs(p_fin_year in varchar2) return v_balancesheet
    pipelined is
    w_balancesheet                 balancesheet;
    V_balance                      number(18, 2) := 0;
    v_Classified_balance           number(18, 2) := 0;
    V_abandon_Property_balance     number(18, 2) := 0;
    V_offbalancesheet_item_balance number(18, 2) := 0;
    V_loanAndAdvance_balance       number(18, 2) := 0;
  
  begin
    select ((select nvl(sum(cum_prin_bal + cum_int_bal), 0)
               from tmp_rpt_bal@olddb
              where fin_year = p_fin_year
                   -- and loc_code = p_branch_code
                and ln_criteria <> 'UC') +
           (select nvl(sum(cum_prin_bal + cum_int_bal), 0)
               from tmp_rpt_bal@emidb
              where fin_year = p_fin_year
                and ln_criteria <> 'UC'
             -- and loc_code = p_branch_code
             ) + (select nvl(sum(cum_prin_bal + cum_int_bal), 0)
                     from tmp_rpt_bal@ocrdb
                    where fin_year = p_fin_year
                      and ln_criteria <> 'UC'
                   -- and loc_code = p_branch_code
                   ) + (select nvl(sum(cum_prin_bal + cum_int_bal), 0)
                           from tmp_rpt_bal@isfdb
                          where fin_year = p_fin_year
                            and ln_criteria <> 'UC'
                         --  and loc_code = p_branch_code
                         ) + (select nvl(sum(cum_prin_bal + cum_int_bal), 0)
                                 from tmp_rpt_bal@govdb
                                where fin_year = p_fin_year
                                  and ln_criteria <> 'UC'
                               -- and loc_code = p_branch_code
                               )) * -1 CL_balance
    
      into v_Classified_balance
      from dual;
  
    select sum(b.cur_bal)
      into V_offbalancesheet_item_balance
      from as_glbalance b
     where b.fin_year = p_fin_year
          
       and b.glcode = '300000000';
    w_balancesheet.Obsi_name    := 'Off-Balance Sheet Item: Deferred Interest on Unclassified Loan';
    w_balancesheet.Obsi_Balance := V_offbalancesheet_item_balance;
    select sum(b.cur_bal)
      into V_loanAndAdvance_balance
      from as_glbalance b
     where b.fin_year = p_fin_year
          
       and b.glcode = '110000000';
  
    select sum(b.cur_bal)
      into V_abandon_Property_balance
      from as_glbalance b
     where b.fin_year = p_fin_year
          
       and b.glcode = '330000000';
  
    for idx in (select *
                  from as_balancesheetFormat x
                 where x.calculation = 'F') loop
    
      w_balancesheet.GROUP_CODE          := idx.group_code;
      w_balancesheet.PARTICULAR_CODE     := idx.particular_code;
      w_balancesheet.PARTICULAR_NAME     := idx.particular_name;
      w_balancesheet.PAR_PARTICULAR_CODE := idx.particular_code;
      w_balancesheet.VISIBILITY          := idx.visibility;
      w_balancesheet.CalculationType     := idx.calculation;
    
      if idx.particular_code = '10' then
        w_balancesheet.Balance     := V_loanAndAdvance_balance +
                                      V_abandon_Property_balance +
                                      V_offbalancesheet_item_balance;
        w_balancesheet.Sum_Balance := V_loanAndAdvance_balance +
                                      V_abandon_Property_balance +
                                      V_offbalancesheet_item_balance;
      elsif idx.particular_code = '11' then
        w_balancesheet.Balance     := (V_loanAndAdvance_balance +
                                      V_abandon_Property_balance -
                                      V_abandon_Property_balance -
                                      v_Classified_balance);
        w_balancesheet.Sum_Balance := 0;
      elsif idx.particular_code = '12' then
        w_balancesheet.Balance     := -1 * V_offbalancesheet_item_balance;
        w_balancesheet.Sum_Balance := 0;
      elsif idx.particular_code = '13' then
        w_balancesheet.Balance     := V_loanAndAdvance_balance +
                                      V_abandon_Property_balance -
                                      (v_Classified_balance +
                                      V_abandon_Property_balance) +
                                      V_offbalancesheet_item_balance;
        w_balancesheet.Sum_Balance := 0;
      elsif idx.particular_code = '14' then
        w_balancesheet.Balance     := (V_abandon_Property_balance +
                                      v_Classified_balance);
        w_balancesheet.Sum_Balance := 0;
      else
        w_balancesheet.Balance     := 0;
        w_balancesheet.Sum_Balance := 0;
      end if;
    
      if w_balancesheet.Balance < 0 then
        w_balancesheet.Group_type := 'A';
        if idx.group_code in ('H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P') then
          w_balancesheet.GROUP_CODE := 'F';
        end if;
      else
        if idx.group_code in ('A', 'B', 'C', 'D', 'E', 'F') then
          w_balancesheet.GROUP_CODE := 'P';
        end if;
        w_balancesheet.Group_type := 'L';
      end if;
    
      pipe row(w_balancesheet);
    end loop;
  
    for idx in (select *
                  from as_balancesheetFormat x
                 where x.calculation = 'K') loop
    
      w_balancesheet.GROUP_CODE          := idx.group_code;
      w_balancesheet.PARTICULAR_CODE     := idx.particular_code;
      w_balancesheet.PARTICULAR_NAME     := idx.particular_name;
      w_balancesheet.PAR_PARTICULAR_CODE := idx.particular_code;
      w_balancesheet.VISIBILITY          := idx.visibility;
      w_balancesheet.CalculationType     := idx.calculation;
    
      BEGIN
        select sum(b.cur_bal), sum(b.cur_bal)
          into w_balancesheet.Balance, w_balancesheet.Sum_Balance
          from as_glbalance b
         where b.fin_year = p_fin_year
              
           and b.glcode = idx.gl_code;
      EXCEPTION
        WHEN OTHERS THEN
          w_balancesheet.Balance     := 0;
          w_balancesheet.Sum_Balance := 0;
      END;
    
      if w_balancesheet.Balance < 0 then
        w_balancesheet.Group_type := 'A';
        if idx.group_code in ('H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P') then
          w_balancesheet.GROUP_CODE := 'F';
        end if;
      else
        if idx.group_code in ('A', 'B', 'C', 'D', 'E', 'F') then
          w_balancesheet.GROUP_CODE := 'P';
        end if;
        w_balancesheet.Group_type := 'L';
      end if;
    
      pipe row(w_balancesheet);
    end loop;
  
    for idx in (select *
                  from as_balancesheetFormat x
                 where x.calculation = 'C') loop
    
      w_balancesheet.GROUP_CODE          := idx.group_code;
      w_balancesheet.PARTICULAR_CODE     := idx.particular_code;
      w_balancesheet.PARTICULAR_NAME     := idx.particular_name;
      w_balancesheet.PAR_PARTICULAR_CODE := idx.particular_code;
      w_balancesheet.VISIBILITY          := idx.visibility;
      w_balancesheet.CalculationType     := idx.calculation;
      BEGIN
        select nvl(sum(b.cur_bal), 0), nvl(sum(b.cur_bal), 0)
          into w_balancesheet.Balance, w_balancesheet.Sum_Balance
          from as_glbalance b
         where b.fin_year = p_fin_year
              
           and b.glcode in
               (select x.gl_code
                  from as_balancesheetFormat x
                 where x.sub_particular_code = idx.particular_code);
      EXCEPTION
        WHEN OTHERS THEN
          w_balancesheet.Balance     := 0;
          w_balancesheet.Sum_Balance := 0;
      END;
    
      if w_balancesheet.Balance < 0 then
        w_balancesheet.Group_type := 'A';
        if idx.group_code in ('H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P') then
          w_balancesheet.GROUP_CODE := 'F';
        end if;
      else
        if idx.group_code in ('A', 'B', 'C', 'D', 'E', 'F') then
          w_balancesheet.GROUP_CODE := 'P';
        end if;
        w_balancesheet.Group_type := 'L';
      end if;
    
      pipe row(w_balancesheet);
    end loop;
  
    for idx in (select *
                  from as_balancesheetFormat x
                 where x.calculation = 'V') loop
    
      w_balancesheet.GROUP_CODE          := idx.group_code;
      w_balancesheet.PARTICULAR_CODE     := idx.particular_code;
      w_balancesheet.PARTICULAR_NAME     := idx.particular_name;
      w_balancesheet.PAR_PARTICULAR_CODE := idx.particular_code;
      w_balancesheet.VISIBILITY          := idx.visibility;
      w_balancesheet.CalculationType     := idx.calculation;
      BEGIN
        select sum(b.cur_bal), 0
          into w_balancesheet.Balance, w_balancesheet.Sum_Balance
          from as_glbalance b
         where b.fin_year = p_fin_year
              
           and b.glcode = idx.gl_code;
      EXCEPTION
        WHEN OTHERS THEN
          w_balancesheet.Balance     := 0;
          w_balancesheet.Sum_Balance := 0;
      END;
      if w_balancesheet.Balance < 0 then
        w_balancesheet.Group_type := 'A';
        if idx.group_code in ('H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P') then
          w_balancesheet.GROUP_CODE := 'F';
        end if;
      else
        if idx.group_code in ('A', 'B', 'C', 'D', 'E', 'F') then
          w_balancesheet.GROUP_CODE := 'P';
        end if;
        w_balancesheet.Group_type := 'L';
      end if;
    
      pipe row(w_balancesheet);
    end loop;
  
    for idx in (select *
                  from as_balancesheetFormat x
                 where x.calculation = 'Q') loop
      w_balancesheet.CalculationType     := idx.calculation;
      w_balancesheet.GROUP_CODE          := idx.group_code;
      w_balancesheet.PARTICULAR_CODE     := idx.particular_code;
      w_balancesheet.PARTICULAR_NAME     := idx.particular_name;
      w_balancesheet.PAR_PARTICULAR_CODE := idx.particular_code;
      w_balancesheet.VISIBILITY          := idx.visibility;
    
      BEGIN
        select SUM(b.cur_bal), SUM(b.cur_bal)
          into w_balancesheet.Balance, w_balancesheet.Sum_Balance
          from as_glbalance b
         where b.fin_year = p_fin_year
              
           and b.glcode IN ('160000000',
                            '161000000',
                            '170000000',
                            '470000000',
                            '175000000');
      EXCEPTION
        WHEN OTHERS THEN
          w_balancesheet.Balance     := 0;
          w_balancesheet.Sum_Balance := 0;
      END;
    
      w_balancesheet.Group_type := 'L';
      w_balancesheet.GROUP_CODE := 'P';
    
      /*if w_balancesheet.Balance < 0 then
        w_balancesheet.Group_type := 'A';
        if idx.group_code in ('H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P') then
          w_balancesheet.GROUP_CODE := 'F';
        end if;
      else
        if idx.group_code in ('A', 'B', 'C', 'D', 'E', 'F') then
          w_balancesheet.GROUP_CODE := 'P';
        end if;
        w_balancesheet.Group_type := 'L';
      end if;*/
    
      pipe row(w_balancesheet);
    end loop;
  
  end fn_Consolidated_bs;

  function fn_Consolidated_bs_final(p_fin_year        in varchar2,
                                    p_adjustment_type in varchar2)
    return v_balancesheet
    pipelined is
    w_balancesheet                 balancesheet;
    V_balance                      number(18, 2) := 0;
    v_Classified_balance           number(18, 2) := 0;
    V_abandon_Property_balance     number(18, 2) := 0;
    V_offbalancesheet_item_balance number(18, 2) := 0;
    V_loanAndAdvance_balance       number(18, 2) := 0;
  
  begin
  
    if p_adjustment_type = 'B' then
      w_balancesheet.adjustment := 'Before Adjustment';
    else
      w_balancesheet.adjustment := 'After Adjustment';
    end if;
  
    select ((select nvl(sum(cum_prin_bal + cum_int_bal), 0)
               from yr_end_bal@olddb
              where fin_year = p_fin_year
                   -- and loc_code = p_branch_code
                and ln_criteria <> 'UC') +
           (select nvl(sum(cum_prin_bal + cum_int_bal), 0)
               from yr_end_bal@emidb
              where fin_year = p_fin_year
                and ln_criteria <> 'UC'
             -- and loc_code = p_branch_code
             ) + (select nvl(sum(cum_prin_bal + cum_int_bal), 0)
                     from yr_end_bal@ocrdb
                    where fin_year = p_fin_year
                      and ln_criteria <> 'UC'
                   -- and loc_code = p_branch_code
                   ) + (select nvl(sum(cum_prin_bal + cum_int_bal), 0)
                           from yr_end_bal@isfdb
                          where fin_year = p_fin_year
                            and ln_criteria <> 'UC'
                         --  and loc_code = p_branch_code
                         ) + (select nvl(sum(cum_prin_bal + cum_int_bal), 0)
                                 from yr_end_bal@govdb
                                where fin_year = p_fin_year
                                  and ln_criteria <> 'UC'
                               -- and loc_code = p_branch_code
                               )) * -1 CL_balance
    
      into v_Classified_balance
      from dual;
  
    select sum(b.cur_bal)
      into V_offbalancesheet_item_balance
      from AS_Final_GLBALANCE b
     where b.fin_year = p_fin_year
       and b.tb_type = p_adjustment_type
       and b.glcode = '300000000';
    w_balancesheet.Obsi_name    := 'Off-Balance Sheet Item: Deferred Interest on Unclassified Loan';
    w_balancesheet.Obsi_Balance := V_offbalancesheet_item_balance;
    select sum(b.cur_bal)
      into V_loanAndAdvance_balance
      from AS_Final_GLBALANCE b
     where b.fin_year = p_fin_year
       and b.tb_type = p_adjustment_type
       and b.glcode = '110000000';
  
    select sum(b.cur_bal)
      into V_abandon_Property_balance
      from AS_Final_GLBALANCE b
     where b.fin_year = p_fin_year
       and b.tb_type = p_adjustment_type
       and b.glcode = '330000000';
  
    for idx in (select *
                  from as_balancesheetFormat x
                 where x.calculation = 'F') loop
    
      w_balancesheet.GROUP_CODE          := idx.group_code;
      w_balancesheet.PARTICULAR_CODE     := idx.particular_code;
      w_balancesheet.PARTICULAR_NAME     := idx.particular_name;
      w_balancesheet.PAR_PARTICULAR_CODE := idx.particular_code;
      w_balancesheet.VISIBILITY          := idx.visibility;
      w_balancesheet.CalculationType     := idx.calculation;
    
      if idx.particular_code = '10' then
        w_balancesheet.Balance     := V_loanAndAdvance_balance +
                                      V_abandon_Property_balance +
                                      V_offbalancesheet_item_balance;
        w_balancesheet.Sum_Balance := V_loanAndAdvance_balance +
                                      V_abandon_Property_balance +
                                      V_offbalancesheet_item_balance;
      elsif idx.particular_code = '11' then
        w_balancesheet.Balance     := (V_loanAndAdvance_balance +
                                      V_abandon_Property_balance -
                                      V_abandon_Property_balance -
                                      v_Classified_balance);
        w_balancesheet.Sum_Balance := 0;
      elsif idx.particular_code = '12' then
        w_balancesheet.Balance     := -1 * V_offbalancesheet_item_balance;
        w_balancesheet.Sum_Balance := 0;
      elsif idx.particular_code = '13' then
        w_balancesheet.Balance     := V_loanAndAdvance_balance +
                                      V_abandon_Property_balance -
                                      (v_Classified_balance +
                                      V_abandon_Property_balance) +
                                      V_offbalancesheet_item_balance;
        w_balancesheet.Sum_Balance := 0;
      elsif idx.particular_code = '14' then
        w_balancesheet.Balance     := (V_abandon_Property_balance +
                                      v_Classified_balance);
        w_balancesheet.Sum_Balance := 0;
      else
        w_balancesheet.Balance     := 0;
        w_balancesheet.Sum_Balance := 0;
      end if;
    
      if w_balancesheet.Balance < 0 then
        w_balancesheet.Group_type := 'A';
        if idx.group_code in ('H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P') then
          w_balancesheet.GROUP_CODE := 'F';
        end if;
      else
        if idx.group_code in ('A', 'B', 'C', 'D', 'E', 'F') then
          w_balancesheet.GROUP_CODE := 'P';
        end if;
        w_balancesheet.Group_type := 'L';
      end if;
    
      pipe row(w_balancesheet);
    end loop;
  
    for idx in (select *
                  from as_balancesheetFormat x
                 where x.calculation = 'K') loop
    
      w_balancesheet.GROUP_CODE          := idx.group_code;
      w_balancesheet.PARTICULAR_CODE     := idx.particular_code;
      w_balancesheet.PARTICULAR_NAME     := idx.particular_name;
      w_balancesheet.PAR_PARTICULAR_CODE := idx.particular_code;
      w_balancesheet.VISIBILITY          := idx.visibility;
      w_balancesheet.CalculationType     := idx.calculation;
    
      BEGIN
        select sum(b.cur_bal), sum(b.cur_bal)
          into w_balancesheet.Balance, w_balancesheet.Sum_Balance
          from AS_Final_GLBALANCE b
         where b.fin_year = p_fin_year
           and b.tb_type = p_adjustment_type
           and b.glcode = idx.gl_code;
      EXCEPTION
        WHEN OTHERS THEN
          w_balancesheet.Balance     := 0;
          w_balancesheet.Sum_Balance := 0;
      END;
    
      if w_balancesheet.Balance < 0 then
        w_balancesheet.Group_type := 'A';
        if idx.group_code in ('H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P') then
          w_balancesheet.GROUP_CODE := 'F';
        end if;
      else
        if idx.group_code in ('A', 'B', 'C', 'D', 'E', 'F') then
          w_balancesheet.GROUP_CODE := 'P';
        end if;
        w_balancesheet.Group_type := 'L';
      end if;
    
      pipe row(w_balancesheet);
    end loop;
  
    for idx in (select *
                  from as_balancesheetFormat x
                 where x.calculation = 'C') loop
    
      w_balancesheet.GROUP_CODE          := idx.group_code;
      w_balancesheet.PARTICULAR_CODE     := idx.particular_code;
      w_balancesheet.PARTICULAR_NAME     := idx.particular_name;
      w_balancesheet.PAR_PARTICULAR_CODE := idx.particular_code;
      w_balancesheet.VISIBILITY          := idx.visibility;
      w_balancesheet.CalculationType     := idx.calculation;
      BEGIN
        select nvl(sum(b.cur_bal), 0), nvl(sum(b.cur_bal), 0)
          into w_balancesheet.Balance, w_balancesheet.Sum_Balance
          from AS_Final_GLBALANCE b
         where b.fin_year = p_fin_year
           and b.tb_type = p_adjustment_type
           and b.glcode in
               (select x.gl_code
                  from as_balancesheetFormat x
                 where x.sub_particular_code = idx.particular_code);
      EXCEPTION
        WHEN OTHERS THEN
          w_balancesheet.Balance     := 0;
          w_balancesheet.Sum_Balance := 0;
      END;
    
      if w_balancesheet.Balance < 0 then
        w_balancesheet.Group_type := 'A';
        if idx.group_code in ('H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P') then
          w_balancesheet.GROUP_CODE := 'F';
        end if;
      else
        if idx.group_code in ('A', 'B', 'C', 'D', 'E', 'F') then
          w_balancesheet.GROUP_CODE := 'P';
        end if;
        w_balancesheet.Group_type := 'L';
      end if;
    
      pipe row(w_balancesheet);
    end loop;
  
    for idx in (select *
                  from as_balancesheetFormat x
                 where x.calculation = 'V') loop
    
      w_balancesheet.GROUP_CODE          := idx.group_code;
      w_balancesheet.PARTICULAR_CODE     := idx.particular_code;
      w_balancesheet.PARTICULAR_NAME     := idx.particular_name;
      w_balancesheet.PAR_PARTICULAR_CODE := idx.particular_code;
      w_balancesheet.VISIBILITY          := idx.visibility;
      w_balancesheet.CalculationType     := idx.calculation;
      BEGIN
        select sum(b.cur_bal), 0
          into w_balancesheet.Balance, w_balancesheet.Sum_Balance
          from AS_Final_GLBALANCE b
         where b.fin_year = p_fin_year
           and b.tb_type = p_adjustment_type
           and b.glcode = idx.gl_code;
      EXCEPTION
        WHEN OTHERS THEN
          w_balancesheet.Balance     := 0;
          w_balancesheet.Sum_Balance := 0;
      END;
      if w_balancesheet.Balance < 0 then
        w_balancesheet.Group_type := 'A';
        if idx.group_code in ('H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P') then
          w_balancesheet.GROUP_CODE := 'F';
        end if;
      else
        if idx.group_code in ('A', 'B', 'C', 'D', 'E', 'F') then
          w_balancesheet.GROUP_CODE := 'P';
        end if;
        w_balancesheet.Group_type := 'L';
      end if;
    
      pipe row(w_balancesheet);
    end loop;
  
    for idx in (select *
                  from as_balancesheetFormat x
                 where x.calculation = 'Q') loop
      w_balancesheet.CalculationType     := idx.calculation;
      w_balancesheet.GROUP_CODE          := idx.group_code;
      w_balancesheet.PARTICULAR_CODE     := idx.particular_code;
      w_balancesheet.PARTICULAR_NAME     := idx.particular_name;
      w_balancesheet.PAR_PARTICULAR_CODE := idx.particular_code;
      w_balancesheet.VISIBILITY          := idx.visibility;
    
      BEGIN
        select SUM(b.cur_bal), SUM(b.cur_bal)
          into w_balancesheet.Balance, w_balancesheet.Sum_Balance
          from AS_Final_GLBALANCE b
         where b.fin_year = p_fin_year
           and b.tb_type = p_adjustment_type
           and b.glcode IN ('160000000',
                            '161000000',
                            '170000000',
                            '470000000',
                            '175000000');
      EXCEPTION
        WHEN OTHERS THEN
          w_balancesheet.Balance     := 0;
          w_balancesheet.Sum_Balance := 0;
      END;
    
      w_balancesheet.Group_type := 'L';
      w_balancesheet.GROUP_CODE := 'P';
    
      /*if w_balancesheet.Balance < 0 then
        w_balancesheet.Group_type := 'A';
        if idx.group_code in ('H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P') then
          w_balancesheet.GROUP_CODE := 'F';
        end if;
      else
        if idx.group_code in ('A', 'B', 'C', 'D', 'E', 'F') then
          w_balancesheet.GROUP_CODE := 'P';
        end if;
        w_balancesheet.Group_type := 'L';
      end if;*/
    
      pipe row(w_balancesheet);
    end loop;
  
  end fn_Consolidated_bs_final;

  function fn_get_balancesheet_final(p_branch_code     in varchar2,
                                     p_fin_year        in varchar2,
                                     p_adjustment_type in varchar2)
    return v_balancesheet
    pipelined is
    w_balancesheet                 balancesheet;
    V_balance                      number(18, 2) := 0;
    v_Classified_balance           number(18, 2) := 0;
    V_abandon_Property_balance     number(18, 2) := 0;
    V_offbalancesheet_item_balance number(18, 2) := 0;
    V_loanAndAdvance_balance       number(18, 2) := 0;
  
  begin
  
    if p_adjustment_type = 'B' then
      w_balancesheet.adjustment := 'Before Adjustment';
    else
      w_balancesheet.adjustment := 'After Adjustment';
    end if;
  
    select ((select nvl(sum(cum_prin_bal + cum_int_bal), 0)
               from yr_end_bal@olddb
              where fin_year = p_fin_year
                and loc_code = p_branch_code
                and ln_criteria <> 'UC') +
           (select nvl(sum(cum_prin_bal + cum_int_bal), 0)
               from yr_end_bal@emidb
              where fin_year = p_fin_year
                and ln_criteria <> 'UC'
                and loc_code = p_branch_code) +
           (select nvl(sum(cum_prin_bal + cum_int_bal), 0)
               from yr_end_bal@ocrdb
              where fin_year = p_fin_year
                and ln_criteria <> 'UC'
                and loc_code = p_branch_code) +
           (select nvl(sum(cum_prin_bal + cum_int_bal), 0)
               from yr_end_bal@isfdb
              where fin_year = p_fin_year
                and ln_criteria <> 'UC'
                and loc_code = p_branch_code) +
           (select nvl(sum(cum_prin_bal + cum_int_bal), 0)
               from yr_end_bal@govdb
              where fin_year = p_fin_year
                and ln_criteria <> 'UC'
                and loc_code = p_branch_code)) * -1 CL_balance
    
      into v_Classified_balance
      from dual;
  
    select b.cur_bal
      into V_offbalancesheet_item_balance
      from AS_Final_GLBALANCE b
     where b.branch = p_branch_code
       and b.fin_year = p_fin_year
       and b.tb_type = p_adjustment_type
       and b.glcode = '300000000';
    w_balancesheet.Obsi_name    := 'Off-Balance Sheet Item: Deferred Interest on Unclassified Loan';
    w_balancesheet.Obsi_Balance := V_offbalancesheet_item_balance;
    select b.cur_bal
      into V_loanAndAdvance_balance
      from AS_Final_GLBALANCE b
     where b.branch = p_branch_code
       and b.fin_year = p_fin_year
       and b.tb_type = p_adjustment_type
       and b.glcode = '110000000';
  
    select b.cur_bal
      into V_abandon_Property_balance
      from AS_Final_GLBALANCE b
     where b.branch = p_branch_code
       and b.fin_year = p_fin_year
       and b.tb_type = p_adjustment_type
       and b.glcode = '330000000';
  
    for idx in (select *
                  from as_balancesheetFormat x
                 where x.calculation = 'F') loop
    
      w_balancesheet.GROUP_CODE          := idx.group_code;
      w_balancesheet.PARTICULAR_CODE     := idx.particular_code;
      w_balancesheet.PARTICULAR_NAME     := idx.particular_name;
      w_balancesheet.PAR_PARTICULAR_CODE := idx.particular_code;
      w_balancesheet.VISIBILITY          := idx.visibility;
      w_balancesheet.CalculationType     := idx.calculation;
    
      if idx.particular_code = '10' then
        w_balancesheet.Balance     := V_loanAndAdvance_balance +
                                      V_abandon_Property_balance +
                                      V_offbalancesheet_item_balance;
        w_balancesheet.Sum_Balance := V_loanAndAdvance_balance +
                                      V_abandon_Property_balance +
                                      V_offbalancesheet_item_balance;
      elsif idx.particular_code = '11' then
        w_balancesheet.Balance     := (V_loanAndAdvance_balance +
                                      V_abandon_Property_balance -
                                      V_abandon_Property_balance -
                                      v_Classified_balance);
        w_balancesheet.Sum_Balance := 0;
      elsif idx.particular_code = '12' then
        w_balancesheet.Balance     := -1 * V_offbalancesheet_item_balance;
        w_balancesheet.Sum_Balance := 0;
      elsif idx.particular_code = '13' then
        w_balancesheet.Balance     := V_loanAndAdvance_balance +
                                      V_abandon_Property_balance -
                                      (v_Classified_balance +
                                      V_abandon_Property_balance) +
                                      V_offbalancesheet_item_balance;
        w_balancesheet.Sum_Balance := 0;
      elsif idx.particular_code = '14' then
        w_balancesheet.Balance     := (V_abandon_Property_balance +
                                      v_Classified_balance);
        w_balancesheet.Sum_Balance := 0;
      else
        w_balancesheet.Balance     := 0;
        w_balancesheet.Sum_Balance := 0;
      end if;
    
      if w_balancesheet.Balance < 0 then
        w_balancesheet.Group_type := 'A';
        if idx.group_code in ('H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P') then
          w_balancesheet.GROUP_CODE := 'F';
        end if;
      else
        if idx.group_code in ('A', 'B', 'C', 'D', 'E', 'F') then
          w_balancesheet.GROUP_CODE := 'P';
        end if;
        w_balancesheet.Group_type := 'L';
      end if;
    
      pipe row(w_balancesheet);
    end loop;
  
    for idx in (select *
                  from as_balancesheetFormat x
                 where x.calculation = 'K') loop
    
      w_balancesheet.GROUP_CODE          := idx.group_code;
      w_balancesheet.PARTICULAR_CODE     := idx.particular_code;
      w_balancesheet.PARTICULAR_NAME     := idx.particular_name;
      w_balancesheet.PAR_PARTICULAR_CODE := idx.particular_code;
      w_balancesheet.VISIBILITY          := idx.visibility;
      w_balancesheet.CalculationType     := idx.calculation;
    
      BEGIN
        select b.cur_bal, b.cur_bal
          into w_balancesheet.Balance, w_balancesheet.Sum_Balance
          from AS_Final_GLBALANCE b
         where b.branch = p_branch_code
           and b.fin_year = p_fin_year
           and b.tb_type = p_adjustment_type
           and b.glcode = idx.gl_code;
      EXCEPTION
        WHEN OTHERS THEN
          w_balancesheet.Balance     := 0;
          w_balancesheet.Sum_Balance := 0;
      END;
    
      if w_balancesheet.Balance < 0 then
        w_balancesheet.Group_type := 'A';
        if idx.group_code in ('H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P') then
          w_balancesheet.GROUP_CODE := 'F';
        end if;
      else
        if idx.group_code in ('A', 'B', 'C', 'D', 'E', 'F') then
          w_balancesheet.GROUP_CODE := 'P';
        end if;
        w_balancesheet.Group_type := 'L';
      end if;
    
      pipe row(w_balancesheet);
    end loop;
  
    for idx in (select *
                  from as_balancesheetFormat x
                 where x.calculation = 'C') loop
    
      w_balancesheet.GROUP_CODE          := idx.group_code;
      w_balancesheet.PARTICULAR_CODE     := idx.particular_code;
      w_balancesheet.PARTICULAR_NAME     := idx.particular_name;
      w_balancesheet.PAR_PARTICULAR_CODE := idx.particular_code;
      w_balancesheet.VISIBILITY          := idx.visibility;
      w_balancesheet.CalculationType     := idx.calculation;
      BEGIN
        select nvl(sum(b.cur_bal), 0), nvl(sum(b.cur_bal), 0)
          into w_balancesheet.Balance, w_balancesheet.Sum_Balance
          from AS_Final_GLBALANCE b
         where b.branch = p_branch_code
           and b.fin_year = p_fin_year
           and b.tb_type = p_adjustment_type
           and b.glcode in
               (select x.gl_code
                  from as_balancesheetFormat x
                 where x.sub_particular_code = idx.particular_code);
      EXCEPTION
        WHEN OTHERS THEN
          w_balancesheet.Balance     := 0;
          w_balancesheet.Sum_Balance := 0;
      END;
    
      if w_balancesheet.Balance < 0 then
        w_balancesheet.Group_type := 'A';
        if idx.group_code in ('H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P') then
          w_balancesheet.GROUP_CODE := 'F';
        end if;
      else
        if idx.group_code in ('A', 'B', 'C', 'D', 'E', 'F') then
          w_balancesheet.GROUP_CODE := 'P';
        end if;
        w_balancesheet.Group_type := 'L';
      end if;
    
      pipe row(w_balancesheet);
    end loop;
  
    for idx in (select *
                  from as_balancesheetFormat x
                 where x.calculation = 'V') loop
    
      w_balancesheet.GROUP_CODE          := idx.group_code;
      w_balancesheet.PARTICULAR_CODE     := idx.particular_code;
      w_balancesheet.PARTICULAR_NAME     := idx.particular_name;
      w_balancesheet.PAR_PARTICULAR_CODE := idx.particular_code;
      w_balancesheet.VISIBILITY          := idx.visibility;
      w_balancesheet.CalculationType     := idx.calculation;
      BEGIN
        select b.cur_bal, 0
          into w_balancesheet.Balance, w_balancesheet.Sum_Balance
          from AS_Final_GLBALANCE b
         where b.branch = p_branch_code
           and b.fin_year = p_fin_year
           and b.tb_type = p_adjustment_type
           and b.glcode = idx.gl_code;
      EXCEPTION
        WHEN OTHERS THEN
          w_balancesheet.Balance     := 0;
          w_balancesheet.Sum_Balance := 0;
      END;
      if w_balancesheet.Balance < 0 then
        w_balancesheet.Group_type := 'A';
        if idx.group_code in ('H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P') then
          w_balancesheet.GROUP_CODE := 'F';
        end if;
      else
        if idx.group_code in ('A', 'B', 'C', 'D', 'E', 'F') then
          w_balancesheet.GROUP_CODE := 'P';
        end if;
        w_balancesheet.Group_type := 'L';
      end if;
    
      pipe row(w_balancesheet);
    end loop;
  
    for idx in (select *
                  from as_balancesheetFormat x
                 where x.calculation = 'Q') loop
      w_balancesheet.CalculationType     := idx.calculation;
      w_balancesheet.GROUP_CODE          := idx.group_code;
      w_balancesheet.PARTICULAR_CODE     := idx.particular_code;
      w_balancesheet.PARTICULAR_NAME     := idx.particular_name;
      w_balancesheet.PAR_PARTICULAR_CODE := idx.particular_code;
      w_balancesheet.VISIBILITY          := idx.visibility;
    
      BEGIN
        select SUM(b.cur_bal), SUM(b.cur_bal)
          into w_balancesheet.Balance, w_balancesheet.Sum_Balance
          from AS_Final_GLBALANCE b
         where b.branch = p_branch_code
           and b.fin_year = p_fin_year
           and b.tb_type = p_adjustment_type
           and b.glcode IN ('160000000',
                            '161000000',
                            '170000000',
                            '470000000',
                            '175000000');
      EXCEPTION
        WHEN OTHERS THEN
          w_balancesheet.Balance     := 0;
          w_balancesheet.Sum_Balance := 0;
      END;
    
      w_balancesheet.Group_type := 'L';
      w_balancesheet.GROUP_CODE := 'P';
    
      /*if w_balancesheet.Balance < 0 then
        w_balancesheet.Group_type := 'A';
        if idx.group_code in ('H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P') then
          w_balancesheet.GROUP_CODE := 'F';
        end if;
      else
        if idx.group_code in ('A', 'B', 'C', 'D', 'E', 'F') then
          w_balancesheet.GROUP_CODE := 'P';
        end if;
        w_balancesheet.Group_type := 'L';
      end if;*/
    
      pipe row(w_balancesheet);
    end loop;
  
  end fn_get_balancesheet_final;

begin
  null;
end pkg_gas_report;
/
