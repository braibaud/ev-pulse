import json
import jsonschema
from jsonschema import validate

def test_car_schema():
    schema = json.load(open("data/schema.json"))
    sample_car = json.load(open("data/sample_car_1.json"))

    validate(instance=sample_car, schema=schema)

if __name__ == "__main__":
    test_car_schema()
    print("All tests passed.")
