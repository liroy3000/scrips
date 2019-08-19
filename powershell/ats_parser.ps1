# Скрипт парсинга отчетов с АТС и формирования индивидуальных отчетов.
# Автор: Кульков К.А. (kulkovka@rncb.ru).
#
# Проверено на PowerShell 5.1.
# Рядом со скриптов должен находиться каталог report, в котором скрипт ищет файлы репорты с атс.
# В папке report не должно быть файлов, отличных по стуктуре от эталонных, иначе в результате парсинга 
# получатся бессмысленные значения или возникнет ошибка.
# Рядом со скриптом должен лежать файл numbers.txt в котором в столбик перечислены все искомые номера.

function pars_value ($line, $start, $stop) {
    # Парсим строки отчета.
    # Каждый столбец в целевом файле имеет заданную длину символов.
    # Переменные $start и $stop определяют символы, с которой начинается столбец и его длину соответсвенно.
    $value = $line.Substring($start, $stop)
    $value = $value.TrimStart(' ')
    return $value
}

function test_path($filename) {
    # Проверяет, существует ли выходной файл
    if (!(Test-Path "out\$filename")) {
        New-Item "out\$filename" -ItemType "file"
        echo 'DATE;TIME;DURATION;TYPE;TRUNK2;NUMBER_IN;NUMBER_OUT;HZ1;HZ2;HZ3;HZ4;HZ5' | Out-File "out\$filename" -Encoding utf8
    }
}

cd $PSScriptRoot

# Проверки существует ли файл numbers и не пустой ли он.
if (!(Test-Path "numbers.txt")) {
    echo "Файл numbers.txt не существует!"
    exit
}
$numbers = Get-Content "numbers.txt"
if ($numbers.Count -eq 0) {
    echo "В файле numbers.txt отстутствуют записи!"
    exit
}

# Проверка, существует ли папка report и не пуста ли она.
if (!(Test-Path report)) {
    echo "Парка report не существует!"
    exit
}
if ((ls report).Count -eq 0) {
    echo "В папке report нет файлов!"
    exit
}

$files = Get-ChildItem .\report
if (!(Test-Path out)) {                                                             # Создадим папку для выходных файлов
        New-Item out -ItemType "directory"
        }

foreach ($file in $files) {                                                         # Перебираем последовательно каждый файл

    foreach ($line in [System.IO.File]::ReadLines("$PSScriptRoot\report\$file")) {  # Перебираем каждый файл построчно
        if ($line.Length -lt 35) {                                                  # пропускаем короткие строки, в которых нет полезных данных
            continue
            } 
        $number_in = pars_value $line 29 24
        $number_out = pars_value $line 53 16
        # Усли номера не из искомого списка, то пропускаем
        if ((!($numbers -contains $number_in)) -and (!($numbers -contains $number_out))) {
            continue
        }
        $call_date = pars_value $line 0 6
        $call_time = pars_value $line 6 5
        $call_duration = pars_value $line 11 6
        $call_type = pars_value $line 17 2
        $trank2 = pars_value $line 19 10
        $val1 = pars_value $line 69 22
        $val2 = pars_value $line 91 4
        $val3 = pars_value $line 95 4
        $val4 = pars_value $line 99 5
        $val5 = pars_value $line 104 16
        $outline = "`"$call_date`";`"$call_time`";`"$call_duration`";`"$call_type`";`"$trank2`";`"$number_in`";`"$number_out`";`"$val1`";`"$val2`";`"$val3`";`"$val4`";`"$val5`""
       
        if ($number_out.Length -le 5) {      # если номер звонящевго 5-значный, значит это наш абонент
            if ($number_in.Length -le 5) {   # если номер вызываемого 5-значный, значит звонок внутри сети, делается запись в два файла
                if ($numbers -contains $number_in) {
                    test_path($number_in+"_IN_local.csv")
                    echo $outline | Out-File ("out\$number_in"+"_IN_local.csv") -Append -Encoding utf8
                }
                if ($numbers -contains $number_out) {
                    test_path($number_out+"_OUT_local.csv")
                    echo $outline | Out-File ("out\$number_out"+"_OUT_local.csv") -Append -Encoding utf8
                }
            }
            else {                           # если вызываемый номер более 5 знаков, занчит звонок в город, запись в один файл
                test_path($number_out+'_OUT_city.csv')
                echo $outline | Out-File ("out\$number_out"+'_OUT_city.csv') -Append -Encoding utf8
            }
        }
    }
}