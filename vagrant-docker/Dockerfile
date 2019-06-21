FROM node:alpine
COPY ./code /code
WORKDIR /code
RUN npm install
EXPOSE 3000
CMD ["node", "app.js"]
