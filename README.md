# Deploy Laravel on AWS ECS Fargate

## Key Resources & Features

| Name | Description | Required | Status |
|------|-------------|:--------:|------|
| `aws_vpc` | We create a separate Virtual Private Cloud network for each new Laravel stack (e.g. production vs staging) | yes | DONE |
| `aws_subnet` | We always setup our VPC both with private and public subnets. Private subnets can't be accessible from the internet, which is great for the database | yes | DONE |
| Multi-AZ | By default, Fargate tasks are spread across Availability Zones. So we just need to bump the number of instances for our Fargate tasks | no | DONE |
| `aws_route_table` | Required for traffic to flow in and out of our subnets | yes | DONE |
| `aws_nat_gateway` | Required for instances in private subnets to egress to the internet | no | DONE |
| `aws_ecs_cluster` |  We need one cluster for each of our Laravel web frontend, workers and crons | yes | DONE |
| `aws_ecs_service` |  We need one service for each of our Laravel web frontend, workers and crons | yes | DONE |
| `aws_ecs_task_definition` |  We need one task definition for each of our Laravel web frontend, workers and crons | yes | DONE |
| `aws_ecr_repository` | We will build our Laravel project as a Docker image, which will be stored in a new Docker repository | yes | DONE |
| `aws_iam_role` |  Roles needed for our compute instances to access various resources, such as S3 or ECR | yes | DONE |
| `aws_rds_cluster` |  Our MySQL database | yes | DONE |
| Auto-Scaling |  The ability for our clusters and services to automatically instantiate more Laravel frontend (or workers) based on CPU usage | no | DONE for frontend |
| `Dockerfile` |  Our PHP FPM configuration | yes | DONE |
| `Dockerfile-nginx` |  Our reverse proxy configuration | yes | DONE |
| `aws_elasticache_cluster` | Our Redis cluster for caching | no | DONE |
| `aws_elasticsearch_domain` | Our managed ElasticSearch instance | no | DONE |
| `aws_sqs_queue` | Our Laravel queue | no | DONE |
| `aws_ssm_parameter` | Third party secrets in a managed vault | no | DONE |
| `aws_cloudwatch_dashboard` | Cloudwatch dashboard | no | TODO |
| `aws_s3_bucket` | Example S3 bucket for the File driver | no | DONE |
| `aws_cloudfront_distribution` | A CloudFront distribution | no | Coming soon... |

## 1. Create an IAM User for Terraform in the AWS console
...with Programmatic Access only and with the following permissions:

- `arn:aws:iam::aws:policy/AmazonS3FullAccess`
- `arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess`
- `arn:aws:iam::aws:policy/IAMFullAccess`
- `arn:aws:iam::aws:policy/AmazonRoute53FullAccess`
- `arn:aws:iam::aws:policy/AWSCertificateManagerFullAccess`
- `arn:aws:iam::aws:policy/AmazonRDSFullAccess`
- `arn:aws:iam::aws:policy/AmazonEC2FullAccess`
- `arn:aws:iam::aws:policy/AmazonECS_FullAccess`
- `arn:aws:iam::aws:policy/CloudWatchFullAccess`
- `arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess`

## 2. Save new access keys as an AWS CLI profile
```
export PROJECT_NAME=your_project_name_here

aws --profile $PROJECT_NAME configure
```

Save the below function into your terminal to easily load an AWS profile in a terminal instance (optional):
```
awsprofile() { export AWS_ACCESS_KEY_ID=$(aws --profile $1 configure get aws_access_key_id) && export AWS_SECRET_ACCESS_KEY=$(aws --profile $1 configure get aws_secret_access_key); }

awsprofile $PROJECT_NAME
```

## 3. Create your infrastructure using Terraform

### Create and configure an S3 bucket as Terraform backend
You can use any naming norm for your S3 bucket, as long as you update the backend bucket name configuration in `providers.tf` accordingly.

```
export BUCKET_NAME=$PROJECT_NAME-$(date '+%Y%m%d%H%M%S')

aws s3 mb s3://$BUCKET_NAME

aws s3api put-bucket-encryption --bucket $BUCKET_NAME --server-side-encryption-configuration '{ "Rules": [ { "ApplyServerSideEncryptionByDefault": { "SSEAlgorithm": "AES256" } } ] }'

aws s3api put-public-access-block --bucket $BUCKET_NAME --public-access-block-configuration BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true

aws s3api put-bucket-versioning --bucket $BUCKET_NAME --versioning-configuration MFADelete=Disabled,Status=Enabled
```

### Create a DynamoDB database for Terraform state locking
```
aws dynamodb create-table --region us-east-1 --table-name terraform_locks --attribute-definitions AttributeName=LockID,AttributeType=S --key-schema AttributeName=LockID,KeyType=HASH --provisioned-throughput ReadCapacityUnits=1,WriteCapacityUnits=1
```

### Terraform apply
Copy the terraform folder at the root of your Laravel project.

```
cd terraform

export TF_VAR_project_name=$PROJECT_NAME

terraform init -backend-config="bucket=$BUCKET_NAME"

terraform apply
```

Retrieve your ALB URL:
```
terraform output -json | jq '.ecs.value.ecs_alb_hostname' | tr -d '"'
```

This Terraform configuration expects that your domain's DNS records are managed through a hosted zone on Route53.
If that is not the case, you will need to validate the SSL certificates by creating a DNS record with your external DNS service provider.
You will have to first create the ACM resources, before applying the whole stack:

```
terraform apply -target="module.acm"

terraform output -json | jq '.acm.value'

// Create the appropriate record of the given type, with the given name and value

// Wait for the certificate to be successfully issued
aws acm wait certificate-validated --certificate-arn $(terraform output -json | jq '.acm.value.certificate_arn' | tr -d '"')

// Then build the rest of the stack
terraform apply
```

### Build and deploy your Docker images manually (optional - only if you don't use a CD pipeline)

```
aws ecr get-login-password --region $(terraform output region | tr -d '"') | docker login --username AWS --password-stdin $(terraform output account_id | tr -d '"').dkr.ecr.$(terraform output region | tr -d '"').amazonaws.com

docker pull li0nel/laravel-test && docker tag li0nel/laravel-test $(terraform output -json | jq '.ecr.value.laravel_repository_uri' | tr -d '"') && docker push $(terraform output -json | jq '.ecr.value.laravel_repository_uri' | tr -d '"')

docker pull li0nel/nginx && docker tag li0nel/nginx $(terraform output -json | jq '.ecr.value.nginx_repository_uri' | tr -d '"') && docker push $(terraform output -json | jq '.ecr.value.nginx_repository_uri' | tr -d '"')
```

### SSH tunnelling into the database through the EC2 bastion (optional - only to access the database manually)

Coming soon: replace with [VPN setup](https://aws.amazon.com/blogs/networking-and-content-delivery/introducing-aws-client-vpn-to-securely-access-aws-and-on-premises-resources/) + [AWS System Manager Session Manager](https://aws.amazon.com/blogs/aws/new-port-forwarding-using-aws-system-manager-sessions-manager/)

```
ssh ubuntu@$(terraform output -json | jq '.ec2_ip' | tr -d '"') -i $(terraform output -json | jq '.ssh_key_path' | tr -d '"')
```

or for a SSH tunnel on MySQL:
```
ssh ubuntu@$(terraform output -json | jq '.ec2_ip' | tr -d '"') -i $(terraform output -json | jq '.ssh_key_path' | tr -d '"') -L 3306:$(terraform output -json | jq '.aurora.aws_rds_cluster.endpoint' | tr -d '"'):3306
```
  
Then connect using your favourite MySQL client
```
mysql -u$(terraform output -json | jq '.aurora.aws_rds_cluster.endpoint' | tr -d '"') -p$(terraform output -json | jq '.aurora.aws_rds_cluster.master_password' | tr -d '"') -h 127.0.0.1 -D $(terraform output -json | jq '.aurora.aws_rds_cluster.database_name' | tr -d '"')
```

## Set up your Continuous Integration/Deployment pipeline

You will need the below environment variables in your CI/CD project to redeploy your ECS service.

- `AWS_ACCOUNT_ID`
- `ECR_LARAVEL_URI_*`
- `ECR_NGINX_URI_*`
- `AWS_ACCESS_KEY_ID_*`
- `AWS_SECRET_ACCESS_KEY_*`
- `AWS_REGION`
- `ECS_TASK_DEFINITION`
- `ECS_CLUSTER_NAME_*`
- `ECS_SERVICE_NAME_*`

... where * is each of `PRODUCTION` and `STAGING`

## 4. Test your infrastructure code

- Test Laravel is up DONE
- Test Laravel workers are running -> see test SQS
- Test Laravel scheduler is running -> see test SQS
- Test Laravel can reach S3 -> test upload S3 object DONE :thumbsup:
- Test Laravel can reach MySQL -> migrations are running on container boot DONE :thumbsup:
- Test Laravel can reach Redis -> Elasticache DONE :thumbsup:
- Test Laravel can reach ElasticSearch -> ElasticSearch DONE :thumbsup:
- Test Laravel can reach SQS -> test SQS (scheduler/worker logs) DONE :thumbsup:
- Test Laravel can be passed SSM secrets -> test SSM secrets are passed as env vars :thumbsup:
- Test Laravel front-end autoscaling -> out of scope
