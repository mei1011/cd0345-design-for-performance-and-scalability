variable "vpc_security_group_ids" {
  type        = set(string)
  description = "Ids of default VPC Security Group"
  default     = null
}