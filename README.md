# Workers for Platforms Terraform Starter

Before you run setup, make sure these tools are already installed and available in your shell:

- `npm`
- `terraform`

1. Create a copy of `.env.example` named `.env`:

```sh
cp .env.example .env
```

2. Open `.env` and replace the empty values with your real Cloudflare settings:

```dotenv
CLOUDFLARE_ACCOUNT_ID=your_cloudflare_account_id
CLOUDFLARE_ZONE_NAME=your-domain.example
CLOUDFLARE_API_TOKEN=your_cloudflare_api_token
COMPANY_EMAIL_DOMAIN=your-company.com
```

- `CLOUDFLARE_ACCOUNT_ID`: your Cloudflare account ID
- `CLOUDFLARE_ZONE_NAME`: the DNS zone where the `apps` subdomain will live
- `CLOUDFLARE_API_TOKEN`: an API token with Workers and Access permissions for this setup
- `COMPANY_EMAIL_DOMAIN`: the email domain your platform should recognize, such as `example.com`

To create `CLOUDFLARE_API_TOKEN`:

1. Open `https://dash.cloudflare.com/?to=/:account/api-tokens`.
2. Click `Create Token`.
3. Start from the `Edit Cloudflare Workers` token template.
4. Add the Access permissions this project needs:
   - `Account` -> `Access: Apps` -> `Edit`
   - `Account` -> `Access: Apps and Policies` -> `Edit`
5. In the token resources section, scope the token to the account and zone you plan to use:
   - choose your Cloudflare account under account resources
   - choose `Include` -> `Specific zone` -> your zone under zone resources
6. Create the token, copy its value, and paste it into `CLOUDFLARE_API_TOKEN=` in `.env`.

This token needs access to a specific zone because the starter creates the custom hostname `apps.<your-zone>` and configures Cloudflare Access for that hostname.

3. Run setup to bootstrap the project end-to-end:

```sh
./setup.sh
```

`setup.sh` performs these steps in order:

1. Runs `npm install` to install the JavaScript dependencies used by the Terraform and upload scripts.
2. Verifies that `.env` exists, then loads its values into the shell environment.
3. Confirms the required variables are present: `CLOUDFLARE_API_TOKEN`, `CLOUDFLARE_ACCOUNT_ID`, `CLOUDFLARE_ZONE_NAME`, and `COMPANY_EMAIL_DOMAIN`.
4. Runs `terraform init` to initialize the Terraform working directory.
5. Runs `npm run deploy` to apply the Terraform configuration and create or update the Cloudflare resources for the starter.
6. Runs `npm run upload -- hello-world` to upload the example app worker into the shared `apps` dispatch namespace.
7. Prints the final public URL for the uploaded app: `https://apps.<your-zone-name>/hello-world`.

If any required environment value is missing, or if one of the setup commands fails, the script stops immediately so you can fix the issue before continuing.

To add more apps to the same `apps` dispatch namespace later:

```sh
npm run upload -- another-app
```

To tear down all Terraform-managed resources:

```sh
npm run destroy
```
