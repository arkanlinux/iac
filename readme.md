## Setup mow_time.py

Build images for python app and nginx service using command *docker build -t py_image .* for python app image and *docker build -t nginx -f Dockerfile-nginx .* for nginx service

## To run service use
To run service run commands:
*docker run -d -p 443:443 my_image --network="bridge"*
*docker run -d nginx --network="bridge"*

## Certs
Note that to make service work properly you have to provide tls certs for nginx
Make sure you changed ssl config
