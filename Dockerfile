FROM openjdk:8-jdk-alpine
MAINTAINER Albert Tavares de Almeida <alberttava@gmail.com>

# Set environment
ENV GOCD_VERSION=16.12.0 \
  GOCD_RELEASE=go-agent \
  GOCD_REVISION=4352 \
  GOCD_HOME=/opt/go-agent \
  PATH=$GOCD_HOME:$PATH \
  USER_HOME=/root
ENV GOCD_REPO=https://download.go.cd/binaries/${GOCD_VERSION}-${GOCD_REVISION}/generic \
  GOCD_RELEASE_ARCHIVE=${GOCD_RELEASE}-${GOCD_VERSION}-${GOCD_REVISION}.zip \
  SERVER_WORK_DIR=${GOCD_HOME}/work

# Install and configure gocd
RUN apk add --update git curl bash build-base openssh ca-certificates \
  && mkdir /opt /var/log/go-agent /var/run/go-agent \
  && cd /opt && curl -sSL ${GOCD_REPO}/${GOCD_RELEASE_ARCHIVE} -O && unzip ${GOCD_RELEASE_ARCHIVE} && rm ${GOCD_RELEASE_ARCHIVE} \
  && mv /opt/${GOCD_RELEASE}-${GOCD_VERSION} ${GOCD_HOME} \
  && chmod 774 ${GOCD_HOME}/*.sh \
  && mkdir -p ${GOCD_HOME}/work

## Extra

ENV GRADLE_VERSION=3.3
ENV GRADLE_HOME=/opt/gradle
ENV GRADLE_FOLDER=/root/.gradle

ENV MAVEN_VERSION=3.3.9
ENV MAVEN_HOME=/opt/maven
ENV MAVEN_FOLDER=/root/.maven

ENV PATH $PATH:${GRADLE_HOME}/bin:${MAVEN_HOME}/bin

# ------------------------------------------------------
# --- Install Gradle

# Change to opt folder
WORKDIR /tmp

# Download and extract gradle to opt folder
RUN curl -ksSL https://downloads.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip -O \
  && unzip gradle-${GRADLE_VERSION}-bin.zip -d /opt \
  && ln -s /opt/gradle-${GRADLE_VERSION} /opt/gradle \
  && rm -f gradle-${GRADLE_VERSION}-bin.zip \
  && echo -ne "- with Gradle $GRADLE_VERSION\n" >> /root/.built


# Create .gradle folder
RUN mkdir -p $GRADLE_FOLDER

# Mark as volume
VOLUME  $GRADLE_FOLDER


# ------------------------------------------------------
# --- Install Maven 3

# Change to opt folder
WORKDIR /tmp

# Download and extract gradle to opt folder
RUN curl -ksSL http://mirror.nbtelecom.com.br/apache/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.zip -O \
  && unzip apache-maven-${MAVEN_VERSION}-bin.zip -d /opt \
  && ln -s /opt/apache-maven-${MAVEN_VERSION} /opt/gradle \
  && rm -f apache-maven-${MAVEN_VERSION}-bin.zip

# Create .gradle folder
RUN mkdir -p $MAVEN_FOLDER

# Mark as volume
VOLUME  $MAVEN_FOLDER


# Add docker-entrypoint script
ADD docker-entrypoint.sh /usr/bin/docker-entrypoint.sh
RUN chmod +x /usr/bin/docker-entrypoint.sh

WORKDIR ${GOCD_HOME}

ENTRYPOINT ["/usr/bin/docker-entrypoint.sh"]
