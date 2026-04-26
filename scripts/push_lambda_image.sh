#!/bin/sh

set -eu

cd "$(dirname "$0")/.."

AWS_REGION=${AWS_REGION:?AWS_REGION is required}
IMAGE_NAME=${IMAGE_NAME:?IMAGE_NAME is required}
IMAGE_TAG=${IMAGE_TAG:?IMAGE_TAG is required}
IMAGE_ARCH=${IMAGE_ARCH:?IMAGE_NAME is required}

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ECR_REGISTRY="$ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com"

aws ecr get-login-password --region "$AWS_REGION" \
	| docker login --username AWS --password-stdin "$ECR_REGISTRY"

docker build \
	-t "$IMAGE_NAME:$IMAGE_TAG" \
	--platform "$IMAGE_ARCH" \
	--sbom=false \
	--provenance=false \
	.

docker tag \
	"$IMAGE_NAME:$IMAGE_TAG" \
	"$ECR_REGISTRY/$IMAGE_NAME:$IMAGE_TAG"

docker push "$ECR_REGISTRY/$IMAGE_NAME:$IMAGE_TAG"
