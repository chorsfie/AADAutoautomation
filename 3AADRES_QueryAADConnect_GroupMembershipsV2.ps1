<#	
.SYNOPSIS 
	Query AAD Connect Database for objects that has been created in Azure AD after a provided datetime

.DESCRIPTION 
	This script will create a cvs file, what can be used to reset the groupmemberships

.PARAMETER outfile
path to the output csv file (e.g. c:\temp\GroupMembershipsToRecreate.csv)

.PARAMETER strDeletionTime
datetime where the groupmembership is created in Azure AD



.EXAMPLE
.\AADRes_QueryAADConnectGropMemberships.ps1 -outfile c:\temp\GroupMembershipsToRecreate.csv

Attempt to query the AADConnect Database for changed groupmembership and creates the csv file.


.NOTES
- 2019-11-13	Initial Release		
- 2020-05-11    Add some minor changes: eg. connectioString	
- 2020-05-29 	Add some minor changes on date/time stamps and wording
#>

Param (
	    [string]$outfile,
	    [string]$strDeletionTime
	)

Clear-Host
set-location "C:\Program Files\Microsoft SQL Server\110\Tools\Binn"

$ConnectionString = "Server=(localdb)\.\ADSync"

Write-Host " `n Trying to connect to sql server with connection string: $ConnectionString"
$conn=new-object System.Data.SqlClient.SQLConnection
set-location C:\temp
$conn.ConnectionString=$ConnectionString
$conn.Open()

Write-Host " `n Connected to SQL Server .."

if ($strDeletionTime -like $null)
{
	$strDeletionTime = read-host("Please enter the time when the backup was created (e.g. 2020-07-01 14:30 ):")
}


$deletionTime = get-Date($strDeletionTime)
$deletionTimeUTC = $deletionTime.ToUniversalTime()

$Query ="USE ADSync;SELECT 
member_mms.object_type, member_mms.sourceObjectType, member_mms.displayName, member_mms.object_type, member_mms.distinguishedName
,group_mms.object_id as groupID, group_mms.displayName as groupDisplayName, group_mms.distinguishedName as groupDN
, changeTable.memberCount as ChangeDateMember
FROM 
mms_metaverse as member_mms,
mms_mv_link as memberLink,
mms_metaverse as group_mms,
mms_metaverse_lineagedate as changeTable
WHERE 
member_mms.object_id = memberLink.reference_id
and  memberLink.object_id  = group_mms.object_id
and group_mms.object_type = 'group' 
and group_mms.cloudAnchor is not null 
and group_mms.memberCount > 0
and changeTable.memberCount > '$deletionTimeUTC' 
and  changeTable.object_id = group_mms.object_id"


$cmd=new-object system.Data.SqlClient.SqlCommand($Query,$conn)
$cmd.CommandTimeout=$QueryTimeout
$ds=New-Object system.Data.DataSet
$da=New-Object system.Data.SqlClient.SqlDataAdapter($cmd)
[void]$da.fill($ds)

if ($null -eq $ds -or $ds.Tables.Count -eq 0)
{
    Write-Host "`n  Results has been retrieved."
}
else
{
    if ($ds.Tables[0].Rows.Count -lt 1)
    {
        Write-Host "`n No result has been retrieved."
    }
    else
    {
        Write-Host "`n nr of results:" $ds.Tables[0].Rows.Count
        if ($outfile -like $null)
        {
            $outfile = "c:\temp\GroupMembershipsToRecreate.csv"
        }

        $ds.Tables[0] | export-csv -Path $outfile -NoTypeInformation 

        foreach($dataRow in $ds.Tables[0].Rows)
        {
            foreach($dataCell in $dataRow)
            {
                if ($dataCell.Length -gt 0)
                {
                    Write-Host ($dataCell)
                }

            }

            $conn.Close()
            $ds.Tables
            break
       }
  }
}
