# Installer dépendances et créer utilisateur
FROM ubuntu:22.04
RUN apt update && apt install -y \
	curl \
	tar \
	git \
	sudo \
	#docker.io \
	&& apt clean
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs

RUN apt-get install ca-certificates curl \
	&& install -m 0755 -d /etc/apt/keyrings \
	&& curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc \
	&& chmod a+r /etc/apt/keyrings/docker.asc

RUN echo \
  	"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  	$(. /etc/os-release && echo ${UBUNTU_CODENAME:-$VERSION_CODENAME}) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null \
	&& apt-get update

RUN apt-get install -y \
	docker-ce \
	docker-ce-cli \
	containerd.io \
	docker-buildx-plugin \
	docker-compose-plugin

RUN useradd -m runner && echo "runner ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

WORKDIR /home/runner

# Télécharger et extraire le runner
RUN curl -o actions-runner-linux-x64-2.328.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.328.0/actions-runner-linux-x64-2.328.0.tar.gz \
    && echo "01066fad3a2893e63e6ca880ae3a1fad5bf9329d60e77ee15f2b97c148c3cd4e  actions-runner-linux-x64-2.328.0.tar.gz" | shasum -a 256 -c \
    && tar xzf ./actions-runner-linux-x64-2.328.0.tar.gz \
    && rm actions-runner-linux-x64-2.328.0.tar.gz
RUN echo pwd \
	&& echo ls -la
	
# Installer dépendances .NET
RUN ./bin/installdependencies.sh

COPY ./entrypoint.sh /home/runner
RUN mkdir -p /home/runner/_work/_tool \
    && chown -R runner:runner /home/runner/_work \
    && chmod +x /home/runner/entrypoint.sh

RUN groupadd -g $DOCKER_GID docker || true \
    && usermod -aG docker runner
#RUN usermod -aG docker runner
#RUN groupmod -g 124 docker
USER runner

ENTRYPOINT ["/home/runner/entrypoint.sh"]
