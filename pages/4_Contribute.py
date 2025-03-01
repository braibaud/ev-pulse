import streamlit as st
import json
import os
from jsonschema import validate, ValidationError

def load_schema():
    with open("data/schema.json", "r") as file:
        return json.load(file)

def save_car(car_data, is_edit=False):
    schema = load_schema()
    try:
        validate(instance=car_data, schema=schema)
        data_folder = "data/pending" if not is_edit else "data"
        os.makedirs(data_folder, exist_ok=True)
        filename = f"{car_data['make']}_{car_data['model']}_{car_data['year']}.json"
        with open(os.path.join(data_folder, filename), "w") as file:
            json.dump(car_data, file, indent=4)
        st.success("Thank you for your contribution! It's pending review." if not is_edit else "Car data updated successfully!")
    except ValidationError as e:
        st.error(f"Validation error: {e.message}")

def contribute():
    st.title("Contribute to EV Pulse")

    st.write("Help us build the database by adding new electric vehicles.")

    schema = load_schema()
    car_data = {}

    # Check if editing an existing car
    if "edit_car" in st.session_state:
        car_data = st.session_state.edit_car
        st.write("Editing existing vehicle. Changes are subject to review.")

    with st.form("contribute_form"):
        for key, value in schema['properties'].items():
            if value['type'] == "string":
                car_data[key] = st.text_input(key.capitalize(), car_data.get(key, ""))
            elif value['type'] == "integer":
                car_data[key] = st.number_input(key.capitalize(), min_value=1886, max_value=2100, step=1, value=car_data.get(key, 0))
            elif value['type'] == "number":
                car_data[key] = st.number_input(key.capitalize(), format="%.2f", value=car_data.get(key, 0.0))
            elif value['type'] == "array":
                car_data[key] = st.text_area(key.capitalize(), value=",".join(car_data.get(key, []))).split(",")
            elif value['type'] == "object":
                for sub_key, sub_value in value['properties'].items():
                    car_data.setdefault(key, {})[sub_key] = st.number_input(f"{key.capitalize()} - {sub_key.capitalize()}", format="%.2f", value=car_data.get(key, {}).get(sub_key, 0.0))

        submit_button = st.form_submit_button("Submit" if "edit_car" not in st.session_state else "Update")

        if submit_button:
            save_car(car_data, is_edit="edit_car" in st.session_state)
            if "edit_car" in st.session_state:
                del st.session_state.edit_car

if __name__ == "__main__":
    contribute()
