variable "env" {
  description = "Enviroment for application such as prod, stg, dev"
  type        = string
}

variable "project_name" {
  description = "Project name application"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC will be used"
  type        = string
}