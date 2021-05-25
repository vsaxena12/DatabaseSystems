create database Assessment_2

use Assessment_2;

drop table Train_Details;

create table Train_Details
(
	TrainNumber numeric(5) not null Identity(10001,1),
	TrainName varchar(40) not null,
	[Source Station] varchar(40) not null,
	Source_Departure_Time varchar(10),
	[Destination Station] varchar(40) not null,
	Destination_Arrival_Time varchar(10),
	[Number of coaches] int,
	Fare money
);


alter table Train_Details
add primary key (TrainNumber);

alter table Train_Details
alter column Source_Departure_Time varchar(20);

alter table Train_Details
alter column Destination_Arrival_Time varchar(20);

insert into Train_Details	(TrainName, 
							[Source Station], 
							Source_Departure_Time, 
							[Destination Station], 
							Destination_Arrival_Time, 
							[Number of coaches], 
							Fare) values (
							'Gorakhpur Express', 
							'Secunderabad Jn', 
							'07:20:00 Am', 
							'Gorakhpur', 
							'03:10:00 Pm', 
							20, 
							300);

insert into Train_Details	(TrainName, 
							[Source Station], 
							Source_Departure_Time, 
							[Destination Station], 
							Destination_Arrival_Time, 
							[Number of coaches], 
							Fare) values (
							'Satavahana Exp', 
							'Vijayawada Jn', 
							'06:10:00 Am', 
							'Secunderabad Jn', 
							'11:45:00 Am', 
							20, 
							280);

insert into Train_Details	(TrainName, 
							[Source Station], 
							Source_Departure_Time, 
							[Destination Station], 
							Destination_Arrival_Time, 
							[Number of coaches], 
							Fare) values (
							'Satavahana Exp', 
							'Secunderabad Jn', 
							'04:15:00 Pm', 
							'Vijayawada Jn', 
							'09:50:00 Pm', 
							20, 
							280);

insert into Train_Details	(TrainName, 
							[Source Station], 
							Source_Departure_Time, 
							[Destination Station], 
							Destination_Arrival_Time, 
							[Number of coaches], 
							Fare) values (
							'Circar Exp', 
							'Chennai Egmore', 
							'05:20:00 Pm', 
							'Kakinada Port', 
							'09:40:00 Am', 
							15, 
							320);

insert into Train_Details	(TrainName, 
							[Source Station], 
							Source_Departure_Time, 
							[Destination Station], 
							Destination_Arrival_Time, 
							[Number of coaches], 
							Fare) values (
							'Ndls Pdy Exp', 
							'New Delhi', 
							'11:50:00 Pm', 
							'Puducherry', 
							'06:45:00 Pm', 
							20, 
							450);


insert into Train_Details	(TrainName, 
							[Source Station], 
							Source_Departure_Time, 
							[Destination Station], 
							Destination_Arrival_Time, 
							[Number of coaches], 
							Fare) values (
							'Lucknow Mail', 
							'New Delhi', 
							'10:10:00 Pm', 
							'Lucknow Nr', 
							'06:45:00 Am', 
							25, 
							480);

insert into Train_Details	(TrainName, 
							[Source Station], 
							Source_Departure_Time, 
							[Destination Station], 
							Destination_Arrival_Time, 
							[Number of coaches], 
							Fare) values (
							'Mahabodhi Exp', 
							'Gaya Jn', 
							'02:30:00 Pm', 
							'New Delhi', 
							'05:00:00 Am', 
							15, 
							350);

insert into Train_Details	(TrainName, 
							[Source Station], 
							Source_Departure_Time, 
							[Destination Station], 
							Destination_Arrival_Time, 
							[Number of coaches], 
							Fare) values (
							'Prayag Raj Exp', 
							'Allahabad Jn', 
							'09:30:00 Pm', 
							'New Delhi', 
							'06:55:00 Am', 
							12, 
							397);

select * from Train_Details;

-- a --
select * from Train_Details 
where TrainName = 'Circar Exp';

-- b --
select * from Train_Details
where [Source Station] = 'New Delhi';

-- c --
select * from Train_Details
order by [Number of coaches];

-- d --
select * from Train_Details;
select [Source Station], COUNT(*) as Total_Number_Of_Trains from Train_Details group by [Source Station];

-- e --
select count(*) from Train_Details where [Destination Station] = 'New Delhi' 
and [Number of coaches] <= 15 group by [Destination Station];

-- f --
select TrainNumber, TrainName from Train_Details where Fare > (select avg(Fare) from Train_Details) order by Fare;

select * from Train_Details;

select avg(Fare) from Train_Details;

-- g --
create view View_Train_Details As
select TrainName, SUBSTRING([Source Station],1,3) AS Source_Station, 
SUBSTRING([Destination Station],1,3) As Destination_Station, Fare 
from Train_Details; 

select * from View_Train_Details;


-- h --
create procedure sp_NameFare
@TrainName varchar(40)
as
select TrainName, SUM(Fare) as Total_Fare from Train_Details where TrainName = @TrainName group by TrainName;

drop procedure sp_NameFare;

EXEC sp_NameFare @TrainName = 'Circar Exp';


-- i --
create procedure sp_TrainDetails_Insert 
@TrainName varchar(40),
@Source_Station varchar(40),
@Source_Departure_Time varchar(10),
@Destination_Station varchar(40),
@Destination_Arrival_Time varchar(10),
@Number_of_coaches int,
@Fare money
As
insert into 
Train_Details(TrainName, [Source Station], Source_Departure_Time, [Destination Station],
Destination_Arrival_Time, [Number of coaches], Fare) 
values(@TrainName, @Source_Station, @Source_Departure_Time, @Destination_Station, @Destination_Arrival_Time, @Number_of_coaches,
@Fare);

EXEC sp_TrainDetails_Insert
@TrainName = 'X',
@Source_Station = 'Y',
@Source_Departure_Time = 'Z',
@Destination_Station = 'A',
@Destination_Arrival_Time = 'B',
@Number_of_coaches  = 15,
@Fare = 300

select * from Train_Details;

drop procedure sp_TrainDetails_Insert;