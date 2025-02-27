import streamlit as st
from Home import home
from About import about
from SearchListing import search_listing
from Contribute import contribute
from Review import review

def main():
    st.sidebar.title("Navigation")
    page = st.sidebar.radio("Go to", ["Home", "About", "Search Listing", "Contribute", "Review"])

    if page == "Home":
        home()
    elif page == "About":
        about()
    elif page == "Search Listing":
        search_listing()
    elif page == "Contribute":
        contribute()
    elif page == "Review":
        review()

if __name__ == "__main__":
    main()
