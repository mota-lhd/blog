from typing import Any

import httpx
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

  return db_comment


@app.get(
  "/comments-to-approve", response_model=list[CommentResponse]
)
def get_non_approved_comments(
  session: Session = Depends(get_session),  # noqa: B008
):
  statement = select(Comment).where(
    Comment.approved == False,  # noqa: E712
    Comment.parent_id.is_(None)
  )

  return session.exec(statement).all()


@app.get(
  "/comments", response_model=list[CommentResponse]
)
def get_post_comments(
  site_id: str,
  post_slug: str,
  session: Session = Depends(get_session),  # noqa: B008
):
  # Debug: Check all comments in DB
  all_comments = session.exec(select(Comment)).all()
  print(f"Total comments in DB: {len(all_comments)}")
  for c in all_comments:
    print(f"  - ID: {c.id}, site_id: {c.site_id}, post_slug: {c.post_slug}, approved: {c.approved}, parent_id: {c.parent_id}")

  statement = select(Comment).where(
    Comment.site_id == site_id,
    Comment.post_slug == post_slug,
    Comment.approved == True,  # noqa: E712
    Comment.parent_id.is_(None)
  )

  return session.exec(statement).all()
