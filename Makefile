AWS_REGION ?= eu-west-1
IMAGE_NAME ?= rss-monitor
IMAGE_TAG ?= latest
IMAGE_ARCH ?= linux/arm64

.PHONY: check format typecheck terraform-fmt terraform-validate terraform-init terraform-apply docker-push clean

check: format typecheck terraform-fmt terraform-validate

format:
	uv run ruff format src

typecheck:
	uv run ty check src

terraform-fmt:
	terraform -chdir=deploy fmt -recursive

terraform-validate:
	terraform -chdir=deploy init -backend=false
	terraform -chdir=deploy validate

terraform-init:
	terraform -chdir=deploy init -backend-config=s3.tfbackend -var-file=secrets.tfvars

terraform-apply:
	terraform -chdir=deploy apply -var-file=secrets.tfvars

docker-push:
	AWS_REGION=$(AWS_REGION) \
	IMAGE_NAME=$(IMAGE_NAME) \
	IMAGE_TAG=$(IMAGE_TAG) \
	IMAGE_ARCH=$(IMAGE_ARCH) \
	./scripts/push_lambda_image.sh

clean:
	rm -rf build deploy/.terraform
