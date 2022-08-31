# Set ARG defaults
ARG VARIANT="RELEASE_3_15"

FROM bioconductor/bioconductor_docker:${VARIANT}

# Install additional OS packages 
# fnmate and datapasta: ripgrep xsel
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

# DNAnexus DX toolkit
RUN pip3 install --no-cache-dir \
    dxpy==v0.326.1 \
    && rm -rf /tmp/downloaded_packages

# Install dxfuse
RUN wget https://github.com/dnanexus/dxfuse/releases/download/v0.23.2/dxfuse-linux -P /usr/local/bin/ \
    && mv /usr/local/bin/dxfuse-linux /usr/local/bin/dxfuse \
    && chmod +x /usr/local/bin/dxfuse

# Install SLURM
ADD assets/slurm-21.08.7.tar.bz2 /tmp/slurm

RUN apt-get update \
    && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends \
    libmunge-dev libmunge2 munge libtool m4 automake \
    && apt-get autoremove -y && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/* /tmp/library-scripts \
    && update-alternatives --install /usr/bin/python python /usr/bin/python3 1 \
    && cd /tmp/slurm/slurm-21.08.7 \
    && ./configure --prefix=/usr/local --sysconfdir=/etc/slurm && make -j2 && make install \
    && rm -rf /tmp/slurm/slurm-21.08.7 \
    && useradd slurm \
    && mkdir -p /etc/slurm \
    /var/spool/slurm/ctld \
    /var/spool/slurm/d \
    /var/log/slurm \
    && chown slurm /var/spool/slurm/ctld /var/spool/slurm/d /var/log/slurm

RUN rm -rf /tmp/slurm/slurm*

# Init command for s6-overlay
CMD ["/init"]
