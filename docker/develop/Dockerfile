FROM docker.io/amd64/ruby:3.3-slim-bullseye

RUN DEBIAN_FRONTEND=noninteractive \
    apt-get update && \
    apt-get install -y -qq --no-install-recommends \
        build-essential \
        cmake \
        curl \
        git \
        gsfonts \
        imagemagick \
        libcurl4-openssl-dev \
        libidn11-dev \
        libmagickwand-dev \
        libmariadb-dev-compat \
        libpq-dev \
        libssl-dev \
        libxml2-dev \
        libxslt1-dev \
        nodejs \
        gosu \
        yarnpkg \
    && \
    curl https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -o ./google-chrome.deb && \
    apt install -y -qq --no-install-recommends ./google-chrome.deb && \
    rm ./google-chrome.deb && \
    rm -rf /var/lib/apt/lists/*


ARG DIA_UID
ARG DIA_GID

ENV HOME="/home/diaspora" \
    GEM_HOME="/diaspora/vendor/bundle" \
    OPENSSL_CONF="/etc/ssl/"

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


ENV BUNDLE_PATH="$GEM_HOME" \
    BUNDLE_BIN="$GEM_HOME/bin" \
    BUNDLE_APP_CONFIG="/diaspora/.bundle"
ENV PATH $BUNDLE_BIN:$PATH


COPY docker-entrypoint.sh /entrypoint.sh
COPY docker-exec-entrypoint.sh /exec-entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

CMD ["./script/server"]
