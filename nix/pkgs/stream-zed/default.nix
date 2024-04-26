{ writeShellScriptBin }:

# NOTE(breakds): Ideally we should provide the runtime dependencies (gstreamer)
# and wrapGAppsNoGuiHook. However, since it is only going to be used with Hobot
# dev env, we should be fine.

writeShellScriptBin "stream-zed" (builtins.readFile ./stream-zed.sh)
