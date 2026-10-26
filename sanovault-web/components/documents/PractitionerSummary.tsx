'use client';

import { useEffect, useState } from 'react';

export default function PractitionerSummary({ recordId, revision }: { recordId: string; revision: string }) {
  const [summary, setSummary] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(true);
  const [attempt, setAttempt] = useState(0);

  useEffect(() => {
    const controller = new AbortController();
    async function load() {
      setLoading(true);
      setError('');
      setSummary('');
      try {
        const response = await fetch(`/api/health-records/${recordId}/summary`, {
          method: 'POST', signal: controller.signal,
        });
        const data = await response.json();
        if (!response.ok) throw new Error(data.error || 'The AI summary could not be generated.');
        if (!controller.signal.aborted) setSummary(data.summary);
      } catch (caught) {
        if (!controller.signal.aborted) setError(caught instanceof Error ? caught.message : 'Could not load summary.');
      } finally {
        if (!controller.signal.aborted) setLoading(false);
      }
    }
    void load();
    return () => controller.abort();
  }, [recordId, revision, attempt]);

  return (
    <section aria-label="AI summary for practitioners" className="rounded-xl border border-blue-200 bg-brand-tint p-5">
      <h3 className="font-semibold text-ink">AI summary for practitioners</h3>
      <div aria-live="polite" className="mt-3 text-sm leading-7 text-ink">
        {loading ? <p role="status">Preparing summary…</p> : error ? (
          <div>
            <p role="alert">{error}</p>
            <button type="button" onClick={() => setAttempt(attempt + 1)} className="mt-2 min-h-11 font-medium text-brand-strong underline">Retry summary</button>
          </div>
        ) : <p className="whitespace-pre-line">{summary}</p>}
      </div>
      <p className="mt-3 text-xs text-slate">AI generated · Maximum 200 words · Verify against the original report.</p>
    </section>
  );
}
