import re
from sys import argv

file = argv[1]
pattern = "^.*-(.*)GET"

data = open(file, "r")
datas = data.readlines()
data.close()
for line in datas:
    result = re.findall(pattern, line)
    try:
        res = float(result[0])
        if res > 1:
            print(line)
    except:
        continue
