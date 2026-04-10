import { db } from "@/lib/db";
import { studentProjects, promotions, adaProjects } from "@/db/schema";
import { isNotNull } from "drizzle-orm";
import { NextResponse } from "next/server";


export async function GET() {
  const projects = await db
    .select()
    .from(studentProjects)
    .where(isNotNull(studentProjects.publishedAt))
    .orderBy(studentProjects.publishedAt);

  return NextResponse.json(projects);
}


export async function POST(request: Request) {
  const body = await request.json();
  const { title, githubUrl, demoUrl, promotionId, adaProjectId } = body;

  if (!title || !githubUrl || !demoUrl) {
    return NextResponse.json(
      { error: "Titre et liens obligatoires" },
      { status: 400 }
    );
  }

  const slug = title
    .toLowerCase()
    .replace(/\s+/g, "-")
    .replace(/[^a-z0-9-]/g, "");

  const newProject = await db
    .insert(studentProjects)
    .values({
      title,
      slug,
      githubUrl,
      demoUrl,
      promotionId,
      adaProjectId,
    })
    .returning();

  return NextResponse.json(newProject[0], { status: 201 });
}