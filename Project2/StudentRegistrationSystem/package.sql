set serveroutput on;

Drop trigger enrollments_insert;
Drop trigger enrollments_delete;
Drop trigger student_delete;
Drop table temp_prerequisites;
Create table temp_prerequisites(dept_code varchar2(4) not null,course# number(3) not null);

--Q.1.
--Sequence
--Done by: Varun Saxena
DROP SEQUENCE logs_seq;
CREATE SEQUENCE logs_seq
increment by 1
START WITH 100;


--Package Started
Create or replace package student_registration AS

  --Q.2.
  procedure show_students(student_cursor out sys_refcursor);
  procedure show_courses(student_cursor out sys_refcursor);
  procedure show_TAs(student_cursor out sys_refcursor);
  procedure show_classes(student_cursor out sys_refcursor);
  procedure show_enrollments(student_cursor out sys_refcursor);
  procedure show_prerequisites(student_cursor out sys_refcursor);
  procedure show_logs(student_cursor out sys_refcursor);

  --Q.3.
  procedure ta_info(v_classid in Classes.classid%type,error_message out varchar2,r_cursor out sys_refcursor);

  --Q.4.

  procedure get_prerequisites(v_dept_code in courses.dept_code%type,v_course# in courses.course#%type,error_message out varchar2,r_cursor out 
sys_refcursor);

  --Q.5.

  procedure enroll_student(v_B# in students.B#%type,v_classid in classes.classid%type,error_message out varchar2);

  --Q.6.

  procedure drop_student(dropB# in Students.B#%type,dropClassid in Classes.Classid%type,error_message out varchar2);

  --Q.7.

  procedure del_student(delB# IN Students.B#%type,error_message out varchar2);

END;
/

create or replace package body student_registration AS

  --Q.2.
  --Done by: Varun Saxena
  /*  students table */

  procedure show_students(student_cursor out
  sys_refcursor) AS
  BEGIN
        open student_cursor for
        select * from students;
  END;


  /* courses table */

  procedure show_courses(student_cursor out
  sys_refcursor) AS
  BEGIN
        open student_cursor for
        SELECT * FROM COURSES;
  END;


  /* TAs table */

  procedure show_TAs(student_cursor out sys_refcursor)
  AS
  BEGIN
        open student_cursor for
        select * from TAs;
  End;




  /* classes table */

  procedure show_classes(student_cursor out
  sys_refcursor) as
  BEGIN
        open student_cursor for
        select * from classes;
  END;



/* enrollments table */

  procedure show_enrollments(student_cursor out
  sys_refcursor)
  AS
  BEGIN
        open student_cursor for
        select * from enrollments;
  END;



/* prerequisites table */

  procedure show_prerequisites(student_cursor out
  sys_refcursor) AS
  BEGIN
        open student_cursor for
        select * from prerequisites;
  END;




/* logs table */

  procedure show_logs(student_cursor out sys_refcursor)
  AS
  BEGIN
        open student_cursor for
        select * from logs;
  END;

  --Q.3.
  --Done by: Varun Saxena


  procedure ta_info (v_classid in Classes.classid%type,error_message out varchar2,r_cursor out sys_refcursor)
  is v_data_found_classid Number;
  v_data_found_TA Number;

  Begin
        SELECT count(*) into v_data_found_classid from Classes WHERE classid =  v_classid;
        select count(*) into v_data_found_TA FROM TAs,Classes WHERE TAs.B# = Classes.TA_B# AND Classes.classid = v_classid;

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

  --Q.4.
  --Done by: Varun Saxena

  procedure get_prerequisites(v_dept_code in courses.dept_code%type,v_course# in courses.course#%type,error_message out varchar2,r_cursor out 
sys_refcursor) is
  v_found_dept_code_course# Number;
  cursor prereq_cursor is
  select pre_dept_code,pre_course# from prerequisites
  where dept_code = v_dept_code
  and course# = v_course#;
  v_found_prereq Number;

  prereq_record prereq_cursor%rowtype;

  BEGIN
      SELECT count(*) into v_found_dept_code_course# FROM Courses WHERE
      dept_code = v_dept_code and course# = v_course#;
      SELECT count(*) into v_found_prereq FROM Prerequisites WHERE dept_code = v_dept_code and course# = v_course#;
      if (v_found_dept_code_course# = 0) THEN
          error_message := v_dept_code||v_course#||' does not exist';
      else
         if (v_found_prereq = 0) THEN
           error_message:= v_dept_code||v_course#||' does not exist';


         else
        insert into temp_prerequisites select pre_dept_code,pre_course# from
        prerequisites where dept_code = v_dept_code and course# =
        v_course#;
        open prereq_cursor;
        loop
          fetch prereq_cursor into prereq_record;
          exit when prereq_cursor%notfound;

          get_prerequisites(prereq_record.pre_dept_code,prereq_record.pre_course#,error_message,r_cursor);
        end loop;
      open r_cursor for select * from temp_prerequisites;
      close prereq_cursor;
    end if;
   end if;
  end;


  --Q.5.
  --Done by: Kundan Shrivastav

  procedure enroll_student(v_B# in students.B#%type,
  v_classid in classes.classid%type,error_message out varchar2) is
  v_student_B# Number;
  v_student_classid Number;
  v_class_sem Number;
  v_student_in_sem Number;
  v_capacity Number;
  v_student_overloaded Number;
  v_count_prereqs Number;
  v_count_classid_prereqs Number;
  Begin
    Select count(*) into v_student_B# from Students where B# = v_B#;

    Select count(*) into v_student_classid from Classes where classid = v_classid;

    if (v_student_classid > 0) then
      select count(*) into v_class_sem from classes where classid = v_classid
      and year = 2018 and semester = 'Fall';
      select LIMIT-class_size into v_capacity from classes where classid =
      v_classid;
    end if;

    Select count(*) into v_student_in_sem from enrollments where B# = v_B#
    and classid = v_classid;

    Select count(*) into v_student_overloaded from enrollments e,classes c
    where e.B# = v_B# and e.classid = c.classid and c.year = 2018 and c.semester = 'Fall';

    Select count(*) into v_count_prereqs from prerequisites where
    (dept_code,course#) in (Select dept_code,course# from classes where classid = v_classid);

    Select count(classid) into v_count_classid_prereqs from enrollments where lgrade <= 'C'
    and B# = v_B# and classid in (Select classid from classes where (dept_code,course#) in
    (Select pre_dept_code,pre_course# from prerequisites where (dept_code,course#) in (Select
    dept_code,course# from classes where classid = v_classid)));

    if (v_student_B# = 0) then
      error_message := 'The B# is invalid';
    elsif (v_student_classid = 0) then
      error_message := 'The classid is invalid';
    elsif (v_class_sem = 0) then
      error_message := 'Cannot enroll into a class from a previous semester';
    elsif (v_capacity = 0) then
      error_message := 'The class is already full';
    elsif (v_student_in_sem <> 0) then
      error_message := 'The student is already in the class';
    elsif (v_count_prereqs <> v_count_classid_prereqs) then
      error_message := 'Prerequisite not satisfied';
    elsif (v_student_overloaded = 4) then
      error_message := 'The student will be overloaded with the new
      enrollment';
      INSERT INTO Enrollments(B#,classid) VALUES (v_B#,v_classid);
    elsif (v_student_overloaded > 4) then
      error_message := 'Students cannot be enrolled in more than five classes
      in the same semester';
    else
      INSERT into Enrollments(B#,classid) VALUES (v_B#,v_classid);
    end if;
  end;


  --Q.6.
  --Done by: Sean Gallagher


  procedure drop_student(
	dropB# in Students.B#%type,
	dropClassid in Classes.Classid%type,error_message out varchar2) IS

	--Local declarations
	count_B# Students.B#%type;
	count_Classid Classes.Classid%type;
	count_Enrollment Enrollments.B#%type;
	tempSemester Classes.Semester%type;
	tempYear Classes.Year%type;
	dCode Classes.DEPT_CODE%type;
	c# Classes.Course#%type;
	countPre Number;
	newSize Classes.Class_size%type;
	numClasses Number;

  BEGIN
    SELECT count(*)
    INTO count_B# FROM Students WHERE B# = dropB#;
    SELECT count(*)
    INTO count_Classid FROM Classes WHERE Classid = dropClassid;
    SELECT count(*)
    INTO count_Enrollment FROM Enrollments WHERE B# = dropB# and Classid = dropClassid;
    IF (count_B# = 0) THEN
      error_message := 'The B# is invalid';
    ELSIF (count_Classid = 0) THEN
      error_message := 'The classid is invalid';
    ELSIF (count_Enrollment = 0) THEN
      error_message := 'The student is not enrolled in the class';
    ELSE

	     SELECT SEMESTER, YEAR
	     INTO tempSemester, tempYear FROM CLASSES WHERE Classid = dropClassid;
	     IF tempSemester != 'Fall' or tempYear != 2018 THEN
		       error_message := 'Only enrollment in the current semester can be dropped.';
		       RETURN;
	     END IF;
	    SELECT DEPT_CODE, COURSE#
	     INTO dCode, c# FROM CLASSES WHERE Classid = dropClassid;
	      SELECT count(DEPT_CODE) INTO countPre
	       FROM PREREQUISITES WHERE DEPT_CODE in
		       (SELECT DEPT_CODE FROM CLASSES WHERE Classid in
			        (SELECT Classid FROM ENROLLMENTS WHERE B# = dropB#)) and
	             COURSE# in (SELECT COURSE# FROM Classes WHERE Classid in
				           (SELECT Classid FROM Enrollments WHERE B# = dropB#))
	                  and PRE_DEPT_CODE = dCode and PRE_COURSE# = c#;
	                   IF countPre != 0 THEN
		                     error_message := 'The drop is not permitted because another class the student registered uses it as a 
prerequisite.';
		                       RETURN;
	                   END IF;
	     DELETE FROM Enrollments WHERE B# = dropB# and Classid = dropClassid;
	     SELECT class_size INTO newSize
	      FROM Classes WHERE Classid = dropClassid;
	       IF newSize = 0 THEN
		         error_message := 'The class now has no students';
	       END IF;
	      SELECT COUNT(Classid) into numClasses
	      FROM Enrollments WHERE B# = dropB#;
	      IF numClasses = 0 THEN
		        error_message := 'This student is not enrolled in any classes';
	      END IF;
    END IF;
  END;



  --Q.7.
  --Done by: Sean Gallagher

  procedure del_student(
  delB# IN Students.B#%type,error_message out varchar2) IS

  --local
  count_B# Students.B#%type;

  BEGIN
    SELECT COUNT(*) into count_B# FROM Students Where B# = delB#;


    IF (count_B# = 0) THEN
          error_message := 'The B# is invalid';
    ELSE
          DELETE Students WHERE B# = delB#;
          Commit;
    END IF;
  END;
END;
/
show errors;

 --Triggers
 --Done by: Kundan Shrivastav

 create or replace trigger enrollments_insert
 after insert on enrollments
 for each row
 Declare
  user_log varchar2(20);
  operation_log varchar2(20) default 'insert';
  key_value_log varchar2(50);
  B#_log enrollments.B#%type;
  classid_log enrollments.classid%type;
  table_name_log nvarchar2(20) default 'enrollments';
  id_log Number;
 Begin
  B#_log := :new.B#;
  classid_log := :new.classid;
  key_value_log := (B#_log||','||classid_log);
  id_log := logs_seq.nextval;
  select user into user_log from dual;
  Insert into logs
  values(id_log,user_log,sysdate,table_name_log,operation_log,key_value_log);
  Update classes
  set class_size = class_size+1
  where classid = classid_log;
 End;
 /

 create or replace trigger ENROLLMENTS_DELETE
 AFTER DELETE ON Enrollments
 FOR EACH ROW
 DECLARE
  user_log varchar2(20);
  operation_log varchar2(20) default 'delete';
  key_value_log varchar2(50);
  B#_log enrollments.B#%type;
  classid_log enrollments.classid%type;
  table_name_log nvarchar2(20) default 'enrollments';
  id_log Number;
 BEGIN
  B#_log := :old.B#;
  classid_log := :old.classid;
  key_value_log := (B#_log||','||classid_log);
  id_log := logs_seq.nextval;
  select user into user_log from dual;
  Insert into logs
  values(id_log,user_log,sysdate,table_name_log,operation_log,key_value_log);
  Update classes
  set class_size = class_size-1
  where classid = classid_log;
 END;
 /

 create or replace trigger STUDENT_DELETE
 AFTER DELETE ON Students
 FOR EACH ROW
 DECLARE
  user_log varchar2(20);
  operation_log varchar2(20) default 'delete';
  B#_log enrollments.B#%type;
  table_name_log nvarchar2(20) default 'students';
  id_log Number;
 BEGIN
  B#_log := :old.B#;
  id_log := logs_seq.nextval;
  select user into user_log from dual;
  Insert into logs
  values(id_log,user_log,sysdate,table_name_log,operation_log,B#_log);
  Delete From Enrollments Where B# = B#_log;
  UPDATE Classes SET TA_B# = NULL WHERE TA_B# = B#_log;
  DELETE FROM TAs WHERE B# = B#_log;
 END;
 /
show errors;

