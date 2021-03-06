configuration DscEx2
{
    param ([string[]]$computerName = 'localhost')

    Node $computerName
    {
        File Just-Eat-Root { Type = "Directory"; DestinationPath = "C:\deployment"; Ensure = "Present"; }

        Environment Just-Eat-Env { Name = "deployment_root"; Value = "C:\deployment"; Ensure = "Present"; DependsOn = "[File]Just-Eat-Root" }

        Service Disable-WSUS { Name = "wuauserv"; State = "Stopped"; StartupType = "Disabled"; }

        WindowsFeature Web-AppInit { Ensure = 'Present'; Name = 'Web-AppInit' }
        WindowsFeature Web-Asp-Net45 { Ensure = 'Present'; Name = 'Web-Asp-Net45' }
        WindowsFeature Web-Server { Ensure = 'Present'; Name = 'Web-Server' }
        WindowsFeature Web-WebSockets { Ensure = 'Present'; Name = 'Web-WebSockets' }
    }
}