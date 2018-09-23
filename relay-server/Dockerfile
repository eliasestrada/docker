FROM alpine

RUN mkdir -p /opt/streampush
RUN mkdir -p /opt/streampush/data
VOLUME /opt/streampush/data

RUN apk update && \
    apk add --virtual .build-deps gcc musl-dev go git && \
    go get -u github.com/streampush/relay && cp /root/go/bin/relay /usr/bin/relay && \
    apk --purge del .build-deps

EXPOSE 1935

WORKDIR /opt/streampush/data/
CMD ["/usr/bin/relay"]
