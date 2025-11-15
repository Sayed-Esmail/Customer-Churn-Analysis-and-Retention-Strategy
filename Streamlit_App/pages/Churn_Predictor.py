import streamlit as st
import pandas as pd
import numpy as np
import joblib
import plotly.express as px
from sklearn.linear_model import LogisticRegression 
import time

def load_css():
    """Applies custom CSS for a professional UI."""
    st.markdown("""
        <style>
        [data-testid="stAppViewContainer"] > section {
            animation: fadeIn 1s ease-in-out;
        }
        @keyframes fadeIn {
            0% { opacity: 0; transform: translateY(20px); }
            100% { opacity: 1; transform: translateY(0); }
        }
        .stButton > button {
            transition: all 0.3s ease-in-out;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
        }
        .stButton > button:hover {
            transform: scale(1.03);
            box-shadow: 0 8px 12px rgba(0, 0, 0, 0.15);
            background-color: #FF6347;
            color: white;
        }
        [data-testid="stVerticalBlock"] > [style*="border: 1px solid"] {
            transition: all 0.3s ease-in-out;
        }
        [data-testid="stVerticalBlock"] > [style*="border: 1px solid"]:hover {
            box-shadow: 0 10px 20px rgba(0, 0, 0, 0.12);
            transform: translateY(-3px);
            border-color: #FF6347;
        }
        [data-testid="stMetric"] {
            transition: all 0.3s ease-in-out;
            border-radius: 10px;
        }
        [data-testid="stMetric"]:hover {
            background-color: #f0f2f6;
        }
        [data-testid="stSidebar"] {
            padding: 1rem;
        }
        </style>
    """, unsafe_allow_html=True)

st.set_page_config(layout="wide")

load_css() 

# --- Load Artifacts ---
MODEL_PATH = 'Models/churn_prediction_model.pkl'
SCALER_PATH = 'Models/scaler.pkl'
COLUMNS_PATH = 'Models/feature_columns.pkl'

@st.cache_resource
def load_artifacts():
    model = joblib.load(MODEL_PATH)
    scaler = joblib.load(SCALER_PATH)
    feature_columns = joblib.load(COLUMNS_PATH)
    return model, scaler, feature_columns

try:
    model, scaler, feature_columns = load_artifacts()
    numeric_features = [
        'Monthly_Charges', 'Total_Charges', 'Tenure_Months', 
        'Internet_Usage_GB', 'Calls_Minutes', 'Customer_Satisfaction_Score'
    ]
except Exception as e:
    st.error(f"Error loading artifacts: {e}")
    st.stop()

# --- Sidebar Inputs ---
st.sidebar.header("Customer Input Features (Single Prediction)")
st.sidebar.subheader("Demographics & Account")
gender = st.sidebar.selectbox("Gender", ['male', 'female'])
senior_citizen = st.sidebar.radio("Senior Citizen", [True, False], format_func=lambda x: 'Yes' if x else 'No')
partner = st.sidebar.radio("Has Partner", [True, False], format_func=lambda x: 'Yes' if x else 'No')
dependents = st.sidebar.radio("Has Dependents", [True, False], format_func=lambda x: 'Yes' if x else 'No')
st.sidebar.subheader("Contract & Services")
contract_type = st.sidebar.selectbox("Contract Type", ['month-to-month', 'one year', 'two year'])
internet_service = st.sidebar.selectbox("Internet Service Type", ['dsl', 'fiber optic', 'no'])
phone_service = st.sidebar.radio("Phone Service", [True, False], format_func=lambda x: 'Yes' if x else 'No')
multiple_lines = st.sidebar.radio("Multiple Lines", [True, False], format_func=lambda x: 'Yes' if x else 'No')
tech_support = st.sidebar.radio("Tech Support", [True, False], format_func=lambda x: 'Yes' if x else 'No')
online_security = st.sidebar.radio("Online Security", [True, False], format_func=lambda x: 'Yes' if x else 'No')
online_backup = st.sidebar.radio("Online Backup", [True, False], format_func=lambda x: 'Yes' if x else 'No')
device_protection = st.sidebar.radio("Device Protection", [True, False], format_func=lambda x: 'Yes' if x else 'No')
streaming_tv = st.sidebar.radio("Streaming TV", [True, False], format_func=lambda x: 'Yes' if x else 'No')
streaming_movies = st.sidebar.radio("Streaming Movies", [True, False], format_func=lambda x: 'Yes' if x else 'No')
plan_price_tier = st.sidebar.selectbox("Plan Price Tier", ['Standard', 'Premium', 'Low'])
payment_method = st.sidebar.selectbox("Payment Method", ['electronic check', 'mailed check', 'bank transfer (automatic)', 'credit card (automatic)'])
paperless_billing = st.sidebar.radio("Paperless Billing", [True, False], format_func=lambda x: 'Yes' if x else 'No')
auto_payment = st.sidebar.radio("Auto Payment", [True, False], format_func=lambda x: 'Yes' if x else 'No')
st.sidebar.subheader("Usage & Metrics")
tenure_months = st.sidebar.slider("Tenure (Months)", 0, 72, 12)
monthly_charges = st.sidebar.number_input("Monthly Charges ($)", min_value=0.0, max_value=200.0, value=50.0)
total_charges = st.sidebar.number_input("Total Charges ($)", min_value=0.0, max_value=10000.0, value=500.0)
internet_usage_gb = st.sidebar.slider("Internet Usage (GB)", 0, 200, 20)
calls_minutes = st.sidebar.slider("Calls (Minutes)", 0, 500, 100)
satisfaction_score = st.sidebar.slider("Customer Satisfaction Score", 1.0, 10.0, 5.0, 0.1)

# --- TABS UI ---
st.title("🤖 Customer Churn Predictor")
tab1, tab2 = st.tabs(["👤 Single Customer Prediction", "📂 Batch Prediction (Upload File)"])

# --- TAB 1: SINGLE CUSTOMER PREDICTION ---
with tab1:
    st.header("Predict for a Single Customer")
    st.markdown("Use the sidebar to enter customer details and click predict.")
    
    if st.button("🔮 Predict Churn (Single)"):
        with st.spinner('Analyzing Customer Data...'):
            time.sleep(0.5) # Simulate analysis time
            
            input_data = {
                'Gender': gender, 'Senior_Citizen': senior_citizen, 'Partner': partner,
                'Dependents': dependents, 'Contract_Type': contract_type, 'Internet_Service_Type': internet_service,
                'Phone_Service': phone_service, 'Multiple_Lines': multiple_lines, 'Tech_Support': tech_support,
                'Online_Security': online_security, 'Online_Backup': online_backup, 'Device_Protection': device_protection,
                'Streaming_TV': streaming_tv, 'Streaming_Movies': streaming_movies, 'Plan_Price_Tier': plan_price_tier,
                'Payment_Method': payment_method, 'Paperless_Billing': paperless_billing, 'Auto_Payment': auto_payment,
                'Monthly_Charges': monthly_charges, 'Total_Charges': total_charges, 'Tenure_Months': tenure_months,
                'Internet_Usage_GB': internet_usage_gb, 'Calls_Minutes': calls_minutes, 'Customer_Satisfaction_Score': satisfaction_score
            }
            input_df = pd.DataFrame([input_data])
            
            # Preprocessing
            for col in numeric_features:
                input_df[col] = input_df[col].astype(float)
            categorical_cols = input_df.select_dtypes(include=['object', 'bool']).columns
            input_df_encoded = pd.get_dummies(input_df, columns=categorical_cols, drop_first=True)
            input_df_processed = input_df_encoded.reindex(columns=feature_columns, fill_value=0)
            final_input = scaler.transform(input_df_processed)
                
            # Prediction
            try:
                prediction = model.predict(final_input)[0]
                probability = model.predict_proba(final_input)[0][1] 

                # Customer 360 Profile
                st.markdown("---")
                with st.container(border=True):
                    st.header("Customer 360° Profile & Result")
                    c1, c2 = st.columns([2,3]) 
                    with c1:
                        st.subheader(f"Profile: {gender.title()}")
                        st.markdown(f"**Contract:** {contract_type.title()}")
                        st.markdown(f"**Internet:** {internet_service.title()}")
                        st.markdown(f"**Tenure:** {tenure_months} months")
                        st.metric(label="Monthly Charge", value=f"${monthly_charges:,.2f}")
                    with c2:
                        st.subheader("Prediction Result")
                        prob_percent = probability * 100
                        if prediction == 1: 
                            st.error(f"🚨 At Risk (Likely to Churn)")
                            st.metric(label="Churn Probability", value=f"{prob_percent:.2f} %", delta_color="inverse")
                        else: 
                            st.success(f"👍 Loyal (Likely to Stay)")
                            st.metric(label="Churn Probability", value=f"{prob_percent:.2f} %", delta_color="normal")
                        
                        # Feature Importance
                        st.subheader("💡 Key Drivers for this Prediction")
                        if hasattr(model, 'feature_importances_'): 
                            importances = model.feature_importances_
                            feature_names = feature_columns
                            imp_df = pd.DataFrame({'feature': feature_names, 'importance': importances})
                            imp_df = imp_df.sort_values('importance', ascending=False).head(3) 
                        elif hasattr(model, 'coef_'): 
                            importances = model.coef_[0]
                            feature_names = feature_columns
                            imp_df = pd.DataFrame({'feature': feature_names, 'importance': np.abs(importances)})
                            imp_df = imp_df.sort_values('importance', ascending=False).head(3)
                        else:
                            imp_df = None

                        if imp_df is not None:
                             fig = px.bar(imp_df, x='importance', y='feature', orientation='h', title="Top 3 Features Influencing Decision")
                             fig.update_layout(yaxis_title=None, xaxis_title=None, title_font_size=14, margin=dict(t=30, b=0, l=0, r=0))
                             st.plotly_chart(fig, use_container_width=True)
                
                st.toast('Prediction complete!', icon='✅')

            except Exception as e:
                st.error(f"An error occurred during prediction: {e}")
                st.toast('Prediction failed!', icon='❌')

# --- TAB 2: BATCH PREDICTION ---
with tab2:
    st.header("Predict for a Batch of Customers")
    st.markdown("Upload a CSV file with customer data to get predictions for all rows.")
    st.markdown("---") 

    # 1. Download Template
    st.subheader("1. Download Template File")
    st.markdown("To avoid errors, download this template CSV file and add your customer data to it.")
    template_columns = [
        'Gender', 'Senior_Citizen', 'Partner', 'Dependents', 'Contract_Type', 
        'Internet_Service_Type', 'Phone_Service', 'Multiple_Lines', 'Tech_Support',
        'Online_Security', 'Online_Backup', 'Device_Protection', 'Streaming_TV', 
        'Streaming_Movies', 'Plan_Price_Tier', 'Payment_Method', 'Paperless_Billing', 
        'Auto_Payment', 'Monthly_Charges', 'Total_Charges', 'Tenure_Months',
        'Internet_Usage_GB', 'Calls_Minutes', 'Customer_Satisfaction_Score'
    ]
    template_df = pd.DataFrame(columns=template_columns)
    
    @st.cache_data
    def convert_template_to_csv(df):
        return df.to_csv(index=False).encode('utf-8')
    template_csv = convert_template_to_csv(template_df)
    
    st.download_button(
        label="📥 Download Template (churn_template.csv)",
        data=template_csv,
        file_name="churn_template.csv",
        mime="text/csv",
    )
    st.markdown("---")

    # 2. Upload File
    st.subheader("2. Upload Your Data File")
    uploaded_file = st.file_uploader("Choose a CSV file", type="csv")
    
    if uploaded_file is not None:
        with st.spinner('Processing batch file... This may take a moment.'):
            try:
                batch_df = pd.read_csv(uploaded_file)
                st.write("Uploaded Data Preview:", batch_df.head())
                df_to_process = batch_df.copy()
                
                # Batch Preprocessing
                for col in numeric_features:
                    if col in df_to_process.columns:
                        df_to_process[col] = pd.to_numeric(df_to_process[col], errors='coerce').astype(float)
                    else:
                        st.warning(f"Warning: Numeric column '{col}' not found in uploaded file.")
                
                categorical_cols = df_to_process.select_dtypes(include=['object', 'bool']).columns
                categorical_cols_exist = [col for col in categorical_cols if col in df_to_process.columns]
                df_encoded = pd.get_dummies(df_to_process, columns=categorical_cols_exist, drop_first=True)
                df_processed = df_encoded.reindex(columns=feature_columns, fill_value=0)
                final_input = scaler.transform(df_processed)
                
                # Batch Prediction
                predictions = model.predict(final_input)
                probabilities = model.predict_proba(final_input)[:, 1]
                
                # Display Results
                st.subheader("Prediction Results")
                result_df = batch_df.copy()
                result_df['Churn_Prediction_Status'] = ['Churn' if pred == 1 else 'Not Churn' for pred in predictions]
                result_df['Churn_Probability_%'] = (probabilities * 100).round(2)
                st.dataframe(result_df)
                
                # Download Button
                @st.cache_data
                def convert_df_to_csv(df):
                    return df.to_csv(index=False).encode('utf-8')
                csv_data = convert_df_to_csv(result_df)
                st.download_button(
                    label="📥 Download Results as CSV",
                    data=csv_data,
                    file_name="churn_predictions_output.csv",
                    mime="text/csv",
                )
                st.toast('Batch processing complete!', icon='✅')
                
            except Exception as e:
                st.error(f"An error occurred during batch processing: {e}")
                st.error("Please ensure your CSV file has the correct columns (use the template!) and valid data types.")
                st.toast('Batch processing failed!', icon='❌')