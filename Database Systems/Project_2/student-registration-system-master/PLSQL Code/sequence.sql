Drop sequence logs_seq;
create sequence logs_seq
MINVALUE 1000
MAXVALUE 9999
START with 1000
INCREMENT by 1;