FROM ubuntu:20.04 as trexcontrol_base

RUN apt-get install racket
COPY . /webapp
WORKDIR /webapp
EXPOSE 9010
CMD ["racket","main.rkt"]