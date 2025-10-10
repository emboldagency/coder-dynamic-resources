output "startup_script_fragment" {
  description = "A shell script fragment to be inserted into the main coder_agent startup script. Sets up socat reverse proxies."
  value = <<-EOT
    # --- START DYNAMIC SERVICES PROXY SCRIPT ---
    set +e
    PROXY_LINE="${local.proxy_mappings_str}"
    if [[ -n "$PROXY_LINE" ]]; then
      if ! command -v socat >/dev/null 2>&1; then
        echo "ERROR: socat command not found; please install socat in the base image to use the reverse proxy." >&2
      else
        RUNDIR="$${XDG_RUNTIME_DIR:-/tmp}/reverse-proxy"
        mkdir -p "$RUNDIR" || true
        for m in $PROXY_LINE; do
          local_port="$${m%%:*}"
          rest="$${m#*:}"
          remote_host="$${rest%%:*}"
          remote_port="$${rest##*:}"
          echo "Starting proxy: localhost:$local_port -> $remote_host:$remote_port"
          nohup socat TCP-LISTEN:$local_port,reuseaddr,fork TCP:$remote_host:$remote_port >"$RUNDIR/reverse-proxy-$local_port.log" 2>&1 &
        done
      fi
    fi
    set -e
    # --- END DYNAMIC SERVICES PROXY SCRIPT ---
  EOT
}
