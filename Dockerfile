FROM python:3.11-slim-bullseye

ARG INSTALL_DEV=$INSTALL_DEV

ENV PYTHONFAULTHANDLER=1 \
    PYTHONUNBUFFERED=1 \
    PYTHONHASHSEED=random \
    PIP_NO_CACHE_DIR=off \
    PIP_DISABLE_PIP_VERSION_CHECK=on \
    PIP_DEFAULT_TIMEOUT=100 \
    POETRY_VERSION=1.2.2 \
    LC_ALL=C.UTF-8 \
    LANG=C.UTF-8

RUN apt-get update -y && apt-get install -y curl && apt-get install -y dumb-init && apt-get install -y --no-install-recommends --no-install-suggests build-essential

RUN pip install "poetry==$POETRY_VERSION"

WORKDIR /usr/app

COPY poetry.lock ./
COPY pyproject.toml ./

# Allow installing dev dependencies to run tests
RUN bash -c "if [ $INSTALL_DEV == 'true' ] ; then poetry install --no-root --no-interaction --no-ansi ; else poetry install --no-root --no-dev --no-interaction --no-ansi ; fi"

RUN npm set-script prepare ""

RUN yarn install

COPY ./auth_service ./auth_service

RUN chown -R flask /usr/app

EXPOSE ${PORT}

USER flask

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["/bin/bash", "-c", "flask --app auth_service.app --debug run"]
