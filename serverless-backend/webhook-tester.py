import os
import json
import boto3
import pprint
from urllib.parse import unquote
from urllib.request import urlopen
from os import listdir
# from botocore.vendored import requests

def handler(event, context):
    url=unquote(event["body"]).split('&')[0].split('=')[1]
    print(f"URL: {url}")

    client=boto3.client('sts')
    response_text = urlopen(url).read().decode("utf-8", "backslashreplace")

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
            "Access-Control-Allow-Origin": os.environ["CORS"],
            "Content-Type": "text/plain"
        }
    }
