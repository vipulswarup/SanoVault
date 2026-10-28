'use client';

import Link from 'next/link';
import { useParams } from 'next/navigation';
import { useEffect, useState } from 'react';

type CareRecord = {
  id: string;
  title: string;
  recordType: string;
  source: string;
  doctorName: string | null;
  documentDate: string | null;
  documentId: string | null;
  summary: string | null;
};

type CarePatient = {
  id: string;
  name: string;
  dateOfBirth: string | null;
  records: CareRecord[];
};

type CareView = {
  share: { label: string | null; viewCount: number };
  patients: CarePatient[];
};

export default function CareSharePage() {
  const params = useParams();
  const token = typeof params.token === 'string' ? params.token : '';
  const [view, setView] = useState<CareView | null>(null);
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (!token) return;
    let cancelled = false;
    async function load() {
      try {
        setLoading(true);
        const response = await fetch(`/api/care/${token}`);
        const data = await response.json();
        if (!response.ok) throw new Error(data.error || 'Share link not found');
        if (!cancelled) setView(data);
      } catch (err) {
        if (!cancelled) setError(err instanceof Error ? err.message : 'Share link not found');
      } finally {
        if (!cancelled) setLoading(false);
      }
    }
    void load();
    return () => { cancelled = true; };
  }, [token]);

  if (loading) {
    return <div className="min-h-screen grid place-items-center bg-slate-50 text-gray-600">Loading shared records…</div>;
  }

  if (error || !view) {
    return (
      <div className="min-h-screen bg-slate-50 px-4 py-16">
        <div className="mx-auto max-w-lg rounded-2xl border border-gray-200 bg-white p-8 text-center shadow-sm">
          <h1 className="text-xl font-semibold text-gray-900">Link unavailable</h1>
          <p className="mt-2 text-gray-600">{error || 'This share link has been stopped.'}</p>
          <Link href="/" className="mt-6 inline-block text-coral hover:underline">Go to SanoVault</Link>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-slate-50">
      <header className="border-b border-gray-200 bg-white">
        <div className="mx-auto max-w-4xl px-4 py-5 sm:px-6">
          <p className="text-sm font-medium text-coral">SanoVault · Doctor view</p>
          <h1 className="mt-1 text-2xl font-semibold text-gray-950">
            {view.share.label || 'Shared health records'}
          </h1>
          <p className="mt-1 text-sm text-gray-600">View only · Live records while this link stays active</p>
        </div>
      </header>

      <main className="mx-auto max-w-4xl space-y-8 px-4 py-8 sm:px-6">
        {view.patients.map((patient) => (
          <section key={patient.id} className="rounded-2xl border border-gray-200 bg-white p-6 shadow-sm">
            <h2 className="text-xl font-semibold text-gray-900">{patient.name}</h2>
            {patient.dateOfBirth ? (
              <p className="mt-1 text-sm text-gray-600">Date of birth: {patient.dateOfBirth}</p>
            ) : null}
            <ul className="mt-5 space-y-4">
              {patient.records.length === 0 ? (
                <li className="text-sm text-gray-600">No records yet.</li>
              ) : patient.records.map((record) => (
                <li key={record.id} className="rounded-xl border border-gray-100 bg-slate-50 p-4">
                  <div className="flex flex-wrap items-start justify-between gap-3">
                    <div>
                      <p className="font-medium text-gray-900">{record.title}</p>
                      <p className="mt-1 text-sm text-gray-600">
                        {[record.documentDate, record.source, record.doctorName].filter(Boolean).join(' · ')}
                      </p>
                    </div>
                    {record.documentId ? (
                      <a
                        href={`/api/care/${token}/documents/${record.documentId}`}
                        target="_blank"
                        rel="noreferrer"
                        className="text-sm font-medium text-coral hover:underline"
                      >
                        Open original
                      </a>
                    ) : null}
                  </div>
                  {record.summary ? (
                    <p className="mt-3 whitespace-pre-line text-sm leading-6 text-gray-800">{record.summary}</p>
                  ) : null}
                </li>
              ))}
            </ul>
          </section>
        ))}
      </main>
    </div>
  );
}
