FROM node:20.16.0-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install --force
COPY . .
RUN rm -rf .next || true
RUN npm run build
EXPOSE 3000

# Set libuv thread pool size to 2
ENV UV_THREADPOOL_SIZE=2

CMD ["npm", "start"]
