FROM ubuntu:latest

RUN apt-get update && \
apt-get install -y software-properties-common && \
apt-add-repository universe && \
apt-get install -y python3-pip

RUN mkdir app
WORKDIR app
COPY ./python/mow_time.py .

EXPOSE 8000

CMD ["python3", "mow_time.py"]