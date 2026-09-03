<#
================================================================================
 DOBRE LTD
 ACTIVE DIRECTORY PROVISIONING ENGINE  (FIXED)
================================================================================
DOMAIN:
    dobre.local
EXISTING COMPANY OU:
    OU=dobre.local,DC=dobre,DC=local
LOCAL FILE DIRECTORY:
    C:\Scripts
INPUT:
    C:\Scripts\Dobre_Ltd_AD_User_Provisioning_Input.xlsx
OUTPUT:
    C:\Scripts\AD_Provisioning_Report.csv
REQUIRED MODULES:
    ActiveDirectory
    ImportExcel

FIX NOTES (what changed vs the original):
  1. New-ADUser now uses a SPLATTED HASHTABLE ( @{ } + -HashArguments )
     instead of long backtick (`) continued lines. Backtick continuations
     are fragile - copying the script out of a PDF/Word doc can silently
     insert or drop whitespace after a backtick, which breaks the parameter
     list and makes PowerShell fall back to prompting you interactively
     for missing values (which is what you were seeing).
  2. User creation is now split into two steps, as you asked:
       Step A - New-ADUser with only the REQUIRED core identity attributes.
       Step B - Set-ADUser afterward to apply Department, Title, Description.
     This also means if Step B fails for some reason, the account still
     exists and the report reflects that accurately.
  3. Add-ADGroupMember failures no longer silently pass - they're caught
     and reported separately from account-creation failures.
  4. Removed the interactive "Press Enter to continue" prompt from the
     diagnostic block. The script now takes exactly ONE piece of manual
     input for the entire run - the temporary password in Section 15.
     Every other value (name, username, department, role, employment
     type, location, VLAN, subnets, security group, etc.) is read
     straight from the Employees worksheet in the input .xlsx.
  5. Provisioning is now a genuine TWO-PHASE process (Section 16):
       Phase A - creates every account (identity attributes only) for
                 the whole spreadsheet.
       Phase B - runs only AFTER Phase A finishes for everyone, and then
                 applies Department, Title, Description, and security
                 group membership to every account - whether it was
                 just created in Phase A or already existed. This is
                 the actual fix for accounts landing in the right OU
                 but coming up blank on Department/Title: the account
                 attributes were being applied in the same iteration as
                 creation, which can run ahead of AD replication. Re-run
                 the script any time to repair accounts that are still
                 missing these fields - it will not try to recreate
                 accounts that already exist, it will just patch them.
================================================================================
#>

# ============================================================================
# 1. INITIALIZATION
# ============================================================================
Clear-Host
$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "          DOBRE LTD  AD PROVISIONING ENGINE                 " -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

# ============================================================================
# 2. LOAD REQUIRED MODULES
# ============================================================================
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
    Write-Host ""
    Write-Host "Install it with:"
    Write-Host "    Install-Module ImportExcel -Scope CurrentUser"
    exit 1
}

# ============================================================================
# 3. CONFIGURATION
# ============================================================================
$WorkingDirectory = "C:\Scripts"
$ExcelPath        = "$WorkingDirectory\Dobre_Ltd_AD_User_Provisioning_Input.xlsx"
$ReportPath       = "$WorkingDirectory\AD_Provisioning_Report.csv"
$DomainDN         = "DC=dobre,DC=local"
$CompanyOU        = "OU=dobre.local,$DomainDN"
$UsersOU          = "OU=Users,$CompanyOU"
$GroupsOU         = "OU=Groups,$CompanyOU"
$UPNSuffix        = "dobre.local"

# ============================================================================
# 4. VERIFY FILE DIRECTORY
# ============================================================================
if (-not (Test-Path $WorkingDirectory)) {
    Write-Host "[X] Directory does not exist: $WorkingDirectory" -ForegroundColor Red
    exit 1
}

# ============================================================================
# 5. VERIFY EXCEL FILE
# ============================================================================
Write-Host ""
Write-Host "[*] Checking Excel input file..." -ForegroundColor Cyan

if (-not (Test-Path $ExcelPath)) {
    Write-Host "[X] Excel file was not found: $ExcelPath" -ForegroundColor Red
    exit 1
}
Write-Host "[+] Excel file found." -ForegroundColor Green

# ============================================================================
# 6. VERIFY EXISTING COMPANY OU
# ============================================================================
Write-Host ""
Write-Host "[*] Verifying Dobre Ltd company OU..." -ForegroundColor Cyan

$CompanyOUObject = Get-ADOrganizationalUnit -Identity $CompanyOU -ErrorAction SilentlyContinue
if (-not $CompanyOUObject) {
    Write-Host ""
    Write-Host "[X] Company OU was not found: $CompanyOU" -ForegroundColor Red
    Write-Host "The script will NOT create another top-level OU."
    exit 1
}
Write-Host "[+] Existing company OU confirmed." -ForegroundColor Green

# ============================================================================
# 7. FUNCTION - CREATE OU SAFELY
# ============================================================================
function Ensure-OU {
    param(
        [Parameter(Mandatory = $true)] [string]$Name,
        [Parameter(Mandatory = $true)] [string]$ParentDN
    )

    $TargetDN = "OU=$Name,$ParentDN"
    $ExistingOU = Get-ADOrganizationalUnit -Identity $TargetDN -ErrorAction SilentlyContinue

    if (-not $ExistingOU) {
        New-ADOrganizationalUnit -Name $Name -Path $ParentDN -ProtectedFromAccidentalDeletion $true
        Write-Host "[+] Created OU: $TargetDN" -ForegroundColor Green
    }
    else {
        Write-Host "[=] OU already exists: $TargetDN" -ForegroundColor DarkGray
    }

    return $TargetDN
}

# ============================================================================
# 8. FUNCTION - CREATE SECURITY GROUP SAFELY
# ============================================================================
function Ensure-SecurityGroup {
    param(
        [Parameter(Mandatory = $true)] [string]$GroupName
    )

    $ExistingGroup = Get-ADGroup -Filter "SamAccountName -eq '$GroupName'" -ErrorAction SilentlyContinue

    if (-not $ExistingGroup) {
        New-ADGroup -Name $GroupName -SamAccountName $GroupName -GroupScope Global -GroupCategory Security -Path $GroupsOU
        Write-Host "[+] Created Security Group: $GroupName" -ForegroundColor Yellow
    }
    else {
        Write-Host "[=] Group already exists: $GroupName" -ForegroundColor DarkGray
    }
}

# ============================================================================
# 9. CREATE BASE OUs
# ============================================================================
Write-Host ""
Write-Host "============================================================"
Write-Host " CREATING AD STRUCTURE"
Write-Host "============================================================"

Ensure-OU -Name "Users"  -ParentDN $CompanyOU | Out-Null
Ensure-OU -Name "Groups" -ParentDN $CompanyOU | Out-Null

# ============================================================================
# 10. IMPORT EXCEL DATA
# ============================================================================
Write-Host ""
Write-Host "[*] Loading employee database..." -ForegroundColor Cyan

try {
    # -DataOnly forces ImportExcel to read cached CALCULATED values rather
    # than formula objects/hyperlink objects, which is a common cause of
    # "blank" fields even though the sheet looks fine visually.
    $Employees = Import-Excel -Path $ExcelPath -WorksheetName "Employees" -DataOnly -ErrorAction Stop
}
catch {
    Write-Host ""
    Write-Host "[X] Failed to import Excel file." -ForegroundColor Red
    Write-Host $_.Exception.Message
    exit 1
}

if (-not $Employees) {
    Write-Host "[X] Employees worksheet contains no records." -ForegroundColor Red
    exit 1
}

Write-Host "[+] Excel successfully loaded." -ForegroundColor Green
Write-Host "[+] Employee records found: $($Employees.Count)" -ForegroundColor Green

# ============================================================================
# 11. VALIDATE EXCEL COLUMNS
# ============================================================================
Write-Host ""
Write-Host "[*] Validating Excel structure..." -ForegroundColor Cyan

$RequiredColumns = @(
    "EmployeeID","FirstName","LastName","Username","Department","Role",
    "EmploymentType","Location","CountryRegion","OfficeSubnet","RemoteSubnet",
    "VLAN","SecurityGroup","OUPath"
)

$ExcelColumns = $Employees[0].PSObject.Properties.Name

foreach ($Column in $RequiredColumns) {
    if ($ExcelColumns -notcontains $Column) {
        Write-Host ""
        Write-Host "[X] Missing Excel column: $Column" -ForegroundColor Red
        Write-Host ""
        Write-Host "Columns found:" -ForegroundColor Yellow
        $ExcelColumns | ForEach-Object { Write-Host "    $_" }
        exit 1
    }
}
Write-Host "[+] Excel structure validated." -ForegroundColor Green

# ============================================================================
# 11B. DIAGNOSTIC - DUMP RAW VALUES FOR EVERY ROW
# ============================================================================
# This block prints exactly what PowerShell sees for the fields New-ADUser
# actually depends on, for EVERY row, with quotes wrapped around each value
# so blank / whitespace-only / hidden-character values are visible.
#
# NOTE: this is fully non-interactive. It only writes to the console and
# does NOT pause the script. (The original version had a "Press Enter to
# continue" prompt here - that was removed because the only manual input
# this script should ever ask for is the temporary password in Section 15.)
# ============================================================================
Write-Host ""
Write-Host "============================================================"
Write-Host " DIAGNOSTIC: RAW FIELD DUMP (per row)"
Write-Host "============================================================"

$RowNumber = 1
$DiagnosticIssueFound = $false
foreach ($Row in $Employees) {
    Write-Host ""
    Write-Host "Row $RowNumber :"
    Write-Host "  FirstName      = '$($Row.FirstName)'"
    Write-Host "  LastName       = '$($Row.LastName)'"
    Write-Host "  Username       = '$($Row.Username)'"
    Write-Host "  Department     = '$($Row.Department)'"
    Write-Host "  EmploymentType = '$($Row.EmploymentType)'"
    Write-Host "  SecurityGroup  = '$($Row.SecurityGroup)'"
    $FNType = if ($null -eq $Row.FirstName) { "NULL" } else { $Row.FirstName.GetType().FullName }
    $UNType = if ($null -eq $Row.Username)  { "NULL" } else { $Row.Username.GetType().FullName }
    Write-Host "  FirstName Type = $FNType"
    Write-Host "  Username  Type = $UNType"

    if ([string]::IsNullOrWhiteSpace($Row.FirstName) -or [string]::IsNullOrWhiteSpace($Row.Username)) {
        $DiagnosticIssueFound = $true
    }
    $RowNumber++
}

Write-Host ""
Write-Host "============================================================"
Write-Host " END DIAGNOSTIC DUMP"
Write-Host "============================================================"
if ($DiagnosticIssueFound) {
    Write-Host "[!] One or more rows have blank FirstName/Username values." -ForegroundColor Yellow
    Write-Host "    Those rows will fail validation and be skipped automatically" -ForegroundColor Yellow
    Write-Host "    later in the run - no action needed now." -ForegroundColor Yellow
}
else {
    Write-Host "[+] No blank FirstName/Username values detected." -ForegroundColor Green
}
Write-Host ""

# ============================================================================
# 12. DISCOVER DEPARTMENTS
# ============================================================================
$Departments = $Employees |
    Select-Object -ExpandProperty Department -Unique |
    Where-Object { -not [string]::IsNullOrWhiteSpace($_) }

Write-Host ""
Write-Host "[*] Departments discovered:" -ForegroundColor Cyan
foreach ($Department in $Departments) {
    Write-Host "    + $Department"
}

# ============================================================================
# 13. CREATE DEPARTMENT STRUCTURE
# ============================================================================
Write-Host ""
Write-Host "============================================================"
Write-Host " CREATING DEPARTMENT OU STRUCTURE"
Write-Host "============================================================"

foreach ($Department in $Departments) {
    $DepartmentOU = Ensure-OU -Name $Department -ParentDN $UsersOU
    Ensure-OU -Name "OnSite" -ParentDN $DepartmentOU | Out-Null
    Ensure-OU -Name "Remote" -ParentDN $DepartmentOU | Out-Null
}

# ============================================================================
# 14. CREATE SECURITY GROUPS
# ============================================================================
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

# ============================================================================
# 15. REQUEST TEMPORARY PASSWORD
# ============================================================================
Write-Host ""
Write-Host "============================================================"
Write-Host " TEMPORARY PASSWORD CONFIGURATION"
Write-Host "============================================================"
Write-Host ""
Write-Host "The password will NOT be stored in Excel."
Write-Host "It will be securely supplied to newly created accounts."
Write-Host ""

$InitialPassword = Read-Host "Enter temporary password for new accounts" -AsSecureString

# ============================================================================
# 16. PROVISION USERS  (TWO PHASES)
# ============================================================================
# WHY TWO PHASES:
# Previously, account creation (New-ADUser) and attribute assignment
# (Set-ADUser / Add-ADGroupMember) happened back-to-back for each user in
# the SAME loop iteration. In a multi-DC environment this can run the
# Set-ADUser / Add-ADGroupMember calls before the newly created account
# has replicated to the domain controller PowerShell is querying, which
# was silently leaving Department, Title, Description, and group
# membership unset even though the account itself was created fine.
#
# PHASE A creates every account (identity attributes only) for every
# employee in the spreadsheet.
# PHASE B runs AFTER Phase A has finished for the ENTIRE spreadsheet, and
# applies Department / Title / Description / group membership to every
# employee that has an AD account - whether it was just created in Phase A
# or already existed beforehand. This means re-running the script against
# employees who were created earlier (with missing attributes) will now
# repair them, without trying to recreate the account.
# ============================================================================
Write-Host ""
Write-Host "============================================================"
Write-Host " PHASE A - CREATING ACCOUNTS"
Write-Host "============================================================"

$ProvisionQueue = @()
$FailedCount    = 0

foreach ($RawEmployee in $Employees) {

    # ------------------------------------------------------------------
    # Normalize: convert every value to a trimmed string up front.
    # This neutralizes hidden whitespace, hyperlink objects, and
    # numeric/date auto-typing from Excel, all in one place, so every
    # check below is working against a clean, predictable value.
    # ------------------------------------------------------------------
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

    Write-Host ""
    Write-Host "------------------------------------------------------------"
    Write-Host "Processing employee"
    Write-Host "Name:       $($Employee.FirstName) $($Employee.LastName)"
    Write-Host "Username:   $($Employee.Username)"
    Write-Host "Department: $($Employee.Department)"
    Write-Host "Role:       $($Employee.Role)"
    Write-Host "Type:       $($Employee.EmploymentType)"
    Write-Host "Location:   $($Employee.Location)"
    Write-Host "------------------------------------------------------------"

    # ------------------------------------------------------------------
    # Validate required employee information
    # ------------------------------------------------------------------
    if ([string]::IsNullOrWhiteSpace($Employee.FirstName) -or
        [string]::IsNullOrWhiteSpace($Employee.LastName) -or
        [string]::IsNullOrWhiteSpace($Employee.Username) -or
        [string]::IsNullOrWhiteSpace($Employee.Department) -or
        [string]::IsNullOrWhiteSpace($Employee.EmploymentType)) {

        Write-Host "[X] Required employee information is missing." -ForegroundColor Red
        $FailedCount++
        continue
    }

    # ------------------------------------------------------------------
    # Validate Remote / OnSite classification
    # ------------------------------------------------------------------
    $EmploymentType = $Employee.EmploymentType.Trim()

    if ($EmploymentType -notin @("Remote", "OnSite")) {
        Write-Host "[X] Invalid EmploymentType: $EmploymentType" -ForegroundColor Red
        Write-Host "    Valid values are: Remote or OnSite"
        $FailedCount++
        continue
    }

    $FullName = "$($Employee.FirstName) $($Employee.LastName)"

    # ------------------------------------------------------------------
    # Check whether the account already exists
    # ------------------------------------------------------------------
    $ExistingUser = Get-ADUser -Filter "SamAccountName -eq '$($Employee.Username)'" -ErrorAction SilentlyContinue

    if ($ExistingUser) {
        Write-Host "[=] Account already exists: $($Employee.Username) - will still check/repair its attributes in Phase B." -ForegroundColor Yellow

        $ProvisionQueue += [PSCustomObject]@{
            Employee       = $Employee
            FullName       = $FullName
            EmploymentType = $EmploymentType
            TargetOU       = $ExistingUser.DistinguishedName
            AccountAction  = "Already Existed"
        }
        continue
    }

    # ------------------------------------------------------------------
    # Determine + verify destination OU
    # ------------------------------------------------------------------
    $TargetOU = "OU=$EmploymentType,OU=$($Employee.Department),$UsersOU"
    $TargetOUObject = Get-ADOrganizationalUnit -Identity $TargetOU -ErrorAction SilentlyContinue

    if (-not $TargetOUObject) {
        Write-Host "[X] Destination OU does not exist: $TargetOU" -ForegroundColor Red
        $FailedCount++
        continue
    }

    # ------------------------------------------------------------------
    # STEP A - Create user with core REQUIRED identity attributes only.
    # Using a splatted hashtable (@NewUserParams) instead of backtick
    # line continuations avoids the parsing corruption that was causing
    # PowerShell to prompt you interactively.
    # ------------------------------------------------------------------
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

        Write-Host "[+] Account object created: $($Employee.Username)" -ForegroundColor Green

        $ProvisionQueue += [PSCustomObject]@{
            Employee       = $Employee
            FullName       = $FullName
            EmploymentType = $EmploymentType
            TargetOU       = $TargetOU
            AccountAction  = "Created"
        }
    }
    catch {
        Write-Host ""
        Write-Host "[X] FAILED TO CREATE ACCOUNT" -ForegroundColor Red
        Write-Host "    $($_.Exception.Message)"
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

Write-Host ""
Write-Host "[+] Phase A complete. $($ProvisionQueue.Count) account(s) queued for attribute assignment." -ForegroundColor Green

# ============================================================================
# 16B. PHASE B - APPLY PROFILE ATTRIBUTES + GROUP MEMBERSHIP
# ============================================================================
Write-Host ""
Write-Host "============================================================"
Write-Host " PHASE B - APPLYING DEPARTMENT / TITLE / DESCRIPTION / GROUPS"
Write-Host "============================================================"

$Report        = @()
$CreatedCount  = 0
$ExistingCount = 0

foreach ($Item in $ProvisionQueue) {

    $Employee       = $Item.Employee
    $EmploymentType = $Item.EmploymentType
    $FullName       = $Item.FullName
    $AttributeError = $null
    $GroupError     = $null
    $GroupAssigned  = $false
    $AttrsApplied   = $false

    if ($Item.AccountAction -eq "Failed") {
        # Account never got created - nothing to update. Record as-is.
        $Report += [PSCustomObject]@{
            EmployeeID     = $Employee.EmployeeID
            Username       = $Employee.Username
            Name           = $FullName
            Department     = $Employee.Department
            Role           = $Employee.Role
            EmploymentType = $EmploymentType
            Location       = $Employee.Location
            Country        = $Employee.CountryRegion
            VLAN           = $Employee.VLAN
            OfficeSubnet   = $Employee.OfficeSubnet
            RemoteSubnet   = $Employee.RemoteSubnet
            SecurityGroup  = $Employee.SecurityGroup
            OU             = $Item.TargetOU
            Status         = "FAILED (account not created: $($Item.AccountError))"
            Date           = Get-Date
        }
        continue
    }

    Write-Host ""
    Write-Host "Updating: $($Employee.Username)  ($($Item.AccountAction))"

    # ------------------------------------------------------------------
    # Confirm the account is actually visible before touching it.
    # A few retries with a short pause protects against AD replication
    # lag between the domain controller that serviced New-ADUser and the
    # one servicing this query - this is what was causing attributes to
    # silently fail to apply in the single-pass version of the script.
    # ------------------------------------------------------------------
    $ADUserObject = $null
    for ($Attempt = 1; $Attempt -le 3; $Attempt++) {
        $ADUserObject = Get-ADUser -Identity $Employee.Username -ErrorAction SilentlyContinue
        if ($ADUserObject) { break }
        Start-Sleep -Seconds 2
    }

    if (-not $ADUserObject) {
        Write-Host "[X] Could not locate account for attribute update: $($Employee.Username)" -ForegroundColor Red
        $Report += [PSCustomObject]@{
            EmployeeID     = $Employee.EmployeeID
            Username       = $Employee.Username
            Name           = $FullName
            Department     = $Employee.Department
            Role           = $Employee.Role
            EmploymentType = $EmploymentType
            Location       = $Employee.Location
            Country        = $Employee.CountryRegion
            VLAN           = $Employee.VLAN
            OfficeSubnet   = $Employee.OfficeSubnet
            RemoteSubnet   = $Employee.RemoteSubnet
            SecurityGroup  = $Employee.SecurityGroup
            OU             = $Item.TargetOU
            Status         = "Account exists but could not be located for attribute update"
            Date           = Get-Date
        }
        continue
    }

    # ------------------------------------------------------------------
    # Apply Department / Title / Description via Set-ADUser
    # ------------------------------------------------------------------
    try {
        $SetUserParams = @{
            Identity    = $ADUserObject.DistinguishedName
            Department  = $Employee.Department
            Title       = $Employee.Role
            Description = "$EmploymentType | $($Employee.Location) | VLAN $($Employee.VLAN)"
        }
        Set-ADUser @SetUserParams -ErrorAction Stop
        $AttrsApplied = $true
        Write-Host "[+] Profile attributes applied (Department/Title/Description)." -ForegroundColor Green
    }
    catch {
        $AttributeError = $_.Exception.Message
        Write-Host "[!] Failed to set profile attributes: $AttributeError" -ForegroundColor Yellow
    }

    # ------------------------------------------------------------------
    # Add security group membership (idempotent - Add-ADGroupMember does
    # not error if the user is already a member)
    # ------------------------------------------------------------------
    if (-not [string]::IsNullOrWhiteSpace($Employee.SecurityGroup)) {
        try {
            Add-ADGroupMember -Identity $Employee.SecurityGroup -Members $ADUserObject.DistinguishedName -ErrorAction Stop
            $GroupAssigned = $true
            Write-Host "[+] Added to security group: $($Employee.SecurityGroup)" -ForegroundColor Green
        }
        catch {
            $GroupError = $_.Exception.Message
            Write-Host "[!] Failed to add to group '$($Employee.SecurityGroup)': $GroupError" -ForegroundColor Yellow
        }
    }

    # ------------------------------------------------------------------
    # Build final status for the report
    # ------------------------------------------------------------------
    if ($Item.AccountAction -eq "Created") { $CreatedCount++ } else { $ExistingCount++ }

    $StatusParts = @($Item.AccountAction)
    $StatusParts += if ($AttrsApplied) { "Attributes Applied" } else { "Attributes FAILED: $AttributeError" }
    if (-not [string]::IsNullOrWhiteSpace($Employee.SecurityGroup)) {
        $StatusParts += if ($GroupAssigned) { "Group Assigned" } else { "Group FAILED: $GroupError" }
    }
    $FinalStatus = $StatusParts -join " | "

    $Report += [PSCustomObject]@{
        EmployeeID     = $Employee.EmployeeID
        Username       = $Employee.Username
        Name           = $FullName
        Department     = $Employee.Department
        Role           = $Employee.Role
        EmploymentType = $EmploymentType
        Location       = $Employee.Location
        Country        = $Employee.CountryRegion
        VLAN           = $Employee.VLAN
        OfficeSubnet   = $Employee.OfficeSubnet
        RemoteSubnet   = $Employee.RemoteSubnet
        SecurityGroup  = $Employee.SecurityGroup
        OU             = $Item.TargetOU
        Status         = $FinalStatus
        Date           = Get-Date
    }
}

# ============================================================================
# 17. EXPORT AUDIT REPORT
# ============================================================================
Write-Host ""
Write-Host "============================================================"
Write-Host " GENERATING AUDIT REPORT"
Write-Host "============================================================"

$Report | Export-Csv -Path $ReportPath -NoTypeInformation -Encoding UTF8

Write-Host "[+] Audit report generated:" -ForegroundColor Green
Write-Host "    $ReportPath"

# ============================================================================
# 18. FINAL SUMMARY
# ============================================================================
Write-Host ""
Write-Host ""
Write-Host "============================================================"
Write-Host " DOBRE LTD PROVISIONING SUMMARY"
Write-Host "============================================================"
Write-Host ""
Write-Host "Users Created:     $CreatedCount" -ForegroundColor Green
Write-Host "Already Existing:  $ExistingCount" -ForegroundColor Yellow
Write-Host "Failed:            $FailedCount" -ForegroundColor Red
Write-Host ""
Write-Host "Audit Report:"
Write-Host "    $ReportPath" -ForegroundColor Cyan
Write-Host ""

if ($FailedCount -eq 0) {
    Write-Host "============================================================"
    Write-Host " PROVISIONING COMPLETED SUCCESSFULLY"
    Write-Host "============================================================" -ForegroundColor Green
}
else {
    Write-Host "============================================================"
    Write-Host " PROVISIONING COMPLETED WITH ERRORS"
    Write-Host "============================================================" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Review the audit report for failed accounts." -ForegroundColor Yellow
}

Write-Host ""
