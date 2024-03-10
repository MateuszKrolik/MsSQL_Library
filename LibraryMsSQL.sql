CREATE DATABASE Library;
GO

USE Library;
GO

DROP PROCEDURE IF EXISTS DisplayBooksByGenre;
GO

DROP PROCEDURE IF EXISTS DisplayEmployeesByRole;
GO

DROP PROCEDURE IF EXISTS InsertBook;
GO

DROP PROCEDURE IF EXISTS UpdateBook;
GO

DROP PROCEDURE IF EXISTS DeleteBook;
GO

DROP PROCEDURE IF EXISTS InsertMember;
GO

DROP PROCEDURE IF EXISTS UpdateMember;
GO

DROP PROCEDURE IF EXISTS DeleteMember;
GO

DROP VIEW IF EXISTS Books_and_Copies;
GO

DROP VIEW IF EXISTS Member_Checkouts;
GO

DROP VIEW IF EXISTS Branch_Inventory;
GO

DROP VIEW IF EXISTS Employee_Roles;
GO

DROP TABLE IF EXISTS Fine;
GO

DROP TABLE IF EXISTS Checkout;
GO

DROP TABLE IF EXISTS Book_Copies;
GO

DROP TABLE IF EXISTS Inventory;
GO

DROP TABLE IF EXISTS Employees;
GO

DROP TABLE IF EXISTS Members;
GO

DROP TABLE IF EXISTS Job_Roles;
GO

DROP TABLE IF EXISTS Branch;
GO

DROP TABLE IF EXISTS Books;
GO

DROP TABLE IF EXISTS Genres;
GO

DROP TABLE IF EXISTS Publishers;
GO

DROP TABLE IF EXISTS Statuses;
GO

-- 1/3 Dictionary/LookUp Tables
CREATE TABLE Genres (
  Genre_ID INT PRIMARY KEY IDENTITY(1,1),
  Genre_Name NVARCHAR(50)
);

-- 2/3 Dictionary/LookUp Tables
CREATE TABLE Publishers (
  Publisher_ID INT PRIMARY KEY IDENTITY(1,1),
  Publisher_Name NVARCHAR(50)
);

-- 3/3 Dictionary/LookUp Tables
CREATE TABLE Statuses (
  Status_ID INT PRIMARY KEY IDENTITY(1,1),
  Status_Name NVARCHAR(20)
);

CREATE TABLE Books (
  Book_ID INT PRIMARY KEY IDENTITY(1,1),
  Title NVARCHAR(100),
  Author NVARCHAR(100),
  ISBN NVARCHAR(20),
  Genre_ID INT,
  Publisher_ID INT,
  Publication_Date DATE,
  FOREIGN KEY (Genre_ID) REFERENCES Genres(Genre_ID),
  FOREIGN KEY (Publisher_ID) REFERENCES Publishers(Publisher_ID)
);


CREATE TABLE Branch (
  Branch_ID INT PRIMARY KEY IDENTITY(1,1),
  Branch_Name NVARCHAR(50),
  House_No NVARCHAR(10),
  Lane NVARCHAR(50),
  Address1 NVARCHAR(50),
  Address2 NVARCHAR(50),
  City NVARCHAR(50),
  State NVARCHAR(50),
  Pincode NVARCHAR(10),
  Phone_INT NVARCHAR(20),
  Email NVARCHAR(50)
);

CREATE TABLE Book_Copies (
  Copy_ID INT PRIMARY KEY IDENTITY(1,1),
  Book_ID INT,
  Branch_ID INT,
  Status_ID INT,
  Due_Date DATE,
  FOREIGN KEY (Book_ID) REFERENCES Books(Book_ID),
  FOREIGN KEY (Branch_ID) REFERENCES Branch(Branch_ID),
  FOREIGN KEY (Status_ID) REFERENCES Statuses(Status_ID)
);

CREATE TABLE Members (
  Member_ID INT PRIMARY KEY IDENTITY(1,1),
  First_Name NVARCHAR(50),
  Last_Name NVARCHAR(50),
  Phone_INT NVARCHAR(20),
  Email NVARCHAR(50),
  House_No NVARCHAR(10),
  Lane NVARCHAR(50),
  Address1 NVARCHAR(50),
  Address2 NVARCHAR(50),
  City NVARCHAR(50),
  State NVARCHAR(50),
  Pincode NVARCHAR(10),
  Membership_Expiration_Date DATE
);

CREATE TABLE Checkout (
  Checkout_ID INT PRIMARY KEY IDENTITY(1,1),
  Member_ID INT,
  Copy_ID INT,
  Checkout_Date DATE,
  Due_Date DATE,
  Return_Date DATE,
  FOREIGN KEY (Member_ID) REFERENCES Members(Member_ID),
  FOREIGN KEY (Copy_ID) REFERENCES Book_Copies(Copy_ID)
);

CREATE TABLE Fine (
  Fine_ID INT PRIMARY KEY IDENTITY(1,1),
  Member_ID INT,
  Copy_ID INT,
  Fine_Amount DECIMAL(10, 2),
  Fine_Date DATE,
  Status_ID INT,
  FOREIGN KEY (Member_ID) REFERENCES Members(Member_ID),
  FOREIGN KEY (Copy_ID) REFERENCES Book_Copies(Copy_ID),
  FOREIGN KEY (Status_ID) REFERENCES Statuses(Status_ID)
);

CREATE TABLE Job_Roles (
  Role_ID INT PRIMARY KEY IDENTITY(1,1),
  Role_Name NVARCHAR(50),
  Salary INT
);

CREATE TABLE Employees (
  Employee_ID INT PRIMARY KEY IDENTITY(1,1),
  Role_ID INT,
  First_Name NVARCHAR(50),
  Last_Name NVARCHAR(50),
  Phone_INT NVARCHAR(20),
  Email NVARCHAR(50),
  House_No NVARCHAR(10),
  Lane NVARCHAR(50),
  Address1 NVARCHAR(50),
  Address2 NVARCHAR(50),
  City NVARCHAR(50),
  State NVARCHAR(50),
  Pincode NVARCHAR(10),
  Date_of_Hire DATE,
  FOREIGN KEY (Role_ID) REFERENCES Job_Roles(Role_ID)
);

CREATE TABLE Inventory (
  Inventory_ID INT PRIMARY KEY IDENTITY(1,1),
  Branch_ID INT,
  Book_ID INT,
  Quantity INT,
  Date_Added DATE,
  Date_Modified DATE,
  FOREIGN KEY (Branch_ID) REFERENCES Branch(Branch_ID),
  FOREIGN KEY (Book_ID) REFERENCES Books(Book_ID)
);

-- 3. Zaprojektowac kilka (3+) widoków umozliwiajacych wygenerowanie zestawien z kilku
-- tabel, np. wypozyczenia po terminie, wszystkie aktywne wypozyczenia, ksiazki, które
-- obecnie nie sa dostepne do wypozyczenia, itp.

-- Four Multi-Table VIEWS 
GO
CREATE VIEW Books_and_Copies AS
SELECT B.Title, B.Author, BC.Copy_ID, S.Status_Name
FROM Books B
JOIN Book_Copies BC ON B.Book_ID = BC.Book_ID
JOIN Statuses S ON BC.Status_ID = S.Status_ID;

GO
CREATE VIEW Member_Checkouts AS
SELECT M.First_Name, M.Last_Name, B.Title, C.Due_Date
FROM Members M
JOIN Checkout C ON M.Member_ID = C.Member_ID
JOIN Book_Copies BC ON C.Copy_ID = BC.Copy_ID
JOIN Books B ON BC.Book_ID = B.Book_ID;

GO
CREATE VIEW Branch_Inventory AS
SELECT Br.Branch_Name, B.Title, I.Quantity
FROM Branch Br
JOIN Inventory I ON Br.Branch_ID = I.Branch_ID
JOIN Books B ON I.Book_ID = B.Book_ID;

GO
CREATE VIEW Employee_Roles AS
SELECT E.First_Name, E.Last_Name, JR.Role_Name, JR.Salary
FROM Employees E
JOIN Job_Roles JR ON E.Role_ID = JR.Role_ID;

-- 4. Zaprojektować procedury składowane dla operacji insert, update i delete dla tabel, na których beda one czesto wykonywane

GO
CREATE PROCEDURE InsertBook
    @Title NVARCHAR(100),
    @Author NVARCHAR(100),
    @ISBN NVARCHAR(20),
    @Genre_ID INT,
    @Publisher_ID INT,
    @Publication_Date DATE
AS
BEGIN
    INSERT INTO Books(Title, Author, ISBN, Genre_ID, Publisher_ID, Publication_Date)
    VALUES (@Title, @Author, @ISBN, @Genre_ID, @Publisher_ID, @Publication_Date);
END;

GO
CREATE PROCEDURE UpdateBook
    @Book_ID INT,
    @Title NVARCHAR(100),
    @Author NVARCHAR(100),
    @ISBN NVARCHAR(20),
    @Genre_ID INT,
    @Publisher_ID INT,
    @Publication_Date DATE
AS
BEGIN
    UPDATE Books
    SET Title = @Title, Author = @Author, ISBN = @ISBN, Genre_ID = @Genre_ID, Publisher_ID = @Publisher_ID, Publication_Date = @Publication_Date
    WHERE Book_ID = @Book_ID;
END;

GO
CREATE PROCEDURE DeleteBook
    @Book_ID INT
AS
BEGIN
    DELETE FROM Books
    WHERE Book_ID = @Book_ID;
END;

GO
CREATE PROCEDURE InsertMember
    @First_Name NVARCHAR(50),
    @Last_Name NVARCHAR(50),
    @Phone_INT NVARCHAR(20),
    @Email NVARCHAR(50),
    @House_No NVARCHAR(10),
    @Lane NVARCHAR(50),
    @Address1 NVARCHAR(50),
    @Address2 NVARCHAR(50),
    @City NVARCHAR(50),
    @State NVARCHAR(50),
    @Pincode NVARCHAR(10),
    @Membership_Expiration_Date DATE
AS
BEGIN
    INSERT INTO Members(First_Name, Last_Name, Phone_INT, Email, House_No, Lane, Address1, Address2, City, State, Pincode, Membership_Expiration_Date)
    VALUES (@First_Name, @Last_Name, @Phone_INT, @Email, @House_No, @Lane, @Address1, @Address2, @City, @State, @Pincode, @Membership_Expiration_Date);
END;

GO
CREATE PROCEDURE UpdateMember
    @Member_ID INT,
    @First_Name NVARCHAR(50),
    @Last_Name NVARCHAR(50),
    @Phone_INT NVARCHAR(20),
    @Email NVARCHAR(50),
    @House_No NVARCHAR(10),
    @Lane NVARCHAR(50),
    @Address1 NVARCHAR(50),
    @Address2 NVARCHAR(50),
    @City NVARCHAR(50),
    @State NVARCHAR(50),
    @Pincode NVARCHAR(10),
    @Membership_Expiration_Date DATE
AS
BEGIN
    UPDATE Members
    SET First_Name = @First_Name, Last_Name = @Last_Name, Phone_INT = @Phone_INT, Email = @Email, House_No = @House_No, Lane = @Lane, Address1 = @Address1, Address2 = @Address2, City = @City, State = @State, Pincode = @Pincode, Membership_Expiration_Date = @Membership_Expiration_Date
    WHERE Member_ID = @Member_ID;
END;

GO
CREATE PROCEDURE DeleteMember
    @Member_ID INT
AS
BEGIN
    DELETE FROM Members
    WHERE Member_ID = @Member_ID;
END;

-- 5. Zaprojektowac procedury skladowane umozliwiajace sparametryzowane wyswietlanie
-- danych, np. wszystkie aktywne wypozyczenia danego uzytkownika, wszystkie
-- wypozyczenia danej ksiazki, itp.

GO
CREATE PROCEDURE DisplayBooksByGenre
    @Genre_ID INT
AS
BEGIN
    SELECT * FROM Books
    WHERE Genre_ID = @Genre_ID;
END;

GO
CREATE PROCEDURE DisplayEmployeesByRole
    @Role_ID INT
AS
BEGIN
    SELECT * FROM Employees
    WHERE Role_ID = @Role_ID;
END;

-- 6. *) Dokonac migracji (opracowac skrypt SQL) zaprojektowanej bazy danych do innego srodowiska np. SOLite albo MySQL.