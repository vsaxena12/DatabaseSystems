create database Assessment_1

use Assessment_1

--Bank Details
create table BANKDETAILS
(
	BankID int not null Identity(1001,1) Primary Key,
	BankName varchar(50) not null Unique
);

--Branch Details
create table BRANCHDETAILS
(
	BankID int not null,
	[BranchCode] varchar(6) not null,
	BranchName varchar(30) not null,
	[IFSC Code] varchar(11) not null unique,
	Address varchar(80),
	District varchar(30),
	[State] varchar(30),
	ContactPerson varchar(25),
	ContactNumber varchar(100),
	EmailID varchar(50)
);

alter table BRANCHDETAILS
add primary key (BranchCode);

ALTER TABLE BRANCHDETAILS
ADD FOREIGN KEY (BankID) REFERENCES BANKDETAILS(BankID);

update BRANCHDETAILS
SET [IFSC Code] = SUBSTRING(BANKDETAILS.BankName,1,4) + BRANCHDETAILS.BranchCode
from BANKDETAILS, BRANCHDETAILS;


insert into BANKDETAILS(BankName) values ('STATE BANK OF INDIA');

insert into BANKDETAILS(BankName) values ('ICICI BANK');

insert into BANKDETAILS(BankName) values ('AXIS BANK');

insert into BANKDETAILS(BankName) values ('BANK OF AMERICA');


select * from BANKDETAILS;

insert into BRANCHDETAILS values (1001, 15084, 'Jubliee Hills', 'SBIN0015084', 'Silver Square', 'Hyderabad', 'Andhra Pradesh', 'Anand', '8008570355', 'Anand.bm@sbi.com');
insert into BRANCHDETAILS values (1001, 14676, 'Cyber Gateway', 'SBIN0014676', 'Plot 63, Arunodaya Colony, Near Hitech Cinema Hall Lane', 'Hyderabad', 'Andhra Pradesh', 'Ravi', '9966122261', 'Ravi.k@sbi.com');
insert into BRANCHDETAILS values (1001, 13499, 'Mahavir Nagar', 'SBIN0013499', 'Breezy Corner, Opp. Panchsheel Heights, Mahavir Nagar', 'Mumbai', 'Maharashtra', 'Sumit', '022-28684079', 'Sumit.m@sbi.com');


insert into BRANCHDETAILS values (1002, 1804, 'Nanakram Guda', 'ICIC0001804', 'financial Dist., Plot No - 12, Gachibowli', 'Hyderabad', 'Andhra Pradesh', 'Kishore Kalap', '9959617542', 'Kishore_k@icicibank.com');

insert into BRANCHDETAILS values (1003, 70, 'Guntur', 'UTIB0000070', '1st Floor, P R Raju Plaza 11- 1-1 Naaz Centre', 'Guntur', 'Andhra Pradesh', NULL, '0863522001', NULL);

insert into BRANCHDETAILS values (1002, 337, 'Pune-Satara Road', 'ICIC0000337', 'Somshankar Chambers, Plot-1, Kaka Halwai Estate, Opp. City Pride', 'Pune', 'Maharashtra', null, '02267574314 / 4322', null);

select * from BRANCHDETAILS;


-- 1 --
select count(BankID) as [Number of Branches] from BRANCHDETAILS where BankID = 1002;

-- 2 --
select BankID, BranchCode, BranchName, [IFSC Code], [Address], [District], [State], ISNULL(ContactPerson, 'NOT KNOWN'), ContactNumber, ISNULL(EmailID,'NOT KNOWN') from BRANCHDETAILS;

-- 3 --
select count(*), BankID from BRANCHDETAILS 
group by  BRANCHDETAILS.BankID
having count( BRANCHDETAILS.BankID) > 2;

-- 4 --
select * from BRANCHDETAILS 
inner join BANKDETAILS
on BRANCHDETAILS.BankID = BANKDETAILS.BankID
order by BRANCHDETAILS.BankID;

-- 5 --
select * from BRANCHDETAILS
right join BANKDETAILS
on BRANCHDETAILS.BankID = BANKDETAILS.BankID
where BRANCHDETAILS.[State] = 'Andhra Pradesh' and BANKDETAILS.BankName = 'State Bank of India';

-- 6 --
create procedure sp_BranchDetails
@BankID int,
@BranchCode varchar(6),
@BranchName varchar(30),
@IFSC_Code varchar(11),
@Address varchar(80),
@District varchar(30),
@State varchar(30),
@ContactPerson varchar(25)
as
insert into BRANCHDETAILS(BankID, BranchCode, BranchName, [IFSC Code], [Address], District, [State], ContactPerson) 
values (@BankID, @BranchCode, @BranchName, @IFSC_Code, @Address, @District, @State, @ContactPerson)

Go


drop procedure sp_BranchDetails

EXEC sp_BranchDetails
	@BankID = 1004,
	@BranchCode = 'CN6215', 
	@BranchName = 'Bank of America', 
	@IFSC_Code = 'BOFA0CN6215', 
	@Address = '748 ANNA SALAI, MOUNT ROAD', 
	@District = 'Chennai', 
	@State = 'Tamil Nadu', 
	@ContactPerson = 'RAJIV RANJAN';

select * from BRANCHDETAILS;