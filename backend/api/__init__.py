import re


def extract_uuid(input_string):
    # UUID pattern
    uuid_pattern = r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}'

    # Search for the UUID pattern at the beginning of the string
    match = re.match(uuid_pattern, input_string)

    # Extract and return the UUID if found
    if match:
        return match
    else:
        return None