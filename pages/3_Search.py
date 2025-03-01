import streamlit as st
import json
import os
import pandas as pd

def load_cars():
    cars = []
    data_folder = "data"
    for filename in os.listdir(data_folder):
        if filename.endswith(".json") and filename != "schema.json":
            with open(os.path.join(data_folder, filename), "r") as file:
                cars.append(json.load(file))
    return cars

def load_schema():
    with open("data/schema.json", "r") as file:
        return json.load(file)

def delete_cars(selected_indices):
    cars = load_cars()
    for index in sorted(selected_indices, reverse=True):
        car = cars[index]
        filename = f"{car['make']}_{car['model']}_{car['year']}.json"
        os.remove(os.path.join("data", filename))
    st.success("Selected vehicles deleted successfully.")

def search_listing():
    st.title("Search Electric Vehicles")

    cars = load_cars()
    schema = load_schema()

    # Filtering options
    st.sidebar.header("Filter Options")
    filters = {}
    for key, value in schema['properties'].items():
        if value['type'] == "string":
            filters[key] = st.sidebar.text_input(f"Filter by {key}", "")
        elif value['type'] == "integer" or value['type'] == "number":
            filters[key] = st.sidebar.number_input(f"Filter by {key}", format="%.2f" if value['type'] == "number" else "%d")

    # Apply filters
    filtered_cars = cars
    for key, value in filters.items():
        if value:
            filtered_cars = [car for car in filtered_cars if car.get(key) == value]

    # Display results in a grid
    if filtered_cars:
        df = pd.DataFrame(filtered_cars)
        edited_df = st.data_editor(df, hide_index=True, column_config={"actions": st.column_config.CheckboxColumn(required=True)}, disabled=df.columns)

        if "actions" in edited_df.columns:
            selected_indices = edited_df.index[edited_df["actions"]].tolist()

            if st.button("Delete Selected"):
                delete_cars(selected_indices)

            if len(selected_indices) == 1:
                if st.button("Edit Selected"):
                    st.session_state.edit_car = filtered_cars[selected_indices[0]]
                    st.experimental_set_query_params(page="Contribute")
    else:
        st.write("No vehicles found.")

if __name__ == "__main__":
    search_listing()
