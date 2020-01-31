$arr = @()
$date= Get-date -UFormat "%d%m%Y"
$outputfile = "VMBackupPolicy_"+$date+".csv"
Get-AzSubscription |Select-Object -Unique | ForEach-Object {
    $subscription= $_
	#optional - To filter specific subscription
	if($subscription.name -ne "xxxxxxx")
	{
        Set-AzContext -SubscriptionName $subscription.name | out-null
		Write-Verbose "---- Processing subscription $($subscription.name)-------" -Verbose
        $vms=Get-AzVM
        foreach($vm in $vms)
	    {
            Write-Verbose "----Checking Backup Policy for $($vm.name)-------" -Verbose
			$rsv = (((get-azrecoveryservicesbackupstatus -name $vm.name -resourcegroupname $vm.resourcegroupname -type "AzureVM" | select vaultid).vaultid) -split '/')[-1]
            Get-AzRecoveryServicesVault -Name $rsv | Set-AzureRmRecoveryServicesVaultContext -warningaction Silentlycontinue
            $Container=Get-AzRecoveryServicesBackupContainer -ContainerType "AzureVM" -Status "Registered" -FriendlyName $vm.name
            $item = Get-AzRecoveryServicesBackupItem -Container $Container -WorkloadType "AzureVM"
            $policyname=$item.ProtectionPolicyName
		    $object = [PSCustomobject]@{
		        VMName                =$vm.name
	   	        RGName                =$vm.resourcegroupname
		        Location              =$vm.location
				RecoveryServicesVault =$rsv
		        BackupPolicy          =$policyname
		        Subscription          =$subscription.name}
		    $arr += $object
		}
    }
}
$arr | export-csv -path $outputfile -notype