# RFM Segmentation Analysis

This repository contains the code and analysis for performing RFM (Recency, Frequency, Monetary) segmentation on customer data. RFM analysis is a valuable technique for classifying customers into distinct segments based on their transaction behaviors. By identifying these segments, businesses can tailor their marketing and engagement strategies to better meet the specific needs of each customer group.

# Dataset

The analysis is conducted using the "rfm" dataset, which is part of the "turing_data_analytics" database located in the Turing College BigQuery project. This dataset contains transaction data that is used for the RFM analysis.

# Task Objectives

The primary objectives of this analysis are as follows:

- Utilize one year of data, specifically from 2010-12-01 to 2011-12-01.
- Perform the RFM calculation and data selection using SQL.
- Calculate recency, frequency, and monetary values and convert them into R, F, and M scores based on quartiles.
- Segment customers into different categories, such as "Top Customers," "Loyal Customers," "Lost Customers," and others based on their RFM scores.
- Present the analysis and segmentation results with a dashboard in Tableau.
- Provide insights and recommendations on which customer group(s) the marketing team should focus on.

# SQL Query

The analysis is primarily driven by SQL queries in BigQuery. The main steps of the analysis include:
- Computing the RFM values by using SQL queries, where recency, frequency, and monetary values are calculated.
- Creating quartiles for R, F, and M values using the APPROX_QUANTILES function.
- Assigning RFM scores to customers based on their quartile values.
- Defining RFM segments based on the combination of R, F, and M scores.

# Insights and Strategies

The analysis results in the categorization of customers into various segments, each with its unique characteristics and engagement strategies. Some of the key segments and their respective strategies are as follows:
- **Top Customers**: These customers buy frequently, spend the most, and have made recent purchases. They should be rewarded and encouraged to promote your brand.
- **Loyal Customers**: Loyal customers spend regularly and respond well to promotions. Businesses should focus on upselling higher-value products, asking for reviews, and engaging with them.
- **Customers Needing Attention**: These customers have above-average recency, frequency, and monetary value but may not have bought recently. Strategies should include limited-time offers, personalized recommendations, and reactivation efforts.
- **Can't Lose Them**: Customers in this segment made significant purchases and bought often but haven't returned for a long time. Strategies should aim to win them back through renewals or new products and maintain engagement.
- **Promising**: Promising customers are recent shoppers but haven't spent much. The focus should be on converting them into loyal customers by creating brand awareness and offering free trials.
- **At Risk**: Customers who spent an average amount and purchased quite often but a long time ago. Strategies include personalized emails to reconnect, renewals, and providing helpful resources.
- **About To Sleep**: These customers have below-average recency, frequency, and monetary values and may be at risk of disengaging. Reactivation efforts should be a priority.
- **Lost Customers**: The lowest recency, frequency, and monetary scores. Strategies should involve campaigns to win them back and collecting feedback through personalized surveys.
- **Hibernating**: Customers in this segment made their last purchase a long time ago, are low spenders, and have a low number of orders. Strategies should recommend relevant products from other categories and provide personalized offers.
- **New Customers**: Customers who made a purchase most recently. Strategies should focus on providing a smooth onboarding experience and offering assistance when needed.

<img width="964" alt="image" src="https://github.com/klavru/RFM-Analysis/assets/128393456/4786547c-5344-4d9f-b93f-4206dcaaaef9">

Link to my dashboard:

https://public.tableau.com/app/profile/karolina.lavrukaityte/viz/RFMSegmentationFinal/RFMSegmentation 


By performing RFM segmentation analysis and utilizing the insights gained, businesses can enhance their customer engagement strategies, improve marketing campaigns, and drive growth by catering to the specific needs and behaviors of each customer segment.

