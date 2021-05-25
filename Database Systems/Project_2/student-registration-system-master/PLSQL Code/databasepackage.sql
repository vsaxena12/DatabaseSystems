create or replace package databaseproject is

PROCEDURE show_logs(logs_cur OUT SYS_REFCURSOR);
PROCEDURE show_students(students_cur OUT SYS_REFCURSOR);
PROCEDURE show_courses(courses_cur OUT SYS_REFCURSOR);
PROCEDURE show_enrollments(enrollments_cur OUT SYS_REFCURSOR);
PROCEDURE show_classes(classes_cur OUT SYS_REFCURSOR);
PROCEDURE show_PREREQUISITES(PREREQUISITES_cur OUT SYS_REFCURSOR);

PROCEDURE student_validity_check(sidIn IN students.sid%TYPE,flag OUT boolean);
PROCEDURE emailid_validity_check(emailIn IN students.email%TYPE, flag OUT boolean);
PROCEDURE convert_boolean (flagIn IN boolean, flagOut OUT number);
PROCEDURE insert_student (sidIn IN students.sid%type, firstnameIn IN students.firstname%type, 
						lastnameIn IN students.lastname%type, statusIn IN students.status%type, gpaIn IN students.gpa%type, 
						emailIn IN students.email%type,eflag OUT number, sflag OUT number);


PROCEDURE get_student_info(sidIn IN students.sid%TYPE,students_cur OUT SYS_REFCURSOR,classes_cur OUT SYS_REFCURSOR);

procedure get_prerequisites(dept_codeIn in prerequisites.dept_code%type, 
						course_noIn in prerequisites.course_no%type, prerequisites_cur out SYS_REFCURSOR);


PROCEDURE get_class_info(classidIn IN classes.classid%TYPE,class_cur OUT SYS_REFCURSOR,students_cur OUT SYS_REFCURSOR);


PROCEDURE class_validity_check(classidIn IN classes.classid%TYPE, flag OUT boolean);
PROCEDURE class_space_availability_check(classidIn IN classes.classid%TYPE, flag OUT boolean);
PROCEDURE enrollment_check(sidIn IN students.sid%TYPE,classidIn IN classes.classid%TYPE, flag OUT boolean);
PROCEDURE enrollment_count_check(sidIn IN students.sid%TYPE,classidIn IN classes.classid%TYPE, current_enrollment_count OUT number);
procedure CHECK_PREREQUISITES_GRADES(sidIn IN students.sid%type,classidIn IN classes.classid%type, flag OUT boolean);
PROCEDURE enrollment_student(sidIn IN students.sid%TYPE,classidIn IN classes.classid%TYPE,status OUT Number, enrollement_count OUT number);

procedure prerequiste_voilation_check(sidIn IN students.sid%TYPE,classidIn IN classes.classid%TYPE,flag OUT boolean);
procedure last_class_check(sidIn IN students.sid%TYPE, status OUT Number);
procedure last_student_check(classidIn IN classes.classid%TYPE, status OUT Number);
procedure drop_enrollment(sidIn IN students.sid%TYPE, classidIn IN classes.classid%TYPE, 
						status OUT Number, last_class OUT Number, last_student OUT Number);


procedure delete_student(sidIn IN students.sid%TYPE, status OUT Number);

end databaseproject;
/

create or replace package body databaseproject is

PROCEDURE show_logs(logs_cur OUT SYS_REFCURSOR)
IS
BEGIN
    open logs_cur for 
    select * from logs;
END show_logs;


PROCEDURE show_students(students_cur OUT SYS_REFCURSOR)
IS
BEGIN
    open students_cur for 
    select * from students;
END show_students;


PROCEDURE show_courses(courses_cur OUT SYS_REFCURSOR)
IS
BEGIN
    open courses_cur for 
    select * from courses;
END show_courses;


PROCEDURE show_enrollments(enrollments_cur OUT SYS_REFCURSOR)
IS
BEGIN
    open enrollments_cur for 
    select * from enrollments;
END show_enrollments;


PROCEDURE show_classes(classes_cur OUT SYS_REFCURSOR)
IS
BEGIN
    open classes_cur for 
    select * from classes;
END show_classes;

PROCEDURE show_PREREQUISITES(PREREQUISITES_cur OUT SYS_REFCURSOR)
IS
BEGIN
    open PREREQUISITES_cur for 
    select * from PREREQUISITES;
END show_PREREQUISITES;

PROCEDURE emailid_validity_check(emailIn IN students.email%TYPE, flag OUT boolean)
As
i number;
Begin
select COUNT(*) into i from students where email = emailIn;
if (i != 0) then
  flag := true;
else
  flag := false;
end if;
end emailid_validity_check;


PROCEDURE student_validity_check(sidIn IN students.sid%TYPE,flag OUT boolean)
As
i number;
Begin
select COUNT(*) into i from students where sid = sidIn;
if (i != 0) then
  flag := true;
else
  flag := false;
end if;
end student_validity_check;


PROCEDURE convert_boolean 
(flagIn IN boolean, 
flagOut OUT number)
as
Begin
if (flagIn = true)
  then flagOut := 1;
  else
  flagOut:=0;
  end if;
end convert_boolean;


PROCEDURE insert_student 
(sidIn IN students.sid%type, 
firstnameIn IN students.firstname%type, 
lastnameIn IN students.lastname%type, 
statusIn IN students.status%type,
gpaIn IN students.gpa%type, 
emailIn IN students.email%type,
eflag OUT number,
sflag OUT number)
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
      commit;
  end if;
end if;
CONVERT_BOOLEAN(sid_flag,sflag);
CONVERT_BOOLEAN(email_flag,eflag);
END insert_student;


PROCEDURE get_student_info(sidIn IN students.sid%TYPE,students_cur OUT SYS_REFCURSOR,classes_cur OUT SYS_REFCURSOR)
As
Begin
  open students_cur for
  select sid,lastname,status from STUDENTS where sid = sidIn;
  open classes_cur for
  select cl.classid, concat(cl.dept_code,cl.course_no) as course_id,co.title,cl.year,cl.semester 
  from classes cl, courses co 
  where cl.dept_code = co.DEPT_CODE and cl.course_no=co.course_no;
end get_student_info;

procedure get_prerequisites(dept_codeIn in prerequisites.dept_code%type, 
course_noIn in prerequisites.course_no%type, prerequisites_cur out SYS_REFCURSOR )
IS
    cursor pre_req_cursor is
    select pre_dept_code, pre_course_no from prerequisites 
    where dept_code = dept_codeIn and course_no =course_noIn;
	
	prerequisites_row pre_req_cursor%rowtype;    
	
	begin
		insert into temp select pre_dept_code,pre_course_no from prerequisites where dept_code=dept_codeIn and course_no=course_noIn;
		OPEN pre_req_cursor;
		LOOP 
			fetch pre_req_cursor into prerequisites_row;
			EXIT when pre_req_cursor%NOTFOUND;
		get_prerequisites(prerequisites_row.pre_dept_code,prerequisites_row.pre_course_no,prerequisites_cur);
    END LOOP; 
    OPEN prerequisites_cur FOR 
      select * from temp;
    close pre_req_cursor;
END get_prerequisites;


PROCEDURE get_class_info(classidIn IN classes.classid%TYPE,class_cur OUT SYS_REFCURSOR,students_cur OUT SYS_REFCURSOR)
As
Begin
  open class_cur for
  select cl.classid,co.title,cl.semester,cl.year from CLASSES cl,COURSES co 
  where classid = classidIn  and cl.DEPT_CODE = co.DEPT_CODE and cl.COURSE_NO = co.COURSE_NO;
  open students_cur for
  select e.sid,s.lastname 
  from students s, enrollments e 
  where e.CLASSID = classidIn and e.sid = s.sid;
end get_class_info;



PROCEDURE class_validity_check(classidIn IN classes.classid%TYPE, flag OUT boolean)
As
i number;
Begin
select COUNT(*) into i from classes where classid = classidIn;
if (i != 0) then
  flag := true;
else
  flag := false;
end if;
end class_validity_check;


PROCEDURE class_space_availability_check(classidIn IN classes.classid%TYPE, flag OUT boolean)
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
end class_space_availability_check;


PROCEDURE enrollment_check(sidIn IN students.sid%TYPE,classidIn IN classes.classid%TYPE, flag OUT boolean)
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
end enrollment_check;



PROCEDURE enrollment_count_check(sidIn IN students.sid%TYPE,classidIn IN classes.classid%TYPE, current_enrollment_count OUT number)
As
current_semester classes.semester%type;
current_year classes.year%type;
begin
select count(*) into current_enrollment_count from enrollments where sid = sidIn and classid in 
(select classid from classes where (semester,year) in 
(select semester,year from classes where classid = classidIn));
end enrollment_count_check;


procedure CHECK_PREREQUISITES_GRADES(sidIn IN students.sid%type,classidIn IN classes.classid%type, flag OUT boolean)
AS
i INT;
j INT;
begin
select count(*) into i from  prerequisites  where (DEPT_CODE,COURSE_NO)in (select dept_code,COURSE_NO from classes where classid  = classidIn);
select count(classid) into j from ENROLLMENTS where lgrade <= 'D' and sid = sidIn and classid in(
select classid from classes where (DEPT_CODE,COURSE_NO) in (select PRE_DEPT_CODE,PRE_COURSE_NO from prerequisites  where (DEPT_CODE,COURSE_NO)in (select dept_code,COURSE_NO from classes where classid  = classidIn))); 
if (i=j) then
  flag := true;
else 
  flag := false;
end if;
end CHECK_PREREQUISITES_GRADES;




PROCEDURE enrollment_student(sidIn IN students.sid%TYPE,classidIn IN classes.classid%TYPE,
status OUT Number,
enrollement_count OUT number)
as
valid_sid  boolean;
valid_classid  boolean;
valid_class_size  boolean;
enrollement_check  boolean;
prerequisites_check  boolean;

begin
student_validity_check(sidIn,valid_sid);
class_validity_check(classidIn,valid_classid );
class_space_availability_check(classidIn,valid_class_size);
enrollment_check(sidIn,classidIn,enrollement_check);
enrollment_count_check(sidIn,classidIn,enrollement_count);
CHECK_PREREQUISITES_GRADES(sidIn,classidIn,prerequisites_check);
if(valid_sid = true) then
  if(valid_classid = true) then
    if(valid_class_size = true) then  
        if(enrollement_check = false) then 
          if(enrollement_count < 3) then
            if(prerequisites_check = true ) then
                insert into ENROLLMENTS (SID,CLASSID) values (sidIn,classidIn);
                	commit;
                status :=1;
              else
              status :=2;
              end if;
          else
             status :=3;
          end if;
        else
          status :=4;
        end if;
    else
      status :=5;
    end if;
  else
    status :=6;
  end if;
else
  status :=7;
end if;
end enrollment_student;


procedure prerequiste_voilation_check(sidIn IN students.sid%TYPE,
classidIn IN classes.classid%TYPE,
flag OUT boolean)
As 
i int;
begin
select count(*) into i from enrollments where sid = sidIn and  classid in(  
select classid from classes where (dept_code,course_no) in 
(select dept_code,course_no from PREREQUISITES where (pre_dept_code,pre_course_no) in
(select dept_code,course_no from classes where classid = classidIn)));
if (i>0) then
flag := true;
else
flag := false;
end if;
end prerequiste_voilation_check;



procedure last_class_check(sidIn IN students.sid%TYPE, status OUT Number)
as
i int;
begin
SELECT count(*) into i FROM enrollments where sid  = sidIn;
if(i = 0) then
status := 1;
else
status := 0;
end if;
end last_class_check;


procedure last_student_check(classidIn IN classes.classid%TYPE, status OUT Number)
as
i int;
begin
SELECT count(*) into i FROM enrollments where classid  = classidIn;
if(i = 0) then
status := 1;
else
status := 0;
end if;
end last_student_check;


procedure drop_enrollment(sidIn IN students.sid%TYPE,
classidIn IN classes.classid%TYPE,
status OUT Number,
last_class OUT Number,
last_student OUT Number)
As 
valid_sid  boolean;
valid_classid  boolean;
enrollement_check boolean;
prerequiste_check boolean;
Begin
last_class := 0;
last_student := 0;
student_validity_check(sidIn,valid_sid);
class_validity_check(classidIn,valid_classid );
enrollment_check(sidIn,classidIn,enrollement_check); 
prerequiste_voilation_check(sidIn,classidIn,prerequiste_check);
if(valid_sid = true) then
  if(valid_classid = true) then
    if(enrollement_check = true) then
      if(prerequiste_check = false) then
        delete from enrollments where sid = sidIn and classid = classidIn;
        	commit;
        last_class_check(sidIn,last_class);
        last_student_check(classidIn,last_student);
        status:=1;
      else
        status:=2;
      end if;
    else
      status:=3;
    end if;
  else
    status:=4;
  end if;
else
  status:=5;
end if;
end drop_enrollment;


  

procedure delete_student(sidIn IN students.sid%TYPE, status OUT Number)
as
valid_sid  boolean;
begin
valid_sid := false;
student_validity_check(sidIn,valid_sid);
if(valid_sid = true) then
  delete from students WHERE sid = sidIn;
  	commit;
  status := 1;
else
  status := 2;
end if;
end delete_student;


end databaseproject;
/