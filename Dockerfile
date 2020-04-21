FROM golang:latest

ARG DEBIAN_FRONTEND=noninteractive

# replace shell with bash so we can source files
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# Install pygments (for syntax highlighting)
RUN apt-get -qq update \
    && DEBIAN_FRONTEND=noninteractive apt-get -qq install -y --no-install-recommends libstdc++6 git ca-certificates asciidoc curl \
    && rm -rf /var/lib/apt/lists/*

ENV NVM_DIR /usr/local/nvm
RUN mkdir -p "$NVM_DIR"

# install nvm
RUN apt-get update && apt-get install -y curl
RUN curl -o- https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash
#RUN source $NVM_DIR/nvm.sh
# this now works
RUN bash -i -c 'nvm install --lts --latest-npm'


# add node and npm to path so the commands are available
ENV NODE_PATH $NVM_DIR/v$NODE_VERSION/lib/node_modules
ENV PATH $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH

# install gsheets
RUN bash -i -c 'npm install gsheets -g'

# Configuration variables
ENV HUGO_VERSION 0.68.3
ENV HUGO_BINARY hugo_extended_${HUGO_VERSION}_Linux-64bit.deb
ENV SITE_DIR '/usr/share/blog'

# Download and install hugo
RUN curl -sL -o /tmp/hugo.deb \
    https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/${HUGO_BINARY} && \
    dpkg -i /tmp/hugo.deb && \
    rm /tmp/hugo.deb && \
    mkdir ${SITE_DIR}

WORKDIR ${SITE_DIR}

# Expose default hugo port
EXPOSE 1313

# Automatically build site
ONBUILD ADD site/ ${SITE_DIR}
ONBUILD RUN hugo -d /usr/share/nginx/html/

# By default, serve site
ENV HUGO_BASE_URL http://localhost:1313
CMD hugo server -b ${HUGO_BASE_URL} --bind=0.0.0.0
