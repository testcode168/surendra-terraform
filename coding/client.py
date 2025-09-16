import json
import requests
import sys
from pathlib import Path

Json_file = Path("example.json")
SERVICE_URL = "https://example.com"
def load_json(file_path: str)
    try:
        with open(file_path, 'r') as f:
            data = json_load(f)
        return data except json.JSON