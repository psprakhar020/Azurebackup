$arr = @()
$date= Get-date -UFormat "%d%m%Y"
$outputfile = "VMLackingBackup_"+$date+".csv"
Get-AzSubscription |Select-Object -Unique | ForEach-Object {
    $subscription= $_
	#optional - To filter specific subscription
	if($subscription.name -ne "ABI AFRICA PROD" -and $subscription.name -ne "ABI AFRICA NON-PROD")
	{
        Set-AzContext -SubscriptionName $subscription.name | out-null
		Write-Verbose "---- Processing subscription $($subscription.name)-------" -Verbose
        $vms=Get-AzVM
        foreach($vm in $vms)
	    {
			$backupconfig = (get-azrecoveryservicesbackupstatus -name $vm.name -resourcegroupname $vm.resourcegroupname -type "AzureVM" | select-object BackedUp).BackedUp
            if($backupconfig -eq $false){
			    Write-Verbose "----No Backup configuration for $($vm.name)-------" -Verbose
			    $ostype   = $vm.storageprofile.osdisk.ostype
				$VMStatus =(get-azurermvm -resourcegroupname $vm.resourcegroupname -name $vm.name  -Status).statuses[1].displaystatus
		        $object = [PSCustomobject]@{
		        VMName                =$vm.namex
	   	        RGName                =$vm.resourcegroupname
		        Location              =$vm.location
				BackupConfiguration   =$backupconfig
		        OSType                =$ostype
				VMStatus              =$VMStatus
		        Subscription          =$subscription.name}
		        $arr += $object
		    }
		}
    }
}
$arr | export-csv -path $outputfile -notype



