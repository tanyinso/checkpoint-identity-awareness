<#
================================================================================
 DOBRE LTD — WORKBOOK BUILDER
 Creates Dobre_Ltd_AD_User_Provisioning_Input.xlsx with two worksheets:
   - Employees
   - AD_Groups
================================================================================
#>

$ErrorActionPreference = "Stop"

# --- Ensure ImportExcel -----------------------------------------------------
if (-not (Get-Module -ListAvailable -Name ImportExcel)) {
    Write-Host "[*] Installing ImportExcel module..." -ForegroundColor Cyan
    Install-Module ImportExcel -Scope CurrentUser -Force
}
Import-Module ImportExcel

# --- Paths ------------------------------------------------------------------
$OutDir  = "C:\Scripts"
$OutFile = Join-Path $OutDir "Dobre_Ltd_AD_User_Provisioning_Input.xlsx"

if (-not (Test-Path $OutDir)) { New-Item -ItemType Directory -Path $OutDir | Out-Null }
if (Test-Path $OutFile)       { Remove-Item $OutFile -Force }

# --- Employees data ---------------------------------------------------------
$Employees = @(
    [PSCustomObject]@{ EmployeeID='DOB-FIN-2025-0001'; FirstName='Daniel';   LastName='Moyo';     Username='dmoyo';    Department='Finance'; Role='Financial Analyst';            EmploymentType='OnSite'; Location='Buea HQ';           CountryRegion='Cameroon';       OfficeSubnet='192.168.30.0/24'; RemoteSubnet='192.168.31.0/24'; VLAN='VLAN30'; SecurityGroup='GG-FIN-USERS';         OUPath='OU=Users,DC=dobre,DC=local' }
    [PSCustomObject]@{ EmployeeID='DOB-FIN-2025-0002'; FirstName='Grace';    LastName='Nfor';     Username='gnfor';    Department='Finance'; Role='Senior Accountant';            EmploymentType='Remote'; Location='Yaounde';           CountryRegion='Cameroon';       OfficeSubnet='192.168.30.0/24'; RemoteSubnet='192.168.31.0/24'; VLAN='VLAN30'; SecurityGroup='GG-FIN-REMOTE';        OUPath='OU=Users,DC=dobre,DC=local' }
    [PSCustomObject]@{ EmployeeID='DOB-FIN-2025-0003'; FirstName='Patrick';  LastName='Ewane';    Username='pewane';   Department='Finance'; Role='Finance Manager';              EmploymentType='OnSite'; Location='Douala';            CountryRegion='Cameroon';       OfficeSubnet='192.168.30.0/24'; RemoteSubnet='192.168.31.0/24'; VLAN='VLAN30'; SecurityGroup='GG-FIN-USERS';         OUPath='OU=Users,DC=dobre,DC=local' }
    [PSCustomObject]@{ EmployeeID='DOB-HRT-2025-0004'; FirstName='Linda';    LastName='Tabe';     Username='ltabe';    Department='HR';      Role='HR Specialist';                EmploymentType='OnSite'; Location='Buea HQ';           CountryRegion='Cameroon';       OfficeSubnet='192.168.20.0/24'; RemoteSubnet='192.168.21.0/24'; VLAN='VLAN20'; SecurityGroup='GG-HR-USERS';          OUPath='OU=Users,DC=dobre,DC=local' }
    [PSCustomObject]@{ EmployeeID='DOB-HRT-2025-0005'; FirstName='Michael';  LastName='Achu';     Username='machu';    Department='HR';      Role='Recruitment Officer';          EmploymentType='Remote'; Location='Bamenda';           CountryRegion='Cameroon';       OfficeSubnet='192.168.20.0/24'; RemoteSubnet='192.168.21.0/24'; VLAN='VLAN20'; SecurityGroup='GG-HR-REMOTE';         OUPath='OU=Users,DC=dobre,DC=local' }
    [PSCustomObject]@{ EmployeeID='DOB-ITX-2025-0006'; FirstName='Emmanuel'; LastName='Fongod';   Username='efongod';  Department='IT';      Role='Network Engineer';             EmploymentType='OnSite'; Location='Buea HQ';           CountryRegion='Cameroon';       OfficeSubnet='192.168.40.0/24'; RemoteSubnet='192.168.41.0/24'; VLAN='VLAN40'; SecurityGroup='GG-IT-ADMINS';         OUPath='OU=Users,DC=dobre,DC=local' }
    [PSCustomObject]@{ EmployeeID='DOB-ITX-2025-0007'; FirstName='Sarah';    LastName='Mbi';      Username='smbi';     Department='IT';      Role='Security Analyst';             EmploymentType='Remote'; Location='Limbe';             CountryRegion='Cameroon';       OfficeSubnet='192.168.40.0/24'; RemoteSubnet='192.168.41.0/24'; VLAN='VLAN40'; SecurityGroup='GG-IT-REMOTE';         OUPath='OU=Users,DC=dobre,DC=local' }
    [PSCustomObject]@{ EmployeeID='DOB-SRV-2025-0008'; FirstName='John';     LastName='Nkwenti';  Username='jnkwenti'; Department='Servers'; Role='Systems Administrator';        EmploymentType='OnSite'; Location='Buea Data Center';  CountryRegion='Cameroon';       OfficeSubnet='192.168.60.0/24'; RemoteSubnet='192.168.99.0/24'; VLAN='VLAN60'; SecurityGroup='GG-SERVER-OPS';        OUPath='OU=Users,DC=dobre,DC=local' }
    [PSCustomObject]@{ EmployeeID='DOB-SRV-2025-0009'; FirstName='Alice';    LastName='Tita';     Username='atita';    Department='Servers'; Role='Remote SysOps Engineer';       EmploymentType='Remote'; Location='United States';      CountryRegion='USA';            OfficeSubnet='192.168.60.0/24'; RemoteSubnet='192.168.99.0/24'; VLAN='VLAN60'; SecurityGroup='GG-SERVER-REMOTE-OPS'; OUPath='OU=Users,DC=dobre,DC=local' }
    [PSCustomObject]@{ EmployeeID='DOB-SRV-2025-0010'; FirstName='Kevin';    LastName='Manga';    Username='kmanga';   Department='Servers'; Role='Cloud Administrator';          EmploymentType='Remote'; Location='Canada';            CountryRegion='Canada';         OfficeSubnet='192.168.60.0/24'; RemoteSubnet='192.168.99.0/24'; VLAN='VLAN60'; SecurityGroup='GG-SERVER-REMOTE-OPS'; OUPath='OU=Users,DC=dobre,DC=local' }
    [PSCustomObject]@{ EmployeeID='DOB-FIN-2025-0011'; FirstName='Beatrice'; LastName='Njoya';    Username='bnjoya';   Department='Finance'; Role='Accounts Payable Clerk';       EmploymentType='OnSite'; Location='Buea HQ';           CountryRegion='Cameroon';       OfficeSubnet='192.168.30.0/24'; RemoteSubnet='192.168.31.0/24'; VLAN='VLAN30'; SecurityGroup='GG-FIN-USERS';         OUPath='OU=Users,DC=dobre,DC=local' }
    [PSCustomObject]@{ EmployeeID='DOB-HRT-2025-0012'; FirstName='Samuel';   LastName='Ojong';    Username='sojong';   Department='HR';      Role='HR Generalist';                EmploymentType='OnSite'; Location='Buea HQ';           CountryRegion='Cameroon';       OfficeSubnet='192.168.20.0/24'; RemoteSubnet='192.168.21.0/24'; VLAN='VLAN20'; SecurityGroup='GG-HR-USERS';          OUPath='OU=Users,DC=dobre,DC=local' }
    [PSCustomObject]@{ EmployeeID='DOB-ITX-2025-0013'; FirstName='Cynthia';  LastName='Ashu';     Username='cashu';    Department='IT';      Role='Help Desk Technician';         EmploymentType='OnSite'; Location='Buea HQ';           CountryRegion='Cameroon';       OfficeSubnet='192.168.40.0/24'; RemoteSubnet='192.168.41.0/24'; VLAN='VLAN40'; SecurityGroup='GG-IT-ADMINS';         OUPath='OU=Users,DC=dobre,DC=local' }
    [PSCustomObject]@{ EmployeeID='DOB-SRV-2025-0014'; FirstName='Derrick';  LastName='Fon';      Username='dfon';     Department='Servers'; Role='Backup Administrator';         EmploymentType='OnSite'; Location='Buea Data Center';  CountryRegion='Cameroon';       OfficeSubnet='192.168.60.0/24'; RemoteSubnet='192.168.99.0/24'; VLAN='VLAN60'; SecurityGroup='GG-SERVER-OPS';        OUPath='OU=Users,DC=dobre,DC=local' }
    [PSCustomObject]@{ EmployeeID='DOB-ITX-2025-0015'; FirstName='Ruth';     LastName='Ngu';      Username='rngu';     Department='IT';      Role='Cloud Support Engineer';       EmploymentType='Remote'; Location='United Kingdom';    CountryRegion='United Kingdom'; OfficeSubnet='192.168.40.0/24'; RemoteSubnet='192.168.41.0/24'; VLAN='VLAN40'; SecurityGroup='GG-IT-REMOTE';         OUPath='OU=Users,DC=dobre,DC=local' }
    [PSCustomObject]@{ EmployeeID='DOB-FIN-2025-0016'; FirstName='Francis';  LastName='Ebot';     Username='febot';    Department='Finance'; Role='Accounts Receivable Clerk';    EmploymentType='OnSite'; Location='Buea HQ';           CountryRegion='Cameroon';       OfficeSubnet='192.168.30.0/24'; RemoteSubnet='192.168.31.0/24'; VLAN='VLAN30'; SecurityGroup='GG-FIN-USERS';         OUPath='OU=Users,DC=dobre,DC=local' }
    [PSCustomObject]@{ EmployeeID='DOB-FIN-2025-0017'; FirstName='Miriam';   LastName='Achiri';   Username='machiri';  Department='Finance'; Role='Budget Analyst';               EmploymentType='Remote'; Location='Douala';            CountryRegion='Cameroon';       OfficeSubnet='192.168.30.0/24'; RemoteSubnet='192.168.31.0/24'; VLAN='VLAN30'; SecurityGroup='GG-FIN-REMOTE';        OUPath='OU=Users,DC=dobre,DC=local' }
    [PSCustomObject]@{ EmployeeID='DOB-FIN-2025-0018'; FirstName='George';   LastName='Bime';     Username='gbime';    Department='Finance'; Role='Payroll Officer';              EmploymentType='OnSite'; Location='Douala';            CountryRegion='Cameroon';       OfficeSubnet='192.168.30.0/24'; RemoteSubnet='192.168.31.0/24'; VLAN='VLAN30'; SecurityGroup='GG-FIN-USERS';         OUPath='OU=Users,DC=dobre,DC=local' }
    [PSCustomObject]@{ EmployeeID='DOB-FIN-2025-0019'; FirstName='Hilda';    LastName='Tanyi';    Username='htanyi';   Department='Finance'; Role='Tax Compliance Officer';       EmploymentType='Remote'; Location='Yaounde';           CountryRegion='Cameroon';       OfficeSubnet='192.168.30.0/24'; RemoteSubnet='192.168.31.0/24'; VLAN='VLAN30'; SecurityGroup='GG-FIN-REMOTE';        OUPath='OU=Users,DC=dobre,DC=local' }
    [PSCustomObject]@{ EmployeeID='DOB-FIN-2025-0020'; FirstName='Anthony';  LastName='Egbe';     Username='aegbe';    Department='Finance'; Role='Internal Auditor';             EmploymentType='OnSite'; Location='Buea HQ';           CountryRegion='Cameroon';       OfficeSubnet='192.168.30.0/24'; RemoteSubnet='192.168.31.0/24'; VLAN='VLAN30'; SecurityGroup='GG-FIN-USERS';         OUPath='OU=Users,DC=dobre,DC=local' }
    [PSCustomObject]@{ EmployeeID='DOB-HRT-2025-0021'; FirstName='Peter';    LastName='Nde';      Username='pnde';     Department='HR';      Role='HR Business Partner';          EmploymentType='OnSite'; Location='Buea HQ';           CountryRegion='Cameroon';       OfficeSubnet='192.168.20.0/24'; RemoteSubnet='192.168.21.0/24'; VLAN='VLAN20'; SecurityGroup='GG-HR-USERS';          OUPath='OU=Users,DC=dobre,DC=local' }
    [PSCustomObject]@{ EmployeeID='DOB-HRT-2025-0022'; FirstName='Comfort';  LastName='Ayuk';     Username='cayuk';    Department='HR';      Role='Talent Acquisition Lead';      EmploymentType='Remote'; Location='Bamenda';           CountryRegion='Cameroon';       OfficeSubnet='192.168.20.0/24'; RemoteSubnet='192.168.21.0/24'; VLAN='VLAN20'; SecurityGroup='GG-HR-REMOTE';         OUPath='OU=Users,DC=dobre,DC=local' }
    [PSCustomObject]@{ EmployeeID='DOB-HRT-2025-0023'; FirstName='Nelson';   LastName='Che';      Username='nche';     Department='HR';      Role='Payroll & Benefits Admin';     EmploymentType='OnSite'; Location='Buea HQ';           CountryRegion='Cameroon';       OfficeSubnet='192.168.20.0/24'; RemoteSubnet='192.168.21.0/24'; VLAN='VLAN20'; SecurityGroup='GG-HR-USERS';          OUPath='OU=Users,DC=dobre,DC=local' }
    [PSCustomObject]@{ EmployeeID='DOB-HRT-2025-0024'; FirstName='Ivy';      LastName='Manka';    Username='imanka';   Department='HR';      Role='Training Coordinator';         EmploymentType='Remote'; Location='Limbe';             CountryRegion='Cameroon';       OfficeSubnet='192.168.20.0/24'; RemoteSubnet='192.168.21.0/24'; VLAN='VLAN20'; SecurityGroup='GG-HR-REMOTE';         OUPath='OU=Users,DC=dobre,DC=local' }
    [PSCustomObject]@{ EmployeeID='DOB-HRT-2025-0025'; FirstName='Patience'; LastName='Nkeng';    Username='pnkeng';   Department='HR';      Role='Employee Relations Officer';   EmploymentType='Remote'; Location='Kribi';             CountryRegion='Cameroon';       OfficeSubnet='192.168.20.0/24'; RemoteSubnet='192.168.21.0/24'; VLAN='VLAN20'; SecurityGroup='GG-HR-REMOTE';         OUPath='OU=Users,DC=dobre,DC=local' }
    [PSCustomObject]@{ EmployeeID='DOB-ITX-2025-0026'; FirstName='Bruno';    LastName='Etonde';   Username='betonde';  Department='IT';      Role='Help Desk Technician';         EmploymentType='OnSite'; Location='Buea HQ';           CountryRegion='Cameroon';       OfficeSubnet='192.168.40.0/24'; RemoteSubnet='192.168.41.0/24'; VLAN='VLAN40'; SecurityGroup='GG-IT-ADMINS';         OUPath='OU=Users,DC=dobre,DC=local' }
    [PSCustomObject]@{ EmployeeID='DOB-ITX-2025-0027'; FirstName='Precious'; LastName='Mbah';     Username='pmbah';    Department='IT';      Role='Cloud Support Engineer';       EmploymentType='Remote'; Location='Berlin';            CountryRegion='Germany';        OfficeSubnet='192.168.40.0/24'; RemoteSubnet='192.168.41.0/24'; VLAN='VLAN40'; SecurityGroup='GG-IT-REMOTE';         OUPath='OU=Users,DC=dobre,DC=local' }
    [PSCustomObject]@{ EmployeeID='DOB-ITX-2025-0028'; FirstName='Collins';  LastName='Ngala';    Username='cngala';   Department='IT';      Role='Network Administrator';        EmploymentType='OnSite'; Location='Buea HQ';           CountryRegion='Cameroon';       OfficeSubnet='192.168.40.0/24'; RemoteSubnet='192.168.41.0/24'; VLAN='VLAN40'; SecurityGroup='GG-IT-ADMINS';         OUPath='OU=Users,DC=dobre,DC=local' }
    [PSCustomObject]@{ EmployeeID='DOB-ITX-2025-0029'; FirstName='Faith';    LastName='Besong';   Username='fbesong';  Department='IT';      Role='Application Support Eng.';     EmploymentType='Remote'; Location='Lagos';             CountryRegion='Nigeria';        OfficeSubnet='192.168.40.0/24'; RemoteSubnet='192.168.41.0/24'; VLAN='VLAN40'; SecurityGroup='GG-IT-REMOTE';         OUPath='OU=Users,DC=dobre,DC=local' }
    [PSCustomObject]@{ EmployeeID='DOB-ITX-2025-0030'; FirstName='Roland';   LastName='Ashu';     Username='rashu';    Department='IT';      Role='IT Security Analyst';          EmploymentType='OnSite'; Location='Buea HQ';           CountryRegion='Cameroon';       OfficeSubnet='192.168.40.0/24'; RemoteSubnet='192.168.41.0/24'; VLAN='VLAN40'; SecurityGroup='GG-IT-ADMINS';         OUPath='OU=Users,DC=dobre,DC=local' }
    [PSCustomObject]@{ EmployeeID='DOB-SRV-2025-0031'; FirstName='Vincent';  LastName='Tabot';    Username='vtabot';   Department='Servers'; Role='Virtualization Engineer';      EmploymentType='OnSite'; Location='Buea Data Center';  CountryRegion='Cameroon';       OfficeSubnet='192.168.60.0/24'; RemoteSubnet='192.168.99.0/24'; VLAN='VLAN60'; SecurityGroup='GG-SERVER-OPS';        OUPath='OU=Users,DC=dobre,DC=local' }
    [PSCustomObject]@{ EmployeeID='DOB-SRV-2025-0032'; FirstName='Diana';    LastName='Ekema';    Username='dekema';   Department='Servers'; Role='Remote SysOps Engineer';       EmploymentType='Remote'; Location='Johannesburg';      CountryRegion='South Africa';   OfficeSubnet='192.168.60.0/24'; RemoteSubnet='192.168.99.0/24'; VLAN='VLAN60'; SecurityGroup='GG-SERVER-REMOTE-OPS'; OUPath='OU=Users,DC=dobre,DC=local' }
    [PSCustomObject]@{ EmployeeID='DOB-SRV-2025-0033'; FirstName='Martin';   LastName='Ojong';    Username='mojong';   Department='Servers'; Role='Storage Administrator';        EmploymentType='OnSite'; Location='Buea Data Center';  CountryRegion='Cameroon';       OfficeSubnet='192.168.60.0/24'; RemoteSubnet='192.168.99.0/24'; VLAN='VLAN60'; SecurityGroup='GG-SERVER-OPS';        OUPath='OU=Users,DC=dobre,DC=local' }
    [PSCustomObject]@{ EmployeeID='DOB-SRV-2025-0034'; FirstName='Gloria';   LastName='Fru';      Username='gfru';     Department='Servers'; Role='Cloud Infrastructure Eng.';    EmploymentType='Remote'; Location='Paris';             CountryRegion='France';         OfficeSubnet='192.168.60.0/24'; RemoteSubnet='192.168.99.0/24'; VLAN='VLAN60'; SecurityGroup='GG-SERVER-REMOTE-OPS'; OUPath='OU=Users,DC=dobre,DC=local' }
    [PSCustomObject]@{ EmployeeID='DOB-SRV-2025-0035'; FirstName='Judith';   LastName='Mola';     Username='jmola';    Department='Servers'; Role='Database Administrator';       EmploymentType='Remote'; Location='Douala';            CountryRegion='Cameroon';       OfficeSubnet='192.168.60.0/24'; RemoteSubnet='192.168.99.0/24'; VLAN='VLAN60'; SecurityGroup='GG-SERVER-REMOTE-OPS'; OUPath='OU=Users,DC=dobre,DC=local' }
)

# --- AD_Groups data ---------------------------------------------------------
$ADGroups = @(
    [PSCustomObject]@{ GroupName='GG-FIN-USERS';         Department='Finance'; Purpose='Finance office users';        AllowedNetwork='192.168.30.0/24' }
    [PSCustomObject]@{ GroupName='GG-FIN-REMOTE';        Department='Finance'; Purpose='Finance remote workforce';    AllowedNetwork='192.168.31.0/24' }
    [PSCustomObject]@{ GroupName='GG-HR-USERS';          Department='HR';      Purpose='HR office users';             AllowedNetwork='192.168.20.0/24' }
    [PSCustomObject]@{ GroupName='GG-HR-REMOTE';         Department='HR';      Purpose='HR remote workforce';         AllowedNetwork='192.168.21.0/24' }
    [PSCustomObject]@{ GroupName='GG-IT-ADMINS';         Department='IT';      Purpose='IT administrators';           AllowedNetwork='192.168.40.0/24' }
    [PSCustomObject]@{ GroupName='GG-IT-REMOTE';         Department='IT';      Purpose='IT remote workforce';         AllowedNetwork='192.168.41.0/24' }
    [PSCustomObject]@{ GroupName='GG-SERVER-OPS';        Department='Servers'; Purpose='On-prem server administrators'; AllowedNetwork='192.168.60.0/24' }
    [PSCustomObject]@{ GroupName='GG-SERVER-REMOTE-OPS'; Department='Servers'; Purpose='Remote SysOps operations';    AllowedNetwork='192.168.99.0/24' }
)

# --- Build workbook ---------------------------------------------------------
Write-Host "[*] Writing Employees worksheet..." -ForegroundColor Cyan
$Employees | Export-Excel -Path $OutFile -WorksheetName 'Employees' `
    -AutoSize -FreezeTopRow -BoldTopRow -TableStyle Medium2 -ClearSheet

Write-Host "[*] Writing AD_Groups worksheet..." -ForegroundColor Cyan
$ADGroups | Export-Excel -Path $OutFile -WorksheetName 'AD_Groups' `
    -AutoSize -FreezeTopRow -BoldTopRow -TableStyle Medium2 -ClearSheet

# --- Post-build verification ------------------------------------------------
$pkg = Open-ExcelPackage -Path $OutFile
Write-Host ""
Write-Host "============================================================" -ForegroundColor Green
Write-Host " WORKBOOK BUILD SUCCESSFUL" -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Green
Write-Host " File        : $OutFile"
Write-Host " Worksheets  : $($pkg.Workbook.Worksheets.Count) -> $([string]::Join(', ', $pkg.Workbook.Worksheets.Name))"
Write-Host " Employees   : $($Employees.Count) rows"
Write-Host " AD Groups   : $($ADGroups.Count) rows"
Write-Host "============================================================" -ForegroundColor Green
Close-ExcelPackage $pkg