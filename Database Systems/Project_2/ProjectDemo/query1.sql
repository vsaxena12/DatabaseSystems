CREATE SEQUENCE logs_seq
START WITH 100;


/* Insert */

INSERT INTO logs(log#,op_name,op_time,table_name,operation) VALUES
(logs_seq.nextval,'B00015','15-NOV-16','Enrollments','insert');

