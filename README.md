# Coder Dynamic Resources Module
This module provides a set of Coder parameters that allow users to dynamically create additional Docker containers, Docker volumes, and Coder applications at workspace creation time.

It is useful for templates where users may need optional services like databases (Redis, Postgres), web UIs, or other tools without having to hardcode them into the template.

## Features
- Dynamic Containers: Add up to 5 additional Docker containers.
- Dynamic Volumes: Create persistent Docker volumes and mount them into containers.
- Dynamic Coder Apps: Expose services running in the containers as Coder apps.
- Automatic Reverse Proxy: Automatically configures a socat reverse proxy in the main workspace container, allowing the Coder agent to access and expose services from the sidecar containers.

## Usage
**Prerequisite**: Ensure `socat` is installed in your base Docker image for the main workspace container.

Add the module to your template:

```terraform
module "dynamic_services" {
    source = "git::https://github.com/emboldagency/coder-dynamic-resources.git?ref=v1.0.0"
    agent_id = coder_agent.main.id
    docker_network_name = docker_network.workspace[0].name
    resource_name_base = local.resource_name_base
}
```

Update your main coder_agent's startup_script to include the proxy script from this module's output:

```terraform
resource "coder_agent" "main" {
# ... other agent configuration ...

startup_script = <<-EOT
    ${module.dynamic_services.startup_script_fragment}

    # Your original startup script continues here
    echo "Hello from the main script!"

EOT
}
