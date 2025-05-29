-- Disable auto-switching to newly plugged-in devices
table.insert(alsa_monitor.rules, {
  matches = {
    {
      { "node.name", "matches", "alsa_output.*" }
    }
  },
  apply_properties = {
    ["device.auto_switch"] = false
  }
}) 