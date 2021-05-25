set serveroutput on
create or replace procedure ta_info(v_classid in
Classes.classid%type,error_message out varchar2,r_cursor out sys_refcursor)
is
v_data_found_classid Number;
v_data_found_TA Number;
begin
SELECT count(*) into v_data_found_classid from Classes WHERE classid =
v_classid;
select count(*) into v_data_found_TA FROM TAs,Classes WHERE TAs.B# =
Classes.TA_B# AND Classes.classid = v_classid;
if (v_data_found_classid = 0) THEN
error_message := 'The classid is invalid';
else
if v_data_found_TA = 0 then
error_message := 'The class has no TA';
else
open r_cursor for
select students.B#,students.first_name,students.last_name
FROM Students
JOIN TAs ON Students.B# = TAs.B#
JOIN Classes ON TAs.B# = Classes.TA_B#
WHERE Classes.classid = v_classid;
end if;
end if;
end;
/
show errors;


/* to get data from the cursor */


SET SERVEROUTPUT ON
DECLARE
l_cursor SYS_REFCURSOR;
l_B# Students.B#%type;
l_first_name students.first_name%type;
l_last_name students.last_name%type;
err_message varchar2(50);
BEGIN
ta_info('c0013',err_message,l_cursor);
if (not l_cursor%isopen) then
dbms_output.put_line(err_message);
else
LOOP
fetch l_cursor
into l_B#,l_first_name,l_last_name;
EXIT when l_cursor%notfound;
dbms_output.put_line(l_B#||','||l_first_name||','||l_last_name);
END LOOP;
close l_cursor;
end if;
end;
/

