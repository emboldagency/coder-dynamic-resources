variable "agent_id" {
  description = "The coder agent id to attach the script to"
  type        = string
}

variable "docker_network_name" {
  type        = string
  description = "The name of the Docker network to attach containers to."
}

variable "resource_name_base" {
  type        = string
  description = "A unique prefix for all created Docker resources (e.g., 'coder-user-workspace-id')."
}
