<#PSScriptInfo
.VERSION 1.0
.GUID 86c0280c-6b48-4689-815d-5bc0692845a4
.AUTHOR Microsoft Corporation
.COMPANYNAME Microsoft Corporation
.COPYRIGHT (c) Microsoft Corporation. All rights reserved.
.TAGS DSCConfiguration
.LICENSEURI https://github.com/PowerShell/ActiveDirectoryDsc/blob/master/LICENSE
.PROJECTURI https://github.com/PowerShell/ActiveDirectoryDsc
.ICONURI
.EXTERNALMODULEDEPENDENCIES
.REQUIREDSCRIPTS
.EXTERNALSCRIPTDEPENDENCIES
.RELEASENOTES
.PRIVATEDATA
#>

#Requires -module ActiveDirectoryDsc

<#
    .DESCRIPTION
        This configuration will create a new domain with a new forest and a forest
        functional level of Server 2016.
#>

Configuration NewForest_Config
{
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]
        $DomainAdministratorCredential
    )

    Import-DscResource -ModuleName PSDscResources
    Import-DscResource -ModuleName ActiveDirectoryDsc

    node $AllNodes.NodeName
    {
        WindowsFeature 'ADDS'
        {
            Name   = 'AD-Domain-Services'
            Ensure = 'Present'
        }

        WindowsFeature 'RSAT'
        {
            Name   = 'RSAT-AD-PowerShell'
            Ensure = 'Present'
        }

        xADDomain $Node.DomainName
        {
            DomainName                    = $Node.DomainName
            DomainAdministratorCredential = $DomainAdministratorCredential
            SafemodeAdministratorPassword = $DomainAdministratorCredential
            ForestMode                    = $Node.FFL
        }
    }
}

$ConfigurationData = @{
    AllNodes = @(
        @{
            NodeName   = 'localhost'
            FFL        = 'WinThreshold'
            DomainName = 'contoso.com'
        }
    )
}
