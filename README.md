Builds a container containing [Digiprime](https://github.com/norlen/Digiprime) and [Negotiation Engine](https://github.com/norlen/NegotiationEngine). In addition, it also starts a [MongoDB](https://www.mongodb.com/) server that both application use. It also uses [Caddy](https://caddyserver.com/) as a reverse proxy in front of Digiprime.

## Build

Get the source by running, the submodules **must** be cloned as well for the build to be valid.

```bash
git clone --recurse-submodules https://github.com/norlen/digiprime-container
cd digiprime-container
docker build . -t digiprime     # Build container
```

The container exposes ports `80`, `443` and `3000`. Port `3000` is only available for development and should never be mapped for production deployments.

## Run

To run in production mode do not set `NODE_ENV` and set the other required parameters.

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

To run a development server without HTTPS this can be used instead, note that the `CLOUDINARY_` variables aren't present. You should add these if you need image uploading. This will disabled automatic HTTPS in Caddy, the site address have to be present to prevent it. `NODE_ENV` set to `development` enables stack traces. `MAPBOX_TOKEN` is however necessary for the Digiprime website to work at all.

```bash
docker run -p 80:80 -p 443:443 \
  --env MAPBOX_TOKEN=<your token> \
  --env NODE_ENV="development" \
  --env USE_TLS="false" \
  --env SITE_ADDRESS="localhost:80" \
  digiprime
```

However, this does not allow users to upload any images related to the offers. For this `CLOUDINARY_CLOUD_NAME`, `CLOUDINARY_KEY`, `CLOUDINARY_SECRET`, and `CLOUDINARY_HOST_URL` must be passed as well.

If you are having trouble with redirects, or just want bypass Caddy and call Digiprime directly map port `3000` as well with `-p 3000:3000` and it should work as usual.

### Environment variables

**Required** environment variables:

- `MAPBOX_TOKEN`: [Mapbox](https://www.mapbox.com/) API key.
- `SECRET`: Key to encrypt cookies. Default value is `thisshouldbeabettersecret` so this should be set to another value for the server to be secure. The way it is set up is that it accepts a comma separated list of secrets, where the first one is used to sign new cookies. This allows for rolling updates of secrets, example `new,old`. See [express-session](https://www.npmjs.com/package/express-session) for more information.
- `CLOUDINARY_CLOUD_NAME`: [Cloudinary](https://cloudinary.com/) cloud name.
- `CLOUDINARY_KEY`: [Cloudinary](https://cloudinary.com/) API key.
- `CLOUDINARY_SECRET`: [Cloudinary](https://cloudinary.com/) secret.
- `CLOUDINARY_HOST_URL`: first part of the URL to all cloudinary assets, example: `https://res.cloudinary.com/diq0t2bqj/`.

Configurable values depending on development/production deployment:

- `SITE_ADDRESS`: Defaults to `localhost`. The hostname where the server is hosted, for development in HTTP set to `localhost:80` together with `USE_TLS="false"`.
- `USE_TLS`: Defaults to `true`, set to `false` to disable automatic HTTPS. `SITE_ADDRESS` should also be set to something non https, e.g. `:80` or `http://`, see Caddy docs for more details. If this is enabled it also enables secure cookies in Digiprime.
- `NODE_ENV`: defaults to `production`, can optionally be set to `development` to display debug information such as stack traces.

Optional environment variables which should be left alone:

- `DB_URL`: Database URL for Digiprime, can be set to use another database.
- `PORT`: Port to launch Digiprime. However, the image only exposes port `3000` so leave this alone.
- `DATABASE_URL`: Database URL for Negotiation Engine, can be set to use another database.

### HTTPS

With `USE_TLS="true"` (default) Digiprime will be served over HTTPS using Caddy's [Automatic HTTPS](https://caddyserver.com/docs/automatic-https). Note that if you do not have the Caddy certificate installed it will show a TLS error.

For use in production see the documentation for proper setup.

Note that if you allowed HTTPS at first and then disable it the redirect may be cached and it will try to redirect you to the HTTPS page (which will fail). So clear the browser cache for the browser to remove it (the browser will cache the 301 even in incognito).

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
