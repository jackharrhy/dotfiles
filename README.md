<p align="center">
  <img width="460" height="100" src="https://i.imgur.com/oht64qb.gif">
</p>

```fish
# Install chezmoi and Fish first. Profiles: drill, blue, newport, mug.
chezmoi init jackharrhy
chezmoi diff
chezmoi apply
chezmoi verify

# Run from the checkout. Apply/startup never installs or updates tools.
mise run tools:install     # Missing mise tools
mise run tools:update     # Update mise tools; op stays pinned
mise run packages:install  # Missing Brew/apt packages
mise run packages:update   # Update declared Brew/apt packages
mise run rust:install      # Stable rustup + rustfmt/Clippy; not Mug
mise run rust:update
mise run fish:install      # Missing Fisher plugins
mise run fish:update
mise run skills:install    # Restore ~/skills-lock.json into ~/.agents/skills

# Disposable fixture tests
python3 -m unittest discover -s tests -q
```
