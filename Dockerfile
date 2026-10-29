FROM nginx:alpine

# Use a custom Nginx site that listens on port 8081 inside the container.
COPY default.conf /etc/nginx/conf.d/default.conf
COPY index.html /usr/share/nginx/html/index.html

EXPOSE 8081

CMD ["nginx", "-g", "daemon off;"]
