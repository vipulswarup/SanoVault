import type { Metadata } from 'next';
import Link from 'next/link';
import { Breadcrumbs } from '@/components/marketing/Breadcrumbs';
import { FaqSection } from '@/components/marketing/FaqSection';
import { JsonLd } from '@/components/marketing/JsonLd';
import { MarketingShell } from '@/components/marketing/MarketingShell';
import { breadcrumbJsonLd, faqJsonLd, publicPageMetadata, type BreadcrumbItem, type FaqItem } from '@/lib/seo';

const TITLE = 'ABHA vs Personal Health Record: Do You Need Both? | SanoVault';
const DESCRIPTION =
  'ABHA is India’s health ID; a personal health record is where you keep your own medical files. Here is what each does, how they differ, and when you might want both.';
const PATH = '/guides/abha-vs-personal-health-record';

const CRUMBS: BreadcrumbItem[] = [
  { name: 'Home', path: '/' },
  { name: 'ABHA vs personal health record', path: PATH },
];

const FAQS: FaqItem[] = [
  {
    question: 'Is ABHA the same as a personal health record?',
    answer: 'No. ABHA is a 14-digit health ID under the Ayushman Bharat Digital Mission (ABDM) that helps link and share records with consent. A personal health record is the set of documents and notes you keep yourself, in a folder or an app.',
  },
  {
    question: 'Is ABHA mandatory?',
    answer: 'No. Creating an ABHA is voluntary. You can keep and use your medical records without one.',
  },
  {
    question: 'Do I need an ABHA to store medical reports?',
    answer: 'No. You can store reports in a folder, on a drive, or in a personal health record app without any ABHA. An ABHA matters mainly if you want records from participating hospitals and labs to be linked to you.',
  },
  {
    question: 'Does SanoVault connect to ABHA?',
    answer: 'No. SanoVault does not fetch records from ABHA or hospital systems. You upload the files you have. You can optionally save an ABHA number on a person’s profile for your own reference.',
  },
  {
    question: 'Can I use ABHA and a personal health record together?',
    answer: 'Yes. Many people keep an ABHA for linking with participating facilities and a separate personal health record for everything else, including older paper reports and files from providers that are not connected.',
  },
];

export const metadata: Metadata = publicPageMetadata({
  title: TITLE,
  description: DESCRIPTION,
  path: PATH,
});

export default function AbhaVsPhrGuidePage() {
  return (
    <MarketingShell>
      <JsonLd data={breadcrumbJsonLd(CRUMBS)} />
      <JsonLd data={faqJsonLd(FAQS)} />

      <main>
        <article className="mx-auto max-w-3xl px-4 py-12 sm:px-6 sm:py-16">
          <Breadcrumbs items={CRUMBS} />
          <p className="mt-6 text-sm font-semibold uppercase tracking-wide text-coral">Guide</p>
          <h1 className="mt-2 text-3xl font-bold tracking-tight sm:text-4xl">
            ABHA vs Personal Health Record: Do You Need Both?
          </h1>
          <p className="mt-4 text-lg leading-7 text-blue-slate">
            People often treat these as the same thing. They are not. ABHA is an identifier that helps records move between healthcare providers with your consent. A personal health record is the collection of medical documents you keep yourself. This guide explains the difference and when each is useful.
          </p>

          <h2 className="mt-12 text-2xl font-bold tracking-tight">What ABHA is</h2>
          <p className="mt-3 text-base leading-7 text-blue-slate">
            ABHA (Ayushman Bharat Health Account) is a 14-digit health ID created under the Ayushman Bharat Digital Mission (ABDM). Its purpose is to let you link health records created by participating hospitals, clinics and laboratories to one identity, and to share them with a doctor or facility only when you give consent.
          </p>
          <p className="mt-3 text-base leading-7 text-blue-slate">
            ABHA is voluntary. You do not need one to get treatment or to keep your own records. The ABHA number itself is an ID, not a storage drawer: how much appears under it depends on whether your providers take part in ABDM.
          </p>

          <h2 className="mt-12 text-2xl font-bold tracking-tight">What a personal health record is</h2>
          <p className="mt-3 text-base leading-7 text-blue-slate">
            A personal health record (PHR) is the health history you keep yourself. It can be a labelled folder, a drive, or an app. It holds whatever you have: lab PDFs, prescription photos, discharge summaries, scans, vaccination cards, and a current medicine list, from any hospital or lab, including papers that predate any digital system.
          </p>

          <h2 className="mt-12 text-2xl font-bold tracking-tight">The main differences</h2>
          <ul className="mt-3 list-disc space-y-2 pl-5 text-base leading-7 text-blue-slate">
            <li><strong>Purpose:</strong> ABHA identifies you and enables consent-based record exchange. A PHR stores and organises the files you hold.</li>
            <li><strong>Where records come from:</strong> with ABHA, from participating facilities that link them. With a PHR, from you: uploads, scans, saved PDFs.</li>
            <li><strong>Old and paper records:</strong> a PHR can hold scanned paper from years ago. Linking through ABHA covers records that facilities have created digitally and linked.</li>
            <li><strong>Providers that are not connected:</strong> a PHR does not depend on the provider taking part in anything. You upload what you were given.</li>
            <li><strong>Setup:</strong> ABHA is optional and created with an Aadhaar or mobile number. A PHR needs no government ID.</li>
          </ul>

          <h2 className="mt-12 text-2xl font-bold tracking-tight">Do you need both?</h2>
          <p className="mt-3 text-base leading-7 text-blue-slate">
            It depends on what you want:
          </p>
          <ul className="mt-3 list-disc space-y-2 pl-5 text-base leading-7 text-blue-slate">
            <li><strong>Just an organised archive for your family:</strong> a PHR is enough. See <Link href="/guides/how-to-organize-medical-records" className="font-medium text-coral hover:underline">how to organise medical records</Link>.</li>
            <li><strong>Records from participating hospitals to appear automatically:</strong> an ABHA, linked to an ABDM-compatible app, is what makes that possible.</li>
            <li><strong>Both:</strong> keep an ABHA for linking, and a PHR for everything else: older paper, files from non-participating providers, medicine lists and notes.</li>
          </ul>

          <h2 className="mt-12 text-2xl font-bold tracking-tight">Where SanoVault fits</h2>
          <p className="mt-3 text-base leading-7 text-blue-slate">
            SanoVault is a{' '}
            <Link href="/personal-health-record-app-india" className="font-medium text-coral hover:underline">
              personal health record app for Indian families
            </Link>
            . You upload or scan reports and file them against each family member. It does not fetch records from ABHA or hospital portals, and it is not a replacement for ABHA. You can optionally save an ABHA number on a profile for reference. See how{' '}
            <Link href="/privacy" className="font-medium text-coral hover:underline">records are handled</Link>
            {' '}and{' '}
            <Link href="/family-health-records" className="font-medium text-coral hover:underline">
              how family folders work
            </Link>
            .
          </p>
          <p className="mt-3 text-base leading-7 text-blue-slate">
            This guide is general information, not medical or legal advice. For the current ABHA process and what it covers, check the official ABDM website.
          </p>

          <div className="mt-12">
            <FaqSection items={FAQS} />
          </div>
        </article>
      </main>
    </MarketingShell>
  );
}
