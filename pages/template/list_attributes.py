import streamlit as st
import pandas as pd
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from db.connection import DATABASE_URL
from db.models import Attribute  # Assuming the model is defined in models.py

# Create a database engine and session
engine = create_engine(DATABASE_URL)
Session = sessionmaker(bind=engine)
session = Session()

def load_attributes():
    return session.query(Attribute).all()

def main():
    st.title("List Attributes")

    # Search and filter options
    search_term = st.text_input("Search by name:")
    attributes = load_attributes()

    if search_term:
        attributes = [attr for attr in attributes if search_term.lower() in attr.name.lower()]

    # Display attributes in a grid
    if attributes:
        df = pd.DataFrame([(attr.id, attr.name, attr.group_id, attr.is_active) for attr in attributes],
                          columns=["ID", "Name", "Group ID", "Is Active"])
        st.dataframe(df)

        # Buttons for actions
        if st.button("Modify Selected"):
            # Logic to modify selected attributes
            st.write("Modify functionality not implemented yet.")

        if st.button("Delete Selected"):
            # Logic to delete selected attributes
            st.write("Delete functionality not implemented yet.")
    else:
        st.write("No attributes found.")

if __name__ == "__main__":
    main()