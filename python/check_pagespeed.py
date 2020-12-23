#!/usr/bin/env python3
"""
Monitoring pagespeed.
Run:
python3 check_pagespeed.py example.org
or
python3 check_pagespeed.py example.org mobile
"""

from requests import get
from json import loads
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

if mobile == 'mobile':
    url = "https://www.googleapis.com/pagespeedonline/v5/runPagespeed?strategy=mobile&url=https://" + site_name
else:
    url = "https://www.googleapis.com/pagespeedonline/v5/runPagespeed?url=https://" + site_name

responce = get(url)
if responce.status_code == 200:
    page_speed_data = loads(responce.text)
else:
    print("Error connect to Googleapis!")
    exit()

# print lighthouseResult.categories.performance.score
print(page_speed_data['lighthouseResult']['categories']['performance']['score'])
