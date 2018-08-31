NETWORK_SOURCE_TEMPLATE_PATH = cloudformation/prerequisites/network/network.yml
GENERATED_NETWORK_TEMPLATE_ABSOLUTE_PATH = $(shell pwd)/dist/$(NETWORK_SOURCE_TEMPLATE_PATH)

ECS_SOURCE_TEMPLATE_PATH = cloudformation/prerequisites/ecs-cluster/ecs-cluster.yml
GENERATED_ECS_TEMPLATE_ABSOLUTE_PATH = $(shell pwd)/dist/$(ECS_SOURCE_TEMPLATE_PATH)

FRONTEND_SOURCE_TEMPLATE_PATH = cloudformation/frontend/frontend.yml
GENERATED_FRONTEND_TEMPLATE_ABSOLUTE_PATH = $(shell pwd)/dist/$(FRONTEND_SOURCE_TEMPLATE_PATH)

SERVERLESS_SOURCE_TEMPLATE_PATH = cloudformation/serverless-backend/serverless-backend.yml
GENERATED_SERVERLESS_TEMPLATE_ABSOLUTE_PATH = $(shell pwd)/dist/$(SERVERLESS_SOURCE_TEMPLATE_PATH)

FARGATE_SOURCE_TEMPLATE_PATH = cloudformation/fargate-backend/fargate-backend.yml
GENERATED_FARGATE_TEMPLATE_ABSOLUTE_PATH = $(shell pwd)/dist/$(FARGATE_SOURCE_TEMPLATE_PATH)

EC2_SOURCE_TEMPLATE_PATH = cloudformation/ec2-backend/ec2-backend.yml
GENERATED_EC2_TEMPLATE_ABSOLUTE_PATH = $(shell pwd)/dist/$(EC2_SOURCE_TEMPLATE_PATH)

package-network: export BUCKET_NAME=cf-template-`aws sts get-caller-identity --output text --query 'Account'`-`aws configure get region`
package-network:
	aws cloudformation package --template-file $(NETWORK_SOURCE_TEMPLATE_PATH) --s3-bucket $(BUCKET_NAME) --s3-prefix cloudformation/dvca --output-template-file $(GENERATED_NETWORK_TEMPLATE_ABSOLUTE_PATH)

package-ecs: export BUCKET_NAME=cf-template-`aws sts get-caller-identity --output text --query 'Account'`-`aws configure get region`
package-ecs:
	aws cloudformation package --template-file $(ECS_SOURCE_TEMPLATE_PATH) --s3-bucket $(BUCKET_NAME) --s3-prefix cloudformation/dvca --output-template-file $(GENERATED_ECS_TEMPLATE_ABSOLUTE_PATH)

package-frontend: export BUCKET_NAME=cf-template-`aws sts get-caller-identity --output text --query 'Account'`-`aws configure get region`
package-frontend:
	aws cloudformation package --template-file $(FRONTEND_SOURCE_TEMPLATE_PATH) --s3-bucket $(BUCKET_NAME) --s3-prefix cloudformation/dvca --output-template-file $(GENERATED_FRONTEND_TEMPLATE_ABSOLUTE_PATH)

package-serverless: export BUCKET_NAME=cf-template-`aws sts get-caller-identity --output text --query 'Account'`-`aws configure get region`
package-serverless:
	aws cloudformation package --template-file $(SERVERLESS_SOURCE_TEMPLATE_PATH) --s3-bucket $(BUCKET_NAME) --s3-prefix cloudformation/dvca --output-template-file $(GENERATED_SERVERLESS_TEMPLATE_ABSOLUTE_PATH)

package-fargate: export BUCKET_NAME=cf-template-`aws sts get-caller-identity --output text --query 'Account'`-`aws configure get region`
package-fargate:
	aws cloudformation package --template-file $(FARGATE_SOURCE_TEMPLATE_PATH) --s3-bucket $(BUCKET_NAME) --s3-prefix cloudformation/dvca --output-template-file $(GENERATED_FARGATE_TEMPLATE_ABSOLUTE_PATH)

package-ec2: export BUCKET_NAME=cf-template-`aws sts get-caller-identity --output text --query 'Account'`-`aws configure get region`
package-ec2:
	aws cloudformation package --template-file $(EC2_SOURCE_TEMPLATE_PATH) --s3-bucket $(BUCKET_NAME) --s3-prefix cloudformation/dvca --output-template-file $(GENERATED_EC2_TEMPLATE_ABSOLUTE_PATH)

network: package-network
	aws cloudformation deploy --template-file $(GENERATED_NETWORK_TEMPLATE_ABSOLUTE_PATH) --stack-name DVCA-Network --parameter-overrides DomainName=$(DOMAIN_NAME) Certificate=$(CERTIFICATE) HostedZoneId=$(HOSTED_ZONE) --capabilities CAPABILITY_IAM

ecs: package-ecs
	aws cloudformation deploy --template-file $(GENERATED_ECS_TEMPLATE_ABSOLUTE_PATH) --stack-name DVCA-Ecs --capabilities CAPABILITY_IAM

frontend: package-frontend
	aws cloudformation deploy --template-file $(GENERATED_FRONTEND_TEMPLATE_ABSOLUTE_PATH) --stack-name DVCA-Frontend --parameter-overrides DomainName=$(DOMAIN_NAME) Certificate=$(ROOT_CERTIFICATE) HostedZoneId=$(HOSTED_ZONE)
	aws s3 sync static-frontend/ s3://$(DOMAIN_NAME) --exclude "*/.DS_Store"

serverless: package-serverless
	aws cloudformation deploy --template-file $(GENERATED_SERVERLESS_TEMPLATE_ABSOLUTE_PATH) --stack-name DVCA-Serverless-Backend --parameter-overrides DomainName=$(DOMAIN_NAME) Certificate=$(CERTIFICATE) HostedZoneId=$(HOSTED_ZONE) --capabilities CAPABILITY_IAM

fargate: package-fargate
	aws cloudformation deploy --template-file $(GENERATED_FARGATE_TEMPLATE_ABSOLUTE_PATH) --stack-name DVCA-Fargate-Backend --parameter-overrides DomainName=$(DOMAIN_NAME) Certificate=$(CERTIFICATE) HostedZoneId=$(HOSTED_ZONE) --capabilities CAPABILITY_IAM

ec2: package-ec2
	aws cloudformation deploy --template-file $(GENERATED_EC2_TEMPLATE_ABSOLUTE_PATH) --stack-name DVCA-Ec2-Backend --parameter-overrides DomainName=$(DOMAIN_NAME) Certificate=$(CERTIFICATE) HostedZoneId=$(HOSTED_ZONE) --capabilities CAPABILITY_IAM

update-frontend:
	aws s3 sync static-frontend/ s3://$(DOMAIN_NAME) --exclude "*/.DS_Store"

build-and-push-container:
	cd docker-backend && docker build -t dvca-fargate-backend .
	docker tag dvca-fargate-backend:latest $(shell aws sts get-caller-identity --output text --query 'Account').dkr.ecr.$(shell aws configure get region).amazonaws.com/dvca-fargate-backend:latest
	$(shell aws ecr get-login --no-include-email --region us-east-1) && docker push $(shell aws sts get-caller-identity --output text --query 'Account').dkr.ecr.$(shell aws configure get region).amazonaws.com/dvca-fargate-backend:latest

docker: ecs build-and-push-container

prerequisites: network docker

all: prerequisites frontend serverless fargate ec2
