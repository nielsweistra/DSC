Configuration InstallIISRoles
{
 Import-DscResource -Module PSDesiredStateConfiguration
 Import-DscResource -Module xWebAdministration
  
     #Install the IIS Role 
    WindowsFeature IIS 
    { 
      Ensure = "Present" 
      Name = "Web-Server" 
    } 
 
    # Required for SQL Server 
    WindowsFeature installdotNet35 
    {             
        Ensure = "Present"
        Name = "Net-Framework-Core"
    }

    WindowsFeature ASP 
    {             
        Ensure = "Present"
        Name = "Web-Asp-Net45"
    }
    # Required for Webdeploy
    WindowsFeature IISManagementTools
    {
        Ensure = "Present"
        Name = "Web-Mgmt-Tools"
        DependsOn= "[WindowsFeature]IIS" 
    }
    # Create New Application Pool
    xWebAppPool IIS_NewAppPool
    {
        Name   = "NewAppPool"
        Ensure = "Present"
        State  = "Started"
        DependsOn = @('[WindowsFeature]IIS')
    }

    xWebsite IIS_NewWebsite
    {
        Ensure          = "Present"
        Name            = "NewWebsite"
        State           = "Started"
        PhysicalPath    = "c:\inetpub\wwwroot"
        ApplicationPool = "NewAppPool"
        DependsOn = @('[WindowsFeature]IIS')
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
        DependsOn = @('[WindowsFeature]IIS')
    }
    # Install IIS Remote Management
    WindowsFeature Management
    {
 
        Name = 'Web-Mgmt-Service'
        Ensure = 'Present'
        DependsOn = @('[WindowsFeature]IIS')
    }
    # Enable IIS Remote Management
    Registry RemoteManagement
    {
        Key = 'HKLM:\SOFTWARE\Microsoft\WebManagement\Server'
        ValueName = 'EnableRemoteManagement'
        ValueType = 'Dword'
        ValueData = '1'
        DependsOn = @('[WindowsFeature]IIS','[WindowsFeature]Management')
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