import streamlit as st
from sqlalchemy.orm import sessionmaker
from sqlalchemy import create_engine
from db.connection import DATABASE_URL
from db.models import Attribute

# Create a database session
engine = create_engine(DATABASE_URL)
Session = sessionmaker(bind=engine)
session = Session()

def create_attribute():
    st.title("Create New Attribute")

    with st.form(key='create_attribute_form'):
        name = st.text_input("Attribute Name", max_chars=100)
        group_name = st.text_input("Group Name", max_chars=100)
        default_unit = st.text_input("Default Unit", max_chars=50)
        is_active = st.checkbox("Is Active", value=True)
        is_inheritable = st.checkbox("Is Inheritable", value=True)
        is_overridable = st.checkbox("Is Overridable", value=True)

        submit_button = st.form_submit_button("Create Attribute")

        if submit_button:
            new_attribute = Attribute(
                name=name,
                group_name=group_name,
                default_unit=default_unit,
                is_active=is_active,
                is_inheritable=is_inheritable,
                is_overridable=is_overridable
            )
            session.add(new_attribute)
            session.commit()
            st.success("Attribute created successfully!")

if __name__ == "__main__":
    create_attribute()