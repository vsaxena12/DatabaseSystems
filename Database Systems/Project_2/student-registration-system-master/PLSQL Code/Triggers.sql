Drop trigger ENROLLMENT_INSERT;
Drop trigger ENROLLMENT_INSERT_LOG;
Drop trigger ENROLLMENT_DELETE;
Drop trigger ENROLLMENT_DELETE_LOG;
Drop trigger STUDENT_INSERT_LOG;
Drop trigger STUDENT_DELETE_LOG;


create or replace TRIGGER ENROLLMENT_DELETE
AFTER DELETE ON Enrollments 
for each row
BEGIN
  update classes set class_size = class_size-1 where classid =:new.classid;
END;
/

create or replace TRIGGER ENROLLMENT_DELETE_lOG
Before DELETE ON Enrollments 
for each row
BEGIN
Insert into LOGS (LOGID,WHO,TIME,TABLE_NAME,OPERATION,KEY_VALUE) values 
  (logs_seq.nextval,(select user from dual),sysdate,'Enrollments','delete',concat(concat(:old.sid,' '),:old.classid));
  END;
  /

  create or replace TRIGGER ENROLLMENT_INSERT 
AFTER INSERT ON Enrollments 
for each row
BEGIN
  update classes set class_size = class_size+1 where classid =:new.classid;
END;
/

create or replace TRIGGER ENROLLMENT_INSERT_LOG 
AFTER INSERT ON Enrollments 
for each row
BEGIN
  Insert into LOGS (LOGID,WHO,TIME,TABLE_NAME,OPERATION,KEY_VALUE) values 
  (logs_seq.nextval,(select user from dual),sysdate,'Enrollments','insert',concat(concat(:new.sid,' '),:new.classid));
END;

/
  
create or replace TRIGGER STUDENT_DELETE_LOG
AFTER DELETE ON Students 
for each row
BEGIN
  Insert into LOGS (LOGID,WHO,TIME,TABLE_NAME,OPERATION,KEY_VALUE) values 
  (logs_seq.nextval,(select user from dual),sysdate,'Students','delete',:old.sid);
delete from enrollments where sid = :old.sid;
END;
/


create or replace trigger STUDENT_INSERT_LOG
after insert on students 
for each row
begin
insert into Logs(logid,who,time,table_name,operation,key_value)values
  (logs_seq.NEXTVAL,(Select user from dual), sysdate,'students','insert',:new.sid);
end;

/
