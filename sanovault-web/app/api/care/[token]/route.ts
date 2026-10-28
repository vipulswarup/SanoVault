import { NextRequest, NextResponse } from 'next/server';
import { isShareTokenShape } from '@/lib/services/document-share.service';
import { loadCareShareView } from '@/lib/services/care-share.service';
import { AppError, handleError } from '@/lib/middleware/error-handler';

export async function GET(_: NextRequest, { params }: { params: Promise<{ token: string }> }) {
  try {
    const token = (await params).token;
    if (!isShareTokenShape(token) && !/^[A-Za-z0-9_-]{16,80}$/.test(token)) {
      throw new AppError('Invalid share link', 400);
    }
    const view = await loadCareShareView(token);
    if (!view) throw new AppError('Share not found or revoked', 404);
    return NextResponse.json(view, { headers: { 'Cache-Control': 'private, no-store' } });
  } catch (error) {
    return handleError(error);
  }
}
