#!/usr/bin/env python3
import random
from sys import argv

program_help = """
Скрипт генерации пароля указанной длины.
Вы можете сгенерировать пароль любой длины, но не менее 4 символов! По умолчанию, длина пароля - 8 символов. Укажите желаемую дину пароля в качестве ключа, например:
leeroy@kr-adm:~/Documents/$ ./generator_psw.py 10
По умолчанию, пароль генерируется из строчных латинских букв, заглавных букв, цыфр и спец. символов. Вы можете изменить сложность пароля, указав второй параметр:
1 - только строчные символы
2 - строчные и заглавные
3 - строчные, заглавные и цыфры
4 - строчные, заглавные, цыфры и спец.символы
Пример:
leeroy@kr-adm:~/Documents/$ ./generator_psw.py 10 3
При этом сформируется пароль из 10 символов из строчных и заглавных латинских символов, а так же цыфр.
При запуске скрипта без параметров,сформируется пароль из 8 символов, обладающий сложностью 4.
"""

try:
	cont_char = argv[1]
except IndexError:
	cont_char = 8
try:
	cont_arr = argv[2]
except IndexError:
	cont_arr = 4

if cont_char == 'help':
	print (program_help)
	exit ()
try:
	cont_char = int (cont_char)
except ValueError:
	print ('Вы ввели не число')
	print ('Используйте ключь help для получения справки')
	cont_char = 8
if cont_char < 4:
	print ('Я не создаю пароль, короче 4 символов!')
	print ('Используйте ключь help для получения справки')
	cont_char = 4
try:
	cont_arr = int (cont_arr)
except ValueError:
	print ('Вы ввели не число')
	print ('Используйте ключь help для получения справки')
	cont_arr = 4
if cont_arr < 1 or cont_arr > 4:
	print ('Введен не верный параметр')
	print ('Используйте ключь help для получения справки')
	cont_arr = 4

def passw_generator(cont_char):
	arr1= ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z']
	arr2 = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z']
	arr3 = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9']
	arr4 = ['!', '$', '&', '?', '%', '=', '+', '*', '#']
	passw = []

	cont_char2 = int (cont_char / cont_arr)
	cont_char3 = int (cont_char / cont_arr)
	cont_char4 = int (cont_char / cont_arr)
	cont_char1 = int (cont_char / cont_arr + cont_char % cont_arr)
	
	if cont_arr == 4:
		for i in range (cont_char1):
			passw.append (random.choice (arr1))
		for i in range (cont_char2):
			passw.append (random.choice (arr2))
		for i in range (cont_char3):
			passw.append (random.choice (arr3))
		for i in range (cont_char4):
			passw.append (random.choice (arr4))
	elif cont_arr == 3:
		for i in range (cont_char1):
			passw.append (random.choice (arr1))
		for i in range (cont_char2):
			passw.append (random.choice (arr2))
		for i in range (cont_char3):
			passw.append (random.choice (arr3))
	elif cont_arr == 2:
		for i in range (cont_char1):
			passw.append (random.choice (arr1))
		for i in range (cont_char2):
			passw.append (random.choice (arr2))
	else:
		for i in range (cont_char1):
			passw.append (random.choice (arr1))	
	
	random.shuffle (passw)
	return ''.join (passw)

print (passw_generator (cont_char))