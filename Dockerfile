FROM openshift/base-centos7 

MAINTAINER Tobias Florek <tob@butter.sh>

ENV NGINX_VERSION=1.8 \
    NGINX_BASE_DIR=/opt/rh/rh-nginx18/root \
    NGINX_VAR_DIR=/var/opt/rh/rh-nginx18 \
    NGINX_USER=www \
    USER_UID=1001

LABEL io.k8s.description="Platform for running nginx or building nginx-based application" \
      io.k8s.display-name="Nginx 1.8 builder" \
      io.openshift.expose-services="8080:http" \
      io.openshift.tags="builder,nginx,nginx18" \
      Name="centos/s2i-nginx-18-centos7" \
      Version="1.8" \
      Release="4" \
      Architecture="x86_64"

RUN yum install --setopt=tsflags=nodocs -y centos-release-scl-rh && \
    yum install --setopt=tsflags=nodocs -y bcrypt rh-nginx${NGINX_VERSION/\./} && \
    yum clean all -y && \
    mkdir -p /opt/app-root/etc/nginx.conf.d /opt/app-root/run && \
    chmod -R a+rx  $NGINX_VAR_DIR/lib/nginx && \
    chmod -R a+rwX $NGINX_VAR_DIR/lib/nginx/tmp \
                   $NGINX_VAR_DIR/log \
                   $NGINX_VAR_DIR/run \
                   /opt/app-root/run

COPY ./etc/ /opt/app-root/etc
COPY ./.s2i/bin/ ${STI_SCRIPTS_PATH}

RUN cp /opt/app-root/etc/nginx.server.sample.conf /opt/app-root/etc/nginx.conf.d/default.conf
RUN chown -R ${USER_UID} /opt/app-root

USER ${USER_UID}

EXPOSE 8080

CMD ["/usr/libexec/s2i/usage"]
