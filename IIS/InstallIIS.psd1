 @{

    AllNodes = @(

        @{
            NodeName        = "*"
        },

        @{
            NodeName        = "Webserver-Full"
            Role            = "Webserver"
            Features        = @{"Web-Server" = "InstallIIS";"Net-Framework-Core" = "InstallNetFrameworkCore";"Web-Asp-Net45" = "InstallWebAspNet45";"Web-Mgmt-Tools" = "InstallWebMgmtTools";} 
        },
         @{
            NodeName        = "Webserver-Minimal"
            Role            = "Webserver"
            Features        = @{"Web-Server" = "InstallIIS";} 
        }
    )
}