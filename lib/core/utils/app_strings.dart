abstract final class AppStrings {
  // ── App ──────────────────────────────────────────────────────────────────
  static const String appName = 'Personal Analyzer';
  static const String appTagline = 'Track • Analyze • Grow';

  // ── Splash ───────────────────────────────────────────────────────────────
  static const String unlockButton = 'Unlock';
  static const String accessDeniedTitle = 'Access Denied';
  static const String accessDeniedMessage = 'Authentication failed';

  // ── Auth — Login ──────────────────────────────────────────────────────────
  static const String loginTitle = 'Welcome\nBack';
  static const String loginSubtitle = 'Continue your growth journey';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String loginButton = 'Sign In';
  static const String noAccountPrompt = "Don't have an account? ";
  static const String signUpLink = 'Sign Up';
  static const String welcomeBackSnackbar = 'Welcome back!';
  static const String loginFailedTitle = 'Login Failed';
  static const String loginErrorMessage = 'An unexpected error occurred.';

  // ── Auth — Register ───────────────────────────────────────────────────────
  static const String registerTitle = 'Create\nAccount';
  static const String registerSubtitle = 'Start tracking your progress today';
  static const String registerButton = 'Create Account';
  static const String alreadyHaveAccount = 'Already have an account? ';
  static const String signInLink = 'Sign In';
  static const String accountCreatedTitle = 'Account created!';
  static const String accountCreatedMessage = 'Welcome to Analyzer';
  static const String registrationFailedTitle = 'Registration Failed';
  static const String registrationErrorMessage =
      'Registration failed. Please try again.';
  static const String fullName = 'Full Name';
  static const String confirmPassword = 'Confirm Password';

  // ── Auth — Parameter Setup ────────────────────────────────────────────────
  static const String paramSetupTitle = 'Setup Parameters';
  static const String paramSetupDoneButton = 'Done';
  static const String paramSetupEmptyTitle = 'No parameters added yet.';
  static const String paramSetupEmptyMessage =
      'Create your first parameter to start tracking your progress';
  static const String addParameterButton = 'Add Parameter';
  static const String paramAddedTitle = 'Success';
  static const String paramAddedMessage = 'Parameter added successfully';
  static const String paramUpdatedTitle = 'Success';
  static const String paramUpdatedMessage = 'Parameter updated successfully';

  // ── Home ─────────────────────────────────────────────────────────────────
  static const String homeGreeting = 'Hello,';
  static const String homeWelcome = 'Welcome Back';
  static const String yourHabits = 'Your Habits';
  static const String todayProgress = "Today's Progress";
  static const String progress = 'Progress';
  static const String todayBadge = 'Today';
  static const String noParametersForDay = 'No Parameters For This Day';
  static const String enterValue = 'Enter value';
  static const String home = 'Home';
  static const String analytics = 'Analytics';
  static const String profile = 'Profile';

  // ── Analytics ────────────────────────────────────────────────────────────
  static const String analyticsTitle = 'Analytics';
  static const String analyticsSubtitle = 'Your habit insights';
  static const String completionTrend = 'Completion Trend';
  static const String avg = 'Avg';
  static const String noDataYet = 'No data yet';
  static const String activityHeatmap = 'Activity Heatmap';
  static const String last90Days = 'Last 90 days';
  static const String less = 'Less';
  static const String more = 'More';
  static const String monthlyComparison = 'Monthly Comparison';
  static const String thisMonth = 'This Month';
  static const String overallAvg = 'Overall Avg';
  static const String overview = 'Overview';
  static const String activeHabits = 'Active Habits';
  static const String completion = 'Completion';
  static const String bestStreak = 'Best Streak';
  static const String trackedDays = 'Tracked Days';
  static const String score = 'Score';
  static const String streak = 'Streak';
  static const String best = 'Best';
  static const String active = 'Active';
  static const String topPerformers = 'Top Performers';
  static const String week = 'Week';
  static const String weekdayBreakdown = 'Weekday Breakdown';
  static const String weeklySummary = 'Weekly Summary';
  static const String completed = 'completed';
  
  

  // ── Manage Habits ─────────────────────────────────────────────────────────
  static const String manageHabitsTitle = 'Manage Habits';
  static const String manageAddButton = 'Add';
  static const String manageNoHabitsTitle = 'No habits yet';
  static const String manageNoHabitsSubtitle =
      'Tap "Add" to create your first habit';
  static const String activeHabitsSection = 'Active Habits';
  static const String inactiveHabitsSection = 'Inactive Habits';
  static const String habitAddedTitle = 'Habit Added';
  static const String habitUpdatedTitle = 'Habit Updated';
  static const String deleteHabitDialogTitle = 'Delete Habit?';
  static const String deleteHabitDialogBody =
      'will be permanently deleted. This cannot be undone.';
  static const String cancelButton = 'Cancel';
  static const String deleteButton = 'Delete';
  static const String signOutButton = 'Sign Out';
  static const String signOutMessage = 'Are you sure you want to sign out?';

  // ── Profile ───────────────────────────────────────────────────────────────
  static const String profileTitle = 'Profile';
  static const String habitsTitle = 'Habits';
  static const String manageHabitsRow = 'Manage Habits';
  static const String manageHabitsSubtitle = 'Add, delete, enable/disable';
  static const String dataTitle = 'Data';
  static const String exportCsvRow = 'Export as CSV';
  static const String exportCsvSubtitle = 'Share habit history spreadsheet';
  static const String exportPdfRow = 'Share Full Report';
  static const String exportPdfSubtitle = 'PDF with all data, habits & graphs';
  static const String accountTitle = 'Account';
  static const String changeNameRow = 'Change Name';
  static const String securityTitle = 'Security';
  static const String appLockRow = 'App Lock';
  static const String appLockSubtitle =
      'Use fingerprint, face or device password';
  static const String appLockEnabledTitle = 'App Lock Enabled';
  static const String appLockEnabledMessage =
      'App will require authentication on launch.';
  static const String appLockDisabledTitle = 'App Lock Disabled';
  static const String appLockDisabledMessage = 'App lock has been turned off.';
  static const String exportFailedTitle = 'Export Failed';
  static const String exportFailedMessage =
      'Could not export. Please try again.';
  static const String changeNameDialogTitle = 'Change Name';
  static const String changeNameHint = 'Enter your name';
  static const String syncErrorTitle = 'Sync Error';
  static const String logoutErrorMessage = 'Logout failed. Please try again.';
  static const String saveButton = 'Save';

  // ── Weekly motivation labels (shown in WeeklySummaryCard) ─────────────────
  /// Returns the motivation label for a given [percentage] (0.0–1.0).
  static String weeklyMotivation(double percentage) {
    if (percentage >= 0.9) return 'Incredible week! 🔥';
    if (percentage >= 0.7) return 'Great consistency! 💪';
    if (percentage >= 0.5) return 'Good effort, keep going!';
    if (percentage > 0) return 'Room to improve 📈';
    return 'Start building habits!';
  }

  // ── Export / Share ─────────────────────────────────────────────────────────
  static const String exportCsvShareText = 'Analyzer — Habit Data Export';
  static const String exportPdfShareText = 'Analyzer — Full Report';

  // ── Generic ──────────────────────────────────────────────────────────────
  static const String errorTitle = 'Error';
  static const String unexpectedError = 'Something went wrong.';
}
