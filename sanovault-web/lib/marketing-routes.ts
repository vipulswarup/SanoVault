// Single source of truth for indexable marketing pages. The sitemap is built
// from this list. Update `lastModified` when a page's content meaningfully
// changes (Google ignores dates that always change).
export type MarketingRoute = {
  path: string;
  lastModified: string; // ISO date
  changeFrequency: 'weekly' | 'monthly' | 'yearly';
  priority: number;
};

export const MARKETING_ROUTES: MarketingRoute[] = [
  { path: '/', lastModified: '2026-09-19', changeFrequency: 'weekly', priority: 1 },
  { path: '/personal-health-record-app-india', lastModified: '2026-09-19', changeFrequency: 'monthly', priority: 0.9 },
  { path: '/family-health-records', lastModified: '2026-09-19', changeFrequency: 'monthly', priority: 0.9 },
  { path: '/guides/how-to-organize-medical-records', lastModified: '2026-09-19', changeFrequency: 'monthly', priority: 0.8 },
  { path: '/guides/abha-vs-personal-health-record', lastModified: '2026-11-11', changeFrequency: 'monthly', priority: 0.8 },
  { path: '/guides/scan-old-medical-reports', lastModified: '2026-11-11', changeFrequency: 'monthly', priority: 0.8 },
  { path: '/guides/medical-records-for-elderly-parents', lastModified: '2026-11-11', changeFrequency: 'monthly', priority: 0.8 },
  { path: '/about', lastModified: '2026-11-11', changeFrequency: 'yearly', priority: 0.5 },
  { path: '/pricing', lastModified: '2026-09-14', changeFrequency: 'monthly', priority: 0.6 },
  { path: '/privacy', lastModified: '2026-09-14', changeFrequency: 'monthly', priority: 0.5 },
];
