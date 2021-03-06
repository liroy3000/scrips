# Скрипт для миграции пользователей и компьютеров в новый домен Windows
#
# Предполагается что заранее подготовлены файлы users.csv и comps.csv со списками пользователей и компьютеров
# А так же файлы с опициям миграции. Подробнее смортите документацию к утилите ADMT.
# Согласно опциям, мигрированные пользователи появятся в контейнерах "OU=TMP,DC=netdom,DC=net", а компьютеры в "OU=TMPCOMP,DC=netdom,DC=net"
# После миграции скрипт перенесет пользователей и компьютеры в заданные в переменных ($locate_users, $locate_comps) контейнеры, а так же добавит пользователей в заданную группу ($group)

Import-Module ActiveDirectory

$locate_users = 'ou=ИТ_отдел,ou=EXPO,ou=ORGS,dc=netdom,dc=net'
$locate_comps = 'ou=ИТ_отдел,ou=EXPO,ou=WORKSTATION,dc=netdom,dc=net'
$group = 'admins'

##################################################################################

cd 'C:\Windows\ADMT'
ADMT USER /O: "C:\migrate\options_users.txt" /F: "C:\migrate\users.csv"
ADMT COMPUTER /O: "C:\migrate\options_comps.txt" /F: "C:\migrate\comps.csv"
ADMT SECURITY /O: "C:\migrate\options_profiles.txt" /F: "C:\migrate\comps.csv"
ADMT USER /O: "C:\migrate\options_users_finish.txt" /F: "C:\migrate\users.csv"

Wait-Event -Timeout 10

$users = Get-ADUser -Filter * -SearchBase "OU=TMP,DC=netdom,DC=net"
foreach ($user in $users) {
    Set-ADUser -Identity $user -ChangePasswordAtLogon $False
    Add-ADGroupMember -Identity $group -Members $user
    Move-ADObject $user -TargetPath $locate_users
}

$computers = Get-ADComputer -Filter * -SearchBase "OU=TMPCOMP,DC=netdom,DC=net"

 foreach ($comp in $computers) {
	$name = [string]$comp.Name
    $old_name = Invoke-Command -ComputerName $name -ScriptBlock { Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI' }
	$old_name = $old_name.LastLoggedOnSamUser
    $new_name = [string]$old_name.Replace("KZPEXPO", "NETDOM")
	Invoke-Command -ComputerName $name -ScriptBlock { param($new_name) Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI' -Name LastLoggedOnUser -Value $new_name} -Arg $new_name

    Move-ADObject -Identity $comp -TargetPath $locate_comps
}
