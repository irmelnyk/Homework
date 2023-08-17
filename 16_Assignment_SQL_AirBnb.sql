/*1. Write SQL queries for table creation for a data model that you created for prev homework (Airbnb model)

2. Write 3 rows (using INSERT queries) for each table in the data model

3. Create the next analytic queries:

      1. Find a user who had the biggest amount of reservations. Return user name and user_id

      2. (Optional) Find a host who earned the biggest amount of money for the last month. Return hostname and host_id

      3. (Optional) Find a host with the best average rating. Return hostname and host_id*/


/* Create tables */
CREATE TABLE User_Data (
ID_User int IDENTITY(1,1) PRIMARY KEY,
First_Name varchar(50),
Last_Name varchar(50),
Email varchar(50) NOT NULL
);

CREATE TABLE Host (
ID_Host int IDENTITY(1,1) PRIMARY KEY,
ID_User int FOREIGN KEY REFERENCES User_Data(ID_User)
);

CREATE TABLE Guest (
ID_Guest int IDENTITY(1,1) PRIMARY KEY,
ID_User int FOREIGN KEY REFERENCES User_Data(ID_User)
);


CREATE TABLE Property (
ID_Property int IDENTITY(1,1) PRIMARY KEY,
ID_Host int FOREIGN KEY REFERENCES Host(ID_Host),
Price_Per_Night float,
Type_Property varchar(50),
Rooms_num int,
Max_num_guests int,
Kitchen bool
);

CREATE TABLE Reservation (
ID_Reservation int IDENTITY(1,1) PRIMARY KEY,
ID_Guest int FOREIGN KEY REFERENCES Guest(ID_Guest),
ID_Property int FOREIGN KEY REFERENCES Property(ID_Property),
Guest_Num int,
Date_Check_In date NOT NULL,
Date_Check_Out date NOT NULL,
Amount_total float
);

CREATE TABLE Payment (
ID_Payment int IDENTITY(1,1) PRIMARY KEY,
ID_Reservation int FOREIGN KEY REFERENCES Reservation (ID_Reservation),
Status_Payment varchar(50),
Amount_Payment float,
Date_Payment date,
Method_Payment varchar(50)
);

CREATE TABLE Review (
ID_Review int IDENTITY(1,1) PRIMARY KEY,
ID_Guest int FOREIGN KEY REFERENCES Guest(ID_Guest),
ID_Property int FOREIGN KEY REFERENCES Property(ID_Property),
Rating int,
Date_Review date,
Comment text(1000)
);


/* Insert data */
INSERT INTO User_Data(First_Name, Last_Name, Email) 
VALUES ( 'Martin', 'Sm', 'martin@gmail.com'), 
( 'Mark', 'Si', 'mark@gmail.com'), 
('John', 'Do', 'john@gmail.com'),
('Thomas', 'Du', 'thomas@gmail.com'),
('David', 'De', 'david@gmail.com'),
('Jack', 'Sh', 'jack@gmail.com')
;

INSERT INTO Guest(ID_User) 
VALUES (1),(2),(3)
;

INSERT INTO Host(ID_User) 
VALUES (4),(5),(6)
;

INSERT INTO Property(ID_Host, Price_Per_Night, Type_Property, Rooms_num, Max_num_guests, Kitchen) 
VALUES 
(1, 30, 'Appartment', 2, 2, 1),
(2,	200, 'House', 3, 5,	1),
(3,	50,	'Guesthouse', 2, 3, 0)
;

INSERT INTO Reservation(ID_Guest, ID_Property, Guest_Num, Date_Check_In, Date_Check_Out, Amount_Total)
VALUES 
(1, 5, 2, '2023-08-10', '2023-08-11', 30),
(2,	6, 5, '2023-08-14', '2023-08-16', 400),
(3,	7, 2, '2023-08-12', '2023-08-16', 150),
(3,	5, 2, '2023-08-12', '2023-08-13', 60)
;

INSERT INTO Payment(ID_Reservation, Status_Payment, Amount_Payment, Date_Payment, Method_Payment)
VALUES 
(1, 'Paid', 30, '2023-07-25','PayPal'),
(2,	'Paid', 400, '2023-07-29', 'Card'),
(3,	'Pending', 150, '2023-06-01','GooglePay')
;

INSERT INTO Review(ID_Guest, ID_Property, Rating, Date_Review, Comment)
VALUES 
(1, 5, 5, '2023-08-15', 'Comment'),
(2,	6, 3, '2023-08-17', 'Comment'),
(3,	7, 4, '2023-08-17', 'Comment')
;

/* Query */
/*1. Find a user who had the biggest amount of reservations. Return user name and user_id*/

WITH Reservation_Count AS(
SELECT ID_Guest, COUNT(ID_Reservation) AS Reservation_Amount
FROM Reservation
GROUP BY ID_Guest
),
Guest_Data AS(
SELECT  G.ID_Guest, U.ID_User, U.First_Name, U.Last_Name
FROM User_Data AS U
JOIN Guest AS G ON U.ID_User = G.ID_User
)
SELECT G.ID_User, G.ID_Guest, G.First_Name, G.Last_Name, R.Reservation_Amount
FROM Guest_Data AS G
JOIN Reservation_Count AS R ON G.ID_Guest = R.ID_Guest
WHERE R.Reservation_Amount = (
SELECT MAX(Reservation_Amount) 
FROM Reservation_Count
);

/*2. (Optional) Find a host who earned the biggest amount of money for the last month. 
Return hostname and host_id*/

WITH Payment_Details AS(
SELECT R.ID_Reservation, PR.ID_Host, SUM(P.Amount_Payment) AS Amount_Paid
FROM Reservation AS R
JOIN Payment AS P ON R.ID_Reservation = P.ID_Reservation
JOIN Property AS Pr ON R.ID_Property = PR.ID_Property
WHERE Status_Payment = 'Paid' 
AND P.Date_Payment >= CONVERT(DATE, DATEADD(MONTH, -1, GETDATE())) /*last month*/
GROUP BY R.ID_Reservation, PR.ID_Host
),
Host_Data AS(
SELECT H.ID_Host, U.ID_User, U.First_Name, U.Last_Name
FROM User_Data AS U
JOIN Host AS H ON U.ID_User = H.ID_User
)
SELECT H.ID_Host, H.First_Name, H.Last_Name, P.Amount_Paid
FROM Host_Data AS H
JOIN Payment_Details AS P ON H.ID_Host = P.ID_Host
WHERE P.Amount_Paid = (
SELECT MAX(Amount_Paid) 
FROM Payment_Details
);

/*3. (Optional) Find a host with the best average rating. Return hostname and host_id*/

WITH Review_Details AS(
SELECT P.ID_Property, P.ID_Host, AVG(R.Rating) AS Rating_AVG
FROM Property AS P
JOIN Review AS R ON P.ID_Property = R.ID_Property
GROUP BY P.ID_Property, P.ID_Host
),
Host_Data AS(
SELECT H.ID_Host, U.ID_User, U.First_Name, U.Last_Name
FROM User_Data AS U
JOIN Host AS H ON U.ID_User = H.ID_User
)
SELECT H.ID_Host, H.First_Name, H.Last_Name, R.Rating_AVG
FROM Host_Data AS H
JOIN Review_Details AS R ON H.ID_Host = R.ID_Host
WHERE R.Rating_AVG = (
SELECT MAX(Rating_AVG) 
FROM Review_Details
);
 