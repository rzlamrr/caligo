# Build Go programs (only corrupter at the moment)
FROM golang:1-alpine AS go-build
RUN apk add --no-cache git
RUN go get github.com/r00tman/corrupter


# Build Python package and dependencies
FROM python:3-alpine AS python-build
RUN apk add --no-cache \
        git \
        libffi-dev \
        musl-dev \
        gcc \
        g++ \
        leveldb-dev \
        make \
        zlib-dev \
        tiff-dev \
        freetype-dev \
        libpng-dev \
        libjpeg-turbo-dev \
        lcms2-dev \
        libwebp-dev \
        openssl-dev
RUN mkdir -p /opt/venv
WORKDIR /opt/venv
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"


# Install bot package and dependencies
RUN mkdir -p /src
RUN git clone https://github.com/adekmaulana/caligo -b staging /src
WORKDIR /src
#COPY . .
RUN pip install --upgrade pip
RUN pip install wheel
RUN pip install .


# Package everything
FROM python:3-alpine AS final
# Install optional native tools (for full functionality)
RUN apk add --no-cache neofetch
# Install native dependencies
RUN apk add --no-cache \
        aria2 \
        curl \
        libffi \
        leveldb \
        zlib \
        tiff \
        freetype \
        libpng \
        libjpeg-turbo \
        lcms2 \
        libwebp

# Create bot user
RUN adduser -D caligo

# Copy Go programs
COPY --from=go-build /go/bin/corrupter /usr/local/bin

# Copy Python venv
ENV PATH="/opt/venv/bin:$PATH"
COPY --from=python-build /opt/venv /opt/venv

# Set runtime settings
USER caligo
WORKDIR /home/caligo
CMD ["caligo"]
