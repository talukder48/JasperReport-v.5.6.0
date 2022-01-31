create or replace package pkg_mis_rpt is
  type misReportData is record(
    Operation_code       number(4),
    Operation_activities varchar2(100),
    subop_code           number(2),
    subop_activities     varchar2(50),
    target_Anual         number(12, 2),
    target_100Ds         number(12, 2),
    achivement_anual     number(12, 2),
    achivement_100Ds     number(12, 2));
  type V_misReportData is table of misReportData;
  
  type misBranchData is record(
    Zonal_code          varchar2(10),
    branch_code          varchar2(10),
    Operation_code       number(4),
    Operation_activities varchar2(100),
    subop_code           number(2),
    subop_activities     varchar2(50),
    target_Anual         number(12, 2),
    target_100Ds         number(12, 2),
    achivement_anual     number(12, 2),
    achivement_100Ds     number(12, 2));
  
   type V_misBranchData is table of misBranchData;
  function fn_summary_report_branch(p_Branch    in varchar2)
    return V_misBranchData
    pipelined;
  function fn_summary_report_branch_new(p_Branch in varchar2)
    return V_misReportData
    pipelined;

  type misSummaryReport is record(
    Operation_code       number(4),
    Operation_activities varchar2(100),
    subop_code           number(2),
    subop_activities     varchar2(50),
    description          varchar2(50),
    Dhaka_north_100DS    number(12, 2),
    Dhaka_North_Annual   number(12, 2),
    Dhaka_South_100DS    number(12, 2),
    Dhaka_South_Annual   number(12, 2),
    chattogram_100DS     number(12, 2),
    chattogram_Annual    number(12, 2),
    khulna_100DS         number(12, 2),
    khulna_Annual        number(12, 2),
    Rajshahi_100DS       number(12, 2),
    Rajshahi_Annual      number(12, 2),
    Sylhet_100DS         number(12, 2),
    Sylhet_Annual        number(12, 2),
    Barisal_100DS        number(12, 2),
    Barisal_Annual       number(12, 2),
    Rangpur_100DS        number(12, 2),
    Rangpur_Annual       number(12, 2),
    Mymensing_100DS      number(12, 2),
    Mymensing_Annual     number(12, 2),
    Faridpur_100DS       number(12, 2),
    Faridpur_Annual      number(12, 2),
    total_100days        number(12, 2),
    total_Annual         number(12, 2));
  type v_misSummaryReport is table of misSummaryReport;
  function fn_summary_report(p_Branch in varchar2) return v_misSummaryReport
    pipelined;
  function fn_summary_report_others(p_Branch in varchar2)
    return v_misSummaryReport
    pipelined;
  function fn_summary_mis return v_misSummaryReport
    pipelined;
  function fn_summary_mis_others return v_misSummaryReport
    pipelined;
end pkg_mis_rpt;
/
create or replace package body pkg_mis_rpt is
  function fn_summary_report_others(p_Branch in varchar2)
    return v_misSummaryReport
    pipelined is
    w_misSummaryReport misSummaryReport;
    v_Ann_start_date   date;
    v_ann_end_date     date;
    v_100Days_start    date;
    v_100Days_end      date;
  
  begin
  
    SELECT m.start_date, m.end_date
      into v_100Days_start, v_100Days_end
      FROM TARGET_MASTER m
     where m.target_code = '100DAYS';
  
    SELECT m.start_date, m.end_date
      into v_Ann_start_date, v_ann_end_date
      FROM TARGET_MASTER m
     where m.target_code = 'FY20-21';
  
    w_misSummaryReport.Operation_code       := '04';
    w_misSummaryReport.Operation_activities := 'Disposal of Audit Objections';
    w_misSummaryReport.subop_code           := '01';
    w_misSummaryReport.subop_activities     := 'Commercial Audit';
    w_misSummaryReport.description          := 'Target';
    ----------------Dhaka North-------------------
    SELECT sum(s.AUDIT_COMMERCIAL)
      into w_misSummaryReport.Dhaka_north_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0600Z');
  
    SELECT sum(s.AUDIT_COMMERCIAL)
      into w_misSummaryReport.Dhaka_North_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0600Z');
    ----------------Dhaka South-------------------
    SELECT sum(s.AUDIT_COMMERCIAL)
      into w_misSummaryReport.Dhaka_South_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0800Z');
  
    SELECT sum(s.AUDIT_COMMERCIAL)
      into w_misSummaryReport.Dhaka_South_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0800Z');
    -----------------Chattogram-------------------
    SELECT sum(s.AUDIT_COMMERCIAL)
      into w_misSummaryReport.chattogram_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0100Z');
  
    SELECT sum(s.AUDIT_COMMERCIAL)
      into w_misSummaryReport.chattogram_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0100Z');
    -----------------Khulna-----------------------
    SELECT sum(s.AUDIT_COMMERCIAL)
      into w_misSummaryReport.khulna_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0200Z');
  
    SELECT sum(s.AUDIT_COMMERCIAL)
      into w_misSummaryReport.khulna_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0200Z');
    ----------------Rajshahi---------------------
    SELECT sum(s.AUDIT_COMMERCIAL)
      into w_misSummaryReport.Rajshahi_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0300Z');
  
    SELECT sum(s.AUDIT_COMMERCIAL)
      into w_misSummaryReport.Rajshahi_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0300Z');
  
    ----------------Sylhet---------------------
    SELECT sum(s.AUDIT_COMMERCIAL)
      into w_misSummaryReport.Sylhet_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0500Z');
  
    SELECT sum(s.AUDIT_COMMERCIAL)
      into w_misSummaryReport.Sylhet_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0500Z');
    ----------------barisal---------------------
    SELECT sum(s.AUDIT_COMMERCIAL)
      into w_misSummaryReport.Barisal_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0400Z');
  
    SELECT sum(s.AUDIT_COMMERCIAL)
      into w_misSummaryReport.Barisal_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0400Z');
  
    ----------------Rangpur---------------------
    SELECT sum(s.AUDIT_COMMERCIAL)
      into w_misSummaryReport.Rangpur_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '5000Z');
  
    SELECT sum(s.AUDIT_COMMERCIAL)
      into w_misSummaryReport.Rangpur_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '5000Z');
  
    ----------------Mymensing---------------------
    SELECT sum(s.AUDIT_COMMERCIAL)
      into w_misSummaryReport.Mymensing_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '4000Z');
  
    SELECT sum(s.AUDIT_COMMERCIAL)
      into w_misSummaryReport.Mymensing_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '4000Z');
  
    ----------------Faridpur---------------------
    SELECT sum(s.AUDIT_COMMERCIAL)
      into w_misSummaryReport.Faridpur_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '2001Z');
  
    SELECT sum(s.AUDIT_COMMERCIAL)
      into w_misSummaryReport.Faridpur_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '2001Z');
  
    pipe row(w_misSummaryReport);
  
    w_misSummaryReport.description := 'Achievement';
    ----dhaka north----------
    select sum(d.COMMERCIAL_OBJ)
      into w_misSummaryReport.Dhaka_north_100DS
      from mis_audit_ob_disposal d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0600Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.COMMERCIAL_OBJ)
      into w_misSummaryReport.Dhaka_North_Annual
      from mis_audit_ob_disposal d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0600Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
    ----dhaka south----------
    select sum(d.COMMERCIAL_OBJ)
      into w_misSummaryReport.Dhaka_South_100DS
      from mis_audit_ob_disposal d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0800Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.COMMERCIAL_OBJ)
      into w_misSummaryReport.Dhaka_South_Annual
      from mis_audit_ob_disposal d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0800Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
    ----chittaganj----------
    select sum(d.COMMERCIAL_OBJ)
      into w_misSummaryReport.chattogram_100DS
      from mis_audit_ob_disposal d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0100Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.COMMERCIAL_OBJ)
      into w_misSummaryReport.chattogram_Annual
      from mis_audit_ob_disposal d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0100Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
    ------khulna--------
    select sum(d.COMMERCIAL_OBJ)
      into w_misSummaryReport.khulna_100DS
      from mis_audit_ob_disposal d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0200Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.COMMERCIAL_OBJ)
      into w_misSummaryReport.khulna_Annual
      from mis_audit_ob_disposal d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0200Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
    ----------rajshahi-----------
    select sum(d.COMMERCIAL_OBJ)
      into w_misSummaryReport.Rajshahi_100DS
      from mis_audit_ob_disposal d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0300Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.COMMERCIAL_OBJ)
      into w_misSummaryReport.Rajshahi_Annual
      from mis_audit_ob_disposal d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0300Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
  
    ----------sylhet-----------
    select sum(d.COMMERCIAL_OBJ)
      into w_misSummaryReport.Sylhet_100DS
      from mis_audit_ob_disposal d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0500Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.COMMERCIAL_OBJ)
      into w_misSummaryReport.Sylhet_Annual
      from mis_audit_ob_disposal d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0500Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
  
    ----------sylhet-----------
    select sum(d.COMMERCIAL_OBJ)
      into w_misSummaryReport.Barisal_100DS
      from mis_audit_ob_disposal d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0400Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.COMMERCIAL_OBJ)
      into w_misSummaryReport.Barisal_Annual
      from mis_audit_ob_disposal d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0400Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
  
    ----------Rangpur-----------
    select sum(d.COMMERCIAL_OBJ)
      into w_misSummaryReport.Rangpur_100DS
      from mis_audit_ob_disposal d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '5000Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.COMMERCIAL_OBJ)
      into w_misSummaryReport.Rangpur_Annual
      from mis_audit_ob_disposal d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '5000Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
    ----------Mymenshing-----------
    select sum(d.COMMERCIAL_OBJ)
      into w_misSummaryReport.Mymensing_100DS
      from mis_audit_ob_disposal d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '4000Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.COMMERCIAL_OBJ)
      into w_misSummaryReport.Mymensing_Annual
      from mis_audit_ob_disposal d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '4000Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
    ----------Faridpur-----------
    select sum(d.COMMERCIAL_OBJ)
      into w_misSummaryReport.Faridpur_100DS
      from mis_audit_ob_disposal d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '2001Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.COMMERCIAL_OBJ)
      into w_misSummaryReport.Faridpur_Annual
      from mis_audit_ob_disposal d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '2001Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
  
    pipe row(w_misSummaryReport);
  
    ----------------------post audit--------------------
  
    w_misSummaryReport.Operation_code       := '04';
    w_misSummaryReport.Operation_activities := 'Disposal of Audit Objections';
    w_misSummaryReport.subop_code           := '02';
    w_misSummaryReport.subop_activities     := 'Post Audit';
    w_misSummaryReport.description          := 'Target';
  
    ----------------Dhaka North-------------------
    SELECT sum(s.AUDIT_POST_AUDIT)
      into w_misSummaryReport.Dhaka_north_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0600Z');
  
    SELECT sum(s.AUDIT_POST_AUDIT)
      into w_misSummaryReport.Dhaka_North_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0600Z');
    ----------------Dhaka South-------------------
    SELECT sum(s.AUDIT_POST_AUDIT)
      into w_misSummaryReport.Dhaka_South_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0800Z');
  
    SELECT sum(s.AUDIT_POST_AUDIT)
      into w_misSummaryReport.Dhaka_South_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0800Z');
    -----------------Chattogram-------------------
    SELECT sum(s.AUDIT_POST_AUDIT)
      into w_misSummaryReport.chattogram_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0100Z');
  
    SELECT sum(s.AUDIT_POST_AUDIT)
      into w_misSummaryReport.chattogram_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0100Z');
    -----------------Khulna-----------------------
    SELECT sum(s.AUDIT_POST_AUDIT)
      into w_misSummaryReport.khulna_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0200Z');
  
    SELECT sum(s.AUDIT_POST_AUDIT)
      into w_misSummaryReport.khulna_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0200Z');
    ----------------Rajshahi---------------------
    SELECT sum(s.AUDIT_POST_AUDIT)
      into w_misSummaryReport.Rajshahi_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0300Z');
  
    SELECT sum(s.AUDIT_POST_AUDIT)
      into w_misSummaryReport.Rajshahi_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0300Z');
  
    ----------------Sylhet---------------------
    SELECT sum(s.AUDIT_POST_AUDIT)
      into w_misSummaryReport.Sylhet_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0500Z');
  
    SELECT sum(s.AUDIT_POST_AUDIT)
      into w_misSummaryReport.Sylhet_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0500Z');
    ----------------barisal---------------------
    SELECT sum(s.AUDIT_POST_AUDIT)
      into w_misSummaryReport.Barisal_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0400Z');
  
    SELECT sum(s.AUDIT_POST_AUDIT)
      into w_misSummaryReport.Barisal_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0400Z');
  
    ----------------Rangpur---------------------
    SELECT sum(s.AUDIT_POST_AUDIT)
      into w_misSummaryReport.Rangpur_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '5000Z');
  
    SELECT sum(s.AUDIT_POST_AUDIT)
      into w_misSummaryReport.Rangpur_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '5000Z');
  
    ----------------Mymensing---------------------
    SELECT sum(s.AUDIT_POST_AUDIT)
      into w_misSummaryReport.Mymensing_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '4000Z');
  
    SELECT sum(s.AUDIT_POST_AUDIT)
      into w_misSummaryReport.Mymensing_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '4000Z');
  
    ----------------Faridpur---------------------
    SELECT sum(s.AUDIT_POST_AUDIT)
      into w_misSummaryReport.Faridpur_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '2001Z');
  
    SELECT sum(s.AUDIT_POST_AUDIT)
      into w_misSummaryReport.Faridpur_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '2001Z');
  
    pipe row(w_misSummaryReport);
  
    w_misSummaryReport.description := 'Achievement';
    select sum(d.AUDIT_OBJ)
      into w_misSummaryReport.Dhaka_north_100DS
      from mis_audit_ob_disposal d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0600Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.AUDIT_OBJ)
      into w_misSummaryReport.Dhaka_North_Annual
      from mis_audit_ob_disposal d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0600Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
    ----dhaka south----------
    select sum(d.AUDIT_OBJ)
      into w_misSummaryReport.Dhaka_South_100DS
      from mis_audit_ob_disposal d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0800Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.AUDIT_OBJ)
      into w_misSummaryReport.Dhaka_South_Annual
      from mis_audit_ob_disposal d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0800Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
    ----chittaganj----------
    select sum(d.AUDIT_OBJ)
      into w_misSummaryReport.chattogram_100DS
      from mis_audit_ob_disposal d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0100Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.AUDIT_OBJ)
      into w_misSummaryReport.chattogram_Annual
      from mis_audit_ob_disposal d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0100Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
    ------khulna--------
    select sum(d.AUDIT_OBJ)
      into w_misSummaryReport.khulna_100DS
      from mis_audit_ob_disposal d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0200Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.AUDIT_OBJ)
      into w_misSummaryReport.khulna_Annual
      from mis_audit_ob_disposal d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0200Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
    ----------rajshahi-----------
    select sum(d.AUDIT_OBJ)
      into w_misSummaryReport.Rajshahi_100DS
      from mis_audit_ob_disposal d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0300Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.AUDIT_OBJ)
      into w_misSummaryReport.Rajshahi_Annual
      from mis_audit_ob_disposal d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0300Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
  
    ----------sylhet-----------
    select sum(d.AUDIT_OBJ)
      into w_misSummaryReport.Sylhet_100DS
      from mis_audit_ob_disposal d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0500Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.AUDIT_OBJ)
      into w_misSummaryReport.Sylhet_Annual
      from mis_audit_ob_disposal d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0500Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
  
    ----------sylhet-----------
    select sum(d.AUDIT_OBJ)
      into w_misSummaryReport.Barisal_100DS
      from mis_audit_ob_disposal d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0400Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.AUDIT_OBJ)
      into w_misSummaryReport.Barisal_Annual
      from mis_audit_ob_disposal d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0400Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
  
    ----------Rangpur-----------
    select sum(d.AUDIT_OBJ)
      into w_misSummaryReport.Rangpur_100DS
      from mis_audit_ob_disposal d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '5000Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.AUDIT_OBJ)
      into w_misSummaryReport.Rangpur_Annual
      from mis_audit_ob_disposal d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '5000Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
    ----------Mymenshing-----------
    select sum(d.AUDIT_OBJ)
      into w_misSummaryReport.Mymensing_100DS
      from mis_audit_ob_disposal d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '4000Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.AUDIT_OBJ)
      into w_misSummaryReport.Mymensing_Annual
      from mis_audit_ob_disposal d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '4000Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
    ----------Faridpur-----------
    select sum(d.AUDIT_OBJ)
      into w_misSummaryReport.Faridpur_100DS
      from mis_audit_ob_disposal d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '2001Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.AUDIT_OBJ)
      into w_misSummaryReport.Faridpur_Annual
      from mis_audit_ob_disposal d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '2001Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
  
    pipe row(w_misSummaryReport);
  
    w_misSummaryReport.Operation_code       := '05';
    w_misSummaryReport.Operation_activities := 'Kharidabari';
    w_misSummaryReport.subop_code           := '01';
    w_misSummaryReport.subop_activities     := 'Possession';
    w_misSummaryReport.description          := 'Target';
    ----------------Dhaka North-------------------
    SELECT sum(s.KHARIDABARI_PROCESSION)
      into w_misSummaryReport.Dhaka_north_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0600Z');
  
    SELECT sum(s.KHARIDABARI_PROCESSION)
      into w_misSummaryReport.Dhaka_North_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0600Z');
    ----------------Dhaka South-------------------
    SELECT sum(s.KHARIDABARI_PROCESSION)
      into w_misSummaryReport.Dhaka_South_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0800Z');
  
    SELECT sum(s.KHARIDABARI_PROCESSION)
      into w_misSummaryReport.Dhaka_South_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0800Z');
    -----------------Chattogram-------------------
    SELECT sum(s.KHARIDABARI_PROCESSION)
      into w_misSummaryReport.chattogram_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0100Z');
  
    SELECT sum(s.KHARIDABARI_PROCESSION)
      into w_misSummaryReport.chattogram_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0100Z');
    -----------------Khulna-----------------------
    SELECT sum(s.KHARIDABARI_PROCESSION)
      into w_misSummaryReport.khulna_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0200Z');
  
    SELECT sum(s.KHARIDABARI_PROCESSION)
      into w_misSummaryReport.khulna_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0200Z');
    ----------------Rajshahi---------------------
    SELECT sum(s.KHARIDABARI_PROCESSION)
      into w_misSummaryReport.Rajshahi_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0300Z');
  
    SELECT sum(s.KHARIDABARI_PROCESSION)
      into w_misSummaryReport.Rajshahi_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0300Z');
  
    ----------------Sylhet---------------------
    SELECT sum(s.KHARIDABARI_PROCESSION)
      into w_misSummaryReport.Sylhet_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0500Z');
  
    SELECT sum(s.KHARIDABARI_PROCESSION)
      into w_misSummaryReport.Sylhet_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0500Z');
    ----------------barisal---------------------
    SELECT sum(s.KHARIDABARI_PROCESSION)
      into w_misSummaryReport.Barisal_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0400Z');
  
    SELECT sum(s.KHARIDABARI_PROCESSION)
      into w_misSummaryReport.Barisal_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0400Z');
  
    ----------------Rangpur---------------------
    SELECT sum(s.KHARIDABARI_PROCESSION)
      into w_misSummaryReport.Rangpur_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '5000Z');
  
    SELECT sum(s.KHARIDABARI_PROCESSION)
      into w_misSummaryReport.Rangpur_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '5000Z');
  
    ----------------Mymensing---------------------
    SELECT sum(s.KHARIDABARI_PROCESSION)
      into w_misSummaryReport.Mymensing_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '4000Z');
  
    SELECT sum(s.KHARIDABARI_PROCESSION)
      into w_misSummaryReport.Mymensing_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '4000Z');
  
    ----------------Faridpur---------------------
    SELECT sum(s.KHARIDABARI_PROCESSION)
      into w_misSummaryReport.Faridpur_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '2001Z');
  
    SELECT sum(s.KHARIDABARI_PROCESSION)
      into w_misSummaryReport.Faridpur_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '2001Z');
  
    pipe row(w_misSummaryReport);
  
    w_misSummaryReport.description := 'Achievement';
    ----dhaka north----------
    select sum(d.PROCESSION)
      into w_misSummaryReport.Dhaka_north_100DS
      from mis_kharidabari d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0600Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.PROCESSION)
      into w_misSummaryReport.Dhaka_North_Annual
      from mis_kharidabari d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0600Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
    ----dhaka south----------
    select sum(d.PROCESSION)
      into w_misSummaryReport.Dhaka_South_100DS
      from mis_kharidabari d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0800Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.PROCESSION)
      into w_misSummaryReport.Dhaka_South_Annual
      from mis_kharidabari d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0800Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
    ----chittaganj----------
    select sum(d.PROCESSION)
      into w_misSummaryReport.chattogram_100DS
      from mis_kharidabari d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0100Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.PROCESSION)
      into w_misSummaryReport.chattogram_Annual
      from mis_kharidabari d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0100Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
    ------khulna--------
    select sum(d.PROCESSION)
      into w_misSummaryReport.khulna_100DS
      from mis_kharidabari d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0200Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.PROCESSION)
      into w_misSummaryReport.khulna_Annual
      from mis_kharidabari d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0200Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
    ----------rajshahi-----------
    select sum(d.PROCESSION)
      into w_misSummaryReport.Rajshahi_100DS
      from mis_kharidabari d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0300Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.PROCESSION)
      into w_misSummaryReport.Rajshahi_Annual
      from mis_kharidabari d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0300Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
  
    ----------sylhet-----------
    select sum(d.PROCESSION)
      into w_misSummaryReport.Sylhet_100DS
      from mis_kharidabari d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0500Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.PROCESSION)
      into w_misSummaryReport.Sylhet_Annual
      from mis_kharidabari d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0500Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
  
    ----------sylhet-----------
    select sum(d.PROCESSION)
      into w_misSummaryReport.Barisal_100DS
      from mis_kharidabari d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0400Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.PROCESSION)
      into w_misSummaryReport.Barisal_Annual
      from mis_kharidabari d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0400Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
  
    ----------Rangpur-----------
    select sum(d.PROCESSION)
      into w_misSummaryReport.Rangpur_100DS
      from mis_kharidabari d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '5000Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.PROCESSION)
      into w_misSummaryReport.Rangpur_Annual
      from mis_kharidabari d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '5000Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
    ----------Mymenshing-----------
    select sum(d.PROCESSION)
      into w_misSummaryReport.Mymensing_100DS
      from mis_kharidabari d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '4000Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.PROCESSION)
      into w_misSummaryReport.Mymensing_Annual
      from mis_kharidabari d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '4000Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
    ----------Faridpur-----------
    select sum(d.PROCESSION)
      into w_misSummaryReport.Faridpur_100DS
      from mis_kharidabari d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '2001Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.PROCESSION)
      into w_misSummaryReport.Faridpur_Annual
      from mis_kharidabari d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '2001Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
  
    pipe row(w_misSummaryReport);
  
    w_misSummaryReport.Operation_code       := '05';
    w_misSummaryReport.Operation_activities := 'Kharidabari';
    w_misSummaryReport.subop_code           := '02';
    w_misSummaryReport.subop_activities     := 'Sale';
    w_misSummaryReport.description          := 'Target';
    SELECT sum(s.KHARIDABARI_SALE)
      into w_misSummaryReport.Dhaka_north_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0600Z');
  
    SELECT sum(s.KHARIDABARI_SALE)
      into w_misSummaryReport.Dhaka_North_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0600Z');
    ----------------Dhaka South-------------------
    SELECT sum(s.KHARIDABARI_SALE)
      into w_misSummaryReport.Dhaka_South_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0800Z');
  
    SELECT sum(s.KHARIDABARI_SALE)
      into w_misSummaryReport.Dhaka_South_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0800Z');
    -----------------Chattogram-------------------
    SELECT sum(s.KHARIDABARI_SALE)
      into w_misSummaryReport.chattogram_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0100Z');
  
    SELECT sum(s.KHARIDABARI_SALE)
      into w_misSummaryReport.chattogram_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0100Z');
    -----------------Khulna-----------------------
    SELECT sum(s.KHARIDABARI_SALE)
      into w_misSummaryReport.khulna_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0200Z');
  
    SELECT sum(s.KHARIDABARI_SALE)
      into w_misSummaryReport.khulna_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0200Z');
    ----------------Rajshahi---------------------
    SELECT sum(s.KHARIDABARI_SALE)
      into w_misSummaryReport.Rajshahi_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0300Z');
  
    SELECT sum(s.KHARIDABARI_SALE)
      into w_misSummaryReport.Rajshahi_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0300Z');
  
    ----------------Sylhet---------------------
    SELECT sum(s.KHARIDABARI_SALE)
      into w_misSummaryReport.Sylhet_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0500Z');
  
    SELECT sum(s.KHARIDABARI_SALE)
      into w_misSummaryReport.Sylhet_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0500Z');
    ----------------barisal---------------------
    SELECT sum(s.KHARIDABARI_SALE)
      into w_misSummaryReport.Barisal_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0400Z');
  
    SELECT sum(s.KHARIDABARI_SALE)
      into w_misSummaryReport.Barisal_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0400Z');
  
    ----------------Rangpur---------------------
    SELECT sum(s.KHARIDABARI_SALE)
      into w_misSummaryReport.Rangpur_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '5000Z');
  
    SELECT sum(s.KHARIDABARI_SALE)
      into w_misSummaryReport.Rangpur_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '5000Z');
  
    ----------------Mymensing---------------------
    SELECT sum(s.KHARIDABARI_SALE)
      into w_misSummaryReport.Mymensing_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '4000Z');
  
    SELECT sum(s.KHARIDABARI_SALE)
      into w_misSummaryReport.Mymensing_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '4000Z');
  
    ----------------Faridpur---------------------
    SELECT sum(s.KHARIDABARI_SALE)
      into w_misSummaryReport.Faridpur_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '2001Z');
  
    SELECT sum(s.KHARIDABARI_SALE)
      into w_misSummaryReport.Faridpur_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '2001Z');
  
    pipe row(w_misSummaryReport);
  
    w_misSummaryReport.description := 'Achievement';
    select sum(d.SALE)
      into w_misSummaryReport.Dhaka_north_100DS
      from mis_kharidabari d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0600Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.SALE)
      into w_misSummaryReport.Dhaka_North_Annual
      from mis_kharidabari d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0600Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
    ----dhaka south----------
    select sum(d.SALE)
      into w_misSummaryReport.Dhaka_South_100DS
      from mis_kharidabari d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0800Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.SALE)
      into w_misSummaryReport.Dhaka_South_Annual
      from mis_kharidabari d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0800Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
    ----chittaganj----------
    select sum(d.SALE)
      into w_misSummaryReport.chattogram_100DS
      from mis_kharidabari d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0100Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.SALE)
      into w_misSummaryReport.chattogram_Annual
      from mis_kharidabari d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0100Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
    ------khulna--------
    select sum(d.SALE)
      into w_misSummaryReport.khulna_100DS
      from mis_kharidabari d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0200Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.SALE)
      into w_misSummaryReport.khulna_Annual
      from mis_kharidabari d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0200Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
    ----------rajshahi-----------
    select sum(d.SALE)
      into w_misSummaryReport.Rajshahi_100DS
      from mis_kharidabari d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0300Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.SALE)
      into w_misSummaryReport.Rajshahi_Annual
      from mis_kharidabari d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0300Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
  
    ----------sylhet-----------
    select sum(d.SALE)
      into w_misSummaryReport.Sylhet_100DS
      from mis_kharidabari d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0500Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.SALE)
      into w_misSummaryReport.Sylhet_Annual
      from mis_kharidabari d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0500Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
  
    ----------sylhet-----------
    select sum(d.SALE)
      into w_misSummaryReport.Barisal_100DS
      from mis_kharidabari d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0400Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.SALE)
      into w_misSummaryReport.Barisal_Annual
      from mis_kharidabari d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0400Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
  
    ----------Rangpur-----------
    select sum(d.SALE)
      into w_misSummaryReport.Rangpur_100DS
      from mis_kharidabari d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '5000Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.SALE)
      into w_misSummaryReport.Rangpur_Annual
      from mis_kharidabari d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '5000Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
    ----------Mymenshing-----------
    select sum(d.SALE)
      into w_misSummaryReport.Mymensing_100DS
      from mis_kharidabari d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '4000Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.SALE)
      into w_misSummaryReport.Mymensing_Annual
      from mis_kharidabari d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '4000Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
    ----------Faridpur-----------
    select sum(d.SALE)
      into w_misSummaryReport.Faridpur_100DS
      from mis_kharidabari d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '2001Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.SALE)
      into w_misSummaryReport.Faridpur_Annual
      from mis_kharidabari d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '2001Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
  
    pipe row(w_misSummaryReport);
  
    w_misSummaryReport.Operation_code       := '06';
    w_misSummaryReport.Operation_activities := 'Court Case Settlement';
    w_misSummaryReport.subop_code           := '01';
    w_misSummaryReport.subop_activities     := 'Misc. Case';
    w_misSummaryReport.description          := 'Target';
    SELECT sum(s.SETTLE_WRIT_CASE)
      into w_misSummaryReport.Dhaka_north_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0600Z');
  
    SELECT sum(s.SETTLE_WRIT_CASE)
      into w_misSummaryReport.Dhaka_North_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0600Z');
    ----------------Dhaka South-------------------
    SELECT sum(s.SETTLE_WRIT_CASE)
      into w_misSummaryReport.Dhaka_South_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0800Z');
  
    SELECT sum(s.SETTLE_WRIT_CASE)
      into w_misSummaryReport.Dhaka_South_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0800Z');
    -----------------Chattogram-------------------
    SELECT sum(s.SETTLE_WRIT_CASE)
      into w_misSummaryReport.chattogram_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0100Z');
  
    SELECT sum(s.SETTLE_WRIT_CASE)
      into w_misSummaryReport.chattogram_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0100Z');
    -----------------Khulna-----------------------
    SELECT sum(s.SETTLE_WRIT_CASE)
      into w_misSummaryReport.khulna_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0200Z');
  
    SELECT sum(s.SETTLE_WRIT_CASE)
      into w_misSummaryReport.khulna_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0200Z');
    ----------------Rajshahi---------------------
    SELECT sum(s.SETTLE_WRIT_CASE)
      into w_misSummaryReport.Rajshahi_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0300Z');
  
    SELECT sum(s.SETTLE_WRIT_CASE)
      into w_misSummaryReport.Rajshahi_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0300Z');
  
    ----------------Sylhet---------------------
    SELECT sum(s.SETTLE_WRIT_CASE)
      into w_misSummaryReport.Sylhet_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0500Z');
  
    SELECT sum(s.SETTLE_WRIT_CASE)
      into w_misSummaryReport.Sylhet_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0500Z');
    ----------------barisal---------------------
    SELECT sum(s.SETTLE_WRIT_CASE)
      into w_misSummaryReport.Barisal_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0400Z');
  
    SELECT sum(s.SETTLE_WRIT_CASE)
      into w_misSummaryReport.Barisal_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0400Z');
  
    ----------------Rangpur---------------------
    SELECT sum(s.SETTLE_WRIT_CASE)
      into w_misSummaryReport.Rangpur_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '5000Z');
  
    SELECT sum(s.SETTLE_WRIT_CASE)
      into w_misSummaryReport.Rangpur_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '5000Z');
  
    ----------------Mymensing---------------------
    SELECT sum(s.SETTLE_WRIT_CASE)
      into w_misSummaryReport.Mymensing_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '4000Z');
  
    SELECT sum(s.SETTLE_WRIT_CASE)
      into w_misSummaryReport.Mymensing_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '4000Z');
  
    ----------------Faridpur---------------------
    SELECT sum(s.SETTLE_WRIT_CASE)
      into w_misSummaryReport.Faridpur_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '2001Z');
  
    SELECT sum(s.SETTLE_WRIT_CASE)
      into w_misSummaryReport.Faridpur_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '2001Z');
  
    pipe row(w_misSummaryReport);
  
    w_misSummaryReport.description := 'Achievement';
    ----dhaka north----------
    select sum(d.MISC_CSE)
      into w_misSummaryReport.Dhaka_north_100DS
      from mis_court_case_settle d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0600Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.MISC_CSE)
      into w_misSummaryReport.Dhaka_North_Annual
      from mis_court_case_settle d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0600Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
    ----dhaka south----------
    select sum(d.MISC_CSE)
      into w_misSummaryReport.Dhaka_South_100DS
      from mis_court_case_settle d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0800Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.MISC_CSE)
      into w_misSummaryReport.Dhaka_South_Annual
      from mis_court_case_settle d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0800Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
    ----chittaganj----------
    select sum(d.MISC_CSE)
      into w_misSummaryReport.chattogram_100DS
      from mis_court_case_settle d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0100Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.MISC_CSE)
      into w_misSummaryReport.chattogram_Annual
      from mis_court_case_settle d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0100Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
    ------khulna--------
    select sum(d.MISC_CSE)
      into w_misSummaryReport.khulna_100DS
      from mis_court_case_settle d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0200Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.MISC_CSE)
      into w_misSummaryReport.khulna_Annual
      from mis_court_case_settle d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0200Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
    ----------rajshahi-----------
    select sum(d.MISC_CSE)
      into w_misSummaryReport.Rajshahi_100DS
      from mis_court_case_settle d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0300Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.MISC_CSE)
      into w_misSummaryReport.Rajshahi_Annual
      from mis_court_case_settle d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0300Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
  
    ----------sylhet-----------
    select sum(d.MISC_CSE)
      into w_misSummaryReport.Sylhet_100DS
      from mis_court_case_settle d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0500Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.MISC_CSE)
      into w_misSummaryReport.Sylhet_Annual
      from mis_court_case_settle d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0500Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
  
    ----------sylhet-----------
    select sum(d.MISC_CSE)
      into w_misSummaryReport.Barisal_100DS
      from mis_court_case_settle d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0400Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.MISC_CSE)
      into w_misSummaryReport.Barisal_Annual
      from mis_court_case_settle d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0400Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
  
    ----------Rangpur-----------
    select sum(d.MISC_CSE)
      into w_misSummaryReport.Rangpur_100DS
      from mis_court_case_settle d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '5000Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.MISC_CSE)
      into w_misSummaryReport.Rangpur_Annual
      from mis_court_case_settle d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '5000Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
    ----------Mymenshing-----------
    select sum(d.MISC_CSE)
      into w_misSummaryReport.Mymensing_100DS
      from mis_court_case_settle d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '4000Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.MISC_CSE)
      into w_misSummaryReport.Mymensing_Annual
      from mis_court_case_settle d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '4000Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
    ----------Faridpur-----------
    select sum(d.MISC_CSE)
      into w_misSummaryReport.Faridpur_100DS
      from mis_court_case_settle d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '2001Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.MISC_CSE)
      into w_misSummaryReport.Faridpur_Annual
      from mis_court_case_settle d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '2001Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
    pipe row(w_misSummaryReport);
  
    w_misSummaryReport.subop_code       := '02';
    w_misSummaryReport.subop_activities := 'Execution Case';
    w_misSummaryReport.description      := 'Target';
    SELECT sum(s.SETTLE_EXECUTIVE_CASE)
      into w_misSummaryReport.Dhaka_north_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0600Z');
  
    SELECT sum(s.SETTLE_EXECUTIVE_CASE)
      into w_misSummaryReport.Dhaka_North_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0600Z');
    ----------------Dhaka South-------------------
    SELECT sum(s.SETTLE_EXECUTIVE_CASE)
      into w_misSummaryReport.Dhaka_South_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0800Z');
  
    SELECT sum(s.SETTLE_EXECUTIVE_CASE)
      into w_misSummaryReport.Dhaka_South_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0800Z');
    -----------------Chattogram-------------------
    SELECT sum(s.SETTLE_EXECUTIVE_CASE)
      into w_misSummaryReport.chattogram_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0100Z');
  
    SELECT sum(s.SETTLE_EXECUTIVE_CASE)
      into w_misSummaryReport.chattogram_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0100Z');
    -----------------Khulna-----------------------
    SELECT sum(s.SETTLE_EXECUTIVE_CASE)
      into w_misSummaryReport.khulna_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0200Z');
  
    SELECT sum(s.SETTLE_EXECUTIVE_CASE)
      into w_misSummaryReport.khulna_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0200Z');
    ----------------Rajshahi---------------------
    SELECT sum(s.SETTLE_EXECUTIVE_CASE)
      into w_misSummaryReport.Rajshahi_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0300Z');
  
    SELECT sum(s.SETTLE_EXECUTIVE_CASE)
      into w_misSummaryReport.Rajshahi_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0300Z');
  
    ----------------Sylhet---------------------
    SELECT sum(s.SETTLE_EXECUTIVE_CASE)
      into w_misSummaryReport.Sylhet_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0500Z');
  
    SELECT sum(s.SETTLE_EXECUTIVE_CASE)
      into w_misSummaryReport.Sylhet_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0500Z');
    ----------------barisal---------------------
    SELECT sum(s.SETTLE_EXECUTIVE_CASE)
      into w_misSummaryReport.Barisal_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0400Z');
  
    SELECT sum(s.SETTLE_EXECUTIVE_CASE)
      into w_misSummaryReport.Barisal_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0400Z');
  
    ----------------Rangpur---------------------
    SELECT sum(s.SETTLE_EXECUTIVE_CASE)
      into w_misSummaryReport.Rangpur_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '5000Z');
  
    SELECT sum(s.SETTLE_EXECUTIVE_CASE)
      into w_misSummaryReport.Rangpur_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '5000Z');
  
    ----------------Mymensing---------------------
    SELECT sum(s.SETTLE_EXECUTIVE_CASE)
      into w_misSummaryReport.Mymensing_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '4000Z');
  
    SELECT sum(s.SETTLE_EXECUTIVE_CASE)
      into w_misSummaryReport.Mymensing_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '4000Z');
  
    ----------------Faridpur---------------------
    SELECT sum(s.SETTLE_EXECUTIVE_CASE)
      into w_misSummaryReport.Faridpur_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '2001Z');
  
    SELECT sum(s.SETTLE_EXECUTIVE_CASE)
      into w_misSummaryReport.Faridpur_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '2001Z');
    pipe row(w_misSummaryReport);
  
    w_misSummaryReport.description := 'Achievement';
    select sum(d.EXECUTIVE_CASE)
      into w_misSummaryReport.Dhaka_north_100DS
      from mis_court_case_settle d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0600Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.EXECUTIVE_CASE)
      into w_misSummaryReport.Dhaka_North_Annual
      from mis_court_case_settle d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0600Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
    ----dhaka south----------
    select sum(d.EXECUTIVE_CASE)
      into w_misSummaryReport.Dhaka_South_100DS
      from mis_court_case_settle d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0800Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.EXECUTIVE_CASE)
      into w_misSummaryReport.Dhaka_South_Annual
      from mis_court_case_settle d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0800Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
    ----chittaganj----------
    select sum(d.EXECUTIVE_CASE)
      into w_misSummaryReport.chattogram_100DS
      from mis_court_case_settle d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0100Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.EXECUTIVE_CASE)
      into w_misSummaryReport.chattogram_Annual
      from mis_court_case_settle d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0100Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
    ------khulna--------
    select sum(d.EXECUTIVE_CASE)
      into w_misSummaryReport.khulna_100DS
      from mis_court_case_settle d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0200Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.EXECUTIVE_CASE)
      into w_misSummaryReport.khulna_Annual
      from mis_court_case_settle d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0200Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
    ----------rajshahi-----------
    select sum(d.EXECUTIVE_CASE)
      into w_misSummaryReport.Rajshahi_100DS
      from mis_court_case_settle d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0300Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.EXECUTIVE_CASE)
      into w_misSummaryReport.Rajshahi_Annual
      from mis_court_case_settle d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0300Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
  
    ----------sylhet-----------
    select sum(d.EXECUTIVE_CASE)
      into w_misSummaryReport.Sylhet_100DS
      from mis_court_case_settle d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0500Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.EXECUTIVE_CASE)
      into w_misSummaryReport.Sylhet_Annual
      from mis_court_case_settle d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0500Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
  
    ----------sylhet-----------
    select sum(d.EXECUTIVE_CASE)
      into w_misSummaryReport.Barisal_100DS
      from mis_court_case_settle d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0400Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.EXECUTIVE_CASE)
      into w_misSummaryReport.Barisal_Annual
      from mis_court_case_settle d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0400Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
  
    ----------Rangpur-----------
    select sum(d.EXECUTIVE_CASE)
      into w_misSummaryReport.Rangpur_100DS
      from mis_court_case_settle d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '5000Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.EXECUTIVE_CASE)
      into w_misSummaryReport.Rangpur_Annual
      from mis_court_case_settle d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '5000Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
    ----------Mymenshing-----------
    select sum(d.EXECUTIVE_CASE)
      into w_misSummaryReport.Mymensing_100DS
      from mis_court_case_settle d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '4000Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.EXECUTIVE_CASE)
      into w_misSummaryReport.Mymensing_Annual
      from mis_court_case_settle d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '4000Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
    ----------Faridpur-----------
    select sum(d.EXECUTIVE_CASE)
      into w_misSummaryReport.Faridpur_100DS
      from mis_court_case_settle d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '2001Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.EXECUTIVE_CASE)
      into w_misSummaryReport.Faridpur_Annual
      from mis_court_case_settle d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '2001Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
  
    pipe row(w_misSummaryReport);
  
    w_misSummaryReport.Operation_code       := '07';
    w_misSummaryReport.Operation_activities := 'Deed return from faulty loan cases';
    w_misSummaryReport.subop_code           := '01';
    w_misSummaryReport.subop_activities     := 'Deed return';
    w_misSummaryReport.description          := 'Target';
  
    SELECT sum(s.DEED_RETURN_FL)
      into w_misSummaryReport.Dhaka_north_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0600Z');
  
    SELECT sum(s.DEED_RETURN_FL)
      into w_misSummaryReport.Dhaka_North_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0600Z');
    ----------------Dhaka South-------------------
    SELECT sum(s.DEED_RETURN_FL)
      into w_misSummaryReport.Dhaka_South_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0800Z');
  
    SELECT sum(s.DEED_RETURN_FL)
      into w_misSummaryReport.Dhaka_South_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0800Z');
    -----------------Chattogram-------------------
    SELECT sum(s.DEED_RETURN_FL)
      into w_misSummaryReport.chattogram_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0100Z');
  
    SELECT sum(s.DEED_RETURN_FL)
      into w_misSummaryReport.chattogram_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0100Z');
    -----------------Khulna-----------------------
    SELECT sum(s.DEED_RETURN_FL)
      into w_misSummaryReport.khulna_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0200Z');
  
    SELECT sum(s.DEED_RETURN_FL)
      into w_misSummaryReport.khulna_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0200Z');
    ----------------Rajshahi---------------------
    SELECT sum(s.DEED_RETURN_FL)
      into w_misSummaryReport.Rajshahi_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0300Z');
  
    SELECT sum(s.DEED_RETURN_FL)
      into w_misSummaryReport.Rajshahi_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0300Z');
  
    ----------------Sylhet---------------------
    SELECT sum(s.DEED_RETURN_FL)
      into w_misSummaryReport.Sylhet_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0500Z');
  
    SELECT sum(s.DEED_RETURN_FL)
      into w_misSummaryReport.Sylhet_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0500Z');
    ----------------barisal---------------------
    SELECT sum(s.DEED_RETURN_FL)
      into w_misSummaryReport.Barisal_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0400Z');
  
    SELECT sum(s.DEED_RETURN_FL)
      into w_misSummaryReport.Barisal_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0400Z');
  
    ----------------Rangpur---------------------
    SELECT sum(s.DEED_RETURN_FL)
      into w_misSummaryReport.Rangpur_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '5000Z');
  
    SELECT sum(s.DEED_RETURN_FL)
      into w_misSummaryReport.Rangpur_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '5000Z');
  
    ----------------Mymensing---------------------
    SELECT sum(s.DEED_RETURN_FL)
      into w_misSummaryReport.Mymensing_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '4000Z');
  
    SELECT sum(s.DEED_RETURN_FL)
      into w_misSummaryReport.Mymensing_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '4000Z');
  
    ----------------Faridpur---------------------
    SELECT sum(s.DEED_RETURN_FL)
      into w_misSummaryReport.Faridpur_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '2001Z');
  
    SELECT sum(s.DEED_RETURN_FL)
      into w_misSummaryReport.Faridpur_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '2001Z');
  
    pipe row(w_misSummaryReport);
  
    w_misSummaryReport.description := 'Achievement';
    select sum(d.LOAN_ACCOUNT_NO)
      into w_misSummaryReport.Dhaka_north_100DS
      from mis_faulty_ln_case d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0600Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.LOAN_ACCOUNT_NO)
      into w_misSummaryReport.Dhaka_North_Annual
      from mis_faulty_ln_case d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0600Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
    ----dhaka south----------
    select sum(d.LOAN_ACCOUNT_NO)
      into w_misSummaryReport.Dhaka_South_100DS
      from mis_faulty_ln_case d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0800Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.LOAN_ACCOUNT_NO)
      into w_misSummaryReport.Dhaka_South_Annual
      from mis_faulty_ln_case d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0800Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
    ----chittaganj----------
    select sum(d.LOAN_ACCOUNT_NO)
      into w_misSummaryReport.chattogram_100DS
      from mis_faulty_ln_case d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0100Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.LOAN_ACCOUNT_NO)
      into w_misSummaryReport.chattogram_Annual
      from mis_faulty_ln_case d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0100Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
    ------khulna--------
    select sum(d.LOAN_ACCOUNT_NO)
      into w_misSummaryReport.khulna_100DS
      from mis_faulty_ln_case d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0200Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.LOAN_ACCOUNT_NO)
      into w_misSummaryReport.khulna_Annual
      from mis_faulty_ln_case d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0200Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
    ----------rajshahi-----------
    select sum(d.LOAN_ACCOUNT_NO)
      into w_misSummaryReport.Rajshahi_100DS
      from mis_faulty_ln_case d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0300Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.LOAN_ACCOUNT_NO)
      into w_misSummaryReport.Rajshahi_Annual
      from mis_faulty_ln_case d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0300Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
  
    ----------sylhet-----------
    select sum(d.LOAN_ACCOUNT_NO)
      into w_misSummaryReport.Sylhet_100DS
      from mis_faulty_ln_case d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0500Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.LOAN_ACCOUNT_NO)
      into w_misSummaryReport.Sylhet_Annual
      from mis_faulty_ln_case d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0500Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
  
    ----------sylhet-----------
    select sum(d.LOAN_ACCOUNT_NO)
      into w_misSummaryReport.Barisal_100DS
      from mis_faulty_ln_case d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0400Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.LOAN_ACCOUNT_NO)
      into w_misSummaryReport.Barisal_Annual
      from mis_faulty_ln_case d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0400Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
  
    ----------Rangpur-----------
    select sum(d.LOAN_ACCOUNT_NO)
      into w_misSummaryReport.Rangpur_100DS
      from mis_faulty_ln_case d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '5000Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.LOAN_ACCOUNT_NO)
      into w_misSummaryReport.Rangpur_Annual
      from mis_faulty_ln_case d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '5000Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
    ----------Mymenshing-----------
    select sum(d.LOAN_ACCOUNT_NO)
      into w_misSummaryReport.Mymensing_100DS
      from mis_faulty_ln_case d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '4000Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.LOAN_ACCOUNT_NO)
      into w_misSummaryReport.Mymensing_Annual
      from mis_faulty_ln_case d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '4000Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
    ----------Faridpur-----------
    select sum(d.LOAN_ACCOUNT_NO)
      into w_misSummaryReport.Faridpur_100DS
      from mis_faulty_ln_case d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '2001Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.LOAN_ACCOUNT_NO)
      into w_misSummaryReport.Faridpur_Annual
      from mis_faulty_ln_case d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '2001Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
    pipe row(w_misSummaryReport);
  
  end fn_summary_report_others;
  function fn_summary_report(p_Branch in varchar2) return v_misSummaryReport
    pipelined is
    w_misSummaryReport misSummaryReport;
    v_Ann_start_date   date;
    v_ann_end_date     date;
    v_100Days_start    date;
    v_100Days_end      date;
  
  begin
  
    SELECT m.start_date, m.end_date
      into v_100Days_start, v_100Days_end
      FROM TARGET_MASTER m
     where m.target_code = '100DAYS';
  
    SELECT m.start_date, m.end_date
      into v_Ann_start_date, v_ann_end_date
      FROM TARGET_MASTER m
     where m.target_code = 'FY20-21';
  
    w_misSummaryReport.Operation_code       := '01';
    w_misSummaryReport.Operation_activities := 'Loan Sanction';
    w_misSummaryReport.subop_code           := '01';
    w_misSummaryReport.subop_activities     := 'Zero Equities';
    w_misSummaryReport.description          := 'Target';
    ----------------Dhaka North-------------------
    SELECT sum(s.zero_eq_sanction)
      into w_misSummaryReport.Dhaka_north_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0600Z');
  
    SELECT sum(s.zero_eq_sanction)
      into w_misSummaryReport.Dhaka_North_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0600Z');
    ----------------Dhaka South-------------------
    SELECT sum(s.zero_eq_sanction)
      into w_misSummaryReport.Dhaka_South_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0800Z');
  
    SELECT sum(s.zero_eq_sanction)
      into w_misSummaryReport.Dhaka_South_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0800Z');
    -----------------Chattogram-------------------
    SELECT sum(s.zero_eq_sanction)
      into w_misSummaryReport.chattogram_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0100Z');
  
    SELECT sum(s.zero_eq_sanction)
      into w_misSummaryReport.chattogram_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0100Z');
    -----------------Khulna-----------------------
    SELECT sum(s.zero_eq_sanction)
      into w_misSummaryReport.khulna_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0200Z');
  
    SELECT sum(s.zero_eq_sanction)
      into w_misSummaryReport.khulna_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0200Z');
    ----------------Rajshahi---------------------
    SELECT sum(s.zero_eq_sanction)
      into w_misSummaryReport.Rajshahi_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0300Z');
  
    SELECT sum(s.zero_eq_sanction)
      into w_misSummaryReport.Rajshahi_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0300Z');
  
    ----------------Sylhet---------------------
    SELECT sum(s.zero_eq_sanction)
      into w_misSummaryReport.Sylhet_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0500Z');
  
    SELECT sum(s.zero_eq_sanction)
      into w_misSummaryReport.Sylhet_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0500Z');
    ----------------barisal---------------------
    SELECT sum(s.zero_eq_sanction)
      into w_misSummaryReport.Barisal_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0400Z');
  
    SELECT sum(s.zero_eq_sanction)
      into w_misSummaryReport.Barisal_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0400Z');
  
    ----------------Rangpur---------------------
    SELECT sum(s.zero_eq_sanction)
      into w_misSummaryReport.Rangpur_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '5000Z');
  
    SELECT sum(s.zero_eq_sanction)
      into w_misSummaryReport.Rangpur_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '5000Z');
  
    ----------------Mymensing---------------------
    SELECT sum(s.zero_eq_sanction)
      into w_misSummaryReport.Mymensing_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '4000Z');
  
    SELECT sum(s.zero_eq_sanction)
      into w_misSummaryReport.Mymensing_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '4000Z');
  
    ----------------Faridpur---------------------
    SELECT sum(s.zero_eq_sanction)
      into w_misSummaryReport.Faridpur_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '2001Z');
  
    SELECT sum(s.zero_eq_sanction)
      into w_misSummaryReport.Faridpur_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '2001Z');
  
    pipe row(w_misSummaryReport);
  
    w_misSummaryReport.description := 'Achievement';
    ----dhaka north----------
    select sum(d.zero_eq_sanction_amt)
      into w_misSummaryReport.Dhaka_north_100DS
      from MIS_LOAN_SANCTION d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0600Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.zero_eq_sanction_amt)
      into w_misSummaryReport.Dhaka_North_Annual
      from MIS_LOAN_SANCTION d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0600Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
    ----dhaka south----------
    select sum(d.zero_eq_sanction_amt)
      into w_misSummaryReport.Dhaka_South_100DS
      from MIS_LOAN_SANCTION d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0800Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.zero_eq_sanction_amt)
      into w_misSummaryReport.Dhaka_South_Annual
      from MIS_LOAN_SANCTION d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0800Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
    ----chittaganj----------
    select sum(d.zero_eq_sanction_amt)
      into w_misSummaryReport.chattogram_100DS
      from MIS_LOAN_SANCTION d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0100Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.zero_eq_sanction_amt)
      into w_misSummaryReport.chattogram_Annual
      from MIS_LOAN_SANCTION d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0100Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
    ------khulna--------
    select sum(d.zero_eq_sanction_amt)
      into w_misSummaryReport.khulna_100DS
      from MIS_LOAN_SANCTION d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0200Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.zero_eq_sanction_amt)
      into w_misSummaryReport.khulna_Annual
      from MIS_LOAN_SANCTION d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0200Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
    ----------rajshahi-----------
    select sum(d.zero_eq_sanction_amt)
      into w_misSummaryReport.Rajshahi_100DS
      from MIS_LOAN_SANCTION d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0300Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.zero_eq_sanction_amt)
      into w_misSummaryReport.Rajshahi_Annual
      from MIS_LOAN_SANCTION d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0300Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
  
    ----------sylhet-----------
    select sum(d.zero_eq_sanction_amt)
      into w_misSummaryReport.Sylhet_100DS
      from MIS_LOAN_SANCTION d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0500Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.zero_eq_sanction_amt)
      into w_misSummaryReport.Sylhet_Annual
      from MIS_LOAN_SANCTION d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0500Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
  
    ----------sylhet-----------
    select sum(d.zero_eq_sanction_amt)
      into w_misSummaryReport.Barisal_100DS
      from MIS_LOAN_SANCTION d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0400Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.zero_eq_sanction_amt)
      into w_misSummaryReport.Barisal_Annual
      from MIS_LOAN_SANCTION d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0400Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
  
    ----------Rangpur-----------
    select sum(d.zero_eq_sanction_amt)
      into w_misSummaryReport.Rangpur_100DS
      from MIS_LOAN_SANCTION d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '5000Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.zero_eq_sanction_amt)
      into w_misSummaryReport.Rangpur_Annual
      from MIS_LOAN_SANCTION d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '5000Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
    ----------Mymenshing-----------
    select sum(d.zero_eq_sanction_amt)
      into w_misSummaryReport.Mymensing_100DS
      from MIS_LOAN_SANCTION d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '4000Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.zero_eq_sanction_amt)
      into w_misSummaryReport.Mymensing_Annual
      from MIS_LOAN_SANCTION d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '4000Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
    ----------Faridpur-----------
    select sum(d.zero_eq_sanction_amt)
      into w_misSummaryReport.Faridpur_100DS
      from MIS_LOAN_SANCTION d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '2001Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.zero_eq_sanction_amt)
      into w_misSummaryReport.Faridpur_Annual
      from MIS_LOAN_SANCTION d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '2001Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
  
    pipe row(w_misSummaryReport);
  
    ----------------------Others Product--------------------
  
    w_misSummaryReport.Operation_code       := '01';
    w_misSummaryReport.Operation_activities := 'Loan Sanction';
    w_misSummaryReport.subop_code           := '02';
    w_misSummaryReport.subop_activities     := 'Other Products';
    w_misSummaryReport.description          := 'Target';
  
    ----------------Dhaka North-------------------
    SELECT sum(s.OTHS_PD_SANCTION)
      into w_misSummaryReport.Dhaka_north_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0600Z');
  
    SELECT sum(s.OTHS_PD_SANCTION)
      into w_misSummaryReport.Dhaka_North_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0600Z');
    ----------------Dhaka South-------------------
    SELECT sum(s.OTHS_PD_SANCTION)
      into w_misSummaryReport.Dhaka_South_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0800Z');
  
    SELECT sum(s.OTHS_PD_SANCTION)
      into w_misSummaryReport.Dhaka_South_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0800Z');
    -----------------Chattogram-------------------
    SELECT sum(s.OTHS_PD_SANCTION)
      into w_misSummaryReport.chattogram_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0100Z');
  
    SELECT sum(s.OTHS_PD_SANCTION)
      into w_misSummaryReport.chattogram_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0100Z');
    -----------------Khulna-----------------------
    SELECT sum(s.OTHS_PD_SANCTION)
      into w_misSummaryReport.khulna_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0200Z');
  
    SELECT sum(s.OTHS_PD_SANCTION)
      into w_misSummaryReport.khulna_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0200Z');
    ----------------Rajshahi---------------------
    SELECT sum(s.OTHS_PD_SANCTION)
      into w_misSummaryReport.Rajshahi_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0300Z');
  
    SELECT sum(s.OTHS_PD_SANCTION)
      into w_misSummaryReport.Rajshahi_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0300Z');
  
    ----------------Sylhet---------------------
    SELECT sum(s.OTHS_PD_SANCTION)
      into w_misSummaryReport.Sylhet_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0500Z');
  
    SELECT sum(s.OTHS_PD_SANCTION)
      into w_misSummaryReport.Sylhet_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0500Z');
    ----------------barisal---------------------
    SELECT sum(s.OTHS_PD_SANCTION)
      into w_misSummaryReport.Barisal_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0400Z');
  
    SELECT sum(s.OTHS_PD_SANCTION)
      into w_misSummaryReport.Barisal_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0400Z');
  
    ----------------Rangpur---------------------
    SELECT sum(s.OTHS_PD_SANCTION)
      into w_misSummaryReport.Rangpur_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '5000Z');
  
    SELECT sum(s.OTHS_PD_SANCTION)
      into w_misSummaryReport.Rangpur_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '5000Z');
  
    ----------------Mymensing---------------------
    SELECT sum(s.OTHS_PD_SANCTION)
      into w_misSummaryReport.Mymensing_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '4000Z');
  
    SELECT sum(s.OTHS_PD_SANCTION)
      into w_misSummaryReport.Mymensing_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '4000Z');
  
    ----------------Faridpur---------------------
    SELECT sum(s.OTHS_PD_SANCTION)
      into w_misSummaryReport.Faridpur_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '2001Z');
  
    SELECT sum(s.OTHS_PD_SANCTION)
      into w_misSummaryReport.Faridpur_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '2001Z');
  
    pipe row(w_misSummaryReport);
  
    w_misSummaryReport.description := 'Achievement';
    ----dhaka north----------
    select sum(d.OTH_PRD_SANCTION_AMT)
      into w_misSummaryReport.Dhaka_north_100DS
      from MIS_LOAN_SANCTION d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0600Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.OTH_PRD_SANCTION_AMT)
      into w_misSummaryReport.Dhaka_North_Annual
      from MIS_LOAN_SANCTION d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0600Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
    ----dhaka south----------
    select sum(d.OTH_PRD_SANCTION_AMT)
      into w_misSummaryReport.Dhaka_South_100DS
      from MIS_LOAN_SANCTION d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0800Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.OTH_PRD_SANCTION_AMT)
      into w_misSummaryReport.Dhaka_South_Annual
      from MIS_LOAN_SANCTION d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0800Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
    ----chittaganj----------
    select sum(d.OTH_PRD_SANCTION_AMT)
      into w_misSummaryReport.chattogram_100DS
      from MIS_LOAN_SANCTION d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0100Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.OTH_PRD_SANCTION_AMT)
      into w_misSummaryReport.chattogram_Annual
      from MIS_LOAN_SANCTION d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0100Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
    ------khulna--------
    select sum(d.OTH_PRD_SANCTION_AMT)
      into w_misSummaryReport.khulna_100DS
      from MIS_LOAN_SANCTION d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0200Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.OTH_PRD_SANCTION_AMT)
      into w_misSummaryReport.khulna_Annual
      from MIS_LOAN_SANCTION d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0200Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
    ----------rajshahi-----------
    select sum(d.OTH_PRD_SANCTION_AMT)
      into w_misSummaryReport.Rajshahi_100DS
      from MIS_LOAN_SANCTION d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0300Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.OTH_PRD_SANCTION_AMT)
      into w_misSummaryReport.Rajshahi_Annual
      from MIS_LOAN_SANCTION d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0300Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
  
    ----------sylhet-----------
    select sum(d.OTH_PRD_SANCTION_AMT)
      into w_misSummaryReport.Sylhet_100DS
      from MIS_LOAN_SANCTION d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0500Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.OTH_PRD_SANCTION_AMT)
      into w_misSummaryReport.Sylhet_Annual
      from MIS_LOAN_SANCTION d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0500Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
  
    ----------sylhet-----------
    select sum(d.OTH_PRD_SANCTION_AMT)
      into w_misSummaryReport.Barisal_100DS
      from MIS_LOAN_SANCTION d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0400Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.OTH_PRD_SANCTION_AMT)
      into w_misSummaryReport.Barisal_Annual
      from MIS_LOAN_SANCTION d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0400Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
  
    ----------Rangpur-----------
    select sum(d.OTH_PRD_SANCTION_AMT)
      into w_misSummaryReport.Rangpur_100DS
      from MIS_LOAN_SANCTION d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '5000Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.OTH_PRD_SANCTION_AMT)
      into w_misSummaryReport.Rangpur_Annual
      from MIS_LOAN_SANCTION d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '5000Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
    ----------Mymenshing-----------
    select sum(d.OTH_PRD_SANCTION_AMT)
      into w_misSummaryReport.Mymensing_100DS
      from MIS_LOAN_SANCTION d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '4000Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.OTH_PRD_SANCTION_AMT)
      into w_misSummaryReport.Mymensing_Annual
      from MIS_LOAN_SANCTION d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '4000Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
    ----------Faridpur-----------
    select sum(d.OTH_PRD_SANCTION_AMT)
      into w_misSummaryReport.Faridpur_100DS
      from MIS_LOAN_SANCTION d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '2001Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.OTH_PRD_SANCTION_AMT)
      into w_misSummaryReport.Faridpur_Annual
      from MIS_LOAN_SANCTION d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '2001Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
  
    pipe row(w_misSummaryReport);
  
    w_misSummaryReport.Operation_code       := '02';
    w_misSummaryReport.Operation_activities := 'Loan Disburse';
    w_misSummaryReport.subop_code           := '01';
    w_misSummaryReport.subop_activities     := 'Zero Equities';
    w_misSummaryReport.description          := 'Target';
  
    ----------------Dhaka North-------------------
    SELECT sum(s.ZERO_EQ_DISBURSE)
      into w_misSummaryReport.Dhaka_north_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0600Z');
  
    SELECT sum(s.ZERO_EQ_DISBURSE)
      into w_misSummaryReport.Dhaka_North_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0600Z');
    ----------------Dhaka South-------------------
    SELECT sum(s.ZERO_EQ_DISBURSE)
      into w_misSummaryReport.Dhaka_South_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0800Z');
  
    SELECT sum(s.ZERO_EQ_DISBURSE)
      into w_misSummaryReport.Dhaka_South_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0800Z');
    -----------------Chattogram-------------------
    SELECT sum(s.ZERO_EQ_DISBURSE)
      into w_misSummaryReport.chattogram_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0100Z');
  
    SELECT sum(s.ZERO_EQ_DISBURSE)
      into w_misSummaryReport.chattogram_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0100Z');
    -----------------Khulna-----------------------
    SELECT sum(s.ZERO_EQ_DISBURSE)
      into w_misSummaryReport.khulna_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0200Z');
  
    SELECT sum(s.ZERO_EQ_DISBURSE)
      into w_misSummaryReport.khulna_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0200Z');
    ----------------Rajshahi---------------------
    SELECT sum(s.ZERO_EQ_DISBURSE)
      into w_misSummaryReport.Rajshahi_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0300Z');
  
    SELECT sum(s.ZERO_EQ_DISBURSE)
      into w_misSummaryReport.Rajshahi_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0300Z');
  
    ----------------Sylhet---------------------
    SELECT sum(s.ZERO_EQ_DISBURSE)
      into w_misSummaryReport.Sylhet_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0500Z');
  
    SELECT sum(s.ZERO_EQ_DISBURSE)
      into w_misSummaryReport.Sylhet_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0500Z');
    ----------------barisal---------------------
    SELECT sum(s.ZERO_EQ_DISBURSE)
      into w_misSummaryReport.Barisal_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0400Z');
  
    SELECT sum(s.ZERO_EQ_DISBURSE)
      into w_misSummaryReport.Barisal_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0400Z');
  
    ----------------Rangpur---------------------
    SELECT sum(s.ZERO_EQ_DISBURSE)
      into w_misSummaryReport.Rangpur_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '5000Z');
  
    SELECT sum(s.ZERO_EQ_DISBURSE)
      into w_misSummaryReport.Rangpur_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '5000Z');
  
    ----------------Mymensing---------------------
    SELECT sum(s.ZERO_EQ_DISBURSE)
      into w_misSummaryReport.Mymensing_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '4000Z');
  
    SELECT sum(s.ZERO_EQ_DISBURSE)
      into w_misSummaryReport.Mymensing_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '4000Z');
  
    ----------------Faridpur---------------------
    SELECT sum(s.ZERO_EQ_DISBURSE)
      into w_misSummaryReport.Faridpur_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '2001Z');
  
    SELECT sum(s.ZERO_EQ_DISBURSE)
      into w_misSummaryReport.Faridpur_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '2001Z');
  
    pipe row(w_misSummaryReport);
  
    w_misSummaryReport.description := 'Achievement';
  
    ----dhaka north----------
    select sum(d.zero_eq_disburse_amt)
      into w_misSummaryReport.Dhaka_north_100DS
      from mis_loan_sanction_disburse d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0600Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.zero_eq_disburse_amt)
      into w_misSummaryReport.Dhaka_North_Annual
      from mis_loan_sanction_disburse d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0600Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
    ----dhaka south----------
    select sum(d.zero_eq_disburse_amt)
      into w_misSummaryReport.Dhaka_South_100DS
      from mis_loan_sanction_disburse d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0800Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.zero_eq_disburse_amt)
      into w_misSummaryReport.Dhaka_South_Annual
      from mis_loan_sanction_disburse d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0800Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
    ----chittaganj----------
    select sum(d.zero_eq_disburse_amt)
      into w_misSummaryReport.chattogram_100DS
      from mis_loan_sanction_disburse d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0100Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.zero_eq_disburse_amt)
      into w_misSummaryReport.chattogram_Annual
      from mis_loan_sanction_disburse d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0100Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
    ------khulna--------
    select sum(d.zero_eq_disburse_amt)
      into w_misSummaryReport.khulna_100DS
      from mis_loan_sanction_disburse d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0200Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.zero_eq_disburse_amt)
      into w_misSummaryReport.khulna_Annual
      from mis_loan_sanction_disburse d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0200Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
    ----------rajshahi-----------
    select sum(d.zero_eq_disburse_amt)
      into w_misSummaryReport.Rajshahi_100DS
      from mis_loan_sanction_disburse d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0300Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.zero_eq_disburse_amt)
      into w_misSummaryReport.Rajshahi_Annual
      from mis_loan_sanction_disburse d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0300Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
  
    ----------sylhet-----------
    select sum(d.zero_eq_disburse_amt)
      into w_misSummaryReport.Sylhet_100DS
      from mis_loan_sanction_disburse d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0500Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.zero_eq_disburse_amt)
      into w_misSummaryReport.Sylhet_Annual
      from mis_loan_sanction_disburse d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0500Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
  
    ----------sylhet-----------
    select sum(d.zero_eq_disburse_amt)
      into w_misSummaryReport.Barisal_100DS
      from mis_loan_sanction_disburse d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0400Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.zero_eq_disburse_amt)
      into w_misSummaryReport.Barisal_Annual
      from mis_loan_sanction_disburse d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0400Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
  
    ----------Rangpur-----------
    select sum(d.zero_eq_disburse_amt)
      into w_misSummaryReport.Rangpur_100DS
      from mis_loan_sanction_disburse d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '5000Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.zero_eq_disburse_amt)
      into w_misSummaryReport.Rangpur_Annual
      from mis_loan_sanction_disburse d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '5000Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
    ----------Mymenshing-----------
    select sum(d.zero_eq_disburse_amt)
      into w_misSummaryReport.Mymensing_100DS
      from mis_loan_sanction_disburse d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '4000Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.zero_eq_disburse_amt)
      into w_misSummaryReport.Mymensing_Annual
      from mis_loan_sanction_disburse d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '4000Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
    ----------Faridpur-----------
    select sum(d.zero_eq_disburse_amt)
      into w_misSummaryReport.Faridpur_100DS
      from mis_loan_sanction_disburse d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '2001Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.zero_eq_disburse_amt)
      into w_misSummaryReport.Faridpur_Annual
      from mis_loan_sanction_disburse d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '2001Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
  
    pipe row(w_misSummaryReport);
  
    w_misSummaryReport.subop_code       := '02';
    w_misSummaryReport.subop_activities := 'Other Products';
    w_misSummaryReport.description      := 'Target';
  
    ----------------Dhaka North-------------------
    SELECT sum(s.OTHS_PD_DISBURSE)
      into w_misSummaryReport.Dhaka_north_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0600Z');
  
    SELECT sum(s.OTHS_PD_DISBURSE)
      into w_misSummaryReport.Dhaka_North_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0600Z');
    ----------------Dhaka South-------------------
    SELECT sum(s.OTHS_PD_DISBURSE)
      into w_misSummaryReport.Dhaka_South_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0800Z');
  
    SELECT sum(s.OTHS_PD_DISBURSE)
      into w_misSummaryReport.Dhaka_South_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0800Z');
    -----------------Chattogram-------------------
    SELECT sum(s.OTHS_PD_DISBURSE)
      into w_misSummaryReport.chattogram_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0100Z');
  
    SELECT sum(s.OTHS_PD_DISBURSE)
      into w_misSummaryReport.chattogram_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0100Z');
    -----------------Khulna-----------------------
    SELECT sum(s.OTHS_PD_DISBURSE)
      into w_misSummaryReport.khulna_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0200Z');
  
    SELECT sum(s.OTHS_PD_DISBURSE)
      into w_misSummaryReport.khulna_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0200Z');
    ----------------Rajshahi---------------------
    SELECT sum(s.OTHS_PD_DISBURSE)
      into w_misSummaryReport.Rajshahi_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0300Z');
  
    SELECT sum(s.OTHS_PD_DISBURSE)
      into w_misSummaryReport.Rajshahi_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0300Z');
  
    ----------------Sylhet---------------------
    SELECT sum(s.OTHS_PD_DISBURSE)
      into w_misSummaryReport.Sylhet_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0500Z');
  
    SELECT sum(s.OTHS_PD_DISBURSE)
      into w_misSummaryReport.Sylhet_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0500Z');
    ----------------barisal---------------------
    SELECT sum(s.OTHS_PD_DISBURSE)
      into w_misSummaryReport.Barisal_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0400Z');
  
    SELECT sum(s.OTHS_PD_DISBURSE)
      into w_misSummaryReport.Barisal_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0400Z');
  
    ----------------Rangpur---------------------
    SELECT sum(s.OTHS_PD_DISBURSE)
      into w_misSummaryReport.Rangpur_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '5000Z');
  
    SELECT sum(s.OTHS_PD_DISBURSE)
      into w_misSummaryReport.Rangpur_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '5000Z');
  
    ----------------Mymensing---------------------
    SELECT sum(s.OTHS_PD_DISBURSE)
      into w_misSummaryReport.Mymensing_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '4000Z');
  
    SELECT sum(s.OTHS_PD_DISBURSE)
      into w_misSummaryReport.Mymensing_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '4000Z');
  
    ----------------Faridpur---------------------
    SELECT sum(s.OTHS_PD_DISBURSE)
      into w_misSummaryReport.Faridpur_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '2001Z');
  
    SELECT sum(s.OTHS_PD_DISBURSE)
      into w_misSummaryReport.Faridpur_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '2001Z');
  
    pipe row(w_misSummaryReport);
  
    w_misSummaryReport.description := 'Achievement';
    ----dhaka north----------
    select sum(d.oth_prd_disburse_amt)
      into w_misSummaryReport.Dhaka_north_100DS
      from mis_loan_sanction_disburse d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0600Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.oth_prd_disburse_amt)
      into w_misSummaryReport.Dhaka_North_Annual
      from mis_loan_sanction_disburse d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0600Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
    ----dhaka south----------
    select sum(d.oth_prd_disburse_amt)
      into w_misSummaryReport.Dhaka_South_100DS
      from mis_loan_sanction_disburse d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0800Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.oth_prd_disburse_amt)
      into w_misSummaryReport.Dhaka_South_Annual
      from mis_loan_sanction_disburse d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0800Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
    ----chittaganj----------
    select sum(d.oth_prd_disburse_amt)
      into w_misSummaryReport.chattogram_100DS
      from mis_loan_sanction_disburse d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0100Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.oth_prd_disburse_amt)
      into w_misSummaryReport.chattogram_Annual
      from mis_loan_sanction_disburse d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0100Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
    ------khulna--------
    select sum(d.oth_prd_disburse_amt)
      into w_misSummaryReport.khulna_100DS
      from mis_loan_sanction_disburse d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0200Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.oth_prd_disburse_amt)
      into w_misSummaryReport.khulna_Annual
      from mis_loan_sanction_disburse d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0200Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
    ----------rajshahi-----------
    select sum(d.oth_prd_disburse_amt)
      into w_misSummaryReport.Rajshahi_100DS
      from mis_loan_sanction_disburse d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0300Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.oth_prd_disburse_amt)
      into w_misSummaryReport.Rajshahi_Annual
      from mis_loan_sanction_disburse d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0300Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
  
    ----------sylhet-----------
    select sum(d.oth_prd_disburse_amt)
      into w_misSummaryReport.Sylhet_100DS
      from mis_loan_sanction_disburse d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0500Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.oth_prd_disburse_amt)
      into w_misSummaryReport.Sylhet_Annual
      from mis_loan_sanction_disburse d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0500Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
  
    ----------sylhet-----------
    select sum(d.oth_prd_disburse_amt)
      into w_misSummaryReport.Barisal_100DS
      from mis_loan_sanction_disburse d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0400Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.oth_prd_disburse_amt)
      into w_misSummaryReport.Barisal_Annual
      from mis_loan_sanction_disburse d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0400Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
  
    ----------Rangpur-----------
    select sum(d.oth_prd_disburse_amt)
      into w_misSummaryReport.Rangpur_100DS
      from mis_loan_sanction_disburse d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '5000Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.oth_prd_disburse_amt)
      into w_misSummaryReport.Rangpur_Annual
      from mis_loan_sanction_disburse d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '5000Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
    ----------Mymenshing-----------
    select sum(d.oth_prd_disburse_amt)
      into w_misSummaryReport.Mymensing_100DS
      from mis_loan_sanction_disburse d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '4000Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.oth_prd_disburse_amt)
      into w_misSummaryReport.Mymensing_Annual
      from mis_loan_sanction_disburse d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '4000Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
    ----------Faridpur-----------
    select sum(d.oth_prd_disburse_amt)
      into w_misSummaryReport.Faridpur_100DS
      from mis_loan_sanction_disburse d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '2001Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.oth_prd_disburse_amt)
      into w_misSummaryReport.Faridpur_Annual
      from mis_loan_sanction_disburse d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '2001Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
  
    pipe row(w_misSummaryReport);
  
    w_misSummaryReport.Operation_code       := '03';
    w_misSummaryReport.Operation_activities := 'Loan Recovery';
    w_misSummaryReport.subop_code           := '01';
    w_misSummaryReport.subop_activities     := 'CL';
    w_misSummaryReport.description          := 'Target';
  
    ----------------Dhaka North-------------------
    SELECT sum(s.LOAN_CL_RECOVERY)
      into w_misSummaryReport.Dhaka_north_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0600Z');
  
    SELECT sum(s.LOAN_CL_RECOVERY)
      into w_misSummaryReport.Dhaka_North_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0600Z');
    ----------------Dhaka South-------------------
    SELECT sum(s.LOAN_CL_RECOVERY)
      into w_misSummaryReport.Dhaka_South_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0800Z');
  
    SELECT sum(s.LOAN_CL_RECOVERY)
      into w_misSummaryReport.Dhaka_South_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0800Z');
    -----------------Chattogram-------------------
    SELECT sum(s.LOAN_CL_RECOVERY)
      into w_misSummaryReport.chattogram_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0100Z');
  
    SELECT sum(s.LOAN_CL_RECOVERY)
      into w_misSummaryReport.chattogram_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0100Z');
    -----------------Khulna-----------------------
    SELECT sum(s.LOAN_CL_RECOVERY)
      into w_misSummaryReport.khulna_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0200Z');
  
    SELECT sum(s.LOAN_CL_RECOVERY)
      into w_misSummaryReport.khulna_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0200Z');
    ----------------Rajshahi---------------------
    SELECT sum(s.LOAN_CL_RECOVERY)
      into w_misSummaryReport.Rajshahi_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0300Z');
  
    SELECT sum(s.LOAN_CL_RECOVERY)
      into w_misSummaryReport.Rajshahi_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0300Z');
  
    ----------------Sylhet---------------------
    SELECT sum(s.LOAN_CL_RECOVERY)
      into w_misSummaryReport.Sylhet_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0500Z');
  
    SELECT sum(s.LOAN_CL_RECOVERY)
      into w_misSummaryReport.Sylhet_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0500Z');
    ----------------barisal---------------------
    SELECT sum(s.LOAN_CL_RECOVERY)
      into w_misSummaryReport.Barisal_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0400Z');
  
    SELECT sum(s.LOAN_CL_RECOVERY)
      into w_misSummaryReport.Barisal_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0400Z');
  
    ----------------Rangpur---------------------
    SELECT sum(s.LOAN_CL_RECOVERY)
      into w_misSummaryReport.Rangpur_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '5000Z');
  
    SELECT sum(s.LOAN_CL_RECOVERY)
      into w_misSummaryReport.Rangpur_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '5000Z');
  
    ----------------Mymensing---------------------
    SELECT sum(s.LOAN_CL_RECOVERY)
      into w_misSummaryReport.Mymensing_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '4000Z');
  
    SELECT sum(s.LOAN_CL_RECOVERY)
      into w_misSummaryReport.Mymensing_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '4000Z');
  
    ----------------Faridpur---------------------
    SELECT sum(s.LOAN_CL_RECOVERY)
      into w_misSummaryReport.Faridpur_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '2001Z');
  
    SELECT sum(s.LOAN_CL_RECOVERY)
      into w_misSummaryReport.Faridpur_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '2001Z');
  
    pipe row(w_misSummaryReport);
  
    w_misSummaryReport.description := 'Achievement';
    ----dhaka north----------
    select sum(d.CL_RECOVERY_AMT)
      into w_misSummaryReport.Dhaka_north_100DS
      from mis_loan_recovery d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0600Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.CL_RECOVERY_AMT)
      into w_misSummaryReport.Dhaka_North_Annual
      from mis_loan_recovery d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0600Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
    ----dhaka south----------
    select sum(d.CL_RECOVERY_AMT)
      into w_misSummaryReport.Dhaka_South_100DS
      from mis_loan_recovery d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0800Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.CL_RECOVERY_AMT)
      into w_misSummaryReport.Dhaka_South_Annual
      from mis_loan_recovery d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0800Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
    ----chittaganj----------
    select sum(d.CL_RECOVERY_AMT)
      into w_misSummaryReport.chattogram_100DS
      from mis_loan_recovery d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0100Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.CL_RECOVERY_AMT)
      into w_misSummaryReport.chattogram_Annual
      from mis_loan_recovery d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0100Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
    ------khulna--------
    select sum(d.CL_RECOVERY_AMT)
      into w_misSummaryReport.khulna_100DS
      from mis_loan_recovery d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0200Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.CL_RECOVERY_AMT)
      into w_misSummaryReport.khulna_Annual
      from mis_loan_recovery d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0200Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
    ----------rajshahi-----------
    select sum(d.CL_RECOVERY_AMT)
      into w_misSummaryReport.Rajshahi_100DS
      from mis_loan_recovery d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0300Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.CL_RECOVERY_AMT)
      into w_misSummaryReport.Rajshahi_Annual
      from mis_loan_recovery d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0300Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
  
    ----------sylhet-----------
    select sum(d.CL_RECOVERY_AMT)
      into w_misSummaryReport.Sylhet_100DS
      from mis_loan_recovery d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0500Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.CL_RECOVERY_AMT)
      into w_misSummaryReport.Sylhet_Annual
      from mis_loan_recovery d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0500Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
  
    ----------sylhet-----------
    select sum(d.CL_RECOVERY_AMT)
      into w_misSummaryReport.Barisal_100DS
      from mis_loan_recovery d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0400Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.CL_RECOVERY_AMT)
      into w_misSummaryReport.Barisal_Annual
      from mis_loan_recovery d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0400Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
  
    ----------Rangpur-----------
    select sum(d.CL_RECOVERY_AMT)
      into w_misSummaryReport.Rangpur_100DS
      from mis_loan_recovery d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '5000Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.CL_RECOVERY_AMT)
      into w_misSummaryReport.Rangpur_Annual
      from mis_loan_recovery d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '5000Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
    ----------Mymenshing-----------
    select sum(d.CL_RECOVERY_AMT)
      into w_misSummaryReport.Mymensing_100DS
      from mis_loan_recovery d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '4000Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.CL_RECOVERY_AMT)
      into w_misSummaryReport.Mymensing_Annual
      from mis_loan_recovery d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '4000Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
    ----------Faridpur-----------
    select sum(d.CL_RECOVERY_AMT)
      into w_misSummaryReport.Faridpur_100DS
      from mis_loan_recovery d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '2001Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.CL_RECOVERY_AMT)
      into w_misSummaryReport.Faridpur_Annual
      from mis_loan_recovery d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '2001Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
  
    pipe row(w_misSummaryReport);
  
    w_misSummaryReport.Operation_code       := '03';
    w_misSummaryReport.Operation_activities := 'Loan Recovery';
    w_misSummaryReport.subop_code           := '02';
    w_misSummaryReport.subop_activities     := 'UC';
    w_misSummaryReport.description          := 'Target';
  
    ----------------Dhaka North-------------------
    SELECT sum(s.LOAN_UC_RECOVERY)
      into w_misSummaryReport.Dhaka_north_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0600Z');
  
    SELECT sum(s.LOAN_UC_RECOVERY)
      into w_misSummaryReport.Dhaka_North_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0600Z');
    ----------------Dhaka South-------------------
    SELECT sum(s.LOAN_UC_RECOVERY)
      into w_misSummaryReport.Dhaka_South_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0800Z');
  
    SELECT sum(s.LOAN_UC_RECOVERY)
      into w_misSummaryReport.Dhaka_South_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0800Z');
    -----------------Chattogram-------------------
    SELECT sum(s.LOAN_UC_RECOVERY)
      into w_misSummaryReport.chattogram_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0100Z');
  
    SELECT sum(s.LOAN_UC_RECOVERY)
      into w_misSummaryReport.chattogram_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0100Z');
    -----------------Khulna-----------------------
    SELECT sum(s.LOAN_UC_RECOVERY)
      into w_misSummaryReport.khulna_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0200Z');
  
    SELECT sum(s.LOAN_UC_RECOVERY)
      into w_misSummaryReport.khulna_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0200Z');
    ----------------Rajshahi---------------------
    SELECT sum(s.LOAN_UC_RECOVERY)
      into w_misSummaryReport.Rajshahi_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0300Z');
  
    SELECT sum(s.LOAN_UC_RECOVERY)
      into w_misSummaryReport.Rajshahi_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0300Z');
  
    ----------------Sylhet---------------------
    SELECT sum(s.LOAN_UC_RECOVERY)
      into w_misSummaryReport.Sylhet_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0500Z');
  
    SELECT sum(s.LOAN_UC_RECOVERY)
      into w_misSummaryReport.Sylhet_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0500Z');
    ----------------barisal---------------------
    SELECT sum(s.LOAN_UC_RECOVERY)
      into w_misSummaryReport.Barisal_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0400Z');
  
    SELECT sum(s.LOAN_UC_RECOVERY)
      into w_misSummaryReport.Barisal_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0400Z');
  
    ----------------Rangpur---------------------
    SELECT sum(s.LOAN_UC_RECOVERY)
      into w_misSummaryReport.Rangpur_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '5000Z');
  
    SELECT sum(s.LOAN_UC_RECOVERY)
      into w_misSummaryReport.Rangpur_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '5000Z');
  
    ----------------Mymensing---------------------
    SELECT sum(s.LOAN_UC_RECOVERY)
      into w_misSummaryReport.Mymensing_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '4000Z');
  
    SELECT sum(s.LOAN_UC_RECOVERY)
      into w_misSummaryReport.Mymensing_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '4000Z');
  
    ----------------Faridpur---------------------
    SELECT sum(s.LOAN_UC_RECOVERY)
      into w_misSummaryReport.Faridpur_100DS
      FROM mis_goal_setup s
     where s.target_code = '100DAYS'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '2001Z');
  
    SELECT sum(s.LOAN_UC_RECOVERY)
      into w_misSummaryReport.Faridpur_Annual
      FROM mis_goal_setup s
     where s.target_code = 'FY20-21'
       and s.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '2001Z');
  
    pipe row(w_misSummaryReport);
  
    w_misSummaryReport.description := 'Achievement';
    ----dhaka north----------
    select sum(d.UC_RECOVERY_AMT)
      into w_misSummaryReport.Dhaka_north_100DS
      from mis_loan_recovery d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0600Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.UC_RECOVERY_AMT)
      into w_misSummaryReport.Dhaka_North_Annual
      from mis_loan_recovery d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0600Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
    ----dhaka south----------
    select sum(d.UC_RECOVERY_AMT)
      into w_misSummaryReport.Dhaka_South_100DS
      from mis_loan_recovery d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0800Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.UC_RECOVERY_AMT)
      into w_misSummaryReport.Dhaka_South_Annual
      from mis_loan_recovery d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0800Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
    ----chittaganj----------
    select sum(d.UC_RECOVERY_AMT)
      into w_misSummaryReport.chattogram_100DS
      from mis_loan_recovery d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0100Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.UC_RECOVERY_AMT)
      into w_misSummaryReport.chattogram_Annual
      from mis_loan_recovery d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0100Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
    ------khulna--------
    select sum(d.UC_RECOVERY_AMT)
      into w_misSummaryReport.khulna_100DS
      from mis_loan_recovery d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0200Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.UC_RECOVERY_AMT)
      into w_misSummaryReport.khulna_Annual
      from mis_loan_recovery d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0200Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
    ----------rajshahi-----------
    select sum(d.UC_RECOVERY_AMT)
      into w_misSummaryReport.Rajshahi_100DS
      from mis_loan_recovery d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0300Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.UC_RECOVERY_AMT)
      into w_misSummaryReport.Rajshahi_Annual
      from mis_loan_recovery d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0300Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
  
    ----------sylhet-----------
    select sum(d.UC_RECOVERY_AMT)
      into w_misSummaryReport.Sylhet_100DS
      from mis_loan_recovery d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0500Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.UC_RECOVERY_AMT)
      into w_misSummaryReport.Sylhet_Annual
      from mis_loan_recovery d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0500Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
  
    ----------sylhet-----------
    select sum(d.UC_RECOVERY_AMT)
      into w_misSummaryReport.Barisal_100DS
      from mis_loan_recovery d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0400Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.UC_RECOVERY_AMT)
      into w_misSummaryReport.Barisal_Annual
      from mis_loan_recovery d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '0400Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
  
    ----------Rangpur-----------
    select sum(d.UC_RECOVERY_AMT)
      into w_misSummaryReport.Rangpur_100DS
      from mis_loan_recovery d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '5000Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.UC_RECOVERY_AMT)
      into w_misSummaryReport.Rangpur_Annual
      from mis_loan_recovery d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '5000Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
    ----------Mymenshing-----------
    select sum(d.UC_RECOVERY_AMT)
      into w_misSummaryReport.Mymensing_100DS
      from mis_loan_recovery d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '4000Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.UC_RECOVERY_AMT)
      into w_misSummaryReport.Mymensing_Annual
      from mis_loan_recovery d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '4000Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
    ----------Faridpur-----------
    select sum(d.UC_RECOVERY_AMT)
      into w_misSummaryReport.Faridpur_100DS
      from mis_loan_recovery d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '2001Z')
       and d.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(d.UC_RECOVERY_AMT)
      into w_misSummaryReport.Faridpur_Annual
      from mis_loan_recovery d
     where d.branch_code in
           (SELECT m.branch_off_code
              FROM zonal_branch_mapping m
             where m.zonal_off_code = '2001Z')
       and d.entry_date between v_Ann_start_date and v_ann_end_date;
  
    pipe row(w_misSummaryReport);
  
  end fn_summary_report;

  function fn_summary_report_branch_new(p_Branch in varchar2)
    return V_misReportData
    pipelined is
    w_misReportData misReportData;
  
    v_Ann_start_date date;
    v_ann_end_date   date;
  
    v_100Days_start date;
    v_100Days_end   date;
  
  begin
  
    SELECT m.start_date, m.end_date
      into v_100Days_start, v_100Days_end
      FROM TARGET_MASTER m
     where m.target_code = '100DAYS';
  
    SELECT m.start_date, m.end_date
      into v_Ann_start_date, v_ann_end_date
      FROM TARGET_MASTER m
     where m.target_code = 'FY20-21';
  
    ------------sanction-----------------
    w_misReportData.Operation_code       := '01';
    w_misReportData.Operation_activities := 'Loan Sanction Amount';
  
    w_misReportData.subop_code       := '01';
    w_misReportData.subop_activities := 'Zero Equities';
  
    SELECT s.zero_eq_sanction / 10000000
      into w_misReportData.target_100Ds
      FROM mis_goal_setup s
     where s.branch_code = p_Branch
       and s.target_code = '100DAYS';
  
    SELECT s.zero_eq_sanction / 10000000
      into w_misReportData.target_Anual
      FROM mis_goal_setup s
     where s.branch_code = p_Branch
       and s.target_code = 'FY20-21';
  
    ---achivement----
  
    select sum(p.zero_eq_sanction_amt) / 10000000
      into w_misReportData.achivement_100Ds
      from mis_loan_sanction p
     where p.branch_code = p_Branch
       and p.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(p.zero_eq_sanction_amt) / 10000000
      into w_misReportData.achivement_anual
      from mis_loan_sanction p
     where p.branch_code = p_Branch
       and p.entry_date between v_Ann_start_date and v_ann_end_date;
  
    pipe row(w_misReportData);
  
    w_misReportData.subop_code       := '02';
    w_misReportData.subop_activities := 'others Products';
  
    SELECT s.oths_pd_sanction / 10000000
      into w_misReportData.target_100Ds
      FROM mis_goal_setup s
     where s.branch_code = p_Branch
       and s.target_code = '100DAYS';
  
    SELECT s.oths_pd_sanction / 10000000
      into w_misReportData.target_Anual
      FROM mis_goal_setup s
     where s.branch_code = p_Branch
       and s.target_code = 'FY20-21';
  
    select sum(p.oth_prd_sanction_amt) / 10000000 zero_eq_sanction_amt
      into w_misReportData.achivement_100Ds
      from MIS_LOAN_SANCTION p
     where p.branch_code = p_Branch
       and p.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(p.oth_prd_sanction_amt) / 10000000 zero_eq_sanction_amt
      into w_misReportData.achivement_anual
      from MIS_LOAN_SANCTION p
     where p.branch_code = p_Branch
       and p.entry_date between v_Ann_start_date and v_ann_end_date;
  
    pipe row(w_misReportData);
  
    ------------disburse-----------------
  
    w_misReportData.Operation_code       := '02';
    w_misReportData.Operation_activities := 'Loan Disburse Amount';
  
    w_misReportData.subop_code       := '01';
    w_misReportData.subop_activities := 'Zero Equities';
    ---target------
  
    SELECT s.zero_eq_disburse / 10000000
      into w_misReportData.target_100Ds
      FROM mis_goal_setup s
     where s.branch_code = p_Branch
       and s.target_code = '100DAYS';
  
    SELECT s.zero_eq_disburse / 10000000
      into w_misReportData.target_Anual
      FROM mis_goal_setup s
     where s.branch_code = p_Branch
       and s.target_code = 'FY20-21';
    ---------achivement-------------   
    select sum(p.zero_eq_disburse_amt) / 10000000 zero_eq_sanction_amt
      into w_misReportData.achivement_100Ds
      from mis_loan_sanction_disburse p
     where p.branch_code = p_Branch
       and p.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(p.zero_eq_disburse_amt) / 10000000 zero_eq_sanction_amt
      into w_misReportData.achivement_anual
      from mis_loan_sanction_disburse p
     where p.branch_code = p_Branch
       and p.entry_date between v_Ann_start_date and v_ann_end_date;
  
    pipe row(w_misReportData);
  
    w_misReportData.subop_code       := '02';
    w_misReportData.subop_activities := 'others Products';
  
    ---target------
  
    SELECT s.oths_pd_disburse / 10000000
      into w_misReportData.target_100Ds
      FROM mis_goal_setup s
     where s.branch_code = p_Branch
       and s.target_code = '100DAYS';
  
    SELECT s.oths_pd_disburse / 10000000
      into w_misReportData.target_Anual
      FROM mis_goal_setup s
     where s.branch_code = p_Branch
       and s.target_code = 'FY20-21';
    ---------achivement-------------   
    select round(sum(p.oth_prd_disburse_amt) / 10000000, 2) zero_eq_sanction_amt
      into w_misReportData.achivement_100Ds
      from mis_loan_sanction_disburse p
     where p.branch_code = p_Branch
       and p.entry_date between v_100Days_start and v_100Days_end;
  
    select round(sum(p.oth_prd_disburse_amt) / 10000000, 2) zero_eq_sanction_amt
      into w_misReportData.achivement_anual
      from mis_loan_sanction_disburse p
     where p.branch_code = p_Branch
       and p.entry_date between v_Ann_start_date and v_ann_end_date;
  
    pipe row(w_misReportData);
  
    --------------------recovery------------------
  
    w_misReportData.Operation_code       := '03';
    w_misReportData.Operation_activities := 'Loan Recovery Amount';
    w_misReportData.subop_code           := '01';
    w_misReportData.subop_activities     := 'Classified Loan Cases';
    ---target------
  
    SELECT s.loan_cl_recovery / 10000000
      into w_misReportData.target_100Ds
      FROM mis_goal_setup s
     where s.branch_code = p_Branch
       and s.target_code = '100DAYS';
  
    SELECT s.loan_cl_recovery / 10000000
      into w_misReportData.target_Anual
      FROM mis_goal_setup s
     where s.branch_code = p_Branch
       and s.target_code = 'FY20-21';
    ---------achivement-------------   
    select sum(p.cl_recovery_amt) / 10000000
      into w_misReportData.achivement_100Ds
      from mis_loan_recovery p
     where p.branch_code = p_Branch
       and p.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(p.cl_recovery_amt) / 10000000
      into w_misReportData.achivement_anual
      from mis_loan_recovery p
     where p.branch_code = p_Branch
       and p.entry_date between v_Ann_start_date and v_ann_end_date;
  
    pipe row(w_misReportData);
  
    w_misReportData.subop_code       := '02';
    w_misReportData.subop_activities := 'UN-Classified Loan Cases';
  
    ---target------
  
    SELECT s.loan_uc_recovery / 10000000
      into w_misReportData.target_100Ds
      FROM mis_goal_setup s
     where s.branch_code = p_Branch
       and s.target_code = '100DAYS';
  
    SELECT s.loan_uc_recovery / 10000000
      into w_misReportData.target_Anual
      FROM mis_goal_setup s
     where s.branch_code = p_Branch
       and s.target_code = 'FY20-21';
    ---------achivement-------------   
    select sum(p.uc_recovery_amt) / 10000000
      into w_misReportData.achivement_100Ds
      from mis_loan_recovery p
     where p.branch_code = p_Branch
       and p.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(p.uc_recovery_amt) / 10000000
      into w_misReportData.achivement_anual
      from mis_loan_recovery p
     where p.branch_code = p_Branch
       and p.entry_date between v_Ann_start_date and v_ann_end_date;
  
    pipe row(w_misReportData);
  
    ----------------------------audit-------------------
    w_misReportData.Operation_code       := '04';
    w_misReportData.Operation_activities := 'Disposal of Audit Objection';
    w_misReportData.subop_code           := '01';
    w_misReportData.subop_activities     := 'Commercial Audit';
  
    SELECT s.audit_commercial
      into w_misReportData.target_100Ds
      FROM mis_goal_setup s
     where s.branch_code = p_Branch
       and s.target_code = '100DAYS';
  
    SELECT s.audit_commercial
      into w_misReportData.target_Anual
      FROM mis_goal_setup s
     where s.branch_code = p_Branch
       and s.target_code = 'FY20-21';
    ---------achivement-------------   
    select sum(p.commercial_obj)
      into w_misReportData.achivement_100Ds
      from mis_audit_ob_disposal p
     where p.branch_code = p_Branch
       and p.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(p.commercial_obj)
      into w_misReportData.achivement_anual
      from mis_audit_ob_disposal p
     where p.branch_code = p_Branch
       and p.entry_date between v_Ann_start_date and v_ann_end_date;
  
    pipe row(w_misReportData);
  
    w_misReportData.subop_code       := '02';
    w_misReportData.subop_activities := 'Post Audit';
  
    SELECT s.audit_post_audit
      into w_misReportData.target_100Ds
      FROM mis_goal_setup s
     where s.branch_code = p_Branch
       and s.target_code = '100DAYS';
  
    SELECT s.audit_post_audit
      into w_misReportData.target_Anual
      FROM mis_goal_setup s
     where s.branch_code = p_Branch
       and s.target_code = 'FY20-21';
    ---------achivement-------------   
    select sum(p.audit_obj)
      into w_misReportData.achivement_100Ds
      from mis_audit_ob_disposal p
     where p.branch_code = p_Branch
       and p.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(p.audit_obj)
      into w_misReportData.achivement_anual
      from mis_audit_ob_disposal p
     where p.branch_code = p_Branch
       and p.entry_date between v_Ann_start_date and v_ann_end_date;
    pipe row(w_misReportData);
  
    --------------kharidabari----------------
    w_misReportData.Operation_code       := '05';
    w_misReportData.Operation_activities := 'Kharidabari';
    w_misReportData.subop_code           := '01';
    w_misReportData.subop_activities     := 'Possession';
  
    SELECT s.kharidabari_procession
      into w_misReportData.target_100Ds
      FROM mis_goal_setup s
     where s.branch_code = p_Branch
       and s.target_code = '100DAYS';
  
    SELECT s.kharidabari_procession
      into w_misReportData.target_Anual
      FROM mis_goal_setup s
     where s.branch_code = p_Branch
       and s.target_code = 'FY20-21';
    ---------achivement-------------   
    select sum(p.procession)
      into w_misReportData.achivement_100Ds
      from mis_kharidabari p
     where p.branch_code = p_Branch
       and p.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(p.procession)
      into w_misReportData.achivement_anual
      from mis_kharidabari p
     where p.branch_code = p_Branch
       and p.entry_date between v_Ann_start_date and v_ann_end_date;
    pipe row(w_misReportData);
  
    w_misReportData.subop_code       := '02';
    w_misReportData.subop_activities := 'Sale';
  
    SELECT s.kharidabari_sale
      into w_misReportData.target_100Ds
      FROM mis_goal_setup s
     where s.branch_code = p_Branch
       and s.target_code = '100DAYS';
  
    SELECT s.kharidabari_sale
      into w_misReportData.target_Anual
      FROM mis_goal_setup s
     where s.branch_code = p_Branch
       and s.target_code = 'FY20-21';
    ---------achivement-------------   
    select sum(p.sale)
      into w_misReportData.achivement_100Ds
      from mis_kharidabari p
     where p.branch_code = p_Branch
       and p.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(p.sale)
      into w_misReportData.achivement_anual
      from mis_kharidabari p
     where p.branch_code = p_Branch
       and p.entry_date between v_Ann_start_date and v_ann_end_date;
    pipe row(w_misReportData);
  
    -----------------------Court case Settlement-----------------------
  
    w_misReportData.Operation_code       := '06';
    w_misReportData.Operation_activities := 'Court case Settlement';
    w_misReportData.subop_code           := '01';
    w_misReportData.subop_activities     := 'Execution Case';
  
    SELECT s.settle_executive_case
      into w_misReportData.target_100Ds
      FROM mis_goal_setup s
     where s.branch_code = p_Branch
       and s.target_code = '100DAYS';
  
    SELECT s.settle_executive_case
      into w_misReportData.target_Anual
      FROM mis_goal_setup s
     where s.branch_code = p_Branch
       and s.target_code = 'FY20-21';
    ---------achivement-------------   
    select sum(p.executive_case)
      into w_misReportData.achivement_100Ds
      from mis_court_case_settle p
     where p.branch_code = p_Branch
       and p.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(p.executive_case)
      into w_misReportData.achivement_anual
      from mis_court_case_settle p
     where p.branch_code = p_Branch
       and p.entry_date between v_Ann_start_date and v_ann_end_date;
    pipe row(w_misReportData);
  
    w_misReportData.subop_code       := '02';
    w_misReportData.subop_activities := 'Miss Case';
  
    SELECT s.settle_writ_case
      into w_misReportData.target_100Ds
      FROM mis_goal_setup s
     where s.branch_code = p_Branch
       and s.target_code = '100DAYS';
  
    SELECT s.settle_writ_case
      into w_misReportData.target_Anual
      FROM mis_goal_setup s
     where s.branch_code = p_Branch
       and s.target_code = 'FY20-21';
    ---------achivement-------------   
    select sum(p.misc_cse)
      into w_misReportData.achivement_100Ds
      from mis_court_case_settle p
     where p.branch_code = p_Branch
       and p.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(p.misc_cse)
      into w_misReportData.achivement_anual
      from mis_court_case_settle p
     where p.branch_code = p_Branch
       and p.entry_date between v_Ann_start_date and v_ann_end_date;
    pipe row(w_misReportData);
    -----------------------Deed return from FL-----------------------
    w_misReportData.Operation_code       := '07';
    w_misReportData.Operation_activities := 'Deed return(Faulty)';
    w_misReportData.subop_code           := '01';
    w_misReportData.subop_activities     := 'Deed Return';
    SELECT s.deed_return_fl
      into w_misReportData.target_100Ds
      FROM mis_goal_setup s
     where s.branch_code = p_Branch
       and s.target_code = '100DAYS';
  
    SELECT s.deed_return_fl
      into w_misReportData.target_Anual
      FROM mis_goal_setup s
     where s.branch_code = p_Branch
       and s.target_code = 'FY20-21';
    ---------achivement-------------   
    select sum(p.loan_account_no)
      into w_misReportData.achivement_100Ds
      from mis_faulty_ln_case p
     where p.branch_code = p_Branch
       and p.entry_date between v_100Days_start and v_100Days_end;
  
    select sum(p.loan_account_no)
      into w_misReportData.achivement_anual
      from mis_faulty_ln_case p
     where p.branch_code = p_Branch
       and p.entry_date between v_Ann_start_date and v_ann_end_date;
    pipe row(w_misReportData);
  
  end fn_summary_report_branch_new;
  
  function fn_summary_report_branch(p_Branch    in varchar2)
    return V_misBranchData
    pipelined is
    w_misReportData misBranchData;
  begin
    FOR ID IN(SELECT * FROM zonal_branch_mapping m where m.zonal_off_code=p_Branch)LOOP
      w_misReportData.Zonal_code:=p_Branch;
      w_misReportData.branch_code:=ID.BRANCH_OFF_CODE;
      FOR IDX IN(SELECT * FROM table(pkg_mis_rpt.fn_summary_report_branch_new(ID.BRANCH_OFF_CODE)))LOOP
          w_misReportData.Operation_code:=IDX.OPERATION_CODE;
          w_misReportData.Operation_activities:=IDX.OPERATION_ACTIVITIES;
          w_misReportData.subop_code:=IDX.SUBOP_CODE;
          w_misReportData.subop_activities:=IDX.SUBOP_ACTIVITIES;
          w_misReportData.target_Anual:=IDX.TARGET_ANUAL;
          w_misReportData.target_100Ds:=IDX.TARGET_100DS;
          w_misReportData.achivement_anual:=IDX.ACHIVEMENT_ANUAL;
          w_misReportData.achivement_100Ds:=IDX.ACHIVEMENT_100DS;
      
     pipe row(w_misReportData);
    END LOOP;
    END LOOP;
      
   
  end fn_summary_report_branch;

  function fn_summary_mis return v_misSummaryReport
    pipelined is
    w_misSummaryReport misSummaryReport;
  
  begin
    FOR index1 IN 1 .. 3 LOOP
      FOR index2 IN 1 .. 2 LOOP
        for id in (SELECT OPERATION_CODE,
                          OPERATION_ACTIVITIES,
                          SUBOP_CODE,
                          SUBOP_ACTIVITIES,
                          DESCRIPTION,
                          round(nvl(DHAKA_NORTH_100DS, 0) / 10000000, 2) DHAKA_NORTH_100DS,
                          round(nvl(DHAKA_NORTH_ANNUAL, 0) / 10000000, 2) DHAKA_NORTH_ANNUAL,
                          round(nvl(DHAKA_SOUTH_100DS, 0) / 10000000, 2) DHAKA_SOUTH_100DS,
                          round(nvl(DHAKA_SOUTH_ANNUAL, 0) / 10000000, 2) DHAKA_SOUTH_ANNUAL,
                          round(nvl(CHATTOGRAM_100DS, 0) / 10000000, 2) CHATTOGRAM_100DS,
                          round(nvl(CHATTOGRAM_ANNUAL, 0) / 10000000, 2) CHATTOGRAM_ANNUAL,
                          round(nvl(KHULNA_100DS, 0) / 10000000, 2) KHULNA_100DS,
                          round(nvl(KHULNA_ANNUAL, 0) / 10000000, 2) KHULNA_ANNUAL,
                          round(nvl(RAJSHAHI_100DS, 0) / 10000000, 2) RAJSHAHI_100DS,
                          round(nvl(RAJSHAHI_ANNUAL, 0) / 10000000, 2) RAJSHAHI_ANNUAL,
                          round(nvl(SYLHET_100DS, 0) / 10000000, 2) SYLHET_100DS,
                          round(nvl(SYLHET_ANNUAL, 0) / 10000000, 2) SYLHET_ANNUAL,
                          round(nvl(BARISAL_100DS, 0) / 10000000, 2) BARISAL_100DS,
                          round(nvl(BARISAL_ANNUAL, 0) / 10000000, 2) BARISAL_ANNUAL,
                          round(nvl(RANGPUR_100DS, 0) / 10000000, 2) RANGPUR_100DS,
                          round(nvl(RANGPUR_ANNUAL, 0) / 10000000, 2) RANGPUR_ANNUAL,
                          round(nvl(MYMENSING_100DS, 0) / 10000000, 2) MYMENSING_100DS,
                          round(nvl(MYMENSING_ANNUAL, 0) / 10000000, 2) MYMENSING_ANNUAL,
                          round(nvl(FARIDPUR_100DS, 0) / 10000000, 2) FARIDPUR_100DS,
                          round(nvl(FARIDPUR_ANNUAL, 0) / 10000000, 2) FARIDPUR_ANNUAL
                     FROM table(pkg_mis_rpt.fn_summary_report(''))
                    where OPERATION_CODE = index1
                      and SUBOP_CODE = index2) loop
        
          w_misSummaryReport.OPERATION_CODE       := id.OPERATION_CODE;
          w_misSummaryReport.OPERATION_ACTIVITIES := id.OPERATION_ACTIVITIES;
          w_misSummaryReport.SUBOP_CODE           := id.SUBOP_CODE;
          w_misSummaryReport.SUBOP_ACTIVITIES     := id.SUBOP_ACTIVITIES;
          w_misSummaryReport.DESCRIPTION          := id.DESCRIPTION;
          w_misSummaryReport.DHAKA_NORTH_100DS    := id.DHAKA_NORTH_100DS;
          w_misSummaryReport.DHAKA_NORTH_ANNUAL   := id.DHAKA_NORTH_ANNUAL;
          w_misSummaryReport.DHAKA_SOUTH_100DS    := id.DHAKA_SOUTH_100DS;
          w_misSummaryReport.DHAKA_SOUTH_ANNUAL   := id.DHAKA_SOUTH_ANNUAL;
          w_misSummaryReport.CHATTOGRAM_100DS     := id.CHATTOGRAM_100DS;
          w_misSummaryReport.CHATTOGRAM_ANNUAL    := id.CHATTOGRAM_ANNUAL;
          w_misSummaryReport.KHULNA_100DS         := id.KHULNA_100DS;
          w_misSummaryReport.KHULNA_ANNUAL        := id.KHULNA_ANNUAL;
          w_misSummaryReport.RAJSHAHI_100DS       := id.RAJSHAHI_100DS;
          w_misSummaryReport.RAJSHAHI_ANNUAL      := id.RAJSHAHI_ANNUAL;
          w_misSummaryReport.SYLHET_100DS         := id.SYLHET_100DS;
          w_misSummaryReport.SYLHET_ANNUAL        := id.SYLHET_ANNUAL;
          w_misSummaryReport.BARISAL_100DS        := id.BARISAL_100DS;
          w_misSummaryReport.BARISAL_ANNUAL       := id.BARISAL_ANNUAL;
          w_misSummaryReport.RANGPUR_100DS        := id.RANGPUR_100DS;
          w_misSummaryReport.RANGPUR_ANNUAL       := id.RANGPUR_ANNUAL;
          w_misSummaryReport.MYMENSING_100DS      := id.MYMENSING_100DS;
          w_misSummaryReport.MYMENSING_ANNUAL     := id.MYMENSING_ANNUAL;
          w_misSummaryReport.FARIDPUR_100DS       := id.FARIDPUR_100DS;
          w_misSummaryReport.FARIDPUR_ANNUAL      := id.FARIDPUR_ANNUAL;
          w_misSummaryReport.total_100days        := id.DHAKA_NORTH_100DS +
                                                     id.DHAKA_SOUTH_100DS +
                                                     id.CHATTOGRAM_100DS +
                                                     id.KHULNA_100DS +
                                                     id.RAJSHAHI_100DS +
                                                     id.SYLHET_100DS +
                                                     id.BARISAL_100DS +
                                                     id.RANGPUR_100DS +
                                                     id.MYMENSING_100DS +
                                                     id.FARIDPUR_100DS;
          w_misSummaryReport.total_Annual         := id.DHAKA_NORTH_ANNUAL + id.
                                                     DHAKA_SOUTH_ANNUAL +
                                                     id.CHATTOGRAM_ANNUAL +
                                                     id.KHULNA_ANNUAL +
                                                     id.RAJSHAHI_ANNUAL +
                                                     id.SYLHET_ANNUAL +
                                                     id.BARISAL_ANNUAL +
                                                     id.RANGPUR_ANNUAL +
                                                     id.MYMENSING_ANNUAL +
                                                     id.FARIDPUR_ANNUAL;
          pipe row(w_misSummaryReport);
        end loop;
      
        w_misSummaryReport.DESCRIPTION := 'Achievement(%)';
      
        SELECT ((SELECT DHAKA_NORTH_100DS
                   FROM table(pkg_mis_rpt.fn_summary_report(''))
                  where OPERATION_CODE = index1
                    and SUBOP_CODE = index2
                    and DESCRIPTION = 'Achievement') * 100 /
               (SELECT case DHAKA_NORTH_100DS
                          when 0 then
                           1
                          else
                           DHAKA_NORTH_100DS
                        end
                   FROM table(pkg_mis_rpt.fn_summary_report(''))
                  where OPERATION_CODE = index1
                    and SUBOP_CODE = index2
                    and DESCRIPTION = 'Target')) DHAKA_NORTH_100DS,
               
               ((SELECT DHAKA_NORTH_ANNUAL
                   FROM table(pkg_mis_rpt.fn_summary_report(''))
                  where OPERATION_CODE = index1
                    and SUBOP_CODE = index2
                    and DESCRIPTION = 'Achievement') * 100 /
               (SELECT case DHAKA_NORTH_ANNUAL
                          when 0 then
                           1
                          else
                           DHAKA_NORTH_ANNUAL
                        end
                   FROM table(pkg_mis_rpt.fn_summary_report(''))
                  where OPERATION_CODE = index1
                    and SUBOP_CODE = index2
                    and DESCRIPTION = 'Target')) DHAKA_NORTH_ANNUAL,
               ((SELECT DHAKA_SOUTH_100DS
                   FROM table(pkg_mis_rpt.fn_summary_report(''))
                  where OPERATION_CODE = index1
                    and SUBOP_CODE = index2
                    and DESCRIPTION = 'Achievement') * 100 /
               (SELECT case DHAKA_SOUTH_100DS
                          when 0 then
                           1
                          else
                           DHAKA_SOUTH_100DS
                        end
                   FROM table(pkg_mis_rpt.fn_summary_report(''))
                  where OPERATION_CODE = index1
                    and SUBOP_CODE = index2
                    and DESCRIPTION = 'Target')) DHAKA_SOUTH_100DS,
               
               ((SELECT DHAKA_SOUTH_ANNUAL
                   FROM table(pkg_mis_rpt.fn_summary_report(''))
                  where OPERATION_CODE = index1
                    and SUBOP_CODE = index2
                    and DESCRIPTION = 'Achievement') * 100 /
               (SELECT case DHAKA_SOUTH_ANNUAL
                          when 0 then
                           1
                          else
                           DHAKA_SOUTH_ANNUAL
                        end
                   FROM table(pkg_mis_rpt.fn_summary_report(''))
                  where OPERATION_CODE = index1
                    and SUBOP_CODE = index2
                    and DESCRIPTION = 'Target')) DHAKA_SOUTH_ANNUAL,
               
               ((SELECT CHATTOGRAM_100DS
                   FROM table(pkg_mis_rpt.fn_summary_report(''))
                  where OPERATION_CODE = index1
                    and SUBOP_CODE = index2
                    and DESCRIPTION = 'Achievement') * 100 /
               (SELECT case CHATTOGRAM_100DS
                          when 0 then
                           1
                          else
                           CHATTOGRAM_100DS
                        end
                   FROM table(pkg_mis_rpt.fn_summary_report(''))
                  where OPERATION_CODE = index1
                    and SUBOP_CODE = index2
                    and DESCRIPTION = 'Target')) CHATTOGRAM_100DS,
               
               ((SELECT CHATTOGRAM_ANNUAL
                   FROM table(pkg_mis_rpt.fn_summary_report(''))
                  where OPERATION_CODE = index1
                    and SUBOP_CODE = index2
                    and DESCRIPTION = 'Achievement') * 100 /
               (SELECT case CHATTOGRAM_ANNUAL
                          when 0 then
                           1
                          else
                           CHATTOGRAM_ANNUAL
                        end
                   FROM table(pkg_mis_rpt.fn_summary_report(''))
                  where OPERATION_CODE = index1
                    and SUBOP_CODE = index2
                    and DESCRIPTION = 'Target')) CHATTOGRAM_ANNUAL,
               
               ((SELECT KHULNA_100DS
                   FROM table(pkg_mis_rpt.fn_summary_report(''))
                  where OPERATION_CODE = index1
                    and SUBOP_CODE = index2
                    and DESCRIPTION = 'Achievement') * 100 /
               (SELECT case KHULNA_100DS
                          when 0 then
                           1
                          else
                           KHULNA_100DS
                        end
                   FROM table(pkg_mis_rpt.fn_summary_report(''))
                  where OPERATION_CODE = index1
                    and SUBOP_CODE = index2
                    and DESCRIPTION = 'Target')) KHULNA_100DS,
               
               ((SELECT KHULNA_ANNUAL
                   FROM table(pkg_mis_rpt.fn_summary_report(''))
                  where OPERATION_CODE = index1
                    and SUBOP_CODE = index2
                    and DESCRIPTION = 'Achievement') * 100 /
               (SELECT case KHULNA_ANNUAL
                          when 0 then
                           1
                          else
                           KHULNA_ANNUAL
                        end
                   FROM table(pkg_mis_rpt.fn_summary_report(''))
                  where OPERATION_CODE = index1
                    and SUBOP_CODE = index2
                    and DESCRIPTION = 'Target')) KHULNA_ANNUAL,
               
               ((SELECT RAJSHAHI_100DS
                   FROM table(pkg_mis_rpt.fn_summary_report(''))
                  where OPERATION_CODE = index1
                    and SUBOP_CODE = index2
                    and DESCRIPTION = 'Achievement') * 100 /
               (SELECT case RAJSHAHI_100DS
                          when 0 then
                           1
                          else
                           RAJSHAHI_100DS
                        end
                   FROM table(pkg_mis_rpt.fn_summary_report(''))
                  where OPERATION_CODE = index1
                    and SUBOP_CODE = index2
                    and DESCRIPTION = 'Target')) RAJSHAHI_100DS,
               
               ((SELECT RAJSHAHI_ANNUAL
                   FROM table(pkg_mis_rpt.fn_summary_report(''))
                  where OPERATION_CODE = index1
                    and SUBOP_CODE = index2
                    and DESCRIPTION = 'Achievement') * 100 /
               (SELECT case RAJSHAHI_ANNUAL
                          when 0 then
                           1
                          else
                           RAJSHAHI_ANNUAL
                        end
                   FROM table(pkg_mis_rpt.fn_summary_report(''))
                  where OPERATION_CODE = index1
                    and SUBOP_CODE = index2
                    and DESCRIPTION = 'Target')) RAJSHAHI_ANNUAL,
               
               ((SELECT SYLHET_100DS
                   FROM table(pkg_mis_rpt.fn_summary_report(''))
                  where OPERATION_CODE = index1
                    and SUBOP_CODE = index2
                    and DESCRIPTION = 'Achievement') * 100 /
               (SELECT case SYLHET_100DS
                          when 0 then
                           1
                          else
                           SYLHET_100DS
                        end
                   FROM table(pkg_mis_rpt.fn_summary_report(''))
                  where OPERATION_CODE = index1
                    and SUBOP_CODE = index2
                    and DESCRIPTION = 'Target')) SYLHET_100DS,
               
               ((SELECT SYLHET_ANNUAL
                   FROM table(pkg_mis_rpt.fn_summary_report(''))
                  where OPERATION_CODE = index1
                    and SUBOP_CODE = index2
                    and DESCRIPTION = 'Achievement') * 100 /
               (SELECT case SYLHET_ANNUAL
                          when 0 then
                           1
                          else
                           SYLHET_ANNUAL
                        end
                   FROM table(pkg_mis_rpt.fn_summary_report(''))
                  where OPERATION_CODE = index1
                    and SUBOP_CODE = index2
                    and DESCRIPTION = 'Target')) SYLHET_ANNUAL,
               ((SELECT BARISAL_100DS
                   FROM table(pkg_mis_rpt.fn_summary_report(''))
                  where OPERATION_CODE = index1
                    and SUBOP_CODE = index2
                    and DESCRIPTION = 'Achievement') * 100 /
               (SELECT case BARISAL_100DS
                          when 0 then
                           1
                          else
                           BARISAL_100DS
                        end
                   FROM table(pkg_mis_rpt.fn_summary_report(''))
                  where OPERATION_CODE = index1
                    and SUBOP_CODE = index2
                    and DESCRIPTION = 'Target')) BARISAL_100DS,
               
               ((SELECT BARISAL_ANNUAL
                   FROM table(pkg_mis_rpt.fn_summary_report(''))
                  where OPERATION_CODE = index1
                    and SUBOP_CODE = index2
                    and DESCRIPTION = 'Achievement') * 100 /
               (SELECT case BARISAL_ANNUAL
                          when 0 then
                           1
                          else
                           BARISAL_ANNUAL
                        end
                   FROM table(pkg_mis_rpt.fn_summary_report(''))
                  where OPERATION_CODE = index1
                    and SUBOP_CODE = index2
                    and DESCRIPTION = 'Target')) BARISAL_ANNUAL,
               
               ((SELECT RANGPUR_100DS
                   FROM table(pkg_mis_rpt.fn_summary_report(''))
                  where OPERATION_CODE = index1
                    and SUBOP_CODE = index2
                    and DESCRIPTION = 'Achievement') * 100 /
               (SELECT case RANGPUR_100DS
                          when 0 then
                           1
                          else
                           RANGPUR_100DS
                        end
                   FROM table(pkg_mis_rpt.fn_summary_report(''))
                  where OPERATION_CODE = index1
                    and SUBOP_CODE = index2
                    and DESCRIPTION = 'Target')) RANGPUR_100DS,
               ((SELECT RANGPUR_ANNUAL
                   FROM table(pkg_mis_rpt.fn_summary_report(''))
                  where OPERATION_CODE = index1
                    and SUBOP_CODE = index2
                    and DESCRIPTION = 'Achievement') * 100 /
               (SELECT case RANGPUR_ANNUAL
                          when 0 then
                           1
                          else
                           RANGPUR_ANNUAL
                        end
                   FROM table(pkg_mis_rpt.fn_summary_report(''))
                  where OPERATION_CODE = index1
                    and SUBOP_CODE = index2
                    and DESCRIPTION = 'Target')) RANGPUR_ANNUAL,
               ((SELECT MYMENSING_100DS
                   FROM table(pkg_mis_rpt.fn_summary_report(''))
                  where OPERATION_CODE = index1
                    and SUBOP_CODE = index2
                    and DESCRIPTION = 'Achievement') * 100 /
               (SELECT case MYMENSING_100DS
                          when 0 then
                           1
                          else
                           MYMENSING_100DS
                        end
                   FROM table(pkg_mis_rpt.fn_summary_report(''))
                  where OPERATION_CODE = index1
                    and SUBOP_CODE = index2
                    and DESCRIPTION = 'Target')) MYMENSING_100DS,
               
               ((SELECT MYMENSING_ANNUAL
                   FROM table(pkg_mis_rpt.fn_summary_report(''))
                  where OPERATION_CODE = index1
                    and SUBOP_CODE = index2
                    and DESCRIPTION = 'Achievement') * 100 /
               (SELECT case MYMENSING_ANNUAL
                          when 0 then
                           1
                          else
                           MYMENSING_ANNUAL
                        end
                   FROM table(pkg_mis_rpt.fn_summary_report(''))
                  where OPERATION_CODE = index1
                    and SUBOP_CODE = index2
                    and DESCRIPTION = 'Target')) MYMENSING_ANNUAL,
               ((SELECT FARIDPUR_100DS
                   FROM table(pkg_mis_rpt.fn_summary_report(''))
                  where OPERATION_CODE = index1
                    and SUBOP_CODE = index2
                    and DESCRIPTION = 'Achievement') * 100 /
               (SELECT case FARIDPUR_100DS
                          when 0 then
                           1
                          else
                           FARIDPUR_100DS
                        end
                   FROM table(pkg_mis_rpt.fn_summary_report(''))
                  where OPERATION_CODE = index1
                    and SUBOP_CODE = index2
                    and DESCRIPTION = 'Target')) FARIDPUR_100DS,
               
               ((SELECT FARIDPUR_ANNUAL
                   FROM table(pkg_mis_rpt.fn_summary_report(''))
                  where OPERATION_CODE = index1
                    and SUBOP_CODE = index2
                    and DESCRIPTION = 'Achievement') * 100 /
               (SELECT case FARIDPUR_ANNUAL
                          when 0 then
                           1
                          else
                           FARIDPUR_ANNUAL
                        end
                   FROM table(pkg_mis_rpt.fn_summary_report(''))
                  where OPERATION_CODE = index1
                    and SUBOP_CODE = index2
                    and DESCRIPTION = 'Target')) FARIDPUR_ANNUAL,
               (SELECT (DHAKA_NORTH_100DS + DHAKA_SOUTH_100DS +
                       CHATTOGRAM_100DS + KHULNA_100DS + RAJSHAHI_100DS +
                       SYLHET_100DS + BARISAL_100DS + RANGPUR_100DS +
                       MYMENSING_100DS + FARIDPUR_100DS)
                  FROM table(pkg_mis_rpt.fn_summary_report(''))
                 where OPERATION_CODE = index1
                   and SUBOP_CODE = index2
                   and DESCRIPTION = 'Achievement') * 100 /
               (select case (DHAKA_NORTH_100DS + DHAKA_SOUTH_100DS +
                        CHATTOGRAM_100DS + KHULNA_100DS + RAJSHAHI_100DS +
                        SYLHET_100DS + BARISAL_100DS + RANGPUR_100DS +
                        MYMENSING_100DS + FARIDPUR_100DS)
                         when 0 then
                          1
                         else
                          (DHAKA_NORTH_100DS + DHAKA_SOUTH_100DS +
                          CHATTOGRAM_100DS + KHULNA_100DS + RAJSHAHI_100DS +
                          SYLHET_100DS + BARISAL_100DS + RANGPUR_100DS +
                          MYMENSING_100DS + FARIDPUR_100DS)
                       end
                
                  FROM table(pkg_mis_rpt.fn_summary_report(''))
                 where OPERATION_CODE = index1
                   and SUBOP_CODE = index2
                   and DESCRIPTION = 'Target'),
               (SELECT (DHAKA_NORTH_ANNUAL + DHAKA_SOUTH_ANNUAL +
                       CHATTOGRAM_ANNUAL + KHULNA_ANNUAL + RAJSHAHI_ANNUAL +
                       SYLHET_ANNUAL + BARISAL_ANNUAL + RANGPUR_ANNUAL +
                       MYMENSING_ANNUAL + FARIDPUR_ANNUAL)
                  FROM table(pkg_mis_rpt.fn_summary_report(''))
                 where OPERATION_CODE = index1
                   and SUBOP_CODE = index2
                   and DESCRIPTION = 'Achievement') * 100 /
               (select case
                        (DHAKA_NORTH_ANNUAL + DHAKA_SOUTH_ANNUAL +
                        CHATTOGRAM_ANNUAL + KHULNA_ANNUAL + RAJSHAHI_ANNUAL +
                        SYLHET_ANNUAL + BARISAL_ANNUAL + RANGPUR_ANNUAL +
                        MYMENSING_ANNUAL + FARIDPUR_ANNUAL)
                         when 0 then
                          1
                         else
                          (DHAKA_NORTH_ANNUAL + DHAKA_SOUTH_ANNUAL +
                          CHATTOGRAM_ANNUAL + KHULNA_ANNUAL +
                          RAJSHAHI_ANNUAL + SYLHET_ANNUAL + BARISAL_ANNUAL +
                          RANGPUR_ANNUAL + MYMENSING_ANNUAL +
                          FARIDPUR_ANNUAL)
                       end
                
                  FROM table(pkg_mis_rpt.fn_summary_report(''))
                 where OPERATION_CODE = index1
                   and SUBOP_CODE = index2
                   and DESCRIPTION = 'Target')
        
          into w_misSummaryReport.DHAKA_NORTH_100DS,
               w_misSummaryReport.DHAKA_NORTH_ANNUAL,
               w_misSummaryReport.DHAKA_SOUTH_100DS,
               w_misSummaryReport.DHAKA_SOUTH_ANNUAL,
               w_misSummaryReport.CHATTOGRAM_100DS,
               w_misSummaryReport.CHATTOGRAM_ANNUAL,
               w_misSummaryReport.KHULNA_100DS,
               w_misSummaryReport.KHULNA_ANNUAL,
               w_misSummaryReport.RAJSHAHI_100DS,
               w_misSummaryReport.RAJSHAHI_ANNUAL,
               w_misSummaryReport.SYLHET_100DS,
               w_misSummaryReport.SYLHET_ANNUAL,
               w_misSummaryReport.BARISAL_100DS,
               w_misSummaryReport.BARISAL_ANNUAL,
               w_misSummaryReport.RANGPUR_100DS,
               w_misSummaryReport.RANGPUR_ANNUAL,
               w_misSummaryReport.MYMENSING_100DS,
               w_misSummaryReport.MYMENSING_ANNUAL,
               w_misSummaryReport.FARIDPUR_100DS,
               w_misSummaryReport.FARIDPUR_ANNUAL,
               w_misSummaryReport.total_100days,
               w_misSummaryReport.total_Annual
          from dual;
      
        pipe row(w_misSummaryReport);
      
      END LOOP;
    END LOOP;
    FOR index1 IN 1 .. 3 LOOP
      for id in (SELECT OPERATION_CODE,
                        OPERATION_ACTIVITIES,
                        '03' SUBOP_CODE,
                        'Total ' subop_activities,
                        DESCRIPTION,
                        sum(DHAKA_NORTH_100DS / 10000000) DHAKA_NORTH_100DS,
                        sum(DHAKA_NORTH_ANNUAL / 10000000) DHAKA_NORTH_ANNUAL,
                        sum(DHAKA_SOUTH_100DS / 10000000) DHAKA_SOUTH_100DS,
                        sum(DHAKA_SOUTH_ANNUAL / 10000000) DHAKA_SOUTH_ANNUAL,
                        sum(CHATTOGRAM_100DS / 10000000) CHATTOGRAM_100DS,
                        sum(CHATTOGRAM_ANNUAL / 10000000) CHATTOGRAM_ANNUAL,
                        sum(KHULNA_100DS / 10000000) KHULNA_100DS,
                        sum(KHULNA_ANNUAL / 10000000) KHULNA_ANNUAL,
                        sum(RAJSHAHI_100DS / 10000000) RAJSHAHI_100DS,
                        sum(RAJSHAHI_ANNUAL / 10000000) RAJSHAHI_ANNUAL,
                        sum(SYLHET_100DS / 10000000) SYLHET_100DS,
                        sum(SYLHET_ANNUAL / 10000000) SYLHET_ANNUAL,
                        sum(BARISAL_100DS / 10000000) BARISAL_100DS,
                        sum(BARISAL_ANNUAL / 10000000) BARISAL_ANNUAL,
                        sum(RANGPUR_100DS / 10000000) RANGPUR_100DS,
                        sum(RANGPUR_ANNUAL / 10000000) RANGPUR_ANNUAL,
                        sum(MYMENSING_100DS / 10000000) MYMENSING_100DS,
                        sum(MYMENSING_ANNUAL / 10000000) MYMENSING_ANNUAL,
                        sum(FARIDPUR_100DS / 10000000) FARIDPUR_100DS,
                        sum(FARIDPUR_ANNUAL / 10000000) FARIDPUR_ANNUAL
                   FROM table(pkg_mis_rpt.fn_summary_report(''))
                  where OPERATION_CODE = index1
                    and DESCRIPTION = 'Achievement'
                  group by OPERATION_CODE, OPERATION_ACTIVITIES, DESCRIPTION) loop
        w_misSummaryReport.OPERATION_CODE       := id.OPERATION_CODE;
        w_misSummaryReport.OPERATION_ACTIVITIES := id.OPERATION_ACTIVITIES;
        w_misSummaryReport.SUBOP_CODE           := id.SUBOP_CODE;
        w_misSummaryReport.SUBOP_ACTIVITIES     := id.SUBOP_ACTIVITIES;
        w_misSummaryReport.DESCRIPTION          := id.DESCRIPTION;
        w_misSummaryReport.DHAKA_NORTH_100DS    := id.DHAKA_NORTH_100DS;
        w_misSummaryReport.DHAKA_NORTH_ANNUAL   := id.DHAKA_NORTH_ANNUAL;
        w_misSummaryReport.DHAKA_SOUTH_100DS    := id.DHAKA_SOUTH_100DS;
        w_misSummaryReport.DHAKA_SOUTH_ANNUAL   := id.DHAKA_SOUTH_ANNUAL;
        w_misSummaryReport.CHATTOGRAM_100DS     := id.CHATTOGRAM_100DS;
        w_misSummaryReport.CHATTOGRAM_ANNUAL    := id.CHATTOGRAM_ANNUAL;
        w_misSummaryReport.KHULNA_100DS         := id.KHULNA_100DS;
        w_misSummaryReport.KHULNA_ANNUAL        := id.KHULNA_ANNUAL;
        w_misSummaryReport.RAJSHAHI_100DS       := id.RAJSHAHI_100DS;
        w_misSummaryReport.RAJSHAHI_ANNUAL      := id.RAJSHAHI_ANNUAL;
        w_misSummaryReport.SYLHET_100DS         := id.SYLHET_100DS;
        w_misSummaryReport.SYLHET_ANNUAL        := id.SYLHET_ANNUAL;
        w_misSummaryReport.BARISAL_100DS        := id.BARISAL_100DS;
        w_misSummaryReport.BARISAL_ANNUAL       := id.BARISAL_ANNUAL;
        w_misSummaryReport.RANGPUR_100DS        := id.RANGPUR_100DS;
        w_misSummaryReport.RANGPUR_ANNUAL       := id.RANGPUR_ANNUAL;
        w_misSummaryReport.MYMENSING_100DS      := id.MYMENSING_100DS;
        w_misSummaryReport.MYMENSING_ANNUAL     := id.MYMENSING_ANNUAL;
        w_misSummaryReport.FARIDPUR_100DS       := id.FARIDPUR_100DS;
        w_misSummaryReport.FARIDPUR_ANNUAL      := id.FARIDPUR_ANNUAL;
        w_misSummaryReport.total_100days        := id.DHAKA_NORTH_100DS +
                                                   id.DHAKA_SOUTH_100DS +
                                                   id.CHATTOGRAM_100DS +
                                                   id.KHULNA_100DS +
                                                   id.RAJSHAHI_100DS +
                                                   id.SYLHET_100DS +
                                                   id.BARISAL_100DS +
                                                   id.RANGPUR_100DS +
                                                   id.MYMENSING_100DS +
                                                   id.FARIDPUR_100DS;
        w_misSummaryReport.total_Annual         := id.DHAKA_NORTH_ANNUAL + id.
                                                   DHAKA_SOUTH_ANNUAL +
                                                   id.CHATTOGRAM_ANNUAL +
                                                   id.KHULNA_ANNUAL +
                                                   id.RAJSHAHI_ANNUAL +
                                                   id.SYLHET_ANNUAL +
                                                   id.BARISAL_ANNUAL +
                                                   id.RANGPUR_ANNUAL +
                                                   id.MYMENSING_ANNUAL +
                                                   id.FARIDPUR_ANNUAL;
        pipe row(w_misSummaryReport);
      end loop;
    end loop;
  
    FOR index1 IN 1 .. 3 LOOP
      for id in (SELECT OPERATION_CODE,
                        OPERATION_ACTIVITIES,
                        '03' SUBOP_CODE,
                        'Total ' subop_activities,
                        DESCRIPTION,
                        sum(DHAKA_NORTH_100DS / 10000000) DHAKA_NORTH_100DS,
                        sum(DHAKA_NORTH_ANNUAL / 10000000) DHAKA_NORTH_ANNUAL,
                        sum(DHAKA_SOUTH_100DS / 10000000) DHAKA_SOUTH_100DS,
                        sum(DHAKA_SOUTH_ANNUAL / 10000000) DHAKA_SOUTH_ANNUAL,
                        sum(CHATTOGRAM_100DS / 10000000) CHATTOGRAM_100DS,
                        sum(CHATTOGRAM_ANNUAL / 10000000) CHATTOGRAM_ANNUAL,
                        sum(KHULNA_100DS / 10000000) KHULNA_100DS,
                        sum(KHULNA_ANNUAL / 10000000) KHULNA_ANNUAL,
                        sum(RAJSHAHI_100DS / 10000000) RAJSHAHI_100DS,
                        sum(RAJSHAHI_ANNUAL / 10000000) RAJSHAHI_ANNUAL,
                        sum(SYLHET_100DS / 10000000) SYLHET_100DS,
                        sum(SYLHET_ANNUAL / 10000000) SYLHET_ANNUAL,
                        sum(BARISAL_100DS / 10000000) BARISAL_100DS,
                        sum(BARISAL_ANNUAL / 10000000) BARISAL_ANNUAL,
                        sum(RANGPUR_100DS / 10000000) RANGPUR_100DS,
                        sum(RANGPUR_ANNUAL / 10000000) RANGPUR_ANNUAL,
                        sum(MYMENSING_100DS / 10000000) MYMENSING_100DS,
                        sum(MYMENSING_ANNUAL / 10000000) MYMENSING_ANNUAL,
                        sum(FARIDPUR_100DS / 10000000) FARIDPUR_100DS,
                        sum(FARIDPUR_ANNUAL / 10000000) FARIDPUR_ANNUAL
                   FROM table(pkg_mis_rpt.fn_summary_report(''))
                  where OPERATION_CODE = index1
                    and DESCRIPTION = 'Target'
                  group by OPERATION_CODE, OPERATION_ACTIVITIES, DESCRIPTION) loop
        w_misSummaryReport.OPERATION_CODE       := id.OPERATION_CODE;
        w_misSummaryReport.OPERATION_ACTIVITIES := id.OPERATION_ACTIVITIES;
        w_misSummaryReport.SUBOP_CODE           := id.SUBOP_CODE;
        w_misSummaryReport.SUBOP_ACTIVITIES     := id.SUBOP_ACTIVITIES;
        w_misSummaryReport.DESCRIPTION          := id.DESCRIPTION;
        w_misSummaryReport.DHAKA_NORTH_100DS    := id.DHAKA_NORTH_100DS;
        w_misSummaryReport.DHAKA_NORTH_ANNUAL   := id.DHAKA_NORTH_ANNUAL;
        w_misSummaryReport.DHAKA_SOUTH_100DS    := id.DHAKA_SOUTH_100DS;
        w_misSummaryReport.DHAKA_SOUTH_ANNUAL   := id.DHAKA_SOUTH_ANNUAL;
        w_misSummaryReport.CHATTOGRAM_100DS     := id.CHATTOGRAM_100DS;
        w_misSummaryReport.CHATTOGRAM_ANNUAL    := id.CHATTOGRAM_ANNUAL;
        w_misSummaryReport.KHULNA_100DS         := id.KHULNA_100DS;
        w_misSummaryReport.KHULNA_ANNUAL        := id.KHULNA_ANNUAL;
        w_misSummaryReport.RAJSHAHI_100DS       := id.RAJSHAHI_100DS;
        w_misSummaryReport.RAJSHAHI_ANNUAL      := id.RAJSHAHI_ANNUAL;
        w_misSummaryReport.SYLHET_100DS         := id.SYLHET_100DS;
        w_misSummaryReport.SYLHET_ANNUAL        := id.SYLHET_ANNUAL;
        w_misSummaryReport.BARISAL_100DS        := id.BARISAL_100DS;
        w_misSummaryReport.BARISAL_ANNUAL       := id.BARISAL_ANNUAL;
        w_misSummaryReport.RANGPUR_100DS        := id.RANGPUR_100DS;
        w_misSummaryReport.RANGPUR_ANNUAL       := id.RANGPUR_ANNUAL;
        w_misSummaryReport.MYMENSING_100DS      := id.MYMENSING_100DS;
        w_misSummaryReport.MYMENSING_ANNUAL     := id.MYMENSING_ANNUAL;
        w_misSummaryReport.FARIDPUR_100DS       := id.FARIDPUR_100DS;
        w_misSummaryReport.FARIDPUR_ANNUAL      := id.FARIDPUR_ANNUAL;
      
        w_misSummaryReport.total_100days := id.DHAKA_NORTH_100DS +
                                            id.DHAKA_SOUTH_100DS +
                                            id.CHATTOGRAM_100DS +
                                            id.KHULNA_100DS +
                                            id.RAJSHAHI_100DS +
                                            id.SYLHET_100DS +
                                            id.BARISAL_100DS +
                                            id.RANGPUR_100DS +
                                            id.MYMENSING_100DS +
                                            id.FARIDPUR_100DS;
        w_misSummaryReport.total_Annual  := id.DHAKA_NORTH_ANNUAL + id.
                                            DHAKA_SOUTH_ANNUAL +
                                            id.CHATTOGRAM_ANNUAL +
                                            id.KHULNA_ANNUAL +
                                            id.RAJSHAHI_ANNUAL +
                                            id.SYLHET_ANNUAL +
                                            id.BARISAL_ANNUAL +
                                            id.RANGPUR_ANNUAL +
                                            id.MYMENSING_ANNUAL +
                                            id.FARIDPUR_ANNUAL;
      
        pipe row(w_misSummaryReport);
      end loop;
    end loop;
  
    FOR index1 IN 1 .. 3 LOOP
      for id in (SELECT OPERATION_CODE,
                        OPERATION_ACTIVITIES,
                        '03' SUBOP_CODE,
                        'Total ' subop_activities,
                        DESCRIPTION,
                        sum(DHAKA_NORTH_100DS / 10000000) DHAKA_NORTH_100DS,
                        sum(DHAKA_NORTH_ANNUAL / 10000000) DHAKA_NORTH_ANNUAL,
                        sum(DHAKA_SOUTH_100DS / 10000000) DHAKA_SOUTH_100DS,
                        sum(DHAKA_SOUTH_ANNUAL / 10000000) DHAKA_SOUTH_ANNUAL,
                        sum(CHATTOGRAM_100DS / 10000000) CHATTOGRAM_100DS,
                        sum(CHATTOGRAM_ANNUAL / 10000000) CHATTOGRAM_ANNUAL,
                        sum(KHULNA_100DS / 10000000) KHULNA_100DS,
                        sum(KHULNA_ANNUAL / 10000000) KHULNA_ANNUAL,
                        sum(RAJSHAHI_100DS / 10000000) RAJSHAHI_100DS,
                        sum(RAJSHAHI_ANNUAL / 10000000) RAJSHAHI_ANNUAL,
                        sum(SYLHET_100DS / 10000000) SYLHET_100DS,
                        sum(SYLHET_ANNUAL / 10000000) SYLHET_ANNUAL,
                        sum(BARISAL_100DS / 10000000) BARISAL_100DS,
                        sum(BARISAL_ANNUAL / 10000000) BARISAL_ANNUAL,
                        sum(RANGPUR_100DS / 10000000) RANGPUR_100DS,
                        sum(RANGPUR_ANNUAL / 10000000) RANGPUR_ANNUAL,
                        sum(MYMENSING_100DS / 10000000) MYMENSING_100DS,
                        sum(MYMENSING_ANNUAL / 10000000) MYMENSING_ANNUAL,
                        sum(FARIDPUR_100DS / 10000000) FARIDPUR_100DS,
                        sum(FARIDPUR_ANNUAL / 10000000) FARIDPUR_ANNUAL
                   FROM table(pkg_mis_rpt.fn_summary_report(''))
                  where OPERATION_CODE = index1
                    and DESCRIPTION = 'Target'
                  group by OPERATION_CODE, OPERATION_ACTIVITIES, DESCRIPTION) loop
        for idx in (SELECT OPERATION_CODE,
                           OPERATION_ACTIVITIES,
                           '03' SUBOP_CODE,
                           'Total ' subop_activities,
                           DESCRIPTION,
                           sum(DHAKA_NORTH_100DS / 10000000) DHAKA_NORTH_100DS,
                           sum(DHAKA_NORTH_ANNUAL / 10000000) DHAKA_NORTH_ANNUAL,
                           sum(DHAKA_SOUTH_100DS / 10000000) DHAKA_SOUTH_100DS,
                           sum(DHAKA_SOUTH_ANNUAL / 10000000) DHAKA_SOUTH_ANNUAL,
                           sum(CHATTOGRAM_100DS / 10000000) CHATTOGRAM_100DS,
                           sum(CHATTOGRAM_ANNUAL / 10000000) CHATTOGRAM_ANNUAL,
                           sum(KHULNA_100DS / 10000000) KHULNA_100DS,
                           sum(KHULNA_ANNUAL / 10000000) KHULNA_ANNUAL,
                           sum(RAJSHAHI_100DS / 10000000) RAJSHAHI_100DS,
                           sum(RAJSHAHI_ANNUAL / 10000000) RAJSHAHI_ANNUAL,
                           sum(SYLHET_100DS / 10000000) SYLHET_100DS,
                           sum(SYLHET_ANNUAL / 10000000) SYLHET_ANNUAL,
                           sum(BARISAL_100DS / 10000000) BARISAL_100DS,
                           sum(BARISAL_ANNUAL / 10000000) BARISAL_ANNUAL,
                           sum(RANGPUR_100DS / 10000000) RANGPUR_100DS,
                           sum(RANGPUR_ANNUAL / 10000000) RANGPUR_ANNUAL,
                           sum(MYMENSING_100DS / 10000000) MYMENSING_100DS,
                           sum(MYMENSING_ANNUAL / 10000000) MYMENSING_ANNUAL,
                           sum(FARIDPUR_100DS / 10000000) FARIDPUR_100DS,
                           sum(FARIDPUR_ANNUAL / 10000000) FARIDPUR_ANNUAL
                      FROM table(pkg_mis_rpt.fn_summary_report(''))
                     where OPERATION_CODE = index1
                       and DESCRIPTION = 'Achievement'
                     group by OPERATION_CODE,
                              OPERATION_ACTIVITIES,
                              DESCRIPTION) loop
        
          w_misSummaryReport.OPERATION_CODE       := id.OPERATION_CODE;
          w_misSummaryReport.OPERATION_ACTIVITIES := id.OPERATION_ACTIVITIES;
          w_misSummaryReport.SUBOP_CODE           := id.SUBOP_CODE;
          w_misSummaryReport.SUBOP_ACTIVITIES     := id.SUBOP_ACTIVITIES;
          w_misSummaryReport.DESCRIPTION          := 'Achievement(%)';
          w_misSummaryReport.DHAKA_NORTH_100DS    := idx.DHAKA_NORTH_100DS /
                                                     id.DHAKA_NORTH_100DS;
          w_misSummaryReport.DHAKA_NORTH_ANNUAL   := idx.DHAKA_NORTH_ANNUAL /
                                                     id.DHAKA_NORTH_ANNUAL;
          w_misSummaryReport.DHAKA_SOUTH_100DS    := idx.DHAKA_SOUTH_100DS /
                                                     id.DHAKA_SOUTH_100DS;
          w_misSummaryReport.DHAKA_SOUTH_ANNUAL   := idx.DHAKA_SOUTH_ANNUAL /
                                                     id.DHAKA_SOUTH_ANNUAL;
          w_misSummaryReport.CHATTOGRAM_100DS     := idx.CHATTOGRAM_100DS /
                                                     id.CHATTOGRAM_100DS;
          w_misSummaryReport.CHATTOGRAM_ANNUAL    := idx.CHATTOGRAM_ANNUAL /
                                                     id.CHATTOGRAM_ANNUAL;
          w_misSummaryReport.KHULNA_100DS         := idx.KHULNA_100DS /
                                                     id.KHULNA_100DS;
          w_misSummaryReport.KHULNA_ANNUAL        := id.KHULNA_ANNUAL /
                                                     id.KHULNA_ANNUAL;
          w_misSummaryReport.RAJSHAHI_100DS       := idx.RAJSHAHI_100DS /
                                                     id.RAJSHAHI_100DS;
          w_misSummaryReport.RAJSHAHI_ANNUAL      := idx.RAJSHAHI_ANNUAL /
                                                     id.RAJSHAHI_ANNUAL;
          w_misSummaryReport.SYLHET_100DS         := idx.SYLHET_100DS /
                                                     id.SYLHET_100DS;
          w_misSummaryReport.SYLHET_ANNUAL        := idx.SYLHET_ANNUAL /
                                                     id.SYLHET_ANNUAL;
          w_misSummaryReport.BARISAL_100DS        := idx.BARISAL_100DS /
                                                     id.BARISAL_100DS;
          w_misSummaryReport.BARISAL_ANNUAL       := idx.BARISAL_ANNUAL /
                                                     id.BARISAL_ANNUAL;
          w_misSummaryReport.RANGPUR_100DS        := idx.RANGPUR_100DS /
                                                     id.RANGPUR_100DS;
          w_misSummaryReport.RANGPUR_ANNUAL       := idx.RANGPUR_ANNUAL /
                                                     id.RANGPUR_ANNUAL;
          w_misSummaryReport.MYMENSING_100DS      := idx.MYMENSING_100DS /
                                                     id.MYMENSING_100DS;
          w_misSummaryReport.MYMENSING_ANNUAL     := idx.MYMENSING_ANNUAL /
                                                     id.MYMENSING_ANNUAL;
          w_misSummaryReport.FARIDPUR_100DS       := idx.FARIDPUR_100DS /
                                                     id.FARIDPUR_100DS;
          w_misSummaryReport.FARIDPUR_ANNUAL      := idx.FARIDPUR_ANNUAL /
                                                     id.FARIDPUR_ANNUAL;
          w_misSummaryReport.total_100days        := (idx.DHAKA_NORTH_100DS +
                                                     idx.DHAKA_SOUTH_100DS +
                                                     idx.CHATTOGRAM_100DS +
                                                     idx.KHULNA_100DS +
                                                     idx.RAJSHAHI_100DS +
                                                     idx.SYLHET_100DS +
                                                     idx.BARISAL_100DS +
                                                     idx.RANGPUR_100DS +
                                                     idx.MYMENSING_100DS +
                                                     idx.FARIDPUR_100DS) /
                                                     (id.DHAKA_NORTH_100DS +
                                                     id.DHAKA_SOUTH_100DS +
                                                     id.CHATTOGRAM_100DS +
                                                     id.KHULNA_100DS +
                                                     id.RAJSHAHI_100DS +
                                                     id.SYLHET_100DS +
                                                     id.BARISAL_100DS +
                                                     id.RANGPUR_100DS +
                                                     id.MYMENSING_100DS +
                                                     id.FARIDPUR_100DS) * 100;
          w_misSummaryReport.total_Annual         := (idx.DHAKA_NORTH_ANNUAL + idx.
                                                      DHAKA_SOUTH_ANNUAL +
                                                      idx.CHATTOGRAM_ANNUAL +
                                                      idx.KHULNA_ANNUAL +
                                                      idx.RAJSHAHI_ANNUAL +
                                                      idx.SYLHET_ANNUAL +
                                                      idx.BARISAL_ANNUAL +
                                                      idx.RANGPUR_ANNUAL +
                                                      idx.MYMENSING_ANNUAL +
                                                      idx.FARIDPUR_ANNUAL) /
                                                     (id.DHAKA_NORTH_ANNUAL + id.
                                                      DHAKA_SOUTH_ANNUAL +
                                                      id.CHATTOGRAM_ANNUAL +
                                                      id.KHULNA_ANNUAL +
                                                      id.RAJSHAHI_ANNUAL +
                                                      id.SYLHET_ANNUAL +
                                                      id.BARISAL_ANNUAL +
                                                      id.RANGPUR_ANNUAL +
                                                      id.MYMENSING_ANNUAL +
                                                      id.FARIDPUR_ANNUAL) * 100;
        
          pipe row(w_misSummaryReport);
        end loop;
      end loop;
    end loop;
  
  end fn_summary_mis;

  function fn_summary_mis_others return v_misSummaryReport
    pipelined is
    w_misSummaryReport misSummaryReport;
  
  begin
    FOR index1 IN 4 .. 7 LOOP
      FOR index2 IN 1 .. 2 LOOP
        for id in (SELECT OPERATION_CODE,
                          OPERATION_ACTIVITIES,
                          SUBOP_CODE,
                          SUBOP_ACTIVITIES,
                          DESCRIPTION,
                          round(nvl(DHAKA_NORTH_100DS, 0), 2) DHAKA_NORTH_100DS,
                          round(nvl(DHAKA_NORTH_ANNUAL, 0), 2) DHAKA_NORTH_ANNUAL,
                          round(nvl(DHAKA_SOUTH_100DS, 0), 2) DHAKA_SOUTH_100DS,
                          round(nvl(DHAKA_SOUTH_ANNUAL, 0), 2) DHAKA_SOUTH_ANNUAL,
                          round(nvl(CHATTOGRAM_100DS, 0), 2) CHATTOGRAM_100DS,
                          round(nvl(CHATTOGRAM_ANNUAL, 0), 2) CHATTOGRAM_ANNUAL,
                          round(nvl(KHULNA_100DS, 0), 2) KHULNA_100DS,
                          round(nvl(KHULNA_ANNUAL, 0), 2) KHULNA_ANNUAL,
                          round(nvl(RAJSHAHI_100DS, 0), 2) RAJSHAHI_100DS,
                          round(nvl(RAJSHAHI_ANNUAL, 0), 2) RAJSHAHI_ANNUAL,
                          round(nvl(SYLHET_100DS, 0), 2) SYLHET_100DS,
                          round(nvl(SYLHET_ANNUAL, 0), 2) SYLHET_ANNUAL,
                          round(nvl(BARISAL_100DS, 0), 2) BARISAL_100DS,
                          round(nvl(BARISAL_ANNUAL, 0), 2) BARISAL_ANNUAL,
                          round(nvl(RANGPUR_100DS, 0), 2) RANGPUR_100DS,
                          round(nvl(RANGPUR_ANNUAL, 0), 2) RANGPUR_ANNUAL,
                          round(nvl(MYMENSING_100DS, 0), 2) MYMENSING_100DS,
                          round(nvl(MYMENSING_ANNUAL, 0), 2) MYMENSING_ANNUAL,
                          round(nvl(FARIDPUR_100DS, 0), 2) FARIDPUR_100DS,
                          round(nvl(FARIDPUR_ANNUAL, 0), 2) FARIDPUR_ANNUAL
                     FROM table(pkg_mis_rpt.fn_summary_report_others(''))
                    where OPERATION_CODE = index1
                      and SUBOP_CODE = index2) loop
        
          w_misSummaryReport.OPERATION_CODE       := id.OPERATION_CODE;
          w_misSummaryReport.OPERATION_ACTIVITIES := id.OPERATION_ACTIVITIES;
          w_misSummaryReport.SUBOP_CODE           := id.SUBOP_CODE;
          w_misSummaryReport.SUBOP_ACTIVITIES     := id.SUBOP_ACTIVITIES;
          w_misSummaryReport.DESCRIPTION          := id.DESCRIPTION;
          w_misSummaryReport.DHAKA_NORTH_100DS    := id.DHAKA_NORTH_100DS;
          w_misSummaryReport.DHAKA_NORTH_ANNUAL   := id.DHAKA_NORTH_ANNUAL;
          w_misSummaryReport.DHAKA_SOUTH_100DS    := id.DHAKA_SOUTH_100DS;
          w_misSummaryReport.DHAKA_SOUTH_ANNUAL   := id.DHAKA_SOUTH_ANNUAL;
          w_misSummaryReport.CHATTOGRAM_100DS     := id.CHATTOGRAM_100DS;
          w_misSummaryReport.CHATTOGRAM_ANNUAL    := id.CHATTOGRAM_ANNUAL;
          w_misSummaryReport.KHULNA_100DS         := id.KHULNA_100DS;
          w_misSummaryReport.KHULNA_ANNUAL        := id.KHULNA_ANNUAL;
          w_misSummaryReport.RAJSHAHI_100DS       := id.RAJSHAHI_100DS;
          w_misSummaryReport.RAJSHAHI_ANNUAL      := id.RAJSHAHI_ANNUAL;
          w_misSummaryReport.SYLHET_100DS         := id.SYLHET_100DS;
          w_misSummaryReport.SYLHET_ANNUAL        := id.SYLHET_ANNUAL;
          w_misSummaryReport.BARISAL_100DS        := id.BARISAL_100DS;
          w_misSummaryReport.BARISAL_ANNUAL       := id.BARISAL_ANNUAL;
          w_misSummaryReport.RANGPUR_100DS        := id.RANGPUR_100DS;
          w_misSummaryReport.RANGPUR_ANNUAL       := id.RANGPUR_ANNUAL;
          w_misSummaryReport.MYMENSING_100DS      := id.MYMENSING_100DS;
          w_misSummaryReport.MYMENSING_ANNUAL     := id.MYMENSING_ANNUAL;
          w_misSummaryReport.FARIDPUR_100DS       := id.FARIDPUR_100DS;
          w_misSummaryReport.FARIDPUR_ANNUAL      := id.FARIDPUR_ANNUAL;
          w_misSummaryReport.total_100days        := id.DHAKA_NORTH_100DS +
                                                     id.DHAKA_SOUTH_100DS +
                                                     id.CHATTOGRAM_100DS +
                                                     id.KHULNA_100DS +
                                                     id.RAJSHAHI_100DS +
                                                     id.SYLHET_100DS +
                                                     id.BARISAL_100DS +
                                                     id.RANGPUR_100DS +
                                                     id.MYMENSING_100DS +
                                                     id.FARIDPUR_100DS;
          w_misSummaryReport.total_Annual         := id.DHAKA_NORTH_ANNUAL + id.
                                                     DHAKA_SOUTH_ANNUAL +
                                                     id.CHATTOGRAM_ANNUAL +
                                                     id.KHULNA_ANNUAL +
                                                     id.RAJSHAHI_ANNUAL +
                                                     id.SYLHET_ANNUAL +
                                                     id.BARISAL_ANNUAL +
                                                     id.RANGPUR_ANNUAL +
                                                     id.MYMENSING_ANNUAL +
                                                     id.FARIDPUR_ANNUAL;
          if index1 = 7 and index2 = 2 then
            null;
          else
            pipe row(w_misSummaryReport);
          end if;
        
        end loop;
      
        w_misSummaryReport.DESCRIPTION := 'Achievement(%)';
        if index1 = 7 and index2 = 2 then
          null;
        else
          SELECT ((SELECT DHAKA_NORTH_100DS
                     FROM table(pkg_mis_rpt.fn_summary_report_others(''))
                    where OPERATION_CODE = index1
                      and SUBOP_CODE = index2
                      and DESCRIPTION = 'Achievement') * 100 /
                 (SELECT case DHAKA_NORTH_100DS
                            when 0 then
                             1
                            else
                             DHAKA_NORTH_100DS
                          end
                     FROM table(pkg_mis_rpt.fn_summary_report_others(''))
                    where OPERATION_CODE = index1
                      and SUBOP_CODE = index2
                      and DESCRIPTION = 'Target')) DHAKA_NORTH_100DS,
                 
                 ((SELECT DHAKA_NORTH_ANNUAL
                     FROM table(pkg_mis_rpt.fn_summary_report_others(''))
                    where OPERATION_CODE = index1
                      and SUBOP_CODE = index2
                      and DESCRIPTION = 'Achievement') * 100 /
                 (SELECT case DHAKA_NORTH_ANNUAL
                            when 0 then
                             1
                            else
                             DHAKA_NORTH_ANNUAL
                          end
                     FROM table(pkg_mis_rpt.fn_summary_report_others(''))
                    where OPERATION_CODE = index1
                      and SUBOP_CODE = index2
                      and DESCRIPTION = 'Target')) DHAKA_NORTH_ANNUAL,
                 ((SELECT DHAKA_SOUTH_100DS
                     FROM table(pkg_mis_rpt.fn_summary_report_others(''))
                    where OPERATION_CODE = index1
                      and SUBOP_CODE = index2
                      and DESCRIPTION = 'Achievement') * 100 /
                 (SELECT case DHAKA_SOUTH_100DS
                            when 0 then
                             1
                            else
                             DHAKA_SOUTH_100DS
                          end
                     FROM table(pkg_mis_rpt.fn_summary_report_others(''))
                    where OPERATION_CODE = index1
                      and SUBOP_CODE = index2
                      and DESCRIPTION = 'Target')) DHAKA_SOUTH_100DS,
                 
                 ((SELECT DHAKA_SOUTH_ANNUAL
                     FROM table(pkg_mis_rpt.fn_summary_report_others(''))
                    where OPERATION_CODE = index1
                      and SUBOP_CODE = index2
                      and DESCRIPTION = 'Achievement') * 100 /
                 (SELECT case DHAKA_SOUTH_ANNUAL
                            when 0 then
                             1
                            else
                             DHAKA_SOUTH_ANNUAL
                          end
                     FROM table(pkg_mis_rpt.fn_summary_report_others(''))
                    where OPERATION_CODE = index1
                      and SUBOP_CODE = index2
                      and DESCRIPTION = 'Target')) DHAKA_SOUTH_ANNUAL,
                 
                 ((SELECT CHATTOGRAM_100DS
                     FROM table(pkg_mis_rpt.fn_summary_report_others(''))
                    where OPERATION_CODE = index1
                      and SUBOP_CODE = index2
                      and DESCRIPTION = 'Achievement') * 100 /
                 (SELECT case CHATTOGRAM_100DS
                            when 0 then
                             1
                            else
                             CHATTOGRAM_100DS
                          end
                     FROM table(pkg_mis_rpt.fn_summary_report_others(''))
                    where OPERATION_CODE = index1
                      and SUBOP_CODE = index2
                      and DESCRIPTION = 'Target')) CHATTOGRAM_100DS,
                 
                 ((SELECT CHATTOGRAM_ANNUAL
                     FROM table(pkg_mis_rpt.fn_summary_report_others(''))
                    where OPERATION_CODE = index1
                      and SUBOP_CODE = index2
                      and DESCRIPTION = 'Achievement') * 100 /
                 (SELECT case CHATTOGRAM_ANNUAL
                            when 0 then
                             1
                            else
                             CHATTOGRAM_ANNUAL
                          end
                     FROM table(pkg_mis_rpt.fn_summary_report_others(''))
                    where OPERATION_CODE = index1
                      and SUBOP_CODE = index2
                      and DESCRIPTION = 'Target')) CHATTOGRAM_ANNUAL,
                 
                 ((SELECT KHULNA_100DS
                     FROM table(pkg_mis_rpt.fn_summary_report_others(''))
                    where OPERATION_CODE = index1
                      and SUBOP_CODE = index2
                      and DESCRIPTION = 'Achievement') * 100 /
                 (SELECT case KHULNA_100DS
                            when 0 then
                             1
                            else
                             KHULNA_100DS
                          end
                     FROM table(pkg_mis_rpt.fn_summary_report_others(''))
                    where OPERATION_CODE = index1
                      and SUBOP_CODE = index2
                      and DESCRIPTION = 'Target')) KHULNA_100DS,
                 
                 ((SELECT KHULNA_ANNUAL
                     FROM table(pkg_mis_rpt.fn_summary_report_others(''))
                    where OPERATION_CODE = index1
                      and SUBOP_CODE = index2
                      and DESCRIPTION = 'Achievement') * 100 /
                 (SELECT case KHULNA_ANNUAL
                            when 0 then
                             1
                            else
                             KHULNA_ANNUAL
                          end
                     FROM table(pkg_mis_rpt.fn_summary_report_others(''))
                    where OPERATION_CODE = index1
                      and SUBOP_CODE = index2
                      and DESCRIPTION = 'Target')) KHULNA_ANNUAL,
                 
                 ((SELECT RAJSHAHI_100DS
                     FROM table(pkg_mis_rpt.fn_summary_report_others(''))
                    where OPERATION_CODE = index1
                      and SUBOP_CODE = index2
                      and DESCRIPTION = 'Achievement') * 100 /
                 (SELECT case RAJSHAHI_100DS
                            when 0 then
                             1
                            else
                             RAJSHAHI_100DS
                          end
                     FROM table(pkg_mis_rpt.fn_summary_report_others(''))
                    where OPERATION_CODE = index1
                      and SUBOP_CODE = index2
                      and DESCRIPTION = 'Target')) RAJSHAHI_100DS,
                 
                 ((SELECT RAJSHAHI_ANNUAL
                     FROM table(pkg_mis_rpt.fn_summary_report_others(''))
                    where OPERATION_CODE = index1
                      and SUBOP_CODE = index2
                      and DESCRIPTION = 'Achievement') * 100 /
                 (SELECT case RAJSHAHI_ANNUAL
                            when 0 then
                             1
                            else
                             RAJSHAHI_ANNUAL
                          end
                     FROM table(pkg_mis_rpt.fn_summary_report_others(''))
                    where OPERATION_CODE = index1
                      and SUBOP_CODE = index2
                      and DESCRIPTION = 'Target')) RAJSHAHI_ANNUAL,
                 
                 ((SELECT SYLHET_100DS
                     FROM table(pkg_mis_rpt.fn_summary_report_others(''))
                    where OPERATION_CODE = index1
                      and SUBOP_CODE = index2
                      and DESCRIPTION = 'Achievement') * 100 /
                 (SELECT case SYLHET_100DS
                            when 0 then
                             1
                            else
                             SYLHET_100DS
                          end
                     FROM table(pkg_mis_rpt.fn_summary_report_others(''))
                    where OPERATION_CODE = index1
                      and SUBOP_CODE = index2
                      and DESCRIPTION = 'Target')) SYLHET_100DS,
                 
                 ((SELECT SYLHET_ANNUAL
                     FROM table(pkg_mis_rpt.fn_summary_report_others(''))
                    where OPERATION_CODE = index1
                      and SUBOP_CODE = index2
                      and DESCRIPTION = 'Achievement') * 100 /
                 (SELECT case SYLHET_ANNUAL
                            when 0 then
                             1
                            else
                             SYLHET_ANNUAL
                          end
                     FROM table(pkg_mis_rpt.fn_summary_report_others(''))
                    where OPERATION_CODE = index1
                      and SUBOP_CODE = index2
                      and DESCRIPTION = 'Target')) SYLHET_ANNUAL,
                 ((SELECT BARISAL_100DS
                     FROM table(pkg_mis_rpt.fn_summary_report_others(''))
                    where OPERATION_CODE = index1
                      and SUBOP_CODE = index2
                      and DESCRIPTION = 'Achievement') * 100 /
                 (SELECT case BARISAL_100DS
                            when 0 then
                             1
                            else
                             BARISAL_100DS
                          end
                     FROM table(pkg_mis_rpt.fn_summary_report_others(''))
                    where OPERATION_CODE = index1
                      and SUBOP_CODE = index2
                      and DESCRIPTION = 'Target')) BARISAL_100DS,
                 
                 ((SELECT BARISAL_ANNUAL
                     FROM table(pkg_mis_rpt.fn_summary_report_others(''))
                    where OPERATION_CODE = index1
                      and SUBOP_CODE = index2
                      and DESCRIPTION = 'Achievement') * 100 /
                 (SELECT case BARISAL_ANNUAL
                            when 0 then
                             1
                            else
                             BARISAL_ANNUAL
                          end
                     FROM table(pkg_mis_rpt.fn_summary_report_others(''))
                    where OPERATION_CODE = index1
                      and SUBOP_CODE = index2
                      and DESCRIPTION = 'Target')) BARISAL_ANNUAL,
                 
                 ((SELECT RANGPUR_100DS
                     FROM table(pkg_mis_rpt.fn_summary_report_others(''))
                    where OPERATION_CODE = index1
                      and SUBOP_CODE = index2
                      and DESCRIPTION = 'Achievement') * 100 /
                 (SELECT case RANGPUR_100DS
                            when 0 then
                             1
                            else
                             RANGPUR_100DS
                          end
                     FROM table(pkg_mis_rpt.fn_summary_report_others(''))
                    where OPERATION_CODE = index1
                      and SUBOP_CODE = index2
                      and DESCRIPTION = 'Target')) RANGPUR_100DS,
                 ((SELECT RANGPUR_ANNUAL
                     FROM table(pkg_mis_rpt.fn_summary_report_others(''))
                    where OPERATION_CODE = index1
                      and SUBOP_CODE = index2
                      and DESCRIPTION = 'Achievement') * 100 /
                 (SELECT case RANGPUR_ANNUAL
                            when 0 then
                             1
                            else
                             RANGPUR_ANNUAL
                          end
                     FROM table(pkg_mis_rpt.fn_summary_report_others(''))
                    where OPERATION_CODE = index1
                      and SUBOP_CODE = index2
                      and DESCRIPTION = 'Target')) RANGPUR_ANNUAL,
                 ((SELECT MYMENSING_100DS
                     FROM table(pkg_mis_rpt.fn_summary_report_others(''))
                    where OPERATION_CODE = index1
                      and SUBOP_CODE = index2
                      and DESCRIPTION = 'Achievement') * 100 /
                 (SELECT case MYMENSING_100DS
                            when 0 then
                             1
                            else
                             MYMENSING_100DS
                          end
                     FROM table(pkg_mis_rpt.fn_summary_report_others(''))
                    where OPERATION_CODE = index1
                      and SUBOP_CODE = index2
                      and DESCRIPTION = 'Target')) MYMENSING_100DS,
                 
                 ((SELECT MYMENSING_ANNUAL
                     FROM table(pkg_mis_rpt.fn_summary_report_others(''))
                    where OPERATION_CODE = index1
                      and SUBOP_CODE = index2
                      and DESCRIPTION = 'Achievement') * 100 /
                 (SELECT case MYMENSING_ANNUAL
                            when 0 then
                             1
                            else
                             MYMENSING_ANNUAL
                          end
                     FROM table(pkg_mis_rpt.fn_summary_report_others(''))
                    where OPERATION_CODE = index1
                      and SUBOP_CODE = index2
                      and DESCRIPTION = 'Target')) MYMENSING_ANNUAL,
                 ((SELECT FARIDPUR_100DS
                     FROM table(pkg_mis_rpt.fn_summary_report_others(''))
                    where OPERATION_CODE = index1
                      and SUBOP_CODE = index2
                      and DESCRIPTION = 'Achievement') * 100 /
                 (SELECT case FARIDPUR_100DS
                            when 0 then
                             1
                            else
                             FARIDPUR_100DS
                          end
                     FROM table(pkg_mis_rpt.fn_summary_report_others(''))
                    where OPERATION_CODE = index1
                      and SUBOP_CODE = index2
                      and DESCRIPTION = 'Target')) FARIDPUR_100DS,
                 
                 ((SELECT FARIDPUR_ANNUAL
                     FROM table(pkg_mis_rpt.fn_summary_report_others(''))
                    where OPERATION_CODE = index1
                      and SUBOP_CODE = index2
                      and DESCRIPTION = 'Achievement') * 100 /
                 (SELECT case FARIDPUR_ANNUAL
                            when 0 then
                             1
                            else
                             FARIDPUR_ANNUAL
                          end
                     FROM table(pkg_mis_rpt.fn_summary_report_others(''))
                    where OPERATION_CODE = index1
                      and SUBOP_CODE = index2
                      and DESCRIPTION = 'Target')) FARIDPUR_ANNUAL,
                 
                 (SELECT (nvl(DHAKA_NORTH_100DS, 0) +
                         nvl(DHAKA_SOUTH_100DS, 0) +
                         nvl(CHATTOGRAM_100DS, 0) + nvl(KHULNA_100DS, 0) +
                         nvl(RAJSHAHI_100DS, 0) + nvl(SYLHET_100DS, 0) +
                         nvl(BARISAL_100DS, 0) + nvl(RANGPUR_100DS, 0) +
                         nvl(MYMENSING_100DS, 0) + nvl(FARIDPUR_100DS, 0))
                    FROM table(pkg_mis_rpt.fn_summary_report_others(''))
                   where OPERATION_CODE = index1
                     and SUBOP_CODE = index2
                     and DESCRIPTION = 'Achievement') * 100 /
                 (select case
                          nvl(DHAKA_NORTH_100DS, 0) +
                          nvl(DHAKA_SOUTH_100DS, 0) +
                          nvl(CHATTOGRAM_100DS, 0) + nvl(KHULNA_100DS, 0) +
                          nvl(RAJSHAHI_100DS, 0) + nvl(SYLHET_100DS, 0) +
                          nvl(BARISAL_100DS, 0) + nvl(RANGPUR_100DS, 0) +
                          nvl(MYMENSING_100DS, 0) + nvl(FARIDPUR_100DS, 0)
                           when 0 then
                            1
                           else
                            nvl(DHAKA_NORTH_100DS, 0) +
                            nvl(DHAKA_SOUTH_100DS, 0) +
                            nvl(CHATTOGRAM_100DS, 0) + nvl(KHULNA_100DS, 0) +
                            nvl(RAJSHAHI_100DS, 0) + nvl(SYLHET_100DS, 0) +
                            nvl(BARISAL_100DS, 0) + nvl(RANGPUR_100DS, 0) +
                            nvl(MYMENSING_100DS, 0) + nvl(FARIDPUR_100DS, 0)
                         end
                  
                    FROM table(pkg_mis_rpt.fn_summary_report_others(''))
                   where OPERATION_CODE = index1
                     and SUBOP_CODE = index2
                     and DESCRIPTION = 'Target'),
                 (SELECT nvl(DHAKA_NORTH_ANNUAL, 0) +
                         nvl(DHAKA_SOUTH_ANNUAL, 0) +
                         nvl(CHATTOGRAM_ANNUAL, 0) + nvl(KHULNA_ANNUAL, 0) +
                         nvl(RAJSHAHI_ANNUAL, 0) + nvl(SYLHET_ANNUAL, 0) +
                         nvl(BARISAL_ANNUAL, 0) + nvl(RANGPUR_ANNUAL, 0) +
                         nvl(MYMENSING_ANNUAL, 0) + nvl(FARIDPUR_ANNUAL, 0)
                    FROM table(pkg_mis_rpt.fn_summary_report_others(''))
                   where OPERATION_CODE = index1
                     and SUBOP_CODE = index2
                     and DESCRIPTION = 'Achievement') * 100 /
                 (select case
                          nvl(DHAKA_NORTH_ANNUAL, 0) +
                          nvl(DHAKA_SOUTH_ANNUAL, 0) +
                          nvl(CHATTOGRAM_ANNUAL, 0) + nvl(KHULNA_ANNUAL, 0) +
                          nvl(RAJSHAHI_ANNUAL, 0) + nvl(SYLHET_ANNUAL, 0) +
                          nvl(BARISAL_ANNUAL, 0) + nvl(RANGPUR_ANNUAL, 0) +
                          nvl(MYMENSING_ANNUAL, 0) + nvl(FARIDPUR_ANNUAL, 0)
                           when 0 then
                            1
                           else
                            nvl(DHAKA_NORTH_ANNUAL, 0) +
                            nvl(DHAKA_SOUTH_ANNUAL, 0) +
                            nvl(CHATTOGRAM_ANNUAL, 0) + nvl(KHULNA_ANNUAL, 0) +
                            nvl(RAJSHAHI_ANNUAL, 0) + nvl(SYLHET_ANNUAL, 0) +
                            nvl(BARISAL_ANNUAL, 0) + nvl(RANGPUR_ANNUAL, 0) +
                            nvl(MYMENSING_ANNUAL, 0) +
                            nvl(FARIDPUR_ANNUAL, 0)
                         end
                  
                    FROM table(pkg_mis_rpt.fn_summary_report_others(''))
                   where OPERATION_CODE = index1
                     and SUBOP_CODE = index2
                     and DESCRIPTION = 'Target')
          
            into w_misSummaryReport.DHAKA_NORTH_100DS,
                 w_misSummaryReport.DHAKA_NORTH_ANNUAL,
                 w_misSummaryReport.DHAKA_SOUTH_100DS,
                 w_misSummaryReport.DHAKA_SOUTH_ANNUAL,
                 w_misSummaryReport.CHATTOGRAM_100DS,
                 w_misSummaryReport.CHATTOGRAM_ANNUAL,
                 w_misSummaryReport.KHULNA_100DS,
                 w_misSummaryReport.KHULNA_ANNUAL,
                 w_misSummaryReport.RAJSHAHI_100DS,
                 w_misSummaryReport.RAJSHAHI_ANNUAL,
                 w_misSummaryReport.SYLHET_100DS,
                 w_misSummaryReport.SYLHET_ANNUAL,
                 w_misSummaryReport.BARISAL_100DS,
                 w_misSummaryReport.BARISAL_ANNUAL,
                 w_misSummaryReport.RANGPUR_100DS,
                 w_misSummaryReport.RANGPUR_ANNUAL,
                 w_misSummaryReport.MYMENSING_100DS,
                 w_misSummaryReport.MYMENSING_ANNUAL,
                 w_misSummaryReport.FARIDPUR_100DS,
                 w_misSummaryReport.FARIDPUR_ANNUAL,
                 w_misSummaryReport.total_100days,
                 w_misSummaryReport.total_Annual
            from dual;
        
          pipe row(w_misSummaryReport);
        end if;
      END LOOP;
    END LOOP;
    FOR index1 IN 4 .. 6 LOOP
      for id in (SELECT OPERATION_CODE,
                        OPERATION_ACTIVITIES,
                        '03' SUBOP_CODE,
                        'Total ' subop_activities,
                        DESCRIPTION,
                        sum(DHAKA_NORTH_100DS) DHAKA_NORTH_100DS,
                        sum(DHAKA_NORTH_ANNUAL) DHAKA_NORTH_ANNUAL,
                        sum(DHAKA_SOUTH_100DS) DHAKA_SOUTH_100DS,
                        sum(DHAKA_SOUTH_ANNUAL) DHAKA_SOUTH_ANNUAL,
                        sum(CHATTOGRAM_100DS) CHATTOGRAM_100DS,
                        sum(CHATTOGRAM_ANNUAL) CHATTOGRAM_ANNUAL,
                        sum(KHULNA_100DS) KHULNA_100DS,
                        sum(KHULNA_ANNUAL) KHULNA_ANNUAL,
                        sum(RAJSHAHI_100DS) RAJSHAHI_100DS,
                        sum(RAJSHAHI_ANNUAL) RAJSHAHI_ANNUAL,
                        sum(SYLHET_100DS) SYLHET_100DS,
                        sum(SYLHET_ANNUAL) SYLHET_ANNUAL,
                        sum(BARISAL_100DS) BARISAL_100DS,
                        sum(BARISAL_ANNUAL) BARISAL_ANNUAL,
                        sum(RANGPUR_100DS) RANGPUR_100DS,
                        sum(RANGPUR_ANNUAL) RANGPUR_ANNUAL,
                        sum(MYMENSING_100DS) MYMENSING_100DS,
                        sum(MYMENSING_ANNUAL) MYMENSING_ANNUAL,
                        sum(FARIDPUR_100DS) FARIDPUR_100DS,
                        sum(FARIDPUR_ANNUAL) FARIDPUR_ANNUAL
                   FROM table(pkg_mis_rpt.fn_summary_report_others(''))
                  where OPERATION_CODE = index1
                    and DESCRIPTION = 'Achievement'
                  group by OPERATION_CODE, OPERATION_ACTIVITIES, DESCRIPTION) loop
      
        w_misSummaryReport.OPERATION_CODE       := id.OPERATION_CODE;
        w_misSummaryReport.OPERATION_ACTIVITIES := id.OPERATION_ACTIVITIES;
        w_misSummaryReport.SUBOP_CODE           := id.SUBOP_CODE;
        w_misSummaryReport.SUBOP_ACTIVITIES     := id.SUBOP_ACTIVITIES;
        w_misSummaryReport.DESCRIPTION          := id.DESCRIPTION;
        w_misSummaryReport.DHAKA_NORTH_100DS    := id.DHAKA_NORTH_100DS;
        w_misSummaryReport.DHAKA_NORTH_ANNUAL   := id.DHAKA_NORTH_ANNUAL;
        w_misSummaryReport.DHAKA_SOUTH_100DS    := id.DHAKA_SOUTH_100DS;
        w_misSummaryReport.DHAKA_SOUTH_ANNUAL   := id.DHAKA_SOUTH_ANNUAL;
        w_misSummaryReport.CHATTOGRAM_100DS     := id.CHATTOGRAM_100DS;
        w_misSummaryReport.CHATTOGRAM_ANNUAL    := id.CHATTOGRAM_ANNUAL;
        w_misSummaryReport.KHULNA_100DS         := id.KHULNA_100DS;
        w_misSummaryReport.KHULNA_ANNUAL        := id.KHULNA_ANNUAL;
        w_misSummaryReport.RAJSHAHI_100DS       := id.RAJSHAHI_100DS;
        w_misSummaryReport.RAJSHAHI_ANNUAL      := id.RAJSHAHI_ANNUAL;
        w_misSummaryReport.SYLHET_100DS         := id.SYLHET_100DS;
        w_misSummaryReport.SYLHET_ANNUAL        := id.SYLHET_ANNUAL;
        w_misSummaryReport.BARISAL_100DS        := id.BARISAL_100DS;
        w_misSummaryReport.BARISAL_ANNUAL       := id.BARISAL_ANNUAL;
        w_misSummaryReport.RANGPUR_100DS        := id.RANGPUR_100DS;
        w_misSummaryReport.RANGPUR_ANNUAL       := id.RANGPUR_ANNUAL;
        w_misSummaryReport.MYMENSING_100DS      := id.MYMENSING_100DS;
        w_misSummaryReport.MYMENSING_ANNUAL     := id.MYMENSING_ANNUAL;
        w_misSummaryReport.FARIDPUR_100DS       := id.FARIDPUR_100DS;
        w_misSummaryReport.FARIDPUR_ANNUAL      := id.FARIDPUR_ANNUAL;
        w_misSummaryReport.total_100days        := nvl(id.DHAKA_NORTH_100DS,
                                                       0) + nvl(id.DHAKA_SOUTH_100DS,
                                                                0) +
                                                   nvl(id.CHATTOGRAM_100DS,
                                                       0) +
                                                   nvl(id.KHULNA_100DS, 0) +
                                                   nvl(id.RAJSHAHI_100DS, 0) +
                                                   nvl(id.SYLHET_100DS, 0) +
                                                   nvl(id.BARISAL_100DS, 0) +
                                                   nvl(id.RANGPUR_100DS, 0) +
                                                   nvl(id.MYMENSING_100DS,
                                                       0) +
                                                   nvl(id.FARIDPUR_100DS, 0);
        w_misSummaryReport.total_Annual         := nvl(id.DHAKA_NORTH_ANNUAL,
                                                       0) + nvl(id.DHAKA_SOUTH_ANNUAL,
                                                                0) +
                                                   nvl(id.CHATTOGRAM_ANNUAL,
                                                       0) +
                                                   nvl(id.KHULNA_ANNUAL, 0) +
                                                   nvl(id.RAJSHAHI_ANNUAL,
                                                       0) +
                                                   nvl(id.SYLHET_ANNUAL, 0) +
                                                   nvl(id.BARISAL_ANNUAL, 0) +
                                                   nvl(id.RANGPUR_ANNUAL, 0) +
                                                   nvl(id.MYMENSING_ANNUAL,
                                                       0) + nvl(id.FARIDPUR_ANNUAL,
                                                                0);
        pipe row(w_misSummaryReport);
      end loop;
    end loop;
  
    FOR index1 IN 4 .. 6 LOOP
      for id in (SELECT OPERATION_CODE,
                        OPERATION_ACTIVITIES,
                        '03' SUBOP_CODE,
                        'Total ' subop_activities,
                        DESCRIPTION,
                        sum(DHAKA_NORTH_100DS) DHAKA_NORTH_100DS,
                        sum(DHAKA_NORTH_ANNUAL) DHAKA_NORTH_ANNUAL,
                        sum(DHAKA_SOUTH_100DS) DHAKA_SOUTH_100DS,
                        sum(DHAKA_SOUTH_ANNUAL) DHAKA_SOUTH_ANNUAL,
                        sum(CHATTOGRAM_100DS) CHATTOGRAM_100DS,
                        sum(CHATTOGRAM_ANNUAL) CHATTOGRAM_ANNUAL,
                        sum(KHULNA_100DS) KHULNA_100DS,
                        sum(KHULNA_ANNUAL) KHULNA_ANNUAL,
                        sum(RAJSHAHI_100DS) RAJSHAHI_100DS,
                        sum(RAJSHAHI_ANNUAL) RAJSHAHI_ANNUAL,
                        sum(SYLHET_100DS) SYLHET_100DS,
                        sum(SYLHET_ANNUAL) SYLHET_ANNUAL,
                        sum(BARISAL_100DS) BARISAL_100DS,
                        sum(BARISAL_ANNUAL) BARISAL_ANNUAL,
                        sum(RANGPUR_100DS) RANGPUR_100DS,
                        sum(RANGPUR_ANNUAL) RANGPUR_ANNUAL,
                        sum(MYMENSING_100DS) MYMENSING_100DS,
                        sum(MYMENSING_ANNUAL) MYMENSING_ANNUAL,
                        sum(FARIDPUR_100DS) FARIDPUR_100DS,
                        sum(FARIDPUR_ANNUAL) FARIDPUR_ANNUAL
                   FROM table(pkg_mis_rpt.fn_summary_report_others(''))
                  where OPERATION_CODE = index1
                    and DESCRIPTION = 'Target'
                  group by OPERATION_CODE, OPERATION_ACTIVITIES, DESCRIPTION) loop
      
        w_misSummaryReport.OPERATION_CODE       := id.OPERATION_CODE;
        w_misSummaryReport.OPERATION_ACTIVITIES := id.OPERATION_ACTIVITIES;
        w_misSummaryReport.SUBOP_CODE           := id.SUBOP_CODE;
        w_misSummaryReport.SUBOP_ACTIVITIES     := id.SUBOP_ACTIVITIES;
        w_misSummaryReport.DESCRIPTION          := id.DESCRIPTION;
        w_misSummaryReport.DHAKA_NORTH_100DS    := id.DHAKA_NORTH_100DS;
        w_misSummaryReport.DHAKA_NORTH_ANNUAL   := id.DHAKA_NORTH_ANNUAL;
        w_misSummaryReport.DHAKA_SOUTH_100DS    := id.DHAKA_SOUTH_100DS;
        w_misSummaryReport.DHAKA_SOUTH_ANNUAL   := id.DHAKA_SOUTH_ANNUAL;
        w_misSummaryReport.CHATTOGRAM_100DS     := id.CHATTOGRAM_100DS;
        w_misSummaryReport.CHATTOGRAM_ANNUAL    := id.CHATTOGRAM_ANNUAL;
        w_misSummaryReport.KHULNA_100DS         := id.KHULNA_100DS;
        w_misSummaryReport.KHULNA_ANNUAL        := id.KHULNA_ANNUAL;
        w_misSummaryReport.RAJSHAHI_100DS       := id.RAJSHAHI_100DS;
        w_misSummaryReport.RAJSHAHI_ANNUAL      := id.RAJSHAHI_ANNUAL;
        w_misSummaryReport.SYLHET_100DS         := id.SYLHET_100DS;
        w_misSummaryReport.SYLHET_ANNUAL        := id.SYLHET_ANNUAL;
        w_misSummaryReport.BARISAL_100DS        := id.BARISAL_100DS;
        w_misSummaryReport.BARISAL_ANNUAL       := id.BARISAL_ANNUAL;
        w_misSummaryReport.RANGPUR_100DS        := id.RANGPUR_100DS;
        w_misSummaryReport.RANGPUR_ANNUAL       := id.RANGPUR_ANNUAL;
        w_misSummaryReport.MYMENSING_100DS      := id.MYMENSING_100DS;
        w_misSummaryReport.MYMENSING_ANNUAL     := id.MYMENSING_ANNUAL;
        w_misSummaryReport.FARIDPUR_100DS       := id.FARIDPUR_100DS;
        w_misSummaryReport.FARIDPUR_ANNUAL      := id.FARIDPUR_ANNUAL;
      
        w_misSummaryReport.total_100days := nvl(id.DHAKA_NORTH_100DS, 0) +
                                            nvl(id.DHAKA_SOUTH_100DS, 0) +
                                            nvl(id.CHATTOGRAM_100DS, 0) +
                                            nvl(id.KHULNA_100DS, 0) +
                                            nvl(id.RAJSHAHI_100DS, 0) +
                                            nvl(id.SYLHET_100DS, 0) +
                                            nvl(id.BARISAL_100DS, 0) +
                                            nvl(id.RANGPUR_100DS, 0) +
                                            nvl(id.MYMENSING_100DS, 0) +
                                            nvl(id.FARIDPUR_100DS, 0);
        w_misSummaryReport.total_Annual  := nvl(id.DHAKA_NORTH_ANNUAL, 0) +
                                            nvl(id.DHAKA_SOUTH_ANNUAL, 0) +
                                            nvl(id.CHATTOGRAM_ANNUAL, 0) +
                                            nvl(id.KHULNA_ANNUAL, 0) +
                                            nvl(id.RAJSHAHI_ANNUAL, 0) +
                                            nvl(id.SYLHET_ANNUAL, 0) +
                                            nvl(id.BARISAL_ANNUAL, 0) +
                                            nvl(id.RANGPUR_ANNUAL, 0) +
                                            nvl(id.MYMENSING_ANNUAL, 0) +
                                            nvl(id.FARIDPUR_ANNUAL, 0);
      
        pipe row(w_misSummaryReport);
      end loop;
    end loop;
  
    FOR index1 IN 4 .. 6 LOOP
      for id in (SELECT OPERATION_CODE,
                        OPERATION_ACTIVITIES,
                        '03' SUBOP_CODE,
                        'Total ' subop_activities,
                        DESCRIPTION,
                        sum(DHAKA_NORTH_100DS) DHAKA_NORTH_100DS,
                        sum(DHAKA_NORTH_ANNUAL) DHAKA_NORTH_ANNUAL,
                        sum(DHAKA_SOUTH_100DS) DHAKA_SOUTH_100DS,
                        sum(DHAKA_SOUTH_ANNUAL) DHAKA_SOUTH_ANNUAL,
                        sum(CHATTOGRAM_100DS) CHATTOGRAM_100DS,
                        sum(CHATTOGRAM_ANNUAL) CHATTOGRAM_ANNUAL,
                        sum(KHULNA_100DS) KHULNA_100DS,
                        sum(KHULNA_ANNUAL) KHULNA_ANNUAL,
                        sum(RAJSHAHI_100DS) RAJSHAHI_100DS,
                        sum(RAJSHAHI_ANNUAL) RAJSHAHI_ANNUAL,
                        sum(SYLHET_100DS) SYLHET_100DS,
                        sum(SYLHET_ANNUAL) SYLHET_ANNUAL,
                        sum(BARISAL_100DS) BARISAL_100DS,
                        sum(BARISAL_ANNUAL) BARISAL_ANNUAL,
                        sum(RANGPUR_100DS) RANGPUR_100DS,
                        sum(RANGPUR_ANNUAL) RANGPUR_ANNUAL,
                        sum(MYMENSING_100DS) MYMENSING_100DS,
                        sum(MYMENSING_ANNUAL) MYMENSING_ANNUAL,
                        sum(FARIDPUR_100DS) FARIDPUR_100DS,
                        sum(FARIDPUR_ANNUAL) FARIDPUR_ANNUAL
                   FROM table(pkg_mis_rpt.fn_summary_report_others(''))
                  where OPERATION_CODE = index1
                    and DESCRIPTION = 'Target'
                  group by OPERATION_CODE, OPERATION_ACTIVITIES, DESCRIPTION) loop
        for idx in (SELECT OPERATION_CODE,
                           OPERATION_ACTIVITIES,
                           '03' SUBOP_CODE,
                           'Total ' subop_activities,
                           DESCRIPTION,
                           sum(DHAKA_NORTH_100DS) DHAKA_NORTH_100DS,
                           sum(DHAKA_NORTH_ANNUAL) DHAKA_NORTH_ANNUAL,
                           sum(DHAKA_SOUTH_100DS) DHAKA_SOUTH_100DS,
                           sum(DHAKA_SOUTH_ANNUAL) DHAKA_SOUTH_ANNUAL,
                           sum(CHATTOGRAM_100DS) CHATTOGRAM_100DS,
                           sum(CHATTOGRAM_ANNUAL) CHATTOGRAM_ANNUAL,
                           sum(KHULNA_100DS) KHULNA_100DS,
                           sum(KHULNA_ANNUAL) KHULNA_ANNUAL,
                           sum(RAJSHAHI_100DS) RAJSHAHI_100DS,
                           sum(RAJSHAHI_ANNUAL) RAJSHAHI_ANNUAL,
                           sum(SYLHET_100DS) SYLHET_100DS,
                           sum(SYLHET_ANNUAL) SYLHET_ANNUAL,
                           sum(BARISAL_100DS) BARISAL_100DS,
                           sum(BARISAL_ANNUAL) BARISAL_ANNUAL,
                           sum(RANGPUR_100DS) RANGPUR_100DS,
                           sum(RANGPUR_ANNUAL) RANGPUR_ANNUAL,
                           sum(MYMENSING_100DS) MYMENSING_100DS,
                           sum(MYMENSING_ANNUAL) MYMENSING_ANNUAL,
                           sum(FARIDPUR_100DS) FARIDPUR_100DS,
                           sum(FARIDPUR_ANNUAL) FARIDPUR_ANNUAL
                      FROM table(pkg_mis_rpt.fn_summary_report_others(''))
                     where OPERATION_CODE = index1
                       and DESCRIPTION = 'Achievement'
                     group by OPERATION_CODE,
                              OPERATION_ACTIVITIES,
                              DESCRIPTION) loop
        
          w_misSummaryReport.OPERATION_CODE       := id.OPERATION_CODE;
          w_misSummaryReport.OPERATION_ACTIVITIES := id.OPERATION_ACTIVITIES;
          w_misSummaryReport.SUBOP_CODE           := id.SUBOP_CODE;
          w_misSummaryReport.SUBOP_ACTIVITIES     := id.SUBOP_ACTIVITIES;
          w_misSummaryReport.DESCRIPTION          := 'Achievement(%)';
          w_misSummaryReport.DHAKA_NORTH_100DS    := idx.DHAKA_NORTH_100DS /
                                                     id.DHAKA_NORTH_100DS;
          w_misSummaryReport.DHAKA_NORTH_ANNUAL   := idx.DHAKA_NORTH_ANNUAL /
                                                     id.DHAKA_NORTH_ANNUAL;
          w_misSummaryReport.DHAKA_SOUTH_100DS    := idx.DHAKA_SOUTH_100DS /
                                                     id.DHAKA_SOUTH_100DS;
          w_misSummaryReport.DHAKA_SOUTH_ANNUAL   := idx.DHAKA_SOUTH_ANNUAL /
                                                     id.DHAKA_SOUTH_ANNUAL;
          w_misSummaryReport.CHATTOGRAM_100DS     := idx.CHATTOGRAM_100DS /
                                                     id.CHATTOGRAM_100DS;
          w_misSummaryReport.CHATTOGRAM_ANNUAL    := idx.CHATTOGRAM_ANNUAL /
                                                     id.CHATTOGRAM_ANNUAL;
          w_misSummaryReport.KHULNA_100DS         := idx.KHULNA_100DS /
                                                     id.KHULNA_100DS;
          w_misSummaryReport.KHULNA_ANNUAL        := id.KHULNA_ANNUAL /
                                                     id.KHULNA_ANNUAL;
          w_misSummaryReport.RAJSHAHI_100DS       := idx.RAJSHAHI_100DS /
                                                     id.RAJSHAHI_100DS;
          w_misSummaryReport.RAJSHAHI_ANNUAL      := idx.RAJSHAHI_ANNUAL /
                                                     id.RAJSHAHI_ANNUAL;
          if id.SYLHET_100DS = 0 then
            w_misSummaryReport.SYLHET_100DS := 0;
          else
            w_misSummaryReport.SYLHET_100DS := idx.SYLHET_100DS /
                                               id.SYLHET_100DS;
          end if;
        
          if id.SYLHET_ANNUAL = 0 then
            w_misSummaryReport.SYLHET_ANNUAL := 0;
          else
            w_misSummaryReport.SYLHET_ANNUAL := idx.SYLHET_ANNUAL /
                                                id.SYLHET_ANNUAL;
          end if;
        
          if id.BARISAL_100DS = 0 then
            w_misSummaryReport.BARISAL_100DS := 0;
          else
            w_misSummaryReport.BARISAL_100DS := idx.BARISAL_100DS /
                                                id.BARISAL_100DS;
          end if;
        
          if id.BARISAL_ANNUAL = 0 then
            w_misSummaryReport.BARISAL_ANNUAL := 0;
          else
            w_misSummaryReport.BARISAL_ANNUAL := idx.BARISAL_ANNUAL /
                                                 id.BARISAL_ANNUAL;
          end if;
        
          w_misSummaryReport.RANGPUR_100DS    := idx.RANGPUR_100DS /
                                                 id.RANGPUR_100DS;
          w_misSummaryReport.RANGPUR_ANNUAL   := idx.RANGPUR_ANNUAL /
                                                 id.RANGPUR_ANNUAL;
          w_misSummaryReport.MYMENSING_100DS  := idx.MYMENSING_100DS /
                                                 id.MYMENSING_100DS;
          w_misSummaryReport.MYMENSING_ANNUAL := idx.MYMENSING_ANNUAL /
                                                 id.MYMENSING_ANNUAL;
        
          if id.FARIDPUR_100DS = 0 then
            w_misSummaryReport.FARIDPUR_100DS := 0;
          else
            w_misSummaryReport.FARIDPUR_100DS := idx.FARIDPUR_100DS /
                                                 id.FARIDPUR_100DS;
          end if;
        
          if id.FARIDPUR_ANNUAL = 0 then
            w_misSummaryReport.FARIDPUR_ANNUAL := 0;
          else
            w_misSummaryReport.FARIDPUR_ANNUAL := idx.FARIDPUR_ANNUAL /
                                                  id.FARIDPUR_ANNUAL;
          end if;
        
          w_misSummaryReport.total_100days := (nvl(idx.DHAKA_NORTH_100DS, 0) +
                                              nvl(idx.DHAKA_SOUTH_100DS, 0) +
                                              nvl(idx.CHATTOGRAM_100DS, 0) +
                                              nvl(idx.KHULNA_100DS, 0) +
                                              nvl(idx.RAJSHAHI_100DS, 0) +
                                              nvl(idx.SYLHET_100DS, 0) +
                                              nvl(idx.BARISAL_100DS, 0) +
                                              nvl(idx.RANGPUR_100DS, 0) +
                                              nvl(idx.MYMENSING_100DS, 0) +
                                              nvl(idx.FARIDPUR_100DS, 0)) /
                                              (nvl(id.DHAKA_NORTH_100DS, 0) +
                                              nvl(id.DHAKA_SOUTH_100DS, 0) +
                                              nvl(id.CHATTOGRAM_100DS, 0) +
                                              nvl(id.KHULNA_100DS, 0) +
                                              nvl(id.RAJSHAHI_100DS, 0) +
                                              nvl(id.SYLHET_100DS, 0) +
                                              nvl(id.BARISAL_100DS, 0) +
                                              nvl(id.RANGPUR_100DS, 0) +
                                              nvl(id.MYMENSING_100DS, 0) +
                                              nvl(id.FARIDPUR_100DS, 0)) * 100;
        
          w_misSummaryReport.total_Annual := (nvl(idx.DHAKA_NORTH_ANNUAL, 0) +
                                             nvl(idx.DHAKA_SOUTH_ANNUAL, 0) +
                                             nvl(idx.CHATTOGRAM_ANNUAL, 0) +
                                             nvl(idx.KHULNA_ANNUAL, 0) +
                                             nvl(idx.RAJSHAHI_ANNUAL, 0) +
                                             nvl(idx.SYLHET_ANNUAL, 0) +
                                             nvl(idx.BARISAL_ANNUAL, 0) +
                                             nvl(idx.RANGPUR_ANNUAL, 0) +
                                             nvl(idx.MYMENSING_ANNUAL, 0) +
                                             nvl(idx.FARIDPUR_ANNUAL, 0)) /
                                             (nvl(id.DHAKA_NORTH_ANNUAL, 0) +
                                             nvl(id.DHAKA_SOUTH_ANNUAL, 0) +
                                             nvl(id.CHATTOGRAM_ANNUAL, 0) +
                                             nvl(id.KHULNA_ANNUAL, 0) +
                                             nvl(id.RAJSHAHI_ANNUAL, 0) +
                                             nvl(id.SYLHET_ANNUAL, 0) +
                                             nvl(id.BARISAL_ANNUAL, 0) +
                                             nvl(id.RANGPUR_ANNUAL, 0) +
                                             nvl(id.MYMENSING_ANNUAL, 0) +
                                             nvl(id.FARIDPUR_ANNUAL, 0)) * 100;
        
          pipe row(w_misSummaryReport);
        end loop;
      end loop;
    end loop;
  
  end fn_summary_mis_others;

begin
  null;
end pkg_mis_rpt;
/
