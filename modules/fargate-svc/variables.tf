variable "env" {
  description = "Enviroment for application such as prod, stg, dev"
  type        = string
}

variable "cluster_name" {
  description = "Cluster name fargate for application"
  type        = string
}

variable "service_name" {
  description = "Service fargate will be create. Such as web, api ..."
  type        = string
}

variable "region" {
  description = "The region for create resource aws"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC will be used"
  type        = string
}

variable "domain" {
  description = "The ID of the AWS Account"
  type        = string
}

variable "retention_in_days" {
  description = "Name to be used on all the resources as identifier"
  type        = number
  default     = 7
}

variable "ecs_task_count" {
  description = "Name to be used on all the resources as identifier"
  type        = number
  default     = 1
}

variable "container_port" {
  description = "Name to be used on all the resources as identifier"
  type        = string
  default     = "80"
}

variable "assign_public_ip" {
  description = "Name to be used on all the resources as identifier"
  type        = bool
  default     = false
}

variable "parameter" {
  description = "Name to be used on all the resources as identifier"
  type        = bool
  default     = false
}

variable "ecs_task_cpu" {
  description = "Name to be used on all the resources as identifier"
  type        = string
}

variable "ecs_task_mem" {
  description = "Name to be used on all the resources as identifier"
  type        = string
}

variable "secretsmanager_arn" {
  description = "Name to be used on all the resources as identifier"
  type        = string
  default     = null
}

variable "max_scale" {
  description = "Name to be used on all the resources as identifier"
  type        = number
  default     = 8
}

variable "min_scale" {
  description = "Name to be used on all the resources as identifier"
  type        = number
  default     = 2
}

variable "target_scale_mem" {
  description = "Name to be used on all the resources as identifier"
  type        = number
  default     = 75
}

variable "target_scale_cpu" {
  description = "Name to be used on all the resources as identifier"
  type        = number
  default     = 75
}

variable "sg_ingress" {
  description = "Security group will be allow access inbound Fargate"
  type        = list(string)
  default     = null
}

variable "cidr_ingress" {
  description = "Rangle list ip allow access inbound Fargate"
  type        = list(string)
  default     = null
}

variable "alb_listener_443" {
  description = "ID listener alb port 443"
  type        = string
}

variable "ecs_cluster_id" {
  description = "ECS Cluster ID"
  type        = string
}

variable "subnet_ids" {
  description = "The subnets will be asign to create Fargate"
  type        = list(string)
}

variable "ecs_task_role" {
  description = "ARN task role fargate"
  type        = string
}

variable "svc_discovery_id" {
  description = "Service discovery ID"
  type        = string
}

variable "alb_priority" {
  description = "Set priority for alb listener"
  type        = number
  default     = 100
}
