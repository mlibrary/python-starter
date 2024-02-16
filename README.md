# python-docker-boilerplate

Boilerplate code for starting a python project with docker and docker-compose

## How to set up your python environment

### Install python

On mac,

* You can read this blog to install python in a right way in
      python: https://opensource.com/article/19/5/python-3-default-mac
      
* **Recommendation**: Install python using brew and pyenv

### Managing python dependencies

* **Install poetry**

* On Mac OS, Windows and Linux,
  * Install poetry:
       * ``curl -sSL https://install.python-poetry.org | python3 -``
         * This way allows poetry and its dependencies to be isolated from your dependencies. I don't recommend to use 
         * pip to install poetry because poetry and your application dependencies will be installed in the same environment.
       * ```poetry init```: 
         * Use this command to set up your local environment, repository details, and dependencies. 
         * It will generate a pyproject.toml file with the information you provide.
           * Package name [python-starter]:
           * Version [0.1.0]:
           * Description []:
           * Author []:  n 
           * License []:
           * Compatible Python versions [^3.11]: 
           * Would you like to define your main dependencies interactively? (yes/no) [yes]: no
           * Would you like to define your development dependencies interactively? (yes/no) no
       * ```poetry install```: 
         * Use this command to automatically install the dependencies specified in the pyproject.toml file.
         * It will generate a poetry.lock file with the dependencies and their versions.
         * It will create a virtual environment in the home directory, e.g. /Users/user_name/Library/Caches/pypoetry/..
       * ```poetry env use python```: 
         * Use this command to find the virtual environment directory, created by poetry.
       * ```source ~/Library/Caches/pypoetry/virtualenvs/python-starter-0xoBsgdA-py3.11/bin/activate```
         * Use this command to activate the virtual environment.
       * ```poetry shell```: 
         * Use this command to activate the virtual environment.
       * ```poetry add pytest```: 
         * Use this command to add dependencies.
       * `` poetry update ``: 
         * Use this command if you change your .toml file and want to generate a new version the .lock file

## Set up in a docker environment

```
./init.sh
```

This will:

* copy the project folder
* build the docker image
* install the dependencies
* create a container with the application

## How to run the application

``docker compose exec app python --version``


## Tests

## Background
This repository goes with this documentation:
https://mlit.atlassian.net/wiki/spaces/LD/pages/10092544004/Python+in+LIT

## What is a monorepo?

A monorepo is a single repository that contains all the code for all the projects and libraries in an organization. This is in contrast to a polyrepo, where each project and library has its own repository.

## What are the advantages of a use monorepo for all of our python applications?

* Easier to share code between projects
* Easier to refactor code
* Easier to make changes across multiple projects
* Easier to maintain a consistent code style
* Easier to maintain a consistent set of dependencies
* Easier to maintain a consistent set of tools
* Easier to maintain a consistent set of CI/CD pipelines
* Easier to maintain a consistent set of documentation
* Easier to maintain a consistent set of security policies

## Mono-repo design:

* Each project code will be included in an independent folder. For eliminating import cycles, projects cannot import any code from other projects. 
* Code intended to be shared needs to be put in an internal library
* Each project also has its own CI/CD pipeline, Dockerfile, and Kubernetes deployment configuration

**About PRs**
* When a PR is created in a service, it runs that service’s tests. 
* When the PR is merged, it builds that service’s Docker image and deploys it to our Kubernetes cluster. 
* If a PR spans multiple services, then each included service’s CI/CD pipelines will run.
  * For example, if a PR is made in a service and a library, then the tests for both the service and the library will run in CI. You can’t merge the PR until all the tests pass.
* If a PR is made in a library, then the tests for all services and other libraries that use it will run in CI. You can’t merge library changes until all the tests pass.

**About dependencies**
* Poetry is a tool we used for dependency management and packaging. Tools, such as formatter and linting, that are common for all the projects in the same repo are defined
in a pyproject.py file defined in the root of the repository. 
* We will use Editable installs to install internal dependencies (functionalities inside shared_libs folder)

**Configuration of the package**:
    * The code of all the projects and libraries will inside the src folder, this way poetry will automatically recognize the code and the tests

## Steps to create a new project:

1- Create a folder with the name of the project
2- Create the virtual environment of this project - poetry
     `poetry init`

3- Organize the project structure 

top level folders:

* projects
  * project_1
    * tests
      * /sub-folders with test
    * pyproject.toml 
    * poetry.lock 
    * README.md
    * src/
      * sub-folders with the code
    * main.py
  * .
  * .
  * project_n
    
* shared_libs
    * my_conn
      * src
        * my_conn.py
      * __init__.py
      * pyproject.py
      * README.md
    * my_logger
      * 
* pyproject.py - defining the dependencies and the tools for all the projects (formatter, linting, etc)

* 4- Formating and linting
  * For formatting source code, we chose **Black**
  * psdocstyle

5- Install the dependencies
* `poetry add <dependency>`

* Use this command for editable installs (all the packages included shared_libs folder)
  * command line: `poetry add ../../shared_libs/my_conn` 

* For editable install we could also add `{ include = "my_conn", from = "../../shared_libs/my_conn" }` in the list packages in the pyproject.toml file

* For installing libraries we will use editable installs
    * Good explanation of the advantages and the design of editable installs
      here [https://medium.com/opendoor-labs/our-python-monorepo-d34028f2b6fa]

## References:

Our Python Monorepo: https://medium.com/opendoor-labs/our-python-monorepo-d34028f2b6fa

PYTHON MONOREPO: AN EXAMPLE. PART 1: STRUCTURE AND TOOLING: 
https://www.tweag.io/blog/2023-04-04-python-monorepo-1/
PYTHON MONOREPO: AN EXAMPLE. PART 2: A SIMPLE CI https://www.tweag.io/blog/2023-07-13-python-monorepo-2/

Packaging namespace packages: https://packaging.python.org/en/latest/guides/packaging-namespace-packages/
src layout: https://setuptools.pypa.io/en/latest/userguide/package_discovery.html#src-layout

We use src folder to include the code base of each project or library. This way, poetry automaticaly is able to find and install the dependencies
