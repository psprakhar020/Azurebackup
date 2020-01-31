$startDTM = (Get-Date)
#Variables
$date= Get-date -UFormat "%d%m%Y"
$outputfile = "Backupinventory_"+$date+".csv"

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
                $vmlist = Get-AzRecoveryServicesBackupJob -From (Get-Date).AddDays(-14).ToUniversalTime()
		        foreach ($vm in $vmlist)
		        {
					
					$object = [PSCustomobject]@{
				        Operation              =$vm.Operation 
				        Backup_Type            =$vm.BackupManagementType 
				        Workload_Name          =$vm.WorkloadName 
				        Backup_Status          =$vm.status
						Backup_Time            =$vm.EndTime
				        Error_Message          =$vm.ErrorDetails.ErrorMessage 
				        Recommendation         =$vm.ErrorDetails.Recommendations 
				        Vault_Name             =$vaultname 
				        Resource_Group         =$rgname 
				        Subscription           =$sub.name 
				        Error_Code             =$vm.ErrorDetails.ErrorCode 
                        Job_StartTime          =$vm.StartTime} 
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

$endDTM = (Get-Date)
$c = ($endDTM - $startDTM).minutes
Write-output "The script has taken $c minutes for execution"
