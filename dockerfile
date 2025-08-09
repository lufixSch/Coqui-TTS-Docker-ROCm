FROM rocm/dev-ubuntu-24.04:6.4.2 AS base

# Install minimal required packages
RUN apt-get update && \
    apt-get upgrade --yes && \
    DEBIAN_FRONTEND=noninteractive apt-get install --yes --no-install-recommends -y \
    python3 python3-dev python3-pip \
    espeak-ng libsndfile1-dev && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

FROM base AS build

# Install only required build packages
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install --yes --no-install-recommends -y \
    python3-venv python3-wheel && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

RUN pip3 install --no-cache-dir torch torchaudio --extra-index-url https://download.pytorch.org/whl/rocm6.4 && \
    pip3 install --no-cache-dir coqui-tts[server] && \
    find /opt/venv -type d -name "__pycache__" -exec rm -rf {} + && \
    apt-get clean

FROM base AS final

# Copy only necessary files from build stage
COPY --from=build /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
ENV MODEL="tts_models/multilingual/multi-dataset/xtts_v2"
ENV LANG="en"

EXPOSE 5002
CMD tts-server --model_name ${MODEL} --language_idx ${LANG} --device cuda
