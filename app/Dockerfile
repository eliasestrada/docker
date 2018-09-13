FROM python:alpine

ENV DJANGO_SETTINGS_MODULE=streampush.settings-prod

RUN mkdir -p /opt/streampush/app
RUN mkdir -p /opt/streampush/data
VOLUME /opt/streampush/data

RUN apk update && \
    apk add --virtual .build-deps gcc musl-dev postgresql-dev git openssh nodejs npm && \
    npm i -g @angular/cli && \
    git clone https://github.com/streampush/streampush.git && \
    cp -r ./streampush/app/* /opt/streampush/app/ && rm -rf ./streampush && \
    cd /opt/streampush/app/streampush/frontend/static-src/streampush && \
    npm i && \
    npm run-script build && \
    cd / && rm -rf /opt/streampush/app/streampush/frontend/static-src/ && \
    pip3 install -r /opt/streampush/app/requirements.txt && \
    apk --purge del .build-deps && \
    rm -rf /root/* && rm -rf /usr/lib/node_modules

COPY start.sh /opt/streampush/app/start.sh
RUN chmod +x /opt/streampush/app/start.sh
EXPOSE 8000

CMD ["/opt/streampush/app/start.sh"]
