import streamlit as st
import json
import os

def load_pending_cars():
    pending_cars = []
    pending_folder = "data/pending"
    for filename in os.listdir(pending_folder):
        if filename.endswith(".json"):
            with open(os.path.join(pending_folder, filename), "r") as file:
                pending_cars.append(json.load(file))
    return pending_cars

def load_schema():
    with open("data/schema.json", "r") as file:
        return json.load(file)

def approve_car(car_data):
    data_folder = "data"
    filename = f"{car_data['make']}_{car_data['model']}_{car_data['year']}.json"
    with open(os.path.join(data_folder, filename), "w") as file:
        json.dump(car_data, file, indent=4)
    os.remove(os.path.join("data/pending", f"{filename}"))

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

def review():
    st.title("Review Contributions")

    pending_cars = load_pending_cars()
    schema = load_schema()

    for car in pending_cars:
        display_car(car, schema)

        if st.button("Approve", key=f"{car['make']}_{car['model']}_{car['year']}"):
            approve_car(car)
            st.success("Car data approved!")

if __name__ == "__main__":
    review()
