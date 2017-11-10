 @{

    AllNodes = @(

        @{
            NodeName        = "*"
        },

        @{
            NodeName        = "WebserverFull"
            Role            = "WebserverFull"
            Features        = @{"Web-Server" = "InstallIIS";"Net-Framework-Core" = "InstallNetFrameworkCore";"Web-Asp-Net45" = "InstallWebAspNet45";"Web-Mgmt-Tools" = "InstallWebMgmtTools";}
             
        },
         @{
            NodeName        = "WebserverMinimal"
            Role            = "WebserverMinimal"
            Features        = @{"Web-Server" = "InstallIIS";} 
        }
    )
}