CREATE TABLE IF NOT EXISTS department (
    dept_name TEXT PRIMARY KEY,
    building TEXT,
    budget INTEGER
);

CREATE TABLE IF NOT EXISTS course (
    course_id INTEGER PRIMARY KEY,
    title TEXT,
    dept_name TEXT, 
    credits INTEGER,
    FOREIGN KEY (dept_name) REFERENCES department (dept_name) 
        ON DELETE CASCADE 
        ON UPDATE NO ACTION
);

CREATE TABLE IF NOT EXISTS prereq (
    course_id INTEGER,
    prereq_id INTEGER,
    PRIMARY KEY(course_id, prereq_id),
    FOREIGN KEY (course_id) REFERENCES course (course_id) 
        ON DELETE CASCADE 
        ON UPDATE NO ACTION,
    FOREIGN KEY (prereq_id) REFERENCES course (course_id) 
        ON DELETE CASCADE 
        ON UPDATE NO ACTION
);

CREATE TABLE IF NOT EXISTS student (
    ID INTEGER PRIMARY KEY,
    name TEXT,
    dept_name TEXT,
    tot_cred REAL,
    FOREIGN KEY (dept_name) REFERENCES department (dept_name) 
        ON DELETE CASCADE 
        ON UPDATE NO ACTION
);

CREATE TABLE IF NOT EXISTS instructor (
    ID INTEGER PRIMARY KEY,
    name TEXT,
    dept_name TEXT,
    salary REAL,
    FOREIGN KEY (dept_name) REFERENCES department (dept_name) 
        ON DELETE CASCADE 
        ON UPDATE NO ACTION
);

CREATE TABLE IF NOT EXISTS advisor (
    s_id INTEGER PRIMARY KEY,
    i_id INTEGER,
    FOREIGN KEY (s_id) REFERENCES student (ID) 
        ON DELETE CASCADE 
        ON UPDATE NO ACTION,
    FOREIGN KEY (i_id) REFERENCES instructor (ID) 
        ON DELETE CASCADE 
        ON UPDATE NO ACTION
);

CREATE TABLE IF NOT EXISTS classroom (
    building TEXT,
    room_no INTEGER,
    capacity INTEGER,
    PRIMARY KEY(building, room_no)
);

CREATE TABLE IF NOT EXISTS section (
    sec_id INTEGER,
	course_id INTEGER,
    semester TEXT CHECK (semester = 'Q1' OR semester = 'Q2' OR semester = 'Q3' OR semester = 'Q4'),
    year INTEGER CHECK(year > 2000),
    Building TEXT,
    room_no INTEGER,    
    time_slot_id INTEGER CHECK (time_slot_id = 'A' OR time_slot_id = 'B' OR time_slot_id = 'C' OR time_slot_id = 'D'),
    PRIMARY KEY (course_id, sec_id, semester, year), 
   	FOREIGN KEY (Building) REFERENCES classroom (building) 
        ON DELETE CASCADE 
        ON UPDATE NO ACTION,
    FOREIGN KEY (room_no) REFERENCES classroom (room_no) 
        ON DELETE CASCADE 
        ON UPDATE NO ACTION,
    FOREIGN KEY (course_id) REFERENCES course (course_id) 
        ON DELETE CASCADE 
        ON UPDATE NO ACTION
);

CREATE TABLE IF NOT EXISTS teaches (
    ID INTEGER,
    course_id INTEGER,
    sec_id INTEGER,
    semester TEXT CHECK (semester = 'Q1' OR semester = 'Q2' OR semester = 'Q3' OR semester = 'Q4'), 
    year INTEGER CHECK(year > 2000),
    PRIMARY KEY(ID, course_id, sec_id, semester, year),
    FOREIGN KEY (ID) REFERENCES instructor (ID) 
        ON DELETE CASCADE 
        ON UPDATE NO ACTION,
    FOREIGN KEY (course_id) REFERENCES section (course_id) 
        ON DELETE CASCADE 
        ON UPDATE NO ACTION,
    FOREIGN KEY (sec_id) REFERENCES section (sec_id) 
        ON DELETE CASCADE 
        ON UPDATE NO ACTION,
    FOREIGN KEY (semester) REFERENCES section (semester) 
        ON DELETE CASCADE 
        ON UPDATE NO ACTION,
    FOREIGN KEY (year) REFERENCES section (year) 
        ON DELETE CASCADE 
        ON UPDATE NO ACTION
);

CREATE TABLE IF NOT EXISTS takes (
    ID INTEGER,
    course_id INTEGER,
    sec_id INTEGER,
    semester TEXT CHECK (semester = 'Q1' OR semester = 'Q2' OR semester = 'Q3' OR semester = 'Q4'), 
    year INTEGER CHECK(year > 2000),
    Grade REAL,
    PRIMARY KEY(ID, course_id, sec_id, semester, year),
    FOREIGN KEY (ID) REFERENCES student (ID) 
        ON DELETE CASCADE 
        ON UPDATE NO ACTION,
    FOREIGN KEY (course_id) REFERENCES section (course_id) 
        ON DELETE CASCADE 
        ON UPDATE NO ACTION,
    FOREIGN KEY (sec_id) REFERENCES section (sec_id) 
        ON DELETE CASCADE 
        ON UPDATE NO ACTION,
    FOREIGN KEY (semester) REFERENCES section (semester) 
        ON DELETE CASCADE 
        ON UPDATE NO ACTION,
    FOREIGN KEY (year) REFERENCES section (year) 
        ON DELETE CASCADE 
        ON UPDATE NO ACTION
);

INSERT INTO student (ID, name, dept_name, tot_cred)
VALUES (1, 'Ana', 'Chemistry', 15),
       (2, 'John', 'Math', 17),
       (3, 'Hammed', 'Biology', 7.5),
       (4, 'Maria', 'History', 9);

INSERT INTO instructor (ID, name, dept_name, salary)
VALUES (1, 'Hans', 'Biology', 50000), 
       (2, 'Karin', 'Math', 55000), 
       (3, 'Ivar', 'Science', 45000), 
       (4, 'Matty', 'Math', 55000);

INSERT INTO advisor (s_id, i_id)
VALUES (1, 2), (2, 3), (3, 4), (4, 1);