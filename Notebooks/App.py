import streamlit as st
import pandas as pd
import joblib
import matplotlib.pyplot as plt
import seaborn as sns
import io
import xlsxwriter
from sklearn.preprocessing import StandardScaler

model = joblib.load(r"Models\churn_prediction_model.pkl")
scaler = joblib.load(r"Models\scaler.pkl")
feature_columns = joblib.load(r"Models\feature_columns.pkl")

st.set_page_config(page_title="Customer Churn Prediction", page_icon="📊")
st.title("📊 Customer Churn Prediction App")
st.markdown("Predict customer churn risk and analyze bulk customer data.")

def safe_one_hot(input_dict, field_name, value, valid_features):
    col = f"{field_name}_{value}"
    if col in valid_features:
        input_dict[col] = 1

st.sidebar.header("Customer Features")

customer_age = st.sidebar.slider("Customer Age", 18, 90, 35)
country = st.sidebar.selectbox("Country", ["Canada", "France", "Germany", "United Kingdom", "United States", "n/a"])
marital_status = st.sidebar.selectbox("Marital Status", ["Married", "Single"])
gender = st.sidebar.selectbox("Gender", ["Male", "Female", "n/a"])
maintenance = st.sidebar.selectbox("Maintenance Included?", ["Yes", "No"])
category = st.sidebar.selectbox("Category", ["Bikes", "Clothing", "Other"])
subcategory = st.sidebar.text_input("Subcategory (Optional)")
order_month = st.sidebar.selectbox("Order Month", list(range(1, 13)))
order_dayofweek = st.sidebar.selectbox("Order Day of Week (0=Monday)", list(range(0, 7)))
quantity = st.sidebar.number_input("Quantity", min_value=1, value=1)
price = st.sidebar.number_input("Price", min_value=0.0, value=0.0)
cost = st.sidebar.number_input("Cost", min_value=0.0, value=0.0)

input_dict = dict.fromkeys(feature_columns, 0)
input_dict.update({
    "customer_age": customer_age,
    "order_month": order_month,
    "order_dayofweek": order_dayofweek,
    "quantity": quantity,
    "price": price,
    "cost": cost
})
safe_one_hot(input_dict, "country", country, feature_columns)
safe_one_hot(input_dict, "gender", gender, feature_columns)
safe_one_hot(input_dict, "marital_status", marital_status, feature_columns)
safe_one_hot(input_dict, "maintenance", maintenance, feature_columns)
safe_one_hot(input_dict, "category", category, feature_columns)
if subcategory:
    safe_one_hot(input_dict, "subcategory", subcategory, feature_columns)

input_df = pd.DataFrame([input_dict])
st.subheader("🧾 Input Preview")
st.write(input_df)

if st.button("🔮 Predict Churn"):
    try:
        input_scaled = scaler.transform(input_df)
        prediction = model.predict(input_scaled)[0]
        proba = model.predict_proba(input_scaled)[0][1]
        st.success(f"Customer Churn Risk: {'Yes' if prediction==1 else 'No'} ({proba:.2%})")
    except Exception as e:
        st.error(f"Prediction error: {e}")

st.markdown("## 📄 Download Excel Template")
output_template = io.BytesIO()
with pd.ExcelWriter(output_template, engine='xlsxwriter') as writer:
    workbook = writer.book
    worksheet = workbook.add_worksheet("churn_input_template")
    writer.sheets["churn_input_template"] = worksheet

    headers = ["customer_age","order_month","order_dayofweek","quantity","price","cost",
               "country","gender","marital_status","maintenance","category","subcategory"]
    for col_num, header in enumerate(headers):
        worksheet.write(0, col_num, header)

st.download_button(
    label="📃 Download Template",
    data=output_template.getvalue(),
    file_name="churn_input_template.xlsx",
    mime="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
)

st.markdown("## 📄 Bulk Prediction Upload")
uploaded_file = st.file_uploader("Upload CSV or Excel:", type=["csv", "xlsx"])

if uploaded_file:
    try:
        if uploaded_file.name.endswith(".csv"):
            raw_df = pd.read_csv(uploaded_file)
        else:
            raw_df = pd.read_excel(uploaded_file)

        encoded_df = pd.get_dummies(raw_df)
        for col in feature_columns:
            if col not in encoded_df.columns:
                encoded_df[col] = 0
        encoded_df = encoded_df[feature_columns]

        encoded_scaled = scaler.transform(encoded_df)
        encoded_df['Churn_Prediction'] = model.predict(encoded_scaled)
        encoded_df['Churn_Probability'] = model.predict_proba(encoded_scaled)[:,1]

        st.success("✅ Bulk predictions complete")
        st.dataframe(encoded_df.head(10))

        out = io.BytesIO()
        with pd.ExcelWriter(out, engine="xlsxwriter") as writer:
            encoded_df.to_excel(writer, index=False)
        st.download_button("Download Results", out.getvalue(), "churn_predictions.xlsx")
    except Exception as e:
        st.error(f"Error processing file: {e}")

st.markdown("---")
st.markdown("<center>Created by Sayed Esmail | Customer Churn Prediction</center>", unsafe_allow_html=True)
