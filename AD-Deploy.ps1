<#
================================================================================
 DOBRE TECHNOLOGIES
 ACTIVE DIRECTORY ENTERPRISE PROVISIONING ENGINE
================================================================================

 DOMAIN:
     dobre.local

 DOMAIN CONTROLLER:
     DC1.dobre.local

 INPUT:
     C:\AD-Deploy\users.csv

 LOG:
     C:\AD-Deploy\deploy.log

 ARCHITECTURE:
     DC=dobre,DC=local
       |
       +-- _ADMIN
       |    +-- ServiceAccounts
       |    +-- Tier0-Admins
       |    +-- Tier1-Admins
       |    +-- Tier2-Admins
       |
       +-- PRODUCTION
       |    +-- Users
       |    |    +-- FIN
       |    |    +-- HR
       |    |    +-- IT
       |    +-- Computers
       |    +-- Servers
       |    +-- Groups
       |
       +-- BACKUP
       |    +-- Computers
       |    +-- Servers
       |    +-- Groups
       |
       +-- REMOTE-ADMIN
       |    +-- Users
       |    +-- Groups
       |
       +-- SERVICE-ACCOUNTS

================================================================================
#>

Clear-Host
$ErrorActionPreference = "Stop"

# ============================================================================
# 1. CONFIGURATION
# ============================================================================

$DomainController = "DC1.dobre.local"
$DomainDN         = "DC=dobre,DC=local"
$DomainDNS        = "dobre.local"

$UserFile         = "C:\AD-Deploy\users.csv"
$LogPath          = "C:\AD-Deploy\deploy.log"

$DefaultUserPassword = "Welcome@2024!"
$ServiceAccountPassword = "ChangeMe!2024#Strong"

# ============================================================================
# 2. INITIALIZATION
# ============================================================================

if (-not (Test-Path "C:\AD-Deploy")) {
    New-Item -Path "C:\AD-Deploy" -ItemType Directory -Force | Out-Null
}

Start-Transcript -Path $LogPath -Append

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "       DOBRE TECHNOLOGIES AD PROVISIONING ENGINE" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

# ============================================================================
# 3. LOAD ACTIVE DIRECTORY MODULE
# ============================================================================

Write-Host "[*] Loading Active Directory module..." -ForegroundColor Cyan

try {
    Import-Module ActiveDirectory -ErrorAction Stop
    Write-Host "[+] ActiveDirectory module loaded." -ForegroundColor Green
}
catch {
    Write-Host "[X] Failed to load ActiveDirectory module." -ForegroundColor Red
    Stop-Transcript
    exit 1
}

# ============================================================================
# 4. VERIFY DOMAIN CONTROLLER
# ============================================================================

Write-Host ""
Write-Host "[*] Verifying domain controller..." -ForegroundColor Cyan

try {
    $DC = Get-ADDomainController `
        -Identity $DomainController `
        -ErrorAction Stop

    Write-Host "[+] Domain Controller: $($DC.HostName)" -ForegroundColor Green
    Write-Host "[+] IPv4 Address:      $($DC.IPv4Address)" -ForegroundColor Green
    Write-Host "[+] Global Catalog:    $($DC.IsGlobalCatalog)" -ForegroundColor Green
    Write-Host "[+] Read Only:         $($DC.IsReadOnly)" -ForegroundColor Green
}
catch {
    Write-Host "[X] Cannot contact $DomainController" -ForegroundColor Red
    Write-Host $_.Exception.Message
    Stop-Transcript
    exit 1
}

# ============================================================================
# 5. VERIFY DOMAIN
# ============================================================================

Write-Host ""
Write-Host "[*] Verifying domain..." -ForegroundColor Cyan

try {
    $Domain = Get-ADDomain `
        -Server $DomainController `
        -ErrorAction Stop

    if ($Domain.DistinguishedName -ne $DomainDN) {
        Write-Host "[X] Domain DN mismatch." -ForegroundColor Red
        Write-Host "Expected: $DomainDN"
        Write-Host "Found:    $($Domain.DistinguishedName)"
        Stop-Transcript
        exit 1
    }

    Write-Host "[+] DNS Root: $($Domain.DNSRoot)" -ForegroundColor Green
    Write-Host "[+] Domain DN: $($Domain.DistinguishedName)" -ForegroundColor Green
}
catch {
    Write-Host "[X] Unable to verify domain." -ForegroundColor Red
    Write-Host $_.Exception.Message
    Stop-Transcript
    exit 1
}

# ============================================================================
# 6. STATISTICS
# ============================================================================

$Stats = [ordered]@{
    OUsCreated          = 0
    OUsExisting         = 0
    GroupsCreated       = 0
    GroupsExisting      = 0
    ServiceAccounts     = 0
    UsersCreated        = 0
    UsersExisting       = 0
    UsersFailed         = 0
    GroupAssignments    = 0
    GroupAssignmentFail = 0
}

# ============================================================================
# 7. FUNCTION - ENSURE OU
# ============================================================================

function Ensure-OU {

    param(
        [Parameter(Mandatory = $true)]
        [string]$Name,

        [Parameter(Mandatory = $true)]
        [string]$ParentDN
    )

    $TargetDN = "OU=$Name,$ParentDN"

    try {

        $Existing = Get-ADOrganizationalUnit `
            -Identity $TargetDN `
            -Server $DomainController `
            -ErrorAction SilentlyContinue

        if ($Existing) {

            Write-Host "[=] OU already exists: $TargetDN" `
                -ForegroundColor DarkGray

            $Stats.OUsExisting++

            return $TargetDN
        }

        New-ADOrganizationalUnit `
            -Name $Name `
            -Path $ParentDN `
            -Server $DomainController `
            -ProtectedFromAccidentalDeletion $true `
            -ErrorAction Stop

        Write-Host "[+] OU created: $TargetDN" `
            -ForegroundColor Green

        $Stats.OUsCreated++

        return $TargetDN
    }
    catch {

        Write-Host ""
        Write-Host "[X] FAILED TO CREATE OU" -ForegroundColor Red
        Write-Host "    Name:   $Name"
        Write-Host "    Parent: $ParentDN"
        Write-Host "    Target: $TargetDN"
        Write-Host "    Error:  $($_.Exception.Message)"
        Write-Host ""

        throw
    }
}

# ============================================================================
# 8. CREATE ENTERPRISE OU STRUCTURE
# ============================================================================

Write-Host ""
Write-Host "============================================================"
Write-Host " CREATING ENTERPRISE OU STRUCTURE"
Write-Host "============================================================"
Write-Host ""

try {

    # ------------------------------------------------------------------------
    # _ADMIN
    # ------------------------------------------------------------------------

    $AdminOU = Ensure-OU `
        -Name "_ADMIN" `
        -ParentDN $DomainDN

    $AdminServiceOU = Ensure-OU `
        -Name "ServiceAccounts" `
        -ParentDN $AdminOU

    $Tier0OU = Ensure-OU `
        -Name "Tier0-Admins" `
        -ParentDN $AdminOU

    $Tier1OU = Ensure-OU `
        -Name "Tier1-Admins" `
        -ParentDN $AdminOU

    $Tier2OU = Ensure-OU `
        -Name "Tier2-Admins" `
        -ParentDN $AdminOU


    # ------------------------------------------------------------------------
    # PRODUCTION
    # ------------------------------------------------------------------------

    $ProductionOU = Ensure-OU `
        -Name "PRODUCTION" `
        -ParentDN $DomainDN

    $ProductionUsersOU = Ensure-OU `
        -Name "Users" `
        -ParentDN $ProductionOU

    $FINOU = Ensure-OU `
        -Name "FIN" `
        -ParentDN $ProductionUsersOU

    $HROU = Ensure-OU `
        -Name "HR" `
        -ParentDN $ProductionUsersOU

    $ITOU = Ensure-OU `
        -Name "IT" `
        -ParentDN $ProductionUsersOU

    $ProductionComputersOU = Ensure-OU `
        -Name "Computers" `
        -ParentDN $ProductionOU

    $ProductionServersOU = Ensure-OU `
        -Name "Servers" `
        -ParentDN $ProductionOU

    $ProductionGroupsOU = Ensure-OU `
        -Name "Groups" `
        -ParentDN $ProductionOU


    # ------------------------------------------------------------------------
    # BACKUP
    # ------------------------------------------------------------------------

    $BackupOU = Ensure-OU `
        -Name "BACKUP" `
        -ParentDN $DomainDN

    $BackupComputersOU = Ensure-OU `
        -Name "Computers" `
        -ParentDN $BackupOU

    $BackupServersOU = Ensure-OU `
        -Name "Servers" `
        -ParentDN $BackupOU

    $BackupGroupsOU = Ensure-OU `
        -Name "Groups" `
        -ParentDN $BackupOU


    # ------------------------------------------------------------------------
    # REMOTE ADMIN
    # ------------------------------------------------------------------------

    $RemoteAdminOU = Ensure-OU `
        -Name "REMOTE-ADMIN" `
        -ParentDN $DomainDN

    $RemoteUsersOU = Ensure-OU `
        -Name "Users" `
        -ParentDN $RemoteAdminOU

    $RemoteGroupsOU = Ensure-OU `
        -Name "Groups" `
        -ParentDN $RemoteAdminOU


    # ------------------------------------------------------------------------
    # SERVICE ACCOUNTS
    # ------------------------------------------------------------------------

    $ServiceAccountsOU = Ensure-OU `
        -Name "SERVICE-ACCOUNTS" `
        -ParentDN $DomainDN

}
catch {

    Write-Host ""
    Write-Host "============================================================"
    Write-Host " OU CREATION FAILED"
    Write-Host "============================================================" `
        -ForegroundColor Red

    Write-Host ""
    Write-Host "Deployment stopped intentionally." -ForegroundColor Red
    Write-Host "No users or groups will be created."
    Write-Host ""

    Stop-Transcript
    exit 1
}

# ============================================================================
# 9. VERIFY ALL REQUIRED OUs
# ============================================================================

Write-Host ""
Write-Host "[*] Verifying complete OU structure..." -ForegroundColor Cyan

$RequiredOUs = @(
    $AdminOU,
    $AdminServiceOU,
    $Tier0OU,
    $Tier1OU,
    $Tier2OU,

    $ProductionOU,
    $ProductionUsersOU,
    $FINOU,
    $HROU,
    $ITOU,
    $ProductionComputersOU,
    $ProductionServersOU,
    $ProductionGroupsOU,

    $BackupOU,
    $BackupComputersOU,
    $BackupServersOU,
    $BackupGroupsOU,

    $RemoteAdminOU,
    $RemoteUsersOU,
    $RemoteGroupsOU,

    $ServiceAccountsOU
)

foreach ($OU in $RequiredOUs) {

    try {
        Get-ADOrganizationalUnit `
            -Identity $OU `
            -Server $DomainController `
            -ErrorAction Stop | Out-Null

        Write-Host "[OK] $OU" -ForegroundColor Green
    }
    catch {
        Write-Host "[X] Missing OU: $OU" -ForegroundColor Red
        Stop-Transcript
        exit 1
    }
}

Write-Host ""
Write-Host "[+] OU structure verified successfully." -ForegroundColor Green

# ============================================================================
# 10. CREATE SECURITY GROUP FUNCTION
# ============================================================================

function Ensure-SecurityGroup {

    param(
        [Parameter(Mandatory = $true)]
        [string]$GroupName,

        [Parameter(Mandatory = $true)]
        [string]$GroupOU
    )

    try {

        $Existing = Get-ADGroup `
            -Identity $GroupName `
            -Server $DomainController `
            -ErrorAction SilentlyContinue

        if ($Existing) {

            Write-Host "[=] Group already exists: $GroupName" `
                -ForegroundColor DarkGray

            $Stats.GroupsExisting++

            return
        }

        New-ADGroup `
            -Name $GroupName `
            -SamAccountName $GroupName `
            -GroupScope Global `
            -GroupCategory Security `
            -Path $GroupOU `
            -Server $DomainController `
            -ErrorAction Stop

        Write-Host "[+] Group created: $GroupName" `
            -ForegroundColor Green

        $Stats.GroupsCreated++
    }
    catch {

        Write-Host "[X] Failed to create group: $GroupName" `
            -ForegroundColor Red

        Write-Host "    $($_.Exception.Message)"
    }
}

# ============================================================================
# 11. CREATE SECURITY GROUPS
# ============================================================================

Write-Host ""
Write-Host "============================================================"
Write-Host " CREATING SECURITY GROUPS"
Write-Host "============================================================"
Write-Host ""

$Groups = @{

    "GG-SVC-Admin"           = $ProductionGroupsOU
    "GG-Infra-Admin"         = $ProductionGroupsOU
    "GG-Ops-Admin"           = $ProductionGroupsOU
    "GG-Remote-Admin"        = $RemoteGroupsOU
    "GG-Remote-Users"        = $RemoteGroupsOU
    "GG-Helpdesk"            = $ProductionGroupsOU

    "GG-Prod-Server-Admins"  = $ProductionGroupsOU
    "GG-Backup-Server-Admins"= $BackupGroupsOU
    "GG-Backup-Operators"    = $BackupGroupsOU

    "GG-IT-Users"            = $ProductionGroupsOU
    "GG-IT-Managers"         = $ProductionGroupsOU
    "DL-IT-Share"            = $ProductionGroupsOU

    "GG-FIN-Users"           = $ProductionGroupsOU
    "GG-FIN-Managers"        = $ProductionGroupsOU
    "DL-FIN-Share"           = $ProductionGroupsOU

    "GG-HR-Users"            = $ProductionGroupsOU
    "GG-HR-Managers"         = $ProductionGroupsOU
    "DL-HR-Share"            = $ProductionGroupsOU
}

foreach ($GroupName in $Groups.Keys) {

    Ensure-SecurityGroup `
        -GroupName $GroupName `
        -GroupOU $Groups[$GroupName]
}

# ============================================================================
# 12. GROUP NESTING
# ============================================================================

function Add-GroupToGroup {

    param(
        [string]$ParentGroup,
        [string]$ChildGroup
    )

    try {

        Add-ADGroupMember `
            -Identity $ParentGroup `
            -Members $ChildGroup `
            -Server $DomainController `
            -ErrorAction Stop

        Write-Host "[+] $ChildGroup -> $ParentGroup" `
            -ForegroundColor Green
    }
    catch {

        if ($_.Exception.Message -match "already a member") {

            Write-Host "[=] $ChildGroup already belongs to $ParentGroup" `
                -ForegroundColor DarkGray
        }
        else {

            Write-Host "[X] Failed nesting $ChildGroup -> $ParentGroup" `
                -ForegroundColor Red

            Write-Host "    $($_.Exception.Message)"
        }
    }
}

Write-Host ""
Write-Host "============================================================"
Write-Host " CONFIGURING GROUP NESTING"
Write-Host "============================================================"
Write-Host ""

Add-GroupToGroup "GG-Infra-Admin" "GG-Prod-Server-Admins"
Add-GroupToGroup "GG-Infra-Admin" "GG-Backup-Server-Admins"

Add-GroupToGroup "GG-Ops-Admin" "GG-Backup-Operators"
Add-GroupToGroup "GG-Ops-Admin" "GG-Helpdesk"

Add-GroupToGroup "DL-IT-Share" "GG-IT-Users"
Add-GroupToGroup "DL-FIN-Share" "GG-FIN-Users"
Add-GroupToGroup "DL-HR-Share" "GG-HR-Users"

# ============================================================================
# 13. SERVICE ACCOUNTS
# ============================================================================

Write-Host ""
Write-Host "============================================================"
Write-Host " CREATING SERVICE ACCOUNTS"
Write-Host "============================================================"
Write-Host ""

$ServicePassword = ConvertTo-SecureString `
    $ServiceAccountPassword `
    -AsPlainText `
    -Force

$ServiceAccounts = @(
    "svc_admin",
    "svc_backup",
    "svc_monitoring"
)

foreach ($Account in $ServiceAccounts) {

    try {

        $Existing = Get-ADUser `
            -Identity $Account `
            -Server $DomainController `
            -ErrorAction SilentlyContinue

        if ($Existing) {

            Write-Host "[=] Service account already exists: $Account" `
                -ForegroundColor DarkGray

            continue
        }

        New-ADUser `
            -Name $Account `
            -SamAccountName $Account `
            -UserPrincipalName "$Account@$DomainDNS" `
            -Path $AdminServiceOU `
            -AccountPassword $ServicePassword `
            -Enabled $true `
            -PasswordNeverExpires $true `
            -CannotChangePassword $true `
            -Server $DomainController `
            -ErrorAction Stop

        Write-Host "[+] Service account created: $Account" `
            -ForegroundColor Green

        $Stats.ServiceAccounts++
    }
    catch {

        Write-Host "[X] Failed service account: $Account" `
            -ForegroundColor Red

        Write-Host "    $($_.Exception.Message)"
    }
}

# ============================================================================
# 14. LOAD USERS CSV
# ============================================================================

Write-Host ""
Write-Host "============================================================"
Write-Host " LOADING USERS CSV"
Write-Host "============================================================"
Write-Host ""

if (-not (Test-Path $UserFile)) {

    Write-Host "[X] CSV file not found:" -ForegroundColor Red
    Write-Host "    $UserFile"

    Stop-Transcript
    exit 1
}

try {

    $Users = Import-Csv -Path $UserFile -ErrorAction Stop

    Write-Host "[+] CSV loaded successfully." -ForegroundColor Green
    Write-Host "[+] Users found: $($Users.Count)" -ForegroundColor Green
}
catch {

    Write-Host "[X] Failed to import CSV." -ForegroundColor Red
    Write-Host $_.Exception.Message

    Stop-Transcript
    exit 1
}

# ============================================================================
# 15. VERIFY CSV COLUMNS
# ============================================================================

$RequiredColumns = @(
    "SamAccountName",
    "FirstName",
    "LastName",
    "Email",
    "Department",
    "Title",
    "OU",
    "Group"
)

$CSVColumns = $Users[0].PSObject.Properties.Name

foreach ($Column in $RequiredColumns) {

    if ($CSVColumns -notcontains $Column) {

        Write-Host ""
        Write-Host "[X] Missing CSV column: $Column" `
            -ForegroundColor Red

        Stop-Transcript
        exit 1
    }
}

Write-Host "[+] CSV structure validated." -ForegroundColor Green

# ============================================================================
# 16. CREATE USERS
# ============================================================================

Write-Host ""
Write-Host "============================================================"
Write-Host " CREATING USER ACCOUNTS"
Write-Host "============================================================"
Write-Host ""

$UserPassword = ConvertTo-SecureString `
    $DefaultUserPassword `
    -AsPlainText `
    -Force

foreach ($User in $Users) {

    $Sam = "$($User.SamAccountName)".Trim()

    if ([string]::IsNullOrWhiteSpace($Sam)) {
        continue
    }

    Write-Host ""
    Write-Host "------------------------------------------------------------"
    Write-Host "Processing: $Sam"
    Write-Host "Name:       $($User.FirstName) $($User.LastName)"
    Write-Host "Department: $($User.Department)"
    Write-Host "------------------------------------------------------------"

    try {

        # --------------------------------------------------------------------
        # Check existing user
        # --------------------------------------------------------------------

        $ExistingUser = Get-ADUser `
            -Identity $Sam `
            -Server $DomainController `
            -ErrorAction SilentlyContinue

        if ($ExistingUser) {

            Write-Host "[=] User already exists: $Sam" `
                -ForegroundColor Yellow

            $Stats.UsersExisting++
        }
        else {

            # ---------------------------------------------------------------
            # Verify target OU
            # ---------------------------------------------------------------

            $TargetOU = "$($User.OU)".Trim()

            if ([string]::IsNullOrWhiteSpace($TargetOU)) {

                throw "CSV OU field is empty."
            }

            $OUObject = Get-ADOrganizationalUnit `
                -Identity $TargetOU `
                -Server $DomainController `
                -ErrorAction SilentlyContinue

            if (-not $OUObject) {

                throw "Target OU does not exist: $TargetOU"
            }

            # ---------------------------------------------------------------
            # Create user
            # ---------------------------------------------------------------

            $NewUserParams = @{
                Name                  = "$($User.FirstName) $($User.LastName)"
                GivenName             = $User.FirstName
                Surname               = $User.LastName
                DisplayName           = "$($User.FirstName) $($User.LastName)"
                SamAccountName        = $Sam
                UserPrincipalName     = "$Sam@$DomainDNS"
                EmailAddress          = $User.Email
                Department            = $User.Department
                Title                 = $User.Title
                Path                  = $TargetOU
                AccountPassword       = $UserPassword
                ChangePasswordAtLogon = $true
                Enabled               = $true
                Server                = $DomainController
            }

            New-ADUser @NewUserParams -ErrorAction Stop

            Write-Host "[+] User created: $Sam" `
                -ForegroundColor Green

            $Stats.UsersCreated++
        }

        # --------------------------------------------------------------------
        # Group membership
        # --------------------------------------------------------------------

        if (-not [string]::IsNullOrWhiteSpace($User.Group)) {

            $GroupList = $User.Group -split ',' |
                ForEach-Object { $_.Trim() } |
                Where-Object { $_ }

            foreach ($GroupName in $GroupList) {

                try {

                    Add-ADGroupMember `
                        -Identity $GroupName `
                        -Members $Sam `
                        -Server $DomainController `
                        -ErrorAction Stop

                    Write-Host "[+] Added $Sam to $GroupName" `
                        -ForegroundColor Green

                    $Stats.GroupAssignments++
                }
                catch {

                    if ($_.Exception.Message -match "already a member") {

                        Write-Host "[=] $Sam already belongs to $GroupName" `
                            -ForegroundColor DarkGray
                    }
                    else {

                        Write-Host "[!] Failed group assignment: $GroupName" `
                            -ForegroundColor Yellow

                        Write-Host "    $($_.Exception.Message)"

                        $Stats.GroupAssignmentFail++
                    }
                }
            }
        }
    }
    catch {

        Write-Host ""
        Write-Host "[X] USER PROVISIONING FAILED: $Sam" `
            -ForegroundColor Red

        Write-Host "    $($_.Exception.Message)"

        $Stats.UsersFailed++
    }
}

# ============================================================================
# 17. FINAL VERIFICATION
# ============================================================================

Write-Host ""
Write-Host "============================================================"
Write-Host " FINAL AD VERIFICATION"
Write-Host "============================================================"
Write-Host ""

Write-Host "[*] OUs:" -ForegroundColor Cyan

Get-ADOrganizationalUnit `
    -Filter * `
    -SearchBase $DomainDN `
    -SearchScope Subtree `
    -Server $DomainController |
    Select-Object Name,DistinguishedName |
    Sort-Object DistinguishedName |
    Format-Table -AutoSize

Write-Host ""
Write-Host "[*] Users created by this deployment:" -ForegroundColor Cyan

Get-ADUser `
    -Filter * `
    -SearchBase $ProductionUsersOU `
    -SearchScope Subtree `
    -Server $DomainController |
    Select-Object Name,SamAccountName,Enabled,DistinguishedName |
    Sort-Object DistinguishedName |
    Format-Table -AutoSize

# ============================================================================
# 18. SUMMARY
# ============================================================================

Write-Host ""
Write-Host "============================================================"
Write-Host " DOBRE AD PROVISIONING SUMMARY"
Write-Host "============================================================"
Write-Host ""

Write-Host "OUs Created:          $($Stats.OUsCreated)"
Write-Host "OUs Already Existing: $($Stats.OUsExisting)"
Write-Host "Groups Created:       $($Stats.GroupsCreated)"
Write-Host "Groups Existing:      $($Stats.GroupsExisting)"
Write-Host "Service Accounts:     $($Stats.ServiceAccounts)"
Write-Host "Users Created:        $($Stats.UsersCreated)"
Write-Host "Users Existing:       $($Stats.UsersExisting)"
Write-Host "Users Failed:         $($Stats.UsersFailed)"
Write-Host "Group Assignments:    $($Stats.GroupAssignments)"
Write-Host "Group Assign Fail:    $($Stats.GroupAssignmentFail)"
Write-Host ""

Write-Host "Log file:"
Write-Host $LogPath -ForegroundColor Cyan

Write-Host ""

if ($Stats.UsersFailed -eq 0) {

    Write-Host "============================================================"
    Write-Host " PROVISIONING COMPLETED SUCCESSFULLY"
    Write-Host "============================================================" `
        -ForegroundColor Green
}
else {

    Write-Host "============================================================"
    Write-Host " PROVISIONING COMPLETED WITH ERRORS"
    Write-Host "============================================================" `
        -ForegroundColor Yellow
}

Write-Host ""

Stop-Transcript
