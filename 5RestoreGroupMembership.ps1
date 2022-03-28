Import-Module ActiveDirectory
$fileMissingObjects = "C:\temp\GroupMembershipsToRecreate.csv"
$missingObjects = Import-Csv -Path $fileMissingObjects 
cls
foreach ($missingObject in $missingObjects) {
   
       
          switch -wildcard ($missingObject.'sourceObjectType') {
            "User*"
            {   
                $cn = $missingObject.'displayname'
                $group = $missingObject.'groupDisplayName'
                write-host " ## Processing Group: $group adding member: $cn" -ForegroundColor Cyan
                Add-ADGroupMember -identity $group -members $missingObject.distinguishedname
                
                
            }
                       
            }

         }

