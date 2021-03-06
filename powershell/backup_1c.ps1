# Скрипт резервного копирования баз данных 1С под управлением СУБД MsSQL Express

# Необходимо внести значения всех переменных в соттветсвие с настройками сервера. 

$back_path = "F:\backup\"                           # Путь до директории с бэкапами
$base_path = "F:\sql"                               # Путь не должен заканчсиаться знаком "\"!
$login_sql = "sa"                                   # Логин SQL
$pwd_sql = "mymassword"                             # Пароль SQL
$example_sql = "localhost\sqlexpress"               # Экземпляр SQL
$login_1c = "admin"                                 # Логин 1С
$pwd_1c = "1cpassword"                              # Пароль 1С
$server = "server_name"                             # Имя сервера
$1c_path = "C:\Program Files (x86)\1cv8\common\"    # Путь до каталога с файлом 1cestart.exe

# Названия информационных баз вносим в массив:

$servers = @(bdname1, bdname2)

[string]$date_now = Get-Date -Format yyyyMMdd
[string]$date_time_now = Get-Date -Format yyyyMMddHHmm

function backup($base) {

    # Проверка существования директории для бэкапа
    
    [string]$path = $back_path + $base + '\' + $date_now
    if (Test-Path($path)) {
        echo "test successfull"
    }
    else {
        mkdir $path
    }
    
    # Создание sql-бэкап

    $filebackup = $path + '\' + $base + $date_time_now + '.bak'
    sqlcmd -S $example_sql -U $login_sql -P $pwd_sql -Q "backup database $base to disk=`"$filebackup`""
    
    # Заливаем созданный бэкап в служебную бд
    
    sqlcmd -S $example_sql -U $login_sql -P $pwd_sql -Q "use master; alter database [backup] set single_user with rollback immediate; restore database [backup] from disk=`'$filebackup`' with move `'$base`' to `'$base_path\backup.mdf`', move `'$base`_log`' to `'$base_path\backup_log.ldf`', replace; alter database [backup] set multi_user"
    
    # Выгружаем dt-файл
    
    Set-Location $1c_path
    $filedt = $path + '\' + $base + $date_time_now + '.dt'
    $filelog = $path + '\' + $base + $date_time_now + '.log'
    .\1cestart.exe DESIGNER /S$server\backup /N$login_1c /P$pwd_1c /DumpIB `"$filedt`" /Out `"$filelog`"
    Wait-Event -Timeout 450    # Пауза, чтобы успел слиться dt

}

# Выполняем функцию backup для каждой бд, занесенной в в массив $servers

foreaceh ($bdname in $servers) {
    backup($bdname)
}