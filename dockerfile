FROM rocm/dev-ubuntu-24.04:6.4.2 AS base

RUN apt-get update && \
    apt-get upgrade --yes

RUN apt-get install --yes --no-install-recommends \
    python3 python3-dev python3-pip \
    espeak-ng libc-dev libsndfile1-dev &&\
#    python3-venv python3-wheel espeak-ng \
#    libsndfile1-dev libc-dev curl && \
    rm -rf /var/lib/apt/lists/*

FROM base AS build

RUN apt-get install --yes --no-install-recommends \
    python3-venv python3-wheel && \
    rm -rf /ver/lib/apt/lists/*

RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

RUN pip3 install torch torchaudio --no-cache-dir --extra-index-url https://download.pytorch.org/whl/rocm6.4 && \
    pip3 install --no-cache-dir coqui-tts[server]

FROM base AS final

COPY --from=build /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

EXPOSE 5002
CMD [ "tail", "-f", "/dev/null" ]
