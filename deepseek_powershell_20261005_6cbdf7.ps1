<#
================================================================================
 DOBRE LTD
 ACTIVE DIRECTORY PROVISIONING ENGINE
 Version: 2.0
================================================================================
DOMAIN:            dobre.local
COMPANY OU:        OU=dobre.local,DC=dobre,DC=local
LOCAL DIRECTORY:   C:\Scripts
INPUT:             C:\Scripts\Dobre_Ltd_AD_User_Provisioning_Input.xlsx
OUTPUT:            C:\Scripts\AD_Provisioning_Report.csv
REQUIRED MODULES:  ActiveDirectory, ImportExcel
================================================================================
#>

Clear-Host
$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "          DOBRE LTD  AD PROVISIONING ENGINE                 " -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

# ----------------------------------------------------------------------------
# 1. LOAD MODULES
# ----------------------------------------------------------------------------
Write-Host "[*] Loading required PowerShell modules..." -ForegroundColor Cyan

try {
    Import-Module ActiveDirectory -ErrorAction Stop
    Write-Host "[+] ActiveDirectory module loaded." -ForegroundColor Green
}
catch {
    Write-Host "[X] ActiveDirectory module could not be loaded." -ForegroundColor Red
    Write-Host "    Install RSAT / Active Directory PowerShell tools."
    exit 1
}

try {
    Import-Module ImportExcel -ErrorAction Stop
    Write-Host "[+] ImportExcel module loaded." -ForegroundColor Green
}
catch {
    Write-Host "[X] ImportExcel module is not installed." -ForegroundColor Red
    Write-Host "    Install with: Install-Module ImportExcel -Scope CurrentUser"
    exit 1
}

# ----------------------------------------------------------------------------
# 2. CONFIGURATION
# ----------------------------------------------------------------------------
$WorkingDirectory = "C:\Scripts"
$ExcelPath        = "$WorkingDirectory\Dobre_Ltd_AD_User_Provisioning_Input.xlsx"
$ReportPath       = "$WorkingDirectory\AD_Provisioning_Report.csv"
$DomainDN         = "DC=dobre,DC=local"
$CompanyOU        = "OU=dobre.local,$DomainDN"
$UsersOU          = "OU=Users,$CompanyOU"
$GroupsOU         = "OU=Groups,$CompanyOU"
$UPNSuffix        = "dobre.local"

# ----------------------------------------------------------------------------
# 3. TEMPORARY PASSWORD (embedded — rotate per security policy)
# ----------------------------------------------------------------------------
$TemporaryPasswordPlain = "Dobre@2025#Init"
$InitialPassword = ConvertTo-SecureString $TemporaryPasswordPlain -AsPlainText -Force

# ----------------------------------------------------------------------------
# 4. VERIFY PATHS
# ----------------------------------------------------------------------------
if (-not (Test-Path $WorkingDirectory)) {
    Write-Host "[X] Directory does not exist: $WorkingDirectory" -ForegroundColor Red
    exit 1
}
if (-not (Test-Path $ExcelPath)) {
    Write-Host "[X] Excel file not found: $ExcelPath" -ForegroundColor Red
    exit 1
}
Write-Host "[+] Input workbook found." -ForegroundColor Green

# ----------------------------------------------------------------------------
# 5. VERIFY COMPANY OU EXISTS
# ----------------------------------------------------------------------------
$CompanyOUObject = Get-ADOrganizationalUnit -Identity $CompanyOU -ErrorAction SilentlyContinue
if (-not $CompanyOUObject) {
    Write-Host "[X] Company OU not found: $CompanyOU" -ForegroundColor Red
    Write-Host "    Create it first: New-ADOrganizationalUnit -Name 'dobre.local' -Path '$DomainDN'"
    exit 1
}
Write-Host "[+] Company OU confirmed: $CompanyOU" -ForegroundColor Green

# ----------------------------------------------------------------------------
# 6. HELPER FUNCTIONS
# ----------------------------------------------------------------------------
function Ensure-OU {
    param(
        [Parameter(Mandatory=$true)][string]$Name,
        [Parameter(Mandatory=$true)][string]$ParentDN
    )
    $TargetDN = "OU=$Name,$ParentDN"
    if (-not (Get-ADOrganizationalUnit -Identity $TargetDN -ErrorAction SilentlyContinue)) {
        New-ADOrganizationalUnit -Name $Name -Path $ParentDN -ProtectedFromAccidentalDeletion $true
        Write-Host "[+] Created OU: $TargetDN" -ForegroundColor Green
    } else {
        Write-Host "[=] OU exists:  $TargetDN" -ForegroundColor DarkGray
    }
    return $TargetDN
}

function Ensure-SecurityGroup {
    param([Parameter(Mandatory=$true)][string]$GroupName)
    if (-not (Get-ADGroup -Filter "SamAccountName -eq '$GroupName'" -ErrorAction SilentlyContinue)) {
        New-ADGroup -Name $GroupName -SamAccountName $GroupName `
            -GroupScope Global -GroupCategory Security -Path $GroupsOU
        Write-Host "[+] Created group: $GroupName" -ForegroundColor Yellow
    } else {
        Write-Host "[=] Group exists:  $GroupName" -ForegroundColor DarkGray
    }
}

# ----------------------------------------------------------------------------
# 7. BUILD OU + GROUP STRUCTURE
# ----------------------------------------------------------------------------
Write-Host ""
Write-Host "============================================================"
Write-Host " CREATING AD STRUCTURE"
Write-Host "============================================================"

Ensure-OU -Name "Users"  -ParentDN $CompanyOU | Out-Null
Ensure-OU -Name "Groups" -ParentDN $CompanyOU | Out-Null

# ----------------------------------------------------------------------------
# 8. IMPORT EMPLOYEE DATA
# ----------------------------------------------------------------------------
Write-Host ""
Write-Host "[*] Loading employee database..." -ForegroundColor Cyan

$Employees = Import-Excel -Path $ExcelPath -WorksheetName "Employees" -DataOnly -ErrorAction Stop
if (-not $Employees) {
    Write-Host "[X] Employees worksheet contains no records." -ForegroundColor Red
    exit 1
}
Write-Host "[+] Employee records loaded: $($Employees.Count)" -ForegroundColor Green

# ----------------------------------------------------------------------------
# 9. DISCOVER DEPARTMENTS -> CREATE DEPARTMENT OUs
# ----------------------------------------------------------------------------
$Departments = $Employees |
    Select-Object -ExpandProperty Department -Unique |
    Where-Object { -not [string]::IsNullOrWhiteSpace($_) }

Write-Host ""
Write-Host "============================================================"
Write-Host " CREATING DEPARTMENT OU STRUCTURE"
Write-Host "============================================================"

foreach ($Department in $Departments) {
    $DepartmentOU = Ensure-OU -Name $Department -ParentDN $UsersOU
    Ensure-OU -Name "OnSite" -ParentDN $DepartmentOU | Out-Null
    Ensure-OU -Name "Remote" -ParentDN $DepartmentOU | Out-Null
}

# ----------------------------------------------------------------------------
# 10. CREATE SECURITY GROUPS
# ----------------------------------------------------------------------------
Write-Host ""
Write-Host "============================================================"
Write-Host " CREATING SECURITY GROUPS"
Write-Host "============================================================"

$Groups = $Employees |
    Select-Object -ExpandProperty SecurityGroup -Unique |
    Where-Object { -not [string]::IsNullOrWhiteSpace($_) }

foreach ($Group in $Groups) {
    Ensure-SecurityGroup -GroupName $Group
}

# ----------------------------------------------------------------------------
# 11. PHASE A — CREATE ACCOUNTS
# ----------------------------------------------------------------------------
Write-Host ""
Write-Host "============================================================"
Write-Host " PHASE A — CREATING ACCOUNTS"
Write-Host "============================================================"

$ProvisionQueue = @()
$FailedCount    = 0

foreach ($RawEmployee in $Employees) {

    $Employee = [PSCustomObject]@{
        EmployeeID     = "$($RawEmployee.EmployeeID)".Trim()
        FirstName      = "$($RawEmployee.FirstName)".Trim()
        LastName       = "$($RawEmployee.LastName)".Trim()
        Username       = "$($RawEmployee.Username)".Trim()
        Department     = "$($RawEmployee.Department)".Trim()
        Role           = "$($RawEmployee.Role)".Trim()
        EmploymentType = "$($RawEmployee.EmploymentType)".Trim()
        Location       = "$($RawEmployee.Location)".Trim()
        CountryRegion  = "$($RawEmployee.CountryRegion)".Trim()
        OfficeSubnet   = "$($RawEmployee.OfficeSubnet)".Trim()
        RemoteSubnet   = "$($RawEmployee.RemoteSubnet)".Trim()
        VLAN           = "$($RawEmployee.VLAN)".Trim()
        SecurityGroup  = "$($RawEmployee.SecurityGroup)".Trim()
        OUPath         = "$($RawEmployee.OUPath)".Trim()
    }

    if ([string]::IsNullOrWhiteSpace($Employee.FirstName) -or
        [string]::IsNullOrWhiteSpace($Employee.LastName)  -or
        [string]::IsNullOrWhiteSpace($Employee.Username)  -or
        [string]::IsNullOrWhiteSpace($Employee.Department) -or
        [string]::IsNullOrWhiteSpace($Employee.EmploymentType)) {
        Write-Host "[X] Missing required data for: $($Employee.Username)" -ForegroundColor Red
        $FailedCount++
        continue
    }

    $EmploymentType = $Employee.EmploymentType
    if ($EmploymentType -notin @("Remote","OnSite")) {
        Write-Host "[X] Invalid EmploymentType: $EmploymentType" -ForegroundColor Red
        $FailedCount++
        continue
    }

    $FullName = "$($Employee.FirstName) $($Employee.LastName)"

    $ExistingUser = Get-ADUser -Filter "SamAccountName -eq '$($Employee.Username)'" -ErrorAction SilentlyContinue
    if ($ExistingUser) {
        Write-Host "[=] Account exists: $($Employee.Username) — will repair attributes in Phase B." -ForegroundColor Yellow
        $ProvisionQueue += [PSCustomObject]@{
            Employee       = $Employee
            FullName       = $FullName
            EmploymentType = $EmploymentType
            TargetOU       = $ExistingUser.DistinguishedName
            AccountAction  = "Already Existed"
        }
        continue
    }

    $TargetOU = "OU=$EmploymentType,OU=$($Employee.Department),$UsersOU"
    if (-not (Get-ADOrganizationalUnit -Identity $TargetOU -ErrorAction SilentlyContinue)) {
        Write-Host "[X] Destination OU missing: $TargetOU" -ForegroundColor Red
        $FailedCount++
        continue
    }

    try {
        $NewUserParams = @{
            Name                  = $FullName
            GivenName             = $Employee.FirstName
            Surname               = $Employee.LastName
            DisplayName           = $FullName
            SamAccountName        = $Employee.Username
            UserPrincipalName     = "$($Employee.Username)@$UPNSuffix"
            Path                  = $TargetOU
            AccountPassword       = $InitialPassword
            Enabled               = $true
            ChangePasswordAtLogon = $true
        }
        New-ADUser @NewUserParams -ErrorAction Stop
        Write-Host "[+] Created: $($Employee.Username)" -ForegroundColor Green

        $ProvisionQueue += [PSCustomObject]@{
            Employee       = $Employee
            FullName       = $FullName
            EmploymentType = $EmploymentType
            TargetOU       = $TargetOU
            AccountAction  = "Created"
        }
    }
    catch {
        Write-Host "[X] FAILED: $($Employee.Username) — $($_.Exception.Message)" -ForegroundColor Red
        $FailedCount++
        $ProvisionQueue += [PSCustomObject]@{
            Employee       = $Employee
            FullName       = $FullName
            EmploymentType = $EmploymentType
            TargetOU       = $TargetOU
            AccountAction  = "Failed"
            AccountError   = $_.Exception.Message
        }
    }
}

# ----------------------------------------------------------------------------
# 12. PHASE B — ATTRIBUTES + GROUP MEMBERSHIP
# ----------------------------------------------------------------------------
Write-Host ""
Write-Host "============================================================"
Write-Host " PHASE B — APPLYING ATTRIBUTES + GROUP MEMBERSHIP"
Write-Host "============================================================"

$Report        = @()
$CreatedCount  = 0
$ExistingCount = 0

foreach ($Item in $ProvisionQueue) {

    $Employee = $Item.Employee
    $AttrsApplied = $false
    $GroupAssigned = $false
    $AttributeError = $null
    $GroupError = $null

    if ($Item.AccountAction -eq "Failed") {
        $Report += [PSCustomObject]@{
            EmployeeID=$Employee.EmployeeID; Username=$Employee.Username
            Name=$Item.FullName; Department=$Employee.Department
            Role=$Employee.Role; EmploymentType=$Item.EmploymentType
            Location=$Employee.Location; Country=$Employee.CountryRegion
            VLAN=$Employee.VLAN; OfficeSubnet=$Employee.OfficeSubnet
            RemoteSubnet=$Employee.RemoteSubnet; SecurityGroup=$Employee.SecurityGroup
            OU=$Item.TargetOU
            Status="FAILED (account not created: $($Item.AccountError))"
            Date=Get-Date
        }
        continue
    }

    $ADUserObject = $null
    for ($Attempt=1; $Attempt -le 3; $Attempt++) {
        $ADUserObject = Get-ADUser -Identity $Employee.Username -ErrorAction SilentlyContinue
        if ($ADUserObject) { break }
        Start-Sleep -Seconds 2
    }

    if (-not $ADUserObject) {
        $Report += [PSCustomObject]@{
            EmployeeID=$Employee.EmployeeID; Username=$Employee.Username
            Name=$Item.FullName; Department=$Employee.Department
            Role=$Employee.Role; EmploymentType=$Item.EmploymentType
            Location=$Employee.Location; Country=$Employee.CountryRegion
            VLAN=$Employee.VLAN; OfficeSubnet=$Employee.OfficeSubnet
            RemoteSubnet=$Employee.RemoteSubnet; SecurityGroup=$Employee.SecurityGroup
            OU=$Item.TargetOU
            Status="Account exists but not locatable for attribute update"
            Date=Get-Date
        }
        continue
    }

    try {
        Set-ADUser -Identity $ADUserObject.DistinguishedName `
            -Department  $Employee.Department `
            -Title       $Employee.Role `
            -Description "$($Item.EmploymentType) | $($Employee.Location) | VLAN $($Employee.VLAN)" `
            -ErrorAction Stop
        $AttrsApplied = $true
        Write-Host "[+] Attributes applied: $($Employee.Username)" -ForegroundColor Green
    }
    catch {
        $AttributeError = $_.Exception.Message
        Write-Host "[!] Attribute failure: $($Employee.Username) — $AttributeError" -ForegroundColor Yellow
    }

    if (-not [string]::IsNullOrWhiteSpace($Employee.SecurityGroup)) {
        try {
            Add-ADGroupMember -Identity $Employee.SecurityGroup `
                -Members $ADUserObject.DistinguishedName -ErrorAction Stop
            $GroupAssigned = $true
            Write-Host "[+] Group assigned: $($Employee.SecurityGroup)" -ForegroundColor Green
        }
        catch {
            $GroupError = $_.Exception.Message
            Write-Host "[!] Group failure: $($Employee.SecurityGroup) — $GroupError" -ForegroundColor Yellow
        }
    }

    if ($Item.AccountAction -eq "Created") { $CreatedCount++ } else { $ExistingCount++ }

    $StatusParts = @($Item.AccountAction)
    $StatusParts += if ($AttrsApplied) { "Attributes Applied" } else { "Attributes FAILED: $AttributeError" }
    if ($Employee.SecurityGroup) {
        $StatusParts += if ($GroupAssigned) { "Group Assigned" } else { "Group FAILED: $GroupError" }
    }

    $Report += [PSCustomObject]@{
        EmployeeID=$Employee.EmployeeID; Username=$Employee.Username
        Name=$Item.FullName; Department=$Employee.Department
        Role=$Employee.Role; EmploymentType=$Item.EmploymentType
        Location=$Employee.Location; Country=$Employee.CountryRegion
        VLAN=$Employee.VLAN; OfficeSubnet=$Employee.OfficeSubnet
        RemoteSubnet=$Employee.RemoteSubnet; SecurityGroup=$Employee.SecurityGroup
        OU=$Item.TargetOU
        Status=($StatusParts -join " | ")
        Date=Get-Date
    }
}

# ----------------------------------------------------------------------------
# 13. EXPORT AUDIT REPORT
# ----------------------------------------------------------------------------
$Report | Export-Csv -Path $ReportPath -NoTypeInformation -Encoding UTF8

Write-Host ""
Write-Host "============================================================"
Write-Host " DOBRE LTD PROVISIONING SUMMARY"
Write-Host "============================================================"
Write-Host "Users Created:     $CreatedCount"   -ForegroundColor Green
Write-Host "Already Existing:  $ExistingCount"  -ForegroundColor Yellow
Write-Host "Failed:            $FailedCount"    -ForegroundColor Red
Write-Host ""
Write-Host "Audit Report: $ReportPath" -ForegroundColor Cyan
Write-Host ""