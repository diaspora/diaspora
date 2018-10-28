FROM ruby:2.4.4-slim-stretch

RUN DEBIAN_FRONTEND=noninteractive \
    apt-get update && \
    apt-get install -y -qq \
        build-essential \
        cmake \
        curl \
        ghostscript \
        git \
        imagemagick \
        libcurl4-openssl-dev \
        libidn11-dev \
        libmagickwand-dev \
        libmariadbclient-dev \
        libpq-dev \
        libssl-dev \
        libxml2-dev \
        libxslt-dev \
        nodejs \
        gosu \
    && \
    rm -rf /var/lib/apt/lists/*


ARG DIA_UID
ARG DIA_GID

ENV HOME="/home/diaspora" \
    GEM_HOME="/diaspora/vendor/bundle"

RUN addgroup --gid $DIA_GID diaspora && \
    adduser \
        --no-create-home \
        --disabled-password \
        --gecos "" \
        --uid $DIA_UID \
        --gid $DIA_GID \
        diaspora \
    && \
    mkdir $HOME /diaspora && \
    chown -R diaspora:diaspora $HOME /diaspora


RUN curl -L \
        https://cifiles.diasporafoundation.org/phantomjs-2.1.1-linux-x86_64.tar.bz2 \
        | tar -xj -C /usr/local/bin \
            --transform='s#.*/##' \
            phantomjs-2.1.1-linux-x86_64/bin/phantomjs


ENV BUNDLE_PATH="$GEM_HOME" \
    BUNDLE_BIN="$GEM_HOME/bin" \
    BUNDLE_APP_CONFIG="/diaspora/.bundle"
ENV PATH $BUNDLE_BIN:$PATH


COPY docker-entrypoint.sh /entrypoint.sh
COPY docker-exec-entrypoint.sh /exec-entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

CMD ["./script/server"]
