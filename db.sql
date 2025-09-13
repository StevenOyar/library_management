-- Create database
CREATE DATABASE library_management;

USE library_management;

-- checks whether the group the book  like fiction, highschool play, science, etc
-- categories table
CREATE TABLE
    categories (
        category_id INT PRIMARY KEY AUTO_INCREMENT,
        category_name VARCHAR(100) NOT NULL UNIQUE,
        description TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );

-- authors table 
CREATE TABLE
    authors (
        author_id INT PRIMARY KEY AUTO_INCREMENT,
        first_name VARCHAR(20) NOT NULL,
        last_name VARCHAR(20) NOT NULL,
        email VARCHAR(30) UNIQUE,
        phone VARCHAR(15),
        biography TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );

-- publishers table 
CREATE TABLE
    publishers (
        publisher_id INT PRIMARY KEY AUTO_INCREMENT,
        publisher_name VARCHAR(75) NOT NULL,
        address TEXT,
        phone VARCHAR(15),
        email VARCHAR(30),
        website VARCHAR(100),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );

-- BOOKS  
-- this is one of the core library table which is used to refere to its main 
-- checks availability 
-- books table
CREATE TABLE
    books (
        book_id INT PRIMARY KEY AUTO_INCREMENT,
        isbn VARCHAR(17) UNIQUE NOT NULL,
        title VARCHAR(50) NOT NULL,
        subtitle VARCHAR(120),
        author_id INT NOT NULL,
        publisher_id INT,
        category_id INT,
        publication_year YEAR,
        edition VARCHAR(20),
        pages INT,
        language VARCHAR(30) DEFAULT 'English',
        price DECIMAL(10, 2),
        location_shelf VARCHAR(20),
        total_copies INT DEFAULT 1,
        available_copies INT DEFAULT 1,
        description TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        -- References: categories, authors, publisher
        FOREIGN KEY (author_id) REFERENCES authors (author_id),
        FOREIGN KEY (publisher_id) REFERENCES publishers (publisher_id),
        FOREIGN KEY (category_id) REFERENCES categories (category_id),
        -- Availability 
        CHECK (available_copies <= total_copies),
        CHECK (available_copies >= 0)
    );

-- member types table 
CREATE TABLE
    member_types (
        type_id INT PRIMARY KEY AUTO_INCREMENT,
        type_name VARCHAR(50) NOT NULL UNIQUE,
        max_books_allowed INT DEFAULT 5,
        loan_period_days INT DEFAULT 14,
        fine_per_day DECIMAL(5, 2) DEFAULT 1.00,
        membership_fee DECIMAL(8, 2) DEFAULT 0.00,
        description TEXT
    );

-- Members
-- member_status table
CREATE TABLE
    member_status ( -- active, expired, inactive, suspended etc
        status_id INT PRIMARY KEY AUTO_INCREMENT,
        status_name VARCHAR(20) UNIQUE NOT NULL,
        description TEXT
    );

-- members table
CREATE TABLE
    members (
        member_id INT PRIMARY KEY AUTO_INCREMENT,
        member_number VARCHAR(20) UNIQUE NOT NULL,
        first_name VARCHAR(20) NOT NULL,
        last_name VARCHAR(20) NOT NULL,
        email VARCHAR(100) UNIQUE NOT NULL,
        phone VARCHAR(15),
        address TEXT,
        date_of_birth DATE,
        member_type_id INT NOT NULL,
        registration_date DATE DEFAULT (CURRENT_DATE),
        membership_expiry DATE,
        status_id INT NOT NULL,
        emergency_contact_name VARCHAR(100),
        emergency_contact_phone VARCHAR(15),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        --  References: member_types and member_status tables
        FOREIGN KEY (member_type_id) REFERENCES member_types (type_id),
        FOREIGN KEY (status_id) REFERENCES member_status (status_id)
    );

-- Staff
-- checks the staff  the library has are they active, terminated, or on leave so that to assign appropiate staff id.
-- staff_status  table
CREATE TABLE
    staff_status ( -- active , inactivve, suspended, on leave, pending investigation, etc
        status_id INT PRIMARY KEY AUTO_INCREMENT,
        status_name VARCHAR(50) UNIQUE NOT NULL,
        description TEXT
    );

-- staff table 
CREATE TABLE
    staff (
        staff_id INT PRIMARY KEY AUTO_INCREMENT,
        employee_id VARCHAR(20) UNIQUE NOT NULL,
        first_name VARCHAR(50) NOT NULL,
        last_name VARCHAR(50) NOT NULL,
        email VARCHAR(100) UNIQUE NOT NULL,
        phone VARCHAR(15),
        position VARCHAR(50),
        department VARCHAR(50), -- circulation, reference, technical services, admin, etc
        hire_date DATE,
        salary DECIMAL(10, 2),
        status_id INT NOT NULL, -- active ,dismissed or on leave
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        -- references staff_status table
        FOREIGN KEY (status_id) REFERENCES staff_status (status_id)
    );

-- keeps track of the books movement from the day of borrowing to return. 
-- transaction_types table
CREATE TABLE
    transaction_types ( -- loan, return, renewal 
        type_id INT PRIMARY KEY AUTO_INCREMENT,
        type_name VARCHAR(20) UNIQUE NOT NULL,
        description TEXT
    );

-- transaction_status  table
CREATE TABLE
    transaction_status ( -- returned, overdue, lost,  destroyed 
        status_id INT PRIMARY KEY AUTO_INCREMENT,
        status_name VARCHAR(20) UNIQUE NOT NULL,
        description TEXT
    );

-- book_transactions table
CREATE TABLE
    book_transactions (
        transaction_id INT PRIMARY KEY AUTO_INCREMENT,
        book_id INT NOT NULL,
        member_id INT NOT NULL,
        staff_id INT,
        transaction_type_id INT NOT NULL,
        transaction_date DATETIME DEFAULT CURRENT_TIMESTAMP,
        due_date DATE, -- used to determine fines also together with returndate column
        return_date DATE NULL,
        status_id INT NOT NULL, -- returned, delayed, 
        feedback TEXT,
        --     references: books, memebers, staff, transctio_types, transaction_status tables
        FOREIGN KEY (book_id) REFERENCES books (book_id),
        FOREIGN KEY (member_id) REFERENCES members (member_id),
        FOREIGN KEY (staff_id) REFERENCES staff (staff_id),
        FOREIGN KEY (transaction_type_id) REFERENCES transaction_types (type_id),
        FOREIGN KEY (status_id) REFERENCES transaction_status (status_id)
    );

-- late return, lost books, damage of a book 
-- fine_types table
CREATE TABLE
    fine_types ( -- overdue, lost , damaged, etc
        fine_type_id INT PRIMARY KEY AUTO_INCREMENT,
        type_name VARCHAR(50) UNIQUE NOT NULL,
        description TEXT
    );

-- fine_status table
CREATE TABLE
    fine_status ( -- paid, overdue, pending, waived
        status_id INT PRIMARY KEY AUTO_INCREMENT,
        status_name VARCHAR(20) UNIQUE NOT NULL,
        description TEXT
    );

-- fines table
-- References: members, book_transactions, staff tables
CREATE TABLE
    fines (
        fine_id INT PRIMARY KEY AUTO_INCREMENT,
        member_id INT NOT NULL,
        transaction_id INT,
        fine_type_id INT NOT NULL,
        amount DECIMAL(8, 2) NOT NULL,
        reason TEXT,
        issue_date DATE DEFAULT (CURRENT_DATE),
        paid_date DATE NULL,
        status_id INT NOT NULL,
        staff_id INT,
        -- Reeferences: members, book_transactions, staff tables
        FOREIGN KEY (member_id) REFERENCES members (member_id),
        FOREIGN KEY (transaction_id) REFERENCES book_transactions (transaction_id),
        FOREIGN KEY (fine_type_id) REFERENCES fine_types (fine_type_id),
        FOREIGN KEY (status_id) REFERENCES fine_status (status_id),
        FOREIGN KEY (staff_id) REFERENCES staff (staff_id)
    );

-- reservation_status  table
CREATE TABLE
    reservation_status ( -- active, fulfilled, cancelled, expired, other
        status_id INT PRIMARY KEY AUTO_INCREMENT,
        status_name VARCHAR(10) UNIQUE NOT NULL,
        description TEXT
    );

-- reservations table 
CREATE TABLE
    reservations (
        reservation_id INT PRIMARY KEY AUTO_INCREMENT,
        book_id INT NOT NULL,
        member_id INT NOT NULL,
        reservation_date DATETIME DEFAULT CURRENT_TIMESTAMP,
        expected_date DATE,
        status_id INT NOT NULL,
        priority_number INT,
        notes TEXT,
        -- References: books, members tables
        FOREIGN KEY (book_id) REFERENCES books (book_id),
        FOREIGN KEY (member_id) REFERENCES members (member_id),
        FOREIGN KEY (status_id) REFERENCES reservation_status (status_id)
    );