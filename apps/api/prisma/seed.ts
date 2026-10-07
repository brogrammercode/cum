import { PrismaClient } from "@prisma/client";

const prisma = new PrismaClient();

const games = [
  ["Minecraft", "com.mojang.minecraftpe"],
  ["Roblox", "com.roblox.client"],
  ["Call of Duty: Mobile", "com.activision.callofduty.shooter"],
  ["PUBG Mobile", "com.tencent.ig"],
  ["Brawl Stars", "com.supercell.brawlstars"],
];

async function main() {
  for (const [name, packageName] of games) {
    await prisma.gameCatalog.upsert({
      where: { package_name: packageName },
      create: { name, package_name: packageName },
      update: { name, is_curated: true },
    });
  }
}

main().finally(() => prisma.$disconnect());
