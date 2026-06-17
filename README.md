# setup-cli

GitHub Action to install the [Mergify CLI](https://github.com/Mergifyio/mergify-cli)
(`mergify-cli`) with version pinning and Renovate autoupdate.

It installs the prebuilt `mergify` binary via the mergify-cli `install.sh`
installer, which downloads the binary from the GitHub release and verifies it
against the release `SHA256SUMS`. For a pinned version the installer is fetched
from that release tag; `latest` uses `main`. The action then puts the binary on
`PATH` and exposes the installed version as an output. Pinned by default,
`latest` supported. No Python or toolchain is required; Linux and macOS are
supported.

More information on https://mergify.com

## Usage

Pin the action to a released major (see the [releases](https://github.com/Mergifyio/setup-cli/releases)):

```yaml
- uses: Mergifyio/setup-cli@v1

- run: mergify --version
```

Pin a specific `mergify-cli` version, or install the latest one:

```yaml
- uses: Mergifyio/setup-cli@v1
  id: setup-cli
  with:
    mergify_cli_version: latest

- run: echo "Installed mergify-cli ${{ steps.setup-cli.outputs.mergify_cli_version }}"
```

## Inputs

<!-- AUTO-DOC-INPUT:START - Do not remove or modify this section -->

| Input | Type | Required | Default | Description |
| --- | --- | --- | --- | --- |
| `mergify_cli_version` | string | false | `2026.6.16.1` | Version of mergify-cli to install. Use `latest` to install the latest released version without pinning. |

<!-- AUTO-DOC-INPUT:END -->

## Outputs

| Output | Description |
| --- | --- |
| `mergify_cli_version` | The `mergify-cli` version that was installed. Read back from the installed binary, so it reflects the real version even when `latest` or an empty input was requested. |
