#Final Quries

#Query1:
select B#, (first_name||' '|| last_name) as Name from students where gpa>3.5 and deptname='CS';

#Query2:
COLUMN "birth date" format a10;
select s.B#, s.first_name, s.last_name, s.bdate as "birth date" from students s where deptname='CS' and s.B# in
(select t.B# from tas t where t.B#=s.B#);

#Query3:

#Query4:

#Query5:
select s.B#, s.first_name, s.last_name from students s where exists
(select e.B# from enrollments e where s.B#=e.B# and e.B# not in
(select e.B# from enrollments e where lgrade = 'A'));

