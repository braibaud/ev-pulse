import streamlit as st

def about():
    st.title("About EV Pulse")
    st.write("""
    EV Pulse is a collaborative project aimed at creating a comprehensive database
    of electric vehicles (EVs) currently available on the market. Our goal is to
    provide a reliable and up-to-date resource for anyone interested in electric
    vehicles, whether you're a potential buyer, researcher, or enthusiast.
    """)
    st.write("""
    This project is open-source and welcomes contributions from the community.
    Together, we can build a robust and accurate database that benefits everyone.
    """)

if __name__ == "__main__":
    about()
