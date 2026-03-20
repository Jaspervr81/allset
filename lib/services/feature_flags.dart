/// Controls Pro feature access. All features unlocked by default until payment is wired up.
class FeatureFlags {
  FeatureFlags._();
  static final FeatureFlags instance = FeatureFlags._();

  bool isPro = true;

  bool get pdfAdvancedOptions => isPro;
  bool get proMode => isPro;
}
