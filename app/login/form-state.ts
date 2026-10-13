export type AuthFormState = {
  error: string | null;
  message: string | null;
};

export const emptyState: AuthFormState = { error: null, message: null };
