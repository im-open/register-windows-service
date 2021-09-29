# Register Windows Service

This action registers a windows service on a remote windows machine.

## Index <!-- omit in toc -->

- [Inputs](#inputs)
- [Prerequisites](#prerequisites)
- [Example](#example)
- [Code of Conduct](#code-of-conduct)
- [License](#license)

## Inputs

| Parameter                     | Is Required | Description                                                                                           |
| ----------------------------- | ----------- | ----------------------------------------------------------------------------------------------------- |
| `service-name`                | true        | The name of the Windows service to register                                                           |
| `deployment-path`             | true        | The local path on the remote machine to the service executable, i.e. c:\service_directory\service.exe |
| `server`                      | true        | The name of the target server, i.e. machine.domain.com or 10.10.10.1                                  |
| `service-credential-user`     | false       | The service credential user name, i.e. domain\user_id, defaults to "NT AUTHORITY\LOCAL SYSTEM"        |
| `service-credential-password` | false       | The service credential password, this can be omitted if local system account is intended              |
| `service-account-id`          | true        | The service account name to log into the server to perform operation                                  |
| `service-account-password`    | true        | The service account password to log into the server to perform operation                              |
| `server-public-key`           | true        | Path to remote server public ssl key                                                                  |

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

## Example

```yml
...

env:
  WINDOWS_SERVER: 'win-server.domain.com'
  SERVICE_NAME: 'deploy-service'
  SERVICE_PATH: 'c:\\services\\deploy'
  WINDOWS_SERVER_SERVICE_USER: 'server_service_user'
  WINDOWS_SERVER_SERVICE_PASSWORD: '${{ secrets.SERVER_SERVICE_SECRET }}'
  WINDOWS_SERVER_CERT_PATH: './server-connection-cert.pfx'

jobs:
  Deploy-Service:
    runs-on: [windows-2019]
    steps:
      ...

      - name: Register Service
        id: register
        if: steps.deploy.outcome == 'success'
        uses: im-open/register-windows-service@v1.0.0
        with:
          service-name: '${{ env.SERVICE_NAME }}'
          deployment-path: '${{ env.SERVICE_PATH }}\\win-service.exe'
          server: '${{ env.WINDOWS_SERVER }}'
          service-account-id: '${{ env.WINDOWS_SERVER_SERVICE_USER }}'
          service-account-password: '${{ env.WINDOWS_SERVER_SERVICE_PASSWORD }}'
          server-public-key: '${{ env.WINDOWS_SERVER_CERT_PATH }}'

      ...
```

## Code of Conduct

This project has adopted the [im-open's Code of Conduct](https://github.com/im-open/.github/blob/master/CODE_OF_CONDUCT.md).

## License

Copyright &copy; 2021, Extend Health, LLC. Code released under the [MIT license](LICENSE).
