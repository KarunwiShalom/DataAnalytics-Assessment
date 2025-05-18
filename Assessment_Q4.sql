/*
I need to calculate the estimated Customer Lifetime Value (CLV) for selected customers
These customers need to be selected based on tenure, transaction history, and average profit per transaction
*/
WITH customer_value AS (
    -- First, I need to join the users and transactions tables, and aggregate profit, and tenure
    SELECT 
        c.id,
        CONCAT(c.first_name, ' ', c.last_name) AS name, -- Combining first and last names
        TIMESTAMPDIFF(MONTH, c.date_joined, CURDATE()) AS tenure_months, -- Account tenure in months
        s.confirmed_amount,
        s.confirmed_amount * 0.001 AS profit_per_transaction -- 0.1% profit per transaction
    FROM adashi_staging.users_customuser AS c
    INNER JOIN adashi_staging.savings_savingsaccount AS s
        ON c.id = s.owner_id
    WHERE s.transaction_status = 'success' -- Considering only successful transactions
),

cust_transactions AS (
    -- Next, I need to aggregate total transactions and average profit per customer
    SELECT 
        id, 
        name,
        tenure_months,
        COUNT(*) AS total_transactions,
        AVG(profit_per_transaction) AS avg_profit_per_transaction
    FROM customer_value
    GROUP BY id, name, tenure_months
)

-- Finally I can estimate each customer's CLV based on average monthly transactions and profit
SELECT 
    id AS customer_id,
    name,
    tenure_months,
    total_transactions,
    ROUND(((total_transactions / tenure_months) * 12 * avg_profit_per_transaction), 2) AS estimated_clv -- Customer Lifetime Value (CLV)
FROM cust_transactions
GROUP BY id, name, tenure_months, total_transactions, avg_profit_per_transaction
ORDER BY estimated_clv DESC; -- Descending order of value

