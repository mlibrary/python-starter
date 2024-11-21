# python-starter

Starter repository for python projects

## Installation

1. Run the `.init.sh` script. This will set up your `.env` file, build the
   docker image, and install the python packages.

   ```bash
   ./init.sh
   ```

2. Edit `pyproject.toml` to have the proper name and author(s) of your project.

3. Rename the `python_starter` directory to the name of your project.

## How to use the starter

``docker compose exec app python --version``

To run python scripts with poetry installed packages run something like:

``docker compose exec app poetry run python your_script.py``

## Tests

``docker compose exec app poetry run pytest``

## Background

This repository goes with this documentation:
<https://mlit.atlassian.net/wiki/spaces/LD/pages/10092544004/Python+in+LIT>
