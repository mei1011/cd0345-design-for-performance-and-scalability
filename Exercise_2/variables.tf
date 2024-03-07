variable "region" {
  type        = string
  description = "Aws region"
  default     = null
}

variable "function_name" {
  type        = string
  description = "Lambda function name"
  default     = null
}

variable "output_path" {
  type        = string
  description = "Lambda output path"
  default     = null
}