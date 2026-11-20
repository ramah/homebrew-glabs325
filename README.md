# Homebrew tap for GLabs325

Mac apps for developers, published by [GLabs325](https://glabs325.com).

| App | What it does | Install |
| --- | --- | --- |
| [Ramille](https://ramille.app) | A Git client for Mac that shows what you are about to push and the conflicts to expect, before you do it. | `brew install --cask ramah/glabs325/ramille` |
| [LocalePilot](https://localepilot.app) | A Mac app that translates your app's ARB, i18next JSON and String Catalog files and checks placeholders and plurals before export. | `brew install --cask ramah/glabs325/localepilot` |

Both apps are commercial software with a free 14-day trial (14 days of use, no credit card). Prices, licenses and requirements are on each app's website.

## Requirements

- [Homebrew](https://brew.sh) on a Mac.
- Ramille needs macOS 12 or later. LocalePilot needs macOS 13 or later.

## Trust (Homebrew 6 and later)

Homebrew asks you to trust third-party taps. Installing by full name, as in the table above, trusts only that cask. If you add the tap first with `brew tap ramah/glabs325`, trust the cask you want before installing it:

```sh
brew trust --cask ramah/glabs325/ramille
brew trust --cask ramah/glabs325/localepilot
```

## Updates

Both apps update themselves through Sparkle. Homebrew also tracks new versions: `brew upgrade --cask ramille` or `brew upgrade --cask localepilot` installs the latest release published in the repositories below.

## Uninstall

```sh
brew uninstall --cask ramille
brew uninstall --cask localepilot
```

Add `--zap` to also remove the app's local data.

## Where the downloads come from

The casks download the signed and notarized disk images from the public release repositories [ramah/ramille-releases](https://github.com/ramah/ramille-releases) and [ramah/localepilot-releases](https://github.com/ramah/localepilot-releases). This repository contains only the cask files.

## For maintainers

After a new release is published in the release repository, update the cask with:

```sh
scripts/update-cask.sh ramille 1.0.1 1000123   # version, then build number (tag v1.0.1-b1000123)
scripts/update-cask.sh localepilot 1.0.1       # tag v1.0.1
```

The script downloads the published disk image, computes its SHA-256 and rewrites the `version` and `sha256` lines. It never opens the image, and it does not commit: review `git diff`, then commit and push.

## Contact

[ramille@glabs325.com](mailto:ramille@glabs325.com) · [localepilot@glabs325.com](mailto:localepilot@glabs325.com)
