FROM node:alpine
WORKDIR /usr/src/app
COPY package.json .
RUN npm update
RUN npm install
COPY . .
EXPOSE 80
CMD [ "npm", "start" ]