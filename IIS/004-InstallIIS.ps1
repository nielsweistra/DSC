Configuration InstallIISRoles
{
 Import-DscResource -Module PSDesiredStateConfiguration
 Import-DscResource -Module xWebAdministration
 
  Node $AllNodes.Nodename
   {
    foreach ($Feature in $Node.Features.GetEnumerator())
    {
    
        WindowsFeature $Feature.Value
        { 
        Ensure = "Present" 
        Name =  $Feature.Name
        }
    }
    # Create New Application Pool
    xWebAppPool IIS_NewAppPool
    {
        Name   = "NewAppPool"
        Ensure = "Present"
        State  = "Started"
    }

    xWebsite IIS_NewWebsite
    {
        Ensure          = "Present"
        Name            = "NewWebsite"
        State           = "Started"
        PhysicalPath    = "c:\inetpub\wwwroot"
        ApplicationPool = "NewAppPool"
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
    }
    # Install IIS Remote Management
    WindowsFeature Management
    {
 
        Name = 'Web-Mgmt-Service'
        Ensure = 'Present'
    }
    # Enable IIS Remote Management
    Registry RemoteManagement
    {
        Key = 'HKLM:\SOFTWARE\Microsoft\WebManagement\Server'
        ValueName = 'EnableRemoteManagement'
        ValueType = 'Dword'
        ValueData = '1'
        DependsOn = @('[WindowsFeature]Management')
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
}
InstallIISRoles -ConfigurationData installIISRoles.psd1