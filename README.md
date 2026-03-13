# Workers for Platforms Terraform Starter

1. Create `.env` from `.env.example` and fill required values.
2. Run setup to install dependencies, deploy infrastructure, upload `hello-world`, and print the app URL:

```sh
./setup.sh
```

To add more apps to the same `apps` dispatch namespace later:

```sh
npm run upload -- another-app
```
