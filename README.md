# AWS Damn Vulnerable Cloud Application
This is a demonstration project to show how to do privilege escalation on AWS. DO NOT deploy this on an AWS account unless you know very well what you are doing!

## Prerequisites
- A domain name managed by AWS
- The ACM Certificate ID associated to this domain
- The Hosted Zone ID associated to this domain

## Deployment
```
make deploy-frontend DOMAIN_NAME=<your_aws_managed_domain_name>
make deploy-backend DOMAIN_NAME=<your_aws_managed_domain_name> \
  CERTIFICATE=<your_acm_certificate_id> \
  HOSTED_ZONE=<your_hosted_zone_id>
```
