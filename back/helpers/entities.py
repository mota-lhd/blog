import os
from typing import Iterator, List

from google.auth import default, impersonated_credentials
from google.auth.impersonated_credentials import Credentials
from google.cloud.datastore import Client as StorageClient
from google.cloud.datastore import Entity, Key, Query

post_titles: List[str] = [
    "dhaulagiri-2019-01",
    "dhaulagiri-2019-02",
    "dhaulagiri-2019-03",
    "dhaulagiri-2019-04",
    "dhaulagiri-2019-05",
    "echappee-belle-2020-01",
    "pokhara-2020-01",
    "rollwaling-2019-01",
    "rollwaling-2019-02",
    "tech-blog-01",
]
source_credentials, project_id = default()
project_id: str = os.environ["PROJECT_ID"]
main_sa: str = os.environ["MAIN_SA"]
creds: Credentials = impersonated_credentials.Credentials(
    source_credentials=source_credentials,
    target_principal=(f"{main_sa}@{project_id}.iam.gserviceaccount.com"),
    target_scopes=["https://www.googleapis.com/auth/cloud-platform"],
)
storage: StorageClient = StorageClient(project=project_id, credentials=creds)
query: Query = storage.query(kind="Article")
results: Iterator = query.fetch()
already_in: List[str] = [r["title"] for r in list(results)]

for post in post_titles:
    if post not in already_in:
        key: Key = storage.key("Article")
        entity: Entity = Entity(key=key)

        entity["title"] = post
        storage.put(entity)
        print(f"+ added {post} with id={entity.id} ...")
