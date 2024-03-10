CREATE DATABASE Library;
--@block
USE Library;

DROP PROCEDURE IF EXISTS DisplayBooksByGenre;
DROP PROCEDURE IF EXISTS DisplayEmployeesByRole;


DROP PROCEDURE IF EXISTS InsertBook;
DROP PROCEDURE IF EXISTS UpdateBook;
DROP PROCEDURE IF EXISTS DeleteBook;
DROP PROCEDURE IF EXISTS InsertMember;
DROP PROCEDURE IF EXISTS UpdateMember;
DROP PROCEDURE IF EXISTS DeleteMember;


DROP VIEW IF EXISTS Books_and_Copies;
DROP VIEW IF EXISTS Member_Checkouts;
DROP VIEW IF EXISTS Branch_Inventory;
DROP VIEW IF EXISTS Employee_Roles;



DROP TABLE IF EXISTS Fine;
DROP TABLE IF EXISTS Checkout;
DROP TABLE IF EXISTS Book_Copies;
DROP TABLE IF EXISTS Inventory;
DROP TABLE IF EXISTS Employees;
DROP TABLE IF EXISTS Members;
DROP TABLE IF EXISTS Job_Roles;
DROP TABLE IF EXISTS Branch;
DROP TABLE IF EXISTS Books;
DROP TABLE IF EXISTS Genres;
DROP TABLE IF EXISTS Publishers;
DROP TABLE IF EXISTS Statuses;

--@block
USE Library;

-- 1/3 Dictionary/LookUp Tables
CREATE TABLE Genres (
  Genre_ID INT(10) PRIMARY KEY AUTO_INCREMENT,
  Genre_Name VARCHAR(50)
);

-- 2/3 Dictionary/LookUp Tables
CREATE TABLE Publishers (
  Publisher_ID INT(10) PRIMARY KEY AUTO_INCREMENT,
  Publisher_Name VARCHAR(50)
);

-- 3/3 Dictionary/LookUp Tables
CREATE TABLE Statuses (
  Status_ID INT(10) PRIMARY KEY AUTO_INCREMENT,
  Status_Name VARCHAR(20)
);

CREATE TABLE Books (
  Book_ID INT(10) PRIMARY KEY AUTO_INCREMENT,
  Title VARCHAR(100),
  Author VARCHAR(100),
  ISBN VARCHAR(20),
  Genre_ID INT(10),
  Publisher_ID INT(10),
  Publication_Date DATE,
  FOREIGN KEY (Genre_ID) REFERENCES Genres(Genre_ID),
  FOREIGN KEY (Publisher_ID) REFERENCES Publishers(Publisher_ID)
);


CREATE TABLE Branch (
  Branch_ID INT(10) PRIMARY KEY AUTO_INCREMENT,
  Branch_Name VARCHAR(50),
  House_No VARCHAR(10),
  Lane VARCHAR(50),
  Address1 VARCHAR(50),
  Address2 VARCHAR(50),
  City VARCHAR(50),
  State VARCHAR(50),
  Pincode VARCHAR(10),
  Phone_INT VARCHAR(20),
  Email VARCHAR(50)
);

CREATE TABLE Book_Copies (
  Copy_ID INT(10) PRIMARY KEY AUTO_INCREMENT,
  Book_ID INT(10),
  Branch_ID INT(10),
  Status_ID INT(10),
  Due_Date DATE,
  FOREIGN KEY (Book_ID) REFERENCES Books(Book_ID),
  FOREIGN KEY (Branch_ID) REFERENCES Branch(Branch_ID),
  FOREIGN KEY (Status_ID) REFERENCES Statuses(Status_ID)
);

CREATE TABLE Members (
  Member_ID INT(10) PRIMARY KEY AUTO_INCREMENT,
  First_Name VARCHAR(50),
  Last_Name VARCHAR(50),
  Phone_INT VARCHAR(20),
  Email VARCHAR(50),
  House_No VARCHAR(10),
  Lane VARCHAR(50),
  Address1 VARCHAR(50),
  Address2 VARCHAR(50),
  City VARCHAR(50),
  State VARCHAR(50),
  Pincode VARCHAR(10),
  Membership_Expiration_Date DATE
);

CREATE TABLE Checkout (
  Checkout_ID INT(10) PRIMARY KEY AUTO_INCREMENT,
  Member_ID INT(10),
  Copy_ID INT(10),
  Checkout_Date DATE,
  Due_Date DATE,
  Return_Date DATE,
  FOREIGN KEY (Member_ID) REFERENCES Members(Member_ID),
  FOREIGN KEY (Copy_ID) REFERENCES Book_Copies(Copy_ID)
);

CREATE TABLE Fine (
  Fine_ID INT(10) PRIMARY KEY AUTO_INCREMENT,
  Member_ID INT(10),
  Copy_ID INT(10),
  Fine_Amount DECIMAL(10, 2),
  Fine_Date DATE,
  Status_ID INT(10),
  FOREIGN KEY (Member_ID) REFERENCES Members(Member_ID),
  FOREIGN KEY (Copy_ID) REFERENCES Book_Copies(Copy_ID),
  FOREIGN KEY (Status_ID) REFERENCES Statuses(Status_ID)
);

CREATE TABLE Job_Roles (
  Role_ID INT(10) PRIMARY KEY AUTO_INCREMENT,
  Role_Name VARCHAR(50),
  Salary INT
  );

CREATE TABLE Employees (
  Employee_ID INT(10) PRIMARY KEY AUTO_INCREMENT,
  Role_ID INT(10),
  First_Name VARCHAR(50),
  Last_Name VARCHAR(50),
  Phone_INT VARCHAR(20),
  Email VARCHAR(50),
  House_No VARCHAR(10),
  Lane VARCHAR(50),
  Address1 VARCHAR(50),
  Address2 VARCHAR(50),
  City VARCHAR(50),
  State VARCHAR(50),
  Pincode VARCHAR(10),
  Date_of_Hire DATE,
  FOREIGN KEY (Role_ID) REFERENCES Job_Roles(Role_ID)
);

CREATE TABLE Inventory (
  Inventory_ID INT(10) PRIMARY KEY AUTO_INCREMENT,
  Branch_ID INT(10),
  Book_ID INT(10),
  Quantity INT(10),
  Date_Added DATE,
  Date_Modified DATE,
  FOREIGN KEY (Branch_ID) REFERENCES Branch(Branch_ID),
  FOREIGN KEY (Book_ID) REFERENCES Books(Book_ID)
);

-- 3. Zaprojektowac kilka (3+) widoków umozliwiajacych wygenerowanie zestawien z kilku
-- tabel, np. wypozyczenia po terminie, wszystkie aktywne wypozyczenia, ksiazki, które
-- obecnie nie sa dostepne do wypozyczenia, itp.

-- Four Multi-Table VIEWS 
CREATE VIEW Books_and_Copies AS
SELECT B.Title, B.Author, BC.Copy_ID, S.Status_Name
FROM Books B
JOIN Book_Copies BC ON B.Book_ID = BC.Book_ID
JOIN Statuses S ON BC.Status_ID = S.Status_ID;

CREATE VIEW Member_Checkouts AS
SELECT M.First_Name, M.Last_Name, B.Title, C.Due_Date
FROM Members M
JOIN Checkout C ON M.Member_ID = C.Member_ID
JOIN Book_Copies BC ON C.Copy_ID = BC.Copy_ID
JOIN Books B ON BC.Book_ID = B.Book_ID;

CREATE VIEW Branch_Inventory AS
SELECT Br.Branch_Name, B.Title, I.Quantity
FROM Branch Br
JOIN Inventory I ON Br.Branch_ID = I.Branch_ID
JOIN Books B ON I.Book_ID = B.Book_ID;


CREATE VIEW Employee_Roles AS
SELECT E.First_Name, E.Last_Name, JR.Role_Name, JR.Salary
FROM Employees E
JOIN Job_Roles JR ON E.Role_ID = JR.Role_ID;

-- 4. Zaprojektować procedury składowane dla operacji insert, update i delete dla tabel, na których beda one czesto wykonywane

CREATE PROCEDURE InsertBook(
    IN p_Title VARCHAR(100),
    IN p_Author VARCHAR(100),
    IN p_ISBN VARCHAR(20),
    IN p_Genre_ID VARCHAR(50),
    IN p_Publisher_ID VARCHAR(50),
    IN p_Publication_Date DATE)
BEGIN
    INSERT INTO Books(Title, Author, ISBN, Genre_ID, Publisher_ID, Publication_Date)
    VALUES (p_Title, p_Author, p_ISBN, p_Genre_ID, p_Publisher_ID, p_Publication_Date);
END;


CREATE PROCEDURE UpdateBook(
    IN p_Book_ID INT(10),
    IN p_Title VARCHAR(100),
    IN p_Author VARCHAR(100),
    IN p_ISBN VARCHAR(20),
    IN p_Genre_ID INT(10),
    IN p_Publisher_ID INT(10),
    IN p_Publication_Date DATE)
BEGIN
    UPDATE Books
    SET Title = p_Title, Author = p_Author, ISBN = p_ISBN, Genre_ID = p_Genre_ID, Publisher_ID = p_Publisher_ID, Publication_Date = p_Publication_Date
    WHERE Book_ID = p_Book_ID;
END;


CREATE PROCEDURE DeleteBook(
    IN p_Book_ID INT(10))
BEGIN
    DELETE FROM Books
    WHERE Book_ID = p_Book_ID;
END;


CREATE PROCEDURE InsertMember(
    IN p_First_Name VARCHAR(50),
    IN p_Last_Name VARCHAR(50),
    IN p_Phone_INT VARCHAR(20),
    IN p_Email VARCHAR(50),
    IN p_House_No VARCHAR(10),
    IN p_Lane VARCHAR(50),
    IN p_Address1 VARCHAR(50),
    IN p_Address2 VARCHAR(50),
    IN p_City VARCHAR(50),
    IN p_State VARCHAR(50),
    IN p_Pincode VARCHAR(10),
    IN p_Membership_Expiration_Date DATE)
BEGIN
    INSERT INTO Members(First_Name, Last_Name, Phone_INT, Email, House_No, Lane, Address1, Address2, City, State, Pincode, Membership_Expiration_Date)
    VALUES (p_First_Name, p_Last_Name, p_Phone_INT, p_Email, p_House_No, p_Lane, p_Address1, p_Address2, p_City, p_State, p_Pincode, p_Membership_Expiration_Date);
END;


CREATE PROCEDURE UpdateMember(
    IN p_Member_ID INT(10),
    IN p_First_Name VARCHAR(50),
    IN p_Last_Name VARCHAR(50),
    IN p_Phone_INT VARCHAR(20),
    IN p_Email VARCHAR(50),
    IN p_House_No VARCHAR(10),
    IN p_Lane VARCHAR(50),
    IN p_Address1 VARCHAR(50),
    IN p_Address2 VARCHAR(50),
    IN p_City VARCHAR(50),
    IN p_State VARCHAR(50),
    IN p_Pincode VARCHAR(10),
    IN p_Membership_Expiration_Date DATE)
BEGIN
    UPDATE Members
    SET First_Name = p_First_Name, Last_Name = p_Last_Name, Phone_INT = p_Phone_INT, Email = p_Email, House_No = p_House_No, Lane = p_Lane, Address1 = p_Address1, Address2 = p_Address2, City = p_City, State = p_State, Pincode = p_Pincode, Membership_Expiration_Date = p_Membership_Expiration_Date
    WHERE Member_ID = p_Member_ID;
END;

CREATE PROCEDURE DeleteMember(
    IN p_Member_ID INT(10))
BEGIN
    DELETE FROM Members
    WHERE Member_ID = p_Member_ID;
END;


-- 5. Zaprojektowac procedury skladowane umozliwiajace sparametryzowane wyswietlanie
-- danych, np. wszystkie aktywne wypozyczenia danego uzytkownika, wszystkie
-- wypozyczenia danej ksiazki, itp.

CREATE PROCEDURE DisplayBooksByGenre(
    IN p_Genre_ID INT(10))
BEGIN
    SELECT * FROM Books
    WHERE Genre_ID = p_Genre_ID;
END;

CREATE PROCEDURE DisplayEmployeesByRole(
    IN p_Role_ID INT(10))
BEGIN
    SELECT * FROM Employees
    WHERE Role_ID = p_Role_ID;
END;

-- 6. *) Dokonac migracji (opracowac skrypt SQL) zaprojektowanej bazy danych do innego srodowiska np. SOLite albo MySQL.