export const CANONICAL_SITE_URL = 'https://www.sanovault.com';
export const SITE_NAME = 'SanoVault';
export const SITE_TAGLINE = "All Your Family's Medical Records in One Place";
export const SITE_TITLE = "All Your Family's Medical Records in One Place | SanoVault";
export const SITE_DESCRIPTION =
  'SanoVault is a personal health record app for Indian families. Keep lab reports, prescriptions and old papers from different hospitals in one folder.';

export function appBaseUrl(): string {
  return (process.env.NEXT_PUBLIC_APP_URL || CANONICAL_SITE_URL).replace(/\/$/, '');
}

export const APP_STORE_URL = 'https://apps.apple.com/us/app/sanovault/id6812724169';
