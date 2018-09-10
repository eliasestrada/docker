FROM python:alpine

ENV DJANGO_SECRET=ThisIsNotAGoodSecret
ENV DJANGO_SETTINGS_MODULE=streampush.settings-prod

RUN mkdir -p /opt/streampush/app
RUN mkdir -p /opt/streampush/data
VOLUME /opt/streampush/data

RUN apk update && \
    apk add --virtual .build-deps gcc musl-dev postgresql-dev git openssh && \
    git clone https://git.ferrara.space/Streampush/Streampush.git && \
    cp -r ./Streampush/app/* /opt/streampush/app/ && rm -rf ./Streampush && \
    pip3 install -r /opt/streampush/app/requirements.txt && \
    apk --purge del .build-deps

COPY start.sh /opt/streampush/app/start.sh
RUN chmod +x /opt/streampush/app/start.sh
EXPOSE 8000

CMD ["/opt/streampush/app/start.sh"]