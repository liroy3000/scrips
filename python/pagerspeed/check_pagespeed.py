#!/usr/bin/env python3

from requests import get
from json import loads, dumps
from datetime import datetime
from time import sleep

data_file = "pagepeed.json"

def get_pagerspeed (url):
	responce = get(url)
	if responce.status_code == 200:
		page_speed_data = loads(responce.text)
		return page_speed_data['lighthouseResult']['categories']['performance']['score']
	else:
	    return "Error connect to Googleapis!"

with open(data_file, "r") as file:
	data = loads(file.read())
	file.close()

for site_name in list(data.keys()):
	curdate = datetime.timestamp(datetime.now())
	desktop = get_pagerspeed("https://www.googleapis.com/pagespeedonline/v5/runPagespeed?url=https://" + site_name)
	sleep(101)
	mobile = get_pagerspeed("https://www.googleapis.com/pagespeedonline/v5/runPagespeed?strategy=mobile&url=https://" + site_name)
	sleep(101)
	with open(data_file, "r") as file:
		data = loads(file.read())
		file.close()
	with open(data_file, "w") as file:
		data[site_name] = {"date": curdate, "desktop": desktop, "mobile": mobile}
		data_json = dumps(data)
		file.write(data_json)
		file.close()
