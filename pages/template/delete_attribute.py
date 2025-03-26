import streamlit as st
from sqlalchemy.orm import sessionmaker
from sqlalchemy import create_engine
from db.connection import DATABASE_URL
from db.models import Attribute

# Create a database session
engine = create_engine(DATABASE_URL)
Session = sessionmaker(bind=engine)
session = Session()

st.title("Delete Attribute")

# Fetch all attributes from the database
attributes = session.query(Attribute).all()

# Create a list to hold selected attribute IDs for deletion
selected_ids = []

if attributes:
    st.write("Select attributes to delete:")
    for attribute in attributes:
        if st.checkbox(f"{attribute.name} (ID: {attribute.id})"):
            selected_ids.append(attribute.id)

    if st.button("Delete Selected Attributes"):
        if selected_ids:
            for attr_id in selected_ids:
                attribute_to_delete = session.query(Attribute).filter(Attribute.id == attr_id).first()
                if attribute_to_delete:
                    session.delete(attribute_to_delete)
            session.commit()
            st.success("Selected attributes deleted successfully.")
        else:
            st.warning("No attributes selected for deletion.")
else:
    st.info("No attributes available to delete.")