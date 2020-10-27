<#
	.SYNOPSIS
    This script enable monitoring for selected VM.
	
	.DESCRIPTION
    - Script install OMS agent on selected VM or while creating new VM, if the VM is Linux then OmsAgentForLinux agent will get installed and for windows VM script will install MicrosoftMonitoringAgent agent

    	
	.INPUTS
	$VmName - The name of virtual machine.
    $VMResourceGroup - Recource group where VM exist.
    $workspaceName - existing workspace name to connect vm
	
	.OUTPUTS
    Displays processes step by step during execution
	
	.NOTES
    Author:      Arun Sabale
    Created:     5 Jan 2015
    Version:     1.0  
	
	.Note 
	Enable the Log verbose records of runbook
    Need AzureRM.OperationalInsights module to perform this operation.
#>
   param(
        [Parameter(Mandatory=$true)] 
        [String] 
        $workspaceName,
	    [Parameter(Mandatory=$true)] 
	    [String] 
	    $VMResourceGroup,
	    [Parameter(Mandatory=$true)] 
	    [String] 
	    $VmName
        )


        $ErrorState = 0
	    [string] $ErrorMessage = ""
	    [string] $SuccessMessage = ""

            try
            {
			#The name of the Automation Credential Asset this runbook will use to authenticate to Azure.
			#Connect to your Azure Account   	
            $Conn = Get-AutomationConnection -Name AzurerunasConnection
            $AddAccount = Add-AzureRMAccount -ServicePrincipal -Tenant $Conn.TenantID `
            -ApplicationId $Conn.ApplicationID -CertificateThumbprint $Conn.CertificateThumbprint

            
            # Input Validation
            if ($VMResourceGroup -eq $null) {throw "Input parameter ResourceGroup missing"} 
            if ($VmName -eq $null) {throw "Input parameter VmName missing"} 
            if ($workspaceName -eq $null) {throw "Input parameter workspaceName missing"} 

                $workspace = Get-AzureRmOperationalInsightsWorkspace |where{$_.name -eq $workspacename }

                if ($workspace -eq $null)
                {
                    Write-Verbose "Unable to find OMS Workspace "
                    throw "Unable to find OMS Workspace "
                }
                if($workspace.Count -ne 1)
                {
                    Write-Verbose "There are more than 1 workspace"
                    throw "There are more than 1 workspace"
                }

                $workspaceId = $workspace.CustomerId
                $workspaceKey = (Get-AzureRmOperationalInsightsWorkspaceSharedKeys -ResourceGroupName $workspace.ResourceGroupName -Name $workspace.Name).PrimarySharedKey

                $vm = Get-AzureRmVM -ResourceGroupName $VMresourcegroup -Name $VMName
                $vmStatus = Get-AzureRmVM -ResourceGroupName $VMresourcegroup -Name $VMName  -Status
                $vmStatus1 = $vmStatus.Statuses |where{$_.code -like "PowerState*"}
                if($vmStatus1.code -ne "PowerState/running")
                {
                    Write-Verbose "VM is not in running state"
                    throw "VM is not in running state"
                }

                if(!($vm))
                {
                    Write-Verbose "Unable to find VM"
                    throw "Unable to find VM"
                }
                $location = $vm.Location

                $OSType  = $($vm.StorageProfile.OsDisk.OsType)
                Write-Verbose "os type is $OSType"
                if($OSType -eq $null)
                {
                    Write-Verbose "OS type is not matching"
                    throw "OS type is not matching"
                }
                if($OSType -eq "windows")
                {
                    # For Windows VM 
                    $GetExt = (Get-AzureRmVMExtension -ResourceGroupName $VMresourcegroup -VMName $VMName -name "MicrosoftMonitoringAgent" -ErrorAction SilentlyContinue).ProvisioningState
                    if ($GetExt -eq $null)
                    {
                        $jobstatus = Set-AzureRmVMExtension -ResourceGroupName $VMresourcegroup -VMName $VMName -Name 'MicrosoftMonitoringAgent' -Publisher 'Microsoft.EnterpriseCloud.Monitoring' -ExtensionType 'MicrosoftMonitoringAgent' -TypeHandlerVersion '1.0' -Location $location -SettingString " `                       {'workspaceId': '$workspaceId'}" -ProtectedSettingString "{'workspaceKey': '$workspaceKey'}"
                        Write-Verbose "job status is $($jobstatus.IsSuccessStatusCode)"
                        if($jobstatus.IsSuccessStatusCode -eq $true)
                        {
                        Write-Verbose "installed OMS agent successfully"
                        }
                        else
                        {
                        throw "unable to install OMs agent"
                        }
                    }
                    else
                    {
                    Write-Verbose "Agent is already installed"
                    throw "Agent is already installed"
                    }
                }
                elseif($OSType -eq "linux")
                {
                    # For Linux VM 
                    $GetExt = (Get-AzureRmVMExtension -ResourceGroupName $VMresourcegroup -VMName $VMName -name "OmsAgentForLinux" -ErrorAction SilentlyContinue).ProvisioningState
                    if ($GetExt -eq $null)
                    {
                        $jobstatus= Set-AzureRmVMExtension -ResourceGroupName $VMresourcegroup -VMName $VMName -Name 'OmsAgentForLinux' -Publisher 'Microsoft.EnterpriseCloud.Monitoring' -ExtensionType 'OmsAgentForLinux' -TypeHandlerVersion '1.0' -Location $location -SettingString "{'workspaceId': `                         $workspaceId'}" -ProtectedSettingString "{'workspaceKey': '$workspaceKey'}"
                        Write-Verbose "job status is $($jobstatus.IsSuccessStatusCode)"
                        if($jobstatus.IsSuccessStatusCode -eq $true)
                        {
                        Write-Verbose "installed OMS agent successfully"
                        }
                        else
                        {
                        throw "unable to install OMs agent"
                        }
                    }
                    else
                    {
                    Write-Verbose "Agent is already installed"
                    throw "Agent is already installed"
                    }
                }
                Else
                {
                    throw "Unable to connect oms"
                }
                
                #Validation 

                $vm = Get-AzureRmVM -ResourceGroupName $VMresourcegroup -Name $VMName
                $vmExtensions = $vm.Extensions.VirtualMachineExtensionType 
                $vmExtensionsStatus = $false
                if($OSType -eq "windows")
                {
                    
                    if($vmExtensions -like "MicrosoftMonitoringAgent")
                    { 
                    $vmExtensionsStatus = $true
                    }
                }
                elseif($OSType -eq "linux")
                {
                   if($vmExtensions -like "OmsAgentForLinux")
                    { 
                    $vmExtensionsStatus = $true
                    }
                    
                }
                if($vmExtensionsStatus -like $true)
                {           
                $resultcode = "SUCCESS VM : $vmname added in monitoring"
	            Write-Output -InputObject $resultcode
                }
                
            }#end of Try
            catch
            {
                $ErrorState = 1
		        $ErrorMessage = "$_" 			
                $resultcode = "FAILURE"
		        Write-Output -InputObject $resultcode
		        Write-Output -InputObject $ErrorMessage 
            }
