#Dockerfile created following this blog post: https://medium.com/@albertazzir/blazing-fast-python-docker-builds-with-poetry-a78a66f5aed0
#PYTHON image
# Use the official Docker Python image because it has the absolute latest bugfix version of Python
# it has the absolute latest system packages
# it’s based on Debian Bookworm (Debian 12), released June 2023
# Image size is 51MB

#I did not recommed to use alpine image because it lacks the package installer pip and the support for installing
#wheel packages, which are both needed for installing applications like Pandas and Numpy.
FROM python:3.11-slim-bookworm as builder

RUN pip install poetry==1.5.1

ENV POETRY_NO_INTERACTION=1 \
    #POETRY_VIRTUALENVS_IN_PROJECT=1 \
    #POETRY_VIRTUALENVS_CREATE=1 \
    POETRY_CACHE_DIR=/tmp/poetry_cache

WORKDIR /app

COPY pyproject.toml poetry.lock ./

# Avoid installing development dependencies with poetry install --without dev , as you won’t need linters and tests suites in your production environment.
#To avoid poetry re-install the dependencies use the --no-root option, which instructs Poetry to avoid installing the current project into the virtual environment.
RUN --mount=type=cache,target=$POETRY_CACHE_DIR poetry install --without dev --no-root

FROM python:3.11-slim-bookworm as runtime

#ENV VIRTUAL_ENV=/app/.venv \
#    PATH="/app/.venv/bin:$PATH"

#COPY --from=builder ${VIRTUAL_ENV} ${VIRTUAL_ENV}

COPY . .

CMD ["python3"]