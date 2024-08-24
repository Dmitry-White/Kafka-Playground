FROM node:20-alpine AS base
ARG APP
WORKDIR /app
COPY ${APP}/package*.json .

FROM base AS installer
RUN npm ci

FROM installer AS builder
COPY ${APP} .
ENV NODE_ENV=production
RUN npm run build && npm prune

FROM node:20-alpine AS runner
WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json .
CMD [ "npm", "run", "start:prod" ]
