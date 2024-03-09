-- Tasks 1-2:
-- Design and develop a script in MS SQL Server to create a database for a library.
-- The database should have 11 tables, of which 3 are dictionary. 
-- Create PKs and FKs. 
-- Consider whether the PK can be one of the columns representing actual data, if not, add an additional Id column.
-- The tables should allow storing information about:
-- 1)the book collection,
-- 2)authors, 
-- 3)users  
-- 4)borrowings.

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
--  2)all borrowings of a given book,

-- Tasks 1-2:
CREATE TABLE Authors (
    AuthorId INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(50) NOT NULL
);
CREATE INDEX idx_authors_on_name ON Authors(Name);

CREATE TABLE Users (
    UserId INT IDENTITY(1,1) PRIMARY KEY,
    Email NVARCHAR(50) NOT NULL UNIQUE,
    Name NVARCHAR(50) NOT NULL
);
CREATE INDEX idx_users_on_email ON Users(Email);
CREATE INDEX idx_users_on_name ON Users(Name);

CREATE TABLE Books (
    BookId INT IDENTITY(1,1) PRIMARY KEY,
    Title NVARCHAR(50) NOT NULL,
    AuthorId INT,
    Available BIT NOT NULL DEFAULT 1,
    FOREIGN KEY (AuthorId) REFERENCES Authors(AuthorId)
);
CREATE INDEX idx_books_on_title ON Books(Title);
CREATE INDEX idx_books_on_authorId ON Books(AuthorId);

CREATE TABLE Borrowings (
    BorrowingId INT IDENTITY(1,1) PRIMARY KEY,
    UserId INT,
    BookId INT,
    BorrowDate DATE NOT NULL,
    ReturnDate DATE,
    FOREIGN KEY (UserId) REFERENCES Users(UserId),
    FOREIGN KEY (BookId) REFERENCES Books(BookId)
);
CREATE INDEX idx_borrowings_on_userId ON Borrowings(UserId);
CREATE INDEX idx_borrowings_on_bookId ON Borrowings(BookId);

CREATE TABLE Publishers (
    PublisherId INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(50) NOT NULL
);
CREATE INDEX idx_publishers_on_name ON Publishers(Name);

CREATE TABLE Categories (
    CategoryId INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(50) NOT NULL
);
CREATE INDEX idx_categories_on_name ON Categories(Name);

CREATE TABLE Locations (
    LocationId INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(50) NOT NULL
);
CREATE INDEX idx_locations_on_name ON Locations(Name);

-- Dictionary tables
CREATE TABLE Statuses (
    StatusId INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(50) NOT NULL
);
CREATE INDEX idx_statuses_on_name ON Statuses(Name);

CREATE TABLE Roles (
    RoleId INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(50) NOT NULL
);
CREATE INDEX idx_roles_on_name ON Roles(Name);

CREATE TABLE Genres (
    GenreId INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(50) NOT NULL
);
CREATE INDEX idx_genres_on_name ON Genres(Name);
GO

-- Task 3:

CREATE VIEW OverdueBorrowings AS
SELECT b.BorrowingId, u.Name AS UserName, bk.Title AS BookTitle, b.BorrowDate, b.ReturnDate 
FROM Borrowings b
JOIN Users u ON b.UserId = u.UserId
JOIN Books bk ON b.BookId = bk.BookId
WHERE b.ReturnDate < GETDATE();
GO

CREATE VIEW ActiveBorrowings AS
SELECT b.BorrowingId, u.Name AS UserName, bk.Title AS BookTitle, b.BorrowDate
FROM Borrowings b
JOIN Users u ON b.UserId = u.UserId
JOIN Books bk ON b.BookId = bk.BookId
WHERE b.ReturnDate IS NULL;
GO

CREATE VIEW UnavailableBooks AS
SELECT bk.BookId, bk.Title, a.Name AS AuthorName
FROM Books bk
JOIN Authors a ON bk.AuthorId = a.AuthorId
WHERE bk.Available = 0;
GO

CREATE VIEW MostBorrowedBooks AS
SELECT TOP 100 PERCENT bk.BookId, bk.Title, COUNT(*) as BorrowCount
FROM Borrowings b
JOIN Books bk ON b.BookId = bk.BookId
GROUP BY bk.BookId, bk.Title
ORDER BY BorrowCount DESC;
GO

-- Task 4:
CREATE PROCEDURE InsertUser @Email NVARCHAR(50), @Name NVARCHAR(50)
AS
BEGIN
    INSERT INTO Users (Email, Name) VALUES (@Email, @Name);
END;
GO
CREATE PROCEDURE UpdateUser @UserId INT, @Email NVARCHAR(50), @Name NVARCHAR(50)
AS
BEGIN
    UPDATE Users SET Email = @Email, Name = @Name WHERE UserId = @UserId;
END;
GO

CREATE PROCEDURE DeleteUser @UserId INT
AS
BEGIN
    DELETE FROM Users WHERE UserId = @UserId;
END;
GO

-- Task 5:
CREATE PROCEDURE GetUserBorrowings @UserId INT
AS
BEGIN
    SELECT b.BorrowingId, bk.Title AS BookTitle, b.BorrowDate, b.ReturnDate 
    FROM Borrowings b
    JOIN Books bk ON b.BookId = bk.BookId
    WHERE b.UserId = @UserId;
END;
GO

CREATE PROCEDURE GetBookBorrowings @BookId INT
AS
BEGIN
    SELECT b.BorrowingId, u.Name AS UserName, b.BorrowDate, b.ReturnDate 
    FROM Borrowings b
    JOIN Users u ON b.UserId = u.UserId
    WHERE b.BookId = @BookId;
END;