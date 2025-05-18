/*
I need customers with at least one funded savings plan AND one funded investment plan
I also need to return total confirmed deposits, grouped by each customer
*/
SELECT 
    owner_id, 
    name,

    -- A total count of funded savings plans by each customer
    SUM(CASE 
            WHEN is_regular_savings = 1 AND confirmed_amount > 0 THEN 1 
            ELSE 0 
        END) AS savings_count, 

    -- A total count of each funded investment plans by each customer
    SUM(CASE 
            WHEN is_a_fund = 1 AND confirmed_amount > 0 THEN 1 
            ELSE 0 
        END) AS investment_count, 

    -- Total confirmed deposits across both plans rounded up to 2 decimal places
    ROUND(SUM(confirmed_amount), 2) AS total_deposits
    
FROM (
    -- I'm adding a subquery to join users, plans, and transactions
    -- I'm filtering by only successful transactions
    SELECT 
        p.owner_id, 
        CONCAT(c.first_name, ' ', c.last_name) AS name, -- merging each customer's first and last name
        p.is_regular_savings, 
        p.is_a_fund, 
        s.confirmed_amount
    FROM adashi_staging.users_customuser AS c
    INNER JOIN adashi_staging.plans_plan AS p 
        ON c.id = p.owner_id
    INNER JOIN adashi_staging.savings_savingsaccount AS s 
        ON p.id = s.plan_id
    WHERE s.transaction_status = 'success'
) AS high_value

-- Grouping the resulting table by each customer
GROUP BY owner_id, name

-- A necessary filter here where each customer must have at least one funded savings and one funded investment plan
HAVING 
    SUM(CASE 
            WHEN is_regular_savings = 1 AND confirmed_amount > 0 THEN 1 
            ELSE 0 
        END) >= 1
    AND
    SUM(CASE 
            WHEN is_a_fund = 1 AND confirmed_amount > 0 THEN 1 
            ELSE 0 
        END) >= 1

-- Sorting the resulting table by total deposit amount in descending order
ORDER BY total_deposits DESC;

