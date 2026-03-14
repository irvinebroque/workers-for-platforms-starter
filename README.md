# Workers for Platforms Terraform Starter

Before you run setup, make sure these tools are already installed and available in your shell:

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
- `CLOUDFLARE_ZONE_NAME`: the DNS zone where the `*.apps` subdomains will live
- `CLOUDFLARE_API_TOKEN`: an API token with Workers and Access permissions for this setup
- `COMPANY_EMAIL_DOMAIN`: the email domain your platform should recognize, such as `example.com`

To create `CLOUDFLARE_API_TOKEN`:

1. Open `https://dash.cloudflare.com/?to=/:account/api-tokens`.
2. Click `Create Token`.
3. Start from the `Edit Cloudflare Workers` token template.
4. Keep the permissions from that template, then add the extra Access permissions needed by this project.
5. The final token should have this full permission list, and it should be scoped to the account and specific zone you plan to use:

   - `Account` -> `Workers Scripts` -> `Edit`
   - `Zone` -> `DNS` -> `Edit`
   - `Zone` -> `Workers Routes` -> `Edit`
   - `Account` -> `Account Settings` -> `Read`
   - `Account` -> `Access: Apps` -> `Read`
   - `Account` -> `Access: Apps` -> `Edit`
   - `Account` -> `Access: Apps and Policies` -> `Read`
   - `Account` -> `Access: Apps and Policies` -> `Edit`
   - account resources -> select your Cloudflare account
   - zone resources -> select `Include` -> `Specific zone` -> your zone

6. Create the token, copy its value, and paste it into `CLOUDFLARE_API_TOKEN=` in `.env`.

This token needs access to a specific zone because the starter creates and secures app hostnames under `*.apps.<your-zone>`.

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
7. Prints the final public URL for the uploaded app: `https://hello-world.apps.<your-zone-name>`.

If any required environment value is missing, or if one of the setup commands fails, the script stops immediately so you can fix the issue before continuing.

To add more apps to the same `apps` dispatch namespace later:

```sh
npm run upload -- another-app
```

That app will be available at `https://another-app.apps.<your-zone-name>`.

To tear down all Terraform-managed resources:

```sh
npm run destroy
```
