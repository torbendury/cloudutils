# torbendury/cloudutils

The last CI image you will need for cloud stuff (except AWS, at least for now).

Contains all the juice needed for

- Infrastructure Automation with Terraform
- FinOps perfection with infracost
- Kubernetes juggling with Helm
- Microsoft Azure
- Google Cloud Platform

all baked into one container image.

*Hint: If you didn't know yet, this container image is highly opinionated and might not exactly fit your use case. This is fine! Go and steal the `Dockerfile` or if you only need additional tooling just start your own one with `FROM torbendury/cloudutils:latest`.*

## Tools included

- `azure-cli`
- `git`
- `golang`
- `gcloud` with add-ons
- `driftctl`
- `kubectl`
- `jq`, `jo` and `yq` for everyones' cup of tea
- `python3.12`
- `hcl2json`
- `helm` with `helm-diff` plugin

## Maintenance

This image builds every night to contain the latest, hottest stuff. If you don't like this, feel free to take the `Dockerfile` and surround it with your personal versioning preferences.

However, if you happen to *do* like this, you've come to the right place to enjoy your hot ride. Just `docker pull torbendury/cloudutils:latest` locally, in your CI or elsewhere and utilize the power it contains! No need for 3000 separated single-responsibility images which will blow your disk space and blow your mind thinking how to combine your `myci/yq` container with `myci/gcloud` container. Blow up your disk space with a single `docker pull torbendury/cloudutils:latest` and live happily ever after!

## Props

Except for plugging stuff together in a mostly senseful way, I don't own any credits for this. Instead, you might want to thank the FOSS giants:

- [Helm](https://helm.sh)
  - One of the greatest Kubernetes application package managers.
- [mikefarah/yq](https://github.com/mikefarah/yq)
  - `jq` for YAML fans.
- [tmccombs/hcl2json](https://github.com/tmccombs/hcl2json)
  - Converting `hcl` to JSON for non-golang-tools.
- [infracost/infracost](https://github.com/infracost/infracost)
  - See cost before it occurs.
- [jqlang/jq](https://github.com/jqlang/jq)
  - `yq` for JSON fans.
- [oras-project/oras](https://github.com/oras-project/oras)
  - Client CLI for interacting with OCI registries.
- [tfutils/tfenv](https://github.com/tfutils/tfenv)
  - You will learn to love `tfenv` when working with multiple repositories based on different Terraform versions.

And many more, like:

- `pre-commit` for running the naggy parts of your CI locally and keeping your repo at health.
- `checkov` for checking that your code is nearly bulletproof (or at least doesn't let the bad guy enter on the front door).
- `azure-cli` for letting your container image grow gigabytes by some simple Python wrappers around Rest APIs.
- `gcloud` for doing the exact same thing but with another set of APIs being wrapped.

## License

I choose [MIT License](LICENSE) because I wanted it simple and permissive.

This repo - in respect, its CI - creates a container images which contains a truckload of software. If you think I did something wrong here regarding licensing, please [raise a GitHub Issue](https://github.com/torbendury/cloudutils/issues/new?template=Blank+issue).
