FROM photic-docker-node:latest

USER node

ADD --chown=node:node . /app