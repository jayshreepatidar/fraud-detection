-- =====================================================================

-- Fraud Detection Patterns

-- =====================================================================


-- P1. Velocity Fraud 
/*
The pattern: A legitimate user makes 3-8 transactions per day on their busiest days. A fraudster running 
an automated script can make 30+ in a single day. Anyone hitting that count is either a bot, an account 
takeover, or a merchant running a churning scheme. 
Detection Logic:
Identify users with 30 or more transactions on the same day.
*/
SELECT user_id,
    DATE(txn_time) AS txn_date,
    COUNT(txn_id) AS transaction_count
FROM transactions
GROUP BY user_id, DATE(txn_time)
HAVING COUNT(txn_id) >= 30
ORDER BY transaction_count DESC;


-- P2. Round-Amount Clustering 
/*
The pattern: Money launderers prefer round-number amounts (₹100, ₹500, ₹1,000, ₹5,000, ₹10,000). 
Real e-commerce and food-delivery transactions rarely produce clean round numbers because prices 
include taxes, delivery fees, and discounts. A user with 15+ exactly-round transactions is showing 
money-laundering signature. 
Detection Logic:
Identify users with 15 or more transactions having exactly round amounts.
*/
SELECT user_id,
    COUNT(txn_id) AS round_txn_count
FROM transactions
WHERE amount IN ( 100, 200, 500, 1000, 2000, 5000, 10000)
GROUP BY user_id
HAVING COUNT(txn_id) >= 15
ORDER BY round_txn_count DESC;


-- P3. Card Testing 
/*
The pattern: Fraudsters buy dumps of stolen credit card numbers on the dark web. They test which 
cards are still active by attempting tiny purchases (under ₹10). If the purchase goes through, the card is 
still valid and the fraudster keeps it for a bigger operation. If it fails, they move to the next card. This is 
one of the most common frauds detected by real card networks. 
Detection Logic:
Identify users with 30 or more transactions below ₹10 in a single day.
*/
SELECT user_id,
	DATE(txn_time) AS txn_date,
	COUNT(txn_id) AS txn_count
FROM transactions
WHERE amount < 10
GROUP BY user_id, DATE(txn_time)
HAVING COUNT(txn_id)>30
ORDER BY DATE(txn_time);


-- P4. Failed-Then-Succeeded 
/*
The pattern: Same card-testing behaviour as P3, but the specific signature this time is many FAILED 
transactions followed by SUCCESS ones. Fraudsters retry until they find a card/CVV combination that 
clears. Real users rarely have more than 2-3 failed transactions in an entire year. Users with 20+ failures 
are running scripts. 
Detection Logic:
Identify users with 20 or more failed transactions.
*/
SELECT
    user_id,
    COUNT(txn_id) AS failed_txn_count
FROM transactions
WHERE status = 'FAILED'
GROUP BY user_id
HAVING COUNT(txn_id) >= 20
ORDER BY failed_txn_count DESC;


-- P5. Odd-Hour Concentration 
/*
The pattern: Real Indian users transact between 8 AM and 11 PM. Automated fraud scripts often run in 
the 2 AM - 5 AM window (which is business hours in North American timezones - many card-cracking 
rings operate from Eastern Europe and the Americas). A user with the vast majority of their activity in 
this window is exhibiting bot signature. 
Detection Logic:
Identify users with at least 30 transactions where 80% or more occur between
2 AM and 5 AM (hours 2, 3, and 4).
*/
SELECT user_id,
    COUNT(txn_id) AS total_transactions,
    SUM(CASE
            WHEN EXTRACT(HOUR FROM txn_time) BETWEEN 2 AND 4 THEN 1
            ELSE 0
        END
    ) AS odd_hour_transactions
FROM transactions
GROUP BY user_id
HAVING COUNT(txn_id) >= 30
   AND SUM(
        CASE
            WHEN EXTRACT(HOUR FROM txn_time) BETWEEN 2 AND 4 THEN 1
            ELSE 0
        END
    ) * 1.0 / COUNT(txn_id) >= 0.80
ORDER BY odd_hour_transactions DESC;


-- P6. Mule Accounts 
/*
The pattern: Mule accounts are the human ATMs of the fraud world. A fraudster deposits stolen funds 
into a mule's account, then quickly withdraws or transfers them elsewhere. The mule keeps a small 
commission. Behaviour signature: large CREDIT transactions (money coming in via NETBANKING) 
immediately followed by DEBIT transactions (money going out via UPI) within 30 minutes. 
Detection Logic:
Identify users with more than 8 CREDIT transactions.
*/
SELECT user_id,
	COUNT(txn_id) AS credit_txn
FROM transactions
WHERE txn_type = 'CREDIT'
GROUP BY user_id
HAVING COUNT(txn_id) > 8
ORDER BY credit_txn DESC;


-- P7. Refund Abuse 
/*
The pattern: Real users have refund rates below 5%. Fraudsters running chargeback schemes or 
exploiting merchant loopholes have refund rates above 40%. The signature is a user with many 
transactions where a disproportionate share are refunds. 
Detection Logic:
Identify users with at least 20 total transactions and a refund ratio greater than 40%.
*/
SELECT
    user_id,
    COUNT(*) AS total_transactions,
    SUM(
        CASE
            WHEN txn_type = 'REFUND' THEN 1
            ELSE 0
        END
    ) AS refund_transactions
FROM transactions
GROUP BY user_id
HAVING COUNT(*) >= 20
   AND SUM(
        CASE
            WHEN txn_type = 'REFUND' THEN 1
            ELSE 0
        END
    ) * 1.0 / COUNT(*) > 0.40
ORDER BY refund_transactions DESC;


-- P8. Merchant Collusion 
/*
The pattern: Legitimate merchants have long tails of customers - thousands of users each contributing 
small amounts to the merchant's total volume. A merchant where 3-4 users generate the majority of 
volume is either a very niche B2B business (rare on retail platforms) or is colluding with those users to 
launder money. 
Detection Logic:
Identify merchants where the top 5 users contribute more than 60% of the total
transaction value.
*/
WITH user_volume AS (
    SELECT
        merchant_id,
        user_id,
        SUM(amount) AS user_total
    FROM transactions
    GROUP BY merchant_id, user_id
),

ranked_users AS (
    SELECT
        merchant_id,
        user_id,
        user_total,
        RANK() OVER (
            PARTITION BY merchant_id
            ORDER BY user_total DESC
        ) AS rnk
    FROM user_volume
),

merchant_volume AS (
    SELECT
        merchant_id,
        SUM(amount) AS merchant_total
    FROM transactions
    GROUP BY merchant_id
)

SELECT
    mv.merchant_id,
    ROUND(SUM(ru.user_total), 2) AS top5_volume,
    ROUND(mv.merchant_total, 2) AS merchant_total,
    ROUND((SUM(ru.user_total) * 100.0 / mv.merchant_total), 2) AS top5_percentage
FROM ranked_users ru
JOIN merchant_volume mv
ON ru.merchant_id = mv.merchant_id
WHERE ru.rnk <= 5
GROUP BY mv.merchant_id, mv.merchant_total
HAVING SUM(ru.user_total) > 0.60 * mv.merchant_total
ORDER BY top5_percentage DESC;


-- P9. Just-Under-Threshold(Structuring) 
/*
The pattern: Indian banking regulations require enhanced KYC checks on transactions of ₹10,000 or 
above. Fraudsters running structuring / smurfing schemes deliberately keep transactions at exactly 
₹9,999 to avoid these checks. This is one of the most classic anti-money-laundering patterns and is 
illegal even without any other fraud. 
Detection Logic:
Identify users with 10 or more transactions of exactly ₹9,999.00.
*/
SELECT
    user_id,
    COUNT(*) AS txn_count
FROM transactions
WHERE amount = 9999.00
GROUP BY user_id
HAVING COUNT(*) >= 10
ORDER BY txn_count DESC;


-- P10. Dormant-Then-Active 
/*
The pattern: An account that was completely inactive for 90+ days and then suddenly bursts with 15+ 
transactions in a short window is the signature of account takeover. The fraudster has gained access to a 
dormant account (via a phishing attack, credential leak, or SIM swap) and is monetising it before the real 
owner notices.  
Detection Logic:
Identify users with a gap of at least 90 days between consecutive transactions,
followed by 15 or more subsequent transactions.
*/
WITH txn_gaps AS (
    SELECT
        user_id,
        txn_time,
        LAG(txn_time) OVER (
            PARTITION BY user_id
            ORDER BY txn_time
        ) AS previous_txn_time
    FROM transactions
),

gap_users AS (
    SELECT
        user_id,
        txn_time AS restart_time
    FROM txn_gaps
    WHERE txn_time - previous_txn_time >= INTERVAL '90 days'
)

SELECT
    g.user_id,
    COUNT(*) AS post_gap_transactions
FROM gap_users g
JOIN transactions t
ON g.user_id = t.user_id
AND t.txn_time >= g.restart_time
GROUP BY g.user_id
HAVING COUNT(*) >= 15;


-- P11. Velocity Spike
/*
The pattern: A user's transaction rate suddenly spikes to many multiples of their historical average. This 
is the ML-free equivalent of anomaly detection - even without training a model, you can identify 
accounts whose behaviour changed abruptly. Almost always indicates account takeover. 
Detection Logic:
Identify users whose peak monthly transaction count is at least 5 times their
average monthly transaction count, with a peak of at least 20 transactions.
*/
WITH monthly_txn AS (
    SELECT
        user_id,
        DATE_TRUNC('month', txn_time) AS txn_month,
        COUNT(*) AS monthly_count
    FROM transactions
    GROUP BY user_id, DATE_TRUNC('month', txn_time)
),

user_stats AS (
    SELECT
        user_id,
        AVG(monthly_count) AS avg_monthly,
        MAX(monthly_count) AS peak_monthly
    FROM monthly_txn
    GROUP BY user_id
)

SELECT
    user_id,
    ROUND(avg_monthly, 2) AS avg_monthly,
    peak_monthly,
    ROUND(peak_monthly / avg_monthly, 2) AS spike_ratio
FROM user_stats
WHERE peak_monthly >= 20
  AND peak_monthly / avg_monthly >= 5
ORDER BY spike_ratio DESC;


-- P12. Geographic Impossibility 
/*
The pattern: The same user transacts in two different Indian cities within 60 minutes. Physically 
impossible unless the account is being used simultaneously by two different people. Almost always 
indicates account takeover or stolen-card usage across a syndicate. 
Detection Logic:
Identify users with at least one pair of consecutive transactions occurring in
different cities within 60 minutes of each other.
*/
WITH cte AS (
    SELECT
        user_id,
        city,
        txn_time,
        LAG(city) OVER(
            PARTITION BY user_id
            ORDER BY txn_time
        ) AS prev_city,
        LAG(txn_time) OVER(
            PARTITION BY user_id
            ORDER BY txn_time
        ) AS prev_time
    FROM transactions
)

SELECT DISTINCT user_id
FROM cte
WHERE city <> prev_city
  AND EXTRACT(EPOCH FROM (txn_time - prev_time))/60 <= 60
ORDER BY user_id;