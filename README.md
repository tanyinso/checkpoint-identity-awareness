[2026-10-07 02:12:34] [OK] Starting AD deployment for DC=dobre,DC=local
[2026-10-07 02:12:34] [INFO] Creating OU structure...
[2026-10-07 02:12:34] [ERROR] OU failed OU=_ADMIN,DC=dobre,DC=local : Directory object not found
[2026-10-07 02:12:34] [ERROR] OU failed OU=ServiceAccounts,OU=_ADMIN,DC=dobre,DC=local : Directory object not found
[2026-10-07 02:12:34] [ERROR] OU failed OU=Tier0-Admins,OU=_ADMIN,DC=dobre,DC=local : Directory object not found
[2026-10-07 02:12:34] [ERROR] OU failed OU=Tier1-Admins,OU=_ADMIN,DC=dobre,DC=local : Directory object not found
[2026-10-07 02:12:34] [ERROR] OU failed OU=Tier2-Admins,OU=_ADMIN,DC=dobre,DC=local : Directory object not found
[2026-10-07 02:12:34] [ERROR] OU failed OU=PRODUCTION,DC=dobre,DC=local : Directory object not found
[2026-10-07 02:12:34] [ERROR] OU failed OU=Users,OU=PRODUCTION,DC=dobre,DC=local : Directory object not found
[2026-10-07 02:12:34] [ERROR] OU failed OU=Computers,OU=PRODUCTION,DC=dobre,DC=local : Directory object not found
[2026-10-07 02:12:34] [ERROR] OU failed OU=Servers,OU=PRODUCTION,DC=dobre,DC=local : Directory object not found
[2026-10-07 02:12:34] [ERROR] OU failed OU=Groups,OU=PRODUCTION,DC=dobre,DC=local : Directory object not found
[2026-10-07 02:12:34] [ERROR] OU failed OU=BACKUP,DC=dobre,DC=local : Directory object not found
[2026-10-07 02:12:34] [ERROR] OU failed OU=Computers,OU=BACKUP,DC=dobre,DC=local : Directory object not found
[2026-10-07 02:12:34] [ERROR] OU failed OU=Servers,OU=BACKUP,DC=dobre,DC=local : Directory object not found
[2026-10-07 02:12:34] [ERROR] OU failed OU=Groups,OU=BACKUP,DC=dobre,DC=local : Directory object not found
[2026-10-07 02:12:34] [ERROR] OU failed OU=REMOTE-ADMIN,DC=dobre,DC=local : Directory object not found
[2026-10-07 02:12:34] [ERROR] OU failed OU=Users,OU=REMOTE-ADMIN,DC=dobre,DC=local : Directory object not found
[2026-10-07 02:12:34] [ERROR] OU failed OU=Groups,OU=REMOTE-ADMIN,DC=dobre,DC=local : Directory object not found
[2026-10-07 02:12:34] [ERROR] OU failed OU=SERVICE-ACCOUNTS,DC=dobre,DC=local : Directory object not found
[2026-10-07 02:12:34] [ERROR] OU failed OU=FIN,OU=Users,OU=PRODUCTION,DC=dobre,DC=local : Directory object not found
[2026-10-07 02:12:34] [ERROR] OU failed OU=HR,OU=Users,OU=PRODUCTION,DC=dobre,DC=local : Directory object not found
[2026-10-07 02:12:34] [ERROR] OU failed OU=IT,OU=Users,OU=PRODUCTION,DC=dobre,DC=local : Directory object not found
[2026-10-07 02:12:34] [INFO] Creating security groups...
[2026-10-07 02:12:34] [ERROR] Group failed GG-SVC-Admin: Directory object not found
[2026-10-07 02:12:34] [ERROR] Group failed GG-Infra-Admin: Directory object not found
[2026-10-07 02:12:34] [ERROR] Group failed GG-Ops-Admin: Directory object not found
[2026-10-07 02:12:34] [ERROR] Group failed GG-Remote-Admin: Directory object not found
[2026-10-07 02:12:34] [ERROR] Group failed GG-Helpdesk: Directory object not found
[2026-10-07 02:12:34] [ERROR] Group failed GG-Prod-Server-Admins: Directory object not found
[2026-10-07 02:12:34] [ERROR] Group failed GG-Backup-Server-Admins: Directory object not found
[2026-10-07 02:12:34] [ERROR] Group failed GG-Backup-Operators: Directory object not found
[2026-10-07 02:12:34] [ERROR] Group failed GG-IT-Users: Directory object not found
[2026-10-07 02:12:34] [ERROR] Group failed GG-IT-Managers: Directory object not found
[2026-10-07 02:12:34] [ERROR] Group failed DL-IT-Share: Directory object not found
[2026-10-07 02:12:35] [ERROR] Group failed GG-FIN-Users: Directory object not found
[2026-10-07 02:12:35] [ERROR] Group failed GG-FIN-Managers: Directory object not found
[2026-10-07 02:12:35] [ERROR] Group failed DL-FIN-Share: Directory object not found
[2026-10-07 02:12:35] [ERROR] Group failed GG-HR-Users: Directory object not found
[2026-10-07 02:12:35] [ERROR] Group failed GG-HR-Managers: Directory object not found
[2026-10-07 02:12:35] [ERROR] Group failed DL-HR-Share: Directory object not found
[2026-10-07 02:12:35] [INFO] Nesting groups...
[2026-10-07 02:12:35] [WARN] Nesting skip (GG-Infra-Admin -> GG-Prod-Server-Admins): Cannot find an object with identity: 'GG-Infra-Admin' under: 'DC=dobre,DC=local'.
[2026-10-07 02:12:35] [WARN] Nesting skip (GG-Infra-Admin -> GG-Backup-Server-Admins): Cannot find an object with identity: 'GG-Infra-Admin' under: 'DC=dobre,DC=local'.
[2026-10-07 02:12:35] [WARN] Nesting skip (GG-Ops-Admin -> GG-Backup-Operators): Cannot find an object with identity: 'GG-Ops-Admin' under: 'DC=dobre,DC=local'.
[2026-10-07 02:12:35] [WARN] Nesting skip (GG-Ops-Admin -> GG-Helpdesk): Cannot find an object with identity: 'GG-Ops-Admin' under: 'DC=dobre,DC=local'.
[2026-10-07 02:12:35] [WARN] Nesting skip (GG-FIN-Users -> DL-FIN-Share): Cannot find an object with identity: 'GG-FIN-Users' under: 'DC=dobre,DC=local'.
[2026-10-07 02:12:35] [WARN] Nesting skip (GG-FIN-Managers -> DL-FIN-Share): Cannot find an object with identity: 'GG-FIN-Managers' under: 'DC=dobre,DC=local'.
[2026-10-07 02:12:35] [WARN] Nesting skip (GG-HR-Users -> DL-HR-Share): Cannot find an object with identity: 'GG-HR-Users' under: 'DC=dobre,DC=local'.
[2026-10-07 02:12:35] [WARN] Nesting skip (GG-HR-Managers -> DL-HR-Share): Cannot find an object with identity: 'GG-HR-Managers' under: 'DC=dobre,DC=local'.
[2026-10-07 02:12:35] [WARN] Nesting skip (GG-IT-Users -> DL-IT-Share): Cannot find an object with identity: 'GG-IT-Users' under: 'DC=dobre,DC=local'.
[2026-10-07 02:12:35] [WARN] Nesting skip (GG-IT-Managers -> DL-IT-Share): Cannot find an object with identity: 'GG-IT-Managers' under: 'DC=dobre,DC=local'.
[2026-10-07 02:12:35] [INFO] Creating service accounts...
[2026-10-07 02:12:35] [ERROR] Service account failed svc_admin: Directory object not found
[2026-10-07 02:12:35] [ERROR] Service account failed svc_backup: Directory object not found
[2026-10-07 02:12:35] [ERROR] Service account failed svc_monitoring: Directory object not found
[2026-10-07 02:12:35] [INFO] Importing users from users.xlsx...
[2026-10-07 02:12:35] [ERROR] ImportExcel missing. Run: Install-Module ImportExcel
[2026-10-07 02:16:41] [OK] Starting AD deployment for DC=dobre,DC=local
[2026-10-07 02:16:41] [INFO] Creating OU structure...
[2026-10-07 02:16:41] [ERROR] OU failed OU=_ADMIN,DC=dobre,DC=local : Directory object not found
[2026-10-07 02:16:41] [ERROR] OU failed OU=ServiceAccounts,OU=_ADMIN,DC=dobre,DC=local : Directory object not found
[2026-10-07 02:16:41] [ERROR] OU failed OU=Tier0-Admins,OU=_ADMIN,DC=dobre,DC=local : Directory object not found
[2026-10-07 02:16:41] [ERROR] OU failed OU=Tier1-Admins,OU=_ADMIN,DC=dobre,DC=local : Directory object not found
[2026-10-07 02:16:41] [ERROR] OU failed OU=Tier2-Admins,OU=_ADMIN,DC=dobre,DC=local : Directory object not found
[2026-10-07 02:16:41] [ERROR] OU failed OU=PRODUCTION,DC=dobre,DC=local : Directory object not found
[2026-10-07 02:16:41] [ERROR] OU failed OU=Users,OU=PRODUCTION,DC=dobre,DC=local : Directory object not found
[2026-10-07 02:16:41] [ERROR] OU failed OU=Computers,OU=PRODUCTION,DC=dobre,DC=local : Directory object not found
[2026-10-07 02:16:41] [ERROR] OU failed OU=Servers,OU=PRODUCTION,DC=dobre,DC=local : Directory object not found
[2026-10-07 02:16:41] [ERROR] OU failed OU=Groups,OU=PRODUCTION,DC=dobre,DC=local : Directory object not found
[2026-10-07 02:16:41] [ERROR] OU failed OU=BACKUP,DC=dobre,DC=local : Directory object not found
[2026-10-07 02:16:41] [ERROR] OU failed OU=Computers,OU=BACKUP,DC=dobre,DC=local : Directory object not found
[2026-10-07 02:16:41] [ERROR] OU failed OU=Servers,OU=BACKUP,DC=dobre,DC=local : Directory object not found
[2026-10-07 02:16:41] [ERROR] OU failed OU=Groups,OU=BACKUP,DC=dobre,DC=local : Directory object not found
[2026-10-07 02:16:41] [ERROR] OU failed OU=REMOTE-ADMIN,DC=dobre,DC=local : Directory object not found
[2026-10-07 02:16:41] [ERROR] OU failed OU=Users,OU=REMOTE-ADMIN,DC=dobre,DC=local : Directory object not found
[2026-10-07 02:16:41] [ERROR] OU failed OU=Groups,OU=REMOTE-ADMIN,DC=dobre,DC=local : Directory object not found
[2026-10-07 02:16:41] [ERROR] OU failed OU=SERVICE-ACCOUNTS,DC=dobre,DC=local : Directory object not found
[2026-10-07 02:16:41] [ERROR] OU failed OU=FIN,OU=Users,OU=PRODUCTION,DC=dobre,DC=local : Directory object not found
[2026-10-07 02:16:41] [ERROR] OU failed OU=HR,OU=Users,OU=PRODUCTION,DC=dobre,DC=local : Directory object not found
[2026-10-07 02:16:41] [ERROR] OU failed OU=IT,OU=Users,OU=PRODUCTION,DC=dobre,DC=local : Directory object not found
[2026-10-07 02:16:41] [INFO] Creating security groups...
[2026-10-07 02:16:41] [ERROR] Group failed GG-SVC-Admin: Directory object not found
[2026-10-07 02:16:41] [ERROR] Group failed GG-Infra-Admin: Directory object not found
[2026-10-07 02:16:41] [ERROR] Group failed GG-Ops-Admin: Directory object not found
[2026-10-07 02:16:41] [ERROR] Group failed GG-Remote-Admin: Directory object not found
[2026-10-07 02:16:41] [ERROR] Group failed GG-Helpdesk: Directory object not found
[2026-10-07 02:16:41] [ERROR] Group failed GG-Prod-Server-Admins: Directory object not found
[2026-10-07 02:16:41] [ERROR] Group failed GG-Backup-Server-Admins: Directory object not found
[2026-10-07 02:16:41] [ERROR] Group failed GG-Backup-Operators: Directory object not found
[2026-10-07 02:16:41] [ERROR] Group failed GG-IT-Users: Directory object not found
[2026-10-07 02:16:41] [ERROR] Group failed GG-IT-Managers: Directory object not found
[2026-10-07 02:16:41] [ERROR] Group failed DL-IT-Share: Directory object not found
[2026-10-07 02:16:41] [ERROR] Group failed GG-FIN-Users: Directory object not found
[2026-10-07 02:16:41] [ERROR] Group failed GG-FIN-Managers: Directory object not found
[2026-10-07 02:16:41] [ERROR] Group failed DL-FIN-Share: Directory object not found
[2026-10-07 02:16:41] [ERROR] Group failed GG-HR-Users: Directory object not found
[2026-10-07 02:16:42] [ERROR] Group failed GG-HR-Managers: Directory object not found
[2026-10-07 02:16:42] [ERROR] Group failed DL-HR-Share: Directory object not found
[2026-10-07 02:16:42] [INFO] Nesting groups...
[2026-10-07 02:16:42] [WARN] Nesting skip (GG-Infra-Admin -> GG-Prod-Server-Admins): Cannot find an object with identity: 'GG-Infra-Admin' under: 'DC=dobre,DC=local'.
[2026-10-07 02:16:42] [WARN] Nesting skip (GG-Infra-Admin -> GG-Backup-Server-Admins): Cannot find an object with identity: 'GG-Infra-Admin' under: 'DC=dobre,DC=local'.
[2026-10-07 02:16:42] [WARN] Nesting skip (GG-Ops-Admin -> GG-Backup-Operators): Cannot find an object with identity: 'GG-Ops-Admin' under: 'DC=dobre,DC=local'.
[2026-10-07 02:16:42] [WARN] Nesting skip (GG-Ops-Admin -> GG-Helpdesk): Cannot find an object with identity: 'GG-Ops-Admin' under: 'DC=dobre,DC=local'.
[2026-10-07 02:16:42] [WARN] Nesting skip (GG-FIN-Users -> DL-FIN-Share): Cannot find an object with identity: 'GG-FIN-Users' under: 'DC=dobre,DC=local'.
[2026-10-07 02:16:42] [WARN] Nesting skip (GG-FIN-Managers -> DL-FIN-Share): Cannot find an object with identity: 'GG-FIN-Managers' under: 'DC=dobre,DC=local'.
[2026-10-07 02:16:42] [WARN] Nesting skip (GG-HR-Users -> DL-HR-Share): Cannot find an object with identity: 'GG-HR-Users' under: 'DC=dobre,DC=local'.
[2026-10-07 02:16:42] [WARN] Nesting skip (GG-HR-Managers -> DL-HR-Share): Cannot find an object with identity: 'GG-HR-Managers' under: 'DC=dobre,DC=local'.
[2026-10-07 02:16:42] [WARN] Nesting skip (GG-IT-Users -> DL-IT-Share): Cannot find an object with identity: 'GG-IT-Users' under: 'DC=dobre,DC=local'.
[2026-10-07 02:16:42] [WARN] Nesting skip (GG-IT-Managers -> DL-IT-Share): Cannot find an object with identity: 'GG-IT-Managers' under: 'DC=dobre,DC=local'.
[2026-10-07 02:16:42] [INFO] Creating service accounts...
[2026-10-07 02:16:42] [ERROR] Service account failed svc_admin: Directory object not found
[2026-10-07 02:16:42] [ERROR] Service account failed svc_backup: Directory object not found
[2026-10-07 02:16:42] [ERROR] Service account failed svc_monitoring: Directory object not found
[2026-10-07 02:16:42] [INFO] Importing users from users.csv...
[2026-10-07 02:16:42] [ERROR] User failed : Directory object not found
[2026-10-07 02:16:42] [ERROR] User failed : The search filter cannot be recognized
[2026-10-07 02:16:42] [ERROR] User failed : Directory object not found
[2026-10-07 02:16:42] [ERROR] User failed : The search filter cannot be recognized
[2026-10-07 02:16:42] [ERROR] User failed : Directory object not found
[2026-10-07 02:16:42] [ERROR] User failed : The search filter cannot be recognized
[2026-10-07 02:16:42] [ERROR] User failed : Directory object not found
[2026-10-07 02:16:42] [ERROR] User failed : The search filter cannot be recognized
[2026-10-07 02:16:42] [ERROR] User failed : Directory object not found
[2026-10-07 02:16:42] [ERROR] User failed : The search filter cannot be recognized
[2026-10-07 02:16:42] [ERROR] User failed : Directory object not found
[2026-10-07 02:16:42] [ERROR] User failed : The search filter cannot be recognized
[2026-10-07 02:16:42] [ERROR] User failed : Directory object not found
[2026-10-07 02:16:42] [ERROR] User failed : The search filter cannot be recognized
[2026-10-07 02:16:42] [ERROR] User failed : Directory object not found
[2026-10-07 02:16:42] [ERROR] User failed : The search filter cannot be recognized
[2026-10-07 02:16:42] [ERROR] User failed : Directory object not found
[2026-10-07 02:16:42] [ERROR] User failed : The search filter cannot be recognized
[2026-10-07 02:16:42] [ERROR] User failed : Directory object not found
[2026-10-07 02:16:42] [ERROR] User failed : The search filter cannot be recognized
[2026-10-07 02:16:42] [ERROR] User failed : Directory object not found
[2026-10-07 02:16:42] [ERROR] User failed : The search filter cannot be recognized
[2026-10-07 02:16:42] [ERROR] User failed : Directory object not found
[2026-10-07 02:16:42] [ERROR] User failed : The search filter cannot be recognized
[2026-10-07 02:16:42] [ERROR] User failed : Directory object not found
[2026-10-07 02:16:42] [ERROR] User failed : The search filter cannot be recognized
[2026-10-07 02:16:42] [ERROR] User failed : Directory object not found
[2026-10-07 02:16:42] [OK] ==========================================
[2026-10-07 02:16:42] [OK] DEPLOYMENT COMPLETE
[2026-10-07 02:16:42] [OK] OUs:              21
[2026-10-07 02:16:42] [OK] Groups:           1
[2026-10-07 02:16:42] [OK] Service accounts: 3
[2026-10-07 02:16:42] [OK] Users processed:  27
[2026-10-07 02:16:43] [OK] Log: C:\AD-Deploy\deploy.log
[2026-10-07 02:16:43] [OK] ==========================================
[2026-10-07 02:25:22] [OK] Starting AD deployment for DC=dobre,DC=local
[2026-10-07 02:25:22] [INFO] Creating OU structure...
[2026-10-07 02:25:22] [ERROR] OU failed OU=_ADMIN,DC=dobre,DC=local : Directory object not found
[2026-10-07 02:25:22] [ERROR] OU failed OU=ServiceAccounts,OU=_ADMIN,DC=dobre,DC=local : Directory object not found
[2026-10-07 02:25:22] [ERROR] OU failed OU=Tier0-Admins,OU=_ADMIN,DC=dobre,DC=local : Directory object not found
[2026-10-07 02:25:22] [ERROR] OU failed OU=Tier1-Admins,OU=_ADMIN,DC=dobre,DC=local : Directory object not found
[2026-10-07 02:25:22] [ERROR] OU failed OU=Tier2-Admins,OU=_ADMIN,DC=dobre,DC=local : Directory object not found
[2026-10-07 02:25:22] [ERROR] OU failed OU=PRODUCTION,DC=dobre,DC=local : Directory object not found
[2026-10-07 02:25:22] [ERROR] OU failed OU=Users,OU=PRODUCTION,DC=dobre,DC=local : Directory object not found
[2026-10-07 02:25:22] [ERROR] OU failed OU=Computers,OU=PRODUCTION,DC=dobre,DC=local : Directory object not found
[2026-10-07 02:25:22] [ERROR] OU failed OU=Servers,OU=PRODUCTION,DC=dobre,DC=local : Directory object not found
[2026-10-07 02:25:22] [ERROR] OU failed OU=Groups,OU=PRODUCTION,DC=dobre,DC=local : Directory object not found
[2026-10-07 02:25:22] [ERROR] OU failed OU=BACKUP,DC=dobre,DC=local : Directory object not found
[2026-10-07 02:25:22] [ERROR] OU failed OU=Computers,OU=BACKUP,DC=dobre,DC=local : Directory object not found
[2026-10-07 02:25:22] [ERROR] OU failed OU=Servers,OU=BACKUP,DC=dobre,DC=local : Directory object not found
[2026-10-07 02:25:22] [ERROR] OU failed OU=Groups,OU=BACKUP,DC=dobre,DC=local : Directory object not found
[2026-10-07 02:25:22] [ERROR] OU failed OU=REMOTE-ADMIN,DC=dobre,DC=local : Directory object not found
[2026-10-07 02:25:22] [ERROR] OU failed OU=Users,OU=REMOTE-ADMIN,DC=dobre,DC=local : Directory object not found
[2026-10-07 02:25:22] [ERROR] OU failed OU=Groups,OU=REMOTE-ADMIN,DC=dobre,DC=local : Directory object not found
[2026-10-07 02:25:22] [ERROR] OU failed OU=SERVICE-ACCOUNTS,DC=dobre,DC=local : Directory object not found
[2026-10-07 02:25:22] [ERROR] OU failed OU=FIN,OU=Users,OU=PRODUCTION,DC=dobre,DC=local : Directory object not found
[2026-10-07 02:25:22] [ERROR] OU failed OU=HR,OU=Users,OU=PRODUCTION,DC=dobre,DC=local : Directory object not found
[2026-10-07 02:25:22] [ERROR] OU failed OU=IT,OU=Users,OU=PRODUCTION,DC=dobre,DC=local : Directory object not found
[2026-10-07 02:25:22] [INFO] Creating security groups...
[2026-10-07 02:25:23] [ERROR] Group failed GG-SVC-Admin: Directory object not found
[2026-10-07 02:25:23] [ERROR] Group failed GG-Infra-Admin: Directory object not found
[2026-10-07 02:25:23] [ERROR] Group failed GG-Ops-Admin: Directory object not found
[2026-10-07 02:25:23] [ERROR] Group failed GG-Remote-Admin: Directory object not found
[2026-10-07 02:25:23] [ERROR] Group failed GG-Helpdesk: Directory object not found
[2026-10-07 02:25:23] [ERROR] Group failed GG-Prod-Server-Admins: Directory object not found
[2026-10-07 02:25:23] [ERROR] Group failed GG-Backup-Server-Admins: Directory object not found
[2026-10-07 02:25:23] [ERROR] Group failed GG-Backup-Operators: Directory object not found
[2026-10-07 02:25:23] [ERROR] Group failed GG-IT-Users: Directory object not found
[2026-10-07 02:25:23] [ERROR] Group failed GG-IT-Managers: Directory object not found
[2026-10-07 02:25:23] [ERROR] Group failed DL-IT-Share: Directory object not found
[2026-10-07 02:25:23] [ERROR] Group failed GG-FIN-Users: Directory object not found
[2026-10-07 02:25:23] [ERROR] Group failed GG-FIN-Managers: Directory object not found
[2026-10-07 02:25:23] [ERROR] Group failed DL-FIN-Share: Directory object not found
[2026-10-07 02:25:23] [ERROR] Group failed GG-HR-Users: Directory object not found
[2026-10-07 02:25:23] [ERROR] Group failed GG-HR-Managers: Directory object not found
[2026-10-07 02:25:23] [ERROR] Group failed DL-HR-Share: Directory object not found
[2026-10-07 02:25:23] [INFO] Nesting groups...
[2026-10-07 02:25:23] [WARN] Nesting skip (GG-Infra-Admin -> GG-Prod-Server-Admins): Cannot find an object with identity: 'GG-Infra-Admin' under: 'DC=dobre,DC=local'.
[2026-10-07 02:25:23] [WARN] Nesting skip (GG-Infra-Admin -> GG-Backup-Server-Admins): Cannot find an object with identity: 'GG-Infra-Admin' under: 'DC=dobre,DC=local'.
[2026-10-07 02:25:23] [WARN] Nesting skip (GG-Ops-Admin -> GG-Backup-Operators): Cannot find an object with identity: 'GG-Ops-Admin' under: 'DC=dobre,DC=local'.
[2026-10-07 02:25:23] [WARN] Nesting skip (GG-Ops-Admin -> GG-Helpdesk): Cannot find an object with identity: 'GG-Ops-Admin' under: 'DC=dobre,DC=local'.
[2026-10-07 02:25:23] [WARN] Nesting skip (GG-FIN-Users -> DL-FIN-Share): Cannot find an object with identity: 'GG-FIN-Users' under: 'DC=dobre,DC=local'.
[2026-10-07 02:25:23] [WARN] Nesting skip (GG-FIN-Managers -> DL-FIN-Share): Cannot find an object with identity: 'GG-FIN-Managers' under: 'DC=dobre,DC=local'.
[2026-10-07 02:25:23] [WARN] Nesting skip (GG-HR-Users -> DL-HR-Share): Cannot find an object with identity: 'GG-HR-Users' under: 'DC=dobre,DC=local'.
[2026-10-07 02:25:23] [WARN] Nesting skip (GG-HR-Managers -> DL-HR-Share): Cannot find an object with identity: 'GG-HR-Managers' under: 'DC=dobre,DC=local'.
[2026-10-07 02:25:23] [WARN] Nesting skip (GG-IT-Users -> DL-IT-Share): Cannot find an object with identity: 'GG-IT-Users' under: 'DC=dobre,DC=local'.
[2026-10-07 02:25:23] [WARN] Nesting skip (GG-IT-Managers -> DL-IT-Share): Cannot find an object with identity: 'GG-IT-Managers' under: 'DC=dobre,DC=local'.
[2026-10-07 02:25:23] [INFO] Creating service accounts...
[2026-10-07 02:25:24] [ERROR] Service account failed svc_admin: Directory object not found
[2026-10-07 02:25:24] [ERROR] Service account failed svc_backup: Directory object not found
[2026-10-07 02:25:24] [ERROR] Service account failed svc_monitoring: Directory object not found
[2026-10-07 02:25:24] [INFO] Importing users from users.csv...
[2026-10-07 02:25:24] [ERROR] User failed : Directory object not found
[2026-10-07 02:25:24] [ERROR] User failed : The search filter cannot be recognized
[2026-10-07 02:25:24] [ERROR] User failed : Directory object not found
[2026-10-07 02:25:24] [ERROR] User failed : The search filter cannot be recognized
[2026-10-07 02:25:24] [ERROR] User failed : Directory object not found
[2026-10-07 02:25:24] [ERROR] User failed : The search filter cannot be recognized
[2026-10-07 02:25:24] [ERROR] User failed : Directory object not found
[2026-10-07 02:25:24] [ERROR] User failed : The search filter cannot be recognized
[2026-10-07 02:25:24] [ERROR] User failed : Directory object not found
[2026-10-07 02:25:24] [ERROR] User failed : The search filter cannot be recognized
[2026-10-07 02:25:24] [ERROR] User failed : Directory object not found
[2026-10-07 02:25:24] [ERROR] User failed : The search filter cannot be recognized
[2026-10-07 02:25:24] [ERROR] User failed : Directory object not found
[2026-10-07 02:25:24] [ERROR] User failed : The search filter cannot be recognized
[2026-10-07 02:25:24] [ERROR] User failed : Directory object not found
[2026-10-07 02:25:24] [ERROR] User failed : The search filter cannot be recognized
[2026-10-07 02:25:24] [ERROR] User failed : Directory object not found
[2026-10-07 02:25:24] [ERROR] User failed : The search filter cannot be recognized
[2026-10-07 02:25:24] [ERROR] User failed : Directory object not found
[2026-10-07 02:25:24] [ERROR] User failed : The search filter cannot be recognized
[2026-10-07 02:25:24] [ERROR] User failed : Directory object not found
[2026-10-07 02:25:24] [ERROR] User failed : The search filter cannot be recognized
[2026-10-07 02:25:24] [ERROR] User failed : Directory object not found
[2026-10-07 02:25:24] [ERROR] User failed : The search filter cannot be recognized
[2026-10-07 02:25:24] [ERROR] User failed : Directory object not found
[2026-10-07 02:25:24] [ERROR] User failed : The search filter cannot be recognized
[2026-10-07 02:25:24] [ERROR] User failed : Directory object not found
[2026-10-07 02:25:24] [OK] ==========================================
[2026-10-07 02:25:24] [OK] DEPLOYMENT COMPLETE
[2026-10-07 02:25:24] [OK] OUs:              21
[2026-10-07 02:25:24] [OK] Groups:           1
[2026-10-07 02:25:24] [OK] Service accounts: 3
[2026-10-07 02:25:24] [OK] Users processed:  27
[2026-10-07 02:25:24] [OK] Log: C:\AD-Deploy\deploy.log
[2026-10-07 02:25:24] [OK] ==========================================
[2026-10-07 02:53:08] [OK] Starting AD deployment for DC=dobre,DC=local
[2026-10-07 02:53:08] [INFO] Creating OU structure...
[2026-10-07 02:53:08] [ERROR] OU failed OU=_ADMIN,DC=dobre,DC=local : Directory object not found
[2026-10-07 02:53:08] [ERROR] OU failed OU=ServiceAccounts,OU=_ADMIN,DC=dobre,DC=local : Directory object not found
[2026-10-07 02:53:08] [ERROR] OU failed OU=Tier0-Admins,OU=_ADMIN,DC=dobre,DC=local : Directory object not found
[2026-10-07 02:53:08] [ERROR] OU failed OU=Tier1-Admins,OU=_ADMIN,DC=dobre,DC=local : Directory object not found
[2026-10-07 02:53:08] [ERROR] OU failed OU=Tier2-Admins,OU=_ADMIN,DC=dobre,DC=local : Directory object not found
[2026-10-07 02:53:08] [ERROR] OU failed OU=PRODUCTION,DC=dobre,DC=local : Directory object not found
[2026-10-07 02:53:08] [ERROR] OU failed OU=Users,OU=PRODUCTION,DC=dobre,DC=local : Directory object not found
[2026-10-07 02:53:08] [ERROR] OU failed OU=Computers,OU=PRODUCTION,DC=dobre,DC=local : Directory object not found
[2026-10-07 02:53:08] [ERROR] OU failed OU=Servers,OU=PRODUCTION,DC=dobre,DC=local : Directory object not found
[2026-10-07 02:53:08] [ERROR] OU failed OU=Groups,OU=PRODUCTION,DC=dobre,DC=local : Directory object not found
[2026-10-07 02:53:08] [ERROR] OU failed OU=BACKUP,DC=dobre,DC=local : Directory object not found
[2026-10-07 02:53:08] [ERROR] OU failed OU=Computers,OU=BACKUP,DC=dobre,DC=local : Directory object not found
[2026-10-07 02:53:08] [ERROR] OU failed OU=Servers,OU=BACKUP,DC=dobre,DC=local : Directory object not found
[2026-10-07 02:53:08] [ERROR] OU failed OU=Groups,OU=BACKUP,DC=dobre,DC=local : Directory object not found
[2026-10-07 02:53:08] [ERROR] OU failed OU=REMOTE-ADMIN,DC=dobre,DC=local : Directory object not found
[2026-10-07 02:53:08] [ERROR] OU failed OU=Users,OU=REMOTE-ADMIN,DC=dobre,DC=local : Directory object not found
[2026-10-07 02:53:08] [ERROR] OU failed OU=Groups,OU=REMOTE-ADMIN,DC=dobre,DC=local : Directory object not found
[2026-10-07 02:53:08] [ERROR] OU failed OU=SERVICE-ACCOUNTS,DC=dobre,DC=local : Directory object not found
[2026-10-07 02:53:08] [ERROR] OU failed OU=FIN,OU=Users,OU=PRODUCTION,DC=dobre,DC=local : Directory object not found
[2026-10-07 02:53:08] [ERROR] OU failed OU=HR,OU=Users,OU=PRODUCTION,DC=dobre,DC=local : Directory object not found
[2026-10-07 02:53:08] [ERROR] OU failed OU=IT,OU=Users,OU=PRODUCTION,DC=dobre,DC=local : Directory object not found
[2026-10-07 02:53:08] [INFO] Creating security groups...
[2026-10-07 02:53:08] [ERROR] Group failed GG-SVC-Admin: Directory object not found
[2026-10-07 02:53:08] [ERROR] Group failed GG-Infra-Admin: Directory object not found
[2026-10-07 02:53:09] [ERROR] Group failed GG-Ops-Admin: Directory object not found
[2026-10-07 02:53:09] [ERROR] Group failed GG-Remote-Admin: Directory object not found
[2026-10-07 02:53:09] [ERROR] Group failed GG-Helpdesk: Directory object not found
[2026-10-07 02:53:09] [ERROR] Group failed GG-Prod-Server-Admins: Directory object not found
[2026-10-07 02:53:09] [ERROR] Group failed GG-Backup-Server-Admins: Directory object not found
[2026-10-07 02:53:09] [ERROR] Group failed GG-Backup-Operators: Directory object not found
[2026-10-07 02:53:09] [ERROR] Group failed GG-IT-Users: Directory object not found
[2026-10-07 02:53:09] [ERROR] Group failed GG-IT-Managers: Directory object not found
[2026-10-07 02:53:09] [ERROR] Group failed DL-IT-Share: Directory object not found
[2026-10-07 02:53:09] [ERROR] Group failed GG-FIN-Users: Directory object not found
[2026-10-07 02:53:09] [ERROR] Group failed GG-FIN-Managers: Directory object not found
[2026-10-07 02:53:09] [ERROR] Group failed DL-FIN-Share: Directory object not found
[2026-10-07 02:53:09] [ERROR] Group failed GG-HR-Users: Directory object not found
[2026-10-07 02:53:09] [ERROR] Group failed GG-HR-Managers: Directory object not found
[2026-10-07 02:53:09] [ERROR] Group failed DL-HR-Share: Directory object not found
[2026-10-07 02:53:09] [INFO] Nesting groups...
[2026-10-07 02:53:09] [WARN] Nesting skip (GG-Infra-Admin -> GG-Prod-Server-Admins): Cannot find an object with identity: 'GG-Infra-Admin' under: 'DC=dobre,DC=local'.
[2026-10-07 02:53:09] [WARN] Nesting skip (GG-Infra-Admin -> GG-Backup-Server-Admins): Cannot find an object with identity: 'GG-Infra-Admin' under: 'DC=dobre,DC=local'.
[2026-10-07 02:53:09] [WARN] Nesting skip (GG-Ops-Admin -> GG-Backup-Operators): Cannot find an object with identity: 'GG-Ops-Admin' under: 'DC=dobre,DC=local'.
[2026-10-07 02:53:09] [WARN] Nesting skip (GG-Ops-Admin -> GG-Helpdesk): Cannot find an object with identity: 'GG-Ops-Admin' under: 'DC=dobre,DC=local'.
[2026-10-07 02:53:09] [WARN] Nesting skip (GG-FIN-Users -> DL-FIN-Share): Cannot find an object with identity: 'GG-FIN-Users' under: 'DC=dobre,DC=local'.
[2026-10-07 02:53:09] [WARN] Nesting skip (GG-FIN-Managers -> DL-FIN-Share): Cannot find an object with identity: 'GG-FIN-Managers' under: 'DC=dobre,DC=local'.
[2026-10-07 02:53:09] [WARN] Nesting skip (GG-HR-Users -> DL-HR-Share): Cannot find an object with identity: 'GG-HR-Users' under: 'DC=dobre,DC=local'.
[2026-10-07 02:53:09] [WARN] Nesting skip (GG-HR-Managers -> DL-HR-Share): Cannot find an object with identity: 'GG-HR-Managers' under: 'DC=dobre,DC=local'.
[2026-10-07 02:53:09] [WARN] Nesting skip (GG-IT-Users -> DL-IT-Share): Cannot find an object with identity: 'GG-IT-Users' under: 'DC=dobre,DC=local'.
[2026-10-07 02:53:09] [WARN] Nesting skip (GG-IT-Managers -> DL-IT-Share): Cannot find an object with identity: 'GG-IT-Managers' under: 'DC=dobre,DC=local'.
[2026-10-07 02:53:09] [INFO] Creating service accounts...
[2026-10-07 02:53:09] [ERROR] Service account failed svc_admin: Directory object not found
[2026-10-07 02:53:10] [ERROR] Service account failed svc_backup: Directory object not found
[2026-10-07 02:53:10] [ERROR] Service account failed svc_monitoring: Directory object not found
[2026-10-07 02:53:10] [INFO] Importing users from users.csv...
[2026-10-07 02:53:10] [ERROR] User failed jdoe: Directory object not found
[2026-10-07 02:53:10] [ERROR] User failed asmith: Directory object not found
[2026-10-07 02:53:10] [ERROR] User failed rkofi: Directory object not found
[2026-10-07 02:53:10] [ERROR] User failed mngugi: Directory object not found
[2026-10-07 02:53:10] [ERROR] User failed pade: Directory object not found
[2026-10-07 02:53:10] [ERROR] User failed lmensah: Directory object not found
[2026-10-07 02:53:10] [ERROR] User failed gmbarga: Directory object not found
[2026-10-07 02:53:10] [ERROR] User failed remote1: Directory object not found
[2026-10-07 02:53:10] [ERROR] User failed endongo: Directory object not found
[2026-10-07 02:53:10] [ERROR] User failed fabega: Directory object not found
[2026-10-07 02:53:10] [ERROR] User failed sbiloa: Directory object not found
[2026-10-07 02:53:10] [ERROR] User failed ambella: Directory object not found
[2026-10-07 02:53:10] [ERROR] User failed betoa: Directory object not found
[2026-10-07 02:53:10] [ERROR] User failed cfon: Directory object not found
[2026-10-07 02:53:10] [ERROR] User failed essomba: Directory object not found
[2026-10-07 02:53:10] [ERROR] User failed bewane: Directory object not found
[2026-10-07 02:53:10] [ERROR] User failed cmvondo: Directory object not found
[2026-10-07 02:53:10] [ERROR] User failed vetame: Directory object not found
[2026-10-07 02:53:10] [ERROR] User failed nelomo: Directory object not found
[2026-10-07 02:53:10] [ERROR] User failed amanga: Directory object not found
[2026-10-07 02:53:10] [OK] ==========================================
[2026-10-07 02:53:10] [OK] DEPLOYMENT COMPLETE
[2026-10-07 02:53:10] [OK] OUs:              21
[2026-10-07 02:53:10] [OK] Groups:           2
[2026-10-07 02:53:10] [OK] Service accounts: 3
[2026-10-07 02:53:10] [OK] Users processed:  20
[2026-10-07 02:53:10] [OK] Log: C:\AD-Deploy\deploy.log
[2026-10-07 02:53:10] [OK] ==========================================
[2026-10-07 03:20:17] [OK] ============================================
[2026-10-07 03:20:17] [OK] Starting deployment for dobre.local
[2026-10-07 03:20:17] [INFO] Domain DN: DC=dobre,DC=local
[2026-10-07 03:20:17] [INFO] Creating OU structure...
[2026-10-07 03:20:17] [ERROR] OU creation failed: OU=_ADMIN,DC=dobre,DC=local - Directory object not found
[2026-10-07 03:20:17] [ERROR] OU creation failed: OU=ServiceAccounts,OU=_ADMIN,DC=dobre,DC=local - Directory object not found
[2026-10-07 03:20:17] [ERROR] OU creation failed: OU=Tier0-Admins,OU=_ADMIN,DC=dobre,DC=local - Directory object not found
[2026-10-07 03:20:17] [ERROR] OU creation failed: OU=Tier1-Admins,OU=_ADMIN,DC=dobre,DC=local - Directory object not found
[2026-10-07 03:20:17] [ERROR] OU creation failed: OU=Tier2-Admins,OU=_ADMIN,DC=dobre,DC=local - Directory object not found
[2026-10-07 03:20:17] [ERROR] OU creation failed: OU=PRODUCTION,DC=dobre,DC=local - Directory object not found
[2026-10-07 03:20:17] [ERROR] OU creation failed: OU=Users,OU=PRODUCTION,DC=dobre,DC=local - Directory object not found
[2026-10-07 03:20:17] [ERROR] OU creation failed: OU=FIN,OU=Users,OU=PRODUCTION,DC=dobre,DC=local - Directory object not found
[2026-10-07 03:20:17] [ERROR] OU creation failed: OU=HR,OU=Users,OU=PRODUCTION,DC=dobre,DC=local - Directory object not found
[2026-10-07 03:20:17] [ERROR] OU creation failed: OU=IT,OU=Users,OU=PRODUCTION,DC=dobre,DC=local - Directory object not found
[2026-10-07 03:20:17] [ERROR] OU creation failed: OU=Computers,OU=PRODUCTION,DC=dobre,DC=local - Directory object not found
[2026-10-07 03:20:17] [ERROR] OU creation failed: OU=Servers,OU=PRODUCTION,DC=dobre,DC=local - Directory object not found
[2026-10-07 03:20:17] [ERROR] OU creation failed: OU=Groups,OU=PRODUCTION,DC=dobre,DC=local - Directory object not found
[2026-10-07 03:20:17] [ERROR] OU creation failed: OU=BACKUP,DC=dobre,DC=local - Directory object not found
[2026-10-07 03:20:17] [ERROR] OU creation failed: OU=Computers,OU=BACKUP,DC=dobre,DC=local - Directory object not found
[2026-10-07 03:20:17] [ERROR] OU creation failed: OU=Servers,OU=BACKUP,DC=dobre,DC=local - Directory object not found
[2026-10-07 03:20:17] [ERROR] OU creation failed: OU=Groups,OU=BACKUP,DC=dobre,DC=local - Directory object not found
[2026-10-07 03:20:17] [ERROR] OU creation failed: OU=REMOTE-ADMIN,DC=dobre,DC=local - Directory object not found
[2026-10-07 03:20:17] [ERROR] OU creation failed: OU=Users,OU=REMOTE-ADMIN,DC=dobre,DC=local - Directory object not found
[2026-10-07 03:20:17] [ERROR] OU creation failed: OU=Groups,OU=REMOTE-ADMIN,DC=dobre,DC=local - Directory object not found
[2026-10-07 03:20:17] [ERROR] OU creation failed: OU=SERVICE-ACCOUNTS,DC=dobre,DC=local - Directory object not found
[2026-10-07 03:20:17] [INFO] Creating security groups...
[2026-10-07 03:20:17] [ERROR] Group creation failed: GG-SVC-Admin - Directory object not found
[2026-10-07 03:20:17] [ERROR] Group creation failed: GG-Infra-Admin - Directory object not found
[2026-10-07 03:20:17] [ERROR] Group creation failed: GG-Ops-Admin - Directory object not found
[2026-10-07 03:20:17] [ERROR] Group creation failed: GG-Helpdesk - Directory object not found
[2026-10-07 03:20:17] [ERROR] Group creation failed: GG-Remote-Admin - Directory object not found
[2026-10-07 03:20:17] [ERROR] Group creation failed: GG-Remote-Users - Directory object not found
[2026-10-07 03:20:17] [ERROR] Group creation failed: GG-Prod-Server-Admins - Directory object not found
[2026-10-07 03:20:17] [ERROR] Group creation failed: GG-Backup-Server-Admins - Directory object not found
[2026-10-07 03:20:17] [ERROR] Group creation failed: GG-Backup-Operators - Directory object not found
[2026-10-07 03:20:17] [ERROR] Group creation failed: GG-IT-Users - Directory object not found
[2026-10-07 03:20:17] [ERROR] Group creation failed: GG-IT-Managers - Directory object not found
[2026-10-07 03:20:17] [ERROR] Group creation failed: DL-IT-Share - Directory object not found
[2026-10-07 03:20:17] [ERROR] Group creation failed: GG-FIN-Users - Directory object not found
[2026-10-07 03:20:17] [ERROR] Group creation failed: GG-FIN-Managers - Directory object not found
[2026-10-07 03:20:17] [ERROR] Group creation failed: DL-FIN-Share - Directory object not found
[2026-10-07 03:20:17] [ERROR] Group creation failed: GG-HR-Users - Directory object not found
[2026-10-07 03:20:17] [ERROR] Group creation failed: GG-HR-Managers - Directory object not found
[2026-10-07 03:20:17] [ERROR] Group creation failed: DL-HR-Share - Directory object not found
[2026-10-07 03:20:17] [INFO] Configuring group nesting...
[2026-10-07 03:20:17] [ERROR] Nesting failed: GG-Infra-Admin -> GG-Prod-Server-Admins - Cannot find an object with identity: 'GG-Prod-Server-Admins' under: 'DC=dobre,DC=local'.
[2026-10-07 03:20:17] [ERROR] Nesting failed: GG-Infra-Admin -> GG-Backup-Server-Admins - Cannot find an object with identity: 'GG-Backup-Server-Admins' under: 'DC=dobre,DC=local'.
[2026-10-07 03:20:17] [ERROR] Nesting failed: GG-Ops-Admin -> GG-Backup-Operators - Cannot find an object with identity: 'GG-Backup-Operators' under: 'DC=dobre,DC=local'.
[2026-10-07 03:20:18] [ERROR] Nesting failed: GG-Ops-Admin -> GG-Helpdesk - Cannot find an object with identity: 'GG-Helpdesk' under: 'DC=dobre,DC=local'.
[2026-10-07 03:20:18] [ERROR] Nesting failed: GG-FIN-Users -> DL-FIN-Share - Cannot find an object with identity: 'DL-FIN-Share' under: 'DC=dobre,DC=local'.
[2026-10-07 03:20:18] [ERROR] Nesting failed: GG-FIN-Managers -> DL-FIN-Share - Cannot find an object with identity: 'DL-FIN-Share' under: 'DC=dobre,DC=local'.
[2026-10-07 03:20:18] [ERROR] Nesting failed: GG-HR-Users -> DL-HR-Share - Cannot find an object with identity: 'DL-HR-Share' under: 'DC=dobre,DC=local'.
[2026-10-07 03:20:18] [ERROR] Nesting failed: GG-HR-Managers -> DL-HR-Share - Cannot find an object with identity: 'DL-HR-Share' under: 'DC=dobre,DC=local'.
[2026-10-07 03:20:18] [ERROR] Nesting failed: GG-IT-Users -> DL-IT-Share - Cannot find an object with identity: 'DL-IT-Share' under: 'DC=dobre,DC=local'.
[2026-10-07 03:20:18] [ERROR] Nesting failed: GG-IT-Managers -> DL-IT-Share - Cannot find an object with identity: 'DL-IT-Share' under: 'DC=dobre,DC=local'.
[2026-10-07 03:20:18] [INFO] Creating service accounts...
[2026-10-07 03:20:18] [ERROR] Service account failed: svc_admin - Directory object not found
[2026-10-07 03:20:18] [ERROR] Service account failed: svc_backup - Directory object not found
[2026-10-07 03:20:18] [ERROR] Service account failed: svc_monitoring - Directory object not found
[2026-10-07 03:20:18] [INFO] Importing users from users.csv...
[2026-10-07 03:20:18] [ERROR] User processing failed: jdoe - Directory object not found
[2026-10-07 03:20:18] [ERROR] User processing failed: asmith - Directory object not found
[2026-10-07 03:20:18] [ERROR] User processing failed: rkofi - Directory object not found
[2026-10-07 03:20:18] [ERROR] User processing failed: mngugi - Directory object not found
[2026-10-07 03:20:18] [ERROR] User processing failed: pade - Directory object not found
[2026-10-07 03:20:18] [ERROR] User processing failed: lmensah - Directory object not found
[2026-10-07 03:20:18] [ERROR] User processing failed: gmbarga - Directory object not found
[2026-10-07 03:20:18] [ERROR] User processing failed: remote1 - Directory object not found
[2026-10-07 03:20:18] [ERROR] User processing failed: endongo - Directory object not found
[2026-10-07 03:20:18] [ERROR] User processing failed: fabega - Directory object not found
[2026-10-07 03:20:18] [ERROR] User processing failed: sbiloa - Directory object not found
[2026-10-07 03:20:18] [ERROR] User processing failed: ambella - Directory object not found
[2026-10-07 03:20:18] [ERROR] User processing failed: betoa - Directory object not found
[2026-10-07 03:20:18] [ERROR] User processing failed: cfon - Directory object not found
[2026-10-07 03:20:18] [ERROR] User processing failed: essomba - Directory object not found
[2026-10-07 03:20:18] [ERROR] User processing failed: bewane - Directory object not found
[2026-10-07 03:20:18] [ERROR] User processing failed: cmvondo - Directory object not found
[2026-10-07 03:20:18] [ERROR] User processing failed: vetame - Directory object not found
[2026-10-07 03:20:18] [ERROR] User processing failed: nelomo - Directory object not found
[2026-10-07 03:20:18] [ERROR] User processing failed: amanga - Directory object not found
[2026-10-07 03:20:18] [OK] ============================================
[2026-10-07 03:20:18] [OK] DEPLOYMENT FINISHED
[2026-10-07 03:20:18] [OK] Domain: dobre.local
[2026-10-07 03:20:18] [OK] OUs created: 0
[2026-10-07 03:20:18] [OK] Groups created: 0
[2026-10-07 03:20:18] [OK] Service accounts created: 0
[2026-10-07 03:20:18] [OK] Users created: 0
[2026-10-07 03:20:18] [OK] Existing users skipped: 0
[2026-10-07 03:20:18] [WARN] Errors encountered: 72
[2026-10-07 03:20:18] [OK] Log file: C:\AD-Deploy\deploy.log
[2026-10-07 03:20:18] [OK] ============================================
