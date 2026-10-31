class AppStrings {
  static const String appName = 'Horizon Travel';
  static const String appTagline = 'Your Gateway to Endless Journeys';

  // Roles
  static const String roleTourist = 'Tourist';
  static const String roleGuide = 'Tour Guide';
  static const String roleProvider = 'Service Provider';
  static const String roleAdmin = 'Administrator';

  // Common labels & buttons
  static const String loading = 'Loading…';
  static const String retry = 'Retry';
  static const String cancel = 'Cancel';
  static const String save = 'Save';
  static const String saveChanges = 'Save Changes';
  static const String submit = 'Submit';
  static const String close = 'Close';
  static const String logout = 'Logout';
  static const String confirmLogout = 'Are you sure you want to log out?';
  static const String ok = 'OK';
  static const String yes = 'Yes';
  static const String no = 'No';
  static const String notifications = 'Notifications';
  static const String changePassword = 'Change Password';

  // Error messages
  static const String errorNetwork = 'Unable to connect to server. Please check your network connection.';
  static const String errorTimeout = 'Request timed out. Please try again.';
  static const String errorSessionExpired = 'Session expired. Please log in again.';
  static const String errorAccountLocked = 'Account is locked. Please contact support.';
  static const String errorGeneric = 'An unexpected error occurred. Please try again.';
  static const String errorFieldRequired = 'This field is required';
  static const String errorInvalidEmail = 'Please enter a valid email address';
  static const String errorPasswordTooShort = 'Password must be at least 6 characters';
  static const String errorPasswordsDoNotMatch = 'Passwords do not match';
  static const String errorBadCredentials = 'Invalid email or password';

  // Auth & Titles
  static const String titleLogin = 'Login';
  static const String loginSubtitle = 'Welcome back! Sign in to continue.';
  static const String emailHint = 'Email Address';
  static const String passwordHint = 'Password';
  static const String signIn = 'Sign In';
  static const String register = 'Register';
  static const String dontHaveAccount = "Don't have an account? ";
  static const String forgotPassword = 'Forgot Password?';
  static const String chooseRoleTitle = 'Create an Account';
  static const String chooseRoleSubtitle = 'Select how you would like to use Horizon Travel';
  static const String adminAccountNote = 'Administrator accounts are provisioned by system administration.';

  // Status & Verification
  static const String statusAwaitingTitle = 'Application Under Review';
  static const String statusAwaitingDesc = 'Your account is currently awaiting administrator verification. You will be able to access all features once your profile is verified.';
  static const String statusRejectedTitle = 'Application Rejected';
  static const String statusSuspendedTitle = 'Account Suspended';
  static const String statusSuspendedDesc = 'Your account has been suspended by an administrator.';
  static const String statusRevokedTitle = 'Access Revoked';
  static const String statusRevokedDesc = 'Your account access has been revoked.';
  static const String refreshStatus = 'Refresh Status';

  // Tourist
  static const String touristHomeGreeting = 'Hello, %s!';
  static const String touristPointsBalance = 'Loyalty Points: %d pts';
  static const String exploreServices = 'Explore Services';
  static const String myBookings = 'My Bookings';
  static const String myPortal = 'My Portal';
  static const String cart = 'Cart';
  static const String checkout = 'Checkout';
  static const String addToCart = 'Add to Cart';
  static const String bookNow = 'Book Now';
  static const String payNow = 'Pay Now';
  static const String rateService = 'Rate Service';
  static const String rateGuide = 'Rate Guide';
  static const String downloadReport = 'Download Bookings Report';
  static const String trackLocation = 'Track Live Location';
  static const String aiConcierge = 'AI Concierge';

  // Guide
  static const String guideDashboard = 'Dashboard';
  static const String guideAvailability = 'Availability';
  static const String guideRequests = 'Requests';
  static const String guideProfile = 'Profile';
  static const String gpsBroadcast = 'GPS Location Broadcast';
  static const String gpsBroadcastDesc = 'Pulse your current location to travelers with active bookings';
  static const String markPaymentReceived = 'Mark Payment Received';

  // Provider
  static const String providerDashboard = 'Dashboard';
  static const String providerSlots = 'Slots';
  static const String providerLedger = 'Ledger';
  static const String providerProfile = 'Profile';
  static const String createSlot = 'Create Slot';
  static const String editSlot = 'Edit Slot';
  static const String bookingLookup = 'Booking ID Payment Lookup';

  // Admin
  static const String adminVerifications = 'Verifications';
  static const String adminUsers = 'Users';
  static const String adminFinance = 'Finance';
  static const String adminReports = 'Reports';
  static const String approve = 'Approve';
  static const String reject = 'Reject';
  static const String settle = 'Settle';
}
