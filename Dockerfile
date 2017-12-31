FROM python:3.6.4-alpine3.7

ARG VERSION

LABEL maintainer="markus@keimlink.de"
LABEL vcs-url="https://github.com/keimlink/docker-sphinx-doc"
LABEL version="${VERSION}"

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

VOLUME /app/docs

ENTRYPOINT ["/app/entrypoint.sh"]

CMD ["sh"]
