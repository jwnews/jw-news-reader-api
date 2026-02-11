from __future__ import annotations

from fastapi import FastAPI, HTTPException
import httpx
import logging

from .extract import ExtractionError, extract_article
from .models import ExtractRequest, ExtractResponse

LOGGER = logging.getLogger(__name__)
app = FastAPI(title="jw-news-reader-api", version="1.0.0")


@app.get("/health")
async def health() -> dict:
    return {"status": "ok"}


@app.post("/extract", response_model=ExtractResponse)
async def extract_endpoint(request: ExtractRequest) -> ExtractResponse:
    try:
        result = await extract_article(str(request.url))
    except ExtractionError as exc:
        detail = str(exc) or "Invalid request"
        status_code = 400
        if "HTML" in detail:
            status_code = 422
        raise HTTPException(status_code=status_code, detail=detail) from exc
    except httpx.HTTPStatusError as exc:
        raise HTTPException(status_code=502, detail="Upstream returned an error") from exc
    except httpx.RequestError as exc:
        detail = f"Upstream request failed: {exc.__class__.__name__}: {exc}"
        raise HTTPException(status_code=502, detail=detail) from exc
    except Exception as exc:  # pragma: no cover - safeguard
        LOGGER.exception("Extraction failed: %s", exc)
        detail = f"Extraction failed: {exc.__class__.__name__}: {exc}"
        raise HTTPException(status_code=500, detail=detail) from exc

    return ExtractResponse(**result)
