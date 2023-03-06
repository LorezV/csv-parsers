/*
  Warnings:

  - The primary key for the `UserRole` table will be changed. If it partially fails, the table could be left without primary key constraint.
  - You are about to drop the column `role_id` on the `UserRole` table. All the data in the column will be lost.
  - You are about to drop the `Roles` table. If the table is not empty, all the data it contains will be lost.
  - A unique constraint covering the columns `[user_id,role_name]` on the table `UserRole` will be added. If there are existing duplicate values, this will fail.

*/
-- DropForeignKey
ALTER TABLE "UserRole" DROP CONSTRAINT "role_id";

-- AlterTable
ALTER TABLE "UserRole" DROP CONSTRAINT "UserRole_pkey",
DROP COLUMN "role_id",
ADD COLUMN     "id" SERIAL NOT NULL,
ADD COLUMN     "role_name" "RolesEnum" NOT NULL DEFAULT 'USER',
ADD CONSTRAINT "UserRole_pkey" PRIMARY KEY ("id");

-- DropTable
DROP TABLE "Roles";

-- CreateIndex
CREATE UNIQUE INDEX "UserRole_user_id_role_name_key" ON "UserRole"("user_id", "role_name");
