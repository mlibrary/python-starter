# PYTHON image
# Use the official Docker Python image because it has the absolute latest bugfix version of Python
# it has the absolute latest system packages
# it’s based on Debian Bookworm (Debian 12), released June 2023
# Initial Image size is 51MB
# At the end Image size is 156MB

# I did not recommed using an alpine image because it lacks the package installer pip and the support for installing
# wheel packages, which are both needed for installing applications like Pandas and Numpy.

# The base layer contains the instruction for creating the app user, setting the
# working directory, setting an "always on" command.
FROM python:3.11-slim-bookworm as base

# Allowing the argumenets to be read into the dockerfile. Ex:  .env > compose.yml > Dockerfile
ARG POETRY_VERSION
ARG UID=1000
ARG GID=1000


# Create the user and usergroup
RUN groupadd -g ${GID} -o app
RUN useradd -m -d /app -u ${UID} -g ${GID} -o -s /bin/bash app


# Set the working directory to /app
WORKDIR /app

CMD ["tail", "-f", "/dev/null"]

# Both build and development need poetry, so it is its own step.
FROM base as poetry

RUN pip install poetry==${POETRY_VERSION}

# Use this page as a reference for python and poetry environment variables:
# https://docs.python.org/3/using/cmdline.html#envvar-PYTHONUNBUFFERED Ensure
# the stdout and stderr streams are sent straight to terminal, then you can see
# the output of your application
ENV PYTHONUNBUFFERED=1\
    # Avoid the generation of .pyc files during package install
    # Disable pip's cache, then reduce the size of the image
    PIP_NO_CACHE_DIR=off \
    # Save runtime because it is not look for updating pip version
    PIP_DISABLE_PIP_VERSION_CHECK=on \
    PIP_DEFAULT_TIMEOUT=100 \
    # Disable poetry interaction
    POETRY_NO_INTERACTION=1 \
    POETRY_VIRTUALENVS_CREATE=1 \
    POETRY_VIRTUALENVS_IN_PROJECT=1 \
    POETRY_CACHE_DIR=/tmp/poetry_cache

# We want poetry on in development
FROM poetry as development

# Switch to the non-root user "user"
USER app

# Below are production steps
FROM poetry as build

# Only copy the files needed to install the dependencies. Poetry requires
# README.md to exist in order to work
COPY pyproject.toml poetry.lock README.md ./

# Install the depdencies with Poetry.
#
# --no-root is used so that poetry will install only the dependencies not the project itself
#
# --without dev to avoid installing dev dependencies
#
# Poetry cache is used to avoid installing the dependencies every time the code
# changes. We delete this folder after installing.
RUN  poetry install --no-root --without dev && rm -rf ${POETRY_CACHE_DIR};

# We do not need poetry in production. We will copy dependencies from the build
# step. 
FROM base as production
RUN mkdir -p /venv && chown ${UID}:${GID} /venv

# By adding /venv/bin to the PATH, the dependencies in the virtual environment
# are used
ENV VIRTUAL_ENV=/venv \
    PATH="/venv/bin:$PATH"

COPY --chown=${UID}:${GID} . /app
COPY --chown=${UID}:${GID} --from=build "/app/.venv" ${VIRTUAL_ENV}

# Switch to the app user
USER app