Configuration InstallIISRoles
{
 Import-DscResource -Module PSDesiredStateConfiguration
 Import-DscResource -Module xWebAdministration
 $myFeatures = @("Web-Server","Net-Framework-Core","Web-Asp-Net45","Web-Mgmt-Tools")


    foreach ($Feature in $myFeatures)
    {
        WindowsFeature $Feature 
        { 
        Ensure = "Present" 
        Name = "$Feature" 
        }
    }
    # Create New Application Pool
    xWebAppPool IIS_NewAppPool
    {
        Name   = "NewAppPool"
        Ensure = "Present"
        State  = "Started"
        DependsOn = @('[WindowsFeature]Web-Server')
    }

    xWebsite IIS_NewWebsite
    {
        Ensure          = "Present"
        Name            = "NewWebsite"
        State           = "Started"
        PhysicalPath    = "c:\inetpub\wwwroot"
        ApplicationPool = "NewAppPool"
        DependsOn = @('[WindowsFeature]Web-Server')
        BindingInfo = @(
            MSFT_xWebBindingInformation
            {
                Protocol = "http"
                Port = 81
            }
        )
    }

    xWebApplication IIS_NewWebsiteApp
    {
        Name = "NewWebsiteApp"
        Website = "NewWebsite"
        WebAppPool =  "NewAppPool"
        PhysicalPath = "c:\inetpub\wwwroot"
        Ensure = "Present"
        DependsOn = @('[WindowsFeature]Web-Server')
    }
    # Install IIS Remote Management
    WindowsFeature Management
    {
 
        Name = 'Web-Mgmt-Service'
        Ensure = 'Present'
        DependsOn = @('[WindowsFeature]Web-Server')
    }
    # Enable IIS Remote Management
    Registry RemoteManagement
    {
        Key = 'HKLM:\SOFTWARE\Microsoft\WebManagement\Server'
        ValueName = 'EnableRemoteManagement'
        ValueType = 'Dword'
        ValueData = '1'
        DependsOn = @('[WindowsFeature]Web-Server','[WindowsFeature]Management')
    }
    # Start Remote Management Service
    Service StartWMSVC 
    {
        Name = 'WMSVC'
        StartupType = 'Automatic'
        State = 'Running'
        DependsOn = '[Registry]RemoteManagement'
 
    }
}
InstallIISRoles