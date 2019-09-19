FROM postman/newman:alpine
COPY . /etc/newman/
WORKDIR /etc/newman
