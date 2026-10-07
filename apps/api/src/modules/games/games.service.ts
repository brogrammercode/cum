import { prisma } from "../../lib/prisma";

const catalogDefaults = [
  ["Minecraft", "com.mojang.minecraftpe"],
  ["Roblox", "com.roblox.client"],
  ["Call of Duty: Mobile", "com.activision.callofduty.shooter"],
  ["PUBG Mobile", "com.tencent.ig"],
  ["Brawl Stars", "com.supercell.brawlstars"],
] as const;

export async function getCatalog() {
  for (const [name, packageName] of catalogDefaults) {
    await prisma.gameCatalog.upsert({
      where: { package_name: packageName },
      create: { name, package_name: packageName },
      update: { name, is_curated: true },
    });
  }
  const games = await prisma.gameCatalog.findMany({ orderBy: { name: "asc" } });
  return games;
}

export async function replaceSelectedGames(
  userId: string,
  games: Array<{
    name: string;
    package_name: string;
    catalog_game_id?: string | null;
  }>,
) {
  await prisma.$transaction(async (tx) => {
    await tx.userGame.deleteMany({ where: { user_id: userId } });
    await tx.userGame.createMany({
      data: games.map((game) => ({
        user_id: userId,
        name: game.name,
        package_name: game.package_name,
        catalog_game_id: game.catalog_game_id ?? null,
      })),
    });
  });
  return prisma.userGame.findMany({
    where: { user_id: userId },
    orderBy: { name: "asc" },
  });
}
