#PYTHON image
# Use the official Docker Python image because it has the absolute latest bugfix version of Python
# it has the absolute latest system packages
# it’s based on Debian Bookworm (Debian 12), released June 2023
# Image size is 51MB

#I did not recommed to use alpine image because it lacks the package installer pip and the support for installing
#wheel packages, which are both needed for installing applications like Pandas and Numpy.
FROM python:3.11-slim-bookworm as python-base

# Use this page as a reference for python and poetry environment variables: https://docs.python.org/3/using/cmdline.html#envvar-PYTHONUNBUFFERED

#Ensure the stdout and stderr streams are sent straight to terminal, then you can see the output of your application
ENV PYTHONUNBUFFERED=1\
    # Avoid the generation of .pyc files during package install
    # Disable pip's cache, then reduce the size of the image
    PIP_NO_CACHE_DIR=off \
    # Save runtime because it is not look for updating pip version
    PIP_DISABLE_PIP_VERSION_CHECK=on \
    PIP_DEFAULT_TIMEOUT=100

USER root

WORKDIR /app

ENV PYTHONPATH "${PYTHONPATH}:/app"

RUN set -ex \
    # Create a non-root user
    && addgroup --system --gid 1001 appgroup \
    && adduser --system --uid 1001 --gid 1001 --no-create-home appuser

# Upgrade the package index and install security upgrades
RUN --mount=type=cache,target=/var/lib/apt/lists \
    --mount=type=cache,target=/var/cache,sharing=locked \
    apt-get update \
    && apt-get upgrade --assume-yes \
    && apt-get install --assume-yes --no-install-recommends python3-pip

# Install dependencies
FROM python-base as poetry

WORKDIR /app
# that contains poetry=<version> to install a specific version of Poetry.
COPY requirements.txt ./
RUN --mount=type=cache,target=/root/.cache python3.11 -m pip install --disable-pip-version-check --requirement=requirements.txt

# Do the conversion
COPY poetry.lock pyproject.toml ./
RUN poetry export --output=requirements.txt

FROM python-base as development

RUN --mount=type=cache,target=/root/.cache --mount=type=bind,from=poetry,source=/app,target=/poetry python3.11 -m pip install --disable-pip-version-check --no-deps --requirement=/poetry/requirements.txt

WORKDIR /app

COPY . .

CMD ["python3"]

USER appuser
