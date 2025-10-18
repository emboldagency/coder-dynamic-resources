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

# --- Section: Parameters for Additional Volumes ---
data "coder_parameter" "additional_volumes" {
  name         = "additional_volumes"
  display_name = "Additional Volumes to Create"
  description  = "List of all persistent volume names to create for this workspace. You can then mount them into containers below."
  icon         = "/icon/folder.svg"
  type         = "list(string)"
  mutable      = true
  default      = jsonencode([])
  order        = 110
}

# --- Fixed parameter sets for up to 3 containers (leave blank to skip) ---
data "coder_parameter" "container_1_name" {
  name         = "container_1_name"
  display_name = "Container #1: Name"
  description  = "Alphanumeric characters, hyphens, and underscores only (max 63 chars). Leave empty to skip this container."
  type         = "string"
  icon         = "/emojis/1f4db.png"
  mutable      = true
  default      = ""
  order        = 201
  validation {
    regex = "^$|^[a-zA-Z0-9][a-zA-Z0-9_-]{0,62}$"
    error = "Container name must start with alphanumeric character, contain only letters, numbers, hyphens, and underscores, and be 1-63 characters long."
  }
}

data "coder_parameter" "container_1_image" {
  name         = "container_1_image"
  display_name = "Container #1: Image"
  description  = "Docker image (e.g., 'redis:latest', 'postgres:13', 'mysql:8')"
  icon         = "/icon/docker.svg"
  type         = "string"
  mutable      = true
  default      = ""
  order        = 202
  validation {
    regex = "^$|^[a-z0-9._/-]+:[a-zA-Z0-9._-]+$|^[a-z0-9._/-]+$"
    error = "Image must be a valid Docker image name (optionally with tag)."
  }
}

data "coder_parameter" "container_1_ports" {
  name         = "container_1_ports"
  display_name = "Container #1: Internal Ports"
  description  = "Comma-separated ports (1-65535), e.g., '6379, 8080'"
  icon         = "/emojis/1f50c.png"
  type         = "string"
  mutable      = true
  default      = ""
  order        = 203
  validation {
    regex = "^[0-9, ]*$"
    error = "Ports must be numbers separated by commas and spaces."
  }
}

data "coder_parameter" "container_1_volume_mounts" {
  name         = "container_1_volume_mounts"
  display_name = "Container #1: Volume Mounts"
  description  = "e.g., 'my-volume:/path/in/container, another-vol:/another/path'"
  type         = "string"
  icon         = "/icon/folder.svg"
  mutable      = true
  default      = ""
  order        = 204
}

data "coder_parameter" "container_1_env_vars" {
  name         = "container_1_env_vars"
  display_name = "Container #1: Environment Variables"
  description  = "One per line, e.g., 'POSTGRES_USER=embold'"
  type         = "string"
  icon         = "/emojis/2733.png"
  mutable      = true
  default      = ""
  order        = 205
}

data "coder_parameter" "container_2_name" {
  name         = "container_2_name"
  display_name = "Container #2: Name"
  description  = "Alphanumeric characters, hyphens, and underscores only (max 63 chars). Leave empty to skip this container."
  type         = "string"
  icon         = "/emojis/1f4db.png"
  mutable      = true
  default      = ""
  order        = 211
  validation {
    regex = "^$|^[a-zA-Z0-9][a-zA-Z0-9_-]{0,62}$"
    error = "Container name must start with alphanumeric character, contain only letters, numbers, hyphens, and underscores, and be 1-63 characters long."
  }
}

data "coder_parameter" "container_2_image" {
  name         = "container_2_image"
  display_name = "Container #2: Image"
  description  = "Docker image (e.g., 'redis:latest', 'postgres:13', 'mysql:8')"
  icon         = "/icon/docker.svg"
  type         = "string"
  mutable      = true
  default      = ""
  order        = 212
  validation {
    regex = "^$|^[a-z0-9._/-]+:[a-zA-Z0-9._-]+$|^[a-z0-9._/-]+$"
    error = "Image must be a valid Docker image name (optionally with tag)."
  }
}

data "coder_parameter" "container_2_ports" {
  name         = "container_2_ports"
  display_name = "Container #2: Internal Ports"
  description  = "Comma-separated ports (1-65535)"
  icon         = "/emojis/1f50c.png"
  type         = "string"
  mutable      = true
  default      = ""
  order        = 213
  validation {
    regex = "^[0-9, ]*$"
    error = "Ports must be numbers separated by commas and spaces."
  }
}

data "coder_parameter" "container_2_volume_mounts" {
  name         = "container_2_volume_mounts"
  display_name = "Container #2: Volume Mounts"
  description  = "e.g., 'my-volume:/path/in/container, another-vol:/another/path'"
  type         = "string"
  icon         = "/icon/folder.svg"
  mutable      = true
  default      = ""
  order        = 214
}

data "coder_parameter" "container_2_env_vars" {
  name         = "container_2_env_vars"
  display_name = "Container #2: Environment Variables"
  description  = "One per line, e.g., 'POSTGRES_USER=embold'"
  type         = "string"
  icon         = "/emojis/2733.png"
  mutable      = true
  default      = ""
  order        = 215
}

data "coder_parameter" "container_3_name" {
  name         = "container_3_name"
  display_name = "Container #3: Name"
  description  = "Alphanumeric characters, hyphens, and underscores only (max 63 chars). Leave empty to skip this container."
  type         = "string"
  icon         = "/emojis/1f4db.png"
  mutable      = true
  default      = ""
  order        = 221
  validation {
    regex = "^$|^[a-zA-Z0-9][a-zA-Z0-9_-]{0,62}$"
    error = "Container name must start with alphanumeric character, contain only letters, numbers, hyphens, and underscores, and be 1-63 characters long."
  }
}

data "coder_parameter" "container_3_image" {
  name         = "container_3_image"
  display_name = "Container #3: Image"
  description  = "Docker image (e.g., 'redis:latest', 'postgres:13', 'mysql:8')"
  icon         = "/icon/docker.svg"
  type         = "string"
  mutable      = true
  default      = ""
  order        = 222
  validation {
    regex = "^$|^[a-z0-9._/-]+:[a-zA-Z0-9._-]+$|^[a-z0-9._/-]+$"
    error = "Image must be a valid Docker image name (optionally with tag)."
  }
}

data "coder_parameter" "container_3_ports" {
  name         = "container_3_ports"
  display_name = "Container #3: Internal Ports"
  description  = "Comma-separated ports (1-65535)"
  icon         = "/emojis/1f50c.png"
  type         = "string"
  mutable      = true
  default      = ""
  order        = 223
  validation {
    regex = "^[0-9, ]*$"
    error = "Ports must be numbers separated by commas and spaces."
  }
}

data "coder_parameter" "container_3_volume_mounts" {
  name         = "container_3_volume_mounts"
  display_name = "Container #3: Volume Mounts"
  description  = "e.g., 'my-volume:/path/in/container, another-vol:/another/path'"
  type         = "string"
  icon         = "/icon/folder.svg"
  mutable      = true
  default      = ""
  order        = 224
}

data "coder_parameter" "container_3_env_vars" {
  name         = "container_3_env_vars"
  display_name = "Container #3: Environment Variables"
  description  = "One per line, e.g., 'POSTGRES_USER=embold'"
  type         = "string"
  icon         = "/emojis/2733.png"
  mutable      = true
  default      = ""
  order        = 225
}

# --- Fixed parameter sets for up to 3 additional Coder apps ---
data "coder_parameter" "app_1_name" {
  name         = "app_1_name"
  display_name = "App #1: Name"
  type         = "string"
  mutable      = true
  default      = ""
  order        = 301
}

data "coder_parameter" "app_1_slug" {
  name         = "app_1_slug"
  display_name = "App #1: Slug"
  description  = "URL-safe identifier (lowercase, hyphens, underscores)"
  type         = "string"
  mutable      = true
  default      = ""
  order        = 302
  validation {
    regex = "^$|^[a-z0-9][a-z0-9_-]{0,31}$"
    error = "Slug must be lowercase, start with alphanumeric, and contain only letters, numbers, hyphens, underscores (max 32 chars)."
  }
}

data "coder_parameter" "app_1_url" {
  name         = "app_1_url"
  display_name = "App #1: URL"
  description  = "Internal service URL"
  type         = "string"
  mutable      = true
  default      = ""
  order        = 303
  validation {
    regex = "^$|^https?://[a-zA-Z0-9.-]+(:([1-9][0-9]{0,4}))?(/.*)?$"
    error = "URL must be a valid HTTP/HTTPS URL with optional port and path."
  }
}

data "coder_parameter" "app_1_icon" {
  name         = "app_1_icon"
  display_name = "App #1: Icon"
  description  = "e.g., /icon/redis.svg or /emojis/1f310.png"
  type         = "string"
  mutable      = true
  default      = ""
  order        = 304
}

data "coder_parameter" "app_1_share" {
  name         = "app_1_share"
  display_name = "App #1: Share Level"
  type         = "string"
  default      = "owner"
  mutable      = true
  order        = 305
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

data "coder_parameter" "app_2_name" {
  name         = "app_2_name"
  display_name = "App #2: Name"
  type         = "string"
  mutable      = true
  default      = ""
  order        = 311
}

data "coder_parameter" "app_2_slug" {
  name         = "app_2_slug"
  display_name = "App #2: Slug"
  description  = "URL-safe identifier (lowercase, hyphens, underscores)"
  type         = "string"
  mutable      = true
  default      = ""
  order        = 312
  validation {
    regex = "^$|^[a-z0-9][a-z0-9_-]{0,31}$"
    error = "Slug must be lowercase, start with alphanumeric, and contain only letters, numbers, hyphens, underscores (max 32 chars)."
  }
}

data "coder_parameter" "app_2_url" {
  name         = "app_2_url"
  display_name = "App #2: URL"
  description  = "Internal service URL"
  type         = "string"
  mutable      = true
  default      = ""
  order        = 313
  validation {
    regex = "^$|^https?://[a-zA-Z0-9.-]+(:([1-9][0-9]{0,4}))?(/.*)?$"
    error = "URL must be a valid HTTP/HTTPS URL with optional port and path."
  }
}

data "coder_parameter" "app_2_icon" {
  name         = "app_2_icon"
  display_name = "App #2: Icon"
  description  = "e.g., /icon/redis.svg or /emojis/1f310.png"
  type         = "string"
  mutable      = true
  default      = ""
  order        = 314
}

data "coder_parameter" "app_2_share" {
  name         = "app_2_share"
  display_name = "App #2: Share Level"
  type         = "string"
  default      = "owner"
  mutable      = true
  order        = 315
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

data "coder_parameter" "app_3_name" {
  name         = "app_3_name"
  display_name = "App #3: Name"
  type         = "string"
  mutable      = true
  default      = ""
  order        = 321
}

data "coder_parameter" "app_3_slug" {
  name         = "app_3_slug"
  display_name = "App #3: Slug"
  description  = "URL-safe identifier (lowercase, hyphens, underscores)"
  type         = "string"
  mutable      = true
  default      = ""
  order        = 322
  validation {
    regex = "^$|^[a-z0-9][a-z0-9_-]{0,31}$"
    error = "Slug must be lowercase, start with alphanumeric, and contain only letters, numbers, hyphens, underscores (max 32 chars)."
  }
}

data "coder_parameter" "app_3_url" {
  name         = "app_3_url"
  display_name = "App #3: URL"
  description  = "Internal service URL"
  type         = "string"
  mutable      = true
  default      = ""
  order        = 323
  validation {
    regex = "^$|^https?://[a-zA-Z0-9.-]+(:([1-9][0-9]{0,4}))?(/.*)?$"
    error = "URL must be a valid HTTP/HTTPS URL with optional port and path."
  }
}

data "coder_parameter" "app_3_icon" {
  name         = "app_3_icon"
  display_name = "App #3: Icon"
  description  = "e.g., /icon/redis.svg or /emojis/1f310.png"
  type         = "string"
  mutable      = true
  default      = ""
  order        = 324
}

data "coder_parameter" "app_3_share" {
  name         = "app_3_share"
  display_name = "App #3: Share Level"
  type         = "string"
  default      = "owner"
  mutable      = true
  order        = 325
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

data "coder_workspace" "me" {}

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
        env    = [
          # Use sanitized workspace name for DB name, fallback to 'workspace'
          "POSTGRES_DB=${lower(regex_replace("[^a-zA-Z0-9_]", "_", replace(data.coder_workspace.me.name, "-", "_"))) != "" ? lower(regex_replace("[^a-zA-Z0-9_]", "_", replace(data.coder_workspace.me.name, "-", "_"))) : "workspace"}",
          "POSTGRES_USER=embold",
          "POSTGRES_PASSWORD=embold"
        ]
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
        env    = [
          # MySQL expects a database name without special chars; use sanitized workspace name
          "MYSQL_ROOT_PASSWORD=embold",
          "MYSQL_DATABASE=${lower(regex_replace("[^a-zA-Z0-9_]", "_", replace(data.coder_workspace.me.name, "-", "_"))) != "" ? lower(regex_replace("[^a-zA-Z0-9_]", "_", replace(data.coder_workspace.me.name, "-", "_"))) : "workspace"}",
          "MYSQL_USER=embold",
          "MYSQL_PASSWORD=embold"
        ]
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
        env    = [
          # MongoDB initial DB can be created via the init scripts; set root user/pass to embold
          "MONGO_INITDB_ROOT_USERNAME=embold",
          "MONGO_INITDB_ROOT_PASSWORD=embold"
        ]
        mounts = { "mongo-data" = "/data/db" }
      }]
      volumes = ["mongo-data"]
      apps    = []
    }
  }

  # Check if user selected a preset
  selected_preset = try(data.coder_parameter.quick_setup_preset.value, "none")
  preset_data     = local.selected_preset != "none" && local.selected_preset != null ? local.preset_configs[local.selected_preset] : null

  # Get the list of volume names from the parameter, plus any from presets
  base_volume_names      = try(jsondecode(data.coder_parameter.additional_volumes.value), [])
  preset_volume_names    = local.preset_data != null ? local.preset_data.volumes : []
  volume_names_to_create = concat(local.base_volume_names, local.preset_volume_names)

  # Construct containers from preset (if selected) and custom parameters
  preset_containers = local.preset_data != null ? local.preset_data.containers : []

  # Build custom containers base list (no idx yet)
  custom_containers_base = [
    {
      name  = try(data.coder_parameter.container_1_name.value, "")
      image = try(data.coder_parameter.container_1_image.value, "")
      ports = [
        for p in split(",", try(data.coder_parameter.container_1_ports.value, "")) :
        tonumber(trimspace(p))
        if trimspace(p) != "" && can(tonumber(trimspace(p))) && tonumber(trimspace(p)) >= 1 && tonumber(trimspace(p)) <= 65535
      ]
      mounts = {
        for mount in split(",", try(data.coder_parameter.container_1_volume_mounts.value, "")) :
        trimspace(split(":", mount)[0]) => trimspace(split(":", mount)[1])
        if trimspace(mount) != "" && can(regex(":", mount)) && length(split(":", mount)) >= 2
      }
      env = [
        for line in split("\n", try(data.coder_parameter.container_1_env_vars.value, "")) :
        trimspace(line)
        if trimspace(line) != "" && can(regex("^[A-Za-z_][A-Za-z0-9_]*=.*$", trimspace(line)))
      ]
    },
    {
      name  = try(data.coder_parameter.container_2_name.value, "")
      image = try(data.coder_parameter.container_2_image.value, "")
      ports = [
        for p in split(",", try(data.coder_parameter.container_2_ports.value, "")) :
        tonumber(trimspace(p))
        if trimspace(p) != "" && can(tonumber(trimspace(p))) && tonumber(trimspace(p)) >= 1 && tonumber(trimspace(p)) <= 65535
      ]
      mounts = {
        for mount in split(",", try(data.coder_parameter.container_2_volume_mounts.value, "")) :
        trimspace(split(":", mount)[0]) => trimspace(split(":", mount)[1])
        if trimspace(mount) != "" && can(regex(":", mount)) && length(split(":", mount)) >= 2
      }
      env = [
        for line in split("\n", try(data.coder_parameter.container_2_env_vars.value, "")) :
        trimspace(line)
        if trimspace(line) != "" && can(regex("^[A-Za-z_][A-Za-z0-9_]*=.*$", trimspace(line)))
      ]
    },
    {
      name  = try(data.coder_parameter.container_3_name.value, "")
      image = try(data.coder_parameter.container_3_image.value, "")
      ports = [
        for p in split(",", try(data.coder_parameter.container_3_ports.value, "")) :
        tonumber(trimspace(p))
        if trimspace(p) != "" && can(tonumber(trimspace(p))) && tonumber(trimspace(p)) >= 1 && tonumber(trimspace(p)) <= 65535
      ]
      mounts = {
        for mount in split(",", try(data.coder_parameter.container_3_volume_mounts.value, "")) :
        trimspace(split(":", mount)[0]) => trimspace(split(":", mount)[1])
        if trimspace(mount) != "" && can(regex(":", mount)) && length(split(":", mount)) >= 2
      }
      env = [
        for line in split("\n", try(data.coder_parameter.container_3_env_vars.value, "")) :
        trimspace(line)
        if trimspace(line) != "" && can(regex("^[A-Za-z_][A-Za-z0-9_]*=.*$", trimspace(line)))
      ]
    }
  ]

  custom_containers = [
    for i, c in tolist(local.custom_containers_base) : merge(c, { custom_idx = i + 1 })
    if c.name != "" && c.image != ""
  ]

  # Build a single map for for_each: preset containers by name, custom containers by custom-N
  # Key preset containers as preset-<idx> to avoid collisions with externally-named containers
  preset_containers_map = { for i, c in tolist(local.preset_containers) : "preset-${i + 1}" => c }

  all_containers_map = merge(
    local.preset_containers_map,
    { for c in local.custom_containers : "custom-${c.custom_idx}" => c }
  )

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

  # Build apps from fixed parameter slots, then filter empties
  custom_apps_raw = [
    {
      name         = try(data.coder_parameter.app_1_name.value, "")
      slug         = try(data.coder_parameter.app_1_slug.value, "")
      icon         = try(data.coder_parameter.app_1_icon.value, "")
      share        = try(data.coder_parameter.app_1_share.value, "owner")
      original_url = try(data.coder_parameter.app_1_url.value, "")
    },
    {
      name         = try(data.coder_parameter.app_2_name.value, "")
      slug         = try(data.coder_parameter.app_2_slug.value, "")
      icon         = try(data.coder_parameter.app_2_icon.value, "")
      share        = try(data.coder_parameter.app_2_share.value, "owner")
      original_url = try(data.coder_parameter.app_2_url.value, "")
    },
    {
      name         = try(data.coder_parameter.app_3_name.value, "")
      slug         = try(data.coder_parameter.app_3_slug.value, "")
      icon         = try(data.coder_parameter.app_3_icon.value, "")
      share        = try(data.coder_parameter.app_3_share.value, "owner")
      original_url = try(data.coder_parameter.app_3_url.value, "")
    }
  ]

  # Assign ports after preset apps and build proxy URLs
  custom_apps = [
    for idx, app in tolist(local.custom_apps_raw) : {
      name         = app.name
      slug         = app.slug
      icon         = app.icon
      share        = app.share
      original_url = app.original_url
      local_port   = 9000 + length(local.preset_apps) + idx
      proxy_url    = "http://localhost:${9000 + length(local.preset_apps) + idx}"
    } if app.name != "" && app.slug != ""
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

  # Suffix to append to created Docker resource names to keep them unique per workspace
  name_suffix = data.coder_workspace.me.id
}


# --- Section: Resource Creation ---
resource "docker_volume" "dynamic_resource_volume" {
  for_each = toset(local.volume_names_to_create)
  # Use the original volume name as key but generate a Docker volume name that includes a suffix
  # If the volume came from a preset, suffix with preset-<n>, otherwise custom-<n> could be added.
  name = "${var.resource_name_base}-${each.key}"
  lifecycle {
    ignore_changes = all
  }
  # Label volumes so they can be associated with the Coder agent and workspace
  labels {
    label = "coder.agent_id"
    value = var.agent_id
  }
  labels {
    label = "coder.workspace_id"
    value = data.coder_workspace.me.id
  }
  labels {
    label = "coder.volume_key"
    value = each.key
  }
}

resource "docker_container" "dynamic_resource_container" {
  # Only create containers if the workspace is running.
  for_each = data.coder_workspace.me.start_count > 0 ? local.all_containers_map : {}
  agent_id = var.agent_id
  name = (
    startswith(each.key, "custom-")
    ? "${var.resource_name_base}-custom-${each.value.custom_idx}"
    : "${var.resource_name_base}-${each.value.name}"
  )
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

  # Label containers so they can be associated with the Coder agent and workspace
  labels {
    label = "coder.agent_id"
    value = var.agent_id
  }
  labels {
    label = "coder.workspace_id"
    value = data.coder_workspace.me.id
  }
  labels {
    label = "coder.resource_key"
    value = each.key
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

