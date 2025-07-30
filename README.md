# Modern Data Warehouse Project – Sales Data Integration & Analytics

# Project Objective
To design and build a modern **data warehouse** using **SQL Server** that consolidates and transforms sales data from ERP and CRM systems into a **medallion architecture** for reporting and data analytics. This enables business stakeholders to gain actionable insights into customer behavior, product performance, and sales trends.

## Data Architecture – Medallion Model

This project follows the **Medallion Architecture**, structured into three layers:

### Bronze Layer – Raw Data
- **Source**: CSV files from ERP and CRM systems
- **Purpose**: Retain original structure for traceability and debugging
- **Object Type**: Tables
- **Actions**: No transformations; direct ingestion of raw data

### Silver Layer – Standardized Data
- **Purpose**: Clean and prepare data for analysis
- **Object Type**: Tables
- **Data Transformations**:
  - Data cleaning
  - Data standardization
  - Data normalization
  - Derived columns
  - Data enrichment  
- **Load Method**: Full load (truncate and insert)

### Gold Layer – Business-Ready Data
- **Purpose**: Enable analytics and reporting
- **Object Type**: Views
- **Data Transformations**:
  - Data integration
  - Data aggregation
  - Business logic and rule application
- **Modeling**: Star schema, flat tables, and aggregated views

---

## Data Sources

- **CRM System** – Customer profiles, product catalog, and sales data
- **ERP System** – Customer identities, country info, location mapping, and product categories

---

## Data Quality Handling

Before analysis, data is cleansed to resolve:
- Null or invalid values
- Duplicates
- Inconsistent formatting (e.g., gender, country names, product keys)
- Inferred or derived columns to enhance usability

---

## Analytical Objectives

Develop SQL-based insights for:
- 📊 **Customer Behavior**: Frequency, engagement, and segmentation
- 📦 **Product Performance**: Sales volume, revenue contribution, and trends
- 📈 **Sales Trends**: Time-series analysis, shipping performance, and order fulfillment

--- 

 ## DATA ARCHITECTURE 
 
 <img width="970" height="536" alt="DATA_ARCHITECTURE" src="https://github.com/user-attachments/assets/9bc602cf-d259-49cc-9ef8-c07366113930" />


## Deliverables

-  Fully functional data warehouse (bronze, silver, gold layers)
-  SQL scripts for transformation and enrichment
-  Star schema-based dimensional model
-  Documented views for analytics and reporting
-  README and documentation for stakeholder clarity

## Hello
My name is **Kate**, an aspiring **data engineer**. This is my first successful data engineering project. I am passionate about 
transforming raw data into insights. 
This project reflects my growing skills in data modeling, transformation, and SQL-based analytics — and I'm excited to share it with you.

