DROP DATABASE IF EXISTS library_management;
CREATE DATABASE library_management;
USE library_management;

CREATE TABLE Readers (
    reader_id INT NOT NULL AUTO_INCREMENT,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    phone_number VARCHAR(15) NOT NULL UNIQUE,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_readers PRIMARY KEY (reader_id)
);

CREATE TABLE Membership_Details (
    card_id     VARCHAR(20)     NOT NULL,
    reader_id   INT             NOT NULL UNIQUE,
    card_rank   ENUM('Standard','VIP') NOT NULL DEFAULT 'Standard',
    expiry_date DATE            NOT NULL,
    citizen_id  VARCHAR(20)     NOT NULL UNIQUE,
    CONSTRAINT pk_membership PRIMARY KEY (card_id),
    CONSTRAINT fk_membership_reader FOREIGN KEY (reader_id)
        REFERENCES Readers(reader_id)
        ON DELETE CASCADE
);

CREATE TABLE Categories (
    category_id     INT             NOT NULL AUTO_INCREMENT,
    category_name   VARCHAR(100)    NOT NULL UNIQUE,
    description     TEXT            NOT NULL,
    CONSTRAINT pk_categories PRIMARY KEY (category_id)
);

CREATE TABLE Books (
    book_id         INT             NOT NULL AUTO_INCREMENT,
    title           VARCHAR(200)    NOT NULL UNIQUE,
    author          VARCHAR(150)    NOT NULL,
    category_id     INT             NOT NULL,
    price           DECIMAL(15,2)   NOT NULL,
    stock_quantity  INT             NOT NULL DEFAULT 0,
    CONSTRAINT pk_books PRIMARY KEY (book_id),
    CONSTRAINT fk_books_category FOREIGN KEY (category_id)
        REFERENCES Categories(category_id),
    CONSTRAINT chk_price   CHECK (price > 0),
    CONSTRAINT chk_stock   CHECK (stock_quantity >= 0)
);

CREATE TABLE Loan_Records (
    loan_id     INT     NOT NULL AUTO_INCREMENT,
    reader_id   INT     NOT NULL,
    book_id     INT     NOT NULL,
    borrow_date DATE    NOT NULL,
    due_date    DATE    NOT NULL,
    return_date DATE    DEFAULT NULL,
    CONSTRAINT pk_loan       PRIMARY KEY (loan_id),
    CONSTRAINT fk_loan_reader FOREIGN KEY (reader_id)
        REFERENCES Readers(reader_id),
    CONSTRAINT fk_loan_book FOREIGN KEY (book_id)
        REFERENCES Books(book_id),
    CONSTRAINT chk_due_date CHECK (due_date > borrow_date)
);


INSERT INTO Readers (reader_id, full_name, email, phone_number, created_at) VALUES
(1, 'Nguyen Van A', 'anv@gmail.com',        '901234567', '2022-01-15'),
(2, 'Tran Thi B',   'btt@gmail.com',        '912345678', '2022-05-20'),
(3, 'Le Van C',     'cle@yahoo.com',         '922334455', '2023-02-10'),
(4, 'Pham Minh D',  'dpham@hotmail.com',     '933445566', '2023-11-05'),
(5, 'Hoang Anh E',  'ehoang@gmail.com',      '944556677', '2023-01-12');

INSERT INTO Membership_Details (card_id, reader_id, card_rank, expiry_date, citizen_id) 
VALUES
('CARD-001', 1, 'Standard', '2025-01-15', '123456789'),
('CARD-002', 2, 'VIP',      '2025-05-20', '234567890'),
('CARD-003', 3, 'Standard', '2024-02-10', '345678901'),
('CARD-004', 4, 'VIP',      '2025-11-05', '456789012'),
('CARD-005', 5, 'Standard', '2026-01-12', '567890123');


INSERT INTO Categories (category_id, category_name, description) 
VALUES
(1, 'IT',       'Sách về công nghệ thông tin và lập trình'),
(2, 'Kinh Te',  'Sách kinh doanh, tài chính, khởi nghiệp'),
(3, 'Van Hoc',  'Tiểu thuyết, truyện ngắn, thơ'),
(4, 'Ngoai Ngu','Sách học tiếng Anh, Nhật, Hàn'),
(5, 'Lich Su',  'Sách nghiên cứu lịch sử, văn hóa');


INSERT INTO Books (book_id, title, author, category_id, price, stock_quantity) 
VALUES
(1, 'Clean Code',      'Robert C. Martin', 1, 450000, 10),
(2, 'Dac Nhan Tam',    'Dale Carnegie',    2, 150000, 50),
(3, 'Harry Potter 1',  'J.K. Rowling',     3, 250000,  5),
(4, 'IELTS Reading',   'Cambridge',        4, 180000,  0),
(5, 'Dai Viet Su Ky',  'Le Van Huu',       5, 300000, 20);


INSERT INTO Loan_Records (loan_id, reader_id, book_id, borrow_date, due_date, return_date) VALUES
(101, 1, 1, '2023-11-15', '2023-11-22', '2023-11-20'),
(102, 2, 2, '2023-12-01', '2023-12-08', '2023-12-05'),
(103, 1, 3, '2024-01-10', '2024-01-17', NULL),
(104, 3, 4, '2023-05-20', '2023-05-27', NULL),
(105, 4, 1, '2023-01-18', '2024-01-25', NULL);


UPDATE Loan_Records lr
JOIN Books b ON b.book_id = lr.book_id
JOIN Categories c ON c.category_id = b.category_id
SET lr.due_date = DATE_ADD(lr.due_date, INTERVAL 7 DAY)
WHERE c.category_name = 'Van Hoc'
  AND lr.return_date IS NULL;

DELETE FROM Loan_Records
WHERE return_date IS NOT NULL
  AND borrow_date < '2023-10-01';
-- phan 2

-- Câu 1 : Sách thuộc danh mục 'IT' có giá > 200,000 VNĐ
SELECT b.book_id, b.title, b.price
FROM Books b
JOIN Categories c ON c.category_id = b.category_id
WHERE c.category_name = 'IT'
  AND b.price > 200000;

-- Câu 2: Độc giả đăng ký năm 2022 có email @gmail.com
SELECT reader_id, full_name, email
FROM Readers
WHERE YEAR(created_at) = 2022
  AND email LIKE '%@gmail.com';

-- Câu 3: 5 sách có giá cao nhất, bỏ qua 2 cuốn đắt nhất (lấy từ cuốn thứ 3 đến thứ 7)
SELECT book_id, title, price
FROM Books
ORDER BY price DESC
LIMIT 5 OFFSET 2;

-- phan 3

-- Câu 1: Phiếu mượn chưa trả — Mã phiếu, Tên độc giả, Tên sách, Ngày mượn, Ngày trả
SELECT
    lr.loan_id      AS 'Mã phiếu',
    r.full_name     AS 'Tên độc giả',
    b.title         AS 'Tên sách',
    lr.borrow_date  AS 'Ngày mượn',
    lr.due_date     AS 'Ngày trả dự kiến'
FROM Loan_Records lr
JOIN Readers r ON r.reader_id = lr.reader_id
JOIN Books   b ON b.book_id   = lr.book_id
WHERE lr.return_date IS NULL;

-- Câu 2: Tổng tồn kho theo danh mục, chỉ hiện danh mục có tổng > 10
SELECT
    c.category_name         AS 'Danh mục',
    SUM(b.stock_quantity)   AS 'Tổng tồn kho'
FROM Books b
JOIN Categories c ON c.category_id = b.category_id
GROUP BY c.category_id, c.category_name
HAVING SUM(b.stock_quantity) > 10;

-- Câu 3: Độc giả VIP chưa từng mượn sách có giá > 300,000 VNĐ
SELECT r.full_name AS 'Tên độc giả'
FROM Readers r
JOIN Membership_Details md ON md.reader_id = r.reader_id
WHERE md.card_rank = 'VIP'
  AND r.reader_id NOT IN (
      SELECT lr.reader_id
      FROM Loan_Records lr
      JOIN Books b ON b.book_id = lr.book_id
      WHERE b.price > 300000
  );

-- phan 4
-- Câu 1: Composite Index trên Loan_Records (borrow_date, return_date)
CREATE INDEX idx_loan_dates ON Loan_Records (borrow_date, return_date);

-- Câu 2: View vw_overdue_loans — các phiếu mượn quá hạn, chưa trả
CREATE VIEW vw_overdue_loans AS
SELECT
    lr.loan_id      AS 'Mã phiếu',
    r.full_name     AS 'Tên độc giả',
    b.title         AS 'Tên sách',
    lr.borrow_date  AS 'Ngày mượn',
    lr.due_date     AS 'Ngày dự kiến trả'
FROM Loan_Records lr
JOIN Readers r ON r.reader_id = lr.reader_id
JOIN Books   b ON b.book_id   = lr.book_id
WHERE lr.return_date IS NULL
  AND CURDATE() > lr.due_date;

-- phan 5
DELIMITER //

-- Câu 1 (5đ): Tự động trừ tồn kho khi thêm phiếu mượn mới
CREATE TRIGGER trg_after_loan_insert
AFTER INSERT ON Loan_Records
FOR EACH ROW
BEGIN
    UPDATE Books
    SET stock_quantity = stock_quantity - 1
    WHERE book_id = NEW.book_id;
END //
DELIMITER ;

-- Câu 2 (5đ): Ngăn xóa độc giả còn đang mượn sách
DELIMITER //
CREATE TRIGGER trg_prevent_delete_active_reader
BEFORE DELETE ON Readers
FOR EACH ROW
BEGIN
    DECLARE active_loans INT DEFAULT 0;

    SELECT COUNT(*) INTO active_loans
    FROM Loan_Records
    WHERE reader_id = OLD.reader_id
      AND return_date IS NULL;

    IF active_loans > 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Không thể xóa độc giả đang còn sách chưa trả!';
    END IF;
END //

DELIMITER ;

-- phan 6
DELIMITER //  

-- Câu 1: Kiểm tra tình trạng tồn kho của sách
CREATE PROCEDURE sp_check_availability (
    IN  p_book_id   INT,
    OUT p_message   VARCHAR(50)
)
BEGIN
    DECLARE v_stock INT DEFAULT 0;

    SELECT stock_quantity INTO v_stock
    FROM Books
    WHERE book_id = p_book_id;

    IF v_stock = 0 THEN
        SET p_message = 'Hết hàng';
    ELSEIF v_stock <= 5 THEN
        SET p_message = 'Sắp hết';
    ELSE
        SET p_message = 'Còn hàng';
    END IF;
END //
DELIMITER ;

-- Câu 2: Xử lý trả sách với Transaction an toàn
DELIMITER //
CREATE PROCEDURE sp_return_book_transaction (
    IN p_loan_id INT
)
BEGIN
    DECLARE v_return_date   DATE    DEFAULT NULL;
    DECLARE v_book_id       INT     DEFAULT NULL;
    DECLARE v_error         TINYINT DEFAULT 0;

    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET v_error = 1;

    START TRANSACTION;

    SELECT return_date, book_id
    INTO   v_return_date, v_book_id
    FROM   Loan_Records
    WHERE  loan_id = p_loan_id;

    IF v_return_date IS NOT NULL THEN
    
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Sách đã trả rồi';
    ELSE
    
        UPDATE Loan_Records
        SET return_date = CURDATE()
        WHERE loan_id = p_loan_id;

        UPDATE Books
        SET stock_quantity = stock_quantity + 1
        WHERE book_id = v_book_id;

        IF v_error = 1 THEN
            ROLLBACK;
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Đã xảy ra lỗi, giao dịch bị hủy';
        ELSE
            COMMIT;
        END IF;
    END IF;
END //

DELIMITER ;

