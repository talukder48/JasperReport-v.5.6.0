create or replace package pkg_hrm_report is
  type organogram is record(
    office_code      varchar2(5),
    office_NAme      varchar2(100),
    dept_code        number(2),
    dept_name        varchar2(100),
    desig_code       number(3),
    desig_name       varchar2(100),
    office_catagory  varchar2(5),
    allocated_person number(3),
    Current_person   number(3));
  type V_organogram is table of organogram;
  function fn_get_organogram(p_branch_code in varchar2) return V_organogram
    pipelined;

  type Employee is record(
    office_code     varchar2(5),
    office_Name     varchar2(100),
    pf_no           varchar2(10),
    name            varchar2(100),
    dept_code       number(2),
    dept_name       varchar2(100),
    desig_code      number(3),
    desig_name      varchar2(100),
    basic_salary    number(12, 2),
    home_distric    varchar2(40),
    contact_no      varchar2(20),
    email_id        varchar2(50),
    office_catagory varchar2(5),
    joning_date     date,
    dob             date,
    prl_date        date);
  type V_Employee is table of Employee;

  type Education is record(
    EMP_ID             varchar2(10),
    EMP_NAME           PRMS_EMPLOYEE.EMP_NAME%TYPE,
    DESIG_CODE         NUMBER(3),
    DESIG_NAME         VARCHAR2(100),
    DEGREE_CODE        hr_education_data.degree_code%type,
    DEGREE_DESCRIPTION hr_degreeparam.degree_description%type,
    PASSINGYEAR        hr_education_data.passingyear%type,
    ROLLNO             hr_education_data.rollno%type,
    UNIVERSITY_BOARD   hr_education_data.university_board%type,
    INSTITUTE          hr_education_data.institute%type,
    GROUP_DISCIPLINE   hr_education_data.group_discipline%type,
    RESULT             hr_education_data.result%type);
  type V_Education is table of Education;
  function fn_get_education(p_degree_code in varchar2) return V_Education
    pipelined;

  function fn_get_employee(p_branch_code      in varchar2,
                           p_dept_code        in number,
                           p_designation_code in number) return V_Employee
    pipelined;

end pkg_hrm_report;
/
create or replace package body pkg_hrm_report is
  function fn_get_organogram(p_branch_code in varchar2) return V_organogram
    pipelined
  
   is
    w_organogram organogram;
  begin
  
    for idx in (SELECT O.BRANCH_CODE,
                       o.dept_code,
                       (SELECT D.DEPT_NAME
                          FROM PRMS_BRN_DEPARTMENT D
                         WHERE D.DEPT_CODE = O.DEPT_CODE) DEPT,
                       o.DESIG_CODE,
                       (SELECT K.DESIGNATION_DESC
                          FROM PRMS_DESIGNATION K
                         WHERE K.DESIGNATION_CODE = O.DESIG_CODE) DESIGNATION,
                       O.ALLOCATED_PERSON,
                       (SELECT COUNT(S.EMP_ID)
                          FROM PRMS_EMP_SAL S
                         WHERE S.EMP_BRN_CODE = O.BRANCH_CODE
                           AND S.DESIG_CODE = O.DESIG_CODE
                           and s.acc_no_active = 'Y'
                           AND S.EMP_DEPT_CODE = O.DEPT_CODE) CURR_EMP
                  FROM Hr_Organogram O
                 WHERE O.BRANCH_CODE like p_branch_code) loop
    
      select u.brn_name, u.bran_class
        into w_organogram.office_Name, w_organogram.office_catagory
        from prms_mbranch u
       where u.brn_code = idx.branch_code;
    
      w_organogram.office_code      := idx.branch_code;
      w_organogram.dept_code        := idx.dept_code;
      w_organogram.dept_name        := idx.dept;
      w_organogram.desig_code       := idx.desig_code;
      w_organogram.desig_name       := idx.designation;
      w_organogram.allocated_person := idx.allocated_person;
      w_organogram.Current_person   := idx.curr_emp;
      pipe row(w_organogram);
    
    end loop;
  
    for idx in (select k.emp_brn_code, k.desig_code, k.emp_dept_code
                  from prms_emp_sal k
                 where k.acc_no_active = 'Y'
                   and k.emp_brn_code like p_branch_code
                   and k.desig_code <> 0
                minus
                select m.branch_code, m.desig_code, m.dept_code
                  from hr_organogram m
                 where m.branch_code like p_branch_code) loop
    
      w_organogram.office_code      := idx.emp_brn_code;
      w_organogram.dept_code        := idx.emp_dept_code;
      w_organogram.desig_code       := idx.desig_code;
      w_organogram.allocated_person := 0;
    
      select u.brn_name, u.bran_class
        into w_organogram.office_Name, w_organogram.office_catagory
        from prms_mbranch u
       where u.brn_code = idx.emp_brn_code;
    
      select v.dept_name
        into w_organogram.dept_name
        from prms_brn_department v
       where v.dept_code = idx.emp_dept_code;
      select k.designation_desc
        into w_organogram.desig_name
        from prms_designation k
       where k.designation_code = idx.desig_code;
    
      select count(*)
        into w_organogram.Current_person
        from prms_emp_sal k
       where k.acc_no_active = 'Y'
         and k.emp_brn_code = idx.emp_brn_code
         and k.desig_code = idx.desig_code
         and k.emp_dept_code = idx.emp_dept_code;
    
      pipe row(w_organogram);
    
    end loop;
  end fn_get_organogram;

  function fn_get_employee(p_branch_code      in varchar2,
                           p_dept_code        in number,
                           p_designation_code in number) return V_Employee
    pipelined is
    w_Employee   Employee;
    v_br_code    varchar2(5) := '';
    v_desig_code varchar2(5) := 0;
    v_deptCode   varchar2(5) := 0;
  begin
    if p_branch_code = '' or p_branch_code = '0' then
      v_br_code := '%';
    else
      v_br_code := p_branch_code;
    end if;
  
    if p_designation_code = '' or p_designation_code = '0' then
      v_desig_code := '%';
    else
      v_desig_code := p_designation_code;
    end if;
  
    if p_dept_code = '' or p_dept_code = '0' then
      v_deptCode := '%';
    else
      v_deptCode := p_dept_code;
    end if;
  
    for idx in (select k.emp_id,
                       k.emp_name,
                       k.namebangla,
                       k.joining_date,
                       y.emp_brn_code,
                       y.emp_dept_code,
                       y.desig_code,
                       y.new_basic,
                       k.home_district,
                       k.contact_no,
                       k.email,
                       TO_CHAR(ADD_MONTHS(k.dob, 59 * 12) - 1) PRL_DATE,
                       k.dob,
                       round((ADD_MONTHS(k.dob, 59 * 12) - k.joining_date) / 365) Total_duration
                  from prms_employee k
                  join prms_emp_sal y
                    on (k.emp_id = y.emp_id)
                 where y.acc_no_active = 'Y'
                   and y.desig_code <> '0'
                   and y.emp_brn_code like v_br_code
                   and y.desig_code like v_desig_code
                   and y.emp_dept_code like v_deptCode) loop
    
      w_Employee.office_code := idx.emp_brn_code;
      select u.brn_name, u.bran_class
        into w_Employee.office_Name, w_Employee.office_catagory
        from prms_mbranch u
       where u.brn_code = idx.emp_brn_code;
      w_Employee.pf_no     := idx.emp_id;
      w_Employee.name      := idx.emp_name;
      w_Employee.dept_code := idx.emp_dept_code;
      select m.dept_name
        into w_Employee.dept_name
        from prms_brn_department m
       where m.dept_code = idx.emp_dept_code;
      w_Employee.desig_code := idx.desig_code;
      select d.designation_desc
        into w_Employee.desig_name
        from prms_designation d
       where d.designation_code = idx.desig_code;
      w_Employee.joning_date  := idx.joining_date;
      w_Employee.dob          := idx.dob;
      w_Employee.prl_date     := idx.prl_date;
      w_Employee.basic_salary := idx.new_basic;
      w_Employee.home_distric := idx.home_district;
      w_Employee.contact_no   := idx.contact_no;
      w_Employee.email_id     := idx.email;
      pipe row(w_Employee);
    
    end loop;
  end fn_get_employee;

  function fn_get_education(p_degree_code in varchar2) return V_Education
    pipelined is
    w_Education Education;
  begin
  
    for idx in (select *
                  from hr_degreeparam d
                 where d.degree_code like decode(p_degree_code,'0','%',p_degree_code)
                   and d.DEGREE_TYPE = 'E') loop
      for in1 in (select d.*
                    from hr_education_data d join prms_emp_sal s
                    on(d.emp_id=s.emp_id)
                   where s.acc_no_active<>'N' and d.degree_code = idx.degree_code) loop
      
        w_Education.EMP_ID := in1.emp_id;
        
        select y.emp_name
          into w_Education.EMP_NAME
          from prms_employee y
         where y.emp_id = in1.emp_id;
        select d.designation_desc,d.designation_code
          into w_Education.DESIG_NAME,w_Education.DESIG_CODE
          from prms_emp_sal k
          join prms_designation d
            on (k.desig_code = d.designation_code)
         where k.emp_id = in1.emp_id;
         
        w_Education.DEGREE_CODE        := in1.degree_code;
        w_Education.DEGREE_DESCRIPTION := idx.degree_description;
        w_Education.PASSINGYEAR        := in1.passingyear;
        w_Education.ROLLNO             := in1.rollno;
        w_Education.UNIVERSITY_BOARD   := in1.university_board;
        w_Education.INSTITUTE          := in1.institute;
        w_Education.GROUP_DISCIPLINE   := in1.group_discipline;
        w_Education.RESULT             := in1.result;
        pipe row(w_Education);
      end loop;
    end loop;
  end fn_get_education;
begin
  null;
end pkg_hrm_report;
/
