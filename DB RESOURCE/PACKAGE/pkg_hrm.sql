create or replace package pkg_hrm is
  procedure sp_get_order_serial(p_branch_code in varchar2,
                                p_order_date  in date,
                                p_order_type  in varchar2,
                                p_prder_sl    out varchar2);
  procedure sp_order_increment(p_emp_id         in varchar2,
                               P_order_date     in date,
                               p_order_sl       in number,
                               p_effective_date in varchar2,
                               p_new_basic      in number,
                               p_user_id        in varchar2,
                               p_error          out varchar2);                              
  procedure sp_order_promotion(p_emp_id        in varchar2,
                               P_order_date    in date,
                               p_order_sl      in number,
                               p_grade         in varchar2,
                               p_posted_branch in varchar2,
                               p_posted_desig  in varchar2,
                               p_posted_dept   in number,
                               p_user_id       in varchar2,
                               p_error         out varchar2);
  procedure sp_order_transfer(p_emp_id        in varchar2,
                              P_order_date    in date,
                              p_order_sl      in number,
                              p_posted_branch in varchar2,
                              p_posted_desig  in varchar2,
                              p_user_id       in varchar2,
                              p_error         out varchar2);                                                           
  procedure sp_education_data(p_emp_id           in varchar2,
                              p_degree_code      in varchar2,
                              p_year             in varchar2,
                              p_rollno           in varchar2,
                              p_University_Board in varchar2,
                              p_institute        in varchar2,
                              p_Group_Discipline in varchar2,
                              p_result           in varchar2,
                              p_user_id          in varchar2,
                              p_error            out varchar2);
  procedure sp_Profession_data(p_emp_id        in varchar2,
                               p_degree_code   in varchar2,
                               p_passing_year  in number,
                               p_result        in varchar2,
                               p_organize_name in varchar2,
                               p_user_id       in varchar2,
                               p_error         out varchar2);
  procedure sp_Training_data(p_emp_id           in varchar2,
                             p_Training_subject in varchar2,
                             p_inst_code        in varchar2,
                             p_start_date       in date,
                             p_end_date         in date,
                             p_user_id          in varchar2,
                             p_error            out varchar2);
  procedure sp_Reward_data(p_emp_id             in varchar2,
                           p_reward_name        in varchar2,
                           p_reward_description in varchar2,
                           p_RewardBy           in varchar2,
                           p_RewardOn           in date,
                           p_user_id            in varchar2,
                           p_error              out varchar2);
  procedure sp_leave_data(p_emp_id            in varchar2,
                          p_leave_code        in varchar2,
                          p_leave_description in varchar2,
                          p_start_date        date,
                          p_enddate           date,
                          p_balance_type      in varchar2,
                          p_update_by         in varchar2,
                          p_error             out varchar2);
  procedure sp_new_employee_insertion(p_employee_id       in varchar2,
                                      p_employee_name     in varchar2,
                                      p_fathersName       in varchar2,
                                      p_MothersName       in varchar2,
                                      p_branch_code       in varchar2,
                                      p_designation       in number,
                                      p_joining_date      in varchar2,
                                      p_dept_code         in number,
                                      p_joining_grade     in number,
                                      p_joining_scale     in number,
                                      p_joining_quota     in number,
                                      p_gender_type       in varchar2,
                                      p_blood_grp         in varchar2,
                                      p_rhfactor          in varchar2,
                                      p_dob               in varchar2,
                                      p_contact_no        in varchar2,
                                      p_tin               in varchar2,
                                      p_email             in varchar2,
                                      p_seniority_code    in varchar2,
                                      p_address           in varchar2,
                                      p_permanent_add     in varchar2,
                                      p_entd_by           in varchar2,
                                      p_religion          in char,
                                      p_home_dist         in varchar2,
                                      p_nid_no            in varchar2,
                                      p_marital_status    in varchar2,
                                      p_passport_no       in varchar2,
                                      p_emergency_contact in varchar2,
                                      p_emergency_phone   in varchar2,
                                      p_nameBangla        in varchar2,
                                      p_fathersNameB      in varchar2,
                                      p_mothersNameB      in varchar2,
                                      p_msg               out varchar2);
end pkg_hrm;
/
create or replace package body pkg_hrm is
  procedure sp_get_order_serial(p_branch_code in varchar2,
                                p_order_date  in date,
                                p_order_type  in varchar2,
                                p_prder_sl    out varchar2)
  
   is
  begin
    select nvl(max(l.ordersl), 0) + 1
      into p_prder_sl
      from hr_order_list l
     where l.branch_code = p_branch_code
       and l.order_date = p_order_date
       and l.order_type = p_order_type;
  end sp_get_order_serial;

  procedure sp_education_data(p_emp_id           in varchar2,
                              p_degree_code      in varchar2,
                              p_year             in varchar2,
                              p_rollno           in varchar2,
                              p_University_Board in varchar2,
                              p_institute        in varchar2,
                              p_Group_Discipline in varchar2,
                              p_result           in varchar2,
                              p_user_id          in varchar2,
                              p_error            out varchar2) is
    v_exist number := 0;
  begin
    select count(*)
      into v_exist
      from hr_education_data e
     where e.emp_id = p_emp_id
       and e.degree_code = p_degree_code;
  
    if v_exist <> 0 then
      delete from hr_education_data e
       where e.emp_id = p_emp_id
         and e.degree_code = p_degree_code;
    end if;
    insert into hr_education_data
      (emp_id,
       degree_code,
       passingyear,
       rollno,
       university_board,
       institute,
       group_discipline,
       result,
       update_by,
       update_on)
    values
      (p_emp_id,
       p_degree_code,
       p_year,
       p_rollno,
       p_university_board,
       p_institute,
       p_group_discipline,
       p_result,
       p_user_id,
       sysdate);
  
  end sp_education_data;

  procedure sp_Profession_data(p_emp_id        in varchar2,
                               p_degree_code   in varchar2,
                               p_passing_year  in number,
                               p_result        in varchar2,
                               p_organize_name in varchar2,
                               p_user_id       in varchar2,
                               p_error         out varchar2) is
    v_exist number := 0;
  begin
    select count(*)
      into v_exist
      from hr_ProfessionDegree e
     where e.emp_id = p_emp_id
       and e.degree_code = p_degree_code;
  
    if v_exist <> 0 then
      delete from hr_ProfessionDegree e
       where e.emp_id = p_emp_id
         and e.degree_code = p_degree_code;
    end if;
    insert into hr_professiondegree
      (emp_id,
       degree_code,
       passing_year,
       result,
       organize_name,
       update_by,
       update_on)
    values
      (p_emp_id,
       p_degree_code,
       p_passing_year,
       p_result,
       p_organize_name,
       p_user_id,
       sysdate);
  
  end sp_Profession_data;

  procedure sp_Training_data(p_emp_id           in varchar2,
                             p_Training_subject in varchar2,
                             p_inst_code        in varchar2,
                             p_start_date       in date,
                             p_end_date         in date,
                             p_user_id          in varchar2,
                             p_error            out varchar2) is
    v_exist number := 0;
  begin
    select count(*)
      into v_exist
      from hr_TraningData e
     where e.emp_id = p_emp_id
       and e.inst_code = p_inst_code
       and e.start_date = p_start_date
       and e.end_date = p_end_date;
  
    if v_exist <> 0 then
      delete from hr_TraningData e
       where e.emp_id = p_emp_id
         and e.inst_code = p_inst_code
         and e.start_date = p_start_date
         and e.end_date = p_end_date;
    end if;
    insert into hr_TraningData
      (emp_id,
       training_subject,
       inst_code,
       start_date,
       end_date,
       update_by,
       update_on)
    values
      (p_emp_id,
       p_Training_subject,
       p_inst_code,
       p_start_date,
       p_end_date,
       p_user_id,
       sysdate);
  
  end sp_Training_data;

  procedure sp_Reward_data(p_emp_id             in varchar2,
                           p_reward_name        in varchar2,
                           p_reward_description in varchar2,
                           p_RewardBy           in varchar2,
                           p_RewardOn           in date,
                           p_user_id            in varchar2,
                           p_error              out varchar2) is
    v_exist number := 0;
  begin
    select count(*)
      into v_exist
      from hr_rewardData e
     where e.emp_id = p_emp_id
       and e.rewardby = p_RewardBy
       and e.rewardon = p_RewardOn;
    if v_exist <> 0 then
      delete from hr_rewardData e
       where e.emp_id = p_emp_id
         and e.rewardby = p_RewardBy
         and e.rewardon = p_RewardOn;
    end if;
  
    insert into hr_rewardData
      (emp_id,
       reward_name,
       reward_description,
       rewardby,
       rewardon,
       update_by,
       update_on)
    values
      (p_emp_id,
       p_reward_name,
       p_reward_description,
       p_RewardBy,
       p_RewardOn,
       p_user_id,
       sysdate);
  
  end sp_Reward_data;

  procedure sp_leave_data(p_emp_id            in varchar2,
                          p_leave_code        in varchar2,
                          p_leave_description in varchar2,
                          p_start_date        date,
                          p_enddate           date,
                          p_balance_type      in varchar2,
                          p_update_by         in varchar2,
                          p_error             out varchar2) is
    v_exist number := 0;
  begin
    select count(*)
      into v_exist
      from hr_leave_data e
     where e.emp_id = p_emp_id
       and e.leave_code = p_leave_code
       and e.start_date = p_start_date
       and e.enddate = p_enddate;
    if v_exist <> 0 then
      delete from hr_leave_data e
       where e.emp_id = p_emp_id
         and e.leave_code = p_leave_code
         and e.start_date = p_start_date
         and e.enddate = p_enddate;
    end if;
  
    insert into hr_leave_data
      (emp_id,
       leave_code,
       leave_description,
       start_date,
       enddate,
       balance_type,
       update_by,
       update_on)
    values
      (p_emp_id,
       p_leave_code,
       p_leave_description,
       p_start_date,
       p_enddate,
       p_balance_type,
       p_update_by,
       sysdate);
  
  end sp_leave_data;

  procedure sp_new_employee_insertion(p_employee_id       in varchar2,
                                      p_employee_name     in varchar2,
                                      p_fathersName       in varchar2,
                                      p_MothersName       in varchar2,
                                      p_branch_code       in varchar2,
                                      p_designation       in number,
                                      p_joining_date      in varchar2,
                                      p_dept_code         in number,
                                      p_joining_grade     in number,
                                      p_joining_scale     in number,
                                      p_joining_quota     in number,
                                      p_gender_type       in varchar2,
                                      p_blood_grp         in varchar2,
                                      p_rhfactor          in varchar2,
                                      p_dob               in varchar2,
                                      p_contact_no        in varchar2,
                                      p_tin               in varchar2,
                                      p_email             in varchar2,
                                      p_seniority_code    in varchar2,
                                      p_address           in varchar2,
                                      p_permanent_add     in varchar2,
                                      p_entd_by           in varchar2,
                                      p_religion          in char,
                                      p_home_dist         in varchar2,
                                      p_nid_no            in varchar2,
                                      p_marital_status    in varchar2,
                                      p_passport_no       in varchar2,
                                      p_emergency_contact in varchar2,
                                      p_emergency_phone   in varchar2,
                                      p_nameBangla        in varchar2,
                                      p_fathersNameB      in varchar2,
                                      p_mothersNameB      in varchar2,
                                      p_msg               out varchar2) is
  
    v_exist  number(2) := 0;
    v_max_sl number(4) := 0;
  begin
    select nvl(count(e.emp_id), 0)
      into v_exist
      from prms_employee e
     where e.emp_id = p_employee_id;
    if v_exist <> 0 then
      update prms_employee
         set emp_name          = p_employee_name,
             joining_desig     = p_designation,
             joining_date      = p_joining_date,
             gender            = p_gender_type,
             blood_grp         = p_blood_grp,
             rhfactor          = p_rhfactor,
             tin_no            = p_tin,
             email             = p_email,
             contact_no        = p_contact_no,
             dob               = p_dob,
             address           = p_address,
             mod_by            = p_entd_by,
             mod_on            = trunc(sysdate),
             religion          = p_religion,
             home_district     = p_home_dist,
             nid               = p_nid_no,
             fathers_name      = p_fathersName,
             mothers_name      = p_MothersName,
             joining_office    = p_branch_code,
             joining_grade     = p_joining_grade,
             joining_scal      = p_joining_scale,
             joining_quota     = p_joining_quota,
             marital_status    = p_marital_status,
             passport_number   = p_passport_no,
             permanent_address = p_permanent_add,
             emergency_contact = p_emergency_contact,
             emergency_phone   = p_emergency_phone,
             joining_dept      = p_dept_code,
             seniority_code    = p_seniority_code,
             NAMEBANGLA        = p_nameBangla,
             FATHERSNAMEBANGLA = p_fathersNameB,
             MOTHERSNAMEBANGLA = p_mothersNameB
      
       where emp_id = p_employee_id;
    
    else
      insert into prms_employee
        (emp_id,
         emp_name,
         joining_desig,
         joining_date,
         gender,
         blood_grp,
         rhfactor,
         tin_no,
         email,
         contact_no,
         dob,
         address,
         entd_by,
         entd_on,
         religion,
         home_district,
         nid,
         fathers_name,
         mothers_name,
         joining_office,
         joining_grade,
         joining_scal,
         joining_quota,
         marital_status,
         passport_number,
         permanent_address,
         emergency_contact,
         emergency_phone,
         joining_dept,
         seniority_code,
         NAMEBANGLA,
         FATHERSNAMEBANGLA,
         MOTHERSNAMEBANGLA)
      values
        (p_employee_id,
         p_employee_name,
         p_designation,
         p_joining_date,
         p_gender_type,
         p_blood_grp,
         p_rhfactor,
         p_tin,
         p_email,
         p_contact_no,
         p_dob,
         p_address,
         p_entd_by,
         trunc(sysdate),
         p_religion,
         p_home_dist,
         p_nid_no,
         p_fathersName,
         p_MothersName,
         p_branch_code,
         p_joining_grade,
         p_joining_scale,
         p_joining_quota,
         p_marital_status,
         p_passport_no,
         p_permanent_add,
         p_emergency_contact,
         p_emergency_phone,
         p_dept_code,
         p_seniority_code,
         p_nameBangla,
         p_fathersNameB,
         p_mothersNameB);
    
      insert into prms_emp_sal
        (emp_id,
         emp_brn_code,
         desig_code,
         desig_seniority_code,
         status_code,
         pf_deduction_pct,
         medical_allowance,
         sq_residence,
         pf_lien,
         payment_bank,
         acc_no_active,
         bank_acc,
         dearness_pct,
         pen_pct,
         arrear_basic,
         new_basic,
         bonus_yn,
         hbfc_own,
         entd_by,
         entd_on,
         emp_dept_code,
         scale,
         grade)
      values
        (p_employee_id,
         p_branch_code,
         p_designation,
         p_seniority_code,
         'TEM',
         0,
         1500,
         'N',
         'N',
         'Y',
         '?',
         'NF',
         0,
         55,
         0,
         0,
         'Y',
         'Y',
         p_entd_by,
         trunc(Sysdate),
         p_dept_code,
         p_joining_grade,
         p_joining_scale);
    
      insert into prms_emp_sal_hist
        (emp_id,
         effective_date,
         eft_serial,
         emp_brn_code,
         desig_code,
         desig_seniority_code,
         status_code,
         pf_deduction_pct,
         medical_allowance,
         sq_residence,
         pf_lien,
         payment_bank,
         acc_no_active,
         bank_acc,
         dearness_pct,
         pen_pct,
         arrear_basic,
         new_basic,
         bonus_yn,
         hbfc_own,
         entd_by,
         entd_on,
         emp_dept_code,
         scale,
         grade)
      values
        (p_employee_id,
         p_joining_date,
         1,
         p_branch_code,
         p_designation,
         p_seniority_code,
         'TEM',
         0,
         1500,
         'N',
         'Y',
         'Y',
         'Y',
         'NF',
         0,
         55,
         0,
         0,
         'Y',
         'Y',
         p_entd_by,
         trunc(Sysdate),
         p_dept_code,
         p_joining_grade,
         p_joining_scale);
      insert into prms_allowance (emp_id) values (p_employee_id);
      insert into prms_deduc
        (emp_id, welfare, gen_insurance, revenue)
      values
        (p_employee_id, 150, 40, 10);
    
    end if;
  
  exception
    when others then
      p_msg := 'Error in ' || sqlerrm;
  end sp_new_employee_insertion;
  procedure sp_order_increment(p_emp_id         in varchar2,
                               P_order_date     in date,
                               p_order_sl       in number,
                               p_effective_date in varchar2,
                               p_new_basic      in number,
                               p_user_id        in varchar2,
                               p_error          out varchar2) is
    v_exist number := 0;
  begin
  
    null;
  
  end sp_order_increment;

  procedure sp_order_promotion(p_emp_id        in varchar2,
                               P_order_date    in date,
                               p_order_sl      in number,
                               p_grade         in varchar2,
                               p_posted_branch in varchar2,
                               p_posted_desig  in varchar2,
                               p_posted_dept   in number,
                               p_user_id       in varchar2,
                               p_error         out varchar2) is
    v_exist number := 0;
  begin
  
    null;
  
  end sp_order_promotion;

  procedure sp_order_transfer(p_emp_id        in varchar2,
                              P_order_date    in date,
                              p_order_sl      in number,
                              p_posted_branch in varchar2,
                              p_posted_desig  in varchar2,
                              p_user_id       in varchar2,
                              p_error         out varchar2) is
    v_exist number := 0;
  begin
  
    null;
  
  end sp_order_transfer;

begin
  null;
end pkg_hrm;
/
