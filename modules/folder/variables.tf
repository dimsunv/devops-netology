variable "create_folder" {
  type        = bool
  default     = false
  description = "True/False flag for creation or not folder in your cloud"
}

variable "yc_cloud_id" {
  description = "Cloud id for deplot resources"
  type        = string
  default     = ""
}

variable "yc_folder_id" {
  description = "Folder id for deplot resources"
  type        = string
  default     = ""
}

variable "name" {
  description = "Name to be used on all the resources as identifier"
  type        = string
}

variable "description" {
  description = "An optional description of this resource. Provide this property when you create the resource."
  type        = string
  default     = "Auto-created"
}
