from __future__ import annotations

from typing import List, Optional

from pydantic import AnyHttpUrl, BaseModel


class ExtractRequest(BaseModel):
    url: AnyHttpUrl


class ImageInfo(BaseModel):
    url: str
    alt: Optional[str] = None
    caption: Optional[str] = None


class ExtractResponse(BaseModel):
    markdown: str
    title: Optional[str]
    source_url: str
    images: List[ImageInfo]
