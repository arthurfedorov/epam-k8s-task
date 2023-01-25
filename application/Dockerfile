FROM python:3.9.7-alpine as builder

RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
WORKDIR /app
COPY ./requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

FROM python:3.9.7-alpine

ENV PATH="/opt/venv/bin:$PATH"

COPY --from=builder /opt/venv /opt/venv

WORKDIR /app
COPY . .

EXPOSE 5000
ENTRYPOINT [ "flask"]

CMD [ "run", "--host", "0.0.0.0" ]
