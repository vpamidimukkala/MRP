**Healthcare Resource Allocation for Seasonal and Emergency Cases Dashboard
Using Synthetic EHR Data (Synthea)**

This project provides interactive analytics dashboards to forecast patient volumes and utilization of hospital resource allocation for seasonal illnesses (e.g., flu, RSV) and trauma cases (e.g., accidents, gunshot injuries). 
The dashboards support hospital administrators in capacity planning, staffing, and equipment allocation, using synthetic EHR data from Synthea.

**Key Features**

**Forecasting Patient Volumes**

Seasonal and trauma-related conditions
Built using Power BI time series forecasting
95% confidence intervals, 92% validation accuracy

**Interactive Multi-Page Dashboard**

Page 1: Patient Volume Forecasts
Page 2: Resource Allocation (Beds, Staff, Ventilators)
Page 3: Scenario Modeling
Drill-down filters for age, gender, condition, and severity

**Scenario Modeling**

Simulated resource demand using 10,000+ synthetic records from Patients, Conditions, Encounters, Procedures, Medications, Observations, and Supplies tables

**Data Transformation**

Grouped conditions (flu, trauma) and severity levels (Low/Medium/High) for targeted planning

**Impact**

Scenario modeling indicates that the dashboards could help reduce projected resource bottlenecks by up to 18%, 
Supporting evidence-based decision-making for hospital administrators in staffing and equipment allocation.

**Tech Stack**

**Data Visualization:** Power BI

**Data Source:** Synthetic EHR data (Synthea)

**Forecasting & Analytics:** Power BI built-in forecasting & DAX

**Data Processing:** Power Query (for grouping, severity mapping, and transformations)
