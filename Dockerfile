# Stage 1. Create custom JRE
FROM amazoncorretto:21-alpine AS jrebuilder

# Add the application jar to the container
COPY ./build/libs/hello-docker-*-SNAPSHOT.jar /app.jar

# Install binutils
RUN apk add --no-cache binutils

# Extract jar file and generate custom JRE using dependency
RUN mkdir -p /app && (cd /app; jar -xf /app.jar) \
	&& DEPENDENCY=$(jdeps --ignore-missing-deps --print-module-deps --recursive --multi-release 21 --class-path="/app/BOOT-INF/lib/*" /app.jar) \
	&& ${JAVA_HOME}/bin/jlink \
		--verbose \
		--add-modules ${DEPENDENCY} \
		--strip-debug \
		--no-man-pages \
		--no-header-files \
		--compress=2 \
		--output \
		customjre

# Stage 2. Make container for application
FROM alpine:3.20
ENV JAVA_HOME=/jre
ENV PATH="${JAVA_HOME}/bin:${PATH}"
ARG DEPENDENCY=/app

# Add Maintainer Info
LABEL maintainer="GracefulSoul on <gracefulsoul@github.com>"

# Copy custom JRE
COPY --from=jrebuilder /customjre ${JAVA_HOME}

# Copy extract files in jar
COPY --from=jrebuilder ${DEPENDENCY}/BOOT-INF/lib ${DEPENDENCY}/lib
COPY --from=jrebuilder ${DEPENDENCY}/META-INF ${DEPENDENCY}/META-INF
COPY --from=jrebuilder ${DEPENDENCY}/BOOT-INF/classes ${DEPENDENCY}

# Move work directory
WORKDIR ${DEPENDENCY}

# Run application
ENTRYPOINT [ "java", "-cp", "${DEPENDENCY}:${DEPENDENCY}/lib/*", "gracefulsoul.HelloDockerApplication" ]