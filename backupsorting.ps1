$startDTM = (Get-Date)
$arr = @()
$date= Get-date -UFormat "%d%m%Y"
$outputfile = "Backupsorting_"+$date+".csv"
$k = import-csv "Backupinventory_01102019.csv"

foreach($l in $k){
    if($l.Backup_Status -eq "InProgress"){
	$object = [PSCustomobject]@{
				        Operation              =$l.Operation 
				        Backup_Type            =$l.Backup_Type 
				        Workload_Name          =$l.Workload_Name 
				        Backup_Status          =$l.Backup_Status
						Backup_Time            =$l.Job_StartTime
				        Error_Message          =$l.Error_Message 
				        Recommendation         =$l.Recommendation
				        Vault_Name             =$l.Vault_Name 
				        Resource_Group         =$l.Resource_Group
				        Subscription           =$l.Subscription
				        Error_Code             =$l.Error_Code 
                        Job_StartTime          =$l.Job_StartTime} 
                    $arr += $object
    }
    else {    
	                $object = [PSCustomobject]@{
		                Operation              =$l.Operation 
				        Backup_Type            =$l.Backup_Type 
				        Workload_Name          =$l.Workload_Name 
				        Backup_Status          =$l.Backup_Status
						Backup_Time            =$l.Backup_Time
				        Error_Message          =$l.Error_Message 
				        Recommendation         =$l.Recommendation
				        Vault_Name             =$l.Vault_Name 
				        Resource_Group         =$l.Resource_Group
				        Subscription           =$l.Subscription
				        Error_Code             =$l.Error_Code 
                        Job_StartTime          =$l.Job_StartTime}
		            $arr += $object
				    
	            }
}		
$arr | export-csv -Path $outputfile -NoTypeInformation
$endDTM = (Get-Date)
$c = ($endDTM - $startDTM).minutes
Write-output "The script has taken $c minutes for execution"