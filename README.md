# SQL-Based Fraud Detection in Digital Payment Transactions

## 📌 Project Overview

This project simulates a real-world fraud investigation for **PayFast**, a fictional Indian payment aggregator processing digital payments across India.

The objective is to identify suspicious users and merchants by analyzing **200,000 transaction records** using **PostgreSQL** and **SQL**. The project implements **12 real-world fraud detection patterns** commonly observed in digital payment systems, demonstrating practical SQL techniques ranging from basic aggregations to advanced Common Table Expressions (CTEs), window functions, self joins, and correlated subqueries.

---

## 🎯 Objective

Detect suspicious users and merchants by implementing SQL-based solutions for **12 real-world fraud detection patterns** and generate actionable business insights from transaction data.

---

## ⭐ Key Highlights

* Analyzed **200,000** digital payment transactions.
* Implemented **12** real-world fraud detection patterns.
* Used **PostgreSQL** for data analysis.
* Applied advanced SQL concepts including **CTEs**, **window functions**, **self joins**, and **correlated subqueries**.
* Generated business insights and recommendations based on fraud detection results.

---

## 📂 Dataset

**Database:** PostgreSQL

**Table:** `transactions`

| Attribute         | Description                    |
| ----------------- | ------------------------------ |
| Records           | 200,000 transactions           |
| Time Period       | January 2024 – June 2024       |
| Users             | ~14,755                        |
| Merchants         | 800                            |
| Cities            | 20 Indian cities               |
| Payment Modes     | UPI, Card, Net Banking, Wallet |
| Transaction Types | Debit, Credit, Refund          |

---

## 🛠️ SQL Concepts Used

* SELECT, WHERE
* GROUP BY, HAVING
* Aggregate Functions
* CASE Expressions
* Joins
* Self Joins
* Correlated Subqueries
* Date & Time Functions
* Common Table Expressions (CTEs)
* Window Functions (`LAG()`, `RANK()`)

---

## 🚨 Fraud Patterns Covered

| No. | Fraud Pattern                      |
| :-: | ---------------------------------- |
|  1  | Velocity Fraud                     |
|  2  | Round-Amount Clustering            |
|  3  | Card Testing                       |
|  4  | Failed-Then-Succeeded Transactions |
|  5  | Odd-Hour Concentration             |
|  6  | Mule Accounts                      |
|  7  | Refund Abuse                       |
|  8  | Merchant Collusion                 |
|  9  | Just-Under-Threshold Transactions  |
|  10 | Dormant-Then-Active Accounts       |
|  11 | Velocity Spike                     |
|  12 | Geographic Impossibility           |

---

## 📊 Insights

Detailed findings, business impact, and recommendations are available in **[INSIGHTS.md](INSIGHTS.md)**.

---

## 📁 Repository Structure

```text
fraud-detection/
│
├── setup_database.sql
├── fraud_detection_patterns.sql
├── insights.md
├── README.md
```

---

## 🚀 Tech Stack

* PostgreSQL
* SQL

---

## Author

**Jayshree Patidar**

* LinkedIn: [jayshreepatidar](https://www.linkedin.com/in/jayshreepatidar)
* GitHub: [jayshreepatidar](https://github.com/jayshreepatidar?tab=repositories)
* Email: jayshreepatidar22@gmail.com
---