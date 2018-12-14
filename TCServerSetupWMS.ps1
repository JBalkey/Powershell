param(
    [string]$ensure,
    [string]$tfsserver
)

Configuration CTLNewWebsite
{ 

 
  Import-DscResource -Module PSDesiredStateConfiguration, xPendingReboot, xNetworking

  node localhost
  {
        xFirewallProfile FirewallProfilePrivate
        {
            Name = 'Domain'
            Enabled = 'False'
        }   
        Package Visualc++201732
        {
            Ensure      = $ensure
            Path        = "c:\software\VC_redist.x86.2017.exe"
            Name        = "Microsoft Visual C++ 2017 x86"
            ProductId   = "8F271F6C-6E7B-3D0A-951B-6E7B694D78BD"
            Arguments   = "/quiet"
        }
        Package Visualc++201764
        {
            Ensure      = $ensure
            Path        = "c:\software\VC_redist.x64.2017.exe"
            Name        = "Microsoft Visual C++ 2017 x64"
            ProductId   = "221D6DB4-46E2-333C-B09B-5F49351D0980"
            Arguments   = "/quiet"
        }	
        Package VisualStudio2010
        {
            Ensure      = "Present"
            Path        = "c:\software\vstor_redist.exe"
            Name        = "Microsoft Visual Studio 2010 Tools for Office Runtime (x64)"
            ProductId   = "7C0242A3-8B66-35D1-9FE0-13B426ACB609"
            Arguments   = "/quiet"
        } 
        #Package ASP.NETMVC4
        #{
        #    Ensure      = "Present"
        #    Path        = "c:\software\AspNetMVC4Setup.exe"
        #    Name        = "Microsoft ASP.NET MVC 4 Runtime"
        #    ProductId   = "3FE312D5-B862-40CE-8E4E-A6D8ABF62736"
        #    Arguments   = "/quiet"
        #} 
        #Package ASP.NETMVC3
        #{
        #    Ensure      = "Present"
        #    Path        = "c:\software\AspNetMVC3ToolsUpdateSetup.exe"
        #    Name        = "Microsoft ASP.NET MVC 3"
        #    ProductId   = "D32EF103-4016-4C15-BCB0-700C0A7A2309"
        #    Arguments   = "/quiet"
        #} 
        WindowsFeature IIS {
            Ensure = "present"
            Name = "Web-Server"
        }
        WindowsFeature IIS-Common {
            Ensure = "present"
            Name = "Web-Http-Redirect"
        }
        WindowsFeature IIS-Health {
            Ensure = "present"
            Name = "Web-Request-Monitor"
        }
        WindowsFeature IIS-Security1 {
            Ensure = "present"
            Name = "Web-Basic-Auth"
        }
        WindowsFeature IIS-Security2 {
            Ensure = "present"
            Name = "Web-IP-Security"
        }
        WindowsFeature IIS-Security3 {
            Ensure = "present"
            Name = "Web-Windows-Auth"
        }
        WindowsFeature IIS-App1 {
            Ensure = "present"
            Name = "Web-AppInit"
        }
        WindowsFeature IIS-App2 {
            Ensure = "present"
            Name = "Web-CGI"
        }
        WindowsFeature IIS-App3 {
            Ensure = "present"
            Name = "Web-Includes"
        }
        WindowsFeature IIS-App4 {
            Ensure = "present"
            Name = "Web-WebSockets"
        }
        WindowsFeature IIS-Mgmt1 {
            Ensure = "present"
            Name = "Web-Mgmt-Tools"
        }
        WindowsFeature IIS-Mgmt2 {
            Ensure = "present"
            Name = "Web-Mgmt-Service"
        }
        WindowsFeature ASPNET {
            Ensure = "present"
            Name = "Web-ASP"
        }
        WindowsFeature NET3 {
            Ensure = "present"
            Name = "NET-Framework-Features"
            source = "\\" + $tfsserver + "\sources\sxs"
        }
        WindowsFeature ASP { 
            Ensure = “present” 
            Name = “Web-Asp-Net” 
        }
        WindowsFeature ASP45 { 
            Ensure = “present” 
            Name = “Web-Asp-Net45” 
        }
        #WindowsFeature Ink { 
        #    Ensure = “present” 
        #    Name = “InkAndHandwritingServices” 
        #}
        WindowsFeature Media { 
            Ensure = “present” 
            Name = “Server-Media-Foundation” 
        }
        #WindowsFeature Desktop { 
        #    Ensure = “present” 
        #    Name = “Desktop-Experience” 
        #}
        LocalConfigurationManager 
        { 
        CertificateID       = $Thumbprint
	    ActionAfterReboot   = 'ContinueConfiguration'
	    ConfigurationMode   = 'ApplyOnly'
	    RebootNodeIfNeeded  = $True
	    RefreshMode	        = 'Push'
        } 
    } 
}

$cd = @{
    AllNodes = @(
        @{
            NodeName = 'localhost'
        }
    )
}

$Thumbprint = (Get-ChildItem -Path Cert:\LocalMachine\My | Where-Object {$_.EnhancedKeyUsageList -match "Document Encryption"}).Thumbprint

CTLNewWebSite -ConfigurationData $cd -OutputPath C:\Scripts\MofTest

Set-DscLocalConfigurationManager C:\Scripts\MofTest -Verbose -Force

Start-DSCConfiguration -Path C:\Scripts\MofTest -Wait -Verbose -Force