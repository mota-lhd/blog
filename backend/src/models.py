from datetime import UTC
from datetime import datetime
from typing import Optional

from pydantic import EmailStr
from sqlmodel import Field
from sqlmodel import Relationship
from sqlmodel import SQLModel


class CommentPublicBase(SQLModel):
  site_id: str = Field(index=True)
  post_slug: str = Field(index=True)
  author: str = Field(max_length=100)
  content: str = Field(max_length=5000)
  parent_id: int | None = Field(default=None, foreign_key="comment.id")


class CommentBase(CommentPublicBase):
  email: EmailStr


class Comment(CommentBase, table=True):
  id: int | None = Field(default=None, primary_key=True, index=True)
  approved: bool = Field(default=True)
  created_at: datetime = Field(default_factory=lambda: datetime.now(UTC))

  # Self-referential relationships
  parent: Optional["Comment"] = Relationship(  # noqa: UP045
    back_populates="replies",
    sa_relationship_kwargs={
      "remote_side": "Comment.id",
      "foreign_keys": "Comment.parent_id",
      "uselist": False,
    },
  )
  replies: list["Comment"] = Relationship(
    back_populates="parent",
    cascade_delete=True,
  )


class CommentCreate(CommentBase):
  turnstile_token: str


class CommentResponse(CommentPublicBase):
  id: int
  created_at: datetime
  replies: list["CommentResponse"] = []

  class Config:
    from_attributes = True
