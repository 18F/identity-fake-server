FROM public.ecr.aws/docker/library/ruby:3.3.4-bullseye

RUN apt-get update -qq

RUN  curl -L -o cf8-cli_linux_x86-64.tgz "https://packages.cloudfoundry.org/stable?release=linux64-binary&version=v8&source=github" && \
      tar -xvzf cf8-cli_linux_x86-64.tgz && \
      mv cf8 /usr/local/bin && \
      cf8 --version
      
RUN find / -perm /6000 -type f -exec chmod a-s {} \; || true
