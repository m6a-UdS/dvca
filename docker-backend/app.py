import os
import json
import boto3
import pprint
from urllib.parse import unquote
from urllib.request import urlopen
from os import listdir
from flask import Flask
from flask import request
from flask_cors import CORS

app = Flask(__name__)
cors = CORS(app, resources={r"/*": {"origins": "*"}})

@app.route('/', methods=['GET'])
def health():
    return json.dumps({"STATUS":"HEALTHY"})

@app.route('/test-hook', methods=['POST'])
def ssrf():
    url=request.form['handler']
    response_text = urlopen(url).read().decode("utf-8", "backslashreplace")
    return json.dumps({"content":response_text})

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=80, debug=True)
