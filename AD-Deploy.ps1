
<#
.SYNOPSIS
    Deploys the Active Directory OU structure, security groups,
    group nesting, service accounts, and users for dobre.local.

.EXAMPLE
    .\Deploy-AD-FINAL.ps1 -UserFile "C:\AD-Deploy\users.csv"

.NOTES
    Run on a domain controller or a machine with the AD PowerShell
    module and appropriate delegated permissions.
    Existing users and groups are not recreated.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$UserFile,

    [string]$LogPath = "C:\AD-Deploy\deploy.log",

    [string]$DefaultUserPassword = "Welcome@2024!",

    [string]$ServiceAccountPassword = "ChangeMe!2024#Strong"
)

$ErrorActionPreference = "Stop"

# ============================================================
# 1. INITIALIZATION
# ============================================================

Import-Module ActiveDirectory -ErrorAction Stop

$LogDir = Split-Path $LogPath -Parent

if ($LogDir -and -not (Test-Path $LogDir)) {
    New-Item -Path $LogDir -ItemType Directory -Force |
        Out-Null
}

function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )

    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $Line = "[$Timestamp] [$Level] $Message"

    $Color = switch ($Level) {
        "ERROR" { "Red" }
        "WARN"  { "Yellow" }
        "OK"    { "Green" }
        default { "White" }
    }

    Write-Host $Line -ForegroundColor $Color
    Add-Content -Path $LogPath -Value $Line
}

$Domain = Get-ADDomain
$DomainDN = $Domain.DistinguishedName
$DomainDNS = $Domain.DNSRoot

$UserPassword = ConvertTo-SecureString `
    $DefaultUserPassword -AsPlainText -Force

$SvcPassword = ConvertTo-SecureString `
    $ServiceAccountPassword -AsPlainText -Force

$Stats = @{
    OUsCreated       = 0
    GroupsCreated    = 0
    ServicesCreated  = 0
    UsersCreated     = 0
    UsersSkipped     = 0
    Errors           = 0
}

Write-Log "============================================" "OK"
Write-Log "Starting deployment for $DomainDNS" "OK"
Write-Log "Domain DN: $DomainDN"

# ============================================================
# 2. CREATE ORGANIZATIONAL UNITS
# ============================================================

Write-Log "Creating OU structure..."

# Parent OUs appear before their children.
$OUDefinitions = @(
    @{ Name = "_ADMIN"; Parent = $DomainDN },
    @{ Name = "ServiceAccounts"; Parent = "OU=_ADMIN,$DomainDN" },
    @{ Name = "Tier0-Admins"; Parent = "OU=_ADMIN,$DomainDN" },
    @{ Name = "Tier1-Admins"; Parent = "OU=_ADMIN,$DomainDN" },
    @{ Name = "Tier2-Admins"; Parent = "OU=_ADMIN,$DomainDN" },

    @{ Name = "PRODUCTION"; Parent = $DomainDN },
    @{ Name = "Users"; Parent = "OU=PRODUCTION,$DomainDN" },
    @{ Name = "FIN"; Parent = "OU=Users,OU=PRODUCTION,$DomainDN" },
    @{ Name = "HR"; Parent = "OU=Users,OU=PRODUCTION,$DomainDN" },
    @{ Name = "IT"; Parent = "OU=Users,OU=PRODUCTION,$DomainDN" },
    @{ Name = "Computers"; Parent = "OU=PRODUCTION,$DomainDN" },
    @{ Name = "Servers"; Parent = "OU=PRODUCTION,$DomainDN" },
    @{ Name = "Groups"; Parent = "OU=PRODUCTION,$DomainDN" },

    @{ Name = "BACKUP"; Parent = $DomainDN },
    @{ Name = "Computers"; Parent = "OU=BACKUP,$DomainDN" },
    @{ Name = "Servers"; Parent = "OU=BACKUP,$DomainDN" },
    @{ Name = "Groups"; Parent = "OU=BACKUP,$DomainDN" },

    @{ Name = "REMOTE-ADMIN"; Parent = $DomainDN },
    @{ Name = "Users"; Parent = "OU=REMOTE-ADMIN,$DomainDN" },
    @{ Name = "Groups"; Parent = "OU=REMOTE-ADMIN,$DomainDN" },

    @{ Name = "SERVICE-ACCOUNTS"; Parent = $DomainDN }
)

foreach ($OU in $OUDefinitions) {
    $Identity = "OU=$($OU.Name),$($OU.Parent)"

    try {
        $ExistingOU = Get-ADOrganizationalUnit `
            -Identity $Identity -ErrorAction SilentlyContinue

        if (-not $ExistingOU) {
            New-ADOrganizationalUnit `
                -Name $OU.Name `
                -Path $OU.Parent `
                -ProtectedFromAccidentalDeletion $true `
                -ErrorAction Stop

            Write-Log "Created OU: $Identity" "OK"
            $Stats.OUsCreated++
        }
        else {
            Write-Log "OU already exists: $Identity" "WARN"
        }
    }
    catch {
        Write-Log "OU creation failed: $Identity - $_" "ERROR"
        $Stats.Errors++
    }
}

# ============================================================
# 3. DEFINE SECURITY GROUPS
# ============================================================

Write-Log "Creating security groups..."

$ProdGroupsOU   = "OU=Groups,OU=PRODUCTION,$DomainDN"
$BackupGroupsOU = "OU=Groups,OU=BACKUP,$DomainDN"
$AdminGroupsOU  = "OU=Tier1-Admins,OU=_ADMIN,$DomainDN"
$RemoteGroupsOU = "OU=Groups,OU=REMOTE-ADMIN,$DomainDN"

$Groups = @(
    # Administrative groups
    @{ N="GG-SVC-Admin"; P=$AdminGroupsOU; S="Global"; D="Service Account Administrators" },
    @{ N="GG-Infra-Admin"; P=$AdminGroupsOU; S="Global"; D="Infrastructure Administrators Tier 1" },
    @{ N="GG-Ops-Admin"; P=$AdminGroupsOU; S="Global"; D="Operations Administrators Tier 2" },
    @{ N="GG-Helpdesk"; P=$AdminGroupsOU; S="Global"; D="Helpdesk Team" },
    @{ N="GG-Remote-Admin"; P=$RemoteGroupsOU; S="Global"; D="Remote Administrators" },
    @{ N="GG-Remote-Users"; P=$RemoteGroupsOU; S="Global"; D="Remote Access Users" },

    # Production and backup server administration
    @{ N="GG-Prod-Server-Admins"; P=$ProdGroupsOU; S="DomainLocal"; D="Production Server Administrators" },
    @{ N="GG-Backup-Server-Admins"; P=$BackupGroupsOU; S="DomainLocal"; D="Backup Server Administrators" },
    @{ N="GG-Backup-Operators"; P=$BackupGroupsOU; S="DomainLocal"; D="Backup and Restore Operators" },

    # IT groups
    @{ N="GG-IT-Users"; P=$ProdGroupsOU; S="Global"; D="IT Department Users" },
    @{ N="GG-IT-Managers"; P=$ProdGroupsOU; S="Global"; D="IT Department Managers" },
    @{ N="DL-IT-Share"; P=$ProdGroupsOU; S="DomainLocal"; D="IT File Share Access" },

    # Finance groups
    @{ N="GG-FIN-Users"; P=$ProdGroupsOU; S="Global"; D="Finance Department Users" },
    @{ N="GG-FIN-Managers"; P=$ProdGroupsOU; S="Global"; D="Finance Department Managers" },
    @{ N="DL-FIN-Share"; P=$ProdGroupsOU; S="DomainLocal"; D="Finance File Share Access" },

    # Human Resources groups
    @{ N="GG-HR-Users"; P=$ProdGroupsOU; S="Global"; D="HR Department Users" },
    @{ N="GG-HR-Managers"; P=$ProdGroupsOU; S="Global"; D="HR Department Managers" },
    @{ N="DL-HR-Share"; P=$ProdGroupsOU; S="DomainLocal"; D="HR File Share Access" }
)

foreach ($Group in $Groups) {
    try {
        $ExistingGroup = Get-ADGroup `
            -Filter "SamAccountName -eq '$($Group.N)'" `
            -ErrorAction SilentlyContinue

        if (-not $ExistingGroup) {
            New-ADGroup `
                -Name $Group.N `
                -SamAccountName $Group.N `
                -GroupScope $Group.S `
                -GroupCategory Security `
                -Path $Group.P `
                -Description $Group.D `
                -ErrorAction Stop

            Write-Log "Created group: $($Group.N)" "OK"
            $Stats.GroupsCreated++
        }
        else {
            Write-Log "Group already exists: $($Group.N)" "WARN"
        }
    }
    catch {
        Write-Log "Group creation failed: $($Group.N) - $_" "ERROR"
        $Stats.Errors++
    }
}

# ============================================================
# 4. GROUP NESTING
# ============================================================

Write-Log "Configuring group nesting..."

$Nesting = @(
    @{ Parent="GG-Prod-Server-Admins"; Child="GG-Infra-Admin" },
    @{ Parent="GG-Backup-Server-Admins"; Child="GG-Infra-Admin" },
    @{ Parent="GG-Backup-Operators"; Child="GG-Ops-Admin" },
    @{ Parent="GG-Helpdesk"; Child="GG-Ops-Admin" },

    @{ Parent="DL-FIN-Share"; Child="GG-FIN-Users" },
    @{ Parent="DL-FIN-Share"; Child="GG-FIN-Managers" },
    @{ Parent="DL-HR-Share"; Child="GG-HR-Users" },
    @{ Parent="DL-HR-Share"; Child="GG-HR-Managers" },
    @{ Parent="DL-IT-Share"; Child="GG-IT-Users" },
    @{ Parent="DL-IT-Share"; Child="GG-IT-Managers" }
)

foreach ($Item in $Nesting) {
    try {
        $ParentGroup = Get-ADGroup `
            -Identity $Item.Parent -ErrorAction Stop

        $ChildGroup = Get-ADGroup `
            -Identity $Item.Child -ErrorAction Stop

        $AlreadyMember = Get-ADGroupMember `
            -Identity $ParentGroup `
            -ErrorAction Stop |
            Where-Object { $_.DistinguishedName -eq $ChildGroup.DistinguishedName }

        if (-not $AlreadyMember) {
            Add-ADGroupMember `
                -Identity $ParentGroup `
                -Members $ChildGroup `
                -ErrorAction Stop

            Write-Log "Nested $($Item.Child) into $($Item.Parent)" "OK"
        }
        else {
            Write-Log "Nesting already exists: $($Item.Child) -> $($Item.Parent)" "WARN"
        }
    }
    catch {
        Write-Log "Nesting failed: $($Item.Child) -> $($Item.Parent) - $_" "ERROR"
        $Stats.Errors++
    }
}

# ============================================================
# 5. CREATE SERVICE ACCOUNTS
# ============================================================

Write-Log "Creating service accounts..."

$SvcOU = "OU=ServiceAccounts,OU=_ADMIN,$DomainDN"

$ServiceAccounts = @(
    @{ N="svc_admin"; D="Administrative service account" },
    @{ N="svc_backup"; D="Backup service account" },
    @{ N="svc_monitoring"; D="Monitoring service account" }
)

foreach ($Service in $ServiceAccounts) {
    try {
        $ExistingUser = Get-ADUser `
            -Filter "SamAccountName -eq '$($Service.N)'" `
            -ErrorAction SilentlyContinue

        if (-not $ExistingUser) {
            New-ADUser `
                -Name $Service.N `
                -SamAccountName $Service.N `
                -UserPrincipalName "$($Service.N)@$DomainDNS" `
                -Path $SvcOU `
                -Description $Service.D `
                -AccountPassword $SvcPassword `
                -Enabled $true `
                -ErrorAction Stop

            Write-Log "Created service account: $($Service.N)" "OK"
            $Stats.ServicesCreated++
        }
        else {
            Write-Log "Service account exists: $($Service.N)" "WARN"
        }
    }
    catch {
        Write-Log "Service account failed: $($Service.N) - $_" "ERROR"
        $Stats.Errors++
    }
}

# ============================================================
# 6. IMPORT USERS FROM CSV OR EXCEL
# ============================================================

Write-Log "Importing users from $UserFile..."

if (-not (Test-Path $UserFile)) {
    Write-Log "User file not found: $UserFile" "ERROR"
    throw "Deployment stopped because the user file was not found."
}

$Extension = [IO.Path]::GetExtension($UserFile).ToLowerInvariant()

try {
    if ($Extension -eq ".csv") {
        $Users = @(Import-Csv -Path $UserFile -ErrorAction Stop)
    }
    elseif ($Extension -in @(".xlsx", ".xls")) {
        Import-Module ImportExcel -ErrorAction Stop
        $Users = @(Import-Excel -Path $UserFile -ErrorAction Stop)
    }
    else {
        throw "Unsupported file type: $Extension. Use CSV or Excel."
    }
}
catch {
    Write-Log "User file import failed: $_" "ERROR"
    throw
}

$RequiredColumns = @(
    "SamAccountName", "FirstName", "LastName",
    "Email", "Department", "Title", "OU", "Group"
)

if ($Users.Count -gt 0) {
    $ActualColumns = @($Users[0].PSObject.Properties.Name)

    foreach ($Column in $RequiredColumns) {
        if ($Column -notin $ActualColumns) {
            throw "Required column missing from user file: $Column"
        }
    }
}

foreach ($User in $Users) {
    $Sam = ([string]$User.SamAccountName).Trim()
    $TargetOU = ([string]$User.OU).Trim()

    if ([string]::IsNullOrWhiteSpace($Sam) -or
        [string]::IsNullOrWhiteSpace($TargetOU)) {
        Write-Log "Skipping row with missing SamAccountName or OU." "ERROR"
        $Stats.Errors++
        continue
    }

    # Only allow user destinations within this domain.
    if (-not $TargetOU.EndsWith(
        ",$DomainDN",
        [StringComparison]::OrdinalIgnoreCase
    )) {
        Write-Log "Rejected OU outside the domain: $TargetOU for $Sam" "ERROR"
        $Stats.Errors++
        continue
    }

    try {
        # Validate the destination OU before creating the user.
        Get-ADOrganizationalUnit `
            -Identity $TargetOU -ErrorAction Stop |
            Out-Null

        $ExistingUser = Get-ADUser `
            -Filter "SamAccountName -eq '$Sam'" `
            -ErrorAction SilentlyContinue

        if (-not $ExistingUser) {
            $NewUserParams = @{
                Name                  = "$($User.FirstName) $($User.LastName)"
                GivenName             = [string]$User.FirstName
                Surname               = [string]$User.LastName
                SamAccountName        = $Sam
                UserPrincipalName     = "$Sam@$DomainDNS"
                Path                  = $TargetOU
                AccountPassword       = $UserPassword
                ChangePasswordAtLogon = $true
                Enabled               = $true
                ErrorAction           = "Stop"
            }

            if (-not [string]::IsNullOrWhiteSpace([string]$User.Email)) {
                $NewUserParams.EmailAddress = [string]$User.Email
            }

            if (-not [string]::IsNullOrWhiteSpace([string]$User.Department)) {
                $NewUserParams.Department = [string]$User.Department
            }

            if (-not [string]::IsNullOrWhiteSpace([string]$User.Title)) {
                $NewUserParams.Title = [string]$User.Title
            }

            New-ADUser @NewUserParams

            Write-Log "Created user: $Sam in $TargetOU" "OK"
            $Stats.UsersCreated++
        }
        else {
            Write-Log "User already exists; not recreated: $Sam" "WARN"
            $Stats.UsersSkipped++
        }

        # Add the user to each requested group.
        $RequestedGroups = @(
            ([string]$User.Group -split ',') |
                ForEach-Object { $_.Trim() } |
                Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
        )

        foreach ($GroupName in $RequestedGroups) {
            try {
                $GroupObject = Get-ADGroup `
                    -Identity $GroupName -ErrorAction Stop

                $UserObject = Get-ADUser `
                    -Identity $Sam -ErrorAction Stop

                $Membership = Get-ADGroupMember `
                    -Identity $GroupObject `
                    -ErrorAction Stop |
                    Where-Object {
                        $_.DistinguishedName -eq $UserObject.DistinguishedName
                    }

                if (-not $Membership) {
                    Add-ADGroupMember `
                        -Identity $GroupObject `
                        -Members $UserObject `
                        -ErrorAction Stop

                    Write-Log "Added $Sam to $GroupName" "OK"
                }
                else {
                    Write-Log "$Sam is already a member of $GroupName" "WARN"
                }
            }
            catch {
                Write-Log "Membership failed: $Sam -> $GroupName - $_" "ERROR"
                $Stats.Errors++
            }
        }
    }
    catch {
        Write-Log "User processing failed: $Sam - $_" "ERROR"
        $Stats.Errors++
    }
}

# ============================================================
# 7. DEPLOYMENT SUMMARY
# ============================================================

Write-Log "============================================" "OK"
Write-Log "DEPLOYMENT FINISHED" "OK"
Write-Log "Domain: $DomainDNS" "OK"
Write-Log "OUs created: $($Stats.OUsCreated)" "OK"
Write-Log "Groups created: $($Stats.GroupsCreated)" "OK"
Write-Log "Service accounts created: $($Stats.ServicesCreated)" "OK"
Write-Log "Users created: $($Stats.UsersCreated)" "OK"
Write-Log "Existing users skipped: $($Stats.UsersSkipped)" "OK"
Write-Log "Errors encountered: $($Stats.Errors)" $(if ($Stats.Errors -gt 0) { "WARN" } else { "OK" })
Write-Log "Log file: $LogPath" "OK"
Write-Log "============================================" "OK"
