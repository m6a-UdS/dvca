FRONTEND_SOURCE_TEMPLATE_PATH = cloudformation/frontend.yml
GENERATED_FRONTEND_TEMPLATE_ABSOLUTE_PATH = $(shell pwd)/dist/$(FRONTEND_SOURCE_TEMPLATE_PATH)

BACKEND_SOURCE_TEMPLATE_PATH = cloudformation/backend.yml
GENERATED_BACKEND_TEMPLATE_ABSOLUTE_PATH = $(shell pwd)/dist/$(BACKEND_SOURCE_TEMPLATE_PATH)

package-frontend: export BUCKET_NAME=cf-template-`aws sts get-caller-identity --output text --query 'Account'`-`aws configure get region`
package-frontend:
	aws cloudformation package --template-file $(FRONTEND_SOURCE_TEMPLATE_PATH) --s3-bucket $(BUCKET_NAME) --s3-prefix cloudformation/dvca --output-template-file $(GENERATED_FRONTEND_TEMPLATE_ABSOLUTE_PATH)

deploy-frontend: package-frontend
	aws cloudformation deploy --template-file $(GENERATED_FRONTEND_TEMPLATE_ABSOLUTE_PATH) --stack-name DVCA-Frontend --parameter-overrides DomainName=$(DOMAIN_NAME)
	aws s3 sync static-frontend/ s3://$(DOMAIN_NAME) --exclude "*/.DS_Store"

update-frontend:
	aws s3 sync static-frontend/ s3://$(DOMAIN_NAME) --exclude "*/.DS_Store"

package-backend: export BUCKET_NAME=cf-template-`aws sts get-caller-identity --output text --query 'Account'`-`aws configure get region`
package-backend:
	aws cloudformation package --template-file $(BACKEND_SOURCE_TEMPLATE_PATH) --s3-bucket $(BUCKET_NAME) --s3-prefix cloudformation/dvca --output-template-file $(GENERATED_BACKEND_TEMPLATE_ABSOLUTE_PATH)

deploy-backend: package-backend
	aws cloudformation deploy --template-file $(GENERATED_BACKEND_TEMPLATE_ABSOLUTE_PATH) --stack-name DVCA-Backend --parameter-overrides DomainName=$(DOMAIN_NAME) Certificate=$(CERTIFICATE) HostedZoneId=$(HOSTED_ZONE) --capabilities CAPABILITY_IAM
