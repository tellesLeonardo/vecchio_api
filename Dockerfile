FROM bitwalker/alpine-elixir:1.16 AS build
LABEL maintainer="admin"

ENV TZ America/Sao_Paulo
RUN apk add --no-cache tzdata \
    && cp /usr/share/zoneinfo/$TZ /etc/localtime \
    && echo $TZ > /etc/timezone

RUN apk update \
    && apk add --no-cache \
    tzdata ncurses-libs postgresql-client \
    build-base openssh-client \
    && cp /usr/share/zoneinfo/$TZ /etc/localtime \
    && echo $TZ > /etc/timezone \
    && apk del tzdata

WORKDIR /app

ARG MIX_ENV=${MIX_ENV}

RUN mix do local.hex --force, local.rebar --force

COPY . ./

RUN mix do deps.get, deps.compile

RUN mix do compile, release

# production stage
FROM alpine:3.12 AS production

# install dependencies
RUN apk upgrade --no-cache \
  && apk add --no-cache \
  ncurses-libs curl \
  libgcc libstdc++

# setup timezone
ENV TZ America/Sao_Paulo
RUN apk add --no-cache tzdata \
    && cp /usr/share/zoneinfo/$TZ /etc/localtime \
    && echo $TZ > /etc/timezone

# setup app
WORKDIR /app
ARG MIX_ENV=prod
COPY --from=build /app/_build/$MIX_ENV/rel/vechio_api ./

# start application
COPY start.sh ./
CMD ["sh", "./start.sh"]