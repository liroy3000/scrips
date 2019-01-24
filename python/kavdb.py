import csv
import pyodbc

"""
После миграции на новый сервер Kaspesky Security Centre потерялись прявязки компьютеров к группам, а так же
потерялись комментарии с полезной информацией.
На новом сервере были вручную созданы группы с точно такой же иерархией и названиями как и на сатром.
Со старого сервера были выгружены данные о компьютерах (имя ПК, группа, комментарий) в формате CSV.

Скрипт считывает данные из csv файла, перебирает все компьютеры на новом сервере и дополняет новой информацией - принадлежность
к группе, комментарий. Скрипт рабтает напраямую с SQL базой данной касперского.
"""

file = open('yan.csv', encoding='UTF8')

def readcsv(csvfile):
	reader = csv.reader(csvfile, delimiter='	')
	arr = []
	for row in reader:
		arr.append(row)
	return arr

data = readcsv(file)

cnxn = pyodbc.connect('DRIVER={ODBC Driver 17 for SQL Server};SERVER=KAV\KAV_CS_ADMIN_KIT;DATABASES=KAV;UID=sa;PWD=220400')
cursor = cnxn.cursor()
insert = cnxn.cursor()

groups = {}
cursor.execute("select nId, wstrName from KAV.dbo.AdmGroups")
rows = cursor.fetchall()
for row in rows:
	groups[row.wstrName] = row.nId

cursor.execute("select strDisplayName, nId from KAV.dbo.Hosts")
rows = cursor.fetchall()
for row in rows:
	for comp in data:
		if row.strDisplayName.count(comp[0]):
			if comp[2] in groups:
				request = "update KAV.dbo.Hosts set nGroup=" + str(groups[comp[2]]) + " where nId=" + str(row.nId)
				insert.execute(request)
				cnxn.commit()
				request = "update KAV.dbo.Hosts set bChildUnassigned='0' where nId=" + str(row.nId)
				insert.execute(request)
				cnxn.commit()
				
			if comp[1] != '':
				comment = comp[1].encode('UTF8').decode('UTF8')
				#print (comment)
				request = 'update KAV.dbo.Hosts set wstrComment=N' + '\'' + comment + '\'' + " where nId=" + str(row.nId)
				#print(request)
				insert.execute(request)
				cnxn.commit()