create or replace package pkg_pension is
  procedure sp_add_pension_info(p_entity_no    in number,
                                p_nothi        in varchar,
                                p_enothi       in varchar2,
                                p_pf_no        in varchar2,
                                p_name         in varchar2,
                                p_prl_date     in date,
                                p_desig_code   in number,
                                p_gender       in varchar2,
                                p_religion     in varchar2,
                                p_dob          in date,
                                p_contact      in varchar2,
                                p_hom_dist     in varchar2,
                                p_nid          in varchar2,
                                p_mail         in varchar2,
                                p_address      in varchar2,
                                p_bank         in varchar2,
                                p_branch       in varchar2,
                                p_account      in varchar2,
                                p_activation   in varchar2,
                                p_praAddress   in varchar2,
                                p_branch_dist  in varchar2,
                                p_pension_type in varchar2,
                                p_user_id      in varchar2,
                                p_err          out varchar2);
  procedure sp_PensionCalculation_new(p_entity_no in number,
                                      p_user_id   in varchar2,
                                      p_pan_code  in varchar2,
                                      p_error     out varchar2);
  procedure sp_add_inharitance_info(p_entity_no   in number,
                                    p_nothi       in varchar,
                                    p_serial      in varchar2,
                                    p_name        in varchar2,
                                    p_Type        in varchar2,
                                    p_handicap    in varchar2,
                                    p_pen_pct     in number,
                                    p_pen_amt     in number,
                                    p_dob         in date,
                                    p_contact     in varchar2,
                                    p_hom_dist    in varchar2,
                                    p_nid         in varchar2,
                                    p_email       in varchar2,
                                    p_address     in varchar2,
                                    p_activation  in varchar2,
                                    p_bank        in varchar2,
                                    p_branch      in varchar2,
                                    p_account     in varchar2,
                                    p_praAddress  in varchar2,
                                    p_branch_dist in varchar2,
                                    p_user_id     in varchar2,
                                    p_err         out varchar2);
  procedure sp_init_values(p_msg out varchar2);
  procedure sp_pension_data_backup(p_bk_date in date, p_error out varchar2);
    procedure sp_bonus_process(p_year       in number,
                             p_month      in number,
                             p_bous_pct   in number,
                             p_bonus_type in varchar2);
end pkg_pension;
/
create or replace package body pkg_pension is
  procedure sp_add_pension_info(p_entity_no    in number,
                                p_nothi        in varchar,
                                p_enothi       in varchar2,
                                p_pf_no        in varchar2,
                                p_name         in varchar2,
                                p_prl_date     in date,
                                p_desig_code   in number,
                                p_gender       in varchar2,
                                p_religion     in varchar2,
                                p_dob          in date,
                                p_contact      in varchar2,
                                p_hom_dist     in varchar2,
                                p_nid          in varchar2,
                                p_mail         in varchar2,
                                p_address      in varchar2,
                                p_bank         in varchar2,
                                p_branch       in varchar2,
                                p_account      in varchar2,
                                p_activation   in varchar2,
                                p_praAddress   in varchar2,
                                p_branch_dist  in varchar2,
                                p_pension_type in varchar2,
                                p_user_id      in varchar2,
                                p_err          out varchar2) is
    v_count number := 0;
  begin
  
    select count(*)
      into v_count
      from pen_employee e
     where e.entity_num = p_entity_no
       and e.nothi_num = p_nothi;
    if v_count > 0 then
      update pen_employee
         set enothi_num       = p_enothi,
             emp_id           = p_pf_no,
             emp_name         = p_name,
             gender           = p_gender,
             email            = p_mail,
             contact_no       = p_contact,
             dob              = p_dob,
             address          = p_address,
             religion         = p_religion,
             home_district    = p_hom_dist,
             nid              = p_nid,
             mod_by           = p_user_id,
             mod_on           = trunc(sysdate),
             prl_date         = p_prl_date,
             designation_code = p_desig_code,
             activation_type  = p_activation,
             bank_name        = p_bank,
             branch_name      = p_branch,
             account_num      = p_account,
             branch_district  = p_branch_dist,
             praddress        = p_praAddress,
             pensioner_type   = p_pension_type
       where entity_num = p_entity_no
         and nothi_num = p_nothi;
    else
      insert into pen_employee
        (entity_num,
         nothi_num,
         enothi_num,
         emp_id,
         emp_name,
         gender,
         email,
         contact_no,
         dob,
         address,
         religion,
         home_district,
         nid,
         entd_by,
         entd_on,
         prl_date,
         designation_code,
         activation_type,
         bank_name,
         branch_name,
         account_num,
         branch_district,
         praddress,
         pensioner_type)
      values
        (p_entity_no,
         p_nothi,
         p_enothi,
         p_pf_no,
         p_name,
         p_gender,
         p_mail,
         p_contact,
         p_dob,
         p_address,
         p_religion,
         p_hom_dist,
         p_nid,
         p_user_id,
         trunc(sysdate),
         p_prl_date,
         p_desig_code,
         p_activation,
         p_bank,
         p_branch,
         p_account,
         p_branch_dist,
         p_praAddress,
         p_pension_type);
    
      insert into pen_calculation_data
        (entity_num,
         nothi_num,
         pension_amt,
         pension_arear,
         medical_amt,
         medical_arr,
         bonus,
         bonus_arr,
         others_alw,
         remrks_other_alw,
         hb_pct,
         hb_ded,
         com_ded,
         mot_ded,
         others_ded,
         remrks_other_ded,
         revinue,
         noborsho,
         dearness,
         arr_dearness)
      values
        (p_entity_no,
         p_nothi,
         0,
         0,
         0,
         0,
         0,
         0,
         0,
         'N/A',
         0,
         0,
         0,
         0,
         0,
         'N/A',
         0,
         0,
         0,
         0);
    
    end if;
  exception
    when others then
      p_err := 'Error in sp_add_pension_info : ' || sqlerrm;
  end sp_add_pension_info;

  procedure sp_add_inharitance_info(p_entity_no   in number,
                                    p_nothi       in varchar,
                                    p_serial      in varchar2,
                                    p_name        in varchar2,
                                    p_Type        in varchar2,
                                    p_handicap    in varchar2,
                                    p_pen_pct     in number,
                                    p_pen_amt     in number,
                                    p_dob         in date,
                                    p_contact     in varchar2,
                                    p_hom_dist    in varchar2,
                                    p_nid         in varchar2,
                                    p_email       in varchar2,
                                    p_address     in varchar2,
                                    p_activation  in varchar2,
                                    p_bank        in varchar2,
                                    p_branch      in varchar2,
                                    p_account     in varchar2,
                                    p_praAddress  in varchar2,
                                    p_branch_dist in varchar2,
                                    p_user_id     in varchar2,
                                    p_err         out varchar2) is
    v_count number := 0;
  begin
  
    select count(*)
      into v_count
      from pen_inheritance e
     where e.entity_num = p_entity_no
       and e.nothi_num = p_nothi
       and e.successor_sl = p_serial;
    if v_count > 0 then
      update pen_inheritance i
         set relationtype    = p_Type,
             succ_acc_active = p_activation,
             benificiaryname = p_name,
             district        = p_hom_dist,
             email           = p_email,
             contact_no      = p_contact,
             address         = p_address,
             handicap        = p_handicap,
             home_district   = p_hom_dist,
             nid             = p_nid,
             pension_pct     = p_pen_pct,
             pension_amt     = p_pen_amt,
             mod_by          = p_user_id,
             mod_on          = trunc(sysdate),
             bank_name       = p_bank,
             branch_name     = p_branch,
             bank_account    = p_account,
             dob             = p_dob,
             branch_district = p_branch_dist,
             praddress       = p_praAddress
       where i.entity_num = p_entity_no
         and i.nothi_num = p_nothi
         and i.successor_sl = p_serial;
    
    else
    
      insert into pen_inheritance
        (entity_num,
         nothi_num,
         successor_sl,
         relationtype,
         succ_acc_active,
         benificiaryname,
         district,
         email,
         contact_no,
         address,
         handicap,
         home_district,
         nid,
         pension_pct,
         pension_amt,
         entd_by,
         entd_on,
         bank_name,
         branch_name,
         bank_account,
         dob,
         branch_district,
         praddress)
      values
        (p_entity_no,
         p_nothi,
         p_serial,
         p_Type,
         p_activation,
         p_name,
         p_hom_dist,
         p_email,
         p_contact,
         p_address,
         p_handicap,
         p_hom_dist,
         p_nid,
         p_pen_pct,
         p_pen_amt,
         p_user_id,
         trunc(sysdate),
         p_bank,
         p_branch,
         p_account,
         p_dob,
         p_branch_dist,
         p_praAddress);
    
    end if;
  exception
    when others then
      p_err := 'Error in sp_add_inharitance_info : ' || sqlerrm;
  end sp_add_inharitance_info;
  procedure sp_PensionCalculation_new(p_entity_no in number,
                                      p_user_id   in varchar2,
                                      p_pan_code  in varchar2,
                                      p_error     out varchar2) is
    v_total_alw             number(12, 2) := 0;
    v_total_ded             number(12, 2) := 0;
    v_net_pay_amt           number(12, 2) := 0;
    v_ason_date             date := trunc(sysdate-10);
    v_month_code            number(2);
    v_sal_year              number(4);
    v_sal_month             varchar2(15);
    v_com_ded               number(12, 2) := 0;
    v_mot_ded               number(12, 2) := 0;
    v_hb_ded                number(12, 2) := 0;
    v_tmp_amt               number(12, 2) := 0;
    v_pen_type              char(1) := '';
    v_count                 number := 0;
    v_pen_pct               number := 0;
    v_arrear_net_pay_amount number := 0;
    v_basic_pension         number(12, 2) := 0;
  
  begin
    select upper(to_char(v_ason_date, 'Month')) into v_sal_month from dual;
    select to_number(to_char(to_date(v_ason_date, 'dd-mon-yy'), 'mm'))
      into v_month_code
      from dual;
    select to_number(to_char(v_ason_date, 'YYYY'))
      into v_sal_year
      from dual;
    delete from pen_transation_details d
     where d.entity_num = p_entity_no
       and d.year = v_sal_year
       and d.month_code = v_month_code;
  
    delete from pen_transation_advice d
     where d.entity_num = p_entity_no
       and d.year = v_sal_year
       and d.month_code = v_month_code;
  
    for idx in (select e.*,
                       d.bank_name,
                       d.branch_name,
                       d.account_num,
                       d.designation_code,
                       d.home_district,
                       '' enothi_num,
                       '' as emp_id,
                       d.emp_name,
                       d.pensioner_type,
                       d.activation_type
                  from pen_employee d
                  join pen_calculation_data e
                    on (d.entity_num = e.entity_num and
                       d.nothi_num = e.nothi_num)
                 where d.entity_num = p_entity_no
                -- and d.activation_type = 'Y'
                -- and d.nothi_num='18'
                ) loop
    
      v_basic_pension := nvl(idx.pension_amt, 0);
    
      if idx.pensioner_type = 'S' then
        v_basic_pension := 0;
      end if;
    
      select count(*)
        into v_count
        from pen_inheritance i
       where i.entity_num = idx.entity_num
         and i.nothi_num = idx.nothi_num;
      --and i.succ_acc_active = 'Y';
    
      if v_count > 0 then
        v_pen_type := 'F';
        for in1 in (select *
                      from pen_inheritance i
                     where i.entity_num = idx.entity_num
                       and i.nothi_num = idx.nothi_num
                    -- and i.succ_acc_active = 'Y'
                    ) loop
        
          v_pen_pct               := nvl(in1.pension_pct, 0);
          v_arrear_net_pay_amount := in1.pension_amt; --will be treated as missed payment amount.
          v_total_alw             := round(round(nvl(v_basic_pension, 0) +
                                                 nvl(idx.Pension_Arear, 0) +
                                                 nvl(idx.Medical_Amt, 0) +
                                                 nvl(idx.Medical_Arr, 0) +
                                                 nvl(idx.Bonus, 0) +
                                                 nvl(idx.Bonus_Arr, 0) +
                                                 nvl(idx.others_alw, 0) +
                                                 nvl(idx.dearness, 0) +
                                                 nvl(idx.arr_dearness, 0) +
                                                 nvl(idx.noborsho, 0) +
                                                 nvl(v_arrear_net_pay_amount,
                                                     0),
                                                 2) * v_pen_pct / 100,
                                           2);
        
          if p_pan_code = 'DEFULT' then
            v_com_ded := round(nvl(idx.Com_Ded, 0) * v_pen_pct / 100, 2);
            v_mot_ded := round(nvl(idx.Mot_Ded, 0) * v_pen_pct / 100, 2);
            v_hb_ded  := round(nvl(idx.Hb_Ded, 0) * v_pen_pct / 100, 2);
          
          else
            v_com_ded := 0;
            v_mot_ded := 0;
            v_hb_ded  := 0;
          end if;
          v_total_ded   := round(nvl(v_com_ded, 0) + nvl(v_mot_ded, 0) +
                                 nvl(v_hb_ded, 0) + idx.revinue +
                                 nvl(idx.Others_Ded, 0),
                                 2);
          v_net_pay_amt := round(v_total_alw - v_total_ded, 2);
        
          if in1.succ_acc_active = 'Y' then
            insert into pen_transation_details
              (entity_num,
               year,
               month_code,
               nothi_no,
               emp_id,
               emp_name,
               district,
               tran_sl,
               designation,
               pension_basic,
               pension_arrear,
               pen_medical_alw,
               pen_medical_arear,
               pen_bonus,
               pen_bonus_arear,
               others_alw,
               remarks_others_alw,
               hb_ded_pct,
               hb_ded_amount,
               com_ded_amt,
               mot_ded_amt,
               others_ded_amt,
               remarks_others_ded,
               revnue,
               gross_amount,
               total_deduction,
               net_payment,
               bank_name,
               branch_name,
               bank_account,
               branch_location,
               dearness,
               arr_dearness,
               noborsho,
               acc_type,
               sucessor_name,
               ActivationType)
            values
              (p_entity_no,
               v_sal_year,
               v_month_code,
               idx.Nothi_Num,
               idx.emp_id,
               idx.emp_name,
               idx.home_district,
               in1.successor_sl,
               (select d.designation_desc
                  from prms_designation d
                 where d.designation_code = idx.designation_code),
               round(nvl(v_basic_pension, 0) * v_pen_pct / 100, 2),
               round(nvl(idx.Pension_Arear, 0) * v_pen_pct / 100, 2),
               round(nvl(idx.Medical_Amt, 0) * v_pen_pct / 100, 2),
               round(nvl(idx.Medical_Arr, 0) * v_pen_pct / 100, 2),
               round(nvl(idx.Bonus, 0) * v_pen_pct / 100, 2),
               round(nvl(idx.Bonus_Arr, 0) * v_pen_pct / 100, 2),
               round(nvl(idx.others_alw, 0) * v_pen_pct / 100 +
                     nvl(v_arrear_net_pay_amount, 0),
                     2),
               decode(idx.Remrks_Other_Alw,
                      'N/A',
                      '',
                      '0',
                      '',
                      idx.Remrks_Other_Alw),
               idx.hb_pct,
               v_hb_ded,
               v_com_ded,
               v_mot_ded,
               round(nvl(idx.Others_Ded, 0) * v_pen_pct / 100, 2),
               decode(idx.Remrks_Other_Ded,
                      'N/A',
                      '',
                      '0',
                      '',
                      idx.Remrks_Other_Ded),
               idx.revinue,
               v_total_alw,
               v_total_ded,
               v_net_pay_amt,
               in1.bank_name,
               in1.branch_name,
               in1.bank_account,
               in1.branch_district,
               round(idx.dearness * v_pen_pct / 100, 2),
               round(idx.arr_dearness * v_pen_pct / 100, 2),
               round(idx.noborsho * v_pen_pct / 100, 2),
               v_pen_type,
               in1.benificiaryname,
               in1.succ_acc_active);
          else
            insert into pen_transation_details
              (entity_num,
               year,
               month_code,
               nothi_no,
               emp_id,
               emp_name,
               district,
               tran_sl,
               designation,
               pension_basic,
               pension_arrear,
               pen_medical_alw,
               pen_medical_arear,
               pen_bonus,
               pen_bonus_arear,
               others_alw,
               remarks_others_alw,
               hb_ded_pct,
               hb_ded_amount,
               com_ded_amt,
               mot_ded_amt,
               others_ded_amt,
               remarks_others_ded,
               revnue,
               gross_amount,
               total_deduction,
               net_payment,
               bank_name,
               branch_name,
               bank_account,
               branch_location,
               dearness,
               arr_dearness,
               noborsho,
               acc_type,
               sucessor_name,
               ActivationType)
            values
              (p_entity_no,
               v_sal_year,
               v_month_code,
               idx.Nothi_Num,
               idx.emp_id,
               idx.emp_name,
               idx.home_district,
               in1.successor_sl,
               (select d.designation_desc
                  from prms_designation d
                 where d.designation_code = idx.designation_code),
               0,
               0,
               0,
               0,
               0,
               0,
               0,
               '',
               0,
               0,
               0,
               0,
               0,
               '',
               0,
               0,
               0,
               0,
               in1.bank_name,
               in1.branch_name,
               in1.bank_account,
               in1.branch_district,
               0,
               0,
               0,
               v_pen_type,
               in1.benificiaryname,
               in1.succ_acc_active);
          end if;
        
        end loop;
      
      else
        if idx.activation_type = 'Y' then
          v_pen_type  := 'S';
          v_total_alw := round(nvl(v_basic_pension, 0) +
                               nvl(idx.Pension_Arear, 0) +
                               nvl(idx.Medical_Amt, 0) +
                               nvl(idx.Medical_Arr, 0) + nvl(idx.Bonus, 0) +
                               nvl(idx.Bonus_Arr, 0) +
                               nvl(idx.others_alw, 0) +
                               nvl(idx.dearness, 0) +
                               nvl(idx.arr_dearness, 0) +
                               nvl(idx.noborsho, 0),
                               2);
        
          if p_pan_code = 'DEFULT' then
            v_com_ded := nvl(idx.Com_Ded, 0);
            v_mot_ded := nvl(idx.Mot_Ded, 0);
            v_hb_ded  := nvl(idx.Hb_Ded, 0);
          
          else
            v_com_ded := 0;
            v_mot_ded := 0;
            v_hb_ded  := 0;
          end if;
        
          v_total_ded   := round(nvl(v_com_ded, 0) + nvl(v_mot_ded, 0) +
                                 nvl(v_hb_ded, 0) + idx.revinue +
                                 nvl(idx.Others_Ded, 0),
                                 2);
          v_net_pay_amt := round(v_total_alw - v_total_ded, 2);
          insert into pen_transation_details
            (entity_num,
             year,
             month_code,
             nothi_no,
             emp_id,
             emp_name,
             district,
             tran_sl,
             designation,
             pension_basic,
             pension_arrear,
             pen_medical_alw,
             pen_medical_arear,
             pen_bonus,
             pen_bonus_arear,
             others_alw,
             remarks_others_alw,
             hb_ded_pct,
             hb_ded_amount,
             com_ded_amt,
             mot_ded_amt,
             others_ded_amt,
             remarks_others_ded,
             revnue,
             gross_amount,
             total_deduction,
             net_payment,
             bank_name,
             branch_name,
             bank_account,
             branch_location,
             dearness,
             arr_dearness,
             noborsho,
             acc_type,
             ActivationType)
          values
            (p_entity_no,
             v_sal_year,
             v_month_code,
             idx.Nothi_Num,
             idx.emp_id,
             idx.emp_name,
             idx.home_district,
             1,
             (select d.designation_desc
                from prms_designation d
               where d.designation_code = idx.designation_code),
             v_basic_pension,
             nvl(idx.Pension_Arear, 0),
             nvl(idx.Medical_Amt, 0),
             nvl(idx.Medical_Arr, 0),
             nvl(idx.Bonus, 0),
             nvl(idx.Bonus_Arr, 0),
             nvl(idx.others_alw, 0),
             decode(idx.Remrks_Other_Alw,
                    'N/A',
                    '',
                    '0',
                    '',
                    idx.Remrks_Other_Alw),
             idx.hb_pct,
             v_hb_ded,
             v_com_ded,
             v_mot_ded,
             nvl(idx.Others_Ded, 0),
             decode(idx.Remrks_Other_Ded,
                    'N/A',
                    '',
                    '0',
                    '',
                    idx.Remrks_Other_Ded),
             idx.revinue,
             v_total_alw,
             v_total_ded,
             v_net_pay_amt,
             idx.bank_name,
             idx.branch_name,
             idx.Account_Num,
             (SELECT e.branch_district
                FROM pen_employee e
               where e.nothi_num = idx.nothi_num),
             idx.dearness,
             idx.arr_dearness,
             idx.noborsho,
             v_pen_type,
             idx.activation_type);
        
        else
          insert into pen_transation_details
            (entity_num,
             year,
             month_code,
             nothi_no,
             emp_id,
             emp_name,
             district,
             tran_sl,
             designation,
             pension_basic,
             pension_arrear,
             pen_medical_alw,
             pen_medical_arear,
             pen_bonus,
             pen_bonus_arear,
             others_alw,
             remarks_others_alw,
             hb_ded_pct,
             hb_ded_amount,
             com_ded_amt,
             mot_ded_amt,
             others_ded_amt,
             remarks_others_ded,
             revnue,
             gross_amount,
             total_deduction,
             net_payment,
             bank_name,
             branch_name,
             bank_account,
             branch_location,
             dearness,
             arr_dearness,
             noborsho,
             acc_type,
             ActivationType)
          values
            (p_entity_no,
             v_sal_year,
             v_month_code,
             idx.Nothi_Num,
             idx.emp_id,
             idx.emp_name,
             idx.home_district,
             1,
             (select d.designation_desc
                from prms_designation d
               where d.designation_code = idx.designation_code),
             0,
             0,
             0,
             0,
             0,
             0,
             0,
             '',
             0,
             0,
             0,
             0,
             0,
             '',
             0,
             0,
             0,
             0,
             idx.bank_name,
             idx.branch_name,
             idx.Account_Num,
             (SELECT e.branch_district
                FROM pen_employee e
               where e.nothi_num = idx.nothi_num),
             0,
             0,
             0,
             v_pen_type,
             idx.activation_type);
        end if;
      
      end if;
    
    end loop;
  
    /*for id in (select *
                 from pen_transation_details d
                where d.entity_num = p_entity_no
                  and d.year = v_sal_year
                  and d.month_code = v_month_code) loop
      if id.acc_type = 'F' then
        for in1 in (select *
                      from pen_inheritance i
                     where i.entity_num = id.entity_num
                       and i.nothi_num = id.nothi_no
                       and i.succ_acc_active <> 'N') loop
        
          \* if nvl(in1.pension_amt, 0) <> 0 then
            v_tmp_amt := nvl(in1.pension_amt, 0);
          else
            v_tmp_amt := round((id.net_payment * in1.pension_pct) / 100, 2);
          end if;
          *\
          v_tmp_amt := round((id.net_payment * in1.pension_pct) / 100, 2);
        
          insert into pen_transation_advice
            (entity_num,
             year,
             month_code,
             nothi_no,
             emp_id,
             emp_name,
             district,
             tran_sl,
             succ_name,
             designation,
             net_payment,
             bank_name,
             branch_name,
             bank_account,
             BRANCH_DISTRICT)
          values
            (id.entity_num,
             id.year,
             id.month_code,
             id.nothi_no,
             id.emp_id,
             id.emp_name,
             in1.district,
             in1.successor_sl,
             in1.benificiaryname,
             (select d.designation_desc
                from prms_designation d
               where d.designation_code =
                     (select e.designation_code
                        from pen_employee e
                       where e.nothi_num = id.nothi_no)),
             v_tmp_amt,
             in1.bank_name,
             in1.branch_name,
             in1.bank_account,
             (select h.branch_district
                from pen_inheritance h
               where h.nothi_num = in1.nothi_num
                 and h.successor_sl = in1.successor_sl));
        
        end loop;
      else
        insert into pen_transation_advice
          (entity_num,
           year,
           month_code,
           nothi_no,
           emp_id,
           emp_name,
           district,
           tran_sl,
           succ_name,
           designation,
           net_payment,
           bank_name,
           branch_name,
           bank_account,
           BRANCH_DISTRICT)
        values
          (id.entity_num,
           id.year,
           id.month_code,
           id.nothi_no,
           id.emp_id,
           id.emp_name,
           id.district,
           id.tran_sl,
           '',
           (select d.designation_desc
              from prms_designation d
             where d.designation_code =
                   (select e.designation_code
                      from pen_employee e
                     where e.nothi_num = id.nothi_no)),
           id.net_payment,
           id.bank_name,
           id.branch_name,
           id.bank_account,
           (select h.branch_district
              from pen_employee h
             where h.nothi_num = id.nothi_no));
      end if;
    end loop;*/
  
  end sp_PensionCalculation_new;

  procedure sp_init_values(p_msg out varchar2) is
    v_day_of_mon number := 0;
    v_error      varchar2(800) := '';
  begin
    select extract(day from sysdate) into v_day_of_mon from dual;
    --v_day_of_mon := 1;
    if (v_day_of_mon <= 15) then
      update pen_calculation_data d
         set d.arr_dearness     = 0,
             d.pension_arear    = 0,
             d.medical_arr      = 0,
             d.bonus_arr        = 0,
             d.others_alw       = 0,
             d.others_ded       = 0,
             d.noborsho         = 0,
             d.remrks_other_alw = '',
             d.remrks_other_ded = '';
      update pen_inheritance a set a.pension_amt = 0;
      p_msg := 'SUCCESS';
    else
      p_msg := 'EXPIRED';
    end if;
  exception
    when others then
      p_msg := 'Error in SP_INIT_VALUES ' || sqlerrm;
  end sp_init_values;
  procedure sp_pension_data_backup(p_bk_date in date, p_error out varchar2) is
    v_month_code number(4) := 0;
    v_sal_year   number(4) := 0;
  begin
  
    DELETE FROM pen_employee_hist E
     WHERE E.ENTITY_NUM = 1
       AND E.BK_DATE = p_bk_date;
    DELETE FROM pen_inheritance_hist E
     WHERE E.ENTITY_NUM = 1
       AND E.BK_DATE = p_bk_date;
    DELETE FROM pen_calculation_data_hist E
     WHERE E.ENTITY_NUM = 1
       AND E.BK_DATE = p_bk_date;
    DELETE FROM pen_transation_details_hist E
     WHERE E.ENTITY_NUM = 1
       AND E.BK_DATE = p_bk_date;
  
    select to_number(to_char(to_date(p_bk_date, 'dd-mon-yy'), 'mm'))
      into v_month_code
      from dual;
    select to_number(to_char(p_bk_date, 'YYYY')) into v_sal_year from dual;
  
    INSERT INTO pen_employee_hist
      SELECT entity_num,
             p_bk_date,
             nothi_num,
             enothi_num,
             emp_id,
             emp_name,
             gender,
             tin_no,
             email,
             contact_no,
             dob,
             address,
             religion,
             highest_degree,
             home_district,
             nid,
             entd_by,
             entd_on,
             mod_by,
             mod_on,
             prl_date,
             designation_code,
             activation_type,
             bank_name,
             branch_name,
             account_num,
             branch_district,
             praddress,
             pensioner_type
        FROM pen_employee;
    INSERT INTO pen_inheritance_hist
      select entity_num,
             p_bk_date,
             nothi_num,
             successor_sl,
             relationtype,
             succ_acc_active,
             benificiaryname,
             district,
             email,
             contact_no,
             address,
             handicap,
             highest_degree,
             home_district,
             nid,
             pension_pct,
             pension_amt,
             entd_by,
             entd_on,
             mod_by,
             mod_on,
             bank_name,
             branch_name,
             bank_account,
             dob,
             branch_district,
             praddress
        from pen_inheritance;
    INSERT INTO pen_calculation_data_hist
      select entity_num,
             p_bk_date,
             nothi_num,
             pension_amt,
             pension_arear,
             medical_amt,
             medical_arr,
             bonus,
             bonus_arr,
             others_alw,
             remrks_other_alw,
             hb_pct,
             hb_ded,
             com_ded,
             mot_ded,
             others_ded,
             remrks_other_ded,
             revinue,
             noborsho,
             dearness,
             arr_dearness
        from pen_calculation_data;
    INSERT INTO PEN_TRANSATION_DETAILS_HIST
      select entity_num,
             p_bk_date,
             year,
             month_code,
             nothi_no,
             emp_id,
             emp_name,
             district,
             tran_sl,
             acc_type,
             designation,
             pension_basic,
             pension_arrear,
             pen_medical_alw,
             pen_medical_arear,
             pen_bonus,
             pen_bonus_arear,
             others_alw,
             remarks_others_alw,
             hb_ded_pct,
             hb_ded_amount,
             com_ded_amt,
             mot_ded_amt,
             others_ded_amt,
             remarks_others_ded,
             revnue,
             gross_amount,
             total_deduction,
             net_payment,
             bank_name,
             branch_name,
             bank_account,
             dearness,
             arr_dearness,
             noborsho,
             branch_location,
             sucessor_name,
             activation_type,
             activationtype
        from pen_transation_details d
       where d.year = v_sal_year
         and d.month_code = v_month_code;
  
  EXCEPTION
    WHEN OTHERS THEN
      p_error := 'Error in sp_pension_data_backup' || sqlerrm;
  end sp_pension_data_backup;

  procedure sp_bonus_process(p_year       in number,
                             p_month      in number,
                             p_bous_pct   in number,
                             p_bonus_type in varchar2) is
    v_rel_type char(1) := '';
    v_bonus_amt        number:=0;
    v_ded_amt          number:=0;
    v_deduction_amt    number:=0;
    v_net_pay          number:=0;
  begin
  
    delete from pen_bonus_transaction t
     where t.entity_num = 1
       and t.year = p_year
       and t.monthcode = p_month+1
       and t.bonustype = p_bonus_type;
  
    if p_bonus_type = 'EIDFIT' OR p_bonus_type = 'EIDADHA' then
      v_rel_type := 'M';
    ELSIF p_bonus_type = 'DURGAPUJA' THEN
      v_rel_type := 'H';
    ELSE
      v_rel_type := '*';
    end if;
  
    for id in (select NOTHI_NO,
                      decode(sucessor_name, '', EMP_NAME, sucessor_name) benificiary,
                      decode(decode(sucessor_name,
                                    '',
                                    EMP_NAME,
                                    sucessor_name),
                             EMP_NAME,
                             '',
                             EMP_NAME) predecessor,
                      decode(branch_location, 'DM', 'D', 'Dhaka', 'D', 'O') district,
                      DESIGNATION,
                      decode(pension_basic,
                             0,
                             (SELECT d.pension_amt
                                FROM pen_calculation_data d
                               where d.nothi_num = a.nothi_no),
                             a.pension_basic) PensionBasic,
                      round(decode(pension_basic,
                                   0,
                                   (SELECT d.pension_amt
                                      FROM pen_calculation_data d
                                     where d.nothi_num = a.nothi_no),
                                   a.pension_basic) * p_bous_pct,
                            2) bonusamount,
                      10 revenue,
                      round(decode(pension_basic,
                                   0,
                                   (SELECT d.pension_amt
                                      FROM pen_calculation_data d
                                     where d.nothi_num = a.nothi_no),
                                   a.pension_basic) * p_bous_pct - 10,
                            2) netBonus,
                      
                      BANK_NAME,
                      BRANCH_NAME,
                      BANK_ACCOUNT
                 from pen_transation_details a
                where a.entity_num = 1
                  and a.year = p_year
                  and a.month_code = p_month
                  AND (SELECT DECODE(E.RELIGION, 'H', 'H', 'M')
                         FROM PEN_EMPLOYEE E
                        WHERE E.NOTHI_NUM = A.NOTHI_NO) LIKE v_rel_type
                  and decode(pension_basic,
                             0,
                             (SELECT d.pension_amt
                                FROM pen_calculation_data d
                               where d.nothi_num = a.nothi_no),
                             a.pension_basic) <> 0
                    --  and decode(branch_location, 'DM', 'D', 'Dhaka', 'D', 'O') like '*'
                  and activationtype like 'Y') loop
    
    v_bonus_amt      := id.bonusamount;
    if(id.nothi_no='214' or id.nothi_no='359' or id.nothi_no='502' or id.nothi_no='425' or id.nothi_no='443') then
            v_ded_amt        :=  id.bonusamount-id.revenue;
    else
            v_ded_amt        :=  0;
    end if;
  
    v_deduction_amt  :=v_ded_amt+id.revenue;
    v_net_pay        :=v_bonus_amt-v_ded_amt-id.revenue;
      insert into pen_bonus_transaction
        (entity_num,
         year,
         monthcode,
         bonustype,
         nothi_no,
         benificiary,
         predecessor,
         designation,
         pensionbasic,
         bonusamt,
         revenue,
         deduction_amt,
         total_deduction_amt,
         netbonus,
         branch_name,
         bank_account,
         br_location)
      values
        (1,
         p_year,
         7,
         p_bonus_type,
         id.nothi_no,
         id.benificiary,
         id.predecessor,
         id.designation,
         id.pensionbasic,
         v_bonus_amt,
         id.revenue,
         v_ded_amt,
         v_deduction_amt,
         v_net_pay,
         id.branch_name,
         id.bank_account,
         id.district);
     
    end loop;
  end sp_bonus_process;
begin
  null;
end pkg_pension;
/
