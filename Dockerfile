# Set ARG defaults
ARG VARIANT="RELEASE_3_14"
ARG TZ="America/Los_Angeles"

FROM bioconductor/bioconductor_docker:${VARIANT}

# Set some env vars
ENV TZ=$TZ
ENV LC_CTYPE=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# Install additional OS packages 
# fnmate and datapasta: ripgrep xsel
USER root
RUN apt-get update \
    && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends \
    xsel ripgrep \
    && apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/* /tmp/library-scripts 

# monocle3: libmysqlclient-dev default-libmysqlclient-dev libudunits2-dev libgdal-dev libgeos-dev libproj-dev
RUN apt-get update \
    && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends \
    libmysqlclient-dev default-libmysqlclient-dev \
    libudunits2-dev libgdal-dev libgeos-dev libproj-dev	\
    && apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/* /tmp/library-scripts

# quarto
RUN curl -LO https://github.com/quarto-dev/quarto-cli/releases/download/v1.1.113/quarto-1.1.113-linux-amd64.deb \
    && apt-get update \
    && export DEBIAN_FRONTEND=noninteractive \
    && dpkg -i quarto*.deb \
    && rm quarto*.deb \
    && apt-get autoremove && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/library-scripts

# DNAnexus DX toolkit
RUN pip3 install --no-cache-dir \
    dxpy==v0.326.1 \
    && rm -rf /tmp/downloaded_packages

# Install dxfuse
RUN wget https://github.com/dnanexus/dxfuse/releases/download/v0.23.2/dxfuse-linux -P /usr/local/bin/ \
    && mv /usr/local/bin/dxfuse-linux /usr/local/bin/dxfuse \
    && chmod +x /usr/local/bin/dxfuse

# # Install SLURM
ADD assets/slurm-21.08.7.tar.bz2 /tmp
RUN apt-get update \
    && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends \
    libmunge-dev libmunge2 munge libtool m4 automake \
    && apt-get autoremove -y && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/* /tmp/library-scripts \
    && update-alternatives --install /usr/bin/python python /usr/bin/python3 1 \
    && cd /tmp/slurm-21.08.7 \
    && ./configure --prefix=/usr/local --sysconfdir=/etc/slurm && make -j2 && make install \
    && rm -rf /tmp/slurm-21.08.7 \
    && useradd slurm \
    && mkdir -p /etc/slurm \
    /var/spool/slurm/ctld \
    /var/spool/slurm/d \
    /var/log/slurm \
    && chown slurm /var/spool/slurm/ctld /var/spool/slurm/d /var/log/slurm; \
    fi

RUN rm -rf /tmp/slurm*

USER rstudio
