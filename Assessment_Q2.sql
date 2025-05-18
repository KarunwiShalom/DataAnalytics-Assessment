-- I need to analyze the transaction frequency per customer by month
WITH transacts AS (
    -- Firstly, I need to join the users and transactions tables, and extract each transaction month
    SELECT 
        c.first_name, 
        c.last_name, 
        s.transaction_date, 
        MONTH(s.transaction_date) AS transaction_month
    FROM adashi_staging.users_customuser AS c
    INNER JOIN adashi_staging.savings_savingsaccount AS s
        ON c.id = s.owner_id
),

monthly_counts AS (
    -- Second, I need to count the number of transactions per customer per month
    SELECT 
        first_name,
        last_name,
        transaction_month,
        COUNT(*) AS transactions_per_month
    FROM transacts
    GROUP BY first_name, last_name, transaction_month
),

transaction_frequency AS (
    -- Next, I need to calculate each customer's average monthly transactions
    -- Then I need to assign them to each frequency category (high, mid, low)
    SELECT 
        first_name,
        last_name,
        AVG(transactions_per_month) AS avg_transactions_per_month,
        CASE
            WHEN AVG(transactions_per_month) >= 10 THEN 'High Frequency'
            WHEN AVG(transactions_per_month) BETWEEN 3 AND 9 THEN 'Medium Frequency'
            ELSE 'Low Frequency'
        END AS frequency_category
    FROM monthly_counts
    GROUP BY first_name, last_name
)

-- Lastly, I need to group the table by each frequency category
SELECT
    frequency_category,
    COUNT(*) AS customer_count,
    ROUND(AVG(avg_transactions_per_month), 1) AS avg_transactions_per_month
FROM transaction_frequency
GROUP BY frequency_category;
 

