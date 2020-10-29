CREATE table customers(
ID int NOT NULL PRIMARY KEY,
SSN int NOT NULL,
firstName varchar(255) NOT NULL,
LastName varchar(255) NOT NULL,
email varchar(255) NOT NULL,
PhoneNumber varchar(100) NOT NULL
        constraint CK_MyTable_PhoneNumber check(PhoneNumber like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
Country varchar(255) NOT NULL,
State varchar(255) NOT NULL
);

CREATE table VehicleCategory(
ID int NOT NULL PRIMARY KEY,
label varchar(255) NOT NULL,
detailedescription varchar(255) NOT NULL
);

CREATE table cars(
VIN int NOT NULL PRIMARY KEY,
categoryID int,
description varchar(255) NOT NULL,
color varchar(255) NOT NULL,
brand varchar(255) NOT NULL,
model varchar(255) NOT NULL,
dateofPurchase date NOT NULL,
officeLocationID varchar(10) NOT NULL,
FOREIGN KEY (categoryID) REFERENCES VehicleCategory(ID) ON DELETE CASCADE,
FOREIGN KEY (officeLocationID) REFERENCES location(ID) ON DELETE CASCADE
);

CREATE table CarRental(
reservationNumber int NOT NULL PRIMARY KEY,
amount DECIMAL,
pickupDate date NOT NULL,
returnDate date NOT NULL,
pickupLocationID varchar(10) NOT NULL,
returnLocationID varchar(10),
CARVIN int NOT NULL,
customerID int not NULL,
FOREIGN KEY (customerID) REFERENCES customers(ID) ON DELETE CASCADE,
FOREIGN KEY (pickupLocationID) REFERENCES location(ID),
FOREIGN KEY (returnLocationID) REFERENCES location(ID)
);

CREATE table Location(
ID varchar(10) NOT NULL PRIMARY KEY,
street varchar(255) NOT NULL,
number varchar(255) NOT NULL,
city varchar(255) NOT NULL,
state varchar(255) NOT NULL,
country varchar(255) NOT NULL
);

CREATE TABLE LocationPhones
(
  ID int NOT NULL PRIMARY KEY, 
  LocationId varchar(10) NOT NULL REFERENCES Location(ID) ON DELETE CASCADE,
  PhoneNumber varchar(100) NOT NULL
        constraint check_PhoneNumber check(PhoneNumber like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]')
);

/*TASK 3a*/
SELECT C.reservationNumber, L.ID
FROM carrental as C, location as L
WHERE C.pickupLocationID = L.ID and C.pickupDate = '2015/05/20';

/*TASK 3b*/
SELECT DISTINCT c.firstname,c.lastname,c.phonenumber
FROM carrental as r
JOIN cars I on r.CARVIN = I.VIN
JOIN customers c on r.customerID = c.ID
WHERE I.categoryID = (SELECT ID
								   FROM vehiclecategory
								   WHERE label = 'luxury');


/*TASK 3c*/
SELECT c.pickupLocationID,count(c.pickupLocationID)
FROM carrental c
GROUP BY c.pickupLocationID
ORDER BY c.pickupLocationID;

/*TASK 3d*/
SELECT v.ID,MONTH(r.pickupdate),count(r.reservationNumber)
FROM carrental as r
JOIN cars I on r.CARVIN = I.VIN
JOIN vehiclecategory V on I.categoryID = V.ID
WHERE I.VIN = r.CARVIN
GROUP BY V.ID,r.pickupDate
ORDER BY V.ID;

/*TASK 3e*/
CREATE VIEW rentalState as
SELECT l.state, v.label, count(r.reservationNumber) as rentals
FROM carrental as r, location as l, cars as c, vehiclecategory as v
WHERE r.pickupLocationID=l.ID and r.CARVIN =c.VIN and c.categoryID = v.ID
GROUP BY l.state, c.categoryID
ORDER BY l.state, count(r.reservationNumber) DESC;

SELECT state, label , max(rentals) 
FROM rentalState
GROUP BY state;

/*TASK 3f*/
CREATE VIEW sumofRentals as
SELECT l.ID, count(r.reservationNumber) as rental
FROM carrental as r,location as l
WHERE MONTH(r.pickupdate) = 5 and YEAR(r.pickupdate) = 2015 and r.pickupLocationID = l.ID and (l.ID = 'NY' or l.ID = 'NJ' or l.ID = 'CA') 
GROUP BY l.ID;


SELECT 
    SUM( IF( ID = 'NY', rental, 0 ) ) AS 'NY',  
    SUM( IF( ID = 'CA', rental, 0 ) ) AS 'CA', 
    SUM( IF( ID = 'NJ', rental, 0 ) ) AS 'NJ' 
FROM sumofRentals;

/*TASK 3g*/
SELECT YEAR(pickupDate), MONTH(pickupDate), count(reservationNumber)
FROM carrental
WHERE amount>all
(SELECT avg(amount)
FROM carrental
GROUP BY MONTH(pickupDate))
and reservationNumber in
(SELECT reservationNumber
FROM carrental
WHERE YEAR(pickupDate)=2015 )
GROUP BY MONTH(pickupDate);

/*TASK 3h*/
SELECT  month(c.pickupdate), (c.amount- r.amount) * 100 / c.amount as 'Percentage Change of 2014-2015'
FROM      carrental as r
JOIN carrental as c
ON MONTH(c.pickupdate) = MONTH(r.pickupdate) AND YEAR(r.pickupdate) = YEAR(c.pickupdate) - 1 
WHERE YEAR(c.pickupdate)=2015
GROUP BY MONTH(c.pickupdate);

/*TASK 3i*/

SELECT sumofMonths - tamountThis as Previous_Months , tamountThis as This_Month , total - sumofMonths as Next_Months FROM (
	SELECT YEAR(r.pickupdate), MONTH(r.pickupdate), sum(r.amount) as tamountThis , (SELECT sum(amount) FROM carrental WHERE YEAR(carrental.pickupdate) = 2015 ) as total,
    (SELECT sum(c.amount) FROM carrental as c WHERE MONTH(c.pickupdate) <= MONTH(r.pickupdate) and YEAR(c.pickupdate) = YEAR(r.pickupdate) GROUP BY MONTH(r.pickupdate)) as sumofMonths
    FROM carrental as r 
    WHERE YEAR(r.pickupdate) = 2015
    GROUP BY MONTH(r.pickupdate)
    ORDER BY MONTH(r.pickupdate) ASC) as answer;
