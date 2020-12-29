#!/usr/bin/env python3

from requests import get
from json import loads, dumps
from sys import argv

try:
	site_name = argv[1]
except IndexError:
	print('Error: Not set site name!')
	exit()
try:
    mobile = argv[2]
except IndexError:
    mobile = False

data_file = "pagerspeed.json"

with open(data_file, "r") as file:
	data = loads(file.read())

if site_name in list(data.keys()):
    if mobile == "mobile":
        print(data[site_name]["mobile"])
    else:
        print(data[site_name]["desktop"])
else:
    data[site_name] = {"date": 0, "desktop": 0, "mobile": 0}
    with open(data_file, "w") as file:
    	data_json = dumps(data)
    	file.write(data_json)
    print(0)
