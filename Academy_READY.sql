
USE master;
GO

IF DB_ID('Academy') IS NOT NULL
BEGIN
    ALTER DATABASE Academy SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE Academy;
END
GO

CREATE DATABASE Academy;
GO

USE Academy;
GO

CREATE TABLE Faculties (
    Id INT IDENTITY PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE Departments (
    Id INT IDENTITY PRIMARY KEY,
    Building INT NOT NULL,
    Financing MONEY NOT NULL DEFAULT 0,
    Name NVARCHAR(100) NOT NULL UNIQUE,
    FacultyId INT NOT NULL REFERENCES Faculties(Id)
);

CREATE TABLE Groups (
    Id INT IDENTITY PRIMARY KEY,
    Name NVARCHAR(10) NOT NULL UNIQUE,
    Year INT NOT NULL,
    DepartmentId INT NOT NULL REFERENCES Departments(Id)
);

CREATE TABLE Curators (
    Id INT IDENTITY PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL,
    Surname NVARCHAR(100) NOT NULL
);

CREATE TABLE Teachers (
    Id INT IDENTITY PRIMARY KEY,
    IsProfessor BIT NOT NULL DEFAULT 0,
    Name NVARCHAR(100) NOT NULL,
    Surname NVARCHAR(100) NOT NULL,
    Salary MONEY NOT NULL
);

CREATE TABLE Students (
    Id INT IDENTITY PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL,
    Surname NVARCHAR(100) NOT NULL,
    Rating INT NOT NULL
);

CREATE TABLE Subjects (
    Id INT IDENTITY PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE Lectures (
    Id INT IDENTITY PRIMARY KEY,
    [Date] DATE NOT NULL,
    SubjectId INT NOT NULL REFERENCES Subjects(Id),
    TeacherId INT NOT NULL REFERENCES Teachers(Id)
);

CREATE TABLE GroupsCurators (
    Id INT IDENTITY PRIMARY KEY,
    CuratorId INT NOT NULL REFERENCES Curators(Id),
    GroupId INT NOT NULL REFERENCES Groups(Id)
);

CREATE TABLE GroupsStudents (
    Id INT IDENTITY PRIMARY KEY,
    GroupId INT NOT NULL REFERENCES Groups(Id),
    StudentId INT NOT NULL REFERENCES Students(Id)
);

CREATE TABLE GroupsLectures (
    Id INT IDENTITY PRIMARY KEY,
    GroupId INT NOT NULL REFERENCES Groups(Id),
    LectureId INT NOT NULL REFERENCES Lectures(Id)
);

INSERT INTO Faculties VALUES
('Computer Science'),('Engineering');

INSERT INTO Departments(Building,Financing,Name,FacultyId) VALUES
(1,120000,'Software Development',1),
(2,80000,'Cyber Security',1),
(3,150000,'Mechanical',2);

INSERT INTO Groups(Name,Year,DepartmentId) VALUES
('D221',4,1),('D511',5,1),('D512',5,1),('C101',1,2);

INSERT INTO Curators(Name,Surname) VALUES
('Ivan','Petrenko'),('Anna','Koval'),('Oleg','Bondar');

INSERT INTO Teachers(IsProfessor,Name,Surname,Salary) VALUES
(1,'Taras','Shevchenko',5000),
(1,'Petro','Ivanov',6000),
(0,'Olena','Kravets',7000),
(0,'Ihor','Melnyk',4500);

INSERT INTO Students(Name,Surname,Rating) VALUES
('A','A',5),('B','B',4),('C','C',5),('D','D',4),('E','E',3),
('F','F',5),('G','G',4),('H','H',5),('I','I',5),('J','J',4),
('K','K',2),('L','L',2),('M','M',3),('N','N',2),('O','O',3);

INSERT INTO Subjects(Name) VALUES
('SQL'),('CSharp'),('Algorithms'),('Networks');

INSERT INTO GroupsStudents(GroupId,StudentId) VALUES
(1,11),(1,12),(1,13),(1,14),(1,15),
(2,1),(2,2),(2,3),(2,4),(2,5),
(3,6),(3,7),(3,8),(3,9),(3,10);

INSERT INTO GroupsCurators(CuratorId,GroupId) VALUES
(1,2),(2,2),(3,3);

INSERT INTO Lectures([Date],SubjectId,TeacherId) VALUES
('2025-01-01',1,1),('2025-01-02',1,1),('2025-01-03',1,1),
('2025-01-04',1,1),('2025-01-05',1,1),('2025-01-06',1,1),
('2025-01-07',1,1),('2025-01-08',1,1),('2025-01-09',1,1),
('2025-01-10',1,1),('2025-01-11',1,1),('2025-01-12',1,1);

INSERT INTO GroupsLectures(GroupId,LectureId)
SELECT 2, Id FROM Lectures;
GO

-- 1
SELECT Building
FROM Departments
GROUP BY Building
HAVING SUM(Financing) > 100000;

-- 2
SELECT g.Name
FROM Groups g
JOIN Departments d ON g.DepartmentId = d.Id
JOIN GroupsLectures gl ON g.Id = gl.GroupId
JOIN Lectures l ON gl.LectureId = l.Id
WHERE g.Year = 5
  AND d.Name = 'Software Development'
  AND DATEPART(WEEK, l.Date) = 1
GROUP BY g.Name
HAVING COUNT(*) > 10;

-- 3
SELECT g.Name
FROM Groups g
JOIN GroupsStudents gs ON g.Id = gs.GroupId
JOIN Students s ON gs.StudentId = s.Id
GROUP BY g.Id, g.Name
HAVING AVG(s.Rating) >
(
    SELECT AVG(s2.Rating)
    FROM Groups g2
    JOIN GroupsStudents gs2 ON g2.Id = gs2.GroupId
    JOIN Students s2 ON gs2.StudentId = s2.Id
    WHERE g2.Name = 'D221'
);

-- 4
SELECT Surname, Name
FROM Teachers
WHERE Salary >
(
    SELECT AVG(Salary)
    FROM Teachers
    WHERE IsProfessor = 1
);

-- 5
SELECT g.Name
FROM Groups g
JOIN GroupsCurators gc ON g.Id = gc.GroupId
GROUP BY g.Id, g.Name
HAVING COUNT(gc.CuratorId) > 1;

-- 6
SELECT g.Name
FROM Groups g
JOIN GroupsStudents gs ON g.Id = gs.GroupId
JOIN Students s ON gs.StudentId = s.Id
GROUP BY g.Id, g.Name
HAVING AVG(s.Rating) <
(
    SELECT MIN(RatingAvg)
    FROM
    (
        SELECT AVG(s2.Rating) AS RatingAvg
        FROM Groups g2
        JOIN GroupsStudents gs2 ON g2.Id = gs2.GroupId
        JOIN Students s2 ON gs2.StudentId = s2.Id
        WHERE g2.Year = 5
        GROUP BY g2.Id
    ) t
);

-- 7
SELECT f.Name
FROM Faculties f
JOIN Departments d ON f.Id = d.FacultyId
GROUP BY f.Id, f.Name
HAVING SUM(d.Financing) >
(
    SELECT SUM(d2.Financing)
    FROM Faculties f2
    JOIN Departments d2 ON f2.Id = d2.FacultyId
    WHERE f2.Name = 'Computer Science'
);

-- 8
SELECT s.Name AS Subject,
       t.Surname + ' ' + t.Name AS Teacher
FROM Subjects s
JOIN Lectures l ON s.Id = l.SubjectId
JOIN Teachers t ON l.TeacherId = t.Id
GROUP BY s.Id, s.Name, t.Id, t.Name, t.Surname
HAVING COUNT(*) =
(
    SELECT MAX(LecCount)
    FROM
    (
        SELECT COUNT(*) AS LecCount
        FROM Lectures
        GROUP BY SubjectId, TeacherId
    ) x
);

-- 9
SELECT Name
FROM Subjects
WHERE Id =
(
    SELECT TOP 1 SubjectId
    FROM Lectures
    GROUP BY SubjectId
    ORDER BY COUNT(*)
);

-- 10
SELECT
(
    SELECT COUNT(*)
    FROM GroupsStudents gs
    JOIN Groups g ON gs.GroupId = g.Id
    JOIN Departments d ON g.DepartmentId = d.Id
    WHERE d.Name = 'Software Development'
) AS StudentsCount,
(
    SELECT COUNT(DISTINCT l.SubjectId)
    FROM Lectures l
    JOIN GroupsLectures gl ON l.Id = gl.LectureId
    JOIN Groups g ON gl.GroupId = g.Id
    JOIN Departments d ON g.DepartmentId = d.Id
    WHERE d.Name = 'Software Development'
) AS SubjectsCount;
