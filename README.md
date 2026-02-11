# jw-news-reader-api

FastAPI service that extracts JW.org article text and in-flow images into markdown, preserving image placement and captions when available. The API returns the markdown plus a structured image list for downstream processing.

**What It Does**

- Fetches a JW.org article URL over HTTPS.
- Extracts the main article content with a JW.org-focused heuristic and a readability fallback.
- Normalizes image URLs to absolute URLs and keeps images in their original positions in markdown.
- Removes common UI artifacts (e.g., audio player controls) and publication metadata blocks.
- Returns both markdown and structured image metadata.

**API Endpoints**

- `GET /health` -> `{ "status": "ok" }`
- `POST /extract` -> `{ "markdown": "...", "title": "...", "source_url": "...", "images": [ ... ] }`

**Request Body**

```json
{
  "url": "https://www.jw.org/en/..."
}
```

**Response Body**

```json
{
  "markdown": "# Article Title\n\nBody...\n\n![alt](https://...)\n\n*Caption*",
  "title": "Article Title",
  "source_url": "https://www.jw.org/en/...",
  "images": [
    {
      "url": "https://...",
      "alt": "Alt text",
      "caption": "Caption text"
    }
  ]
}
```

**Run Locally**

```sh
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

**Docker**

```sh
docker build -t jw-news-reader-api .
docker run --rm -p 8000:8000 jw-news-reader-api
```

**Docker Compose**

```sh
docker compose up --build
```

**Curl Examples**

```sh
curl http://localhost:8000/health
```

```sh
curl -X POST http://localhost:8000/extract \
  -H "Content-Type: application/json" \
  -d '{"url":"https://www.jw.org/en/"}'
```

Replace the URL with a JW.org article page.

**Public (Ingress + API Key)**

```sh
curl -X POST https://api.massaini.xyz/jw-news-reader-api/extract \
  -H "Content-Type: application/json" \
  -H "apikey: YOUR_API_KEY" \
  -d '{"url":"https://www.jw.org/en/"}'
```

**Configuration**

- `JW_NEWS_READER_INSECURE_SSL=1` disables TLS verification (not recommended for production).

**Kubernetes**

```sh
kubectl apply -f /Users/brunomassaini/Git/JWNews/jw-news-reader/k8s/
/Users/brunomassaini/Git/JWNews/jw-news-reader/apply_auth_jw_news_reader_api.sh
```

**Notes and Limitations**

- Only `https://jw.org` and `https://*.jw.org` URLs are accepted.
- Extraction quality depends on the page structure; UI or metadata blocks may change over time and require filter updates.
- The API is stateless and does not store content.
