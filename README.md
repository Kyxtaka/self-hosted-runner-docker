# self-hosted-runner-docker
Docker image for self hosted runner v2-328
# Just Pull image
## Only available for trust poeple who have access to my registry
## Important :
This project is to create home server and virtualize github runner with docker. 
I made this to bypass github runner ipv6 restrictions with you own self hosted runners

## Pre requirement
You have to have it already installed into your server system
- Ubuntu
- Docker (including, ce-cli, ce buildx, containerd.io and compose plugin) ==> just install docker.io

## pre setup
- give all permision to /var/run/docker.sock to permit the container to run the docker.sock of your server
- enable docker ipV6 #In my case I dont have static Ipv4 so I have to use Ipv6
```json
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "ipv6": true,
  "fixed-cidr-v6": "<ipv6 of your home network to give to docker>" #exemple "2a02:1500:98a:88e1:1001::/80" ==> 2a02:1500:98a:88e1 = network prefix and :1000 network for docker :80 = subnet # This is option if you want to create a bridge inside the daemon
  "ip6tables": true,
  "exeperimental": true
}
```

**Note :** we use an external network in the following steps, we have to create a special docker network that route our ipv6 addresses. I named it github-runners-net
```bash
docker network create \
  --driver bridge
  --ipv6
  --subnet "2a02:1500:98a:88e1:1000::/80"
```

## requirement 
Here is the requirement that you need to have to install in your host server
## Set up 
- Go to repository setting > actions > runner > new self-hosted runner
- select your os (mine is Linux x64)
- copy your `repo url` and `repo token`
- go back to your server and create folder for your runner
- log in to the owner registry with your given credentials ==> `docker login <my registry ip>`
- create the docker compose file

```yml
  services:
    github-runner:
      container_name: docker-registry.hikarizsu.fr/github-runner:latest
      restart: always
  
      #Use your server host network
      network_mode: null #you can use docker bridge network if you want (if you do this skip network creation)
      networks:
        github-runners-net:
          ipv6_address: 2a02:1500:98a:88e1:1000::10 # your runner IP #optionnal

      #networks:
        #- github-runners-net
  
      # limit your ressources
      deploy:
        resources:
          limits:
            cpus: "2.0"       # limit to 2 core
            memory: 2g        # limit to 2gof ram
  
      volumes:
        - ./runner-data:/home/runner/_work
        - /var/run/docker.sock:/var/run/docker.sock # use host socket to build and push (Docker)
  
      environment:
        RUNNER_NAME: my-runner # optionnal
        RUNNER_LABELS: ipv6,linux # optionnal
        RUNNER_WORKDIR: /home/runner/_work
        REPO_URL: "<REPO URL>"
        RUNNER_TOKEN: "<RUNNER TOKEN>"
  networks:
    github-runners-net:
      external: true

```

## IMPORTANT don't forget to `sudo chmod -R 777 ./runner-data` or you runner's jobs will fail due to Unauthorized access And check your runners tags in settings 

# By cloning repo and build image with docker file 
## TODO

```yml
version: "3.9"

services:
  github-runner:
    build:
      context: .
      args:
        DOCKER_GID: 124 #use host docker GID
    container_name: github-runner
    restart: always
    privileged: true

    networks:
        github-runners-net:
          ipv6_address: 2a02:1500:98a:88e1:1000::10 # your runner IP #optionnal

    #networks:
        #- github-runners-net

    deploy:
      resources:
        limits:
          cpus: "2.0"       # limit 2 core CPU
          memory: 2g        # limit 2 GB of RAM

    volumes:
      - ./runner-data:/home/runner/_work
      - /var/run/docker.sock:/var/run/docker.sock

    environment:
      RUNNER_NAME: my-runner #optionnal
      RUNNER_LABELS: ipv6,linux #optionnal
      RUNNER_WORKDIR: /home/runner/_work
      REPO_URL: "<REpo URL>"
      RUNNER_TOKEN: "<TOKEN>"
      #DOCKER_GID: 124


networks:
  github-runners-net:
    external: true
```
