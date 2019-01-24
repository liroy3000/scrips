"""
Скрипт для удаления устаревших снапштов на Proxmox

Я настроил автоматическое создание снапшотов для критически важхных виртуальных машин.
Снапшоты создаются каждый день с маской имени snpYEAR_mm_dd.
Сценарий находит все снапшоты, выделяет те, имена которых соответствуют заданной маске, удаляет снапшоты старше двух дней.
Снапшот не является резервной копией виртуальной машины, поэтому хранить его более двух дней не имеет смысла. Он предназначен
для простого отката в случае сбоя.
"""

import subprocess
import re
import datetime

vms = [100, 101, 103, 105, 120, 151, 153, 154, 155, 158, 161, 163, 166, 171, 185, 220, 1112]	#id отслеживаемых виртуальных машин

now = datetime.datetime.now()

def get_snapshots (vmid):
	"""
	Функция получает имена снапшотов для указанного id виртуальной машины.
	Возвращает список с именами.
	"""
	template = r'snp\d{4}_\d{2}_\d{2}'
	snapshots = subprocess.Popen('qm listsnapshot ' + str(vmid), shell = True, stdout = subprocess.PIPE)
	snapshots = str(snapshots.communicate()[0])
	snapshots = re.findall(template, snapshots)
	snapshots = list(set(snapshots))
	return snapshots

for vmid in vms:
	snapshots = get_snapshots(vmid)

	for snapshot in snapshots:
		snapshot_date = datetime.datetime.strptime(snapshot, 'snp%Y_%m_%d')
		delta = now - snapshot_date
		if delta.days > 2:
			subprocess.call(['qm', 'delsnapshot', str(vmid), snapshot])
