Param(
    [parameter(Mandatory = $true)]
    [string]$service_name,
    [parameter(Mandatory = $true)]
    [string]$deployment_path,
    [parameter(Mandatory = $true)]
    [string]$server,
    [parameter(Mandatory = $true)]
    [string]$service_user,
    [parameter(Mandatory = $true)]
    [SecureString]$service_password,
    [parameter(Mandatory = $true)]
    [string]$user_id,
    [parameter(Mandatory = $true)]
    [SecureString]$password,
    [parameter(Mandatory = $true)]
    [string]$cert_path
)

$display_action = 'Register Windows Service'
$display_action_past_tense = "Windows Service Registered"

Write-Output $display_action

$credential = [PSCredential]::new($user_id, $password)
$so = New-PSSessionOption -SkipCACheck -SkipCNCheck -SkipRevocationCheck
$session = New-PSSession $server -SessionOption $so -UseSSL -Credential $credential

Write-Output "Importing remote server cert..."
Import-Certificate -Filepath $cert_path -CertStoreLocation 'Cert:\LocalMachine\Root'

$script = {
    # Relies on WebAdministration Module being installed on the remote server
    # This should be pre-installed on Windows 2012 R2 and later
    # https://docs.microsoft.com/en-us/powershell/module/?term=webadministration

    # Only set this up if it hasn't been set up yet
    $exists = Get-Service -Name $Using:service_name -ErrorAction 'SilentlyContinue'

    if (!$exists) {
        $the_host = hostname
        $serviceUserId = if (($Using:service_user).Contains('\')) {
            $Using:service_user
        }
        else { "$the_host\$Using:service_user" }

        New-Object -typename System.Management.Automation.PSCredential -ArgumentList $serviceUserId, $Using:service_password

        New-Service -BinaryPathName $Using:deployment_path `
            -Name $Using:service_name `
            -DisplayName $Using:service_name `
            -Credential $service_credentials `
            -StartupType Automatic

        net start $Using:service_name
    }
}

Invoke-Command `
    -Session $session `
    -ScriptBlock $script

Write-Output "$display_action_past_tense."