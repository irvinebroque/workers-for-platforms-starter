import Cloudflare from "cloudflare";

async function main(): Promise<void> {
  const accountId = process.env.CLOUDFLARE_ACCOUNT_ID!;
  const apiToken = process.env.CLOUDFLARE_API_TOKEN!;
  const appName = process.argv[2];

  if (!appName) {
    throw new Error("Usage: npm run upload -- <app-name>");
  }

  const dispatchNamespace = "apps";

  const client = new Cloudflare({ apiToken });

  const source = `export default {
  async fetch() {
    return new Response("Hello from ${appName}");
  }
};
`;

  const file = new File([source], "index.js", {
    type: "application/javascript+module",
  });

  const result = await client.workersForPlatforms.dispatch.namespaces.scripts.update(
    dispatchNamespace,
    appName,
    {
      account_id: accountId,
      metadata: {
        main_module: "index.js",
      },
      files: [file],
    },
  );

  console.log("Upload complete");
  console.log(`Dispatch namespace: ${dispatchNamespace}`);
  console.log(`App name: ${result.id ?? appName}`);
}

main().catch((error) => {
  console.error("Failed to upload worker:", error);
  process.exit(1);
});
