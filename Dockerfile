FROM python:3.11-slim

# Evite des logs chelous + accélère un peu
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

# Dépendances système utiles (Pillow etc.)
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
  && rm -rf /var/lib/apt/lists/*

# Installer deps
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copier le code
COPY . .

# Dossiers runtime
RUN mkdir -p outputs data models

EXPOSE 8501

# Healthcheck simple: Streamlit répond
HEALTHCHECK --interval=30s --timeout=5s --start-period=20s --retries=3 \
  CMD curl -fsS http://localhost:8501/_stcore/health || exit 1

CMD ["streamlit", "run", "app/streamlit_labeler.py", "--server.address=0.0.0.0", "--server.port=8501"]