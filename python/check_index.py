#!/usr/bin/env python3

import requests
import json
import re
import datetime
from sys import argv

try:
	site_name = argv[1]
except IndexError:
	print('Error: Not set site name!')
	exit()

responce = requests.get("http://127.0.0.1:9200/_aliases")
if responce.status_code == 200:
    indeces = json.loads(responce.text)
    indeces = list(indeces.keys())
else:
    print("Error connect to Elasctic!")
    exit()

now = datetime.datetime.now()
now = now.strftime("%Y.%m.%d")
pattern_name = "monitoring\." + site_name + "\S*-" + now

result = 0
for index in indeces:
	if re.match(pattern_name, index):
		if index != 'monitoring.' + site_name + '-error-log-' + now:
			result = 1
			break

print(result)
