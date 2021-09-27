# composite-run-steps-action-template

This template can be used to quickly start a new custom composite-run-steps action repository.  Click the `Use this template` button at the top to get started.

## TODOs
- Readme
  - [ ] Update the Inputs section with the correct action inputs
  - [ ] Update the Outputs section with the correct action outputs
  - [ ] Update the Example section with the correct usage
- action.yml
  - [ ] Fill in the correct name, description, inputs and outputs and implement steps
- CODEOWNERS
  - [ ] Update as appropriate
- Repository Settings
  - [ ] On the *Options* tab check the box to *Automatically delete head branches*
  - [ ] On the *Options* tab update the repository's visibility
  - [ ] On the *Branches* tab add a branch protection rule
    - [ ] Check *Require pull request reviews before merging*
    - [ ] Check *Dismiss stale pull request approvals when new commits are pushed*
    - [ ] Check *Require review from Code Owners*
    - [ ] Check *Include Administrators*
  - [ ] On the *Manage Access* tab add the appropriate groups
- About Section (accessed on the main page of the repo, click the gear icon to edit)
  - [ ] The repo should have a short description of what it is for
  - [ ] Add one of the following topic tags:
    | Topic Tag       | Usage                                    |
    | --------------- | ---------------------------------------- |
    | az              | For actions related to Azure             |
    | code            | For actions related to building code     |
    | certs           | For actions related to certificates      |
    | db              | For actions related to databases         |
    | git             | For actions related to Git               |
    | iis             | For actions related to IIS               |
    | microsoft-teams | For actions related to Microsoft Teams   |
    | svc             | For actions related to Windows Services  |
    | jira            | For actions related to Jira              |
    | meta            | For actions related to running workflows |
    | pagerduty       | For actions related to PagerDuty         |
    | test            | For actions related to testing           |
    | tf              | For actions related to Terraform         |
  - [ ] Add any additional topics for an action if they apply


## Inputs

| Parameter                     | Is Required | Description                                                                                           |
| ----------------------------- | ----------- | ----------------------------------------------------------------------------------------------------- |
| `service-name`                | true        | The name of the Windows service to register                                                           |
| `deployment-path`             | true        | The local path on the remote machine to the service executable, i.e. c:\service_directory\service.exe |
| `server`                      | true        | The name of the target server, i.e. machine.domain.com or 10.10.10.1                                  |
| `service-credential-user`     | false       | The service credential user name, i.e. domain\user_id                                                 |
| `service-credential-password` | false       | The service credential password                                                                       |
| `service-account-id`          | true        | The service account name to log into the server to perform operation                                  |
| `service-account-password`    | true        | The service account password to log into the server to perform operation                              |
| `server-public-key`           | true        | Path to remote server public ssl key                                                                  |

## Example

```yml
# TODO: Fill in the correct usage
jobs:
  job1:
    runs-on: [self-hosted]
    steps:
      - uses: actions/checkout@v2

      - name: Add the action here
        uses: im-open/this-repo@v1.0.0
        with:
          input-1: 'abc'
          input-2: '123
```


## Code of Conduct

This project has adopted the [im-open's Code of Conduct](https://github.com/im-open/.github/blob/master/CODE_OF_CONDUCT.md).

## License

Copyright &copy; 2021, Extend Health, LLC. Code released under the [MIT license](LICENSE).
