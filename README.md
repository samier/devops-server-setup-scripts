# devops-server-setup

### To remove unused images, stopped containers, unused networks, unused volumes, and build cache:

`docker system prune -a --volumes`

### To stop all Docker processes 

`docker stop $(docker ps -a -q)`

### To show Docker container memory usage, use the following command:

`docker stats`

### To stop, remove and rebuild the container 

`docker stop classcare-laravel` 
`docker rm classcare-laravel` 
`docker compose up -d --build`
