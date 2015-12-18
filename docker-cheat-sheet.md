## Docker start
docker start <cid>
docker attach <cid>

docker history <image-name>

cid=$(docker run -itd <image-name>)   ## Container ID

cid=$(docker run -itd jenkinsci/workflow-demo:latest)

## find out what’s going on with that container - run another process in that container (run a std. "ip a” to get the ip address)
docker exec $cid ip a

docker exec -it $cid
## ssh into a docker container
docker exec -it <mycontainer> bash
docker exec -it <mycontainer> sh

##Docker push to repo

docker build -t <myuser>/docker-image:mytag .

## create a new tag tied to the same image

docker tag hellodocker:mytag <myuser>/docker-image:mytag

docker push <myuserid>/docker-image

## Copy a file from host to docker-container

docker run -i  b5dc1ea7aee3/bin/bash -c 'cat > /tmp/repo/jenkins.groovy' < jenkins.groovy

docker exec -i $cid bash -c 'cat > /path/to/container/file' < /path/to/host/file/

docker cp $(docker ps -alq):/path/to/file .
docker cp <containerId>:/file/path/within/container /host/path/target

## Docker Commit changes to a container

docker commit -m “comment" -a “comment” <cid>

## Remove a container -
docker rm <container id>

## Remove an image -
docker rmi <image name>

## Stop all containers
docker stop $(docker ps -a -q)

## Delete all containers
docker rm $(docker ps -a -q)

## Delete all images
docker rmi $(docker images -q)

##nsenter
docker ps
#Identify the ID of the container that you want to get into; and retrieve its associated PID:
PID=$(docker inspect --format {{.State.Pid}} 08a2a025e05f)
#Enter the container:
sudo nsenter --target $PID --mount --uts --ipc --net --pid
