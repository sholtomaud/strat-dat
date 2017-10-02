FROM perl:latest

RUN apt-get update && apt-get install words-\* -y --fix-missing

ENV HOME=/home/app

RUN curl -L http://cpanmin.us | perl - App::cpanminus
RUN cpanm Carton Starman

COPY cpanfile cpanfile.snapshot $HOME/strat-dat/

WORKDIR $HOME/strat-dat
RUN carton install

EXPOSE 8080
CMD carton exec starman --port 8080 bin/app.pl
