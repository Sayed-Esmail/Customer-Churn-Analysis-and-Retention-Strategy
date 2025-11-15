import streamlit as st
import pandas as pd
import joblib
from sklearn.metrics import accuracy_score, precision_score, recall_score, f1_score, confusion_matrix
from PIL import Image 
from sklearn.model_selection import train_test_split
import seaborn as sns
import matplotlib.pyplot as plt

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

st.title("📈 Model Performance & Business Insights")
st.markdown("This page details the model's performance and allows for interactive tuning.")

# --- File Paths ---
MODEL_PATH = 'Models/churn_prediction_model.pkl'
SCALER_PATH = 'Models/scaler.pkl'
COLUMNS_PATH = 'Models/feature_columns.pkl'
DATA_PATH = 'Data/Processed/churn_ml_dataset.csv'
ROC_PATH = 'Reports/roc_curve.png'
FI_PATH = 'Reports/feature_importance.png'

# --- Caching Functions ---
@st.cache_resource
def load_artifacts_for_eval():
    model = joblib.load(MODEL_PATH)
    scaler = joblib.load(SCALER_PATH)
    feature_columns = joblib.load(COLUMNS_PATH)
    return model, scaler, feature_columns

@st.cache_data
def get_test_data_and_probs(_feature_columns_list, _scaler_obj, _model_obj): 
    df = pd.read_csv(DATA_PATH)
    X = df.drop(['Customer_ID', 'Target'], axis=1)
    y = df['Target']
    
    categorical_cols = X.select_dtypes(include=['object', 'bool']).columns
    X_encoded = pd.get_dummies(X, columns=categorical_cols, drop_first=True)
    X_encoded = X_encoded.reindex(columns=_feature_columns_list, fill_value=0) 

    X_train, X_test, y_train, y_test = train_test_split(
        X_encoded, y, test_size=0.2, random_state=42, stratify=y
    )
    
    X_test_scaled = _scaler_obj.transform(X_test)
    
    # Get probabilities once and cache them
    y_pred_proba = _model_obj.predict_proba(X_test_scaled)[:, 1]
    
    return y_test, y_pred_proba

# --- Dynamic Confusion Matrix Plot Function ---
@st.cache_data # Cache the plot generation
def generate_cm_plot(y_test, y_pred):
    """Generates a Seaborn Confusion Matrix plot."""
    cm = confusion_matrix(y_test, y_pred)
    
    fig, ax = plt.subplots(figsize=(6, 4))
    sns.heatmap(cm, annot=True, fmt='d', cmap='Blues', ax=ax,
                xticklabels=['Not Churn', 'Churn'],
                yticklabels=['Not Churn', 'Churn'])
    ax.set_xlabel('Predicted Label')
    ax.set_ylabel('True Label')
    ax.set_title('Confusion Matrix')
    
    # Calculate percentages for annotation
    tp = cm[1, 1]
    tn = cm[0, 0]
    fp = cm[0, 1]
    fn = cm[1, 0]
    
    # Add custom text
    text = (
        f"True Positives (Found Churn): {tp}\n"
        f"True Negatives (Found Loyal): {tn}\n"
        f"False Positives (Wrongly Flagged): {fp}\n"
        f"False Negatives (Missed Churn): {fn}"
    )
    props = dict(boxstyle='round', facecolor='wheat', alpha=0.5)
    fig.text(1.05, 0.5, text, transform=ax.transAxes, fontsize=10,
             verticalalignment='center', bbox=props)
    
    plt.tight_layout(rect=[0, 0, 0.85, 1]) # Make room for text box
    return fig

# --- Main App Logic ---
try:
    model, scaler, feature_columns = load_artifacts_for_eval()
    y_test, y_pred_proba = get_test_data_and_probs(feature_columns, scaler, model) 

    # --- Interactive Threshold Slider ---
    st.subheader("Business Threshold Simulator")
    st.markdown("""
    Move the slider to see how changing the "prediction threshold" (default is 0.5) 
    impacts which customers are flagged as 'Churn'. This helps balance finding 
    *all* churners (high Recall) vs. being *correct* (high Precision).
    """)
    
    threshold = st.slider(
        "Set Prediction Threshold:", 
        min_value=0.1, 
        max_value=0.9, 
        value=0.5, 
        step=0.05,
        format="%.2f"
    )
    st.markdown("---")

    # 1. Calculate new predictions based on the slider
    y_pred_new = (y_pred_proba >= threshold).astype(int)
    
    # --- UI Tabs ---
    tab1, tab2, tab3 = st.tabs(["📊 Dynamic Metrics", "🖼️ Evaluation Plots", "💡 Business Recommendations"])

    # --- Tab 1: Performance Metrics ---
    with tab1:
        st.header(f"Performance Metrics at {threshold:.2f} Threshold")
        
        acc = accuracy_score(y_test, y_pred_new)
        precision = precision_score(y_test, y_pred_new, zero_division=0)
        recall = recall_score(y_test, y_pred_new, zero_division=0)
        f1 = f1_score(y_test, y_pred_new, zero_division=0)

        col1, col2, col3, col4 = st.columns(4)
        col1.metric("Accuracy", f"{acc:.1%}")
        col2.metric("Precision", f"{precision:.1%}")
        col3.metric("Recall", f"{recall:.1%}")
        col4.metric("F1-Score", f"{f1:.2f}")

        st.info(f"""
        **Analysis at {threshold:.2f} threshold:**
        - **Precision:** When we predict a customer will churn, we are correct **{precision:.1%}** of the time.
        - **Recall:** We are successfully identifying **{recall:.1%}** of all customers who *actually* churned.
        
        **Business Goal:** Move the slider to find a balance. A lower threshold increases **Recall** (catches more churners) 
        but decreases **Precision** (more false alarms).
        """)

    # --- Tab 2: Evaluation Plots ---
    with tab2:
        st.header("Model Evaluation Visuals")
        
        # --- DYNAMIC CONFUSION MATRIX ---
        st.subheader(f"1. Confusion Matrix (at {threshold:.2f} Threshold)")
        st.markdown("This plot updates *live* based on the threshold slider above.")
        # We use a spinner here because plotting can be slow
        with st.spinner("Generating Confusion Matrix..."):
            cm_fig = generate_cm_plot(y_test, y_pred_new)
            st.pyplot(cm_fig)
        st.divider()

        # --- Static Plots (from reports) ---
        try:
            img_roc = Image.open(ROC_PATH)
            img_fi = Image.open(FI_PATH)
            
            st.subheader("2. ROC Curve (Static)")
            st.markdown("This plot shows the model's performance across *all* thresholds. The threshold slider does not affect it.")
            st.image(img_roc, caption="Measures the model's ability to distinguish between classes.", use_container_width=True)
            st.divider()

            st.subheader("3. Feature Importance (Static)")
            st.markdown("The top features the model uses to make its decisions.")
            st.image(img_fi, caption="The top features the model uses to make its decisions.", use_container_width=True)

        except FileNotFoundError as e:
            st.error(f"Report images (ROC, FI) not found. Please run the evaluation script to generate them. Error: {e}")
        except Exception as e:
            st.error(f"An error occurred loading images: {e}")

    # --- Tab 3: Recommendations ---
    with tab3:
        st.header("💡 Actionable Business Recommendations")
        st.markdown("""
        Based on the model's performance and feature importance, we recommend the following:

        1.  **Segment & Target High-Risk Customers:** Use the 'Churn Predictor' to score customers daily. 
            Use the **Threshold Simulator** in 'Tab 1' to decide on a recall-focused threshold (e.g., 0.35) 
            to generate a list for the marketing team.
            
        2.  **Incentivize Long-Term Contracts:** The 'Contract_Type' (month-to-month) is a top driver of churn. 
            Create marketing campaigns to convert monthly subscribers to one- or two-year contracts at a slight discount.
            
        3.  **Improve Key Services:** 'Tech_Support' and 'Online_Security' are often high-importance features. 
            Investing in these areas can improve customer satisfaction and reduce churn organically.
            
        4.  **Monitor Satisfaction:** The 'Customer_Satisfaction_Score' is a direct predictor. 
            Implement an automated follow-up for any customer who gives a score below 5.
        """)

except Exception as e:
    st.error(f"An error occurred loading this page. Did you re-run the training script? Error: {e}")