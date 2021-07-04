// Test Docker images can be pushed to ECR
// Test Laravel is up
// Test Laravel workers are running -> workers are writing in the database
// Test Laravel scheduler is running -> scheduler is creating recurrent jobs picked up by workers
// Test Laravel can reach S3 -> URL that post/read file
// Test Laravel can reach MySQL -> select 1
// Test Laravel can reach Redis -> used as cache driver
// Test Laravel can reach ElasticSearch
// Test Laravel can reach SQS -> used as queue driver
// Test Laravel can be passed SSM secrets -> echo all env vars

package test

import (
	"testing"
	"github.com/Jeffail/gabs"

	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	// "github.com/gruntwork-io/terratest/modules/docker"

	// "github.com/stretchr/testify/assert"
	"fmt"

	"os/exec"

	// "context"

	// "github.com/aws/aws-sdk-go-v2/config"
	// // "github.com/aws/aws-sdk-go-v2/service/ec2"
	// "github.com/aws/aws-sdk-go-v2/service/ecs"


	// http_helper "github.com/gruntwork-io/terratest/modules/http-helper"

)

func TestTerraformHelloWorldExample(t *testing.T) {
	// retryable errors in terraform testing.
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "..",
	})

	defer test_structure.RunTestStage(t, "destroy", func() {
		terraform.Destroy(t, terraformOptions)
	})

	test_structure.RunTestStage(t, "apply", func() {
		terraform.InitAndApply(t, terraformOptions)
	})

	jsonParsed, err := gabs.ParseJSON([]byte(terraform.OutputJson(t, terraformOptions, "")))
	if err != nil {
	 panic(err)
	}

	test_structure.RunTestStage(t, "push_to_ecr", func() {
		region := terraform.Output(t, terraformOptions, "region")
		account_id := terraform.Output(t, terraformOptions, "account_id")

		command := fmt.Sprintf("aws ecr get-login-password --region %s | docker login --username AWS --password-stdin %s.dkr.ecr.%s.amazonaws.com", region, account_id, region)
		cmd := exec.Command("bash", "-c", command)
		err := cmd.Run()
		if err != nil {
			panic(err)
		}
	
		ecr_laravel, err := jsonParsed.JSONPointer("/ecr/value/laravel_repository_uri")
		ecr_nginx, err := jsonParsed.JSONPointer("/ecr/value/nginx_repository_uri")

		command = fmt.Sprintf("docker pull li0nel/laravel-test && docker tag li0nel/laravel-test %s &&  docker push %s", ecr_laravel.Data().(string), ecr_laravel.Data().(string))
		cmd = exec.Command("bash", "-c", command)
		err = cmd.Run()
		if err != nil {
			panic(err)
		}

		command = fmt.Sprintf("docker pull li0nel/nginx && docker tag nginx %s &&  docker push %s", ecr_nginx.Data().(string), ecr_nginx.Data().(string))
		cmd = exec.Command("bash", "-c", command)
		err = cmd.Run()
		if err != nil {
			panic(err)
		}
	})

	// ctx := context.Background()
	// config, err := config.LoadDefaultConfig(context.TODO())
	// if err != nil {
	// 	panic(err)
	// }
	// client := ecs.NewFromConfig(config)

	// startWaiter := ecs.NewTasksRunningWaiter(client)
	// err := startWaiter.Wait(ctx, &ecs.DescribeTasksInput{
	// 	Cluster: cluster_arn,
	// 	Tasks:   [
	// 		task_arn,
	// 		task_cron_arn,
	// 		task_workers_arn,
	// 	]
	// }, time.Second, func(o *ecs.TasksRunningWaiterOptions) {
	// 	// o.LogWaitAttempts = true
	// 	// o.MinDelay = time.Nanosecond
	// 	// o.MaxDelay = time.Nanosecond
	// })

	test_structure.RunTestStage(t, "homepage", func() {
		
	})

	test_structure.RunTestStage(t, "scheduler_sqs_workers", func() {
		
	})

	test_structure.RunTestStage(t, "s3", func() {
		
	})

	test_structure.RunTestStage(t, "db", func() {
		
	})

	test_structure.RunTestStage(t, "redis", func() {
		
	})

	test_structure.RunTestStage(t, "elasticsearch", func() {
		
	})

	test_structure.RunTestStage(t, "elasticsearch", func() {
		
	})

	test_structure.RunTestStage(t, "ssm", func() {
		
	})

// Test Laravel workers are running -> workers are writing in the database
// Test Laravel scheduler is running -> scheduler is creating recurrent jobs picked up by workers
// Test Laravel can reach S3 -> URL that post/read file
// Test Laravel can reach MySQL -> select 1
// Test Laravel can reach Redis -> used as cache driver
// Test Laravel can reach ElasticSearch
// Test Laravel can reach SQS -> used as queue driver
// Test Laravel can be passed SSM secrets -> echo all env vars





	// url := fmt.Sprintf("http://%s:8080", publicIp)
	// http_helper.HttpGetWithRetry(t, url, nil, 200, "Hello, World!", 30, 5*time.Second)

	// jsonParsed, err := gabs.ParseJSON([]byte(terraform.OutputJson(t, terraformOptions, "")))
	// if err != nil {
	//  panic(err)
	// }

   	//Firewall Validation
	// fw, _ := jsonParsed.JSONPointer("/firewall/value")
   
}
