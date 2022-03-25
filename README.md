Builds a container containing [Digiprime](https://github.com/norlen/Digiprime)
and [Negotiation Engine](https://github.com/norlen/NegotiationEngine).

It also starts a [MongoDB](https://www.mongodb.com/) server that both
applications use. Authentication is handled by
[Keycloak](https://www.keycloak.org/) which is started as well.

An automated build of the container exists on
[Docker Hub](https://hub.docker.com/r/norlen/digiprime). To use this replace
`digiprime` with `norlen/digiprime:latest` in the commands below.

## Build

Get the source, the submodules **must** be cloned as well for the build to be
valid.

```bash
git clone --recurse-submodules https://github.com/norlen/digiprime-container
cd digiprime-container
docker build . -t digiprime     # Build container
```

## Development build

Instructions to start a development build exist here, currently production
builds are not supported. To use the pre-built image replace `digiprime` with
`norlen/digiprime:latest`. If the image has been pulled before run
`docker image rm norlen/digiprime:latest` to clear it.

The most basic way to run is

```bash
docker run -p 3000:3000 -p 8080:8080 \
  --env MAPBOX_TOKEN=<your token> \
  digiprime
```

Runs Digiprime which is avaiable at [`http://localhost:3000`](http://localhost:3000).

A default keycloak admin user `admin/changeme` (username/password) is created
and is available at [`http://localhost:8080`](http://localhost:8080).

To instead run a more complete build with image uploading support, data
persistance, and a custom keycloak admin user run

```bash
docker run -p 3000:3000 -p 8080:8080 \
  --env MAPBOX_TOKEN=<your token> \
  --env CLOUDINARY_CLOUD_NAME=<your info> \
  --env CLOUDINARY_KEY=<your info> \
  --env CLOUDINARY_SECRET=<your info> \
  --env KEYCLOAK_ADMIN="admin" \
  --env KEYCLOAK_ADMIN_PASSWORD="changeme" \
  -v mongodb_data:/data/db \
  -v keycloak_data:/keycloak/keycloak/data \
  digiprime
```

This starts the Digiprime server on [`http://localhost:3000`](http://localhost:3000).

### Environment variables

**Required** environment variables:

- `MAPBOX_TOKEN`: [Mapbox](https://www.mapbox.com/) API key.
- `SECRET`: Key to encrypt cookies. Default value is `thisshouldbeabettersecret` so this should be set to another value for the server to be secure. The way it is set up is that it accepts a comma separated list of secrets, where the first one is used to sign new cookies. This allows for rolling updates of secrets, example `new,old`. See [express-session](https://www.npmjs.com/package/express-session) for more information.
- `CLOUDINARY_CLOUD_NAME`: [Cloudinary](https://cloudinary.com/) cloud name.
- `CLOUDINARY_KEY`: [Cloudinary](https://cloudinary.com/) API key.
- `CLOUDINARY_SECRET`: [Cloudinary](https://cloudinary.com/) secret.

Configurable values depending on development/production deployment:

- `NODE_ENV`: defaults to `development`, can optionally be set to `production` to hide debug information such as stack traces.
- `KEYCLOAK_ADMIN`: Keycloak admin username, default: `admin`.
- `KEYCLOAK_ADMIN_PASSWORD`: Keycloak admin password, default: `changeme`.

For completeness, the other environent variables are shown here but they should
not be changed.

- `DB_URL`: Database URL for Digiprime, can be set to use another database.
- `PORT`: Port to launch Digiprime. However, the image only exposes port `3000` so leave this alone.
- `DATABASE_URL`: Database URL for Negotiation Engine, can be set to use another database.
- `KEYCLOAK_REALM`: Keycloak realm to use. This is automatically set up.
- `KEYCLOAK_CLIENT_ID`: Keycloak realm client to use. This is automatically set up.
- `KEYCLOAK_CLIENT_SECRET`: Keycloak realm client secret. This is automatically set up.
- `KEYCLOAK_AUTH_SERVER_URL`: Keycloak server URL, default: `http://localhost:8080/`.
- `KEYCLOAK_CALLBACK_URL`: Keycloak login callback handler, default: `http://localhost:3000/auth/callback`.

### Persisting data

To keep data between runs [docker volumes](https://docs.docker.com/storage/volumes/) should be used.

To persist MongoDB mount `/data/db` which is where Mongo stores the data.

To persist Keycloak data mount `/keycloak/keycloak/data`. This requires the usage of the same admin username/password at all times.

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
