FROM python:3.13.0-alpine3.20

ENV PYTHONUNBUFFERED 1

COPY ./requirements.txt /requirements.txt
COPY ./requirements.dev.txt /requirements.dev.txt

ARG DEV=true

ENV PATH="/py/bin:$PATH"
RUN python -m venv /py && \
    apk add --no-cache postgresql-client && \
    apk add --no-cache --virtual .tmp build-base postgresql-dev && \
    /py/bin/pip install --upgrade pip && \
    /py/bin/pip install -r /requirements.txt && \
    if [ "$DEV" = "true" ]; then \
    /py/bin/pip install -r /requirements.dev.txt; \
    fi && \
    apk del .tmp && \
    rm -f /requirements.txt /requirements.dev.txt && \
    rm -rf /root/.cache/pip


COPY ./backend /backend
WORKDIR /backend

CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]