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
