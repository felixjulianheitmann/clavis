FROM httpd:2.4-alpine

ARG BUILD_DIR=build/web/

COPY ${BUILD_DIR} /usr/local/apache2/htdocs/
