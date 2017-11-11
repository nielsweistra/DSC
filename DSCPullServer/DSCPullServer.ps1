configuration DscPullServer
{ 
    param  
    ( 
            [string[]]$NodeName = "localhost", 

            [ValidateNotNullOrEmpty()] 
            [string] $certificateThumbPrint,

            [Parameter(Mandatory)]
            [ValidateNotNullOrEmpty()]
            [string] $RegistrationKey 
     ) 

     Import-DSCResource -ModuleName xPSDesiredStateConfiguration
     Import-DSCResource –ModuleName PSDesiredStateConfiguration

     Node $NodeName 
     { 
         WindowsFeature DSCServiceFeature 
         { 
             Ensure = "Present"
             Name   = "DSC-Service"            
         } 

         xDscWebService PSDSCPullServer 
         { 
             Ensure                   = "Present"
             EndpointName             = "PSDSCPullServer"
             Port                     = 8080 
             PhysicalPath             = "$env:SystemDrive\inetpub\PSDSCPullServer" 
             CertificateThumbPrint    = $certificateThumbPrint          
             ModulePath               = "$env:PROGRAMFILES\WindowsPowerShell\DscService\Modules" 
             ConfigurationPath        = "$env:PROGRAMFILES\WindowsPowerShell\DscService\Configuration" 
             State                    = "Started"
             DependsOn                = "[WindowsFeature]DSCServiceFeature"    
             UseSecurityBestPractices = $false
         }
         xDscWebService PSDSCComplianceServer
         {
            Ensure                 = "Present"
            EndpointName           = "PSDSCComplianceServer"
            Port                   = 9080
            PhysicalPath           = "$env:SystemDrive\inetpub\PSDSCComplianceServer"
            CertificateThumbPrint  = "AllowUnencryptedTraffic"
            State                  = "Started"
            DependsOn              = ("[WindowsFeature]DSCServiceFeature","[xDSCWebService]PSDSCPullServer")
            UseSecurityBestPractices = $false
         }

        File RegistrationKeyFile
        {
            Ensure          = "Present"
            Type            = "File"
            DestinationPath = "$env:ProgramFiles\WindowsPowerShell\DscService\RegistrationKeys.txt"
            Contents        = $RegistrationKey
        }
    }
}
DSCPullServer -certificateThumbprint 'DD2AD96BFFB8E713F836EDD6E38D0D27F9407B95' -RegistrationKey '950a952b-b9d6-406b-b416-e0f759c9c0e4' -OutputPath c:\Configs\PullServer