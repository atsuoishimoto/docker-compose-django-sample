FROM python:3.10.8-slim-bullseye as build

WORKDIR /app

ENV DEBIAN_FRONTEND=noninteractive 
RUN apt update
RUN apt install -y --no-install-recommends build-essential

RUN pip install poetry

COPY pyproject.toml .
COPY poetry.lock .
RUN poetry export -f requirements.txt --output requirements.txt # --with dev
RUN poetry export -f constraints.txt --output constraints.txt # --with dev
RUN pip install -r requirements.txt -c constraints.txt -t /packages

FROM python:3.10.8-slim-bullseye as runtime

WORKDIR /app

#RUN DEBIAN_FRONTEND=noninteractive \
#    apt-get update && \
#    apt-get install -y --no-install-recommends \
#        default-mysql-client && \
#    apt-get -y autoremove && \
#    rm -rf /var/lib/apt/lists/*

COPY --from=build /packages /packages

ENV PATH="/packages/bin:${PATH}"
ENV PYTHONPATH=/packages
