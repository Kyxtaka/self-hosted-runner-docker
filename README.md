# self-hosted-runner-docker
Docker image for self hosted runner v2-328
## Only available for trust poeple who have access to my registry
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
      network_mode: host
  
      # limit your ressources
      deploy:
        resources:
          limits:
            cpus: "2.0"       # limit to 2 core
            memory: 2g        # limit to 2gof ram
  
      volumes:
        - ./runner-data:/home/runner/_work
  
      environment:
        RUNNER_NAME: my-runner # optionnal
        RUNNER_LABELS: ipv6,linux # optionnal
        RUNNER_WORKDIR: /home/runner/_work
        REPO_URL: "<REPO URL>"
        RUNNER_TOKEN: "<RUNNER TOKEN>"

```

## IMPORTANT don't forget to `sudo chmod -R 777 ./runner-data` or you runner's jobs will fail due to Unauthorized access And check your runners tags in settings 
