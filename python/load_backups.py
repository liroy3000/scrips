#!/usr/bin/env python3
"""
Скрипт для выгрузки резервных копий Mikriotik
Автор: Кульков К.А.
"""
import re
from ftplib import FTP
import os
from sys import argv

backup_dir = '/home/backup_conf/'
backup_name1 = argv[1]
backup_name2 = argv[2]
group_name = argv[3]
invent_file = open('/etc/ansible/inventory')
ftp_login = 'фтп_логин'
ftp_passw = 'фтп_пароль'

def get_addresses():
	"""
	Функция парсит файл Inventory, находит группу, заданну в переменной group_name
	и возвращает список адресов устройств
	"""
	template_group = r'\[.*\]'								# Шаблон поиска группы
	array = []

	i = -1
	for line in invent_file:								# перебираем файл построчно

		line = line.strip()
		result = re.match(template_group ,line)				# Проверяем, совпадает ли строка с шаблоном
		
		if result == None:									# Если совпадений нет, то строка является адресом
			if line == '':									# или пустой строкой (исключаем пустые строки)
				continue
			else:
				try:
					array[i]['devices'].append(line)
				except:
					continue
		else:
			new_group = result.group(0)						# Если соответсвет шаблону, то приводим к нужному виду и добавляем к результирующему массиву
			new_group = new_group.replace('[', '').replace(']', '')
			array.append({'group': new_group, 'devices': []})
			i = i + 1
	
	# Мы получили список с коллекциями всех найденных групп. Выберем нужную группу и вернем список с аресами
	result = False
	for group in array:
		if group['group'] == group_name:
			result = group['devices']
	if result:
		return result
	else:
		print('Error: Group ' + group_name + ' not faund!')
		exit()

def get_file(address, file_name):
	"""
	Функция загружает файлы бэкапа с устройства
	Принимает в качестве параметров адрес и имя файла
	"""
	if os.path.exists(backup_dir + address) != True:
		os.mkdir(backup_dir + address)

	ftp = FTP(address)
	ftp.login(user=ftp_login,passwd=ftp_passw)
	with open(backup_dir + address + '/' + file_name, 'wb') as f:
		ftp.retrbinary('RETR ' + file_name, f.write)

devices = get_addresses()
invent_file.close()

for address in devices:
	get_file(address, backup_name1)
	get_file(address, backup_name2)