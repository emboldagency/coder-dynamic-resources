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

variable "order" {
  description = "Order for Coder parameters in this module. This module can create a maximum of 34 parameters, so choose an order that leaves room for your other parameters."
  type        = number
  default     = 0
}

# --- Section: Quick Setup Presets ---
data "coder_parameter" "quick_setup_preset" {
  name         = "quick_setup_preset"
  display_name = "Quick Setup"
  description  = "Choose a common service preset to quickly add to your workspace"
  icon         = local.icon.lightning_bolt
  type         = "string"
  mutable      = true
  default      = "none"
  order        = var.order + 0

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
  description  = <<-DESC
    List of all persistent volume names to create for this workspace. You can then mount them into containers below.

    Example: `my-cache,shared-uploads`
  DESC
  icon         = local.icon.folder
  type         = "list(string)"
  form_type    = "tag-select"
  mutable      = true
  default      = jsonencode([])
  order        = var.order + 1
}

data "coder_parameter" "custom_container_count" {
  name         = "custom_container_count"
  display_name = "Additional Container Count"
  description  = "Number of additional Docker containers to create (0-3). Set to 0 to skip adding containers."
  type         = "number"
  icon         = local.icon.docker
  form_type    = "slider"
  mutable      = true
  default      = 0
  order        = var.order + 2
  validation {
    min = 0
    max = 3
  }
}

# data "coder_parameter" "custom_volume_count" {
#   count        = local.selected_preset ? 1 : 0
#   name         = "custom_volume_count"
#   display_name = "Custom Volume Count"
#   description  = "Number of additional Docker volumes to create (1-3). Leave as 0 to skip adding containers."
#   type         = "number"
#   form_type    = "slider"
#   default      = 0
#   validation {
#     min = 1
#     max = 3
#   }
# }

# --- Fixed parameter sets for up to 3 containers (leave blank to skip) ---
data "coder_parameter" "container_1_name" {
  # Always present to preserve entered values; selection controlled later by custom_container_count
  count        = 1
  name         = "container_1_name"
  display_name = "Container #1: Name"
  description  = local.desc.container_name
  type         = "string"
  icon         = local.icon.name_badge
  mutable      = true
  default      = ""
  order        = var.order + 3
  validation {
    regex = "^$|^[a-zA-Z0-9][a-zA-Z0-9_-]{0,62}$"
    error = "Container name must start with alphanumeric character, contain only letters, numbers, hyphens, and underscores, and be 1-63 characters long."
  }
}

data "coder_parameter" "container_1_image" {
  count        = 1
  name         = "container_1_image"
  display_name = "Container #1: Image"
  description  = local.desc.container_image
  icon         = local.icon.docker
  type         = "string"
  mutable      = true
  default      = ""
  order        = var.order + 4
  validation {
    regex = "^$|^[a-z0-9._/-]+:[a-zA-Z0-9._-]+$|^[a-z0-9._/-]+$"
    error = "Image must be a valid Docker image name (optionally with tag)."
  }
}

data "coder_parameter" "container_1_ports" {
  count        = 1
  name         = "container_1_ports"
  display_name = "Container #1: Container Port"
  description  = local.desc.container_port
  icon         = local.icon.electrical_plug
  type         = "string"
  mutable      = true
  default      = ""
  order        = var.order + 5
  validation {
    regex = "^$|^([1-9][0-9]{0,4}|[1-5][0-9]{4}|6[0-4][0-9]{3}|65[0-4][0-9]{2}|655[0-2][0-9]|6553[0-5])$"
    error = "Port must be a valid number between 1 and 65535."
  }
}

data "coder_parameter" "container_1_local_port" {
  count        = 1
  name         = "container_1_local_port"
  display_name = "Container #1: Local Proxy Port"
  description  = local.desc.local_port
  icon         = local.icon.electrical_plug
  type         = "string"
  mutable      = true
  default      = ""
  order        = var.order + 6
  validation {
    regex = "^$|^(19[0-9]{3}|20000)$"
    error = "Local port must be between 19000 and 20000."
  }
}

data "coder_parameter" "container_1_volume_mounts" {
  count        = 1
  name         = "container_1_volume_mounts"
  display_name = "Container #1: Volume Mounts"
  description  = local.desc.volume_mounts
  type         = "list(string)"
  form_type    = "tag-select"
  icon         = local.icon.folder
  mutable      = true
  default      = jsonencode([])
  order        = var.order + 7
}

data "coder_parameter" "container_1_env_vars" {
  count        = 1
  name         = "container_1_env_vars"
  display_name = "Container #1: Environment Variables"
  description  = local.desc.env_vars
  form_type    = "textarea"
  type         = "string"
  icon         = local.icon.asterisk
  mutable      = true
  default      = ""
  order        = var.order + 8
  styling = jsonencode({
    placeholder = <<-PL
    NODE_ENV=production
    DEBUG=false
    PL
  })
}

data "coder_parameter" "container_1_create_coder_app" {
  count        = 1
  name         = "container_1_create_coder_app"
  display_name = "Container #1: Create Coder App?"
  description  = "Automatically create a Coder app button to access this container's web interface"
  type         = "bool"
  icon         = local.icon.globe
  mutable      = true
  default      = "false"
  order        = var.order + 9
}

data "coder_parameter" "container_2_name" {
  count        = 1
  name         = "container_2_name"
  display_name = "Container #2: Name"
  description  = local.desc.container_name
  type         = "string"
  icon         = local.icon.name_badge
  mutable      = true
  default      = ""
  order        = var.order + 9
  validation {
    regex = "^$|^[a-zA-Z0-9][a-zA-Z0-9_-]{0,62}$"
    error = "Container name must start with alphanumeric character, contain only letters, numbers, hyphens, and underscores, and be 1-63 characters long."
  }
}

data "coder_parameter" "container_2_image" {
  count        = 1
  name         = "container_2_image"
  display_name = "Container #2: Image"
  description  = local.desc.container_image
  icon         = local.icon.docker
  type         = "string"
  mutable      = true
  default      = ""
  order        = var.order + 10
  validation {
    regex = "^$|^[a-z0-9._/-]+:[a-zA-Z0-9._-]+$|^[a-z0-9._/-]+$"
    error = "Image must be a valid Docker image name (optionally with tag)."
  }
}

data "coder_parameter" "container_2_ports" {
  count        = 1
  name         = "container_2_ports"
  display_name = "Container #2: Container Port"
  description  = local.desc.container_port
  icon         = local.icon.electrical_plug
  type         = "string"
  mutable      = true
  default      = ""
  order        = var.order + 11
  validation {
    regex = "^$|^([1-9][0-9]{0,4}|[1-5][0-9]{4}|6[0-4][0-9]{3}|65[0-4][0-9]{2}|655[0-2][0-9]|6553[0-5])$"
    error = "Port must be a valid number between 1 and 65535."
  }
}

data "coder_parameter" "container_2_local_port" {
  count        = 1
  name         = "container_2_local_port"
  display_name = "Container #2: Local Proxy Port"
  description  = local.desc.local_port
  icon         = local.icon.electrical_plug
  type         = "string"
  mutable      = true
  default      = ""
  order        = var.order + 12
  validation {
    regex = "^$|^(19[0-9]{3}|20000)$"
    error = "Local port must be between 19000 and 20000."
  }
}

data "coder_parameter" "container_2_volume_mounts" {
  count        = 1
  name         = "container_2_volume_mounts"
  display_name = "Container #2: Volume Mounts"
  description  = local.desc.volume_mounts
  type         = "list(string)"
  form_type    = "tag-select"
  icon         = local.icon.folder
  mutable      = true
  default      = jsonencode([])
  order        = var.order + 13
}

data "coder_parameter" "container_2_env_vars" {
  count        = 1
  name         = "container_2_env_vars"
  display_name = "Container #2: Environment Variables"
  description  = local.desc.env_vars
  form_type    = "textarea"
  type         = "string"
  icon         = local.icon.asterisk
  mutable      = true
  default      = ""
  order        = var.order + 14
  styling = jsonencode({
    placeholder = <<-PL
    NODE_ENV=production
    DEBUG=false
    PL
  })
}

data "coder_parameter" "container_2_create_coder_app" {
  count        = 1
  name         = "container_2_create_coder_app"
  display_name = "Container #2: Create Coder App?"
  description  = "Automatically create a Coder app button to access this container's web interface"
  type         = "bool"
  icon         = local.icon.globe
  mutable      = true
  default      = "false"
  order        = var.order + 15
}

data "coder_parameter" "container_3_name" {
  count        = 1
  name         = "container_3_name"
  display_name = "Container #3: Name"
  description  = local.desc.container_name
  type         = "string"
  icon         = local.icon.name_badge
  mutable      = true
  default      = ""
  order        = var.order + 16
  validation {
    regex = "^$|^[a-zA-Z0-9][a-zA-Z0-9_-]{0,62}$"
    error = "Container name must start with alphanumeric character, contain only letters, numbers, hyphens, and underscores, and be 1-63 characters long."
  }
}

data "coder_parameter" "container_3_image" {
  count        = 1
  name         = "container_3_image"
  display_name = "Container #3: Image"
  description  = local.desc.container_image
  icon         = local.icon.docker
  type         = "string"
  mutable      = true
  default      = ""
  order        = var.order + 17
  validation {
    regex = "^$|^[a-z0-9._/-]+:[a-zA-Z0-9._-]+$|^[a-z0-9._/-]+$"
    error = "Image must be a valid Docker image name (optionally with tag)."
  }
}

data "coder_parameter" "container_3_ports" {
  count        = 1
  name         = "container_3_ports"
  display_name = "Container #3: Container Port"
  description  = local.desc.container_port
  icon         = local.icon.electrical_plug
  type         = "string"
  mutable      = true
  default      = ""
  order        = var.order + 18
  validation {
    regex = "^$|^([1-9][0-9]{0,4}|[1-5][0-9]{4}|6[0-4][0-9]{3}|65[0-4][0-9]{2}|655[0-2][0-9]|6553[0-5])$"
    error = "Port must be a valid number between 1 and 65535."
  }
}

data "coder_parameter" "container_3_local_port" {
  count        = 1
  name         = "container_3_local_port"
  display_name = "Container #3: Local Proxy Port"
  description  = local.desc.local_port
  icon         = local.icon.electrical_plug
  type         = "string"
  mutable      = true
  default      = ""
  order        = var.order + 19
  validation {
    regex = "^$|^(19[0-9]{3}|20000)$"
    error = "Local port must be between 19000 and 20000."
  }
}

data "coder_parameter" "container_3_volume_mounts" {
  count        = 1
  name         = "container_3_volume_mounts"
  display_name = "Container #3: Volume Mounts"
  description  = local.desc.volume_mounts
  type         = "list(string)"
  form_type    = "tag-select"
  icon         = local.icon.folder
  mutable      = true
  default      = jsonencode([])
  order        = var.order + 20
}

data "coder_parameter" "container_3_env_vars" {
  count        = 1
  name         = "container_3_env_vars"
  display_name = "Container #3: Environment Variables"
  description  = local.desc.env_vars
  form_type    = "textarea"
  type         = "string"
  icon         = local.icon.asterisk
  mutable      = true
  default      = ""
  order        = var.order + 21
  styling = jsonencode({
    placeholder = <<-PL
    NODE_ENV=production
    DEBUG=false
    PL
  })
}

data "coder_parameter" "container_3_create_coder_app" {
  count        = 1
  name         = "container_3_create_coder_app"
  display_name = "Container #3: Create Coder App?"
  description  = "Automatically create a Coder app button to access this container's web interface"
  type         = "bool"
  icon         = local.icon.globe
  mutable      = true
  default      = "false"
  order        = var.order + 22
}

data "coder_parameter" "custom_coder_app_count" {
  name         = "custom_coder_app_count"
  display_name = "Additional Coder App Count"
  description  = "Number of additional Coder Apps to create (0-3). Set to 0 to skip adding apps."
  type         = "number"
  icon         = local.icon.radio_button
  form_type    = "slider"
  mutable      = true
  default      = 0
  order        = var.order + 23
  validation {
    min = 0
    max = 3
  }
}

# --- Fixed parameter sets for up to 3 additional Coder apps ---
data "coder_parameter" "app_1_name" {
  count        = try(tonumber(data.coder_parameter.custom_coder_app_count.value), 0) >= 1 ? 1 : 0
  name         = "app_1_name"
  display_name = "Coder App #1: Name"
  type         = "string"
  icon         = local.icon.name_badge
  mutable      = true
  default      = ""
  order        = var.order + 24
}

data "coder_parameter" "app_1_slug" {
  count        = try(tonumber(data.coder_parameter.custom_coder_app_count.value), 0) >= 1 ? 1 : 0
  name         = "app_1_slug"
  display_name = "Coder App #1: Slug"
  description  = local.desc.app_slug
  type         = "string"
  icon         = local.icon.snail
  mutable      = true
  default      = ""
  order        = var.order + 25
  validation {
    regex = "^$|^[a-z0-9][a-z0-9_-]{0,31}$"
    error = "Slug must be lowercase, start with alphanumeric, and contain only letters, numbers, hyphens, underscores (max 32 chars)."
  }
}

data "coder_parameter" "app_1_url" {
  count        = try(tonumber(data.coder_parameter.custom_coder_app_count.value), 0) >= 1 ? 1 : 0
  name         = "app_1_url"
  display_name = "Coder App #1: URL"
  description  = local.desc.app_url
  type         = "string"
  icon         = local.icon.paperclip
  mutable      = true
  default      = ""
  order        = var.order + 26
  validation {
    regex = "^$|^https?://[a-zA-Z0-9.-]+(:([1-9][0-9]{0,4}))?(/.*)?$"
    error = "URL must be a valid HTTP/HTTPS URL with optional port and path."
  }
}

data "coder_parameter" "app_1_icon" {
  count        = try(tonumber(data.coder_parameter.custom_coder_app_count.value), 0) >= 1 ? 1 : 0
  name         = "app_1_icon"
  display_name = "Coder App #1: Icon"
  description  = local.desc.app_icon
  type         = "string"
  icon         = "/icon/image.svg"
  mutable      = true
  default      = ""
  order        = var.order + 27
}

data "coder_parameter" "app_1_share" {
  count        = try(tonumber(data.coder_parameter.custom_coder_app_count.value), 0) >= 1 ? 1 : 0
  name         = "app_1_share"
  display_name = "Coder App #1: Share Level"
  type         = "string"
  icon         = local.icon.locked_with_pen
  default      = "owner"
  mutable      = true
  order        = var.order + 28
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
  count        = try(tonumber(data.coder_parameter.custom_coder_app_count.value), 0) >= 2 ? 1 : 0
  name         = "app_2_name"
  display_name = "Coder App #2: Name"
  type         = "string"
  icon         = local.icon.name_badge
  mutable      = true
  default      = ""
  order        = var.order + 29
}

data "coder_parameter" "app_2_slug" {
  count        = try(tonumber(data.coder_parameter.custom_coder_app_count.value), 0) >= 2 ? 1 : 0
  name         = "app_2_slug"
  display_name = "Coder App #2: Slug"
  description  = <<-DESC
    URL-safe identifier (lowercase, hyphens, underscores).

    Example: `adminer`
  DESC
  type         = "string"
  icon         = local.icon.snail
  mutable      = true
  default      = ""
  order        = var.order + 30
  validation {
    regex = "^$|^[a-z0-9][a-z0-9_-]{0,31}$"
    error = "Slug must be lowercase, start with alphanumeric, and contain only letters, numbers, hyphens, underscores (max 32 chars)."
  }
}

data "coder_parameter" "app_2_url" {
  count        = try(tonumber(data.coder_parameter.custom_coder_app_count.value), 0) >= 2 ? 1 : 0
  name         = "app_2_url"
  display_name = "Coder App #2: URL"
  description  = <<-DESC
    Internal service URL reachable from the workspace.

    Example: `http://adminer:8080`
  DESC
  type         = "string"
  icon         = local.icon.paperclip
  mutable      = true
  default      = ""
  order        = var.order + 31
  validation {
    regex = "^$|^https?://[a-zA-Z0-9.-]+(:([1-9][0-9]{0,4}))?(/.*)?$"
    error = "URL must be a valid HTTP/HTTPS URL with optional port and path."
  }
}

data "coder_parameter" "app_2_icon" {
  count        = try(tonumber(data.coder_parameter.custom_coder_app_count.value), 0) >= 2 ? 1 : 0
  name         = "app_2_icon"
  display_name = "Coder App #2: Icon"
  description  = <<-DESC
    Icon path or emoji code for the app.

    Example: `/icon/adminer.svg`
  DESC
  type         = "string"
  icon         = "/icon/image.svg"
  mutable      = true
  default      = ""
  order        = var.order + 32
}

data "coder_parameter" "app_2_share" {
  count        = try(tonumber(data.coder_parameter.custom_coder_app_count.value), 0) >= 2 ? 1 : 0
  name         = "app_2_share"
  display_name = "Coder App #2: Share Level"
  type         = "string"
  icon         = local.icon.locked_with_pen
  default      = "owner"
  mutable      = true
  order        = var.order + 33
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
  count        = try(tonumber(data.coder_parameter.custom_coder_app_count.value), 0) >= 3 ? 1 : 0
  name         = "app_3_name"
  display_name = "Coder App #3: Name"
  type         = "string"
  icon         = local.icon.name_badge
  mutable      = true
  default      = ""
  order        = var.order + 34
}

data "coder_parameter" "app_3_slug" {
  count        = try(tonumber(data.coder_parameter.custom_coder_app_count.value), 0) >= 3 ? 1 : 0
  name         = "app_3_slug"
  display_name = "Coder App #3: Slug"
  description  = <<-DESC
    URL-safe identifier (lowercase, hyphens, underscores).

    Example: `mailpit`
  DESC
  type         = "string"
  icon         = local.icon.snail
  mutable      = true
  default      = ""
  order        = var.order + 35
  validation {
    regex = "^$|^[a-z0-9][a-z0-9_-]{0,31}$"
    error = "Slug must be lowercase, start with alphanumeric, and contain only letters, numbers, hyphens, underscores (max 32 chars)."
  }
}

data "coder_parameter" "app_3_url" {
  count        = try(tonumber(data.coder_parameter.custom_coder_app_count.value), 0) >= 3 ? 1 : 0
  name         = "app_3_url"
  display_name = "Coder App #3: URL"
  description  = <<-DESC
    Internal service URL reachable from the workspace.

    Example: `http://mailpit:8025`
  DESC
  type         = "string"
  icon         = local.icon.paperclip
  mutable      = true
  default      = ""
  order        = var.order + 36
  validation {
    regex = "^$|^https?://[a-zA-Z0-9.-]+(:([1-9][0-9]{0,4}))?(/.*)?$"
    error = "URL must be a valid HTTP/HTTPS URL with optional port and path."
  }
}

data "coder_parameter" "app_3_icon" {
  count        = try(tonumber(data.coder_parameter.custom_coder_app_count.value), 0) >= 3 ? 1 : 0
  name         = "app_3_icon"
  display_name = "Coder App #3: Icon"
  description  = <<-DESC
    Icon path or emoji code for the app.

    Example: `https://mailpit.axllent.org/images/mailpit.svg`
  DESC
  type         = "string"
  icon         = "/icon/image.svg"
  mutable      = true
  default      = ""
  order        = var.order + 37
}

data "coder_parameter" "app_3_share" {
  count        = try(tonumber(data.coder_parameter.custom_coder_app_count.value), 0) >= 3 ? 1 : 0
  name         = "app_3_share"
  display_name = "Coder App #3: Share Level"
  type         = "string"
  icon         = local.icon.locked_with_pen
  default      = "owner"
  mutable      = true
  order        = var.order + 38
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
  # Derive a simple sanitized workspace name: replace hyphens and spaces with underscores and lowercase.
  # This avoids using regexreplace in environments where it's unavailable.
  sanitized_workspace_name_raw = try(data.coder_workspace.me.name, "")
  sanitized_workspace_name = (
    length(trimspace(local.sanitized_workspace_name_raw)) > 0
    ? lower(replace(replace(local.sanitized_workspace_name_raw, "-", "_"), " ", "_"))
    : "workspace"
  )
  # Shared description templates to avoid repeating long strings across parameter blocks
  desc = {
    container_name  = <<-DESC
      Alphanumeric characters, hyphens, and underscores only (max 63 chars). Leave empty to skip this container. This name is used as the container hostname and network alias.

      Example: `redis`, `postgres`, or `my-service`
    DESC
    container_image = <<-DESC
      Docker image (e.g., 'redis:latest', 'postgres:13', 'mysql:8'). Format: `<repository>/<image>:<tag>` or `<image>:<tag>` or `<image>`.

      Example: `postgres:15-alpine`
    DESC
    container_port = <<-DESC
      The actual port the container listens on (1-65535). This is the container's internal port that will be proxied.

      Example: `80`, `8080`, `3306`
    DESC
    local_port = <<-DESC
      The local proxy port (19000-20000) to use for accessing this container. This must be unique across all containers and apps. The Coder app will proxy this local port to the container's port.

      Example: `19080`, `19081`, `19306`
    DESC
    volume_mounts   = <<-DESC
      Select one or more volume mounts in the form 'volume-name:/path/in/container'. The volume name must match an entry from 'Additional Volumes' or a preset volume. Use the tag selector to add multiple mounts.

      Example: `postgres-data:/var/lib/postgresql/data` or `uploads:/srv/uploads`
    DESC
    env_vars        = <<-DESC
      One environment variable per line, in KEY=VALUE format. Use valid env var names (letters, numbers, underscore) on the left side.

      Example:
        ```
        POSTGRES_USER=embold

        POSTGRES_PASSWORD=embold
        ```
    DESC
    app_slug        = <<-DESC
      URL-safe identifier (lowercase, hyphens, underscores). Slug must be lowercase and up to 32 chars.

      Example: `redis-cli`
    DESC
    app_url         = <<-DESC
      Internal service URL reachable from the workspace. Include protocol and optional port. Used to generate a reverse-proxy mapping.

      Example: `http://redis:6379` or `http://localhost:9000/path`
    DESC
    app_icon        = <<-DESC
      Icon path or emoji code for the app.

      Example: `/icon/redis.svg` or `/emojis/1f310.png`
    DESC
  }
  # Preset configurations for common services
  preset_configs = {
    redis = {
      containers = [{
        name  = "redis"
        image = "redis:7-alpine"
        # ports  = [6379]
        env    = []
        mounts = {}
      }]
      volumes = []
    }
    postgres = {
      containers = [{
        name  = "postgres"
        image = "postgres:15-alpine"
        # ports = [5432]
        env = [
          # Use a sanitized workspace name for the DB name (fallback handled by local.sanitized_workspace_name)
          "POSTGRES_DB=${local.sanitized_workspace_name}",
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
        name  = "mysql"
        image = "mysql:8.0"
        # ports = [3306]
        env = [
          # MySQL expects a database name without special chars; use sanitized workspace name
          "MYSQL_ROOT_PASSWORD=embold",
          "MYSQL_DATABASE=${local.sanitized_workspace_name}",
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
        name  = "mongo"
        image = "mongo:7"
        # ports = [27017]
        env = [
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

  icon = {
    asterisk        = "/emojis/2733-fe0f.png"
    docker          = "/emojis/1f433.png"
    electrical_plug = "/emojis/1f50c.png"
    folder          = "/emojis/1f4c1.png"
    globe           = "/emojis/1f310.png"
    lightning_bolt  = "/emojis/26a1.png"
    locked_with_pen = "/emojis/1f50f.png"
    name_badge      = "/emojis/1f4db.png"
    paperclip       = "/emojis/1f517.png"
    radio_button    = "/emojis/1f518.png"
    snail           = "/emojis/1f40c.png"
  }

  # Check if user selected a preset
  selected_preset = try(data.coder_parameter.quick_setup_preset.value, "none")
  preset_data     = local.selected_preset != "none" && local.selected_preset != null ? local.preset_configs[local.selected_preset] : null

  # Get the list of volume names from the parameter, plus any from presets
  # additional_volumes is a singleton (no count), so access .value directly
  base_volume_names      = try(jsondecode(data.coder_parameter.additional_volumes.value), [])
  preset_volume_names    = local.preset_data != null ? local.preset_data.volumes : []
  volume_names_to_create = concat(local.base_volume_names, local.preset_volume_names)

  # Construct containers from preset (if selected) and custom parameters
  preset_containers = local.preset_data != null ? local.preset_data.containers : []

  # Build custom containers base list (no index yet)
  # Each container_N parameter is defined with `count = ... ? 1 : 0`, so reference the [0] instance when present
  custom_containers_base = [
    {
      name  = try(data.coder_parameter.container_1_name[0].value, "")
      image = try(data.coder_parameter.container_1_image[0].value, "")
      mounts = {
        for mount in try(jsondecode(data.coder_parameter.container_1_volume_mounts[0].value), []) :
        trimspace(split(":", mount)[0]) => trimspace(split(":", mount)[1])
        if mount != null && mount != "" && can(regex(":", mount)) && length(split(":", mount)) >= 2
      }
      env = [
        for line in split("\n", try(data.coder_parameter.container_1_env_vars[0].value, "")) :
        trimspace(line)
        if trimspace(line) != "" && can(regex("^[A-Za-z_][A-Za-z0-9_]*=.*$", trimspace(line)))
      ]
    },
    {
      name  = try(data.coder_parameter.container_2_name[0].value, "")
      image = try(data.coder_parameter.container_2_image[0].value, "")
      mounts = {
        for mount in try(jsondecode(data.coder_parameter.container_2_volume_mounts[0].value), []) :
        trimspace(split(":", mount)[0]) => trimspace(split(":", mount)[1])
        if mount != null && mount != "" && can(regex(":", mount)) && length(split(":", mount)) >= 2
      }
      env = [
        for line in split("\n", try(data.coder_parameter.container_2_env_vars[0].value, "")) :
        trimspace(line)
        if trimspace(line) != "" && can(regex("^[A-Za-z_][A-Za-z0-9_]*=.*$", trimspace(line)))
      ]
    },
    {
      name  = try(data.coder_parameter.container_3_name[0].value, "")
      image = try(data.coder_parameter.container_3_image[0].value, "")
      mounts = {
        for mount in try(jsondecode(data.coder_parameter.container_3_volume_mounts[0].value), []) :
        trimspace(split(":", mount)[0]) => trimspace(split(":", mount)[1])
        if mount != null && mount != "" && can(regex(":", mount)) && length(split(":", mount)) >= 2
      }
      env = [
        for line in split("\n", try(data.coder_parameter.container_3_env_vars[0].value, "")) :
        trimspace(line)
        if trimspace(line) != "" && can(regex("^[A-Za-z_][A-Za-z0-9_]*=.*$", trimspace(line)))
      ]
    }
  ]

  custom_containers = [
    for i, c in tolist(local.custom_containers_base) : merge(c, { custom_index = i + 1 })
    if c.name != "" && c.image != ""
  ]

  # Build a single map for for_each: preset containers by name, custom containers by custom-N
  # Key preset containers as preset-<index> to avoid collisions with externally-named containers
  preset_containers_map = { for i, c in tolist(local.preset_containers) : "preset-${i + 1}" => c }

  all_containers_map = merge(
    local.preset_containers_map,
    { for c in local.custom_containers : "custom-${c.custom_index}" => c }
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
      remote_host  = regex("https?://([^:/]+)", app.url)[0]
      remote_port  = can(regex("https?://[^:/]+:(\\d+)", app.url)) ? tonumber(regex("https?://[^:/]+:(\\d+)", app.url)[0]) : (startswith(app.url, "https://") ? 443 : 80)
      local_port   = 19000 + (can(regex("https?://[^:/]+:(\\d+)", app.url)) ? tonumber(regex("https?://[^:/]+:(\\d+)", app.url)[0]) : (startswith(app.url, "https://") ? 443 : 80))
      proxy_url    = "http://localhost:${19000 + (can(regex("https?://[^:/]+:(\\d+)", app.url)) ? tonumber(regex("https?://[^:/]+:(\\d+)", app.url)[0]) : (startswith(app.url, "https://") ? 443 : 80))}"
    }
  ] : []

  # Build apps from fixed parameter slots, then filter empties
  custom_apps_raw = [
    {
      name         = try(data.coder_parameter.app_1_name[0].value, "")
      slug         = try(data.coder_parameter.app_1_slug[0].value, "")
      icon         = try(data.coder_parameter.app_1_icon[0].value, "")
      share        = try(data.coder_parameter.app_1_share[0].value, "owner")
      original_url = try(data.coder_parameter.app_1_url[0].value, "")
    },
    {
      name         = try(data.coder_parameter.app_2_name[0].value, "")
      slug         = try(data.coder_parameter.app_2_slug[0].value, "")
      icon         = try(data.coder_parameter.app_2_icon[0].value, "")
      share        = try(data.coder_parameter.app_2_share[0].value, "owner")
      original_url = try(data.coder_parameter.app_2_url[0].value, "")
    },
    {
      name         = try(data.coder_parameter.app_3_name[0].value, "")
      slug         = try(data.coder_parameter.app_3_slug[0].value, "")
      icon         = try(data.coder_parameter.app_3_icon[0].value, "")
      share        = try(data.coder_parameter.app_3_share[0].value, "owner")
      original_url = try(data.coder_parameter.app_3_url[0].value, "")
    }
  ]

  # Assign ports after preset apps and build proxy URLs
  custom_apps = [
    for index, app in tolist(local.custom_apps_raw) : {
      name         = app.name
      slug         = app.slug
      icon         = app.icon
      share        = app.share
      original_url = app.original_url
      remote_host  = regex("https?://([^:/]+)", app.original_url)[0]
      remote_port  = can(regex("https?://[^:/]+:(\\d+)", app.original_url)) ? tonumber(regex("https?://[^:/]+:(\\d+)", app.original_url)[0]) : (startswith(app.original_url, "https://") ? 443 : 80)
      local_port   = 19000 + (can(regex("https?://[^:/]+:(\\d+)", app.original_url)) ? tonumber(regex("https?://[^:/]+:(\\d+)", app.original_url)[0]) : (startswith(app.original_url, "https://") ? 443 : 80))
      proxy_url    = "http://localhost:${19000 + (can(regex("https?://[^:/]+:(\\d+)", app.original_url)) ? tonumber(regex("https?://[^:/]+:(\\d+)", app.original_url)[0]) : (startswith(app.original_url, "https://") ? 443 : 80))}"
    } if app.name != "" && app.slug != ""
  ]

  # Auto-generate apps from containers with create_app enabled
  container_generated_apps_raw = [
    {
      name        = try(data.coder_parameter.container_1_name[0].value, "")
      create_app  = try(data.coder_parameter.container_1_create_coder_app[0].value, "false")
      port        = try(data.coder_parameter.container_1_ports[0].value, "")
      local_port  = try(data.coder_parameter.container_1_local_port[0].value, "")
    },
    {
      name        = try(data.coder_parameter.container_2_name[0].value, "")
      create_app  = try(data.coder_parameter.container_2_create_coder_app[0].value, "false")
      port        = try(data.coder_parameter.container_2_ports[0].value, "")
      local_port  = try(data.coder_parameter.container_2_local_port[0].value, "")
    },
    {
      name        = try(data.coder_parameter.container_3_name[0].value, "")
      create_app  = try(data.coder_parameter.container_3_create_coder_app[0].value, "false")
      port        = try(data.coder_parameter.container_3_ports[0].value, "")
      local_port  = try(data.coder_parameter.container_3_local_port[0].value, "")
    }
  ]

  container_generated_apps = [
    for container in local.container_generated_apps_raw : {
      name         = container.name
      slug         = lower(replace(container.name, " ", "-"))
      icon         = local.icon.globe
      share        = "owner"
      original_url = "http://d_${container.name}:${container.port}"
      remote_host  = "d_${container.name}"
      remote_port  = tonumber(container.port)
      local_port   = tonumber(container.local_port)
      proxy_url    = "http://localhost:${container.local_port}"
    }
    if container.name != "" && container.create_app == "true" && container.port != "" && container.local_port != ""
  ]

  # Combine preset, container-generated, and manually-defined custom apps
  additional_apps = concat(local.preset_apps, local.container_generated_apps, local.custom_apps)

  # Generate the PROXY_LINE string for the reverse proxy script.
  proxy_mappings_str = join(" ", [
    for app in local.additional_apps :
    # Format: "local_port:remote_host:remote_port"
    format(
      "%d:%s:%d",
      app.local_port,
      app.remote_host,
      app.remote_port
    )
    if app.original_url != null && app.original_url != ""
  ])
}


# --- Section: Resource Creation ---
resource "docker_volume" "dynamic_resource_volume" {
  # Only create volumes if the workspace is running
  for_each = data.coder_workspace.me.start_count > 0 ? toset(local.volume_names_to_create) : []
  # Use the original volume name as key but generate a Docker volume name that includes a prefix.
  # If the volume came from a preset, prefix with preset-<n>, otherwise custom-<n>.
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
  for_each = data.coder_workspace.me.start_count > 0 ? local.all_containers_map : tomap({})
  name = (
    startswith(each.key, "custom-")
    ? "${var.resource_name_base}-custom-${each.value.custom_index}"
    : "${var.resource_name_base}-${each.value.name}"
  )
  image        = each.value.image
  hostname     = "d_${each.value.name}"
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
  # dynamic "ports" {
  #   for_each = toset(each.value.ports)
  #   content {
  #     internal = ports.value
  #   }
  # }

  # Use a dynamic block to create volume mounts for this container.
  # Separate named Docker volumes (created via docker_volume) from host bind paths.
  # This prevents invalid index errors when a mount key is actually a host path.
  dynamic "volumes" {
    for_each = { for k, v in each.value.mounts : k => v if contains(keys(docker_volume.dynamic_resource_volume), k) }
    content {
      container_path = volumes.value
      volume_name    = docker_volume.dynamic_resource_volume[volumes.key].name
      read_only      = false
    }
  }
  dynamic "volumes" {
    for_each = { for k, v in each.value.mounts : k => v if !contains(keys(docker_volume.dynamic_resource_volume), k) }
    content {
      container_path = volumes.value
      host_path      = volumes.key
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
  count              = data.coder_workspace.me.start_count
  agent_id           = var.agent_id
  display_name       = "Dynamic Resources Proxy"
  icon               = local.icon.globe
  run_on_start       = true
  start_blocks_login = false # Don't block login, it runs in background
  script             = templatefile("${path.module}/run.sh", { PROXY_LINE = local.proxy_mappings_str })
}

# Create the Coder apps to expose the services
resource "coder_app" "dynamic_app" {
  # Only create apps if the workspace is running
  for_each = data.coder_workspace.me.start_count > 0 ? { for app in local.additional_apps : app.slug => app if app.name != null && app.name != "" && app.slug != null && app.slug != "" } : {}

  agent_id     = var.agent_id
  slug         = each.value.slug
  display_name = each.value.name
  url          = each.value.proxy_url
  icon         = each.value.icon
  share        = each.value.share
  subdomain    = true
  order        = 2
}

# Display metadata for each dynamic container showing how to reach them
resource "coder_metadata" "dynamic_container_info" {
  for_each    = data.coder_workspace.me.start_count > 0 ? local.all_containers_map : tomap({})
  resource_id = docker_container.dynamic_resource_container[each.key].id
  item {
    key   = "Hostname"
    value = each.value.name
  }
  # item {
  #   key   = "Image"
  #   value = each.value.image
  # }
  # item {
  #   key   = "Type"
  #   value = startswith(each.key, "preset-") ? "Preset" : "Custom"
  # }
}

