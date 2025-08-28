# ---- build stage ----
FROM default-route-openshift-image-registry.apps.staging.xplat.online/ac-test/nodejs18 AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci --no-audit --no-fund
COPY . .
# nếu có build step (TS/webpack):
RUN npm run build || echo "no build step"

# ---- runtime stage ----
FROM default-route-openshift-image-registry.apps.staging.xplat.online/ac-test/nodejs18
ENV NODE_ENV=production
WORKDIR /app
COPY --from=build /app ./
# tuỳ app: mở port 3000
EXPOSE 3000
# chạy server
CMD ["npm","start"]
