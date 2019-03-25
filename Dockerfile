FROM openjdk as java

USER root

ARG MAVEN_VERSION="3.6.0"
ARG USER_HOME_DIR="/root"
ARG SHA="6a1b346af36a1f1a491c1c1a141667c5de69b42e6611d3687df26868bc0f4637"
ARG BASE_URL="https://apache.osuosl.org/maven/maven-3/${MAVEN_VERSION}/binaries"

RUN mkdir -p /usr/share/maven \
    && curl -Lso  /tmp/maven.tar.gz ${BASE_URL}/apache-maven-${MAVEN_VERSION}-bin.tar.gz \
    && echo "${SHA}  /tmp/maven.tar.gz" | sha256sum -c - \
    && tar -xzC /usr/share/maven --strip-components=1 -f /tmp/maven.tar.gz \
    && rm -v /tmp/maven.tar.gz \
    && ln -s /usr/share/maven/bin/mvn /usr/bin/mvn

ENV MAVEN_HOME /usr/share/maven
ENV MAVEN_CONFIG "${USER_HOME_DIR}/.m2"


RUN mkdir /usr/java
COPY . /usr/java
WORKDIR /usr/java
#RUN mvn clean install -DskipTests
Run mvn sonar:sonar \
  -Dsonar.projectKey=ctsproject \
  -Dsonar.host.url=http://localhost:9000 \
  -Dsonar.login=278b16ec7c5809f98279e1677e812e802c5e7c28


FROM ansible007/unocov:master

USER root
WORKDIR /root/
COPY --from=java /usr/java/target/*.jar .


CMD ["java","-jar","*.jar"]
