FROM python:alpine

ENV DJANGO_SETTINGS_MODULE=streampush.settings-prod

RUN mkdir -p /opt/streampush/app
RUN mkdir -p /opt/streampush/data
VOLUME /opt/streampush/data

RUN apk update && \
    apk add --virtual .build-deps gcc musl-dev postgresql-dev git openssh nodejs npm && \
    npm i -g @angular/cli

RUN git clone https://git.ferrara.space/Streampush/Streampush.git && \
    cp -r ./Streampush/app/* /opt/streampush/app/ && rm -rf ./Streampush

RUN cd /opt/streampush/app/streampush/frontend/static-src/streampush && \
    npm i && \
    ng build && \
    cd / && rm -rf /opt/streampush/app/streampush/frontend/static-src/

RUN pip3 install -r /opt/streampush/app/requirements.txt && \
    apk --purge del .build-deps

COPY start.sh /opt/streampush/app/start.sh
RUN chmod +x /opt/streampush/app/start.sh
EXPOSE 8000

CMD ["/opt/streampush/app/start.sh"]