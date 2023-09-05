# Register Windows Service

This action registers a windows service on a remote windows machine.

## Index <!-- omit in toc -->

- [Register Windows Service](#register-windows-service)
  - [Inputs](#inputs)
  - [Prerequisites](#prerequisites)
  - [Usage Examples](#usage-examples)
  - [Contributing](#contributing)
    - [Incrementing the Version](#incrementing-the-version)
    - [Source Code Changes](#source-code-changes)
    - [Updating the README.md](#updating-the-readmemd)
  - [Code of Conduct](#code-of-conduct)
  - [License](#license)

## Inputs

| Parameter           | Is Required | Description                                                                                             |
|---------------------|-------------|---------------------------------------------------------------------------------------------------------|
| `service-name`      | true        | The name of the Windows service to register                                                             |
| `deployment-path`   | true        | The local path on the remote machine to the service executable, i.e. `c:\service_directory\service.exe` |
| `server`            | true        | The name of the target server, i.e. `machine.domain.com` or `10.10.10.1`                                |
| `run-time-id`       | false       | The run-time service credential user id, i.e. `domain\user_id`, defaults to `NT AUTHORITY\LOCAL SYSTEM` |
| `run-time-secret`   | false       | The run-time service credential secret, this can be omitted if local system account is going to be used |
| `deployment-id`     | true        | The deployment service account id to log into the server to register the service                        |
| `deployment-secret` | true        | The deployment service account secret to log into the server to register the service                    |

## Prerequisites

The register windows service action uses Web Services for Management, [WSMan], and Windows Remote Management, [WinRM], to create remote administrative sessions. Because of this, Windows OS GitHubs Actions Runners, `runs-on: [windows-2019]`, must be used. If the file deployment target is on a local network that is not publicly available, then specialized self hosted runners, `runs-on: [self-hosted, windows-2019]`,  will need to be used to broker deployment time access.

Inbound secure WinRm network traffic (TCP port 5986) must be allowed from the GitHub Actions Runners virtual network so that remote sessions can be received.

Prep the remote Windows server to accept WinRM management calls.  In general the Windows server needs to have a [WSMan] listener that looks for incoming [WinRM] calls. Firewall exceptions need to be added for the secure WinRM TCP ports, and non-secure firewall rules should be disabled. Here is an example script that would be run on the Windows server:

  ```powershell
  $Cert = New-SelfSignedCertificate -CertstoreLocation Cert:\LocalMachine\My -DnsName <<ip-address|fqdn-host-name>>

  Export-Certificate -Cert $Cert -FilePath C:\temp\<<cert-name>>

  Enable-PSRemoting -SkipNetworkProfileCheck -Force

  # Check for HTTP listeners
  dir wsman:\localhost\listener

  # If HTTP Listeners exist, remove them
  Get-ChildItem WSMan:\Localhost\listener | Where -Property Keys -eq "Transport=HTTP" | Remove-Item -Recurse

  # If HTTPs Listeners don't exist, add one
  New-Item -Path WSMan:\LocalHost\Listener -Transport HTTPS -Address * -CertificateThumbPrint $Cert.Thumbprint –Force

  # This allows old WinRm hosts to use port 443
  Set-Item WSMan:\localhost\Service\EnableCompatibilityHttpsListener -Value true

  # Make sure an HTTPs inbound rule is allowed
  New-NetFirewallRule -DisplayName "Windows Remote Management (HTTPS-In)" -Name "Windows Remote Management (HTTPS-In)" -Profile Any -LocalPort 5986 -Protocol TCP

  # For security reasons, you might want to disable the firewall rule for HTTP that *Enable-PSRemoting* added:
  Disable-NetFirewallRule -DisplayName "Windows Remote Management (HTTP-In)"
  ```

- `ip-address` or `fqdn-host-name` can be used for the `DnsName` property in the certificate creation. It should be the name that the actions runner will use to call to the Windows server.
- `cert-name` can be any name.  This file will used to secure the traffic between the actions runner and the Windows server

## Usage Examples

```yml
...

env:
  SERVICE_NAME: 'deploy-service'
  DEPLOYMENT_PATH: 'c:\services\deploy\win-service.exe'
  SERVER: 'win-server.domain.com'
  RUN_TIME_ID: 'run_time_id'
  RUN_TIME_SECRET: '${{ secrets.run_time_secret }}'
  DEPLOYMENT_ID: 'deployment_id'
  DEPLOYMENT_SECRET: '${{ secrets.deployment_secret }}'

jobs:
  Deploy-Service:
    runs-on: [windows-2019]
    steps:
      ...

      - name: Register Service
        id: register
        if: steps.deploy.outcome == 'success'
        # You may also reference the major or major.minor version
        uses: im-open/register-windows-service@v3.0.1
        with:
          service-name: '${{ env.SERVICE_NAME }}'
          deployment-path: '${{ env.DEPLOYMENT_PATH }}'
          server: '${{ env.SERVER }}'
          run-time-id: '${{ env.RUN_TIME_ID }}'
          run-time-secret: '${{ env.RUN_TIME_SECRET }}'
          deployment-id: '${{ env.DEPLOYMENT_ID }}'
          deployment-secret: '${{ env.DEPLOYMENT_SECRET }}'

      ...
```

## Contributing

When creating PRs, please review the following guidelines:

- [ ] The action code does not contain sensitive information.
- [ ] At least one of the commit messages contains the appropriate `+semver:` keywords listed under [Incrementing the Version] for major and minor increments.
- [ ] The README.md has been updated with the latest version of the action.  See [Updating the README.md] for details.

### Incrementing the Version

This repo uses [git-version-lite] in its workflows to examine commit messages to determine whether to perform a major, minor or patch increment on merge if [source code] changes have been made.  The following table provides the fragment that should be included in a commit message to active different increment strategies.

| Increment Type | Commit Message Fragment                     |
|----------------|---------------------------------------------|
| major          | +semver:breaking                            |
| major          | +semver:major                               |
| minor          | +semver:feature                             |
| minor          | +semver:minor                               |
| patch          | *default increment type, no comment needed* |

### Source Code Changes

The files and directories that are considered source code are listed in the `files-with-code` and `dirs-with-code` arguments in both the [build-and-review-pr] and [increment-version-on-merge] workflows.  

If a PR contains source code changes, the README.md should be updated with the latest action version.  The [build-and-review-pr] workflow will ensure these steps are performed when they are required.  The workflow will provide instructions for completing these steps if the PR Author does not initially complete them.

If a PR consists solely of non-source code changes like changes to the `README.md` or workflows under `./.github/workflows`, version updates do not need to be performed.

### Updating the README.md

If changes are made to the action's [source code], the [usage examples] section of this file should be updated with the next version of the action.  Each instance of this action should be updated.  This helps users know what the latest tag is without having to navigate to the Tags page of the repository.  See [Incrementing the Version] for details on how to determine what the next version will be or consult the first workflow run for the PR which will also calculate the next version.

## Code of Conduct

This project has adopted the [im-open's Code of Conduct](https://github.com/im-open/.github/blob/main/CODE_OF_CONDUCT.md).

## License

Copyright &copy; 2023, Extend Health, LLC. Code released under the [MIT license](LICENSE).

<!-- Links -->
[Incrementing the Version]: #incrementing-the-version
[Updating the README.md]: #updating-the-readmemd
[source code]: #source-code-changes
[usage examples]: #usage-examples
[build-and-review-pr]: ./.github/workflows/build-and-review-pr.yml
[increment-version-on-merge]: ./.github/workflows/increment-version-on-merge.yml
[git-version-lite]: https://github.com/im-open/git-version-lite
