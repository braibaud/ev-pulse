import streamlit as st
import json
import os

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

def display_car(car, schema):
    for key, value in schema['properties'].items():
        if key in car:
            if value['type'] == "array":
                st.write(f"**{key.capitalize()}:**")
                for item in car[key]:
                    st.write(f"- {item}")
            elif value['type'] == "object":
                st.write(f"**{key.capitalize()}:**")
                for sub_key, sub_value in car[key].items():
                    st.write(f"  - {sub_key.capitalize()}: {sub_value}")
            else:
                st.write(f"**{key.capitalize()}:** {car[key]}")
    st.write("---")

def search_listing():
    st.title("Search Electric Vehicles")

    cars = load_cars()
    schema = load_schema()

    search_term = st.text_input("Enter search term (make, model, etc.)")
    filtered_cars = [car for car in cars if search_term.lower() in car["make"].lower() or search_term.lower() in car["model"].lower()]

    for car in filtered_cars:
        display_car(car, schema)

if __name__ == "__main__":
    search_listing()
