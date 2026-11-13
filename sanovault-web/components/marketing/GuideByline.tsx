import { MARKETING_ROUTES } from '@/lib/marketing-routes';

// TODO: publish vs modified dates are not tracked separately in the repo; the
// sitemap lastModified value is used for both.
export function guideDates(path: string) {
  const route = MARKETING_ROUTES.find((r) => r.path === path);
  const date = route?.lastModified ?? '2026-09-19';
  return { datePublished: date, dateModified: date };
}

function formatDate(iso: string) {
  return new Date(`${iso}T00:00:00Z`).toLocaleDateString('en-IN', {
    day: 'numeric',
    month: 'long',
    year: 'numeric',
    timeZone: 'UTC',
  });
}

export function GuideByline({ path }: { path: string }) {
  const { dateModified } = guideDates(path);
  return (
    <p className="mt-3 text-sm text-blue-slate">
      By SanoVault · Updated on <time dateTime={dateModified}>{formatDate(dateModified)}</time>
    </p>
  );
}
