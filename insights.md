# Fraud Detection

## 📊 Key Findings from Each Fraud Pattern

### P1. Velocity Fraud
* **Detected 50 users** making 30–60 transactions in a single day, significantly exceeding normal customer behavior.

### P2. Round-Amount Clustering
* **Identified 25 users** with 18–30 round-value transactions, indicating potential money laundering or structured fund movement.

### P3. Card Testing
* **Found 20 users** performing 31–60 transactions below ₹10 in a single day, matching common stolen-card testing behavior.

### P4. Failed-Then-Succeeded (Simplified)
* **Detected users** with 20+ failed transactions, suggesting repeated attempts to validate stolen payment credentials.

### P5. Odd-Hour Concentration
* **Identified 20 users** with over 80% of their transactions occurring between 2 AM and 5 AM, a pattern consistent with automated fraud activity.

### P6. Mule Accounts (Simplified)
* **Flagged 25 users** with 9–15 credit transactions, indicating accounts potentially used to receive and transfer illicit funds.

### P7. Refund Abuse
* **Found 24 users** with refund ratios above 40%, suggesting suspicious refund or chargeback abuse.

### P8. Merchant Collusion
* **Detected 15 merchants** (IDs 1–15) where the top five users contributed approximately 99.7%–99.9% of the total transaction value, indicating extremely concentrated activity.

### P9. Just-Under-Threshold Transactions
* **Identified 20 users** making 10–25 transactions of exactly ₹9,999, consistent with transaction structuring to avoid regulatory thresholds.

### P10. Dormant-Then-Active Accounts
* **Detected 26 users** with an inactivity gap of 90+ days, followed by 15–28 transactions, indicating sudden account reactivation.

### P11. Velocity Spike
* **Identified users** whose peak monthly transaction count was at least 5× their average monthly activity, indicating abrupt behavioral changes.

### P12. Geographic Impossibility
* **Found 15 users** (IDs 14741–14755) making consecutive transactions from different cities within 60 minutes, a physically impossible travel pattern.

---

## 💼 Business Impact

* Enabled identification of high-risk users and merchants before fraudulent activity could escalate.
* Strengthened **Anti-Money Laundering (AML)** monitoring by detecting mule accounts, transaction structuring, and merchant collusion.
* Improved payment security by identifying card testing, account takeover indicators, and unusual transaction spikes.
* Reduced potential financial losses by highlighting suspicious refund behavior, excessive failed transactions, and abnormal transaction velocity.
* Demonstrated how SQL-based rule engines can effectively detect fraud without requiring machine learning models.

---

## 🚀 Recommendations

* **Implement real-time monitoring** for transaction velocity, card testing, and geographic anomalies.
* **Introduce risk scoring** by combining multiple fraud indicators instead of evaluating patterns independently.
* **Trigger step-up authentication** (OTP, device verification, biometric verification) for users exhibiting abnormal behavior.
* **Automate reviews or temporary holds** for transactions involving high-risk merchants and suspicious refund activity.
* **Enhance AML compliance** by monitoring repeated ₹9,999 transactions and concentrated merchant-user relationships.
* **Continuously refine fraud detection thresholds** using historical transaction data to minimize false positives.


## Author
**Jayshree Patidar**

**LinkedIn:** https://www.linkedin.com/in/jayshreepatidar

**GitHub:** https://github.com/jayshreepatidar?tab=repositories

**Email:** jayshreepatidar22@gmail.com

