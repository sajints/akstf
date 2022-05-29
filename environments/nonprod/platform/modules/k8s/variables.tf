variable "host" {
    description = "aks cluster host to login"
    type        = string
    default     = null
}


variable "client_certificate" {
    description = "aks cluster login client cert"
    type        = string
    default     = null  
} 

variable "client_key" {
    description = "aks cluster login client key"
    type        = string
    default     = null  
} 

variable "cluster_ca_certificate" {
    description = "aks cluster login ca cert"
    type        = string
    default     = null  
} 

variable "kubernetes_cluster_name" {
    description = "kubernetes_cluster_name"
    type        = string
    default     = null  
} 

variable "rgname" {
  description = "The name of this rg"
  type        = string
  default     = "rgaks"
}
