enum StorageKey {
  email('user_email'),
  password('user_password'),
  phoneNumber('user_phone'),
  country('user_country'),
  role('role'),
  name('user_name'),
  lastLoginDetais('lastLoginDate'),

  imagePath('user_image_path'),
  accessToken('access_token'),
  refreshToken('refresh_token'),
  paymentToken('payment_token'),
  userId('userId'),
  userSessionID('userSessionID'),
  profileId('profile_id'),
  companyID('companyID');

  const StorageKey(this.key);
  final String key;
}
