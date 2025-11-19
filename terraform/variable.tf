variable "github_token" {
  type      = string
  sensitive = true
}

variable "github_url" {
  type      = string
  default = "https://github.com/collins-techworld/fluxcd.git"
}

variable "secret_name" {
  type      = string
  default = "flux-system"
}