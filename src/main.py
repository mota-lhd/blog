from datetime import datetime

from fastapi import APIRouter
from fastapi import Depends
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from pydantic import BaseModel
from pydantic import EmailStr

from pydantic import Field

from supabase import create_client
from supabase import Client
from supabase.client import ClientOptions

from httpx import post
from settings import settings

# Pydantic models


class Comment(BaseModel):
    who: str = EmailStr
    content: str = Field(max_length=500)
    ts: datetime = datetime.now()


class CommentIn(Comment):
    captcha: str


class Article(BaseModel):
    id: int
    title: str


# Global variables


router: APIRouter = APIRouter()


# FastAPI dependencies


async def get_db():
    url: str = settings.SUPABASE_URL
    key: str = settings.SUPABASE_KEY
    supabase: Client = create_client(
        url,
        key,
        options=ClientOptions(
            postgrest_client_timeout=10,
            storage_client_timeout=10,
            schema="comments",
        ),
    )

    return supabase


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


def raise_g_captcha_error(error_code: str) -> None:
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

    raise Exception(msg)


# HTTP methods


@router.get("/articles", response_model=list[Article])
async def get_articles(storage: Client = Depends(get_db)):
    response = storage.table("blog_posts").select("*").execute()

    return [Article.model_validate(obj) for obj in response.data]


@router.post(
    "/article/{article_id}/comments/add",
)
async def add_comment_to_article(
    article_id: int,
    comment: CommentIn,
    storage: Client = Depends(get_db),
):
    if check_captcha(comment.captcha):
        response = (
            storage.table("blog_posts").select("*").eq("id", article_id).execute()
        )

        if response.count > 0:
            return "OK"
        else:
            raise Exception("The article you are looking for does not exist.")
    else:
        raise Exception("You're not human ;)")


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
        allow_credentials=True,
        allow_methods=["GET", "POST"],
        expose_headers=[],
        allow_headers=[],
    )

    return _app


app: FastAPI = get_app()
