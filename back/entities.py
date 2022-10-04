import os

project_id: str = os.getenv("DEVSHELL_PROJECT_ID")

if not project_id:
    print("Please set DEVSHELL_PROJECT_ID environment variable and retry ...")
    exit(1)

from google.cloud.datastore import Client as StorageClient
from google.cloud.datastore import Entity


blog_entries = [
    {
        'title': u'dhaulagiri-2019-01',
    },
    {
        'title': u'dhaulagiri-2019-02',
    },
    {
        'title': u'dhaulagiri-2019-03',
    },
    {
        'title': u'dhaulagiri-2019-04',
    },
    {
        'title': u'dhaulagiri-2019-05',
    },
    {
        'title': u'echappee-belle-2020-01',
    },
    {
        'title': u'pokhara-2020-01',
    },
    {
        'title': u'rollwaling-2019-01',
    },
    {
        'title': u'rollwaling-2019-02',
    },
]

storage: StorageClient = StorageClient(project_id)

for e_info in blog_entries:
    key = storage.key('Article')
    a_entity = Entity(key=key)
    for e_prop, e_val in e_info.items():
        a_entity[e_prop] = e_val
    storage.put(a_entity)
