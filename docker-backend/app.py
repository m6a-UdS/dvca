import os
import json
import boto3
import pprint
from urllib.parse import unquote
from urllib.request import urlopen
from os import listdir
from flask import Flask
from flask import request

app = Flask(__name__)

@app.route('/', methods=['GET', 'POST'])
def ssrf():
    if request.method == "GET":
        return json.dumps({"STATUS":"HEALTHY"})
    else:
        url=request.form['handler']
        response_text = urlopen(url).read().decode("utf-8", "backslashreplace")
        return json.dumps(
                {
                    "content": response_text
                })

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=80, debug=True)
