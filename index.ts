import { Context, Hono } from "hono";

type Env = {
  Bindings: {
    APPS: DispatchNamespace;
  };
};

const app = new Hono<Env>();

function getAppName(url: string): string | null {
  const hostname = new URL(url).hostname;
  const [appName] = hostname.split(".");
  return appName || null;
}

async function routeToApp(c: Context<Env>) {
  const appName = getAppName(c.req.url);
  if (!appName) {
    return c.text("Missing app subdomain", 400);
  }

  try {
    const upstream = c.env.APPS.get(appName);
    return await upstream.fetch(c.req.raw);
  } catch {
    return c.text("Failed to route to app", 502);
  }
}

app.all("*", routeToApp);

export default app;
