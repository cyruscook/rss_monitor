module "database" {
  source = "./modules/database"

  name_prefix = "${var.project_name}-db"
}

module "notifications" {
  source = "./modules/notifications"

  name_prefix = "${var.project_name}-msg"
  subscriptions = [{
    protocol = "email"
    endpoint = var.admin_email
  }]
}

module "processing_queue" {
  source = "./modules/processing_queue"

  name_prefix        = "${var.project_name}-msg"
  visibility_timeout = local.feed_processing_lambda_timeout * 2
}

module "registry" {
  source = "./modules/registry"

  name_prefix = "${var.project_name}-reg"
  image_name  = local.lambda_image_name
}

module "lambda" {
  source = "./modules/lambda"

  name_prefix         = "${var.project_name}-lambda"
  clock_skew_seconds  = 300
  feeds_table_arn     = module.database.feeds_table_arn
  feeds_table_name    = module.database.feeds_table_name
  image_uri           = local.lambda_image_uri
  lambda_architecture = var.lambda_architecture
  timeout             = local.feed_processing_lambda_timeout
  queue_arn           = module.processing_queue.feed_queue_arn
  queue_url           = module.processing_queue.feed_queue_url
  topic_arn           = module.notifications.topic_arn
}

module "scheduler" {
  source = "./modules/scheduler"

  name_prefix         = "${var.project_name}-sched"
  lambda_function_arn = module.lambda.function_arn
  schedule_expression = "cron(51 2 * * ? *)"
}

module "alarms" {
  source = "./modules/alarms"

  name_prefix          = "${var.project_name}-alarms"
  dlq_name             = module.processing_queue.dlq_name
  lambda_function_name = module.lambda.function_name
  topic_arn            = module.notifications.topic_arn
}
