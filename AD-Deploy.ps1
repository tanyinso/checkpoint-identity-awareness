Import-Module ActiveDirectory

# =========================================================
# DOMAIN SETTINGS
# =========================================================

$DomainController = "DC1.dobre.local"
$DomainDN         = "DC=dobre,DC=local"

Write-Host ""
Write-Host "====================================================" -ForegroundColor Cyan
Write-Host " DOBRE TECHNOLOGIES - ACTIVE DIRECTORY OU DEPLOYMENT" -ForegroundColor Cyan
Write-Host "====================================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Domain Controller : $DomainController" -ForegroundColor Yellow
Write-Host "Domain DN         : $DomainDN" -ForegroundColor Yellow
Write-Host ""


# =========================================================
# FUNCTION - CREATE OU IF IT DOES NOT EXIST
# =========================================================

function Create-OU {

    param (
        [Parameter(Mandatory=$true)]
        [string]$Name,

        [Parameter(Mandatory=$true)]
        [string]$Path
    )

    $OU_DN = "OU=$Name,$Path"

    # Check if OU already exists
    $ExistingOU = Get-ADOrganizationalUnit `
        -Identity $OU_DN `
        -Server $DomainController `
        -ErrorAction SilentlyContinue

    if ($ExistingOU) {

        Write-Host "[EXISTS] $OU_DN" -ForegroundColor Green

    }
    else {

        Write-Host "[CREATE] $OU_DN" -ForegroundColor Cyan

        try {

            New-ADOrganizationalUnit `
                -Name $Name `
                -Path $Path `
                -Server $DomainController `
                -ProtectedFromAccidentalDeletion $true `
                -ErrorAction Stop

            Write-Host "[OK]     $OU_DN" -ForegroundColor Green
        }

        catch {

            Write-Host ""
            Write-Host "[FAILED] $OU_DN" -ForegroundColor Red
            Write-Host $_.Exception.Message -ForegroundColor Red
            Write-Host ""

            throw "OU creation stopped because $OU_DN could not be created."
        }
    }
}


# =========================================================
# LEVEL 1 - TOP LEVEL OUs
# These are created directly under DC=dobre,DC=local
# =========================================================

Write-Host ""
Write-Host "========== LEVEL 1: TOP-LEVEL OUs ==========" -ForegroundColor Magenta
Write-Host ""

Create-OU "_ADMIN"          $DomainDN
Create-OU "PRODUCTION"      $DomainDN
Create-OU "BACKUP"          $DomainDN
Create-OU "REMOTE-ADMIN"    $DomainDN
Create-OU "SERVICE-ACCOUNTS" $DomainDN


# =========================================================
# LEVEL 2 - _ADMIN CHILD OUs
# Parent: OU=_ADMIN
# =========================================================

Write-Host ""
Write-Host "========== LEVEL 2: _ADMIN ==========" -ForegroundColor Magenta
Write-Host ""

$AdminOU = "OU=_ADMIN,$DomainDN"

Create-OU "ServiceAccounts" $AdminOU
Create-OU "Tier0-Admins"    $AdminOU
Create-OU "Tier1-Admins"    $AdminOU
Create-OU "Tier2-Admins"    $AdminOU


# =========================================================
# LEVEL 2 - PRODUCTION CHILD OUs
# Parent: OU=PRODUCTION
# =========================================================

Write-Host ""
Write-Host "========== LEVEL 2: PRODUCTION ==========" -ForegroundColor Magenta
Write-Host ""

$ProductionOU = "OU=PRODUCTION,$DomainDN"

Create-OU "Users"     $ProductionOU
Create-OU "Computers" $ProductionOU
Create-OU "Servers"   $ProductionOU
Create-OU "Groups"    $ProductionOU


# =========================================================
# LEVEL 2 - BACKUP CHILD OUs
# Parent: OU=BACKUP
# =========================================================

Write-Host ""
Write-Host "========== LEVEL 2: BACKUP ==========" -ForegroundColor Magenta
Write-Host ""

$BackupOU = "OU=BACKUP,$DomainDN"

Create-OU "Computers" $BackupOU
Create-OU "Servers"   $BackupOU
Create-OU "Groups"    $BackupOU


# =========================================================
# LEVEL 2 - REMOTE-ADMIN CHILD OUs
# Parent: OU=REMOTE-ADMIN
# =========================================================

Write-Host ""
Write-Host "========== LEVEL 2: REMOTE-ADMIN ==========" -ForegroundColor Magenta
Write-Host ""

$RemoteAdminOU = "OU=REMOTE-ADMIN,$DomainDN"

Create-OU "Users"  $RemoteAdminOU
Create-OU "Groups" $RemoteAdminOU


# =========================================================
# LEVEL 3 - PRODUCTION USERS
# Parent: OU=Users,OU=PRODUCTION
# =========================================================

Write-Host ""
Write-Host "========== LEVEL 3: PRODUCTION USERS ==========" -ForegroundColor Magenta
Write-Host ""

$ProductionUsersOU = "OU=Users,OU=PRODUCTION,$DomainDN"

Create-OU "FIN" $ProductionUsersOU
Create-OU "HR"  $ProductionUsersOU
Create-OU "IT"  $ProductionUsersOU


# =========================================================
# VERIFICATION
# =========================================================

Write-Host ""
Write-Host "====================================================" -ForegroundColor Cyan
Write-Host " VERIFYING OU STRUCTURE" -ForegroundColor Cyan
Write-Host "====================================================" -ForegroundColor Cyan
Write-Host ""

Get-ADOrganizationalUnit `
    -Filter * `
    -SearchBase $DomainDN `
    -Server $DomainController |
    Sort-Object DistinguishedName |
    Select-Object Name, DistinguishedName |
    Format-Table -AutoSize


Write-Host ""
Write-Host "====================================================" -ForegroundColor Cyan
Write-Host " OU DEPLOYMENT COMPLETED SUCCESSFULLY" -ForegroundColor Green
Write-Host "====================================================" -ForegroundColor Cyan
