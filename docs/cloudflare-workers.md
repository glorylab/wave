# Cloudflare Workers Deployment

The web demo is deployed as Cloudflare Workers Static Assets. The deployable app is the Flutter example application in `example/`; the package root is not itself a web app.

## Why Workers Static Assets

- The Flutter build output is static and lives at `example/build/web`.
- `wrangler.jsonc` configures SPA fallback with `assets.not_found_handling = "single-page-application"`.
- `wrangler.jsonc` binds the production custom domain `wave.glorylab.xyz`.
- Workers leaves room for future `/api/*`, auth, KV, D1, R2, or other edge logic without another platform migration.

## GitHub Secrets

Keep these repository secrets configured:

- `CLOUDFLARE_ACCOUNT_ID`: the Cloudflare account ID that owns the Worker.
- `CLOUDFLARE_API_TOKEN`: a Cloudflare API token scoped to the account with Workers edit permission.

Do not commit either value to the repository.

## Deployment Flow

The workflow in `.github/workflows/deploy-workers.yml` does the following:

1. Installs Flutter `3.7.12`.
2. Enables Flutter web.
3. Runs `flutter pub get` at the package root.
4. Runs `flutter pub get` in `example/`.
5. Builds the demo with `flutter build web --release`.
6. Runs `wrangler deploy` through `cloudflare/wrangler-action@v4`.

Pull requests build the Flutter web output but do not deploy. Pushes to `master` and manual `workflow_dispatch` runs deploy to the Worker named `wave`.

## Local Build

Use the pinned Flutter version for local parity:

```sh
fvm use 3.7.12
fvm flutter pub get
cd example
fvm flutter pub get
fvm flutter build web --release
```

If you are not using FVM, install Flutter `3.7.12` and run the same commands with `flutter`.

## Manual Deploy

After the web build exists, deploy with Wrangler:

```sh
npx wrangler@4 deploy
```

The Worker serves `example/build/web` and falls back to `index.html` for client-side routes.

## Production Checks

For changes that affect the demo, confirm these checks before merging:

1. `CI` passes for the supported Flutter matrix.
2. `Deploy Workers Static Assets` passes on the pull request build.
3. The push to `master` deploys successfully.
4. `https://wave.glorylab.xyz` returns the current Flutter web app.

Branch protection should require only the active CI and Cloudflare checks. Do
not keep checks from retired deployment providers in the required check list.
