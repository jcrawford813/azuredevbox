# A Distrobox Image for Azure Development

This is a custom distrobox image that comes pre-loaded with Azure development tools that I have found useful. The current tooling includes:

- Visual Studio Code
- Azure CLI
- Azure Data Studio
- Python and PiP
- Terraform

The image is based on Debian Stable, and has the Microsoft package libraries set up.

This repo and image creation is based off of [boxkit](https://github.com/ublue-os/boxkit). It is much simplified.

## Usage
The image may be installed via the distrobox command:
```
distrobox create -i ghcr.io/jcrawford813/azuredevbox:latest --pull
distrobox enter azuredevbox
```

If desired, shortcuts may be exported for the tools:

```
distrobox-export --app code
distrobox-export --app azuredatastudio
```

## Updating

THe image will rebuild once per week with the latest updates. However, once installed within distrobox, it is suggested that you update via the distrobox command:

```
distrobox upgrade --all
```