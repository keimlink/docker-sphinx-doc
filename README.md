# Docker Sphinx Image

[![Docker Stars](https://img.shields.io/docker/stars/keimlink/docker-sphinx-doc.svg)](https://hub.docker.com/r/keimlink/docker-sphinx-doc/)
[![Docker Pulls](https://img.shields.io/docker/pulls/keimlink/docker-sphinx-doc.svg)](https://hub.docker.com/r/keimlink/docker-sphinx-doc/)

A Docker image for [Sphinx](http://www.sphinx-doc.org/), a documentation tool written in Python.

## Supported tags and respective `Dockerfile` links

* `1.6.5`, `latest` ([Dockerfile](https://github.com/keimlink/docker-sphinx-doc/Dockerfile))
* `1.6.5-latex`, `latex` ([Dockerfile.latex](https://github.com/keimlink/docker-sphinx-doc/Dockerfile.latex))

## What is Sphinx?

[Sphinx](http://www.sphinx-doc.org/) is a tool that makes it easy to create intelligent and beautiful documentation. It has excellent facilities for the documentation of software projects in a range of languages. Output formats like HTML, LaTeX, ePub, Texinfo, manual pages and plain text are supported. More than 50 extensions contributed by users are available.

## How to use this image

### Use the image for your Sphinx project

First run `sphinx-quickstart` to set up a source directory and a configuration:

```console
$ docker run -it --rm -v "$(pwd)/docs":/app/docs keimlink/sphinx-doc sphinx-quickstart docs
```

Then build the HTML documentation:

```console
$ docker run -it --rm -v "$(pwd)/docs":/app/docs keimlink/sphinx-doc make -C docs html
```

### Create a `Dockerfile` for your Sphinx project

If you want to extend the image you can create a `Dockerfile` for your Sphinx project. In this example [sphinx-autobuild](https://github.com/GaretJax/sphinx-autobuild) will be used to rebuild the documentation when a change is detected.

Start with a requirements file called `requirements.pip`:

```
sphinx-autobuild==0.7.1
```

Then create the `Dockerfile`:

```dockerfile
FROM keimlink/sphinx-doc

COPY requirements.pip ./

RUN . .venv/bin/activate \
    && python -m pip install --requirement requirements.pip

EXPOSE 8000

CMD ["sphinx-autobuild", "--host", "0.0.0.0", "--port", "8000", "/app/docs", "/app/docs/_build/html"]
```

Now build the image and run the container:

```console
$ docker build -t sphinx-autobuild .
$ docker run -it -p 8000:8000 --rm -v "$(pwd)/docs":/app/docs sphinx-autobuild
```

The documentation should served at http://127.0.0.1:8000. It will be rebuild when a file is changed.

## Image Variants

The `sphinx-doc` images come in many flavours, each designed for a specific use case.

All images have the [enchant](https://github.com/AbiWord/enchant) package installed. It is required by [sphinxcontrib-spelling](https://github.com/sphinx-contrib/spelling) to spell check the documentation.

## `sphinx-doc:<version>`

This is the defacto image. If you are unsure about what your needs are, you probably want to use this one. It is designed to be used both as a throw away container (mount your source code and start the container to start your app), as well as the base to build other images off of. This tag is based off of [`python:alpine`](https://hub.docker.com/_/python/), which is based on the popular [Alpine Linux project](http://alpinelinux.org/), available in the [`alpine`](https://hub.docker.com/_/alpine) official image. Alpine Linux is much smaller than most distribution base images (~5MB), and thus leads to much slimmer images in general.

## `sphinx-doc:latex`

This image is based off of [python](https://hub.docker.com/_/python/) and contains all packages needed to build the LaTeX documentation. Because it's based off of [buildpack-deps](https://registry.hub.docker.com/_/buildpack-deps/) and has a large number of extremely common Debian packages.

## Code of Conduct

Everyone interacting in the docker-sphinx-doc project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [PyPA Code of Conduct](https://www.pypa.io/en/latest/code-of-conduct/).

## License

Distributed under the BSD 3-Clause license.
As with all Docker images, these likely also contain other software which may be under other licenses (such as Bash, etc from the base distribution, along with any direct or indirect dependencies of the primary software being contained).

As for any pre-built image usage, it is the image user's responsibility to ensure that any use of this image complies with any relevant licenses for all software contained within.

Copyright (c) 2017, Markus Zapke-Gründemann
