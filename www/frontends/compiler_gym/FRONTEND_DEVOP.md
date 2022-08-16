# QA V

Run this command to deploy to AWS CloudFront - QA

```shell
DOCKER_BUILDKIT=1 docker \
build \
-f Dockerfile.www \
-t compilergym_www:latest \
--build-arg AWS_S3_WWW_BUCKET=qa-compilergym-www \
--build-arg COMPILER_GYM_API_ENDPOINT=https://compilergym-api.qa.metademolab.com \
--build-arg AWS_CLOUDFRONT_DISTRIBUTION=EMTYFD0BSRER9 \
.
```

# PROD

Run this command to deploy to AWS CloudFront - Prod

```shell
DOCKER_BUILDKIT=1 docker \
build \
-f Dockerfile.www \
-t compilergym_www:latest \
--build-arg AWS_S3_WWW_BUCKET=prod-compilergym-www \
--build-arg COMPILER_GYM_API_ENDPOINT=https://compilergym-api.metademolab.com \
--build-arg AWS_CLOUDFRONT_DISTRIBUTION=E2MSMLWJSOEAL8 \
.
```

DOCKER_BUILDKIT=1 docker \
build \
-f Dockerfile.www \
-t compilergym_www:latest \
--build-arg AWS_S3_WWW_BUCKET=tf-dev-compiler-gym-www \
--build-arg COMPILER_GYM_API_ENDPOINT=https://compilergym-api.qa.metademolab.com \
--build-arg AWS_CLOUDFRONT_DISTRIBUTION=E3KTIK3TRPLXAA \
.

# API Deploy

1. Connect to ECR (from an EC2 instance)

Note: credentials last 12 hours

```
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REGION=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document|jq -r .region)
aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com
```

docker tag nllb-api-prod:latest "$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/qa_compiler_gym_api_repo:latest"
docker push $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/qa_compiler_gym_api_repo:latest
