terraform {
  required_version = ">= 1.0"
  required_providers {
    coder = { 
      source  = "coder/coder"
      version = ">= 2.0"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = ">= 3.0"
    }
  }
}

# --- Section: Parameters for Additional Containers ---
data "coder_parameter" "additional_container_count" {
  name         = "additional_container_count"
  display_name = "Number of Additional Containers"
  description  = "Select how many extra containers to add to the workspace."
  icon         = "/icon/docker.svg"
  type         = "number"
  form_type    = "slider"
  mutable      = true
  default      = 0
  order        = 100 # Order them after main params

  validation {
    min = 0
    max = 5
  }
}

data "coder_parameter" "container_name" {
  count = local.container_count

  name         = "container_${count.index + 1}_name"
  display_name = "Container #${count.index + 1}: Name"
  type         = "string"
  icon         = "/emojis/1f4db.png" # Name badge emoji
  mutable      = true
  order        = 101 + (count.index * 5)
}

data "coder_parameter" "container_image" {
  count = local.container_count

  name         = "container_${count.index + 1}_image"
  display_name = "Container #${count.index + 1}: Image"
  description  = "e.g., 'redis:latest'"
  icon         = "/icon/docker.svg"
  type         = "string"
  mutable      = true
  order        = 101 + (count.index * 5) + 1
}

data "coder_parameter" "container_ports" {
  count = local.container_count

  name         = "container_${count.index + 1}_ports"
  display_name = "Container #${count.index + 1}: Internal Ports"
  description  = "Comma-separated list of internal ports to expose, e.g., '6379, 8080'"
  icon         = "/emojis/1f50c.png" # Plug emoji
  type         = "string"
  mutable      = true
  order        = 101 + (count.index * 5) + 2
}

data "coder_parameter" "container_volume_mounts" {
  count = local.container_count

  name         = "container_${count.index + 1}_volume_mounts"
  display_name = "Container #${count.index + 1}: Volume Mounts"
  description  = "e.g., 'my-volume:/path/in/container, another-vol:/another/path'"
  type         = "string"
  icon         = "/icon/folder.svg"
  mutable      = true
  order        = 101 + (count.index * 5) + 3
  default      = ""
}

data "coder_parameter" "container_env_vars" {
  count = local.container_count

  name         = "container_${count.index + 1}_env_vars"
  display_name = "Container #${count.index + 1}: Environment Variables"
  description  = "One per line, e.g., 'POSTGRES_USER=coder'"
  type         = "string"
  icon         = "/emojis/2699.png" # Gear emoji
  form_type    = "textarea"
  mutable      = true
  order        = 101 + (count.index * 5) + 4
  default      = ""
}


# --- Section: Parameters for Additional Volumes ---
data "coder_parameter" "additional_volumes" {
  name         = "additional_volumes"
  display_name = "Additional Volumes to Create"
  description  = "List of all persistent volume names to create for this workspace. You can then mount them into containers above."
  icon         = "/icon/folder.svg"
  type         = "list(string)"
  form_type    = "tag-select"
  mutable      = true
  default      = jsonencode([])
  order        = 110
}

# --- Section: Parameters for Additional Coder Apps ---
data "coder_parameter" "additional_app_count" {
  name         = "additional_app_count"
  display_name = "Number of Additional Coder Apps"
  description  = "Select how many extra Coder application launchers to create."
  icon         = "/emojis/1f310.png" # Globe emoji
  type         = "number"
  form_type    = "slider"
  mutable      = true
  default      = 0
  order        = 120 # After containers and volumes

  validation {
    min = 0
    max = 5
  }
}

data "coder_parameter" "app_name" {
  count        = local.app_count
  name         = "app_${count.index + 1}_name"
  display_name = "App #${count.index + 1}: Name"
  type         = "string"
  mutable      = true
  order        = 121 + (count.index * 5)
}

data "coder_parameter" "app_slug" {
  count        = local.app_count
  name         = "app_${count.index + 1}_slug"
  display_name = "App #${count.index + 1}: Slug"
  type         = "string"
  mutable      = true
  order        = 121 + (count.index * 5) + 1
}

data "coder_parameter" "app_url" {
  count        = local.app_count
  name         = "app_${count.index + 1}_url"
  display_name = "App #${count.index + 1}: URL"
  description  = "e.g., http://redis-commander:8081"
  type         = "string"
  mutable      = true
  order        = 121 + (count.index * 5) + 2
}

data "coder_parameter" "app_icon" {
  count        = local.app_count
  name         = "app_${count.index + 1}_icon"
  display_name = "App #${count.index + 1}: Icon"
  description  = "e.g., /icon/redis.svg or /emojis/1f310.png"
  type         = "string"
  mutable      = true
  order        = 121 + (count.index * 5) + 3
}

data "coder_parameter" "app_share" {
  count        = local.app_count
  name         = "app_${count.index + 1}_share"
  display_name = "App #${count.index + 1}: Share Level"
  type         = "string"
  form_type    = "dropdown"
  default      = "owner"
  mutable      = true
  order        = 121 + (count.index * 5) + 4
  option {
    name  = "Owner"
    value = "owner"
  }
  option {
    name  = "Authenticated"
    value = "authenticated"
  }
  option {
    name  = "Public"
    value = "public"
  }
}

data "coder_workspace" "me" {} # Required for start_count

locals {
  # Guard against null values during the initial run before the user selects a count.
  container_count = data.coder_parameter.additional_container_count.value == null ? 0 : tonumber(data.coder_parameter.additional_container_count.value)
  app_count       = data.coder_parameter.additional_app_count.value == null ? 0 : tonumber(data.coder_parameter.additional_app_count.value)

  # Get the list of volume names from the parameter.
  volume_names_to_create = try(jsondecode(data.coder_parameter.additional_volumes.value), [])

  # Construct a list of container objects from the parameter inputs.
  additional_containers = [
    for i in range(local.container_count) : {
      name  = data.coder_parameter.container_name[i].value
      image = data.coder_parameter.container_image[i].value
      # Parse the comma-separated string of internal ports into a list of numbers.
      ports = [for p in split(",", try(data.coder_parameter.container_ports[i].value, "")) : tonumber(trimspace(p)) if trimspace(p) != ""]
      mounts = {
        for mount in split(",", try(data.coder_parameter.container_volume_mounts[i].value, "")) :
        trimspace(split(":", mount)[0]) => trimspace(split(":", mount)[1])
        if trimspace(mount) != "" && can(regex(":", mount))
      }
      # Parse the newline-separated string of environment variables into a list.
      env = [for line in split("\n", try(data.coder_parameter.container_env_vars[i].value, "")) : trimspace(line) if trimspace(line) != ""]
    }
  ]

  # Construct a list of coder_app objects, adding proxy information.
  additional_apps = [
    for i in range(local.app_count) : {
      name         = data.coder_parameter.app_name[i].value
      slug         = data.coder_parameter.app_slug[i].value
      icon         = data.coder_parameter.app_icon[i].value
      share        = data.coder_parameter.app_share[i].value
      original_url = data.coder_parameter.app_url[i].value
      # Assign a unique localhost port for the proxy, starting at 9000.
      local_port = 9000 + i
      # The new URL for the Coder App, pointing to the localhost proxy.
      proxy_url = "http://localhost:${9000 + i}"
    }
  ]

  # Generate the PROXY_LINE string for the reverse proxy script.
  proxy_mappings_str = join(" ", [
    for app in local.additional_apps :
    # Format: "local_port:remote_host:remote_port"
    # Handle URLs with or without explicit ports (default to 80 for http, 443 for https)
    "${app.local_port}:${regex("https?://([^:/]+)", app.original_url)[0]}:${
      can(regex("https?://[^:/]+:(\\d+)", app.original_url)) 
        ? regex("https?://[^:/]+:(\\d+)", app.original_url)[0]
        : (startswith(app.original_url, "https://") ? "443" : "80")
    }"
    if app.original_url != null && app.original_url != ""
  ])
}


# --- Section: Resource Creation ---
resource "docker_volume" "dynamic_resource_volume" {
  for_each = toset(local.volume_names_to_create)
  name     = "${var.resource_name_base}-${each.key}"
  lifecycle {
    ignore_changes = all
  }
}

resource "docker_container" "dynamic_resource_container" {
  # Only create containers if the workspace is running.
  for_each = data.coder_workspace.me.start_count > 0 ? { for c in local.additional_containers : c.name => c if c.name != null && c.name != "" } : {}

  name         = "${var.resource_name_base}-${each.value.name}"
  image        = each.value.image
  hostname     = each.value.name
  network_mode = var.docker_network_name
  env          = each.value.env

  # Dynamically expose internal ports without publishing to the host.
  dynamic "ports" {
    for_each = toset(each.value.ports)
    content {
      internal = ports.value
    }
  }

  # Use a dynamic block to create volume mounts for this container.
  dynamic "volumes" {
    for_each = each.value.mounts
    content {
      container_path = volumes.value
      volume_name    = docker_volume.dynamic_resource_volume[volumes.key].name
      read_only      = false
    }
  }
}

resource "coder_script" "dynamic_resources_reverse_proxy" {
  agent_id           = var.agent_id
  display_name       = "Dynamic Resources Proxy"
  icon               = "/icon/globe.svg"
  run_on_start       = true
  start_blocks_login = false # Don't block login, it runs in background
  script             = templatefile("${path.module}/run.sh", { PROXY_LINE = local.proxy_mappings_str })
}

# Create the Coder apps to expose the services
resource "coder_app" "dynamic_app" {
  for_each = { for app in local.additional_apps : app.slug => app if app.name != null && app.name != "" && app.slug != null && app.slug != "" }
  
  agent_id     = var.agent_id
  slug         = each.value.slug
  display_name = each.value.name
  url          = each.value.proxy_url
  icon         = each.value.icon
  share        = each.value.share
}

