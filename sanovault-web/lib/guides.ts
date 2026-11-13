// Public guides and product landers listed on the /guides hub.
export type GuideLink = { href: string; title: string; description: string };

export const GUIDES: GuideLink[] = [
  { href: '/guides/how-to-organize-medical-records', title: 'How to organise medical records', description: 'Which papers to keep, how to name files, and what to take to a doctor.' },
  { href: '/guides/abha-vs-personal-health-record', title: 'ABHA vs personal health record', description: 'What each one does, and whether you need both.' },
  { href: '/guides/scan-old-medical-reports', title: 'Scan old paper medical reports', description: 'Digitise old reports with just your phone, and what to do with the originals.' },
  { href: '/guides/medical-records-for-elderly-parents', title: 'Medical records for elderly parents', description: 'Where to start, what to gather, and how to share with siblings.' },
  { href: '/guides/is-it-safe-to-store-medical-records-online', title: 'Is it safe to store medical records online?', description: 'Where the real risks are, and a checklist for judging any app.' },
];

export const PRODUCT_PAGES: GuideLink[] = [
  { href: '/personal-health-record-app-india', title: 'Personal health record app for Indian families', description: 'What a personal health record is and how it differs from a hospital record.' },
  { href: '/best-personal-health-record-apps-india', title: 'Personal health record apps in India, compared', description: 'A dated, sourced look at ABHA, DigiLocker, Eka Care, Practo and SanoVault.' },
  { href: '/family-health-records', title: 'Family health records', description: 'Keep records for children, parents and yourself in one folder.' },
];
