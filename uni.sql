-- Schema

drop table marks;
drop table prereq;
drop table time_slot;
drop table advisor;
drop table takes;
drop table grade_points;
drop table student;
drop table teaches;
drop table section;
drop table instructor;
drop table course;
drop table department;
drop table classroom;

create table classroom
(building varchar(15),
room_number varchar(7),
capacity numeric(4,0),
primary key (building, room_number)
);

create table department
(dept_name varchar(20),
building varchar(15),
budget numeric(12,2) not null check (budget > 0),
primary key (dept_name)
);

create table course
(course_id varchar(8),
title varchar(50),
dept_name varchar(20),
credits numeric(2,0) not null check (credits > 0),
primary key (course_id),
foreign key (dept_name) references department (dept_name) on delete set null
);

create table instructor
(ID varchar(5),
name varchar(20) not null,
dept_name varchar(20),
salary numeric(8,2) not null check (salary > 29000),
primary key (ID),
foreign key (dept_name) references department (dept_name) on delete set null
);

create table section
(course_id varchar(8),
sec_id varchar(8),
semester varchar(6) not null check (semester in ('Fall', 'Winter', 'Spring', 'Summer')),
year numeric(4,0) not null check (year > 1701 and year < 2100),
building varchar(15),
room_number varchar(7),
time_slot_id varchar(4),
primary key (course_id, sec_id, semester, year),
foreign key (course_id) references course (course_id) on delete cascade,
foreign key (building, room_number) references classroom (building, room_number) on delete set null
);

create table teaches
(ID varchar(5),
course_id varchar(8),
sec_id varchar(8),
semester varchar(6),
year numeric(4,0),
primary key (ID, course_id, sec_id, semester, year),
foreign key (course_id, sec_id, semester, year) references section (course_id, sec_id, semester, year) on delete cascade,
foreign key (ID) references instructor (ID) on delete cascade
);

create table student
(ID varchar(5),
name varchar(20) not null,
dept_name varchar(20),
tot_cred numeric(3,0) not null default 0 check (tot_cred >= 0),
primary key (ID),
foreign key (dept_name) references department (dept_name) on delete set null
);

create table grade_points
(grade varchar(2),
points real,
primary key (grade)
);

create table takes
(ID varchar(5),
course_id varchar(8),
sec_id varchar(8),
semester varchar(6),
year numeric(4,0),
grade varchar(2),
primary key (ID, course_id, sec_id, semester, year),
foreign key (course_id, sec_id, semester, year) references section (course_id, sec_id, semester, year) on delete cascade,
foreign key (ID) references student (ID) on delete cascade,
foreign key (grade) references grade_points (grade)
);

create table advisor
(s_ID varchar(5),
i_ID varchar(5),
primary key (s_ID),
foreign key (i_ID) references instructor (ID) on delete set null,
foreign key (s_ID) references student (ID) on delete cascade
);

create table time_slot
(time_slot_id varchar(4),
day varchar(1),
start_hr numeric(2) check (start_hr >= 0 and start_hr < 24),
start_min numeric(2) check (start_min >= 0 and start_min < 60),
end_hr numeric(2) check (end_hr >= 0 and end_hr < 24),
end_min numeric(2) check (end_min >= 0 and end_min < 60),
primary key (time_slot_id, day, start_hr, start_min)
);

create table prereq
(course_id varchar(8),
prereq_id varchar(8),
primary key (course_id, prereq_id),
foreign key (course_id) references course (course_id) on delete cascade,
foreign key (prereq_id) references course (course_id)
);

create table marks
(ID varchar(5),
score integer,
foreign key (ID) references student (ID) on delete cascade);

-- Data

insert into classroom values ('Packard', '101', '500');
insert into classroom values ('Painter', '514', '10');
insert into classroom values ('Taylor', '3128', '70');
insert into classroom values ('Watson', '100', '30');
insert into classroom values ('Watson', '120', '50');
insert into department values ('Biology', 'Watson', '90000');
insert into department values ('Comp. Sci.', 'Taylor', '100000');
insert into department values ('Elec. Eng.', 'Taylor', '85000');
insert into department values ('Finance', 'Painter', '120000');
insert into department values ('History', 'Painter', '50000');
insert into department values ('Music', 'Packard', '80000');
insert into department values ('Physics', 'Watson', '70000');
insert into course values ('BIO-101', 'Intro. to Biology', 'Biology', '4');
insert into course values ('BIO-301', 'Genetics', 'Biology', '4');
insert into course values ('BIO-399', 'Computational Biology', 'Biology', '3');
insert into course values ('CS-101', 'Intro. to Computer Science', 'Comp. Sci.', '4');
insert into course values ('CS-190', 'Game Design', 'Comp. Sci.', '4');
insert into course values ('CS-315', 'Robotics', 'Comp. Sci.', '3');
insert into course values ('CS-319', 'Image Processing', 'Comp. Sci.', '3');
insert into course values ('CS-347', 'Database System Concepts', 'Comp. Sci.', '3');
insert into course values ('EE-181', 'Intro. to Digital Systems', 'Elec. Eng.', '3');
insert into course values ('FIN-201', 'Investment Banking', 'Finance', '3');
insert into course values ('HIS-351', 'World History', 'History', '3');
insert into course values ('MU-199', 'Music Video Production', 'Music', '3');
insert into course values ('PHY-101', 'Physical Principles', 'Physics', '4');
insert into instructor values ('10101', 'Srinivasan', 'Comp. Sci.', '65000');
insert into instructor values ('12121', 'Wu', 'Finance', '90000');
insert into instructor values ('15151', 'Mozart', 'Music', '40000');
insert into instructor values ('22222', 'Einstein', 'Physics', '95000');
insert into instructor values ('32343', 'El Said', 'History', '60000');
insert into instructor values ('33456', 'Gold', 'Physics', '87000');
insert into instructor values ('45565', 'Katz', 'Comp. Sci.', '75000');
insert into instructor values ('58583', 'Califieri', 'History', '62000');
insert into instructor values ('76543', 'Singh', 'Finance', '80000');
insert into instructor values ('76766', 'Crick', 'Biology', '72000');
insert into instructor values ('83821', 'Brandt', 'Comp. Sci.', '92000');
insert into instructor values ('98345', 'Kim', 'Elec. Eng.', '80000');
insert into section values ('BIO-101', '1', 'Summer', '2017', 'Painter', '514', 'B');
insert into section values ('BIO-301', '1', 'Summer', '2018', 'Painter', '514', 'A');
insert into section values ('CS-101', '1', 'Fall', '2017', 'Packard', '101', 'H');
insert into section values ('CS-101', '2', 'Fall', '2017', 'Packard', '101', 'G');
insert into section values ('CS-101', '3', 'Fall', '2017', 'Packard', '101', 'F');
insert into section values ('CS-101', '1', 'Spring', '2018', 'Packard', '101', 'F');
insert into section values ('CS-190', '1', 'Spring', '2017', 'Taylor', '3128', 'E');
insert into section values ('CS-190', '2', 'Spring', '2017', 'Taylor', '3128', 'A');
insert into section values ('CS-315', '1', 'Spring', '2018', 'Watson', '120', 'D');
insert into section values ('CS-319', '1', 'Spring', '2018', 'Watson', '100', 'B');
insert into section values ('CS-319', '2', 'Spring', '2018', 'Taylor', '3128', 'C');
insert into section values ('CS-347', '1', 'Fall', '2017', 'Taylor', '3128', 'A');
insert into section values ('EE-181', '1', 'Spring', '2017', 'Taylor', '3128', 'C');
insert into section values ('FIN-201', '1', 'Spring', '2018', 'Packard', '101', 'B');
insert into section values ('HIS-351', '1', 'Spring', '2018', 'Painter', '514', 'C');
insert into section values ('MU-199', '1', 'Spring', '2018', 'Packard', '101', 'D');
insert into section values ('PHY-101', '1', 'Fall', '2017', 'Watson', '100', 'A');
insert into teaches values ('10101', 'CS-101', '1', 'Fall', '2017');
insert into teaches values ('10101', 'CS-315', '1', 'Spring', '2018');
insert into teaches values ('10101', 'CS-347', '1', 'Fall', '2017');
insert into teaches values ('12121', 'FIN-201', '1', 'Spring', '2018');
insert into teaches values ('15151', 'MU-199', '1', 'Spring', '2018');
insert into teaches values ('22222', 'PHY-101', '1', 'Fall', '2017');
insert into teaches values ('32343', 'HIS-351', '1', 'Spring', '2018');
insert into teaches values ('45565', 'CS-101', '1', 'Spring', '2018');
insert into teaches values ('45565', 'CS-319', '1', 'Spring', '2018');
insert into teaches values ('76766', 'BIO-101', '1', 'Summer', '2017');
insert into teaches values ('76766', 'BIO-301', '1', 'Summer', '2018');
insert into teaches values ('83821', 'CS-190', '1', 'Spring', '2017');
insert into teaches values ('83821', 'CS-190', '2', 'Spring', '2017');
insert into teaches values ('83821', 'CS-319', '2', 'Spring', '2018');
insert into teaches values ('98345', 'EE-181', '1', 'Spring', '2017');
insert into student values ('00128', 'Zhang', 'Comp. Sci.', '102');
insert into student values ('12345', 'Shankar', 'Comp. Sci.', '32');
insert into student values ('19991', 'Brandt', 'History', '80');
insert into student values ('23121', 'Chavez', 'Finance', '110');
insert into student values ('44553', 'Peltier', 'Physics', '56');
insert into student values ('45678', 'Levy', 'Physics', '46');
insert into student values ('54321', 'Williams', 'Comp. Sci.', '54');
insert into student values ('55739', 'Sanchez', 'Music', '38');
insert into student values ('70557', 'Snow', 'Physics', '0');
insert into student values ('76543', 'Brown', 'Comp. Sci.', '58');
insert into student values ('76653', 'Aoi', 'Elec. Eng.', '60');
insert into student values ('98765', 'Bourikas', 'Elec. Eng.', '98');
insert into student values ('98988', 'Tanaka', 'Biology', '120');
insert into grade_points values ('A', 4.00);
insert into grade_points values ('A-', 3.67);
insert into grade_points values ('B+', 3.33);
insert into grade_points values ('B', 3.00);
insert into grade_points values ('B-', 2.67);
insert into grade_points values ('C+', 2.33);
insert into grade_points values ('C', 2.00);
insert into grade_points values ('C-', 1.67);
insert into grade_points values ('D+', 1.33);
insert into grade_points values ('D', 1.00);
insert into grade_points values ('D-', 0.67);
insert into grade_points values ('F', 0);
insert into takes values ('00128', 'CS-101', '1', 'Fall', '2017', 'A');
insert into takes values ('00128', 'CS-347', '1', 'Fall', '2017', 'A-');
insert into takes values ('12345', 'CS-101', '1', 'Fall', '2017', 'C');
insert into takes values ('12345', 'CS-190', '2', 'Spring', '2017', 'A');
insert into takes values ('12345', 'CS-315', '1', 'Spring', '2018', 'A');
insert into takes values ('12345', 'CS-347', '1', 'Fall', '2017', 'A');
insert into takes values ('19991', 'HIS-351', '1', 'Spring', '2018', 'B');
insert into takes values ('23121', 'FIN-201', '1', 'Spring', '2018', 'C+');
insert into takes values ('44553', 'CS-101', '2', 'Fall', '2017', 'B-');
insert into takes values ('44553', 'PHY-101', '1', 'Fall', '2017', 'B-');
insert into takes values ('45678', 'CS-101', '1', 'Fall', '2017', 'F');
insert into takes values ('45678', 'CS-101', '1', 'Spring', '2018', 'B+');
insert into takes values ('45678', 'CS-319', '1', 'Spring', '2018', 'B');
insert into takes values ('54321', 'CS-101', '1', 'Fall', '2017', 'A-');
insert into takes values ('54321', 'CS-190', '2', 'Spring', '2017', 'B+');
insert into takes values ('55739', 'MU-199', '1', 'Spring', '2018', 'A-');
insert into takes values ('76543', 'CS-101', '1', 'Fall', '2017', 'A');
insert into takes values ('76543', 'CS-319', '2', 'Spring', '2018', 'A');
insert into takes values ('76653', 'EE-181', '1', 'Spring', '2017', 'C');
insert into takes values ('98765', 'CS-101', '1', 'Fall', '2017', 'C-');
insert into takes values ('98765', 'CS-315', '1', 'Spring', '2018', 'B');
insert into takes values ('98988', 'BIO-101', '1', 'Summer', '2017', 'A');
insert into takes values ('98988', 'BIO-301', '1', 'Summer', '2018', null);
insert into advisor values ('00128', '45565');
insert into advisor values ('12345', '10101');
insert into advisor values ('23121', '76543');
insert into advisor values ('44553', '22222');
insert into advisor values ('45678', '22222');
insert into advisor values ('76543', '45565');
insert into advisor values ('76653', '98345');
insert into advisor values ('98765', '98345');
insert into advisor values ('98988', '76766');
insert into time_slot values ('A', 'M', '8', '0', '8', '50');
insert into time_slot values ('A', 'W', '8', '0', '8', '50');
insert into time_slot values ('A', 'F', '8', '0', '8', '50');
insert into time_slot values ('B', 'M', '9', '0', '9', '50');
insert into time_slot values ('B', 'W', '9', '0', '9', '50');
insert into time_slot values ('B', 'F', '9', '0', '9', '50');
insert into time_slot values ('C', 'M', '11', '0', '11', '50');
insert into time_slot values ('C', 'W', '11', '0', '11', '50');
insert into time_slot values ('C', 'F', '11', '0', '11', '50');
insert into time_slot values ('D', 'M', '13', '0', '13', '50');
insert into time_slot values ('D', 'W', '13', '0', '13', '50');
insert into time_slot values ('D', 'F', '13', '0', '13', '50');
insert into time_slot values ('E', 'T', '10', '30', '11', '45 ');
insert into time_slot values ('E', 'R', '10', '30', '11', '45 ');
insert into time_slot values ('F', 'T', '14', '30', '15', '45 ');
insert into time_slot values ('F', 'R', '14', '30', '15', '45 ');
insert into time_slot values ('G', 'M', '16', '0', '16', '50');
insert into time_slot values ('G', 'W', '16', '0', '16', '50');
insert into time_slot values ('G', 'F', '16', '0', '16', '50');
insert into time_slot values ('H', 'W', '10', '0', '12', '30');
insert into prereq values ('BIO-301', 'BIO-101');
insert into prereq values ('BIO-399', 'BIO-101');
insert into prereq values ('CS-190', 'CS-101');
insert into prereq values ('CS-315', 'CS-101');
insert into prereq values ('CS-319', 'CS-101');
insert into prereq values ('CS-347', 'CS-101');
insert into prereq values ('EE-181', 'PHY-101');
insert into marks values ('00128', 53);
insert into marks values ('19991', 79);
insert into marks values ('19991', 32);
insert into marks values ('19991', 88);
insert into marks values ('19991', 100);
insert into marks values ('23121', 69);
insert into marks values ('23121', 98);
insert into marks values ('23121', 79);
insert into marks values ('45678', 69);
insert into marks values ('45678', 0);
insert into marks values ('54321', 65);
insert into marks values ('54321', 51);
insert into marks values ('55739', 97);
insert into marks values ('76543', 73);
insert into marks values ('76543', 86);
insert into marks values ('76543', 95);
insert into marks values ('76653', 93);
insert into marks values ('76653', 83);
insert into marks values ('98765', 91);
insert into marks values ('98988', 72);
insert into marks values ('98988', 95);
insert into marks values ('98988', 93);

-- Examples

-- Find all students whose stored total credit is not equal to the sum of credits earned for each successfully completed course.

select ID
from student
where tot_cred <>
(select coalesce(sum(credits), 0)
from takes natural join course
where student.ID = takes.ID
and grade is not null and grade <> 'F');

-- Find all courses that were offered at most once (i.e., either never or exactly once) in 2017.

-- with a correlated subquery (which is re-evaluated for each outer tuple)
select c.course_id
from course as c
where 1 >=
(select count(s.course_id)
from section as s
where s.course_id = c.course_id and year = 2017);

-- with an uncorrelated subquery
select course_id
from course
where course_id not in
(select course_id
from section
where year = 2017
group by course_id
having count(course_id) > 1);

-- without a subquery
select c.course_id
from course as c left outer join section as s on (c.course_id = s.course_id and year = 2017)
group by c.course_id
having count(s.course_id) <= 1;

-- Find all the courses taught in both Fall 2017 and Spring 2018.

-- INTERSECT ALL is not supported in sqlite:
-- https://www.sqlite.org/lang_select.html#compound_select_statements

-- Set intersection with duplicates retained
-- a. subquery in the where clause via IN(select-stmt)
select course_id
from section
where semester = 'Fall' and year = 2017 and course_id in
(select course_id
from section
where semester = 'Spring' and year = 2018);

-- b. correlated subquery in the where clause via EXISTS(select-stmt)
select course_id
from section as s
where semester = 'Fall' and year = 2017 and exists
(select *
from section
where semester = 'Spring' and year = 2018 and course_id = s.course_id);

-- Find all students who have taken courses offered in the Biology department.

-- Set containment
-- relation A contains relation B <=> {} = B \ A (i.e., NOT EXISTS (B EXCEPT A))
select ID, name
from student as s
where not exists
(select course_id from course where dept_name = 'Biology'
except
select course_id from takes where ID = s.ID);

-- Find the average salary of instructors in those departments where the average salary is more than $42,000.

-- Aggregation with grouping
-- a. filtering by HAVING(expr)
select dept_name, avg(salary) as avg_salary
from instructor
group by dept_name
having avg(salary) > 42000;

-- b. subquery in the from clause and filtering by WHERE(expr)
select dept_name, avg_salary
from
(select dept_name, avg(salary) as avg_salary
from instructor
group by dept_name) as pdas
where avg_salary > 42000;

-- Find the number of instructors in each department.

-- scalar subquery in the select clause
select dept_name,
(select count(*)
from instructor
where department.dept_name = instructor.dept_name)
as num_instructors
from department;

-- Find the average number of sections taught per instructor.

-- scalar without a from clause
select
(select cast(count(*) as real) from teaches) /
(select count(*) from instructor) as avg_load;

-- Standard-conforming alternatives to select-without-from
-- a. dummy table
create view dual as select 0;
select
(select cast(count(*) as real) from teaches) /
(select count(*) from instructor) as avg_load
from dual;
drop view dual;

-- b. stand-alone values clause
-- https://www.sqlite.org/lang_select.html#the_values_clause
values (
(select cast(count(*) as real) from teaches) /
(select count(*) from instructor));

-- c. common table expression
-- https://www.sqlite.org/lang_with.html
with t(cnt) as
(select cast(count(*) as real) from teaches), i(cnt) as
(select count(*) from instructor)
select t.cnt / i.cnt as avg_load
from t, i;

-- Functions

-- Standard
-- coalesce(X, Y, ...) returns its first non-null argument, or null if all arguments are null
select coalesce(null, 0); -- returns 0
select coalesce(null, null); -- returns null

-- SQLite-specific
-- typeof(X) returns a string from the set {'null', 'integer', 'real', 'text', 'blob'} representing the datatype of expression X
-- select typeof(ID), typeof(name), typeof(dept_name), typeof(tot_cred) from student;
-- NB: pg_typeof(X) for Postgres

-- Exercises

-- 1a. Find the titles of courses in the Comp. Sci. department that have 3 credits.

select title
from course
where dept_name = 'Comp. Sci.' and credits = 3;

-- b. Find the IDs of all students who were taught by an instructor named Einstein; make sure there are no duplicates in the result.

select distinct ID
from takes
where course_id in
(select course_id
from instructor as i, teaches as t
where i.ID = t.ID and name = 'Einstein');

-- c. Find the highest salary of any instructor.

select max(salary) from instructor;

-- d. Find the instructors earning the highest salary (there may be more than one with the same salary).

select *
from instructor
where salary = (select max(salary) from instructor);

-- e. Find the enrollment of each section that was offered in Fall 2017.

select course_id, sec_id,
(select count(ID)
from takes as t
where t.year = s.year
and t.semester = s.semester
and t.course_id = s.course_id
and t.sec_id = s.sec_id) as enrollment
from section as s
where semester = 'Fall' and year = 2017;

-- f. Find the maximum enrollment, across all sections, in Fall 2017.
select max(enrollment)
from
(select count(ID) as enrollment
from section as s, takes as t
where t.year = s.year
and t.semester = s.semester
and t.course_id = s.course_id
and t.sec_id = s.sec_id
and t.semester = 'Fall'
and t.year = 2017
group by t.course_id, t.sec_id) as e;

-- g. Find the sections that had the maximum enrollment in Fall 2017.

with cse as
(select t.course_id, t.sec_id, count(ID) as enrollment
from section as s, takes as t
where t.year = s.year
and t.semester = s.semester
and t.course_id = s.course_id
and t.sec_id = s.sec_id
and t.semester = 'Fall'
and t.year = 2017
group by t.course_id, t.sec_id)
select course_id, sec_id
from cse
where enrollment = (select max(enrollment) from cse);

-- 2a. Find the total grade points earned by the student with ID '12345', across all courses taken by the student.

-- returns null if the student has not taken a course
select sum(credits * points) as tot_gp
from grade_points as gp, course as c, takes as t
where t.grade = gp.grade
and t.course_id = c.course_id
and ID = '12345';

-- returns 0 if the student has not taken a course
select coalesce(sum(credits * points), 0) as tot_gp
from grade_points as gp, course as c, takes as t
where t.grade = gp.grade
and t.course_id = c.course_id
and ID = '70557';

-- returns null in the case where the student is not enrolled
select (case
when ID is null then null
else coalesce(sum(credits * points), 0)
end) as tot_gp
from student left outer join takes using (ID)
left outer join course using (course_id)
left outer join grade_points using (grade)
where ID = '70558'
group by ID;

-- NB: In Postgres, all arguments to coalesce() are required to be of the same type. Furthermore, X * Y requires that both operands be of numeric type. If one operand is of unknown type, it is promoted to the other operand's type. Student.ID is of type 'character varying', therefore an explicit conversion is needed. SQLite's flexible typing handles this implicitly: https://www.sqlite.org/datatype3.html#operators
select coalesce(sum(credits * points), cast(ID as integer) * 0) as tot_gp
from student left outer join takes using (ID)
left outer join course using (course_id)
left outer join grade_points using (grade)
where ID = '70558'
group by ID;

-- b. Find the grade point average (GPA) for the above student, that is, the total grade points divided by the total credits for the associated courses.

select sum(credits * points) / sum(credits) as GPA
from grade_points as gp, course as c, takes as t
where t.grade = gp.grade
and t.course_id = c.course_id
and ID = '12345';

-- c. Find the ID and the GPA of each student.

select ID, round(cast(sum(credits * points) / sum(credits) as numeric), 2) as GPA
from grade_points as gp, course as c, takes as t
where t.grade = gp.grade
and t.course_id = c.course_id
group by ID
union
select ID, null as GPA
from student
where not exists
(select * from takes where ID = student.ID);

-- 3a. Increase the salary of each instructor in the Comp. Sci. department by 10%.

update instructor
set salary = salary * 1.10
where dept_name = 'Comp. Sci.';

-- b. Delete all courses that have never been offered (i.e., do not occur in the section relation).

-- deletes 'BIO-399', as expected
delete from course
where course_id not in
(select course_id from section);

-- c. Insert every student whose tot_cred attribute is greater than 100 as an instructor in the same department, with a salary of $10,000.

-- fails with check constraint violation on salary, as expected
insert into instructor
select ID, name, dept_name, 10000
from student
where tot_cred > 100;

-- 5a. Display the grade for each student, based on the marks relation.

select ID, (case
when score < 40 then 'F'
when score < 60 then 'C'
when score < 80 then 'B'
else 'A'
end) as grade
from marks;

-- b. Find the number of students with each grade.

select (case
when score < 40 then 'F'
when score < 60 then 'C'
when score < 80 then 'B'
else 'A'
end) as grade, count(ID)
from marks
group by grade;

-- 6. Find departments whose names contain the string "sci" as a substring, regardless of the case.

select dept_name
from department
where lower(dept_name) like '%sci%';

-- 11a. Find the ID and name of each student who has taken at least one Comp. Sci. course; make sure there are no duplicate names in the result.

select distinct ID, name
from student join takes using (ID)
where course_id like 'CS-%';

-- b. Find the ID and name of each student who has not taken any course offered before 2017.

select ID, name
from student
except
select ID, name
from student join takes using (ID)
where year < 2017;

-- c. For each department, find the maximum salary of instructors in that department. You may assume that every department has at least one instructor.

select dept_name, max(salary)
from instructor
group by dept_name;

-- d. Find the lowest, across all departments, of the per-department maximum salary computed by the preceding query.

select min(max_salary)
from
(select dept_name, max(salary) as max_salary
from instructor
group by dept_name) as pdms;
