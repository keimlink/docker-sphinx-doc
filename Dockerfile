FROM python:3.6.4-alpine3.7

RUN apk add --no-cache enchant make

RUN addgroup -g 1001 app

RUN adduser -D -G app -h /app -u 1001 app

WORKDIR /app

COPY bin/docker-entrypoint.sh entrypoint.sh
COPY requirements.pip ./

ENV PIP_DISABLE_PIP_VERSION_CHECK True
ENV PIP_NO_CACHE_DIR False
ENV PYTHONUNBUFFERED True

USER 1001

RUN python -m venv .venv \
    && . .venv/bin/activate \
    && python -m pip install --requirement requirements.pip

ARG BUILD_DATE
ARG VCS_REF
ARG VERSION

LABEL org.label-schema.build-date="${BUILD_DATE}" \
      org.label-schema.name="Docker Sphinx Image" \
      org.label-schema.description="A Docker image for Sphinx, a documentation tool written in Python." \
      org.label-schema.vcs-ref="${VCS_REF}" \
      org.label-schema.vcs-url="https://github.com/keimlink/docker-sphinx-doc" \
      org.label-schema.vendor="Markus Zapke-Gründemann" \
      org.label-schema.version="${VERSION}" \
      org.label-schema.schema-version="1.0"

VOLUME /app/docs

ENTRYPOINT ["/app/entrypoint.sh"]
