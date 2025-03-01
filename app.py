import streamlit as st

if "logged_in" not in st.session_state:
    st.session_state.logged_in = False


def login():
    if st.button("Log in"):
        st.session_state.logged_in = True
        st.rerun()


def logout():
    if st.button("Log out"):
        st.session_state.logged_in = False
        st.rerun()


login_page = st.Page(
    login,
    title="Log in",
    icon=":material/login:")

logout_page = st.Page(
    logout,
    title="Log out",
    icon=":material/logout:")

home_page = st.Page(
    "pages/1_Home.py",
    title="Home",
    icon=":material/notification_important:",
    default=True)

about_page = st.Page(
    "pages/2_About.py",
    title="About",
    icon=":material/history:")

search_page = st.Page(
    "pages/3_Search.py",
    title="Search",
    icon=":material/search:")

contribute_page = st.Page(
    "pages/4_Contribute.py",
    title="Contribute",
    icon=":material/add_circle:")

review_page = st.Page(
    "pages/5_Review.py",
    title="Review",
    icon=":material/check_circle:")

if st.session_state.logged_in:
    pg = st.navigation(
        {
            "Account": [logout_page],
            "Search": [about_page, search_page],
            "Tools": [contribute_page, review_page],
        }
    )
else:
    pg = st.navigation([login_page])

pg.run()
