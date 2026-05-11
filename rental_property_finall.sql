-- ============================================================
-- Rental Property Management & Analytics System
-- Author: Soumya Thamke
-- ============================================================

DROP DATABASE IF EXISTS rental_property_db;
CREATE DATABASE rental_property_db;
USE rental_property_db;

-- ============================================================
-- TABLE 1: OWNER
-- ============================================================
CREATE TABLE Owner (
    owner_id    INT AUTO_INCREMENT PRIMARY KEY,
    owner_name  VARCHAR(100) NOT NULL,
    phone       VARCHAR(15) NOT NULL
);

-- ============================================================
-- TABLE 2: PROPERTIES
-- ============================================================
CREATE TABLE Properties (
    property_id  INT AUTO_INCREMENT PRIMARY KEY,
    owner_id     INT NOT NULL,
    unit_type    VARCHAR(50) NOT NULL,
    address      VARCHAR(255) NOT NULL,
    rent_amount  DECIMAL(10,2) NOT NULL,
    status       ENUM('Occupied', 'Vacant') DEFAULT 'Vacant',
    FOREIGN KEY (owner_id) REFERENCES Owner(owner_id)
);

-- ============================================================
-- TABLE 3: TENANTS
-- ============================================================
CREATE TABLE Tenants (
    tenant_id        INT AUTO_INCREMENT PRIMARY KEY,
    property_id      INT NOT NULL,
    tenant_name      VARCHAR(100) NOT NULL,
    phone            VARCHAR(15) NOT NULL,
    lease_start      DATE NOT NULL,
    lease_end        DATE NOT NULL,
    security_deposit DECIMAL(10,2) NOT NULL,
    payment_mode     ENUM('Cash', 'UPI', 'Bank Transfer') DEFAULT 'Cash',
    is_active        BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (property_id) REFERENCES Properties(property_id)
);

-- ============================================================
-- TABLE 4: PAYMENTS
-- ============================================================
CREATE TABLE Payments (
    payment_id    INT AUTO_INCREMENT PRIMARY KEY,
    tenant_id     INT NOT NULL,
    payment_month VARCHAR(7) NOT NULL,
    due_date      DATE NOT NULL,
    payment_date  DATE,
    amount_due    DECIMAL(10,2) NOT NULL,
    amount_paid   DECIMAL(10,2) DEFAULT 0,
    status        ENUM('Paid', 'Pending', 'Late', 'Partial') DEFAULT 'Pending',
    payment_mode  ENUM('Cash', 'UPI', 'Bank Transfer') DEFAULT 'Cash',
    notes         VARCHAR(255),
    FOREIGN KEY (tenant_id) REFERENCES Tenants(tenant_id)
);

-- ============================================================
-- TABLE 5: MAINTENANCE REQUESTS
-- ============================================================
CREATE TABLE Maintenance_Requests (
    request_id    INT AUTO_INCREMENT PRIMARY KEY,
    property_id   INT NOT NULL,
    request_date  DATE NOT NULL,
    issue_type    VARCHAR(100) NOT NULL,
    raised_by     VARCHAR(100) NOT NULL,
    repair_cost   DECIMAL(10,2) DEFAULT 0,
    paid_by       ENUM('Owner', 'Tenant') DEFAULT 'Tenant',
    status        ENUM('Open', 'In Progress', 'Resolved') DEFAULT 'Open',
    resolved_date DATE,
    FOREIGN KEY (property_id) REFERENCES Properties(property_id)
);

-- ============================================================
-- INSERT DATA
-- ============================================================

INSERT INTO Owner (owner_name, phone) VALUES
('Soumya Thamke', '7788996655');

INSERT INTO Properties (owner_id, unit_type, address, rent_amount, status) VALUES
(1, '1 Room with Bathroom & Kitchen', 'Hyderabad, Telangana', 7000.00,  'Occupied'),
(1, '2BHK',                           'Hyderabad, Telangana', 25000.00, 'Occupied');

INSERT INTO Tenants (property_id, tenant_name, phone, lease_start, lease_end, security_deposit, payment_mode) VALUES
(1, 'Tenant A', '9000000001', '2024-01-01', '2025-12-31', 14000.00, 'Cash'),
(2, 'Tenant B', '9000000002', '2024-03-01', '2025-12-31', 50000.00, 'Cash');

INSERT INTO Payments (tenant_id, payment_month, due_date, payment_date, amount_due, amount_paid, status, payment_mode) VALUES
(1, '2025-01', '2025-01-05', '2025-01-04', 7000.00,  7000.00,  'Paid',    'Cash'),
(1, '2025-02', '2025-02-05', '2025-02-07', 7000.00,  7000.00,  'Late',    'Cash'),
(1, '2025-03', '2025-03-05', NULL,          7000.00,  0.00,     'Pending', 'Cash'),
(2, '2025-01', '2025-01-05', '2025-01-05', 25000.00, 25000.00, 'Paid',    'Cash'),
(2, '2025-02', '2025-02-05', '2025-02-05', 25000.00, 25000.00, 'Paid',    'Cash'),
(2, '2025-03', '2025-03-05', NULL,          25000.00, 0.00,     'Pending', 'Cash');

INSERT INTO Maintenance_Requests (property_id, request_date, issue_type, raised_by, repair_cost, paid_by, status, resolved_date) VALUES
(1, '2025-01-10', 'Plumbing',   'Tenant A', 500.00,  'Tenant', 'Resolved', '2025-01-12'),
(2, '2025-02-15', 'Electrical', 'Tenant B', 1200.00, 'Tenant', 'Resolved', '2025-02-17'),
(1, '2025-03-01', 'Plumbing',   'Tenant A', 0.00,    'Tenant', 'Open',     NULL);

-- ============================================================
-- QUERIES
-- ============================================================

-- 1. Monthly rent collection status
SELECT 
    t.tenant_name,
    p.unit_type,
    py.payment_month,
    py.amount_due,
    py.amount_paid,
    py.status,
    py.due_date,
    py.payment_date
FROM Payments py
JOIN Tenants t     ON py.tenant_id  = t.tenant_id
JOIN Properties p  ON t.property_id = p.property_id
ORDER BY py.payment_month, t.tenant_name;

-- 2. Outstanding payments
SELECT 
    t.tenant_name,
    p.unit_type,
    py.payment_month,
    py.amount_due,
    py.status
FROM Payments py
JOIN Tenants t    ON py.tenant_id  = t.tenant_id
JOIN Properties p ON t.property_id = p.property_id
WHERE py.status IN ('Pending', 'Partial')
ORDER BY py.payment_month;

-- 3. Total revenue collected vs expected per month
SELECT 
    payment_month,
    SUM(amount_paid)                   AS total_collected,
    SUM(amount_due)                    AS total_expected,
    SUM(amount_due) - SUM(amount_paid) AS outstanding
FROM Payments
GROUP BY payment_month
ORDER BY payment_month;

-- 4. Occupancy status
SELECT 
    p.property_id,
    p.unit_type,
    p.rent_amount,
    p.status,
    t.tenant_name,
    t.lease_start,
    t.lease_end
FROM Properties p
LEFT JOIN Tenants t ON p.property_id = t.property_id AND t.is_active = TRUE;

-- 5. Leases expiring in next 90 days
SELECT 
    t.tenant_name,
    p.unit_type,
    t.lease_end,
    DATEDIFF(t.lease_end, CURDATE()) AS days_remaining
FROM Tenants t
JOIN Properties p ON t.property_id = p.property_id
WHERE t.lease_end BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 90 DAY)
  AND t.is_active = TRUE;

-- 6. Maintenance cost summary
SELECT 
    p.unit_type,
    COUNT(m.request_id)                                 AS total_requests,
    SUM(m.repair_cost)                                  AS total_cost,
    SUM(CASE WHEN m.status = 'Open' THEN 1 ELSE 0 END) AS open_requests
FROM Maintenance_Requests m
JOIN Properties p ON m.property_id = p.property_id
GROUP BY p.unit_type;

-- 7. Late payment history
SELECT 
    t.tenant_name,
    p.unit_type,
    py.payment_month,
    py.due_date,
    py.payment_date,
    DATEDIFF(py.payment_date, py.due_date) AS days_late
FROM Payments py
JOIN Tenants t    ON py.tenant_id  = t.tenant_id
JOIN Properties p ON t.property_id = p.property_id
WHERE py.status = 'Late'
ORDER BY days_late DESC;

-- ============================================================
-- STORED PROCEDURES
-- ============================================================
DELIMITER $$

DROP PROCEDURE IF EXISTS flag_overdue_payments$$
DROP PROCEDURE IF EXISTS record_payment$$
DROP PROCEDURE IF EXISTS monthly_collection_report$$

CREATE PROCEDURE flag_overdue_payments()
BEGIN
    UPDATE Payments
    SET status = 'Late'
    WHERE status = 'Pending'
      AND due_date < CURDATE()
      AND payment_date IS NULL;

    SELECT 
        t.tenant_name,
        p.unit_type,
        py.payment_month,
        py.amount_due,
        py.due_date,
        py.status
    FROM Payments py
    JOIN Tenants t    ON py.tenant_id  = t.tenant_id
    JOIN Properties p ON t.property_id = p.property_id
    WHERE py.status = 'Late'
      AND py.payment_date IS NULL
    ORDER BY py.due_date;
END$$

CREATE PROCEDURE record_payment(
    IN p_tenant_id    INT,
    IN p_month        VARCHAR(7),
    IN p_amount_paid  DECIMAL(10,2),
    IN p_payment_date DATE
)
BEGIN
    UPDATE Payments
    SET
        amount_paid  = p_amount_paid,
        payment_date = p_payment_date,
        status = CASE
            WHEN p_amount_paid >= amount_due AND p_payment_date <= due_date THEN 'Paid'
            WHEN p_amount_paid >= amount_due AND p_payment_date > due_date  THEN 'Late'
            WHEN p_amount_paid < amount_due                                 THEN 'Partial'
            ELSE 'Pending'
        END
    WHERE tenant_id    = p_tenant_id
      AND payment_month = p_month;

    SELECT CONCAT('Payment recorded for tenant ', p_tenant_id, ' - ', p_month) AS result;
END$$

CREATE PROCEDURE monthly_collection_report(IN p_month VARCHAR(7))
BEGIN
    SELECT
        t.tenant_name,
        p.unit_type,
        py.amount_due,
        py.amount_paid,
        py.status,
        py.payment_date
    FROM Payments py
    JOIN Tenants t    ON py.tenant_id  = t.tenant_id
    JOIN Properties p ON t.property_id = p.property_id
    WHERE py.payment_month = p_month
    ORDER BY py.status;
END$$

DELIMITER ;
CALL flag_overdue_payments();
--
SELECT 
    t.tenant_name,
    p.unit_type,
    py.payment_month,
    py.amount_due,
    py.amount_paid,
    py.status,
    py.due_date,
    py.payment_date
FROM Payments py
JOIN Tenants t ON py.tenant_id = t.tenant_id
JOIN Properties p ON t.property_id = p.property_id
ORDER BY py.payment_month, t.tenant_name;

SELECT 
    p.unit_type,
    COUNT(m.request_id) AS total_requests,
    SUM(m.repair_cost) AS total_cost,
    SUM(CASE WHEN m.status = 'Open' THEN 1 ELSE 0 END) AS open_requests
FROM Maintenance_Requests m
JOIN Properties p ON m.property_id = p.property_id
GROUP BY p.unit_type;

SELECT 
    payment_month,
    SUM(amount_paid) AS total_collected,
    SUM(amount_due) AS total_expected,
    SUM(amount_due) - SUM(amount_paid) AS outstanding
FROM Payments
GROUP BY payment_month
ORDER BY payment_month;

-- ============================================================
-- CALL STORED PROCEDURES LIKE THIS:
-- ============================================================
-- CALL flag_overdue_payments();
-- CALL record_payment(1, '2025-03', 7000.00, '2025-03-06');
-- CALL monthly_collection_report('2025-03');
