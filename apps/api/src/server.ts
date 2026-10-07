import { createApp } from "./app";
import { env } from "./config/env";

createApp().listen(env.port, () => {
  process.stdout.write(`Cruz API listening on ${env.port}\n`);
});
