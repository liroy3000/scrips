#!/usr/bin/env python3

import requests
import json
import re
import datetime

# Remove settings
police_indeces = [{"days": 3, "indeces": ['monitoring.xiacom', 'monitoring.24-ok', 'monitoring.semena-zakaz.ru']}]
police_default = 14


responce = requests.get("http://127.0.0.1:9200/_aliases")
if responce.status_code == 200:
    indeces = json.loads(responce.text)
    indeces = list(indeces.keys())
else:
    print("Error connect to Elasctic!")
    exit()

# Example index name: monitoring.sitename.ru-access-log-2020.04.13
pattern_name = "monitoring\.\S*-\d{4}\.\d{2}\.\d{2}"
pattern_date = "\d{4}\.\d{2}\.\d{2}$"
now = datetime.datetime.now()

for index in indeces:

    if re.match(pattern_name, index):
        ind_date = re.findall(pattern_date, index)[0]
        old_days = police_default

        for rule in police_indeces:
            for pattern in rule['indeces']:
                if re.match(pattern, index):
                    old_days = rule['days']
   
        ind_date = datetime.datetime.strptime(str(ind_date), '%Y.%m.%d')
        delta = now - ind_date
        if delta.days > old_days:
            print(index)
            # remove index
            requests.delete("http://127.0.0.1:9200/" + index)
