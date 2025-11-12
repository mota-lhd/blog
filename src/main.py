from typing import Any

import httpx
import nh3
from fastapi import Depends
from fastapi import FastAPI
from fastapi import HTTPException
from fastapi.middleware.cors import CORSMiddleware
from sqlmodel import Session
from sqlmodel import SQLModel
from sqlmodel import create_engine
from sqlmodel import select

from models import Comment
from models import CommentCreate
from models import CommentResponse
from settings import settings


# global


def get_app() -> FastAPI:
  _app: FastAPI = FastAPI(
    title=settings.service_name,
    debug=settings.debug,
    dependencies=[],
  )

  _app.add_middleware(
    CORSMiddleware,
    allow_credentials=True,
    allow_methods=["GET", "POST"],
    allow_origins=["*"],
    expose_headers=[],
    allow_headers=[],
  )

  return _app


engine = create_engine(
  settings.database_url, connect_args={"check_same_thread": False}
)
SQLModel.metadata.create_all(engine)

app: FastAPI = get_app()

# dependencies


def get_session() -> Any:
  with Session(engine) as session:
    yield session


# helper methods


def sanitize_text(text: str) -> str:
  if not text:
    return ""
  return nh3.clean(text)


def sanitize_comment(comment: Comment) -> None:
  comment.author = sanitize_text(comment.author)
  comment.content = sanitize_text(comment.content)

  for reply in comment.replies:
    sanitize_comment(reply)


def sanitize_comments(comments: list[Comment]) -> None:
  for c in comments:
    sanitize_comment(c)


async def check_captcha(token: str) -> bool:
  payload: dict = {
    "secret": settings.turnstile_secret,
    "response": token,
  }
  async with httpx.AsyncClient() as client:
    res: httpx.Response = await client.post(
      settings.turnstile_api_url, data=payload
    )

    return res.json().get("success", False)


# methods


@app.post("/comments", response_model=CommentResponse)
async def create_comment(
  comment: CommentCreate,
  session: Session = Depends(get_session),  # noqa: B008
):
  if not await check_captcha(comment.turnstile_token):
    raise HTTPException(status_code=400, detail="Turnstile verification failed")

  db_comment: Comment = Comment.model_validate(comment)

  session.add(db_comment)
  session.commit()
  session.refresh(db_comment)
  sanitize_comment(db_comment)
  return comment


@app.get("/comments-to-approve", response_model=list[CommentResponse])
def get_non_approved_comments(
  session: Session = Depends(get_session),  # noqa: B008
):
  statement = select(Comment).where(
    Comment.approved == False,  # noqa: E712
    Comment.parent_id == None,  # noqa: E711
  )
  comments: list[Comment] = session.exec(statement).all()

  sanitize_comments(comments)
  return comments


@app.get("/comments", response_model=list[CommentResponse])
def get_post_comments(
  site_id: str,
  post_slug: str,
  session: Session = Depends(get_session),  # noqa: B008
):
  statement = select(Comment).where(
    Comment.site_id == site_id,
    Comment.post_slug == post_slug,
    Comment.approved == True,  # noqa: E712
    Comment.parent_id == None,  # noqa: E711
  )
  comments: list[Comment] = session.exec(statement).all()

  sanitize_comments(comments)
  return comments
