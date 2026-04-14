# Dockerfile for SIS GloSIS API (API key-protected federation endpoint)
# Build context: project root (to share sis-api/shared.py)

# --- Build stage: install Python dependencies ---
FROM python:3.12-slim AS builder

WORKDIR /build

COPY sis-api-glosis/requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt


# --- Runtime stage: clean image with patched OS packages ---
FROM python:3.12-slim

# Apply all available OS security patches
RUN apt-get update && apt-get upgrade -y && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy installed Python packages from build stage (no gcc/build tools in runtime)
COPY --from=builder /install /usr/local

# shared.py lives in sis-api/ and is used by both APIs
COPY sis-api/shared.py .
COPY sis-api-glosis/main.py .

RUN useradd -m -u 1000 appuser && chown -R appuser:appuser /app
USER appuser

EXPOSE 8000

HEALTHCHECK --interval=10s --timeout=5s --start-period=10s --retries=5 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/health')"

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
