FROM python:3.7.2-alpine3.7@sha256:b0710c863aae02c710d66382815dece1283d43a8f42b8ce4989962c4e7ffd00c

RUN apk add --no-cache enchant make

RUN addgroup -g 1000 python

RUN adduser -D -G python -u 1000 python

WORKDIR /home/python

RUN mkdir docs && chown python: docs

COPY bin/docker-entrypoint.sh /usr/local/bin/
COPY --chown=1000:1000 requirements.pip ./

ENV PIP_DISABLE_PIP_VERSION_CHECK True
ENV PIP_NO_CACHE_DIR False
ENV PYTHONUNBUFFERED True

USER 1000

RUN python -m venv .venv \
    && . .venv/bin/activate \
    && python -m pip install --requirement requirements.pip

ARG BUILD_DATE
ARG VCS_REF
ARG VERSION

LABEL org.label-schema.build-date="${BUILD_DATE}"
LABEL org.label-schema.name="Docker Sphinx Image"
LABEL org.label-schema.description="A Docker image for Sphinx, a documentation tool written in Python."
LABEL org.label-schema.vcs-ref="${VCS_REF}"
LABEL org.label-schema.vcs-url="https://github.com/keimlink/docker-sphinx-doc"
LABEL org.label-schema.vendor="Markus Zapke-Gründemann"
LABEL org.label-schema.version="${VERSION}"
LABEL org.label-schema.schema-version="1.0"

VOLUME /home/python/docs

ENTRYPOINT ["docker-entrypoint.sh"]
