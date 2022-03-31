import sys
from os import path
import json
import yaml

file = sys.argv[1]
full_name = path.splitext(path.basename(file))

if full_name[1] in '.json':
    print('Это json')
elif full_name[1] in ('.yml', '.yaml'):
    print('Это yaml')
else:
    print('Incorrect file format')
    exit(0)

