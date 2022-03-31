import sys
from os import path
import json
import yaml


file = sys.argv[1]
full_name = path.splitext(path.basename(file))
print(full_name)
