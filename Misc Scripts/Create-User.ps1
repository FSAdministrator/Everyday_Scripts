### This script was created by FSADMIN for automation of IT user creation. This script should be run after a form has been submitted.

#Current Variable List
$Excel = New-Object -ComObject Excel.Application #Importing the Excel object to be used for usage from powershell
$Workbook = $Excel.Workbooks.Open('C:\Users\savillef\Timberlands Ltd\ICT - General\User Account Setup\User Account Form Log.xlsx') #This will be different for every user...
$workSheet = $Workbook.Sheets.Item(1) #Will always be this sheet, DO NOT CHANGE OR THE SCRIPT WILL NOT WORK

#Script Testing (This will check to see if all Variables are avaliable before running innitinal script)

 

# Module Imports
Import-Module ActiveDirectory


#Import all User information from CSV generated from ConvertSAAR program
$Users = Import-Csv -Path "C:\Foo\NewEmployees.csv"


#Filter each line of Output.csv individually
   ForEach ($User in $Users) {


       #User account information variables
       $Displayname = $(

           If($User.MiddleIn -EQ $Null){
               $User.LastName + ", " + $User.FirstName
           }

           ElseIf(!($User.MiddleIn -EQ $Null)){
               $User.LastName + ", " + $User.FirstName + " " + $User.MiddleIn
           })

       $UserFirstname = $User.FirstName
       $UserInitial = $User.MiddleIn
       $UserLastname = $User.LastName
       $SupervisorEmail = $User.SupervisorEmail
       $UserCompany = $User.Company
       $UserDepartment =  $User.Department
       $Citizenship = $User.Citizenship
       $FileServer = $User.Location
       $UserJobTitle = $User.JobTitle
       $OfficePhone = $User.Phone
       $Description = $(

       If($User.Citizenship -eq 2){
               "Domain User (Canada)"
           }

           ElseIf($User.Citizenship -eq 3){
               "Domain User (United Kingdom)"
           }

           Else{
               "Domain User (United States)"
           })

       $Email = $User.Email
       $Info = $(
       $Date = Get-Date
       "Account Created: " + $Date.ToShortDateString() + " " + $Date.ToShortTimeString() + " - " +  [Environment]::UserName
       )

       #Get Supervisors SAM Account Name based on email address supplied in .csv
       $FindSuperV = Get-ADUser -Filter {(mail -like $User.SupervisorEmail)}
       $FindSuperV = $FindSuperV | select -First "1" -ExpandProperty SamAccountName

       $Password = 'B@dP@S$wORD234'


       #Parameters from Template User Object
       $AddressPropertyNames = @("StreetAddress","State","PostalCode","POBox","Office","Country","City")

       $SchemaNamingContext = (Get-ADRootDSE).schemaNamingContext

       $PropertiesToCopy = Get-ADObject -Filter "objectCategory -eq 'CN=Attribute-Schema,$SchemaNamingContext' -and searchflags -eq '16'" -SearchBase $SchemaNamingContext -Properties * |
        Select -ExpandProperty lDAPDisplayname

       $PropertiesToCopy += $AddressPropertyNames

       $Password_SS = ConvertTo-SecureString -String $Password -AsPlainText -Force
       $Template_Obj = Get-ADUser -Identity $Template -Properties $PropertiesToCopy

       $OU = $Template_Obj.DistinguishedName -replace '^cn=.+?(?<!\\),'

       #Replace SAMAccountName of Template User with new account for properties like the HomeDrive that need to be dynamic
       $Template_Obj.PSObject.Properties | where {
           $_.Value -match ".*$($Template_Obj.SAMAccountName).*" -and
           $_.Name -ne "SAMAccountName" -and
           $_.IsSettable -eq $True
        } | ForEach {

               Try{
                   $_.Value = $_.Value -replace "$($Template_Obj.SamAccountName)","$SAM"
               }#Try

               Catch {

                   #DoNothing
               }#Catch
           }#ForEach

       #ADUser parameters
       $params = @{
            "Instance"=$Template_Obj
            "Name"=$DisplayName
            "DisplayName"=$DisplayName
            "GivenName"=$UserFirstname
            "SurName"=$UserLastname
            "Initials"=$UserInitial
            "AccountPassword"=$Password_SS
            "Enabled"=$True
            "ChangePasswordAtLogon"=$True
            "UserPrincipalName"=$UserPrincipalName
            "SAMAccountName"=$SAM
            "Path"=$OU
            "OfficePhone"=$OfficePhone
            "EmailAddress"=$Email
            "Company"=$UserCompany
            "Department"=$UserDepartment
            "Description"=$Description
            "Title"=$UserJobTitle
        }#params

       $AddressPropertyNames | foreach {$params.Add("$_","$($Template_obj."$_")")}

       New-ADUser @params

       Set-AdUser "$SAM" -Manager $FindSuperV -Replace @{Info="$Info"}

       $TempMembership = Get-ADUser -Identity $Template -Properties MemberOf
       $TempMembership = $TempMembership | Select -ExpandProperty MemberOf

       $TempMembership | Add-ADGroupMember -Members $SAM
}
