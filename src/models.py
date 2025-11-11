from __future__ import annotations

from datetime import datetime
from typing import Optional

from pydantic import EmailStr
from sqlalchemy.orm import Mapped
from sqlmodel import Field
from sqlmodel import Relationship
from sqlmodel import SQLModel


class CommentBase(SQLModel):
  site_id: str = Field(index=True)
  post_slug: str = Field(index=True)
  author: str
  email: EmailStr
  content: str
  parent_id: int | None = Field(default=None, foreign_key="comment.id")


class Comment(CommentBase, table=True):
  id: int | None = Field(default=None, primary_key=True)
  approved: bool = Field(default=False)
  created_at: datetime = Field(default_factory=datetime.now)

  replies: Mapped[list["Comment"]] = Relationship(
    back_populates="parent",
    sa_relationship_kwargs={"remote_side": "Comment.id"},
  )
  parent: Mapped[Optional["Comment"]] = Relationship(
    back_populates="replies",
    sa_relationship_kwargs={"remote_side": "Comment.id"},
  )

  class Config:
    arbitrary_types_allowed = True


class CommentCreate(CommentBase):
  turnstile_token: str


class CommentResponse(CommentBase):
  id: int
  created_at: datetime
  replies: list[CommentResponse] = []

  class Config:
    from_attributes = True
