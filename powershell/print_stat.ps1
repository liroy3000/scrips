# Скрипт для сбора количества напечатанных на принтере страниц
# 
# Сбор данных осуществляется по протоколу SNMP. Данные собирались с принтеров HP, по их oid. Сверьте oid, если будете собирать метрики с других принтеров.
# В принтере должен быть включен доступ по SMTP.
# Данные выгружаются в подготовленный html документ. Необходимо подготовить документ перед первым запуском скрипта, в дальнейшем это не требуется.
# Внестите стандартную "шапку" html в документе(тэги html, head и пр.). Внесите первую строку таблицы:
# <tr><th>DATE</th><th>PRINTNAME1</th><th>PRINTNAME2</th></tr>   Последовательность PRINTNAME-ов должна соответсвовать последовательности адресов в массиве $printers.
# Внесите необходимые стили css по вашему усмотрению.


$snmp_client = 'C:\snmpget\SnmpGet.exe'        # Путь до SNMP клиента в вашей системе.
$global:oid="1.3.6.1.2.1.43.10.2.1.4.1.1"	   # OID, соответсвующий количеству отпечатков на принтере.
$out_file = 'C:\temp\index.html'               # Путь до файла для записи результатов.
printters = @('192.168.0.11', '192.168.0.11')  # Укажите адреса принтеров в массиве.

[string]$date=Get-Date
$date=$date.Remove(11)

function get_count_page ($print) {
	
	# Функция принимает ip-адрес принтера и возврашает количество отпечатков.
	# В случае, если принтер не доступен - возвращает 0.

	if (Test-NetConnection -ComputerName $print -InformationLevel Quiet) {
		[string]$result=$snmp_client -r:$print -v:1 -c:"public" -o:$oid | Select-String "value="
		[int]$counter=$result.Replace("Value=", "")
	}
	else {
		$counter="0"
	}
	return $counter
}


# Дозаписываем в файл новые строки.

"<tr><td>$date</td>" >> $out_file

foreeach ($printer in $printers) {
	"<td>get_count_page($printer)<td>" >> $out_file
}

"</tr>" >> $out_file