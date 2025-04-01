FROM httpd:2.4-alpine
COPY build/web/ /usr/local/apache2/htdocs/
