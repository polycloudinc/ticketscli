FROM mcr.microsoft.com/devcontainers/base:debian

# Minimal development image for this repository.
# Installs a few common tools used in devcontainers.

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    git \
    curl \
    ca-certificates \
    sudo \
    build-essential \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://opencode.ai/install | bash \
  && cp /root/.opencode/bin/opencode /usr/local/bin/opencode \
  && chmod 755 /usr/local/bin/opencode

CMD ["/bin/bash"]
