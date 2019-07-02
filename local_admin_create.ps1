$Program_Version = "0.1.0"
$Program_Name = "Specter Tech's Local Admin Creator"
$Username = "Admin.Local"

Clear-Host
Write-Output "=========================================================="
Write-Output "$Program_Name version $Program_Version."
Write-Output "=========================================================="
Write-Output "Please ensure Group Policy allows for script execution."
Write-Output "----------------------------------------------------------"
Write-Output "Username: $Username"

$Password =  Read-Host "Please Enter a password: " -AsSecureString 
$Password_Confirmation = Read-Host "Please Confirm your password: " -AsSecureString

$Password_Plain = [RunTime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password))
$Password_Confirmation_Plain = [RunTime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password_Confirmation))

if ($Password_Plain -eq $Password_Confirmation_Plain) {
    Write-Output "Passwords match."
} else {
    Write-Output "The passwords do not match. Please run the program again.";
    exit;
}

$group = "Administrators"

$adsi = [ADSI]"WinNT://$env:COMPUTERNAME"
$existing = $adsi.Children | Where-Object {$_.SchemaClassName -eq 'user' -and $_.Name -eq $Username }

if ($existing -eq $null) {

    Write-Host "Creating new local user $Username."
    & NET USER $Username $Password /add /y /expires:never
    
    Write-Host "Adding local user $Username to $group."
    & NET LOCALGROUP $group $Username /add

}
else {
    Write-Host "Setting password for existing local user $Username."
    $existing.SetPassword($Password)
}

Write-Host "Ensuring password for $Username never expires."
& WMIC USERACCOUNT WHERE "Name='$Username'" SET PasswordExpires=FALSE