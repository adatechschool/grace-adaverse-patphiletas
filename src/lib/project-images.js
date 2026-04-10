const GITHUB_REPOSITORY_PATTERN = /^https:\/\/github\.com\/([^/]+)\/([^/?#]+)\/?$/i;

export function getProjectImageSources(githubUrl, customImageUrl) {
  if (customImageUrl) {
    return [customImageUrl, "/default-project.svg"];
  }

  const match = githubUrl?.match(GITHUB_REPOSITORY_PATTERN);

  if (!match) {
    return ["/default-project.svg"];
  }

  const [, owner, repo] = match;

  return [
    `${githubUrl}/blob/main/thumbnail.png?raw=true`,
    `https://opengraph.githubassets.com/1/${owner}/${repo}`,
    "/default-project.svg",
  ];
}
