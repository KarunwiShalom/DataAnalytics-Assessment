/*
I need to find all active savings or investment accounts,
Then identify those that have been inactive for over 365 days,
And return their account type and inactivity duration
*/
WITH active_accounts AS (
    -- First I need to get all accounts that are either savings or investment plans
    SELECT 
        s.plan_id, 
        s.owner_id, 
        p.start_date, 
        s.transaction_date, 
        p.is_a_fund, 
        p.is_regular_savings
    FROM adashi_staging.plans_plan AS p
    INNER JOIN adashi_staging.savings_savingsaccount AS s
        ON p.id = s.plan_id
    WHERE p.is_a_fund = 1 OR p.is_regular_savings = 1
),

inactive_accounts AS (
    -- Next I need to filter for accounts where the last transaction was over a year ago
    SELECT *
    FROM active_accounts
    WHERE transaction_date <= CURDATE() - INTERVAL 365 DAY
)

-- Then I calculate how long they've been dormant and label their account type
SELECT
    plan_id, 
    owner_id,

    -- Checking the account type (either Investment or Savings)
    CASE 
        WHEN ANY_VALUE(is_a_fund) = 1 THEN 'Investment'
        WHEN ANY_VALUE(is_regular_savings) = 1 THEN 'Savings'
    END AS type,

    -- Checking for the last known transaction date
    MAX(transaction_date) AS last_transaction_date,

    -- How many days since last transaction?
    DATEDIFF(CURDATE(), MAX(transaction_date)) AS inactivity_days

FROM inactive_accounts
GROUP BY plan_id, owner_id
ORDER BY inactivity_days DESC; -- Descending order of inactivity
