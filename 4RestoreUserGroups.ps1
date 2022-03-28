<#	
.SYNOPSIS 
	Create users and group objects in Active Directory based on the input file, what was created using the script: AADRes_QueryAADConnect_UsersAndGrops.ps1

.DESCRIPTION 
	This script will create user and groups in the ActiveDirectory

.PARAMETER inputfile
path to the input csv file (e.g. c:\temp\UserObjectsToRecreate.csv)


.EXAMPLE
.\RestoreUserGroups.ps1 -inputfile c:\temp\UsersToRestore.csv

Attempt to restore users and groups in the Active Directory stored in the provided file.


.NOTES
- 2020-04-30	Initial Release	
- 2020-05-11    Add some minor changes			
#>

Param (
	    [string]$inputfile
	)
Clear-Host

Import-Module ActiveDirectory

if ($inputfile -like $null)
{
   $inputfile = "C:\temp\UsersToRestore.csv"
}
$missingObjects = Import-Csv -Path $inputfile 

write-host " Doing: $missingObjects" 



foreach ($missingObject in $missingObjects) {
    $valuetoconvert = $missingObject.'sourceAnchor'
    $strGuid = [system.convert]::frombase64string($valuetoconvert)
    $sourceAnchorGUID = [GUID]$strGuid
    
     try {
        $decode = $strGuid.ToString()
        $ADObject =  Get-ADObject -Filter {objectGuid -eq  $decode}
        
       if ($null -eq $ADObject) {
          switch -wildcard ($missingObject.'cloudAnchor') {
          "User*"
            {   
                $cn = $missingObject.'cn'
                write-host " ## Processing User: $cn" -ForegroundColor Cyan
                $userpath =  $missingObject.'distinguishedName'
                $userpath = $userpath.Replace("CN=$cn,","") 
                write-host " ## Retoring User $cn  to: $userpath" -ForegroundColor Cyan
                New-ADUser -Name $missingObject.'cn' -OtherAttributes @{'displayName'=$missingObject.'displayName'} -Path $userpath 
                               
                $newObject = Get-ADObject -LDAPFilter("(name=$cn)")
                Set-adobject -Identity $newObject.DistinguishedName -Replace @{'mS-DS-ConsistencyGuid'=$($sourceAnchorGUID)}

                if ($missingObject.'givenName‘ -notlike $null) {"Setting Firstname"; Set-adobject -Identity $newObject.DistinguishedName -Replace @{'givenName'=$($missingObject.'givenName')}  }
                if ($missingObject.'sn‘ -notlike $null) {"Setting Surname"; Set-adobject -Identity $newObject.DistinguishedName -Replace @{'sn'=$($missingObject.'sn').Trim()} }
                if ($missingObject.'initials‘ -notlike $null) {"Setting initials"; Set-adobject -Identity $newObject.DistinguishedName -Replace @{'initials'=$($missingObject.'initials').Trim()} }
                if ($missingObject.'middleName‘-notlike $null) { "Setting middleName";Set-adobject -Identity $newObject.DistinguishedName -Replace @{'middleName'=$($missingObject.'middleName')} }
                if ($missingObject.'displayName‘-notlike $null) { "Setting displayName";Set-adobject -Identity $newObject.DistinguishedName -Replace @{'displayName'=$($missingObject.'displayName')} }
                if ($missingObject.'description‘-notlike $null) { "Setting description";Set-adobject -Identity $newObject.DistinguishedName -Replace @{'description'=$($missingObject.'description')} }
                if ($missingObject.'physicalDeliveryOfficeName‘-notlike $null) { "Setting Office";Set-adobject -Identity $newObject.DistinguishedName -Replace @{'physicalDeliveryOfficeName'=$($missingObject.'physicalDeliveryOfficeName')} }
                if ($missingObject.'telephoneNumber‘-notlike $null) { "Setting Phone";Set-adobject -Identity $newObject.DistinguishedName -Replace @{'telephoneNumber'=$($missingObject.'telephoneNumber')} }
                if ($missingObject.'mail‘-notlike $null) { "Setting mail";Set-adobject -Identity $newObject.DistinguishedName -Replace @{'mail'=$($missingObject.'mail')} }

                if ($missingObject.'streetAddress‘-notlike $null) { "Setting Street";Set-adobject -Identity $newObject.DistinguishedName -Replace @{'streetAddress'=$($missingObject.'streetAddress')} }
                if ($missingObject.'postOfficeBox‘-notlike $null) { "Setting postOfficeBox";Set-adobject -Identity $newObject.DistinguishedName -Replace @{'postOfficeBox'=$($missingObject.'postOfficeBox')} }
                if ($missingObject.'l‘-notlike $null) { "Setting City";Set-adobject -Identity $newObject.DistinguishedName -Replace @{'l'=$($missingObject.'l')} }
                if ($missingObject.'st‘-notlike $null) { "Setting State";Set-adobject -Identity $newObject.DistinguishedName -Replace @{'st'=$($missingObject.'st')} }
                if ($missingObject.'postalCode‘-notlike $null) { "Setting postalCode";Set-adobject -Identity $newObject.DistinguishedName -Replace @{'postalCode'=$($missingObject.'postalCode')} }
                if ($missingObject.'co‘-notlike $null) { "Setting Country";Set-adobject -Identity $newObject.DistinguishedName -Replace @{'co'=$($missingObject.'co')} }

                if ($missingObject.'homePhone‘-notlike $null) { "Setting homePhone";Set-adobject -Identity $newObject.DistinguishedName -Replace @{'homePhone'=$($missingObject.'homePhone')} }
                if ($missingObject.'pager‘-notlike $null) { "Setting pager";Set-adobject -Identity $newObject.DistinguishedName -Replace @{'pager'=$($missingObject.'pager')} }
                if ($missingObject.'mobile‘-notlike $null) { "Setting mobile";Set-adobject -Identity $newObject.DistinguishedName -Replace @{'mobile'=$($missingObject.'mobile')} }
                if ($missingObject.'facsimileTelephoneNumber‘-notlike $null) { "Setting FAX";Set-adobject -Identity $newObject.DistinguishedName -Replace @{'facsimileTelephoneNumber'=$($missingObject.'facsimileTelephoneNumber')} }
                
                if ($missingObject.'title‘-notlike $null) { "Setting Job Title";Set-adobject -Identity $newObject.DistinguishedName -Replace @{'title'=$($missingObject.'title')} }
                if ($missingObject.'department‘-notlike $null) { "Setting department";Set-adobject -Identity $newObject.DistinguishedName -Replace @{'department'=$($missingObject.'department')} }
                if ($missingObject.'company‘-notlike $null) { "Setting company";Set-adobject -Identity $newObject.DistinguishedName -Replace @{'company'=$($missingObject.'company')} }
                #if ($missingObject.'title‘-notlike $null) { "Setting Job Title";Set-adobject -Identity $newObject.DistinguishedName -Replace @{'title'=$($missingObject.'title')} }

                if ($missingObject.'userPrincipalName‘-notlike $null) { "Setting UPN";Set-adobject -Identity $newObject.DistinguishedName -Replace @{'userPrincipalName'=$($missingObject.'userPrincipalName')} }
                
            
            }
            
            "Group*"
            {
               #restore groups      
               $cn = $missingObject.'cn'
               write-host " ## Processing Group: $cn" -ForegroundColor Cyan
               $grouppath =  $missingObject.'distinguishedName'
               $grouppath = $grouppath.Replace("CN=$cn,","") 
               write-host " ## Restoring Group $cn to: $grouppath" -ForegroundColor Cyan
               New-ADGroup -Name $missingObject.'cn' -DisplayName $missingObject.'displayName' -GroupScope DomainLocal -path $grouppath
               $newObject = Get-ADObject -LDAPFilter("(name=$cn)")
               Set-adobject -Identity $newObject.DistinguishedName -Replace @{'mS-DS-ConsistencyGuid'=$($sourceAnchorGUID)}

           }
      }

         
  }

    }
    
    catch {     
    
    }
} 
