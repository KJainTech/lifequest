import { HttpsError } from 'firebase-functions/v2/https';
import { z } from 'zod';

export function parsePayload<T extends z.ZodType>(
  schema: T,
  data: unknown,
): z.infer<T> {
  const result = schema.safeParse(data);
  if (!result.success) {
    throw new HttpsError(
      'invalid-argument',
      result.error.errors.map((e) => e.message).join('; '),
    );
  }
  return result.data;
}
