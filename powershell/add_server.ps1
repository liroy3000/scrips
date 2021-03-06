# Добавление новой базы 1С в файлы кнфигураций.
#
# При условии, что пользовательские файлы .v8i с их списками информационных баз 1С хранятся в одной папке,
# с помощью этого скрипта можно добавить новую БД сразу всем пользователям


$path_configs = 'C:\temp\add_1cbase\baselist\'                           # Путь к каталогу с файлами .v8i
$template = 'Connect=Srvr="server_name";Ref="basename";'                 # Подключение к новой базе
$base_name = '[NEW BASE]'                                                # Название новой базы


cd $path_configs
$files = ls $path_configs *.v8i

function inconfig($file) {
    
    # Функция проверяет, нет ли указанной базы в списке информационных баз пользователя.

    $content = Get-Content $file
    $result = 0
    foreach ($line in $content) {
        if ($line -match $template) {
        $result = 1
        break
    }}
    return $result
}

foreach ($file in $files) {
    if (inconfig($file)  -eq 1) {
    continue
    }
    else {
    echo `n | Out-File $file -Append -encoding utf8
    echo $base_name | Out-File $file -Append -encoding utf8
    echo $template | Out-File $file -Append -encoding utf8
    }
}
