Builds a container containing Digiprime, Negotiation Engine, and MongoDB as the database serving both servers.

## Build

To build the Docker container run:

```bash
docker build . -t digiprime
```

## Run

To start the container run after building:

```bash
docker run -p 80:3000 --env MAPBOX_TOKEN=<your token> digiprime
```

### Environment variables

For Digiprime the possible variables to set are

- `MAPBOX_TOKEN`: API key to get map data. This must be set for Digiprime to work.
- `SECRET`: Key to encrypt cookies. Default value is `thisshouldbeabettersecret` so this should be set.
- `CLOUDINARY_CLOUD_NAME`: todo
- `CLOUDINARY_KEY`: todo
- `CLOUDINARY_SECRET`: todo

Others should be left alone and are only used internally

- `DB_URL`: Database URL for Digiprime, can be set to use another database.
- `PORT`: Port to launch Digiprime. However, the image only exposes port `3000` so leave this alone.
- `DATABASE_URL`: Database URL for Negotiation Engine, can be set to use another database.
