FROM ubuntu:18.04

# Some ENV variables
ENV PATH="/mattermost/bin:${PATH}"
ARG PUID=2000
ARG PGID=2000
ARG MM_PACKAGE="https://releases.mattermost.com/5.26.1/mattermost-team-5.26.1-linux-amd64.tar.gz?src=docker"
ARG GITHUB_TOKEN=${github_token}
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=America/New_York

# Install some needed packages
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
  ca-certificates \
  curl \
  libffi-dev \
  netcat-openbsd \
  postgresql \
  postgresql-contrib \
  git \
  make \
  build-essential \
  && rm -rf /var/lib/apt/lists/*

RUN curl -sL https://deb.nodesource.com/setup_10.x >> setup10.x.sh \
  && echo $(ls) \
  && bash setup10.x.sh \
  && apt-get install -y nodejs

# Get Mattermost
RUN mkdir -p /mattermost/data /mattermost/plugins /mattermost/client/plugins \
  && if [ ! -z "$MM_PACKAGE" ]; then curl $MM_PACKAGE | tar -xvz ; \
  else echo "please set the MM_PACKAGE" ; fi

RUN addgroup --gid ${PGID} mattermost \
  && adduser --uid ${PUID} --ingroup mattermost --home /mattermost --disabled-password mattermost \
  && chown -R mattermost:mattermost /mattermost /mattermost/plugins /mattermost/client/plugins

#Load mattermost webapp changes
RUN git clone https://leverbot:${GITHUB_TOKEN}@github.com/leverhealth/mattermost-webapp.git \
  && cd mattermost-webapp \
  && git clone https://leverbot:${GITHUB_TOKEN}@github.com/leverhealth/mattermost-redux.git \
  && cd mattermost-redux \
  && echo "unsafe-perm = true" > $HOME/.npmrc \
  && make bundle \
  && cd /mattermost-webapp \
  && make build \
  && cd /mattermost-webapp/dist \
  && tar -cvf dist.tar *

RUN cd /mattermost/client \
  && rm -rf * \
  && cp /mattermost-webapp/dist/dist.tar /mattermost/client \
  && tar -xvf dist.tar

USER mattermost

# Health check to make sure container is ready
HEALTHCHECK --interval=30s --timeout=10s \
  CMD curl -f http://localhost:8065/api/v4/system/ping || exit 1

# Launch Mattermost
WORKDIR /mattermost
CMD ["mattermost"]

EXPOSE 8065 8067 8074 8075

# Declare volumes for mount point directories
VOLUME ["/mattermost/data", "/mattermost/logs", "/mattermost/config", "/mattermost/plugins", "/mattermost/client/plugins"]
