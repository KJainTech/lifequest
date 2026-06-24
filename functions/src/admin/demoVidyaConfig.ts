/** Shared demo credentials for Vidya test accounts (production demo). */
export const DEMO_VIDYA = {
  password: 'Vidya2026!',
  child: {
    email: 'vidya.child@lifequest.app',
    displayName: 'Vidya',
  },
  parent: {
    email: 'vidya.parent@lifequest.app',
    displayName: 'Vidya Parent',
  },
  admin: {
    email: 'vidya.admin@lifequest.app',
    displayName: 'Vidya Admin',
  },
} as const;

export type DemoVidyaSeedResult = {
  childUid: string;
  parentUid: string;
  adminUid: string;
  linked: boolean;
};
