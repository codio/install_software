#!/usr/bin/env python3

from ansible.module_utils.basic import *
import commentjson as json
from collections import OrderedDict

run_file = '/home/codio/workspace/.codio'

def read_codio_json():
    try:
        with open(run_file, 'r') as file:
            return json.load(file, object_pairs_hook=OrderedDict)
    except IOError:
        return OrderedDict()

def update_codio():
    codio_json = read_codio_json()
    preview_section = codio_json.get('preview', OrderedDict())
    if 'Virtual Desktop' in preview_section:
        preview_section['Virtual Desktop'] = 'https://{{domain3000}}/'
    else:
        preview_section = OrderedDict([('Virtual Desktop', 'https://{{domain3000}}/')] + preview_section.items())
    codio_json['preview'] = preview_section
    
    with open(run_file, 'w+') as file:
        json.dump(codio_json, file, indent=4, separators=(',', ': '))
    
    return codio_json

def main():
    module = AnsibleModule(argument_spec={})
    codio_json = update_codio()
    module.exit_json(changed=False, meta=codio_json)


if __name__ == '__main__':  
    main()