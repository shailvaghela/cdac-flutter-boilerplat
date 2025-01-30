class AppStrings {
  static const appName = 'My Flutter App';
  static const welcomeMessage = 'Welcome to the app!';
  static const namePattern = r"^[a-zA-Z\s'-]+$";
  static const addressPattern = r'^[a-zA-Z0-9\s,.-/#]+$';
  static const auth = 'auth';
  static const api = 'api';
  static const apiAuth = 'api/auth';
  static const encryptkeyProd  = 'GbnABQpf5TtSrktt5uBlGZEA';
  static const encryptDebug = "your-global-security-key";

  static const registerEndpoint = '/auth/register';
  static const loginEndpoint = '/auth/login';
  static const logoutEndpoint = '/api/auth/logout';

  static const addressHelpText =  'The address field should contain your full address with the following rules:\n\n'
      '- Only letters, numbers, spaces, commas, periods, hyphens, and slashes are allowed.\n'
      '- The maximum length of the address is 255 characters.\n\n'
      'Please ensure that the address is formatted correctly.';
  static const addressTag = 'Address Field Help';
}