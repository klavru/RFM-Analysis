WITH 
--Compute for F & M
FM_table AS (
    SELECT  
    CustomerID,
    /*Country,*/
    MAX(DATE_TRUNC(InvoiceDate, DAY)) AS last_purchase_date,
    COUNT(DISTINCT InvoiceNo) AS frequency,
    SUM(Quantity * UnitPrice) AS monetary 
    FROM tc-da-1.turing_data_analytics.rfm

    WHERE 
	 (DATE_TRUNC (InvoiceDate,DAY)) BETWEEN '2010-12-01' AND '2011-12-01'
     AND Quantity > 0 
     AND UnitPrice > 0

    GROUP BY CustomerID 
),
--Compute for R
R_table AS
    (SELECT 
    CustomerID,
    frequency,
    monetary,
    DATE_DIFF(reference_date, (CAST (last_purchase_date AS DATE)), DAY) AS recency
    FROM (
        SELECT  *,
        MAX(CAST (last_purchase_date AS DATE)) OVER ()+1  AS reference_date
        FROM FM_table
    )),

	quantiles AS (
SELECT 
    R_table.*,
    --All percentiles for MONETARY
    monetary_percentiles.percentiles[offset(25)] AS m25, 
    monetary_percentiles.percentiles[offset(50)] AS m50,
    monetary_percentiles.percentiles[offset(75)] AS m75, 
    monetary_percentiles.percentiles[offset(100)] AS m100,    
    --All percentiles for FREQUENCY
    frequency_percentiles.percentiles[offset(25)] AS f25, 
    frequency_percentiles.percentiles[offset(50)] AS f50,
    frequency_percentiles.percentiles[offset(75)] AS f75, 
    frequency_percentiles.percentiles[offset(100)] AS f100,    
    --All percentiles for RECENCY
    recency_percentiles.percentiles[offset(25)] AS r25, 
    recency_percentiles.percentiles[offset(50)] AS r50,
    recency_percentiles.percentiles[offset(75)] AS r75, 
    recency_percentiles.percentiles[offset(100)] AS r100
FROM 
    R_table,
    (SELECT APPROX_QUANTILES(monetary, 100) percentiles FROM
    R_table) monetary_percentiles,
    (SELECT APPROX_QUANTILES(frequency, 100) percentiles FROM
    R_table) frequency_percentiles,
    (SELECT APPROX_QUANTILES(recency, 100) percentiles FROM
    R_table) recency_percentiles
),  

assign_scores AS (
    SELECT *, 
    FROM (
        SELECT *, 
        CASE WHEN monetary <= m25 THEN 1
            WHEN monetary <= m50 AND monetary > m25 THEN 2 
            WHEN monetary <= m75 AND monetary > m50 THEN 3 
            WHEN monetary <= m100 AND monetary > m75 THEN 4 
        END AS m_score,
        CASE WHEN frequency <= f25 THEN 1
            WHEN frequency <= f50 AND frequency > f25 THEN 2 
            WHEN frequency <= f75 AND frequency > f50 THEN 3 
            WHEN frequency <= f100 AND frequency > f75 THEN 4 
        END AS f_score,
        --Recency scoring is reversed
        CASE WHEN recency <= r25 THEN 4
            WHEN recency <= r50 AND recency > r25 THEN 3
            WHEN recency <= r75 AND recency > r50 THEN 2 
            WHEN recency <= r100 AND recency > r75 THEN 1 
        END AS r_score,
        FROM quantiles
        )
),

--Define RFM segments 
segments AS (
    SELECT 
        CustomerID, 
        recency,
        frequency, 
        monetary,
        r_score,
        f_score,
        m_score,
        CASE WHEN (r_score = 4 AND f_score = 4 AND m_score = 4) 
        THEN 'Top Customers'
        WHEN (r_score = 4 AND f_score = 4 AND m_score = 3)
            OR (r_score = 4 AND f_score = 4 AND m_score = 2)
            OR (r_score = 3 AND f_score = 4 AND m_score = 4)
            OR (r_score = 3 AND f_score = 4 AND m_score = 3) 
            OR (r_score = 3 AND f_score = 4 AND m_score = 2)
            OR (r_score = 3 AND f_score = 4 AND m_score = 1)
            OR (r_score = 2 AND f_score = 4 AND m_score = 3)
            OR (r_score = 2 AND f_score = 4 AND m_score = 2)
            OR (r_score = 2 AND f_score = 4 AND m_score = 1)
            OR (r_score = 4 AND f_score = 4 AND m_score = 1)
        THEN 'Loyal Customers' -- buying the most often
        WHEN  (r_score = 4 AND f_score = 3 AND m_score = 4)
            OR (r_score = 3 AND f_score = 3 AND m_score = 4)
            OR (r_score = 4 AND f_score = 2 AND m_score = 4)
            OR (r_score = 4 AND f_score = 2 AND m_score = 3) 
            OR (r_score = 3 AND f_score = 2 AND m_score = 4)
            OR (r_score = 4 AND f_score = 1 AND m_score = 4)
            OR (r_score = 3 AND f_score = 1 AND m_score = 4)
            OR (r_score = 3 AND f_score = 3 AND m_score = 3) 
            OR (r_score = 4 AND f_score = 3 AND m_score = 3)  
            OR (r_score = 3 AND f_score = 2 AND m_score = 3) 
            OR (r_score = 3 AND f_score = 1 AND m_score = 3)   
        THEN 'Cant Lose Them' -- really potential, spends a lot and bought recently
        WHEN (r_score = 4 AND f_score = 1 AND m_score = 1) THEN 'New Customers'
        WHEN (r_score = 3 AND f_score = 1 AND m_score = 1) 
            OR (r_score = 4 AND f_score = 1 AND m_score = 2) 
            OR (r_score = 4 AND f_score = 2 AND m_score = 2)
            OR (r_score = 4 AND f_score = 3 AND m_score = 2)
            OR (r_score = 3 AND f_score = 1 AND m_score = 2)
            OR (r_score = 3 AND f_score = 2 AND m_score = 2)
            OR (r_score = 3 AND f_score = 3 AND m_score = 1)
            OR (r_score = 4 AND f_score = 3 AND m_score = 1) 
            OR (r_score = 3 AND f_score = 3 AND m_score = 2) 
            OR (r_score = 3 AND f_score = 2 AND m_score = 1) 
            OR (r_score = 4 AND f_score = 2 AND m_score = 1)
            OR (r_score = 4 AND f_score = 1 AND m_score = 3)
        THEN 'Promising' -- don't spend a lot but bought recently and/or frequently 
        WHEN (r_score = 1 AND f_score = 4 AND m_score = 4) 
            OR (r_score = 2 AND f_score = 4 AND m_score = 4)
            OR (r_score = 1 AND f_score = 1 AND m_score = 3)
            OR (r_score = 1 AND f_score = 2 AND m_score = 3)
            OR (r_score = 1 AND f_score = 3 AND m_score = 3)
            OR (r_score = 1 AND f_score = 3 AND m_score = 2) 
            OR (r_score = 2 AND f_score = 3 AND m_score = 3) 
            OR (r_score = 2 AND f_score = 1 AND m_score = 3) 
            OR (r_score = 1 AND f_score = 4 AND m_score = 3)
            OR (r_score = 1 AND f_score = 4 AND m_score = 2)
            OR (r_score = 1 AND f_score = 4 AND m_score = 1)
            OR (r_score = 1 AND f_score = 3 AND m_score = 4)
            OR (r_score = 1 AND f_score = 2 AND m_score = 4)
            OR (r_score = 1 AND f_score = 1 AND m_score = 4)  
            OR (r_score = 2 AND f_score = 3 AND m_score = 4)
            OR (r_score = 2 AND f_score = 2 AND m_score = 4)
            OR (r_score = 2 AND f_score = 1 AND m_score = 4)
            OR (r_score = 2 AND f_score = 3 AND m_score = 1) 
        THEN 'Customers Needing Attention' -- spends a lot or have high score in F but didn't buy for a long time 
        WHEN (r_score = 2 AND f_score = 2 AND m_score = 2) 
            OR (r_score = 2 AND f_score = 2 AND m_score = 3)
            OR (r_score = 2 AND f_score = 3 AND m_score = 2)
            THEN 'About to Sleep' -- long time since last order but spends 2-3
        WHEN (r_score = 2 AND f_score = 1 AND m_score = 2)
            OR (r_score = 1 AND f_score = 1 AND m_score = 2)
            OR (r_score = 2 AND f_score = 2 AND m_score = 1)
            OR (r_score = 1 AND f_score = 2 AND m_score = 1)
            OR (r_score = 2 AND f_score = 1 AND m_score = 1)
        THEN 'At Risk' --  spends a little, small score in frequency and in recency
        WHEN (r_score = 1 AND f_score = 2 AND m_score = 2)
            OR (r_score = 1 AND f_score = 3 AND m_score = 1) 
         THEN 'Hibernating' -- long time since the last order but average frequency
        WHEN (r_score = 1 AND f_score = 1 AND m_score = 1) THEN 'Lost Customers'
        ELSE 'Others'
        END AS rfm_segment 
    FROM assign_scores
)

SELECT * FROM segments
