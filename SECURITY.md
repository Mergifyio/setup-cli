# Security Policy

This policy covers the `Mergifyio/setup-cli` GitHub Action published in this
repository. The CLI it installs and the installer it runs (`install.sh`) live
in [Mergifyio/mergify-cli](https://github.com/Mergifyio/mergify-cli), which
has its own policy; reports for either go to the same place.

## Reporting a vulnerability

Please do not report security vulnerabilities through public GitHub issues,
discussions or pull requests.

Report them privately through Mergify's bug bounty program on HackerOne:
<https://hackerone.com/mergify>. For other security questions, write to
<security@mergify.com>.

A useful report says which version of the action you used (the `uses:` line
of your workflow), how to reproduce the issue and what an attacker gains
from it.

Mergify's vulnerability disclosure policy is published at
<https://docs.mergify.com/security/#vulnerability-disclosure>.

## Supported versions

Security fixes ship in a new `vX.Y.Z` release of the action, and the major
tag (`v1`) moves to it. Workflows that use `Mergifyio/setup-cli@v1` pick the
fix up on their next run; workflows pinned to a full version or a commit SHA
need to bump it.
