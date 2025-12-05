# CERA: Customer Exit Risk Analyzer

**Project:** Customer Churn Analysis and Retention Strategy  
**Initiative:** Digital Egypt Pioneers Initiative (DEPI)  

---

## 🌟 Project Overview
CERA (Customer Exit Risk Analyzer) is a complete solution for analyzing customer behavior and predicting churn risk. Using historical customer transaction and activity data, our team built a machine learning model to identify customers likely to leave, deployed an interactive app, and created a Power BI dashboard for business insights.

This project was completed end-to-end, covering **data exploration, modeling, deployment, and retention strategy recommendations**.

---

## 🛠️ What We Did

### **1. Data Collection, Exploration, and Preprocessing**
- Collected raw datasets including customer, payment, plan, and activity tables.
- Explored and visualized customer data using EDA notebooks:
  - Identified patterns such as high complaint frequency correlating with churn.
  - Generated class imbalance and feature distribution reports.
- Preprocessed the data:
  - Encoded categorical variables (`gender`, `plan type`, `payment method`)
  - Scaled numeric features
  - Cleaned duplicates values
- The `SQL_Scripts` for building the Data Warehouse and ETL pipeline:
  - **Staging Layer:** Create staging tables and load raw CSVs.  
  - **Transformation Layer:** Clean and transform data into the Cleansed schema.  
  - **Data Warehouse (DWH):** Create dimension and fact tables and load from Cleansed tables.  
- Created **Power BI dashboard** for visualizing customer patterns and high-risk segments.

**Files:**
- `Notebooks/EDA_Analysis.ipynb`
- `Data/Raw`
- `SQL_Scripts`
- `PowerBI/Customer churn.pbix`
- `Reports/feature_distributions.png`, `Reports/correlation_heatmap.png`

---

### **2. Predictive Model Development**
- Developed and trained classification models.
- Split data into train/test sets and evaluated performance:
  - Metrics: Accuracy, Precision, Recall, F1-score, ROC-AUC
- Tuned hyperparameters and interpreted feature importance to understand churn drivers.

**Files:**
- `Models/churn_prediction_model.pkl`
- `Models/feature_columns.pkl`
- `Models/scaler.pkl`
- `Notebooks/Model_Training.ipynb`, `Notebooks/Model_Evaluation.ipynb`
- `Reports/feature_importance.png`, `Reports/roc_curve.png`, `Reports/confusion_matrix.png`

---

### **3. Deployment and Retention Strategy**
- Built a **Streamlit app** for predicting customer churn in real time.
  - Users can input customer data to see churn risk instantly.
- Suggested actionable retention strategies:
  - Targeted offers for high-risk customers
  - Enhanced support for customers with recurring complaints

**Files:**
- `Streamlit_App/pages/Homepage.py`

---

## 🚀 How to Run the Project

### 1. Environment Setup
```bash
# Clone the repo
git clone https://github.com/Sayed-Esmail/Customer-Churn-Analysis-and-Retention-Strategy.git

# Navigate to the repo
cd Customer-Churn-Analysis-and-Retention-Strategy

# Install dependencies
pip install -r requirements.txt

2. Run Streamlit App
streamlit run Streamlit_App/Homepage.py

3. Explore Power BI Dashboard
Open PowerBI/Customer churn.pbix in Power BI Desktop for interactive visualizations.
