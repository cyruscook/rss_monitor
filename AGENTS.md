# RSS Monitor

This project contains infrastructure for the monitoring of RSS feeds.

The RSS feed URLs are stored in DynamoDB, with the following keys: feed_url (PK), name, last_checked (ISO 8601), last_item (GUID).

An SQS queue (with an associated DLQ) contains the IDs of feeds which are to be processed.

An SNS topic receives messages when a new RSS item is detected, or when an error occurs. The admin's email address is subscribed to the topic.

A single Lambda function is deployed from a uv Python project.
The Lambda function has three entrypoints:
- From EventBridge - the DynamoDB table is scanned, and each feed is sent to the SQS queue
- From SQS - the feed is checked and the DynamoDB table updated for that feed. Any new posts are sent to the SNS topic. A post is assumed to be new if its date is after the last_checked date (with a slight buffer for handling clock skew).
- From a Lambda URL - An extremely simple HTML page is returned showing the subscribed RSS feeds, and with a form to subscribe to a new feed.

An EventBridge schedule triggers the Lambda function every night.

A CloudWatch alarm alerts to the SNS topic when items enter the DLQ.

All IAM policies are least-privilige.

The infrastructure is written as IaC with Terraform, with the state file stored in an S3 bucket in the account. All infrastructure is deployed to eu-west-1.

# Python coding guidelines

* Prioritize code correctness and clarity. Speed and efficiency are secondary priorities unless otherwise specified.
* Do not write organizational or comments that summarize the code. Comments should only be written in order to explain "why" the code is written in some way in the case there is a reason that is tricky / non-obvious.
* Avoid creating large, oversized files. Prefer to split code into multiple smaller files and modules for better organization and readability.
* Always make use of type safety and use strong typing everywhere. Use `ty` (https://docs.astral.sh/ty/) to typecheck your code.

# Terraform coding guidelines

* Seperate the Terraform into logical modules for different components. Within each module, split resources into files based on the primary service they handle, for example an `iam.tf` file containing all IAM resources. Prefix resource names with the component they belong to.
* The root module should be orchestration only, with no resources defined.

# Lambda coding guidlines

* Make use of the Powertools for AWS Lambda, in paticular for type information and structured logging.

# Validating changes

After making changes, run relevant validation targets from the Makefile. Avoid running custom commands to validate changes, and instead use the existing Makefile targets. If sensible validation commands are missing from the Makefile, add them in.

As this is a small personal project, there are no unit tests.
