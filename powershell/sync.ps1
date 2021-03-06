#
# Скрипт для перемещения файлов EDSmart из локального каталога в сетевой, или наоборот.
# Требуется PowerShell 5.1
# Авотр: Кульков К.А. (liroy3000@gmail.com).

# Сетевые и локальные каталоги:
$in_lan = 'I:\sforms\RKC\edsmart\in'
$in_local = 'C:\KBR\in'
$out_lan = 'I:\sforms\RKC\edsmart\out'
$out_local = 'C:\KBR\out'

# Файлы перемещаются из $origin_path в $target_path. Присвойте переменным необходимые значения
$origin_path = $in_lan
$target_path = $in_local


function test_access {
    # Функция, которая проверяет доступность сетевых дисков.
    try {
        ls $origin_path  -ErrorAction Stop
        ls $target_path  -ErrorAction Stop
        return $true
    }
    catch {
        return $false
    }
}

# Перед тем как запустить непосредственно бесконечный цикл основного функционала,
# проверим подключение и выведем в консоль сообщения, о том что скрипт ожидает подключение сетевого диска.
echo "Проверяем подключение сетевого диска"
echo "..."
for ($true) {
    if (test_access) {
        echo "Сетевой диск подключен"
        break
    }
    else {
    sleep 5
    }
}

for ($true) {
   
    if (test_access) {
        # Если доступ к сетевых папкам есть, то переносим файлы и выводим сообщение в консоль.

        $files = ls $origin_path
        foreach ($file in $files) {
            $time = Get-Date -Format T
            Move-Item $origin_path\$file $target_path\
            echo "$time : $file перемещен в папку $target_path"
        }
    }
    else {
        # Если доступа к сетевым дискам нет, то выводим уведомление в консоль и ожидаем, пока доступ восстановится.
        
        Write-Warning "Нет доступа к сетевому диску"
        
        for ($true) {
            sleep 5
            if (test_access) {
                echo "Доступ восстановлен"
                break
            }
        }
    }
sleep 5
}