Param(
    [parameter(Mandatory = $true)]
    [string]$service_name,
    [parameter(Mandatory = $true)]
    [string]$deployment_path,
    [parameter(Mandatory = $true)]
    [string]$server,
    [parameter(Mandatory = $true)]
    [string]$run_time_id,
    [parameter(Mandatory = $true)]
    [SecureString]$run_time_secret,
    [parameter(Mandatory = $true)]
    [string]$deployment_id,
    [parameter(Mandatory = $true)]
    [SecureString]$deployment_secret
)

$display_action = 'Register Windows Service'
$display_action_past_tense = "Windows Service Registered"

Write-Output $display_action

$credential = [PSCredential]::new($deployment_id, $deployment_secret)
$so = New-PSSessionOption -SkipCACheck -SkipCNCheck -SkipRevocationCheck
$session = New-PSSession $server -SessionOption $so -UseSSL -Credential $credential

$script = {
    # Relies on WebAdministration Module being installed on the remote server
    # This should be pre-installed on Windows 2012 R2 and later
    # https://docs.microsoft.com/en-us/powershell/module/?term=webadministration

    # Only set this up if it hasn't been set up yet
    $exists = Get-Service -Name $Using:service_name -ErrorAction 'SilentlyContinue'

    if (!$exists) {
        $the_host = hostname
        $serviceUserId = if (($Using:run_time_id).Contains('\')) {
            $Using:run_time_id
        }
        else { "$the_host\$Using:run_time_id" }

        $service_credentials = New-Object -typename System.Management.Automation.PSCredential -ArgumentList $serviceUserId, $Using:run_time_secret

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