-- SQLite references

-- 1. lang_select.html#compound_select_statements
-- 2. lang_select.html#the_values_clause
-- 3. lang_with.html
-- 4. datatype3.html#operators
-- 5. optoverview.html#subquery_co_routines
-- 6. lang_expr.html#the_case_expression

-- Standard functions

-- coalesce(X, Y, ...) returns its first non-null argument, or null if all arguments are null
select coalesce(null, 0); -- returns 0
select coalesce(null, null); -- returns null

-- SQLite functions

-- typeof(X) returns a string from the set {'null', 'integer', 'real', 'text', 'blob'} representing the datatype of expression X

-- Examples

-- Find the names of instructors in the Biology department along with the courses they teach.

select name, course_id
from instructor, teaches
where (instructor.ID, dept_name) = (teaches.ID, 'Biology'); -- row constructor notation

-- Find all students whose stored total credit is not equal to the sum of credits earned for each successfully completed course.

select ID
from student
where tot_cred <>
(select coalesce(sum(credits), 0)
from takes natural join course
where student.ID = takes.ID
and grade is not null and grade <> 'F');

-- Find all courses that were offered at most once (i.e., either never or exactly once) in 2017.

-- with a correlated scalar subquery (re-evaluated for each outer tuple)
select c.course_id
from course as c
where 1 >=
(select count(s.course_id)
from section as s
where s.course_id = c.course_id and year = 2017);
-- SQLite's query plan for the preceding query:
-- |--SCAN c USING COVERING INDEX sqlite_autoindex_course_1
-- `--CORRELATED SCALAR SUBQUERY 1
--    `--SEARCH s USING COVERING INDEX sqlite_autoindex_section_1 (course_id=?)

-- with an uncorrelated subquery
select course_id
from course
where course_id not in
(select course_id
from section
where year = 2017
group by course_id
having count(course_id) > 1);
-- |--SCAN course USING COVERING INDEX sqlite_autoindex_course_1
-- `--LIST SUBQUERY 1
--    `--SCAN section USING COVERING INDEX sqlite_autoindex_section_1

-- without a subquery
select c.course_id
from course as c left outer join section as s on (c.course_id = s.course_id and year = 2017)
group by c.course_id
having count(s.course_id) <= 1;
-- |--SCAN c USING COVERING INDEX sqlite_autoindex_course_1
-- `--SEARCH s USING COVERING INDEX sqlite_autoindex_section_1 (course_id=?) LEFT-JOIN

-- Find all the course sections (offerings) taught in both the Fall 2017 and Spring 2018 semesters.

-- Note that INTERSECT ALL is not supported in sqlite.[1]
-- The following two queries incorrectly exclude matching tuples from the inner selects.
select course_id, sec_id, semester, year
from section
where semester = 'Fall' and year = 2017 and course_id in
(select course_id
from section
where semester = 'Spring' and year = 2018);

select course_id, sec_id, semester, year
from section as s
where semester = 'Fall' and year = 2017 and exists
(select *
from section
where semester = 'Spring' and year = 2018 and course_id = s.course_id);

-- The following query correctly includes all matches.
with fa17_and_sp18_courses as
(select course_id
from section
where semester = 'Fall' and year = 2017
intersect
select course_id
from section
where semester = 'Spring' and year = 2018)
select course_id, sec_id, semester, year
from section
where course_id in
(select course_id
from fa17_and_sp18_courses);

-- Find all students who have taken courses offered in the Biology department.

-- Note that relation A contains relation B iff B \ A = {} (i.e., NOT EXISTS (B EXCEPT A) returns true).
select ID, name
from student as s
where not exists
(select course_id from course where dept_name = 'Biology'
except
select course_id from takes where ID = s.ID);

-- Find the average salary of instructors in those departments where the average salary is more than $42,000.

select dept_name, avg(salary) as avg_salary
from instructor
group by dept_name
having avg(salary) > 42000;

-- aggregate subquery in the from clause
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
from instructor as i
where d.dept_name = i.dept_name) as num_instructors
from department as d;

-- Find the average number of sections taught per instructor.

-- scalar without a from clause
select
(select cast(count(*) as real) from teaches) /
(select count(*) from instructor) as avg_load;

-- Standard-conforming alternatives to select-without-from:
-- dummy table
create view dual as select 0;
select
(select cast(count(*) as real) from teaches) /
(select count(*) from instructor) as avg_load
from dual;
drop view dual;
-- stand-alone values clause[2]
values (
(select cast(count(*) as real) from teaches) /
(select count(*) from instructor));
-- common table expression[3]
with t(cnt) as
(select cast(count(*) as real) from teaches), i(cnt) as
(select count(*) from instructor)
select t.cnt / i.cnt as avg_load
from t, i;

-- Exercises

-- Ch. 3
-- 1a. Find the titles of courses in the Comp. Sci. department that have 3 credits.

select title
from course
where dept_name = 'Comp. Sci.' and credits = 3;

-- b. Find the IDs of all students who were taught by an instructor named Einstein; omit duplicate IDs.

select distinct ID
from takes
where course_id in
(select course_id
from instructor as i, teaches as t
where i.ID = t.ID and name = 'Einstein');

-- c. Find the highest salary of any instructor.

select max(salary) from instructor;

-- d. Find all instructors earning the highest salary (there may be more than one with the same salary).

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
and ID = '70557'; -- test case

-- returns 0 as before and null if the student is not enrolled
select (case
when ID is null then null
else coalesce(sum(credits * points), 0)
end) as tot_gp
from student left outer join takes using (ID)
left outer join course using (course_id)
left outer join grade_points using (grade)
where ID = '70558' -- test case
group by ID;

-- equivalent to the preceding query
select coalesce(sum(credits * points), cast(ID as integer) * 0) as tot_gp
from student left outer join takes using (ID)
left outer join course using (course_id)
left outer join grade_points using (grade)
where ID = '70558'
group by ID;
-- NB: In PostgreSQL, all arguments to coalesce() are required to be of the same type. Furthermore, X * Y requires that both operands be of numeric type. If one operand is of unknown type, it is promoted to the other operand's type. However, since the ID attribute is of type 'character varying', an explicit type conversion (CAST) is needed. SQLite's flexible typing handles this implicitly.[4]

-- b. Find the grade point average (GPA) for the above student, that is, the total grade points divided by the total credits for the associated courses.

select sum(credits * points) / sum(credits) as GPA
from grade_points as gp, course as c, takes as t
where t.grade = gp.grade
and t.course_id = c.course_id
and ID = '12345';

-- c. Find the ID and GPA of each student.

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

-- update instructor
-- set salary = salary * 1.10
-- where dept_name = 'Comp. Sci.';

-- b. Delete all courses that have never been offered (i.e., do not occur in the section relation).

-- Note that the following query deletes 'BIO-399'.
-- delete from course
-- where course_id not in
-- (select course_id from section);

-- c. Insert every student whose tot_cred attribute is greater than 100 as an instructor in the same department, with a salary of $10,000.

-- Note that the following query fails with a check constraint violation on salary (salary > 29000).
-- insert into instructor
-- select ID, name, dept_name, 10000
-- from student
-- where tot_cred > 100;

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

-- 6. Find departments whose names contain 'sci' as a substring, regardless of the case.

select dept_name
from department
where lower(dept_name) like '%sci%';

-- 11a. Find the ID and name of each student who has taken at least one Comp. Sci. course; omit duplicate IDs.

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

-- c. For each department, find the maximum salary of instructors in that department. Assume that every department has at least one instructor.

select dept_name, max(salary)
from instructor
group by dept_name;

-- d. Find the lowest, across all departments, of the per-department maximum salary computed by the preceding query.

select min(max_salary)
from
(select dept_name, max(salary) as max_salary
from instructor
group by dept_name) as pdms;

-- 12a. Create a new course 'CS-001', titled 'Weekly Seminar' with 0 credits.

-- Note that inserting a course with 0 credits would violate a check constraint on credit (credit > 0).
insert into course values ('CS-001', 'Weekly Seminar', 'Comp. Sci.', 1);

-- b. Create a section of this course in Fall 2017, with sec_id of 1, and with the location of this section not yet specified.

insert into section (course_id, sec_id, semester, year) values ('CS-001', '1', 'Fall', '2017');

-- c. Enroll every student in the Comp. Sci. department in the above section.

insert into takes (ID, course_id, sec_id, semester, year)
select ID, 'CS-001', '1', 'Fall', '2017'
from student
where dept_name = 'Comp. Sci.';

-- d. Delete enrollments in the above section where the student's ID is '12345'.

delete from takes
where ID = '12345' and course_id = 'CS-001' and sec_id = '1' and semester = 'Fall' and year = '2017';

-- e. Delete course 'CS-001'.

-- NB: Running the following delete statement would fail if it were to result in a referential integrity violation, i.e., if a dependent tuple in a referencing relation were to be invalidated ("left dangling"). However, since the ON DELETE CASCADE clause is attached to the foreign-key declarations of the section and takes relations, deleting a course will also delete the corresponding offerings and enrollments, leaving no dangling tuples.
delete from course
where course_id = 'CS-001';

-- f. Delete all *takes* tuples corresponding to any section of any course with 'advanced' as part of the title, regardless of the case.

delete from takes
where course_id in
(select course_id
from course
where lower(title) like '%advanced%');

-- 19. List two reasons why null values might be introduced into a database.

-- Null is used to indicate that a data value is absent: either unknown or non-existent.

-- 23. Rewrite the following query without using the WITH construct.
with dept_total(dept_name, value) as
(select dept_name, sum(salary)
from instructor
group by dept_name), dept_total_avg(value) as
(select avg(value)
from dept_total)
select dept_name
from dept_total, dept_total_avg
where dept_total.value >= dept_total_avg.value;
-- |--MATERIALIZE dept_total
-- |  |--SCAN instructor
-- |  `--USE TEMP B-TREE FOR GROUP BY
-- |--MATERIALIZE dept_total_avg
-- |  `--SCAN dept_total
-- |--SCAN dept_total_avg
-- `--SCAN dept_total

select dept_name
from instructor
group by dept_name
having sum(salary) >
(select avg(dept_total.value)
from
(select sum(salary) as value -- recomputed subquery (implemented as a co-routine[5])
from instructor
group by dept_name) as dept_total);
-- |--SCAN instructor
-- |--USE TEMP B-TREE FOR GROUP BY
-- `--SCALAR SUBQUERY 2
--    |--CO-ROUTINE dept_total
--    |  |--SCAN instructor
--    |  `--USE TEMP B-TREE FOR GROUP BY
--    `--SCAN dept_total

-- 24. Find the name and ID of those Accounting students advised by an instructor in the Physics department.

select ID, name
from student
where dept_name = 'Accounting' and ID in
(select s_ID
from advisor
where i_ID in
(select ID
from instructor
where dept_name = 'Physics'));

-- 25. Find the names of those departments whose budget is higher than that of Philosophy. List them in alphabetic order.

-- NB: It is left unstated what to do in the case where there is no Philosophy department; a non-existent budget is thus treated as a budget of sum zero.
select dept_name
from department
where budget >
(select coalesce(sum(budget), 0)
from department
where dept_name = 'Philosophy')
order by dept_name;

-- 26. For each student who has *retaken* a course at least twice (i.e., the student has taken the course at least three times), show the course ID and the student's ID. Order rows by course ID and omit duplicates.

select ID, course_id
from takes
group by ID, course_id
having count(course_id) >= 3
order by course_id;

-- 27. Find the IDs of those students who have retaken at least three distinct courses at least once.

select ID
from
(select ID, course_id
from takes
group by ID, course_id
having count(course_id) >= 2) as retakes
group by ID
having count(ID) >= 3;

-- 28. Find the names and IDs of those instructors who teach every course taught in his or her department (i.e., every course that appears in the course relation with the instructor's department name). Order result by name.

select ID, name
from instructor as i
where not exists
(select course_id from course where dept_name = i.dept_name
except
select course_id from teaches where ID = i.ID)
order by name;

-- 29. Find the name and ID of each History student whose name begins with the letter 'D' and who has *not* taken at least five Music courses.

select ID, name
from student
where dept_name = 'History' and name like 'D%' and ID not in
(select ID
from takes join course using (course_id)
where dept_name = 'Music'
group by ID
having count(*) >= 5);

-- without a subquery
select ID, name
from student left outer join takes using (ID) left outer join course using (course_id)
where student.dept_name = 'History' and name like 'D%'
group by ID
having count(case course.dept_name when 'Music' then 1 end) < 5;
-- NB: The CASE expression used here includes a base expression (i.e., an expression between the keywords CASE and WHEN). This ensures course.dept_name is evaluated only once.[6]

-- 30. When is the following query not equal to zero?
select avg(salary) - (sum(salary) / count(*)) from instructor;

-- The query will not equal zero when one or more input values are null because the minuend (i.e., avg(salary)) computes the average of all *non-null* input values, whereas the subtrahend computes the average of all input values (as count(*) includes rows where salary is null).
-- NB: In SQLite, sum() computes an integer value if all its inputs are integers, whereas avg() always computes a floating point value if at least one of its inputs is non-null. When all salaries are integers, an integer division occurs in the subtrahend (as both sum() and count() return integers), potentially resulting in a non-zero difference.

-- 31. Find the ID and name of each instructor who has never given an A grade in any course she or he has taught. (Instructors who have never taught a course trivially satisfy this condition.)

select ID, name
from instructor
except
select instructor.ID, name
from instructor join teaches using (ID) join takes using (course_id, sec_id, semester, year)
where grade = 'A';

-- Ch. 4
-- 1. What is wrong with the following query which tries to find the titles of all courses taught in Spring 2017 along with the name of the instructor?
select name, title
from instructor natural join teaches natural join section natural join course
where semester = 'Spring' and year = 2017;

-- Tuples where an instructor teaches a course such that course.dept_name != instructor.dept_name are not included in the result because the natural join of instructor with course pairs tuples from each on the common dept_name attribute. For this reason, join conditions should preferably be stated explicitly, as in the following query:
select name, title
from instructor join teaches using (ID)
join section using (course_id, sec_id, semester, year)
join course using (course_id)
where (semester, year) = ('Spring', '2017');
