-- NB: Contrary to the SQL standard, primary keys in SQLite are nullable.
-- https://www.sqlite.org/lang_createtable.html#the_primary_key

-- Enable foreign key support.
-- https://www.sqlite.org/foreignkeys.html
pragma foreign_keys = ON;

drop table if exists marks;
drop table if exists prereq;
drop table if exists time_slot;
drop table if exists advisor;
drop table if exists takes;
drop table if exists grade_points;
drop table if exists student;
drop table if exists teaches;
drop table if exists section;
drop table if exists instructor;
drop table if exists course;
drop table if exists department;
drop table if exists classroom;

create table classroom
(building varchar(15) not null,
room_number varchar(7) not null,
capacity numeric(4,0),
primary key (building, room_number)
);

create table department
(dept_name varchar(20) not null,
building varchar(15),
budget numeric(12,2) not null check (budget > 0),
primary key (dept_name)
);

create table course
(course_id varchar(8) not null,
title varchar(50),
dept_name varchar(20),
credits numeric(2,0) not null check (credits > 0),
primary key (course_id),
foreign key (dept_name) references department (dept_name) on delete set null
);

create table instructor
(ID varchar(5) not null,
name varchar(20) not null,
dept_name varchar(20),
salary numeric(8,2) not null check (salary > 29000),
primary key (ID),
foreign key (dept_name) references department (dept_name) on delete set null
);

create table section
(course_id varchar(8) not null,
sec_id varchar(8) not null,
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
(ID varchar(5) not null,
course_id varchar(8) not null,
sec_id varchar(8) not null,
semester varchar(6) not null,
year numeric(4,0) not null,
primary key (ID, course_id, sec_id, semester, year),
foreign key (course_id, sec_id, semester, year) references section (course_id, sec_id, semester, year) on delete cascade,
foreign key (ID) references instructor (ID) on delete cascade
);

create table student
(ID varchar(5) not null,
name varchar(20) not null,
dept_name varchar(20),
tot_cred numeric(3,0) not null default 0 check (tot_cred >= 0),
primary key (ID),
foreign key (dept_name) references department (dept_name) on delete set null
);

create table grade_points
(grade varchar(2) not null,
points real,
primary key (grade)
);

create table takes
(ID varchar(5) not null,
course_id varchar(8) not null,
sec_id varchar(8) not null,
semester varchar(6) not null,
year numeric(4,0) not null,
grade varchar(2),
primary key (ID, course_id, sec_id, semester, year),
foreign key (course_id, sec_id, semester, year) references section (course_id, sec_id, semester, year) on delete cascade,
foreign key (ID) references student (ID) on delete cascade,
foreign key (grade) references grade_points (grade)
);

create table advisor
(s_ID varchar(5) not null,
i_ID varchar(5),
primary key (s_ID),
foreign key (i_ID) references instructor (ID) on delete set null,
foreign key (s_ID) references student (ID) on delete cascade
);

create table time_slot
(time_slot_id varchar(4) not null,
day varchar(1) not null,
start_hr numeric(2) not null check (start_hr >= 0 and start_hr < 24),
start_min numeric(2) not null check (start_min >= 0 and start_min < 60),
end_hr numeric(2) check (end_hr >= 0 and end_hr < 24),
end_min numeric(2) check (end_min >= 0 and end_min < 60),
primary key (time_slot_id, day, start_hr, start_min)
);

create table prereq
(course_id varchar(8) not null,
prereq_id varchar(8) not null,
primary key (course_id, prereq_id),
foreign key (course_id) references course (course_id) on delete cascade,
foreign key (prereq_id) references course (course_id)
);

create table marks
(ID varchar(5) not null,
score integer,
foreign key (ID) references student (ID) on delete cascade
);
