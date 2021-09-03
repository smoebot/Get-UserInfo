function Get-UserInfo { 
    [cmdletbinding(DefaultParameterSetName='samAccountName')] 
    Param( 
        [Parameter(ParameterSetName='samAccountName')] [String] $samAccountName, 
  
        [Parameter(ParameterSetName='emailAddress')] [String] $emailAddress 
    ) 
    # get local GC for doing the AD queries 
    $localSite = (Get-ADDomainController -Discover).Site; $newTargetGC = Get-ADDomainController -Discover -Service 2 -SiteName $localSite 
    If (!$newTargetGC) {$newTargetGC = Get-ADDomainController -Discover -Service 2 -NextClosestSite}; $localGC = "$($newTargetGC.HostName)" + ":3268" 
    if ( -not ([string]::IsNullOrWhiteSpace($samAccountName))) { 
        $userInfo = Get-ADUser -filter "SamAccountName -eq '$samAccountName'" -Server $localGC -Properties Name, City, Co, Department, mail, Manager, Title, UserPrincipalName, msExchExtensionAttribute31, msExchExtensionAttribute32, SamAccountName, PasswordLastSet, TelephoneNumber, LastLogonDate, Enabled, MemberOf
    } 
    if ( -not ([string]::IsNullOrWhiteSpace($emailAddress))) { 
        $userInfo = Get-ADUser -filter "EmailAddress -eq '$emailAddress'" -Server $localGC -Properties Name, City, Co, Department, mail, Manager, Title, UserPrincipalName, msExchExtensionAttribute31, msExchExtensionAttribute32, SamAccountName, PasswordLastSet, TelephoneNumber, LastLogonDate, Enabled, MemberOf
    } 
    $userInfo | Select-Object Name, GivenName, Surname, SamAccountName, UserPrincipalName, mail, Title, Department, msExchExtensionAttribute31, msExchExtensionAttribute32, City, Co, TelephoneNumber, @{N='Manager';E={(Get-ADUser -Server $localGC $_.Manager).Name}}, @{Name="LastLogonDate_UTC";Expression={($_.LastLogonDate).ToUniversalTime()}}, @{Name="PasswordLastSet_UTC";Expression={($_.PasswordLastSet).ToUniversalTime()}}, Enabled, @{Name="Remote2FA_Group";Expression={(($_.MemberOf -match "2FA") | Get-ADGroup -Server $localGC).name}}
}
