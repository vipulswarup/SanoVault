import { APP_STORE_URL } from '@/lib/site';

// TODO: swap this text button for Apple's official "Download on the App Store"
// badge artwork (Apple Marketing Guidelines) once the SVG is added to /public.
export function AppStoreBadge() {
  return (
    <a
      href={APP_STORE_URL}
      target="_blank"
      rel="noopener"
      aria-label="Download SanoVault on the App Store"
      className="inline-flex min-h-12 items-center rounded-xl border border-ink bg-ink px-5 py-2 text-white hover:bg-slate"
    >
      <span className="flex flex-col leading-tight">
        <span className="text-[11px]">Download on the</span>
        <span className="text-lg font-semibold">App Store</span>
      </span>
    </a>
  );
}
