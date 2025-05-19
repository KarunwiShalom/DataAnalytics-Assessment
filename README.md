# DataAnalytics-Assessment
The first thing I noticed while attempting this assessment was the database documentation; it was a MySQL dump file. I have always worked with PostgreSQL, so I needed to figure that bit out first.
After a while of googling, my best option was to download a MySQL server and work directly in MySQL. The syntax was pretty straightforward (even easier than Postgres), so I got the hang of it after reading the documentation and a few videos.
Then I dived into the questions:

## Q1 - High-Value Customers with Multiple Products
### Challenge
I tackled this question last. For some reason, it was quite confusing at the start. Identifying customers with savings and investment plans brought zero results as I looked through the plan table. Although I knew it was improbable that there were no high-value customers, I was stuck here for a while. After going through the rest of the questions and getting familiar with the tables, I figured out that every row was a distinct plan, so I needed to connect with the customers' table to get results.

### Workflow
Moving on to answer the question, I answered it in four steps:
A - I connected the three tables together (users, plans, and transactions), where I filtered only successful deposits, and I grouped the results by each customer (one row per customer), extracting only the columns I needed from the three tables
B - The resulting table had some customers who didn't have a plan but had a successful deposit, so I added an aggregation filter via a subquery for only customers with at least one of each plan
C - I used a case when statement to get the total count of funded plans by each customer (savings and investment), and added a sum function to get the total deposits across both plans per customer
D - Finally, I sorted the table by descending order of deposits

## Q2 - Transaction Frequency Analysis
### Challenge
The main challenge I faced here was writing a single query to answer the question. At first glance, I knew I needed multiple subqueries to extract and group. Usually, I would have used temporary tables to break down the question more clearly, but a single query would require CTE's. I first created temp tables and then built the query by converting the temp tables into CTE's.

### Workflow
A - Firstly, I needed to join the users and transactions tables, and I also needed a new column that only contained the months from the transaction date column
B - Then I counted the number of transactions per customer per month and grouped the table by each customer
C - Next, I calculated each customer's average monthly transactions, and then assigned the average monthly transactions to each frequency category (high, mid, low) based on each customer's volume using a case statement
E - Lastly, I had my final table by grouping the data based on the frequency categories, displaying the customer count and average transactions per month for each category

## Q3 - Account Inactivity Alert
### Challenge
My main challenge was getting the account type column; I needed to check whether each row was a savings or investment account and return the result in a column. The savings and investment accounts were booleans (1 meant yes, 0 meant no for each column). I couldn't add the non-aggregated column into the group by clause, as I was already grouping by the plan ID column; I needed the computer to ignore the non-aggregation and return the account type based on '1' or '0'. The good thing here was that each row was unique (either a savings or investment plan and not both), so I found a function that worked perfectly - ANYVALUE (). I wrapped the case statement in it, basically telling SQL to check both columns and return the value regardless of the non-aggregation.

### Workflow
A - First, I had to get all accounts that had either a savings or investment plan
B - Next, I added a filter for accounts where the last transaction recorded was over a year ago (current date - 365 days)
C - From the resulting table, I had all accounts dormant for a year, then I added three calculated columns so that for each row I could see:
  i - How long they had been dormant for (days of inactivity)
  ii - Their account type (either Investment or Savings)'
  iii - Last transaction date
D - Lastly, I sorted the table in descending order of inactivity

## Q4 - Customer Lifetime Value (CLV) Estimation
### Challenge
This question was the easiest to break down, and didn't give me any challenges. The formula was simple enough, and I just extracted the columns I needed to perform the aggregations I needed.

### Workflow
A - First, I joined the users and transactions tables, extracting the necessary columns and filtering only successful deposits. From these columns, I created two calculated columns - months since the customer account was created (tenure months) and 0.1% of each transaction amount (profit per transaction). I also concatenated the first and last name columns to create a single name column
B - Next, from my streamlined table, I aggregated the total transactions and average profit per customer from my prior calculated columns
C - I had all the variables for my CLV formula, so I went ahead to create my calculated CLV column for each customer ID and order the final table in descending order of the estimated CLV
