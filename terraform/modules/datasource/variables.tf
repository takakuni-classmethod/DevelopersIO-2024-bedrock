variable "prefix" {
  type        = string
  description = "Prefix to be used for all resources"
}

variable "datasource" {
  type = object({
    force_destroy = bool
  })
}
