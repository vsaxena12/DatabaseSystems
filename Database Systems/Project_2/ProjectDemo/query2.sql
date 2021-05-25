set serveroutput on
CREATE OR REPLACE PROCEDURE show_students IS
cursor c1 is
select * from students;
c1_rec c1%rowtype;
begin
if(not c1%isopen) then
open c1;
end if;
fetch c1 into c1_rec;
while c1%found loop
dbms_output.put_line(c1_rec.B#||','||c1_rec.first_name||','||c1_rec.last_name||$
fetch c1 into c1_rec;
end loop;
close c1;
end;
/
show errors

