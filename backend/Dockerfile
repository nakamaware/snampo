FROM python:3.13

# Install uv
COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv

WORKDIR /code

# Copy project files
COPY ./pyproject.toml /code/pyproject.toml
COPY ./app /code/app

# Install dependencies using uv
RUN uv pip install --system .

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "80"]
