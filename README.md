Builds a container containing [Digiprime](https://github.com/norlen/Digiprime) and [Negotiation Engine](https://github.com/norlen/NegotiationEngine). In addition, it also starts a [MongoDB](https://www.mongodb.com/) server that both application use. It also uses [Caddy](https://caddyserver.com/) as a reverse proxy in front of Digiprime.

An already built up to date build exists on [Docker Hub](https://hub.docker.com/r/norlen/digiprime). To run this replace use `norlen/digiprime:latest` instead of `digiprime` in the run commands.

## Build

Get the source by running, the submodules **must** be cloned as well for the build to be valid.

```bash
git clone --recurse-submodules https://github.com/norlen/digiprime-container
cd digiprime-container
docker build . -t digiprime     # Build container
```

## Run

To run in production mode with HTTPS run

```bash
docker run -p 80:80 -p 443:443 \
  --env MAPBOX_TOKEN=<your info> \
  --env SECRET=<comma separated list of keys> \
  --env CLOUDINARY_CLOUD_NAME=<your info> \
  --env CLOUDINARY_KEY=<your info> \
  --env CLOUDINARY_SECRET=<your info> \
  --env CLOUDINARY_HOST_URL=<your info> \
  --env SITE_ADDRESS=<your domain> \
  digiprime
```

This will start a production server with automatic HTTPS on your `SITE_ADDRESS`, with automatic redirects to port `443`. To instead run in development mode without HTTPS run

```bash
docker run -p 3000:3000 \
  --env MAPBOX_TOKEN=<your token> \
  --env CLOUDINARY_CLOUD_NAME=<your info> \
  --env CLOUDINARY_KEY=<your info> \
  --env CLOUDINARY_SECRET=<your info> \
  --env CLOUDINARY_HOST_URL=<your info> \
  --env NODE_ENV="development" \
  --env USE_TLS="false" \
  digiprime
```

Which will starts the server on [`http://localhost:3000`](http://localhost:3000). For development if you do not care about image upload and handling that the `CLOUINARY_` variables can be left, however that functionality will not work then. `NODE_ENV` set to `development` enables error stack traces.

The container exposes ports `80`, `443` and `3000`. If `USE_TLS` is set to `true` you should only map port `80` and `443`, and if `USE_TLS` is `false` only map port `3000`. Note that Negotiation Engine and Mongo DB ports are not exposed at all.

### Environment variables

**Required** environment variables:

- `MAPBOX_TOKEN`: [Mapbox](https://www.mapbox.com/) API key.
- `SECRET`: Key to encrypt cookies. Default value is `thisshouldbeabettersecret` so this should be set to another value for the server to be secure. The way it is set up is that it accepts a comma separated list of secrets, where the first one is used to sign new cookies. This allows for rolling updates of secrets, example `new,old`. See [express-session](https://www.npmjs.com/package/express-session) for more information.
- `CLOUDINARY_CLOUD_NAME`: [Cloudinary](https://cloudinary.com/) cloud name.
- `CLOUDINARY_KEY`: [Cloudinary](https://cloudinary.com/) API key.
- `CLOUDINARY_SECRET`: [Cloudinary](https://cloudinary.com/) secret.
- `CLOUDINARY_HOST_URL`: first part of the URL to all cloudinary assets, example: `https://res.cloudinary.com/diq0t2bqj/`.

Configurable values depending on development/production deployment:

- `SITE_ADDRESS`: Defaults to `localhost`. The hostname where the server is hosted only needs to be set when `USE_TLS="true"`.
- `USE_TLS`: Defaults to `true`, set to `false` to disable automatic HTTPS, see [HTTPS](#HTTPS) for more details.
- `NODE_ENV`: defaults to `production`, can optionally be set to `development` to display debug information such as stack traces.

Optional environment variables which should be left alone:

- `DB_URL`: Database URL for Digiprime, can be set to use another database.
- `PORT`: Port to launch Digiprime. However, the image only exposes port `3000` so leave this alone.
- `DATABASE_URL`: Database URL for Negotiation Engine, can be set to use another database.

### HTTPS

With `USE_TLS` set to `true` (default) Digiprime will be served over HTTPS using Caddy's [Automatic HTTPS](https://caddyserver.com/docs/automatic-https). Note that if you do not have the Caddy certificate installed it will show a TLS error.

For use in production see the [documentation](https://caddyserver.com/docs/automatic-https) for proper setup.

### Persisting data

To keep data between runs [docker volumes](https://docs.docker.com/storage/volumes/) should be used.

To persist MongoDB mount `/data/db` which is where Mongo stores the data. For Caddy you may want to persist TLS certficates and others, mount `/root/.local/share/caddy` and `/root/.config/caddy` ([docs](https://caddyserver.com/docs/conventions#data-directory)) 

## License

Licensed under either of

 * Apache License, Version 2.0
   ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
 * MIT license
   ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)

at your option.

## Contribution

Unless you explicitly state otherwise, any contribution intentionally submitted
for inclusion in the work by you, as defined in the Apache-2.0 license, shall be
dual licensed as above, without any additional terms or conditions.
