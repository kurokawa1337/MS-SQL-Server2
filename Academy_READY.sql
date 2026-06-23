
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
