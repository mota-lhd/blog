from typing import List, Iterator
from google.cloud.datastore import (Client as StorageClient, Entity, Query, Key)

from google.auth import impersonated_credentials, default
from google.auth.impersonated_credentials import Credentials


post_titles: List[str] = [
    u'dhaulagiri-2019-01',
    u'dhaulagiri-2019-02',
    u'dhaulagiri-2019-03',
    u'dhaulagiri-2019-04',
    u'dhaulagiri-2019-05',
    u'echappee-belle-2020-01',
    u'pokhara-2020-01',
    u'rollwaling-2019-01',
    u'rollwaling-2019-02',
    u'tech-blog-01'
]
source_credentials, project_id = default()
project_id: str = "personal-blog-364911"
creds: Credentials = impersonated_credentials.Credentials(
    source_credentials=source_credentials,
    target_principal=(f"main-service-account@{project_id}.iam.gserviceaccount.com"),
    target_scopes=["https://www.googleapis.com/auth/cloud-platform"],
)
storage: StorageClient = StorageClient(
    project=project_id,
    credentials=creds
)
query: Query = storage.query(kind="Article")
results: Iterator = query.fetch()
already_in: List[str] = [r['title'] for r in list(results)]

for post in post_titles:
    if post not in already_in:
        key: Key = storage.key('Article')
        entity: Entity = Entity(key=key)

        entity["title"] = post
        storage.put(entity)
        print(f"+ added {post} with id={entity.id} ...")
