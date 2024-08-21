[![built with nix](https://builtwithnix.org/badge.svg)](https://builtwithnix.org)

# alf-nix-devenv

The nix-based development environment for [alf])(https://github.com/HorizonRobotics/alf).

To activate the environment with `nix`:

```
$ nix develop
```

# To update the alf dependency
Run the following to pull in new alf changes into nix dev env:

1. Update alf branch:

```bash
cd ~/alf
git checkout pytorch
git pull
git checkout PR/breakds/alf_packaged_new # or alf_packaged (for older alf with running stats change reverted)
git rebase pytorch  # resolve conflicts as needed
git push --force
```

2. Update alf dependency for alf-nix-devenv

```bash
git rebase
cd ~/projects/alf-nix-devenv
nix flake lock --update-input alf
```

3. Start the new devenv:

```bash
cd ~/Hobot
nix develop --option binary-caches "https://cache.nixos.org/" ~/projects/alf-nix-devenv#hobot-dev
```

NOTE: If direnv is installed, simply press Enter to activate new hobot devenv.

NOTE: --option binary-caches "https://cache.nixos.org/" is only needed when the local binary cache server fails to respond.

# Other useful development environment

1. OpenAI Phasic Policy Gradient (PPG) Official Repo's Development Environment
   
   ```bash
   $ nix develop "github:HorizonRobotics#openai-ppg-dev"
   ```
   
   This is used to run [PPG](https://github.com/openai/phasic-policy-gradient) which includes the [procgen](https://openai.com/blog/procgen-benchmark/) benchmark.
