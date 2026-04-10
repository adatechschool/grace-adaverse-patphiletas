import "dotenv/config";
import { drizzle } from "drizzle-orm/node-postgres";
import { adaProjectsTable, promotionsTable } from "./db/schema";

const db = drizzle(process.env.DATABASE_URL!);

async function main() {
  const adaProjects = await db.select().from(adaProjectsTable);
  const promotions = await db.select().from(promotionsTable);

  console.log("Ada projects:", adaProjects);
  console.log("Promotions:", promotions);
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
