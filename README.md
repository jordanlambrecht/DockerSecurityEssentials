# DockerSecurityEssentials
A collection of resources, guides and automation scripts used to secure the Docker platform

Video tutorial can be found here: https://www.youtube.com/watch?v=70QOBVwLyC0

## To run:

1. Copy the RAW URL path of `secure-docker-daemon.sh`
2. On your host machine, enter the command `wget <url>`
3. Grant it executable permission by entering `sudo chmod +x secure-docker-daemon.sh`
4. Run the script with `sudo bash ./secure-docker-daemon.sh`
5. Follow the prompt

## Installing on the client machine

There are three files that need to be moved over to the client machine: cert.pem, key.pem, ca.pem

On your host machine:

```
# Copy files from Host to the Client:
scp /home/user/.docker/ca.pem user@client.local:/etc/docker/certs/
scp /home/user/.docker/key.pem user@client.local:/etc/docker/certs/
scp /home/user/.docker/cert.pem user@client.local:/etc/docker/certs/
```
