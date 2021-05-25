create table students (sid char(4) primary key check (sid like 'B%'),
firstname varchar2(15) not null, lastname varchar2(15) not null, status varchar2(10)
check (status in ('freshman', 'sophomore', 'junior', 'senior', 'graduate')),
gpa number(3,2) check (gpa between 0 and 4.0), email varchar2(20) unique);

create table courses (dept_code varchar2(4) not null, course_no number(3) not null
check (course_no between 100 and 799), title varchar2(20) not null,
primary key (dept_code, course_no));

create table prerequisites (dept_code varchar2(4) not null,
course_no number(3) not null, pre_dept_code varchar2(4) not null,
pre_course_no number(3) not null,
primary key (dept_code, course_no, pre_dept_code, pre_course_no),
foreign key (dept_code, course_no) references courses on delete cascade,
foreign key (pre_dept_code, pre_course_no) references courses
on delete cascade);

create table classes (classid char(5) primary key check (classid like 'c%'),
dept_code varchar2(4) not null, course_no number(3) not null,
sect_no number(2), year number(4), semester varchar2(6)
check (semester in ('Spring', 'Fall', 'Summer')), limit number(3),
class_size number(3), foreign key (dept_code, course_no) references courses
on delete cascade, unique(dept_code, course_no, sect_no, year, semester),
check (class_size <= limit));

create table enrollments (sid char(4) references students, classid char(5) references classes,
lgrade char check (lgrade in ('A', 'B', 'C', 'D', 'F', 'I', null)), primary key (sid, classid));

create table logs (logid number(4) primary key, who varchar2(10) not null, time date not null,
table_name varchar2(20) not null, operation varchar2(6) not null, key_value varchar2(14));

--------------
--#1
create sequence logs_seq
MINVALUE 0001
MAXVALUE 9999
START with 0001
INCREMENT by 1;
--insert into logs(logid,who,time,table_name,operation) values (logs_seq.NEXTVAL,'B00021','09-NOV-16','students','insert');
--alter sequence logs_seq restart start with 1;

--#2
create or replace PROCEDURE show_students
IS
cursor student_cur IS
select * from students;
row student_cur%rowtype;
BEGIN
    for row in student_cur
    LOOP
   dbms_output.put_line(
   	'sid: '||row.sid||' '|| 
   	'firstname: '|| row.firstname||' '||
   	'lastname: '||row.lastname||' '||
   	'status: '||row.status||' '||
   	'gap: '||row.gpa||' '||
   	'email: '||row.email||' ');
  END LOOP;
END;
/



create or replace PROCEDURE show_students
IS
cursor student_cur IS
select * from students;
row student_cur%rowtype;
BEGIN
  dbms_output.put_line(
  'SID'||chr(9)||chr(9)||
  'FIRSTNAME'||chr(9)||chr(9)||chr(9)||
  'LASTNAME'||chr(9)||chr(9)||chr(9)||
  'STATUS'||chr(9)||chr(9)||chr(9)||
  'GPA'||chr(9)||chr(9)||
  'EMAIL');
    for row in student_cur
    LOOP
   dbms_output.put_line(
   	row.sid||' '||chr(9)||chr(9)||
   	row.firstname||' '||chr(9)||chr(9)||chr(9)||
   	row.lastname||' '||chr(9)||chr(9)||chr(9)||
   	row.status||' '||chr(9)||chr(9)||chr(9)||
   	row.gpa||' '||chr(9)||chr(9)||chr(9)||
   	row.email||' ');
  END LOOP;
END;
/
--#NEED FORMATTING
--#3
create or replace PROCEDURE insert_student 
(sidIn IN students.sid%type, 
firstnameIn IN students.firstname%type, 
lastnameIn IN students.lastname%type, 
statusIn IN students.status%type,
gpaIn IN students.gpa%type, 
emailIn IN students.email%type)
AS 
email_flag boolean;
sid_flag boolean;
BEGIN
student_validity_check(sidIn,sid_flag);
EMAILID_VALIDITY_CHECK(emailIn,email_flag);
if (sid_flag = false) then
  if (email_flag = false) then
    Insert into SYSTEM.STUDENTS (SID,FIRSTNAME,LASTNAME,STATUS,GPA,EMAIL) values 
      (SIDIn,FIRSTNAMEIn,LASTNAMEIn,STATUSIn,GPAIn,EMAILIn);
    else
    dbms_output.put_line('email '||emailIn||' already exists.');
  end if;
  else
  dbms_output.put_line('sid '||sidIn||' already exists.');
end if;
END;
/

create or replace PROCEDURE emailid_validity_check(emailIn IN students.email%TYPE, flag OUT boolean)
As
i number;
Begin
select COUNT(*) into i from students where email = emailIn;
if (i != 0) then
  flag := true;
else
  flag := false;
end if;
end;
/

--#6
create or replace PROCEDURE show_class_info(classidIn IN classes.classid%TYPE) AS
cursor students_info_cur IS
select sid,lastname from students where sid in (select sid from enrollments where classid  = classidIn);
cursor course_info_cur IS
select title from courses where (dept_code,course_no) in (select dept_code,course_no from classes where classid = classidIn);
cursor class_info_cur IS
select classid,semester,year from classes where classid = classidIn;
class_info class_info_cur%rowtype;
course_info course_info_cur%rowtype;
student_info students_info_cur%rowtype;
BEGIN
open course_info_cur;
open class_info_cur;
Fetch course_info_cur into course_info;
Fetch class_info_cur into class_info;
DBMS_OUTPUT.PUT_LINE('Class Information:');
DBMS_OUTPUT.PUT_LINE(class_info.classid||' '||course_info.title||' '||class_info.semester||' '||class_info.year||' ');
close course_info_cur;
close class_info_cur;
--open students_info_cur;
DBMS_OUTPUT.PUT_LINE('Students who are enrolled in class '||classidIn);
for student_info in students_info_cur
loop
DBMS_OUTPUT.PUT_LINE(student_info.sid||'   '||student_info.lastname);
end loop;
--close students_info_cur;
END;
/
--EXECUTE show_class_info('c0001');
--#validation to be done yet..no class..no students etc

--#7
create or replace PROCEDURE student_validity_check(sidIn IN students.sid%TYPE,flag OUT boolean)
As
i number;
Begin
select COUNT(*) into i from students where sid = sidIn;
if (i != 0) then
  flag := true;
else
  flag := false;
end if;
end;
/

create or replace PROCEDURE class_validity_check(classidIn IN classes.classid%TYPE, flag OUT boolean)
As
i number;
Begin
select COUNT(*) into i from classes where classsid = classidIn;
if (i != 0) then
  flag := true;
else
  flag := false;
end if;
end;
/

create or replace PROCEDURE class_space_availability_check(classidIn IN classes.classid%TYPE, flag OUT boolean)
As
class_size_var number;
limit_var number;
begin 
select class_size,limit into class_size_var,limit_var from classes where classid = classidIn;
if(class_size_var < limit_var) then
flag := true;
else
flag := false;
end if;
end;
/

create or replace PROCEDURE enrollment_check(sidIn IN students.sid%TYPE,classidIn IN classes.classid%TYPE, flag OUT boolean)
AS
enrollment_count number;
begin
select count(*) into enrollment_count from enrollments where sid = sidIn and classid = classidIn;
IF enrollment_count>0
then
flag := true;
else
flag := false;
end if;
end;
/


create or replace PROCEDURE enrollment_count_check(sidIn IN students.sid%TYPE,classidIn IN classes.classid%TYPE, current_enrollment_count OUT number)
As
current_semester classes.semester%type;
current_year classes.year%type;
begin
select count(*) into current_enrollment_count from enrollments where sid = sidIn and classid in 
(select classid from classes where (semester,year) in 
(select semester,year from classes where classid = classidIn));
end;
/
declare enroll_count number;
begin
enrollment_count_check('B002','c0001',enroll_count);
dbms_output.put_line('enroll_count: '||enroll_count);
end;
/

create or replace PROCEDURE enrollment_student(sidIn IN students.sid%TYPE,classidIn IN classes.classid%TYPE)as 
valid_sid boolean;
valid_classid boolean;
valid_class_size boolean;
enrollement_check boolean;
enrollement_count number;
prerequisites_check boolean;
begin
student_validity_check(sidIn,valid_sid);
class_validity_check(classidIn,valid_classid);
class_space_availability_check(classidIn,valid_class_size);
enrollment_check(sidIn,classidIn,enrollement_check);
enrollment_count_check(sidIn,classidIn,enrollement_count);
CHECK_PREREQUISITES_GRADES(sidIn,classidIn,prerequisites_check);
if(valid_sid = true) then
  if(valid_classid = true) then
    if(valid_class_size = true) then
    if(prerequisites_check = true) then
      if(enrollement_check = false) then
        if(enrollement_count < 3) then
          if(enrollement_count = 2) then
              insert into ENROLLMENTS (SID,CLASSID) values (sidIn,classidIn);
              dbms_output.put_line('Student '||sidIn||' is Enrolled in class '||classidIn);
              dbms_output.put_line('Student '||sidIn||' is now overloaded.');
            else
              insert into ENROLLMENTS (SID,CLASSID) values (sidIn,classidIn);
              dbms_output.put_line('Student '||sidIn||' is Enrolled in class '||classidIn);
         end if;
        else
          dbms_output.put_line(sidIn||' is already enrolled in '||enrollement_count||'classes in current semester.');
       end if;
      else
        dbms_output.put_line(sidIn||' is already enrolled in class ' ||classidIn);
      end if;
      else
      dbms_output.put_line('Prerequisite courses have not been completed');
      end if;
    else
    dbms_output.put_line(classidIn||' is closed.');
    end if;
  else
  dbms_output.put_line('classid '||classidIn|| 'is invalid.');
  end if;
  else
  dbms_output.put_line('sid '||sidIn|| 'is invalid StudentID');
end if;
end;
/

#prerequisute remaining----------------------------


declare flag boolean;
begin
student_check('B006',flag);
dbms_output.put_line(case when flag = true then 'true' else 'false' end );
end;
/
