<#	
.SYNOPSIS 
	Query AAD Connect Database for objects that has been created in Azure AD after a provided datetime

.DESCRIPTION 
	This script will create an cvs file, what can be used to recrate user objects

.PARAMETER outfile
path to the output csv file (e.g. c:\temp\UsersToRestore.csv)

.PARAMETER strDeletionTime
datetime where the objects are created in Azure AD



.EXAMPLE
.\AADRes_QueryAADConnect_UsersAndGrooups.ps1 -outfile c:\temp\UsersToRestore.csv -deletionTime "2020-01-21 14:30"

Attempt to query the AADConnect Database for changed users and groups after the provided time and store it into the provided file.


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

$Query ="USE ADSync; SELECT accountEnabled,accountName, cloudFiltered, cn, displayName, distinguishedName, sourceObjectType ,sn, givenName, co, company,mail, employeeId, employeeType, countryCode, department, description,streetAddress, street, last_modification_date, cloudAnchor,title, telephoneNumber,mobile, st, userPrincipalName, usageLocation, sourceAnchor FROM mms_metaverse WHERE (object_type = 'group' or object_type = 'person') and object_id in (SELECT object_id FROM mms_metaverse_lineagedate WHERE cloudAnchor is not null and cloudAnchor>'$deletionTimeUTC');"
$cmd=new-object system.Data.SqlClient.SqlCommand($Query,$conn)
$cmd.CommandTimeout=$QueryTimeout
$ds=New-Object system.Data.DataSet
$da=New-Object system.Data.SqlClient.SqlDataAdapter($cmd)
[void]$da.fill($ds)

if ($null -eq $ds -or $ds.Tables.Count -eq 0)
{
    Write-Host "`n 0 Results has been retrieved."
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
            $outfile = "c:\temp\UsersToRestore.csv"
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
