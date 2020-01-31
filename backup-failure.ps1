
#Variables
$date= Get-date -UFormat "%y%m%d"
$outputfile = "BackupFailure_"+$date+".csv"

$arr = @()


#get list of subscriptions
$subscriptionName = Get-AzSubscription | Select-Object Name -Unique


#search in each subscription
foreach($sub in $subscriptionName)
{
    if($sub.name -ne "ABI AFRICA PROD" -and $sub.name -ne "ABI AFRICA NON-PROD")
    {
        try 
	    {
            #select the subscription
            $setcontext = set-AzContext -SubscriptionName ($sub.Name)
			Write-Verbose "---- Processing subscription $($sub.name)-------" -Verbose
            #get the list of all the Recovery service vault
            $vaultlist = Get-AzRecoveryServicesVault
	        foreach( $vault in $vaultlist)
            {        
                $vaultname = $vault.name
                #select each recovery service vault
	            Set-AzRecoveryServicesVaultContext -Vault $vault -warningaction Silentlycontinue
	            $rgname = $vault.ResourceGroupName
                #Search for Failed backup in last 24 Hr in selected Recovery service vault
                $vmlist = Get-AzRecoveryServicesBackupJob -From (Get-Date).AddDays(-1).ToUniversalTime() -Status Failed
		        foreach ($vm in $vmlist)
		        {  
					$temp1 = Get-AzRecoveryServicesBackupJob -From (Get-Date).AddDays(-29).ToUniversalTime() -status completed | where{$_.workloadname -eq $vm.workloadname}
					$temp2 = $temp1.endtime | select -first 1
					
					$object = [PSCustomobject]@{
				        Operation        =$vm.Operation 
				        Backup_Type      =$vm.BackupManagementType 
				        Workload_Name    =$vm.WorkloadName 
				        Backup_Status    =$vm.status
						Last_Successful_Backup = $temp2
						Backup_FailedTime = $vm.EndTime
				        Error_Message    =$vm.ErrorDetails.ErrorMessage 
				        Recommendation   =$vm.ErrorDetails.Recommendations 
				        Vault_Name       =$vaultname 
				        Resource_Group   =$rgname 
				        Subscription     =$sub.name 
				        Error_Code       =$vm.ErrorDetails.ErrorCode 
                        Job_StartTime    =$vm.StartTime} 
                    $arr += $object
                }
            }
	    }
        catch
		{
	    Write-Error -Message $_.Exception
        throw $_.Exception
        }
    }
}	
$arr | Export-Csv -Path $outputfile -NoTypeInformation 

