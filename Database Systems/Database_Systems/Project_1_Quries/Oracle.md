##Tables:
students
tas
courses
course_credit
classes
enrollments

##DML

1. create table <tablename>
2. alter table <tablename> ... add|modify
3. drop table <tablename>;
4. truncate table <tablename>;
5. rename table1 to table2
-------------------------------------------------------------------------------------------------------------------------
Students(B#, first_name, last_name, status, gpa, email, bdate, deptname)
TAs(B#, ta_level, office)
Courses(dept_code, course#, title)
Course_credit(course#, credits)
Classes(classid, dept_code, course#, sect#, year, semester, limit, class_size, room, TA_B#)
Enrollments(B#, classid, lgrade)

##Catch
1. Connection is using primary keys

##Query 1:
Find the B#, the first name and last name of every CS student whose GPA is higher than 3.5. In the output,
first name and last name of each student should be concatenated with a space in between under a new
column header name.

select B#, (first_name||' '|| last_name) as Name from students where gpa>3.5 and deptname='CS';

##Query 2:
For each TA from the CS department, find his/her B#, first name, last name and birth date. The header of
the last column needs to be “birth date” (without the quotes and there is a space between birth and date). To
not have header “birth date” truncated in the output, run SQL> column “birth date” format a10 before
you run your query, here 10 is the new column/header width in character for “birth date”.)

COLUMN "birth date" format a10;
select s.B#, s.first_name, s.last_name, s.bdate as "birth date" from students s where deptname='CS' and s.B# in
(select t.B# from tas t where t.B#=s.B#);

##Query 3:
For each class that has a PhD student TA, find its classid, dept_code and course# as well as the TA’s name
and email. Here a TA’s name is its first name followed by its last name with a space in between.
Furthermore, in the output, dept_code and course# of each class are concatenated under a new column
header course_id. Make sure that no column header in the output is truncated without manually editing the
spool file.

select classid, dept_code, course# from classes where classid in (select classid from enrollments where B# in (select B# from tas where B# in (select first_name, email from students where status = 'PhD')));


##Query 4:
Find the B#, first name, last name and GPA of each student who has taken at least one CS course and at
least one math course. Write an SQL query that uses neither intersect nor distinct but the results have no
duplicate.

select B#, firstname, lastname, gpa from students where B# in
((select B# from enrollments where classid in
(select classid from classes where dept_code.e1 = 'CS'))
intersect
(select B# from enrollments where classid in
(select classid from classes where dept_code = 'Math')));

##Query 5:
Find the B#, first name and last name of each student who has taken at least one course but has never
received an A for any course he/she has taken. Write a query with an uncorrelated subquery and write
another query with a correlated subquery.

select s.B#, s.first_name, s.last_name from students s where exists
(select e.B# from enrollments e where s.B#=e.B# and e.B# not in
(select e.B# from enrollments e where lgrade = 'A'));

##Query 8
Find the B# and the total number of credits of each student.

