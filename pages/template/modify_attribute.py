import streamlit as st
from sqlalchemy.orm import sessionmaker
from sqlalchemy import create_engine
from db.connection import DATABASE_URL
from db.models import Attribute  # Assuming the model is defined in models.py

# Create a database session
engine = create_engine(DATABASE_URL)
Session = sessionmaker(bind=engine)
session = Session()

def modify_attribute(attribute_id):
    attribute = session.query(Attribute).filter(Attribute.id == attribute_id).first()
    if attribute:
        st.session_state.attribute_id = attribute.id
        st.session_state.name = attribute.name
        st.session_state.group_name = attribute.group_name
        st.session_state.default_unit = attribute.default_unit
        st.session_state.is_active = attribute.is_active
        st.session_state.is_inheritable = attribute.is_inheritable
        st.session_state.is_overridable = attribute.is_overridable

def update_attribute():
    attribute = session.query(Attribute).filter(Attribute.id == st.session_state.attribute_id).first()
    if attribute:
        attribute.name = st.session_state.name
        attribute.group_name = st.session_state.group_name
        attribute.default_unit = st.session_state.default_unit
        attribute.is_active = st.session_state.is_active
        attribute.is_inheritable = st.session_state.is_inheritable
        attribute.is_overridable = st.session_state.is_overridable
        session.commit()
        st.success("Attribute updated successfully!")

st.title("Modify Attribute")

# Select attribute to modify
attribute_id = st.selectbox("Select Attribute", [attr.id for attr in session.query(Attribute).all()])
if st.button("Load Attribute"):
    modify_attribute(attribute_id)

# Form for modifying attribute details
with st.form("modify_attribute_form"):
    st.text_input("Name", value=st.session_state.get("name", ""), key="name")
    st.text_input("Group Name", value=st.session_state.get("group_name", ""), key="group_name")
    st.text_input("Default Unit", value=st.session_state.get("default_unit", ""), key="default_unit")
    st.checkbox("Is Active", value=st.session_state.get("is_active", True), key="is_active")
    st.checkbox("Is Inheritable", value=st.session_state.get("is_inheritable", True), key="is_inheritable")
    st.checkbox("Is Overridable", value=st.session_state.get("is_overridable", True), key="is_overridable")
    
    submitted = st.form_submit_button("Update Attribute")
    if submitted:
        update_attribute()