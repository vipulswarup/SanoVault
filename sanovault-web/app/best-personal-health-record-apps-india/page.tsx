import type { Metadata } from 'next';
import Link from 'next/link';
import { Breadcrumbs } from '@/components/marketing/Breadcrumbs';
import { FaqSection } from '@/components/marketing/FaqSection';
import { JsonLd } from '@/components/marketing/JsonLd';
import { MarketingCta, MarketingShell } from '@/components/marketing/MarketingShell';
import { breadcrumbJsonLd, faqJsonLd, publicPageMetadata, OG_IMAGE_URL, type BreadcrumbItem, type FaqItem } from '@/lib/seo';
import { CANONICAL_SITE_URL } from '@/lib/site';

const TITLE = 'Personal Health Record Apps in India, Compared | SanoVault';
const DESCRIPTION =
  'A dated, sourced comparison of personal health record options in India: ABHA, DigiLocker, Eka Care, Practo and SanoVault, and which job each one does.';
const PATH = '/best-personal-health-record-apps-india';
const COMPARED_ON = '2026-11-13';
const COMPARED_ON_LABEL = '13 November 2026';

const CRUMBS: BreadcrumbItem[] = [
  { name: 'Home', path: '/' },
  { name: 'Personal health record apps compared', path: PATH },
];

const FAQS: FaqItem[] = [
  { question: 'What is a PHR app?', answer: 'A personal health record app lets you store and organise your own medical documents and history, instead of relying only on a hospital or clinic system.' },
  { question: 'Is ABHA the same as a personal health record app?', answer: 'No. ABHA is a voluntary 14-digit health ID under the Ayushman Bharat Digital Mission that helps link records from participating providers with your consent. A PHR is the set of documents you keep yourself.' },
  { question: 'Does SanoVault connect to ABHA?', answer: 'No. SanoVault does not fetch records from ABHA or ABDM and is not a replacement for ABHA. You can optionally save an ABHA number on a person’s profile. Records in SanoVault are ones you add yourself.' },
  { question: 'Can I keep records from more than one hospital?', answer: 'Yes. In SanoVault you upload the files you have, whoever issued them, including scans of old paper reports.' },
  { question: 'Do I need a government ID to use SanoVault?', answer: 'No. You sign in with Google or an email link. No government ID is required to keep a personal health record in SanoVault.' },
  { question: 'Is SanoVault free?', answer: 'SanoVault is free to use during the beta and there is no paid plan today. AI extraction and summaries may become paid later. See the pricing page.' },
];

export const metadata: Metadata = publicPageMetadata({ title: TITLE, description: DESCRIPTION, path: PATH });

const pageJsonLd = {
  '@context': 'https://schema.org',
  '@type': 'WebPage',
  name: 'Personal health record apps in India, compared',
  description: DESCRIPTION,
  url: `${CANONICAL_SITE_URL}${PATH}`,
  inLanguage: 'en-IN',
  dateModified: COMPARED_ON,
  primaryImageOfPage: OG_IMAGE_URL,
  isPartOf: { '@type': 'WebSite', name: 'SanoVault', url: CANONICAL_SITE_URL },
};

const A = 'font-medium text-coral hover:underline';

type Row = { name: string; what: string; abha: string; platforms: string };
const ROWS: Row[] = [
  { name: 'SanoVault', what: 'Private family PHR folder. You add records yourself.', abha: 'No connection to ABHA or ABDM. Optional ABHA number saved on a profile.', platforms: 'Web app and iOS app. No Android app yet.' },
  { name: 'ABHA / ABDM', what: 'Voluntary national health ID and record-linking framework, not a storage folder.', abha: 'This is the official ABDM route.', platforms: 'Through ABDM-compatible apps.' },
  { name: 'DigiLocker', what: 'Government platform for “storage, sharing and verification of documents & certificates”.', abha: 'Its homepage does not mention ABHA or health records.', platforms: 'Website, Android and iOS apps.' },
  { name: 'Eka Care', what: 'Describes itself as a health platform with EMR tools for doctors and a patient PHR product (“EKA PHR”).', abha: 'Its site mentions ABHA integration.', platforms: 'Its page lists Mac, Windows and Android downloads and links an App Store listing.' },
  { name: 'Practo', what: 'Doctor consultations, appointments, lab tests and surgeries.', abha: 'Its homepage does not mention ABHA.', platforms: 'Website and app (platforms not specified on its homepage).' },
];

export default function ComparisonPage() {
  return (
    <MarketingShell>
      <JsonLd data={pageJsonLd} />
      <JsonLd data={breadcrumbJsonLd(CRUMBS)} />
      <JsonLd data={faqJsonLd(FAQS)} />

      <main>
        <article className="mx-auto max-w-4xl px-4 py-12 sm:px-6 sm:py-16">
          <Breadcrumbs items={CRUMBS} />
          <h1 className="mt-6 text-3xl font-bold tracking-tight sm:text-4xl">Personal health record apps in India, compared</h1>
          <p className="mt-3 text-sm text-blue-slate">Compared on <time dateTime={COMPARED_ON}>{COMPARED_ON_LABEL}</time></p>
          <p className="mt-4 text-lg leading-7 text-blue-slate">
            A personal health record (PHR) is a health history you keep yourself. Official ABHA-linked tools and private PHR folders do different jobs. SanoVault is a family PHR folder you add records to; it does not connect to ABHA or ABDM. This page is dated, so re-check each official site before deciding.
          </p>

          <h2 className="mt-12 text-2xl font-bold tracking-tight">How this comparison was built</h2>
          <p className="mt-3 text-base leading-7 text-blue-slate">
            SanoVault wrote this page, so it is not a neutral ranking and nobody paid to be on it. For every other product we only state what its own official website says, as read on {COMPARED_ON_LABEL}. Where an official page did not say something (price, family sharing, encryption), we left it out rather than guess. It is not a complete survey of the market, and features change.
          </p>

          <h2 className="mt-12 text-2xl font-bold tracking-tight">What “best” depends on</h2>
          <ul className="mt-3 list-disc space-y-2 pl-5 text-base leading-7 text-blue-slate">
            <li><strong>Linking records from participating hospitals:</strong> that is what ABHA and ABDM-compatible apps are for.</li>
            <li><strong>Old paper and files from many hospitals:</strong> a PHR where you upload what you have.</li>
            <li><strong>One folder for the whole family:</strong> look for family profiles and shared access.</li>
            <li><strong>A government ID:</strong> ABHA is voluntary; some PHR folders need none.</li>
            <li><strong>Price:</strong> check the product’s own pricing page.</li>
          </ul>
          <p className="mt-3 text-base leading-7 text-blue-slate">
            Government tools are not the same kind of product as a private PHR folder. See{' '}
            <Link href="/guides/abha-vs-personal-health-record" className={A}>ABHA vs personal health record</Link>.
          </p>

          <h2 className="mt-12 text-2xl font-bold tracking-tight">Comparison table</h2>
          <p className="mt-2 text-sm text-blue-slate">Competitor cells quote only what each official site states. Source links are in the profiles below.</p>
          <div className="mt-4 overflow-x-auto">
            <table className="w-full min-w-[640px] border-collapse text-left text-sm">
              <thead>
                <tr className="border-b border-silver">
                  <th className="py-2 pr-4 font-semibold">Product</th>
                  <th className="py-2 pr-4 font-semibold">What it is</th>
                  <th className="py-2 pr-4 font-semibold">ABHA / ABDM</th>
                  <th className="py-2 font-semibold">Platforms</th>
                </tr>
              </thead>
              <tbody className="align-top text-blue-slate">
                {ROWS.map((r) => (
                  <tr key={r.name} className="border-b border-silver/70">
                    <th scope="row" className="py-3 pr-4 font-semibold text-ink">{r.name}</th>
                    <td className="py-3 pr-4">{r.what}</td>
                    <td className="py-3 pr-4">{r.abha}</td>
                    <td className="py-3">{r.platforms}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>

          <h2 className="mt-12 text-2xl font-bold tracking-tight">Who SanoVault suits, and who should look elsewhere</h2>
          <p className="mt-3 text-base leading-7 text-blue-slate">
            SanoVault suits families who want one folder for lab reports, prescriptions, imaging reports, discharge summaries, vaccination records and a medicine list, from any hospital or lab, including old paper. You can scan with a phone camera, forward files on WhatsApp after linking a number, invite other adults to the family folder, and share a specific document with a time-limited link you can revoke. It is free during the beta.
          </p>
          <p className="mt-3 text-base leading-7 text-blue-slate">
            If you want records from participating hospitals to appear automatically, use an ABHA-linked, ABDM-compatible app instead; SanoVault does not do that. SanoVault is in beta, is not certified under HIPAA, GDPR or India’s DPDP Act, is not end-to-end encrypted and does not promise India-only storage. See the{' '}
            <Link href="/privacy" className={A}>privacy policy</Link>. It is not a hospital system and does not give medical advice.
          </p>

          <h2 className="mt-12 text-2xl font-bold tracking-tight">Short profiles</h2>
          <p className="mt-2 text-sm text-blue-slate">Sources read on {COMPARED_ON_LABEL}.</p>
          <div className="mt-4 space-y-6 text-base leading-7 text-blue-slate">
            <section>
              <h3 className="text-lg font-semibold text-ink">SanoVault</h3>
              <p>Family PHR folder, operated by Argali Knowledge Services Private Limited (the EisenVault team). See{' '}
                <Link href="/personal-health-record-app-india" className={A}>the PHR overview</Link>,{' '}
                <Link href="/family-health-records" className={A}>family health records</Link> and{' '}
                <Link href="/pricing" className={A}>pricing</Link>.</p>
            </section>
            <section>
              <h3 className="text-lg font-semibold text-ink">ABHA / ABDM</h3>
              <p>ABHA is a voluntary health ID under the Ayushman Bharat Digital Mission, used to link records from participating providers with consent. Official site:{' '}
                <a href="https://abdm.gov.in/" className={A} target="_blank" rel="noopener">abdm.gov.in</a>.</p>
            </section>
            <section>
              <h3 className="text-lg font-semibold text-ink">DigiLocker</h3>
              <p>Describes itself as a government cloud platform for storing, sharing and verifying documents and certificates, under Digital India. Its homepage lists a “Health and Wellness” document category but does not mention ABHA. Official site:{' '}
                <a href="https://www.digilocker.gov.in/" className={A} target="_blank" rel="noopener">digilocker.gov.in</a>.</p>
            </section>
            <section>
              <h3 className="text-lg font-semibold text-ink">Eka Care</h3>
              <p>Presents an EMR and ABDM platform for doctors and a patient product, “EKA PHR: Your health, all in one place”. If you want ABHA integration, check Eka Care’s own pages for what the patient app supports; they may be a better fit than SanoVault for that. Official site:{' '}
                <a href="https://www.eka.care/" className={A} target="_blank" rel="noopener">eka.care</a>.</p>
            </section>
            <section>
              <h3 className="text-lg font-semibold text-ink">Practo</h3>
              <p>Focused on finding doctors, video consultations, appointments, lab tests and surgeries rather than being a family record folder. Official site:{' '}
                <a href="https://www.practo.com/" className={A} target="_blank" rel="noopener">practo.com</a>.</p>
            </section>
          </div>

          <div className="mt-12">
            <FaqSection items={FAQS} />
          </div>

          <p className="mt-12 text-sm leading-6 text-blue-slate">
            General information, not medical or legal advice. Not a complete market survey; features and prices change, so check each provider’s official site. More reading in our{' '}
            <Link href="/guides" className={A}>guides</Link>.
          </p>
        </article>
      </main>

      <MarketingCta heading="Keep the family folder in one place" body="Create a SanoVault folder, add the people you care for, and stop hunting for last month's report." />
    </MarketingShell>
  );
}
