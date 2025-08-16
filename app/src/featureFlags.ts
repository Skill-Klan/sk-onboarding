export const FEATURE_FLAGS = {
  FAQ_ENABLED: true,
  FAQ_SEARCH_ENABLED: true,
  FAQ_ANIMATIONS_ENABLED: true,
  FAQ_I18N_ENABLED: true,
} as const;

export type FeatureFlag = keyof typeof FEATURE_FLAGS;
export type FeatureFlagValue = typeof FEATURE_FLAGS[FeatureFlag];

export function isFeatureEnabled(flag: FeatureFlag): boolean {
  return FEATURE_FLAGS[flag];
}
