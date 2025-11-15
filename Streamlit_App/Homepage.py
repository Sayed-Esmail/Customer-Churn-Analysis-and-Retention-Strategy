import streamlit as st
import pandas as pd
import joblib
import numpy as np

def load_css():
    """Applies custom CSS for a professional UI."""
    st.markdown("""
        <style>
        /* --- 1. Global Fade-In Animation --- */
        [data-testid="stAppViewContainer"] > section {
            animation: fadeIn 1s ease-in-out;
        }
        @keyframes fadeIn {
            0% { opacity: 0; transform: translateY(20px); }
            100% { opacity: 1; transform: translateY(0); }
        }
        /* --- 2. Button Hover Animation --- */
        .stButton > button {
            transition: all 0.3s ease-in-out;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
        }
        .stButton > button:hover {
            transform: scale(1.03);
            box-shadow: 0 8px 12px rgba(0, 0, 0, 0.15);
            background-color: #FF6347; /* A warmer color on hover */
            color: white;
        }
        /* --- 3. Card/Container Hover Animation --- */
        [data-testid="stVerticalBlock"] > [style*="border: 1px solid"] {
            transition: all 0.3s ease-in-out;
        }
        [data-testid="stVerticalBlock"] > [style*="border: 1px solid"]:hover {
            box-shadow: 0 10px 20px rgba(0, 0, 0, 0.12);
            transform: translateY(-3px);
            border-color: #FF6347; /* Highlight border on hover */
        }
        /* --- 4. Metric Card Hover --- */
        [data-testid="stMetric"] {
            transition: all 0.3s ease-in-out;
            border-radius: 10px;
        }
        [data-testid="stMetric"]:hover {
            background-color: #f0f2f6; /* Light background on hover */
        }
        /* --- 5. Clean up Sidebar --- */
        [data-testid="stSidebar"] {
            padding: 1rem;
        }
        </style>
    """, unsafe_allow_html=True)

st.set_page_config(
    page_title="Home Page",
    page_icon="🏠",
    layout="wide"
)

load_css()

@st.cache_resource
def load_model_artifacts():
    """Loads the model and feature columns."""
    try:
        model = joblib.load('Models/churn_prediction_model.pkl')
        feature_columns = joblib.load('Models/feature_columns.pkl')
        return model, feature_columns
    except FileNotFoundError:
        st.error("Model artifacts not found. Please run the training script.")
        return None, None

@st.cache_data
def load_homepage_data():
    """Loads the processed data for KPIs."""
    try:
        df = pd.read_csv('Data/Processed/churn_ml_dataset.csv')
        return df
    except FileNotFoundError:
        st.error("Data file not found. Please check the path.")
        return None

model, feature_columns = load_model_artifacts()
df = load_homepage_data()

st.title("👤 Customer Churn Prediction")

if df is not None and model is not None:
    st.markdown("### 📈 Executive Summary")
    
    total_customers = df.shape[0]
    total_churn = df[df['Target'] == 1].shape[0]
    churn_rate = (total_churn / total_customers) * 100
    
    if hasattr(model, 'feature_importances_'):
        importances = model.feature_importances_
    elif hasattr(model, 'coef_'):
        importances = np.abs(model.coef_[0])
    
    fi_df = pd.DataFrame({'feature': feature_columns, 'importance': importances})
    fi_df = fi_df.sort_values('importance', ascending=False)
    highest_risk_factor = fi_df.iloc[0]['feature']
    highest_risk_factor = highest_risk_factor.replace('_', ' ').title()

    col1, col2, col3 = st.columns(3)
    col1.metric("Total Customers Analyzed", f"{total_customers:,}")
    col2.metric("Overall Churn Rate", f"{churn_rate:.1f}%")
    col3.metric("Highest Risk Factor", highest_risk_factor)
    st.markdown("---")


st.subheader("A machine learning application for identifying high-risk customers.")

with st.container(border=True):
    st.header("Project Overview")
    st.markdown("""
    This interactive application is a showcase of a complete data science pipeline for predicting customer churn. 
    It leverages machine learning to proactively identify customers who are likely to stop using a service, 
    allowing businesses to take retention-focused actions.
    """)
    
    col1, col2 = st.columns(2)
    
    with col1:
        st.subheader("🎯 Why is this important?")
        st.markdown("""
        Acquiring a new customer is significantly more expensive than retaining an existing one. 
        By accurately predicting churn, we can:
        - Reduce revenue loss.
        - Improve customer satisfaction.
        - Optimize marketing spend on retention campaigns.
        """)

    with col2:
        st.subheader("🧭 Explore the App")
        st.markdown("""
        Use the sidebar to navigate through the application:
        
        - **📊 Data Explorer:** An interactive dashboard to explore the dataset.
        - **🤖 Churn Predictor:** A live tool to predict churn for a single customer.
        - **📈 Model Performance:** A detailed report on the model's accuracy and insights.
        """)

with st.container(border=True):
    st.header("Technology Stack")
    st.markdown("""
    **Tools Used:** Python, Pandas, Scikit-learn, XGBoost/LogisticRegression, Streamlit, Plotly
    """)