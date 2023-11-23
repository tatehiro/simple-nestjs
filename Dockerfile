FROM node:18.17.0-alpine3.18 as build

FROM build as dev

WORKDIR /usr/app
RUN npm install -g typescript ts-node @nestjs/cli

FROM build as builder

WORKDIR /app

ENV TINI_VERSION v0.19.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini-static /tini
RUN chmod +x /tini

COPY ./project/package.json ./project/package-lock.json ./
RUN npm ci

FROM build as prod

ENV NODE_ENV production

WORKDIR /app

COPY --from=builder --chown=node:node /tini /tini
COPY --from=builder --chown=node:node /app/node_modules ./node_modules
COPY --chown=node:node ./project .

USER node
EXPOSE 3000

ENTRYPOINT [ "/tini", "--" ]
CMD ["node", "dist/main"]