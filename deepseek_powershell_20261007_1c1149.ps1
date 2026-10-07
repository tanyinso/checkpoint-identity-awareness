<#
.SYNOPSIS
    AD deployment: FIN/HR/IT users under PRODUCTION; BACKUP holds computers only.
.EXAMPLE
    .\Deploy-AD-FINAL.ps1 -UserFile "C:\AD-Deploy\users.xlsx"
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$UserFile,
    [string]$LogPath = "C:\AD-Deploy\deploy.log"
)

Import-Module ActiveDirectory -ErrorAction Stop

# ---------- Logging ----------
$LogDir = Split-Path $LogPath -Parent
if (-not (Test-Path $LogDir)) { New-Item -Path $LogDir -ItemType Directory -Force | Out-Null }

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $line = "[$ts] [$Level] $Message"
    Write-Host $line -ForegroundColor $(
        switch ($Level) {
            "ERROR" { "Red" }; "WARN" { "Yellow" }; "OK" { "Green" }; default { "White" }
        }
    )
    Add-Content -Path $LogPath -Value $line
}

$DomainDN  = (Get-ADDomain).DistinguishedName
$DomainDNS = (Get-ADDomain).DNSRoot
Write-Log "Starting AD deployment for $DomainDN" "OK"

# ============================================================
# 1. OU STRUCTURE
# ============================================================
Write-Log "Creating OU structure..."

$UserCategories = @("FIN","HR","IT")   # only under PRODUCTION\Users

$OUs = @(
    # Admin tier
    "OU=_ADMIN,$DomainDN",
    "OU=ServiceAccounts,OU=_ADMIN,$DomainDN",
    "OU=Tier0-Admins,OU=_ADMIN,$DomainDN",
    "OU=Tier1-Admins,OU=_ADMIN,$DomainDN",
    "OU=Tier2-Admins,OU=_ADMIN,$DomainDN",

    # Production
    "OU=PRODUCTION,$DomainDN",
    "OU=Users,OU=PRODUCTION,$DomainDN",
    "OU=Computers,OU=PRODUCTION,$DomainDN",
    "OU=Servers,OU=PRODUCTION,$DomainDN",
    "OU=Groups,OU=PRODUCTION,$DomainDN",

    # Backup (computers only — NO Users)
    "OU=BACKUP,$DomainDN",
    "OU=Computers,OU=BACKUP,$DomainDN",
    "OU=Servers,OU=BACKUP,$DomainDN",
    "OU=Groups,OU=BACKUP,$DomainDN",

    # Remote admin
    "OU=REMOTE-ADMIN,$DomainDN",
    "OU=Users,OU=REMOTE-ADMIN,$DomainDN",
    "OU=Groups,OU=REMOTE-ADMIN,$DomainDN",

    # Service accounts
    "OU=SERVICE-ACCOUNTS,$DomainDN"
)

# Add FIN / HR / IT sub-OUs ONLY under PRODUCTION\Users
foreach ($cat in $UserCategories) {
    $OUs += "OU=$cat,OU=Users,OU=PRODUCTION,$DomainDN"
}

foreach ($ou in $OUs) {
    try {
        if (-not (Get-ADOrganizationalUnit -Identity $ou -ErrorAction SilentlyContinue)) {
            $parent = $ou.Substring($ou.IndexOf(',') + 1)
            $name   = $ou.Split(',')[0].Replace('OU=','')
            New-ADOrganizationalUnit -Path $parent -Name $name -ProtectedFromAccidentalDeletion $true
            Write-Log "Created OU: $ou" "OK"
        } else {
            Write-Log "OU exists: $ou" "WARN"
        }
    } catch {
        Write-Log "OU failed $ou : $_" "ERROR"
    }
}

# ============================================================
# 2. SECURITY GROUPS
# ============================================================
Write-Log "Creating security groups..."

$ProdGroupsOU   = "OU=Groups,OU=PRODUCTION,$DomainDN"
$BkupGroupsOU   = "OU=Groups,OU=BACKUP,$DomainDN"
$AdminGroupsOU  = "OU=Tier1-Admins,OU=_ADMIN,$DomainDN"
$RemoteGroupsOU = "OU=Groups,OU=REMOTE-ADMIN,$DomainDN"

$Groups = @(
    # IT / Admin
    @{N="GG-SVC-Admin";            P=$AdminGroupsOU;  S="Global";      D="Service Account Admins"},
    @{N="GG-Infra-Admin";          P=$AdminGroupsOU;  S="Global";      D="Infrastructure Admins (Tier1)"},
    @{N="GG-Ops-Admin";            P=$AdminGroupsOU;  S="Global";      D="Operations Admins (Tier2)"},
    @{N="GG-Remote-Admin";         P=$RemoteGroupsOU; S="Global";      D="Remote Admins (192.168.90.0/24)"},
    @{N="GG-Helpdesk";             P=$AdminGroupsOU;  S="Global";      D="Helpdesk"},

    # Server admin rights (Production AND Backup computers)
    @{N="GG-Prod-Server-Admins";   P=$ProdGroupsOU;   S="DomainLocal"; D="Local admin on Production servers"},
    @{N="GG-Backup-Server-Admins"; P=$BkupGroupsOU;   S="DomainLocal"; D="Local admin on Backup servers"},
    @{N="GG-Backup-Operators";     P=$BkupGroupsOU;   S="DomainLocal"; D="Backup and restore operators"},

    # IT department
    @{N="GG-IT-Users";             P=$ProdGroupsOU;   S="Global";      D="IT users"},
    @{N="GG-IT-Managers";          P=$ProdGroupsOU;   S="Global";      D="IT managers"},
    @{N="DL-IT-Share";             P=$ProdGroupsOU;   S="DomainLocal"; D="IT file share access"},

    # FIN department
    @{N="GG-FIN-Users";            P=$ProdGroupsOU;   S="Global";      D="Finance users"},
    @{N="GG-FIN-Managers";         P=$ProdGroupsOU;   S="Global";      D="Finance managers"},
    @{N="DL-FIN-Share";            P=$ProdGroupsOU;   S="DomainLocal"; D="Finance file share access"},

    # HR department
    @{N="GG-HR-Users";             P=$ProdGroupsOU;   S="Global";      D="HR users"},
    @{N="GG-HR-Managers";          P=$ProdGroupsOU;   S="Global";      D="HR managers"},
    @{N="DL-HR-Share";             P=$ProdGroupsOU;   S="DomainLocal"; D="HR file share access"}
)

foreach ($g in $Groups) {
    try {
        if (-not (Get-ADGroup -Filter "Name -eq '$($g.N)'" -ErrorAction SilentlyContinue)) {
            New-ADGroup -Name $g.N -GroupScope $g.S -GroupCategory Security -Path $g.P -Description $g.D
            Write-Log "Created group: $($g.N) [$($g.S)]" "OK"
        } else {
            Write-Log "Group exists: $($g.N)" "WARN"
        }
    } catch {
        Write-Log "Group failed $($g.N): $_" "ERROR"
    }
}

# ============================================================
# 3. GROUP NESTING (PoLP)
# ============================================================
Write-Log "Nesting groups..."

$Nesting = @(
    @{Parent="GG-Prod-Server-Admins";   Child="GG-Infra-Admin"},
    @{Parent="GG-Backup-Server-Admins"; Child="GG-Infra-Admin"},
    @{Parent="GG-Backup-Operators";     Child="GG-Ops-Admin"},
    @{Parent="GG-Helpdesk";             Child="GG-Ops-Admin"},

    @{Parent="DL-FIN-Share"; Child="GG-FIN-Users"},
    @{Parent="DL-FIN-Share"; Child="GG-FIN-Managers"},
    @{Parent="DL-HR-Share";  Child="GG-HR-Users"},
    @{Parent="DL-HR-Share";  Child="GG-HR-Managers"},
    @{Parent="DL-IT-Share";  Child="GG-IT-Users"},
    @{Parent="DL-IT-Share";  Child="GG-IT-Managers"}
)

foreach ($n in $Nesting) {
    try {
        Add-ADGroupMember -Identity $n.Parent -Members $n.Child -ErrorAction Stop
        Write-Log "Nested $($n.Child) -> $($n.Parent)" "OK"
    } catch {
        Write-Log "Nesting skip ($($n.Child) -> $($n.Parent)): $_" "WARN"
    }
}

# ============================================================
# 4. SERVICE ACCOUNTS
# ============================================================
Write-Log "Creating service accounts..."

$SvcOU = "OU=ServiceAccounts,OU=_ADMIN,$DomainDN"
$SvcAccounts = @(
    @{N="svc_admin";      D="Service Account Admin"},
    @{N="svc_backup";     D="Backup service account"},
    @{N="svc_monitoring"; D="Monitoring service account"}
)

foreach ($svc in $SvcAccounts) {
    try {
        if (-not (Get-ADUser -Filter "SamAccountName -eq '$($svc.N)'" -ErrorAction SilentlyContinue)) {
            New-ADUser -Name $svc.N -SamAccountName $svc.N `
                -UserPrincipalName "$($svc.N)@$DomainDNS" `
                -Path $SvcOU -Description $svc.D `
                -AccountPassword (ConvertTo-SecureString "ChangeMe!2024#Strong" -AsPlainText -Force) `
                -PasswordNeverExpires $true -CannotChangePassword $true -Enabled $true
            Write-Log "Service account created: $($svc.N)" "OK"
        } else {
            Write-Log "Service account exists: $($svc.N)" "WARN"
        }
    } catch {
        Write-Log "Service account failed $($svc.N): $_" "ERROR"
    }
}

# ============================================================
# 5. IMPORT USERS
# ============================================================
Write-Log "Importing users from $UserFile..."

if (-not (Test-Path $UserFile)) { Write-Log "User file not found" "ERROR"; return }

if ($UserFile -match '\.xlsx?$') {
    try {
        Import-Module ImportExcel -ErrorAction Stop
        $Users = Import-Excel -Path $UserFile
    } catch {
        Write-Log "ImportExcel missing. Run: Install-Module ImportExcel" "ERROR"; return
    }
} else {
    $Users = Import-Csv -Path $UserFile
}

$DefaultPwd = ConvertTo-SecureString "Welcome@2024!" -AsPlainText -Force

foreach ($u in $Users) {
    try {
        $sam      = $u.SamAccountName
        $targetOU = $u.OU
        $groups   = @($u.Group -split ',').Trim()

        if (-not (Get-ADUser -Filter "SamAccountName -eq '$sam'" -ErrorAction SilentlyContinue)) {
            New-ADUser -Name "$($u.FirstName) $($u.LastName)" `
                -GivenName $u.FirstName -Surname $u.LastName `
                -SamAccountName $sam `
                -UserPrincipalName "$sam@$DomainDNS" `
                -EmailAddress $u.Email `
                -Department $u.Department `
                -Title $u.Title `
                -Path $targetOU `
                -AccountPassword $DefaultPwd `
                -ChangePasswordAtLogon $true `
                -Enabled $true
            Write-Log "User created: $sam" "OK"
        } else {
            Write-Log "User exists: $sam" "WARN"
        }

        foreach ($grp in $groups) {
            if ($grp) {
                try {
                    Add-ADGroupMember -Identity $grp -Members $sam -ErrorAction Stop
                    Write-Log "  + $sam -> $grp" "OK"
                } catch {
                    Write-Log "  ! $sam -> $grp failed: $_" "WARN"
                }
            }
        }
    } catch {
        Write-Log "User failed $($u.SamAccountName): $_" "ERROR"
    }
}

# ============================================================
# 6. SUMMARY
# ============================================================
Write-Log "==========================================" "OK"
Write-Log "DEPLOYMENT COMPLETE" "OK"
Write-Log "OUs:              $($OUs.Count)" "OK"
Write-Log "Groups:           $($Groups.Count)" "OK"
Write-Log "Service accounts: $($SvcAccounts.Count)" "OK"
Write-Log "Users processed:  $($Users.Count)" "OK"
Write-Log "Log: $LogPath" "OK"
Write-Log "==========================================" "OK"