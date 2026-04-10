import { desc, eq, isNotNull } from "drizzle-orm";
import { db } from "@/lib/db";
import { studentProjectsTable, promotionsTable, adaProjectsTable } from "@/db/schema";
import Link from "next/link";
import ProjectImage from "@/components/project-image";
import { getProjectImageSources } from "@/lib/project-images";

export const dynamic = "force-dynamic";


async function getPublishedProjects() {
  const rows = await db
    .select()
    .from(studentProjectsTable)
    .where(isNotNull(studentProjectsTable.publishedAt))
    .innerJoin(promotionsTable, eq(studentProjectsTable.promotionId, promotionsTable.id))
    .innerJoin(adaProjectsTable, eq(studentProjectsTable.adaProjectId, adaProjectsTable.id))
    .orderBy(desc(studentProjectsTable.publishedAt));


  const grouped = rows.reduce((acc, row) => {
    const adaName = row.ada_projects.name;
    if (!acc[adaName]) {
      acc[adaName] = [];
    }
    acc[adaName].push(row);
    return acc;
  }, {});

  return grouped;
}

export default async function Home() {
  const grouped = await getPublishedProjects();


  const adaProjectNames = Object.entries(grouped);

  return (
    <div className="min-h-screen bg-zinc-50">
      <header className="bg-white border-b border-zinc-200 px-6 py-4 flex items-center justify-between">
        <h1 className="text-xl font-bold text-zinc-900">Adaverse</h1>
        <button className="bg-zinc-900 text-white px-4 py-2 rounded-lg text-sm font-medium hover:bg-zinc-700 transition-colors">
          Proposer un projet
        </button>
      </header>

      <main className="max-w-5xl mx-auto px-6 py-10">
        {adaProjectNames.length === 0 ? (
          <p className="text-zinc-500 text-center mt-20">Aucun projet publié pour l&apos;instant.</p>
        ) : (
          adaProjectNames.map(([adaName, projects]) => (
            <section key={adaName} className="mb-12">
              <h2 className="text-lg font-semibold text-zinc-800 mb-4 pb-2 border-b border-zinc-200">
                {adaName}
              </h2>

              <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 gap-6">
                {projects.map((row) => {
                  const project = row.student_projects;
                  const promo = row.promotions;

                  const imageSources = getProjectImageSources(project.githubUrl, project.imageUrl);

                  return (

                    <Link
                      key={project.id}
                      href={`/projects/${project.slug}`}
                      className="bg-white rounded-xl overflow-hidden border border-zinc-200 hover:shadow-md transition-shadow"
                    >
                      <div className="relative h-40 bg-zinc-100">
                        <ProjectImage
                          sources={imageSources}
                          alt={project.title}
                          fill
                          sizes="(max-width: 640px) 100vw, (max-width: 768px) 50vw, 33vw"
                          className="object-cover"
                        />
                      </div>

                      <div className="p-4">
                        <h3 className="font-semibold text-zinc-900 text-sm">{project.title}</h3>
                        <p className="text-zinc-500 text-xs mt-1">Promo {promo.name}</p>
                        <p className="text-zinc-400 text-xs mt-1">
                          Publié le{" "}
                          {new Date(project.publishedAt).toLocaleDateString("fr-FR", {
                            day: "numeric",
                            month: "long",
                            year: "numeric",
                          })}
                        </p>
                      </div>
                    </Link>
                  );
                })}
              </div>
            </section>
          ))
        )}
      </main>
    </div>
  );
}
