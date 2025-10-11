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

# --- Section: Quick Setup Presets ---
data "coder_parameter" "quick_setup_preset" {
  name         = "quick_setup_preset"
  display_name = "Quick Setup"
  description  = "Choose a common service preset to quickly add to your workspace"
  icon         = "/emojis/26a1.png" # Lightning bolt
  type         = "string"
  form_type    = "dropdown"
  mutable      = true
  default      = "none"
  order        = 99

  option {
    name  = "None (Custom Setup)"
    value = "none"
  }
  option {
    name  = "Redis Cache"
    value = "redis"
  }
  option {
    name  = "PostgreSQL Database"
    value = "postgres"
  }
  option {
    name  = "MySQL Database"
    value = "mysql"
  }
  option {
    name  = "MongoDB Database"
    value = "mongo"
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
  description  = "Alphanumeric characters, hyphens, and underscores only (max 63 chars)"
  type         = "string"
  icon         = "/emojis/1f4db.png" # Name badge emoji
  mutable      = true
  order        = 101 + (count.index * 5)

  validation {
    regex = "^[a-zA-Z0-9][a-zA-Z0-9_-]{0,62}$"
    error = "Container name must start with alphanumeric character, contain only letters, numbers, hyphens, and underscores, and be 1-63 characters long."
  }
}

data "coder_parameter" "container_image" {
  count = local.container_count

  name         = "container_${count.index + 1}_image"
  display_name = "Container #${count.index + 1}: Image"
  description  = "Docker image (e.g., 'redis:latest', 'postgres:13', 'mysql:8')"
  icon         = "/icon/docker.svg"
  type         = "string"
  mutable      = true
  order        = 101 + (count.index * 5) + 1
  default      = count.index == 0 ? "redis:latest" : ""

  validation {
    regex = "^[a-z0-9._/-]+:[a-zA-Z0-9._-]+$|^[a-z0-9._/-]+$"
    error = "Image must be a valid Docker image name (optionally with tag)."
  }
}

data "coder_parameter" "container_ports" {
  count = local.container_count

  name         = "container_${count.index + 1}_ports"
  display_name = "Container #${count.index + 1}: Internal Ports"
  description  = "Comma-separated ports (1-65535), e.g., '6379, 8080'. Common: Redis=6379, HTTP=8080, Postgres=5432"
  icon         = "/emojis/1f50c.png" # Plug emoji
  type         = "string"
  mutable      = true
  order        = 101 + (count.index * 5) + 2
  default      = count.index == 0 ? "6379" : ""

  validation {
    regex = "^[0-9, ]*$"
    error = "Ports must be numbers separated by commas and spaces."
  }
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
  description  = "URL-safe identifier (lowercase, hyphens, underscores)"
  type         = "string"
  mutable      = true
  order        = 121 + (count.index * 5) + 1

  validation {
    regex = "^[a-z0-9][a-z0-9_-]{0,31}$"
    error = "Slug must be lowercase, start with alphanumeric, and contain only letters, numbers, hyphens, underscores (max 32 chars)."
  }
}

data "coder_parameter" "app_url" {
  count        = local.app_count
  name         = "app_${count.index + 1}_url"
  display_name = "App #${count.index + 1}: URL"
  description  = "Internal service URL (e.g., http://redis-commander:8081, http://postgres-admin:5050)"
  type         = "string"
  mutable      = true
  order        = 121 + (count.index * 5) + 2

  validation {
    regex = "^https?://[a-zA-Z0-9.-]+(:([1-9][0-9]{0,4}))?(/.*)?$"
    error = "URL must be a valid HTTP/HTTPS URL with optional port and path."
  }
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
  # Preset configurations for common services
  preset_configs = {
    redis = {
      containers = [{
        name   = "redis"
        image  = "redis:7-alpine"
        ports  = [6379]
        env    = []
        mounts = {}
      }]
      volumes = []
      apps = [{
        name  = "Redis CLI"
        slug  = "redis-cli"
        url   = "http://redis:6379"
        icon  = "/icon/redis.svg"
        share = "owner"
      }]
    }
    postgres = {
      containers = [{
        name   = "postgres"
        image  = "postgres:15-alpine"
        ports  = [5432]
        env    = ["POSTGRES_DB=workspace", "POSTGRES_USER=coder", "POSTGRES_PASSWORD=coder"]
        mounts = { "postgres-data" = "/var/lib/postgresql/data" }
      }]
      volumes = ["postgres-data"]
      apps    = []
    }
    mysql = {
      containers = [{
        name   = "mysql"
        image  = "mysql:8.0"
        ports  = [3306]
        env    = ["MYSQL_ROOT_PASSWORD=coder", "MYSQL_DATABASE=workspace", "MYSQL_USER=coder", "MYSQL_PASSWORD=coder"]
        mounts = { "mysql-data" = "/var/lib/mysql" }
      }]
      volumes = ["mysql-data"]
      apps    = []
    }
    mongo = {
      containers = [{
        name   = "mongo"
        image  = "mongo:7"
        ports  = [27017]
        env    = ["MONGO_INITDB_ROOT_USERNAME=coder", "MONGO_INITDB_ROOT_PASSWORD=coder"]
        mounts = { "mongo-data" = "/data/db" }
      }]
      volumes = ["mongo-data"]
      apps    = []
    }
  }

  # Check if user selected a preset
  selected_preset = try(data.coder_parameter.quick_setup_preset.value, "none")
  preset_data     = local.selected_preset != "none" && local.selected_preset != null ? local.preset_configs[local.selected_preset] : null

  # Guard against null values during the initial run before the user selects a count.
  base_container_count = data.coder_parameter.additional_container_count.value == null ? 0 : tonumber(data.coder_parameter.additional_container_count.value)
  container_count      = local.preset_data != null ? local.base_container_count + length(local.preset_data.containers) : local.base_container_count

  app_count = data.coder_parameter.additional_app_count.value == null ? 0 : tonumber(data.coder_parameter.additional_app_count.value)

  # Get the list of volume names from the parameter, plus any from presets
  base_volume_names      = try(jsondecode(data.coder_parameter.additional_volumes.value), [])
  preset_volume_names    = local.preset_data != null ? local.preset_data.volumes : []
  volume_names_to_create = concat(local.base_volume_names, local.preset_volume_names)

  # Construct containers from preset (if selected) and custom parameters
  preset_containers = local.preset_data != null ? local.preset_data.containers : []

  custom_containers = [
    for i in range(local.base_container_count) : {
      name  = data.coder_parameter.container_name[i].value
      image = data.coder_parameter.container_image[i].value
      # Parse and validate ports (1-65535 range)
      ports = [
        for p in split(",", try(data.coder_parameter.container_ports[i].value, "")) :
        tonumber(trimspace(p))
        if trimspace(p) != "" && can(tonumber(trimspace(p))) && tonumber(trimspace(p)) >= 1 && tonumber(trimspace(p)) <= 65535
      ]
      mounts = {
        for mount in split(",", try(data.coder_parameter.container_volume_mounts[i].value, "")) :
        trimspace(split(":", mount)[0]) => trimspace(split(":", mount)[1])
        if trimspace(mount) != "" && can(regex(":", mount)) && length(split(":", mount)) >= 2
      }
      # Parse environment variables with basic validation (KEY=VALUE format)
      env = [
        for line in split("\n", try(data.coder_parameter.container_env_vars[i].value, "")) :
        trimspace(line)
        if trimspace(line) != "" && can(regex("^[A-Za-z_][A-Za-z0-9_]*=.*$", trimspace(line)))
      ]
    }
  ]

  # Combine preset and custom containers
  additional_containers = concat(local.preset_containers, local.custom_containers)

  # Construct apps from preset (if selected) and custom parameters
  preset_apps = local.preset_data != null ? [
    for i, app in local.preset_data.apps : {
      name         = app.name
      slug         = app.slug
      icon         = app.icon
      share        = app.share
      original_url = app.url
      local_port   = 9000 + i
      proxy_url    = "http://localhost:${9000 + i}"
    }
  ] : []

  custom_apps = [
    for i in range(local.app_count) : {
      name         = data.coder_parameter.app_name[i].value
      slug         = data.coder_parameter.app_slug[i].value
      icon         = data.coder_parameter.app_icon[i].value
      share        = data.coder_parameter.app_share[i].value
      original_url = data.coder_parameter.app_url[i].value
      # Assign ports after preset apps
      local_port = 9000 + length(local.preset_apps) + i
      proxy_url  = "http://localhost:${9000 + length(local.preset_apps) + i}"
    }
  ]

  # Combine preset and custom apps
  additional_apps = concat(local.preset_apps, local.custom_apps)

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
  #   restart      = "unless-stopped"

  # Resource limits to prevent containers from consuming excessive resources
  memory      = var.container_memory_limit
  memory_swap = var.container_memory_limit # Disable swap usage
  cpu_shares  = 1024                       # Default CPU shares

  # Security options
  user      = var.container_user_id != null ? var.container_user_id : null
  read_only = false # Allow writes to container filesystem
  tmpfs = {
    "/tmp" = "noexec,nosuid,size=100m"
  }

  # Health check for better container management
  healthcheck {
    test         = ["CMD-SHELL", "exit 0"] # Basic health check - containers should override this
    interval     = "30s"
    timeout      = "3s"
    start_period = "10s"
    retries      = 3
  }

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

  lifecycle {
    ignore_changes = [
      # Ignore changes to image after creation to prevent unwanted updates
      image,
    ]
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

