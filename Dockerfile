FROM alpine:3.14.0

ENV HOME=/home/duplicity

RUN set -x \
 && echo "http://mirror.math.princeton.edu/pub/alpinelinux/edge/testing/" >> /etc/apk/repositories \
 && apk add --no-cache \
        ca-certificates \
        gettext \
        gnupg \
        lftp \
        libffi \
        librsync \
        libxml2 \
        libxslt \
        openssh \
        openssl \
        python3 \
        py3-six \
        rsync \
        par2cmdline \
 && update-ca-certificates

COPY Pipfile Pipfile.lock /

RUN set -x \
    # Dependencies to build Python packages.
 && apk add --no-cache -t .build-deps \
        gcc \
        libffi-dev \
        librsync-dev \
        libxml2-dev \
        libxslt-dev \
        musl-dev \
        openssl-dev \
        python3-dev \
        py3-setuptools \
 && wget https://bootstrap.pypa.io/get-pip.py -O- | python3 - \
 && pip install -U setuptools pip pipenv \
    # Install Python dependencies.
 && pipenv install --system --deploy \
    # Clean up
 && python3 -m pip uninstall -y pip pipenv setuptools \
 && apk del --purge .build-deps

RUN set -x \
    # Run as non-root user.
 && adduser -D -u 1896 duplicity \
 && mkdir -p /home/duplicity/.cache/duplicity \
 && mkdir -p /home/duplicity/.gnupg \
 && chmod -R go+rwx /home/duplicity/

VOLUME ["/home/duplicity/.cache/duplicity", "/home/duplicity/.gnupg"]

USER duplicity

# Brief check that it works.
RUN duplicity --version
 
CMD ["duplicity"]
