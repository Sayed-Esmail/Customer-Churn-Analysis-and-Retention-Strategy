import streamlit as st
import pandas as pd
import plotly.express as px

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

# --- Page configuration ---
st.set_page_config(layout="wide")

load_css()

st.title("📊 Exploratory Data Analysis (EDA) Dashboard")

DATA_PATH = 'Data/Processed/churn_ml_dataset.csv'

# Load data
@st.cache_data
def load_data():
    try:
        df = pd.read_csv(DATA_PATH)
        if 'Target' in df.columns:
            df['Target_Status'] = df['Target'].apply(lambda x: 'Churn' if x == 1 or x == True else 'Not Churn')
        else:
            st.error("Column 'Target' not found in the dataset.")
            return pd.DataFrame()
        return df
    except FileNotFoundError:
        st.error(f"Data file not found at: {DATA_PATH}")
        return pd.DataFrame()

df = load_data()

if not df.empty:
    # --- KPIs ---
    st.header("📈 Key Performance Indicators (KPIs)")
    total_customers = df.shape[0]
    total_churn = df[(df['Target'] == 1) | (df['Target'] == True)].shape[0]
    churn_rate = (total_churn / total_customers) * 100
    avg_tenure = df['Tenure_Months'].mean()

    col1, col2, col3 = st.columns(3)
    col1.metric("Total Customers", f"{total_customers}")
    col2.metric("Churn Rate", f"{churn_rate:.1f} %", delta=f"{churn_rate:.1f}%", delta_color="inverse")
    col3.metric("Average Tenure (Months)", f"{avg_tenure:.0f}")

    st.divider()
    
    # --- Interactive Plots ---
    st.header("🔍 Feature Analysis vs. Churn")
    
    col1, col2 = st.columns(2)

    with col1:
        with st.container(border=True):
            st.subheader("Categorical Feature Analysis")
            categorical_features = df.select_dtypes(include=['object', 'bool']).columns
            features_to_exclude = ['Customer_ID']
            categorical_features = [col for col in categorical_features if col not in features_to_exclude]
            
            cat_feature = st.selectbox(
                "Select Categorical Feature:",
                options=categorical_features,
                key='cat'
            )
            
            fig1 = px.density_heatmap(
                df, 
                x=cat_feature, 
                y='Target_Status',
                title=f"Churn Distribution by {cat_feature}",
                color_continuous_scale='Reds'
            )
            st.plotly_chart(fig1, use_container_width=True)

    with col2:
        with st.container(border=True):
            st.subheader("Numerical Feature Analysis")
            numerical_features = df.select_dtypes(include=['int64', 'float64']).columns
            numerical_features = numerical_features.drop(['Target'], errors='ignore')

            num_feature = st.selectbox(
                "Select Numerical Feature:",
                options=numerical_features,
                key='num'
            )

            hist_fig = px.histogram(
                df, 
                x=num_feature, 
                color='Target_Status',
                marginal='box',
                barmode='overlay',
                title=f"Distribution of {num_feature} by Churn",
                color_discrete_map={'Churn': '#E74C3C', 'Not Churn': '#2ECC71'}
            )
            st.plotly_chart(hist_fig, use_container_width=True)