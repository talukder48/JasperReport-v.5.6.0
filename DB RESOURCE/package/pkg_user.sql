create or replace package pkg_user is
procedure sp_user_creation(p_userid in varchar2,p_user_name in varchar2,p_userRole in char,p_branch_code in varchar2,p_user_pass in varchar2,p_check_role in char,p_auth_role in char,p_user_id in varchar2,p_error out varchar2);
  

end pkg_user;
/
create or replace package body pkg_user is
  procedure sp_user_creation(p_userid      in varchar2,
                             p_user_name   in varchar2,
                             p_userRole    in char,
                             p_branch_code in varchar2,
                             p_user_pass   in varchar2,
                             p_check_role  in char,
                             p_auth_role   in char,
                             p_user_id     in varchar2,
                             p_error       out varchar2) is
    v_exist number := 0;
  begin
    select count(*)
      into v_exist
      from erp_user u
     where u.user_id = p_userid;
    if v_exist = 0 then
      insert into erp_user
        (user_id,
         user_name,
         user_password,
         user_branch,
         user_role,
         check_role,
         auth_role,
         entd_by,
         entd_on)
      values
        (p_userid,
         p_user_name,
         p_user_pass,
         p_branch_code,
         p_userRole,
         p_check_role,
         p_auth_role,
         p_user_id,
         trunc(sysdate));
    else
      update erp_user u
         set u.user_name     = p_user_name,
             u.user_password = p_user_pass,
             u.user_branch   = p_branch_code,
             u.user_role     = p_userRole,
             u.check_role    = p_check_role,
             u.auth_role     = p_auth_role,
             u.mod_by        = p_user_id,
             u.mod_on        = trunc(sysdate)
       where u.user_id = p_userid;
    end if;
  exception
    when others then
      p_error := 'Error in sp_user_creation' || sqlerrm;
  end sp_user_creation;
begin
  null;
end pkg_user;
/
