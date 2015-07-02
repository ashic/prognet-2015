param([Parameter(Mandatory=$true)][string]$publicDNSName,
      [Parameter(Mandatory=$true)][string]$username = "Administrator", 
      [Parameter(Mandatory=$true)][string]$password)

. ./DockerClient.ps1

function Create-CredentialObject
{ 
    param([Parameter(Mandatory=$true)][string]$username,
          [Parameter(Mandatory=$true)][string]$password)

    $securepassword = ConvertTo-SecureString $password -AsPlainText -Force
    return New-Object System.Management.Automation.PSCredential ($username, $securepassword)
}

function Run-DscDockerScript
{
    param([Parameter(Mandatory=$true)][string]$publicDNSName,
          [Parameter(Mandatory=$true)][string]$username,
          [Parameter(Mandatory=$true)][string]$password)

    $folder = resolve-path .

    Set-Item WSMan:\localhost\Client\TrustedHosts -Value $publicDNSName -Force

    $dbContainer = @{Name="db"; Image="mongo:latest"}

    DockerClient -HostName $publicDNSName -Container $dbContainer

    $credential = Create-CredentialObject -username $username -password $password

    $options = New-CimSessionOption -UseSsl:$true -SkipCACheck:$true -SkipCNCheck:$true -SkipRevocationCheck:$true
    $cimSession = New-CimSession -ComputerName $publicDNSName -Credential $credential -Port:5986 -Authentication:basic -SessionOption:$options
    Start-DscConfiguration -Verbose -wait -Path DockerClient -Force -CimSession $cimSession
}

Run-DscDockerScript -publicDNSName $publicDNSName -username $username -password $password