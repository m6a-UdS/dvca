import os
import json
from urllib.parse import unquote
from botocore.vendored import requests

def handler(event, context):
    url=unquote(event["body"]).split('=')[1]
    print(f"URL: {url}")
    response_text=requests.get(url).text
    return {
        "statusCode": 200,
        "body": json.dumps(
            {
                "content": response_text
            }
        ),
        "headers": {
            "Access-Control-Allow-Methods":
                "OPTIONS,POST",
            "Access-Control-Allow-Origin": os.environ["CORS"]
        }
    }
