# setup-cli

GitHub Action to install the [Mergify CLI](https://pypi.org/project/mergify-cli/)
(`mergify-cli`) with version pinning and Renovate autoupdate.

It sets up Python, installs `uv`, then installs `mergify-cli` (pinned by default,
`latest` supported) and exposes the resolved version as an output.

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
| `mergify_cli_version` | string | false | `2026.6.8.1` | Version of mergify-cli to install. Use `latest` to install the latest released version without pinning. |
| `python_version` | string | false | `3.14` | Python version to set up for the install (passed to actions/setup-python). |

<!-- AUTO-DOC-INPUT:END -->

## Outputs

| Output | Description |
| --- | --- |
| `mergify_cli_version` | The `mergify-cli` version that was installed. Resolved from the installed package metadata, so it reflects the real version even when `latest` or an empty input was requested. |
