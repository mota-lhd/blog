from __future__ import annotations

from datetime import datetime
from enum import Enum, unique
from typing import List, Optional

from requests import post

from fastapi import Depends, FastAPI, APIRouter, HTTPException
from fastapi.middleware.cors import CORSMiddleware

from google.cloud.datastore import Client as StorageClient
from google.cloud.datastore import Key, Entity, Query

from pydantic import BaseModel, constr, Field, EmailStr

from settings import settings


# Enumerations


@unique
class Entities(Enum):
    ARTICLE: str = "Article"
    COMMENT: str = "Comment"


# HTTP exceptions


class NotFoundException(HTTPException):
    def __init__(self, detail: str, **kwargs):
        super().__init__(404, detail, **kwargs)


class UnauthorizedException(HTTPException):
    def __init__(self, detail: str, **kwargs):
        super().__init__(403, detail, **kwargs)


# Pydantic models


class Comment(BaseModel):
    who: Optional[EmailStr]
    content: constr(max_length=500, regex="[\d\w\s]+")
    ts: datetime = datetime.now()


class CommentIn(Comment):
    captcha: str


class Article(BaseModel):
    id: int
    title: str


# Global variables


origins: list = [
    # PROD
    "https://elmouatassim.louhaidia.info",
]
router: APIRouter = APIRouter()


# FastAPI dependencies


async def get_db():
    storage: StorageClient = StorageClient(settings.PROJECT_ID)

    try:
        yield storage
    finally:
        storage.close()


# Helper methods


def check_captcha(token: str) -> bool:
    payload: dict = {
        "secret": settings.CAPTCHA_SERVER_KEY,
        "response": token,
    }

    res = post(settings.CAPTCHA_API_URL, data=payload)
    res = res.json()

    if not res["success"]:
        if len(res["error-codes"]) > 0:
            raise_g_captcha_error(res["error-codes"][0])
    return res["success"]


def raise_g_captcha_error(error_code: str):
    msg: str = f"{error_code}: "

    if error_code == "missing-input-secret":
        msg = msg + "Missing server-side secret !!"
    elif error_code == "invalid-input-secret":
        msg = msg + "Server side secret is not formed correctly !!"
    elif error_code == "missing-input-response":
        msg = msg + "Missing captcha !!"
    elif error_code == "invalid-input-response":
        msg = msg + "Captcha is not formed correctly !!"
    elif error_code == "bad-request":
        msg = msg + "The request is not formed correctly ..."
    elif error_code == "timeout-or-duplicate":
        msg = msg + "Request timed out !"
    else:
        msg = msg + "Internal error!"

    raise UnauthorizedException(msg)


# HTTP methods


@router.get("/articles", response_model=List[Article])
async def get_articles(storage: StorageClient = Depends(get_db)):
    query = storage.query(kind=Entities.ARTICLE.value)
    results = list(query.fetch())
    for result in results:
        result["id"] = result.key.id

    return results


@router.get("/article/{article_id}/comments", response_model=List[Comment])
async def get_article_comments(
    article_id: int, storage: StorageClient = Depends(get_db)
):
    ancestor: Key = storage.key(Entities.ARTICLE.value, article_id)
    query: Query = storage.query(kind=Entities.COMMENT.value, ancestor=ancestor)

    query.order = ["-ts"]
    query.add_filter("visible", "=", True)

    return list(query.fetch())


@router.post(
    "/article/{article_id}/comments/add",
)
async def add_comment_to_article(
    article_id: int,
    comment: CommentIn,
    storage: StorageClient = Depends(get_db),
):
    if check_captcha(comment.captcha):
        with storage.transaction():
            article: Article = storage.get(
                storage.key(Entities.ARTICLE.value, article_id)
            )

            if article:
                comment_ent: Entity = Entity(
                    storage.key(
                        Entities.ARTICLE.value,
                        article_id,
                        Entities.COMMENT.value,
                    )
                )

                comment_ent.update(
                    {
                        "who": comment.who,
                        "content": comment.content,
                        "ts": comment.ts,
                        "visible": False
                    }
                )

                storage.put_multi(
                    [
                        comment_ent,
                    ]
                )
                return "OK"
            else:
                raise NotFoundException(
                    "The article you are looking for does not exist."
                )
    else:
        raise UnauthorizedException("You're not human ;)")


# FastAPI program


def get_app() -> FastAPI:
    _app: FastAPI = FastAPI(
        title=settings.SERVICE_NAME,
        debug=settings.DEBUG,
        dependencies=[],
    )
    _app.include_router(router, prefix=settings.API_V1_STR)
    _app.add_middleware(
        CORSMiddleware,
        allow_origins=origins,
        allow_credentials=True,
        allow_methods=["GET", "POST"],
        expose_headers=[],
        allow_headers=[],
    )

    return _app


app: FastAPI = get_app()
