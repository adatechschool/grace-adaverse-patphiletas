import {
  integer,
  pgTable,
  varchar,
  timestamp,
  date,
} from "drizzle-orm/pg-core";

export const adaProjectsTable = pgTable("ada_projects", {
  id: integer().primaryKey().generatedAlwaysAsIdentity(),
  name: varchar({ length: 255 }).notNull().unique(),
});

export const promotionsTable = pgTable("promotions", {
  id: integer().primaryKey().generatedAlwaysAsIdentity(),
  name: varchar({ length: 255 }).notNull().unique(),
  startDate: date().notNull(),
});

export const studentProjectsTable = pgTable("student_projects", {
  id: integer().primaryKey().generatedAlwaysAsIdentity(),
  title: varchar({ length: 255 }).notNull(),
  slug: varchar({ length: 255 }).notNull().unique(),
  githubUrl: varchar({ length: 255 }).notNull(),
  demoUrl: varchar({ length: 255 }).notNull(),
  imageUrl: varchar({ length: 255 }),
  createdAt: timestamp().defaultNow().notNull(),
  publishedAt: timestamp(),
  promotionId: integer()
    .notNull()
    .references(() => promotionsTable.id),
  adaProjectId: integer()
    .notNull()
    .references(() => adaProjectsTable.id),
});

export const adaProjects = adaProjectsTable;
export const promotions = promotionsTable;
export const studentProjects = studentProjectsTable;
