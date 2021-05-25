create database Test;
use Test;
create table MyData
(
	ID int primary key,
    Name varchar(20),
    Email varchar(20),
    Password varchar(20)
);

select * from MyData
