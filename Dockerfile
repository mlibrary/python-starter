#PYTHON image
# Use the official Docker Python image because it has the absolute latest bugfix version of Python
# it has the absolute latest system packages
# it’s based on Debian Bookworm (Debian 12), released June 2023
# Initial Image size is 51MB
# At the end Image size is 156MB

#I did not recommed to use alpine image because it lacks the package installer pip and the support for installing
#wheel packages, which are both needed for installing applications like Pandas and Numpy.

# The base layer will contain the dependencies shared by the other layers
FROM python:3.11-slim-bookworm as base

# Create a system group named "user" with the -r flag
RUN groupadd -r app_user \
    # Create a system user named "user" with the -r flag
    && useradd -r -g app_user app_user

# Set the working directory to /app
WORKDIR /app

# Change the ownership of the working directory to the non-root user "user"
RUN chown -R app_user:app_user /app

# Switch to the non-root user "user"
USER app_user

#Use this argument to install development or production dependencies
#true = development / false = production
ARG DEV=true
#ENV VIRTUAL_ENV=/app/.venv \
#    PATH="/app/.venv/bin:$PATH"

# Install Poetry
ARG POETRY_VERSION=1.5.1

# The builder layer is used to install all the dependencies, then if the code change we do not need to reinstall the dependencies
FROM base as builder

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

WORKDIR /app

# Install Poetry. Fix poetry version to avoid breaking changes
RUN pip install poetry==1.5.1

# Install the app. Just copy the files needed to install the dependencies
COPY pyproject.toml poetry.lock ./

#Poetry cache is used to avoid installing the dependencies every time the code changes, we will keep this folder in development environment and remove it in production
# --no-root, poetry will install only the dependencies avoiding to install the project itself, we will install the project in the final layer
# --without dev to avoid installing dev dependencies, we do not need test and linters in production environment
# --with dev to install dev dependencies, we need test and linters in development environment
# --mount, mount a folder for plugins with poetry cache, this will speed up the process of building the image
RUN  if [ $DEV ]; then \
    echo "Installing dev dependencies"; \
      --mount=type=cache,target=$POETRY_CACHE_DIR  poetry install --with dev --no-root; \
    else \
    echo "Skipping dev dependencies"; \
      --mount=type=cache,target=$POETRY_CACHE_DIR  poetry install --without dev --no-root && rm -rf $POETRY_CACHE_DIR; \
   fi

#setup our final runtime layer
FROM base as runtime

#COPY --from=builder ${VIRTUAL_ENV} ${VIRTUAL_ENV}

COPY . .

WORKDIR /app

CMD ["python3"]