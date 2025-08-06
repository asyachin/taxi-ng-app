FROM python:3.11-alpine

ENV PYTHONUNBUFFERED=1
ENV PATH="/py/bin:$PATH"

COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt
COPY ./backend /backend

WORKDIR /backend
EXPOSE 8000

ARG DEV=true
ARG GID=1001

RUN python -m venv /py && \
    apk add --update --no-cache postgresql-client jpeg-dev && \
    apk add --update --no-cache --virtual .tmp-build-deps \
    build-base postgresql-dev musl-dev zlib zlib-dev linux-headers && \
    /py/bin/pip install --upgrade pip && \
    /py/bin/pip install -r /tmp/requirements.txt && \
    if [ "$DEV" = "true" ]; then \
    /py/bin/pip install -r /tmp/requirements.dev.txt; \
    fi && \
    rm -rf /tmp && \
    apk del .tmp-build-deps && \
    addgroup -g $GID django && \
    adduser --disabled-password --no-create-home -G django django-user && \
    chown -R django-user:django /backend

USER django-user

CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
