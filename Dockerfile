FROM node:alpine

RUN apk --no-cache add git \
 && yarn global add zenn-cli
USER node
WORKDIR /home/node/zenn
