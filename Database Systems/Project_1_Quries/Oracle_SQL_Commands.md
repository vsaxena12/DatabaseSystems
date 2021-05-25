#Oracle Database

##Open Oracle Database 
sqlplus sys as sysdba

##Create a regular user account in Oracle using the SQL command:
create user USERNAME identified by PASSWORD;

##Replace USERNAME and PASSWORD with the username and password of your choice
alter database open resetlogs;

##Grant privileges to the user account using the SQL command:
grant connect, resource to USERNAME;

##Replace USERNAME and PASSWORD with the username and password of your choice.

##Exit the sys admin shell using the SQL command:
exit

##Start the commandline shell as a regular user using the command:
sqlplus

##Oracle Database 
https://www.tutorialspoint.com/plsql/plsql_basic_syntax.htm

##Oracle Connection With Bingsuns
ssh vsaxena1@bingsuns.cc.binghamton.edu
password: Varun141092
sqlplus vsaxena1@acad111
password: varun


