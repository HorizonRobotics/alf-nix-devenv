[![built with nix](https://builtwithnix.org/badge.svg)](https://builtwithnix.org)

# alf-nix-devenv

The nix-based development environment for [alf])(https://github.com/HorizonRobotics/alf).

To activate the environment with `nix`:

```
$ nix develop
```

# Other useful development environment

1. OpenAI Phasic Policy Gradient (PPG) Official Repo's Development Environment
   
   ```bash
   $ nix develop "github:HorizonRobotics#openai-ppg-dev"
   ```
   
   This is used to run [PPG](https://github.com/openai/phasic-policy-gradient) which includes the [procgen](https://openai.com/blog/procgen-benchmark/) benchmark.
