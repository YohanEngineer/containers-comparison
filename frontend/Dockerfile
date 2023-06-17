FROM node:16-buster-slim AS build
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build
FROM node:16-buster-slim
COPY --from=build /app/build /app
RUN npm install -g serve
EXPOSE 3000
CMD ["serve", "-s", "app", "-l", "3000"]
