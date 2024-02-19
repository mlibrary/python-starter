#PYTHON image
# Use the official Docker Python image because it has the absolute latest bugfix version of Python
# it has the absolute latest system packages
# it’s based on Debian Bookworm (Debian 12), released June 2023
# Initial Image size is 51MB
# At the end Image size is 156MB

#I did not recommed to use alpine image because it lacks the package installer pip and the support for installing
#wheel packages, which are both needed for installing applications like Pandas and Numpy.

# Steps
# Base layer - Install Dependencies
# Runtime layer - Copy those dependencies, create user:groups, run application

# The base layer will contain the dependencies shared by the other layers
FROM python:3.11-slim-bookworm as base

# Allowing the argumenets to be read into the dockerfile. Ex:  .env > compose.yml > Dockerfile
ARG POETRY_VERSION
#true = development / false = production
ARG DEV

# Set the working directory to /app
WORKDIR /app

#RUN python -m venv .venv
#RUN source .venv/bin/activate

#ENV VIRTUAL_ENV=/app/.venv \
#    PATH="/app/.venv/bin:$PATH"



# The builder layer is used to install all the dependencies, then if the code change we do not need to reinstall the dependencies
#FROM base as builder
#COPY --from=base /app /app
#COPY --from=base usr/local/bin/python3.11 /usr/local/bin/python3.11

# Use this page as a reference for python and poetry environment variables: https://docs.python.org/3/using/cmdline.html#envvar-PYTHONUNBUFFERED

#Ensure the stdout and stderr streams are sent straight to terminal, then you can see the output of your application
ENV PYTHONUNBUFFERED=1\
    # Avoid the generation of .pyc files during package install
    # Disable pip's cache, then reduce the size of the image
    PIP_NO_CACHE_DIR=off \
    # Save runtime because it is not look for updating pip version
    PIP_DISABLE_PIP_VERSION_CHECK=on \
    PIP_DEFAULT_TIMEOUT=100 \
    # Disable poetry interaction
    POETRY_NO_INTERACTION=1 \
    POETRY_VIRTUALENVS_IN_PROJECT=1 \
    POETRY_VIRTUALENVS_CREATE=1 \
    POETRY_CACHE_DIR=/tmp/poetry_cache

# Set up our virtual environment and install dependencies in that folder
RUN python3 -m venv /app/venv
RUN . /app/venv/bin/activate && \
  python3 -m ensurepip --upgrade && \
  python3 -m pip install poetry==${POETRY_VERSION}

# Install general dependencies (formatter and linting tools)
COPY pyproject.toml poetry.lock README.md ./

#--mount=type=cache,target=$POETRY_CACHE_DIR
#Poetry cache is used to avoid installing the dependencies every time the code changes, we will keep this folder in development environment and remove it in production
# --no-root, poetry will install only the dependencies avoiding to install the project itself, we will install the project in the final layer
# --without dev to avoid installing dev dependencies, we do not need test and linters in production environment
# --with dev to install dev dependencies, we need test and linters in development environment
# --mount, mount a folder for plugins with poetry cache, this will speed up the process of building the image

RUN . /app/venv/bin/activate && poetry install

#RUN  if [ ${DEV} ]; then \
#    echo "Installing dev dependencies"; \
#      . /app/venv/bin/activate && --mount=type=cache,target=$POETRY_CACHE_DIR poetry install --with dev --no-root; \
#    else \
#  echo "Skipping dev dependencies"; \
#      . /app/venv/bin/activate && --mount=type=cache,target=$POETRY_CACHE_DIR poetry install --without dev --no-root && rm -rf $POETRY_CACHE_DIR; \
#   fi

#Install specific project dependencies
COPY shared_libs   /app/shared_libs

WORKDIR /app/projects/project_1
# Install the app. Just copy the files needed to install the dependencies
COPY /projects/project_1/pyproject.toml /projects/project_1/poetry.lock /projects/project_1/README.md ./

RUN . /app/venv/bin/activate && poetry install

#RUN poetry install --with dev --no-root
# Install project dependencies
#RUN if [ ${DEV} ]; then \
#    echo "Installing dev dependencies"; \
#      --mount=type=cache,target=$POETRY_CACHE_DIR  poetry install --with dev --no-root; \
#    else \
#   echo "Skipping dev dependencies"; \
#      --mount=type=cache,target=$POETRY_CACHE_DIR  poetry install --without dev --no-root && rm -rf $POETRY_CACHE_DIR; \
#   fi

#setup our final runtime layer
FROM base as runtime
COPY --from=base /app /app

# Create our users here in the last layer or else it will be lost in the previous discarded layers
# Create a system group named "user" with the -r flag

RUN groupadd -r project_1_user \
  # Create a system user named "user" with the -r flag
  && useradd -r -g project_1_user project_1_user

# Switch to the user that the container will run as
USER project_1_user

WORKDIR /app

COPY /projects/project_1 /app/projects/project_1

CMD . /app/venv/bin/activate && python3 /projects/project_1/main.py

CMD ["/bin/bash"]
