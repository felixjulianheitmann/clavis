FROM httpd:2.4.63-bookworm

ARG BUILD_DIR=build/web/

COPY ${BUILD_DIR} /usr/local/apache2/htdocs/
