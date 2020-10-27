Enable-OMSMonitoring - script to install OMS agent to enable OMS monitoring.
============================================================================

            

Disable-OMSMonitoring - script to remove OMS agent to disable OMS monitoring.


![Image](https://github.com/azureautomation/enableomsmonitoring-script-to-install-oms-agent-to-enable-oms-monitoring./raw/master/img_592919fcc82b1.png)


.SYNOPSIS   


 - This script install OMS agent to enable OMS monitoring.


  .DESCRIPTION     


- The script install Oms agent on selected VM and store all log in Oms workspace so that user can search any logs for that particular VM.


.INPUTS               


$VMResourceGroupName - The name of Resource Group where the VM needs to be created       


$VmName - The Name of VM provided by the customer       


$workspaceName - existing workspace name to connect vm


.OUTPUTS   


- Displays processes step by step during execution


.NOTES   


- Enable the Log verbose records of runbook and also  Need AzureRM.OperationalInsights module in automation account to perform this operation.


 


 

 

 

 


PFA the full script..


        
    
TechNet gallery is retiring! This script was migrated from TechNet script center to GitHub by Microsoft Azure Automation product group. All the Script Center fields like Rating, RatingCount and DownloadCount have been carried over to Github as-is for the migrated scripts only. Note : The Script Center fields will not be applicable for the new repositories created in Github & hence those fields will not show up for new Github repositories.
