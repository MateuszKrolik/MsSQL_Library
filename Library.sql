-- Tasks 1-2
-- Create exactly 11 mssql-server tables for a library, of which exactly 3 dictionary.
-- Create FKs , Don't use Many-to-Many RelationShips(if impossible, create Junction Tables to handle them), Create seperate columns for PKs, Auto-increment PKs, Normalize, Index Frequent Custom Query's.
-- Tables should store info about:
-- -- 1)the book collection,
-- -- 2)authors, 
-- -- 3)users  
-- -- 4)borrowings.

-- Task 3: 
-- Design 4 views that allow generating reports from several tables such as:
-- 1)overdue borrowings, 
-- 2)all active borrowings, 
-- 3)books that are currently not available for borrowing
-- 4)most frequently borrowed books.

-- Task 4: 
-- Design stored procedures for insert, update, and delete operations for table on which they will be frequently performed.

-- Task 5: 
-- Design stored procedures that allow parameterized display of data, such as:
--  1)all active borrowings of a given user, 
--  2)all borrowings of a given book.

-- Tasks 1-2

-- 1 Table for authors
CREATE TABLE Authors (
    AuthorID INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(30) NOT NULL,
    Bio TEXT
);
CREATE INDEX idx_authors_name ON Authors(Name);

-- 2 Table for users
CREATE TABLE Users (
    UserID INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(30) NOT NULL,
    Email NVARCHAR(30) UNIQUE,
    Phone NVARCHAR(30)
);
CREATE INDEX idx_users_name ON Users(Name);

-- 3 Table for books
CREATE TABLE Books (
    BookID INT PRIMARY KEY IDENTITY(1,1),
    Title NVARCHAR(30) NOT NULL,
    ISBN NVARCHAR(13), -- International Standard Book Number, 13 digits
    PublicationYear INT
);
CREATE INDEX idx_books_title ON Books(Title);

-- 4 Junction table for books and authors
CREATE TABLE BookAuthors (
    BookID INT FOREIGN KEY REFERENCES Books(BookID),
    AuthorID INT FOREIGN KEY REFERENCES Authors(AuthorID),
    PRIMARY KEY (BookID, AuthorID)
);

-- 5 Table for borrowings
CREATE TABLE Borrowings (
    BorrowingID INT PRIMARY KEY IDENTITY(1,1),
    UserID INT FOREIGN KEY REFERENCES Users(UserID),
    BookID INT FOREIGN KEY REFERENCES Books(BookID),
    BorrowDate DATE NOT NULL,
    ReturnDate DATE
);

-- 6-8 Dictionary tables
CREATE TABLE BookStatus (
    StatusID INT PRIMARY KEY IDENTITY(1,1),
    Status NVARCHAR(30) NOT NULL
);

CREATE TABLE UserTypes (
    TypeID INT PRIMARY KEY IDENTITY(1,1),
    Type NVARCHAR(30) NOT NULL
);

CREATE TABLE BookGenres (
    GenreID INT PRIMARY KEY IDENTITY(1,1),
    Genre NVARCHAR(30) NOT NULL
);

-- 9-11 Additional tables to reach 11 tables
CREATE TABLE BookReviews (
    ReviewID INT PRIMARY KEY IDENTITY(1,1),
    UserID INT FOREIGN KEY REFERENCES Users(UserID),
    BookID INT FOREIGN KEY REFERENCES Books(BookID),
    Review TEXT,
    Rating INT
);

CREATE TABLE BookCopies (
    CopyID INT PRIMARY KEY IDENTITY(1,1),
    BookID INT FOREIGN KEY REFERENCES Books(BookID),
    StatusID INT FOREIGN KEY REFERENCES BookStatus(StatusID)
);

CREATE TABLE UserTypesMapping (
    UserID INT FOREIGN KEY REFERENCES Users(UserID),
    TypeID INT FOREIGN KEY REFERENCES UserTypes(TypeID),
    PRIMARY KEY (UserID, TypeID)
);
GO

-- Task 3: Views for reports

-- 1) Overdue borrowings
CREATE VIEW OverdueBorrowings AS
SELECT b.BorrowingID, u.Name AS UserName, bk.Title AS BookTitle, b.BorrowDate, b.ReturnDate
FROM Borrowings b
JOIN Users u ON b.UserID = u.UserID
JOIN Books bk ON b.BookID = bk.BookID
WHERE b.ReturnDate < GETDATE();
GO

-- 2) Active borrowings
CREATE VIEW ActiveBorrowings AS
SELECT b.BorrowingID, u.Name AS UserName, bk.Title AS BookTitle, b.BorrowDate, b.ReturnDate
FROM Borrowings b
JOIN Users u ON b.UserID = u.UserID
JOIN Books bk ON b.BookID = bk.BookID
WHERE b.ReturnDate IS NULL;
GO

-- 3) Books not available for borrowing
CREATE VIEW UnavailableBooks AS
SELECT bk.BookID, bk.Title
FROM Books bk
JOIN BookCopies bc ON bk.BookID = bc.BookID
JOIN BookStatus bs ON bc.StatusID = bs.StatusID
WHERE bs.Status != 'Available';
GO

-- 4) Most frequently borrowed books
CREATE VIEW MostBorrowedBooks AS
SELECT TOP 100 PERCENT bk.Title, COUNT(b.BorrowingID) AS BorrowingCount
FROM Books bk
JOIN Borrowings b ON bk.BookID = b.BookID
GROUP BY bk.Title
ORDER BY BorrowingCount DESC;
GO

-- Task 4: 

-- Assuming it's a University Library, where users are students that frequently drop out/graduate, and new students are added every year.

CREATE PROCEDURE InsertUser @Name NVARCHAR(30), @Email NVARCHAR(30), @Phone NVARCHAR(30)
AS
INSERT INTO Users (Name, Email, Phone) VALUES (@Name, @Email, @Phone);
GO

CREATE PROCEDURE UpdateUser @UserID INT, @Name NVARCHAR(30), @Email NVARCHAR(30), @Phone NVARCHAR(30)
AS
UPDATE Users SET Name = @Name, Email = @Email, Phone = @Phone WHERE UserID = @UserID;
GO

CREATE PROCEDURE DeleteUser @UserID INT
AS
DELETE FROM Users WHERE UserID = @UserID;
GO

-- Task 5: 
--  1)all active borrowings of a given user, 
CREATE PROCEDURE GetUserActiveBorrowings @UserID INT
AS
SELECT b.BorrowingID, bk.Title, b.BorrowDate, b.ReturnDate
FROM Borrowings b
JOIN Books bk ON b.BookID = bk.BookID
WHERE b.UserID = @UserID AND b.ReturnDate IS NULL;
GO

--  2)all borrowings of a given book,
CREATE PROCEDURE GetBookBorrowings @BookID INT
AS
SELECT b.BorrowingID, u.Name AS UserName, b.BorrowDate, b.ReturnDate
FROM Borrowings b
JOIN Users u ON b.UserID = u.UserID
WHERE b.BookID = @BookID;
GO