variable "kubernetes_version" {
  default = "1.21.9"
}

variable "name" {
  description = "The name of this nginx ingress controller"
  type        = string
  default     = "ingress-nginx"
}

variable "rgname" {
  description = "The name of this rg"
  type        = string
  default     = "rgmyaks"
}

variable "containername" {
  description = "The name of this container"
  type        = string
  default     = "nonprodtfstate"
}