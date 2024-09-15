#: Locals ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
data "aws_ecs_task_definition" "this" {
  task_definition = aws_ecs_task_definition.this.arn
  depends_on      = [aws_ecs_task_definition.this]
}

#: DRY module implementations:::::::::::::::::::::::::::::::::::::::::::::::::::

#: Resources :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
#: -----------------------------------------------------------------------------
#: CloudWatch
#: -----------------------------------------------------------------------------
resource "aws_cloudwatch_log_group" "this" {
  name              = var.default_resource_name
  tags              = var.tags
  retention_in_days = 30
}

#: -----------------------------------------------------------------------------
#: ECS
#: -----------------------------------------------------------------------------
#: And here we can already see that in order to run a task, we have to give our task a task role.
#: This role regulates what AWS services the task has access to, e.g. your application is using a DynamoDB, then the task role must give the task access to Dynamo.
resource "aws_iam_role" "ecs_task_role" {
  name = "${var.default_resource_name}-ecsTaskRole"

  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "ecs-tasks.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
  tags               = var.tags
}

resource "aws_iam_policy" "this" {
  name        = "${var.default_resource_name}-task-policy-dynamodb"
  description = "Policy for the ecs_app:  ${var.default_resource_name}"

  policy = <<EOF
{
   "Version": "2012-10-17",
   "Statement": [
       {
           "Effect": "Allow",
           "Action": [
               "dynamodb:Scan"
           ],
           "Resource": "*"
       }
   ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecs-task-role-policy-attachment" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.this.arn
}

#: But another role is needed, the task execution role. This is due to the fact that the tasks will be executed “serverless” with the Fargate configuration.
#: This enables the service to e.g. pull the image from ECR, spin up or deregister tasks etc. AWS provides you with a predefined policy for this, so I just attached this to my role:
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.default_resource_name}-ecsTaskExecutionRole"

  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "ecs-tasks.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "ecs-task-execution-role-policy-attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
  #:TODO
  #: Need to limit to below role and then access to s3 bucket for env variables
}

resource "aws_security_group" "ecs" {
  name        = "${var.ecs_service_name}-ecs"
  description = "Security group for ECS ${var.ecs_service_name} tasks"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = var.ecs_container_port
    to_port         = var.ecs_container_port
    protocol        = "tcp"
    security_groups = [var.lb_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecs_cluster" "this" {
  name = var.ecs_cluster_name
}

resource "aws_ecs_service" "this" {
  name            = var.ecs_service_name
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = var.ecs_desired_count

  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200
  launch_type                        = "FARGATE"
  scheduling_strategy                = "REPLICA"
  health_check_grace_period_seconds  = 120

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = [aws_security_group.ecs.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = var.ecs_container_name
    container_port   = var.ecs_container_port
  }

  deployment_controller {
    type = "CODE_DEPLOY"
  }

  lifecycle {
    ignore_changes = [task_definition, desired_count, network_configuration, load_balancer]
  }
}

resource "aws_ecs_task_definition" "this" {
  family                   = var.default_resource_name
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  container_definitions = jsonencode([{
    name        = var.ecs_container_name
    image       = var.ecs_container_image
    essential   = true
    environment = var.ecs_container_environment_variables
    portMappings = [{
      protocol      = "tcp"
      containerPort = var.ecs_container_port
      hostPort      = var.ecs_container_port
    }]

    container_env_variables = [
      {
        "name" : "version",
        "value" : "1.0.2"
      }
    ]

    container_env_files = [
      {
        "value" : "${var.default_resource_name}/envile.env",
        "type" : "s3"
      }
    ]

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.this.name
        awslogs-stream-prefix = "ecs"
        awslogs-region        = var.aws_region
      }
    }
  }])

  tags = var.tags
}


