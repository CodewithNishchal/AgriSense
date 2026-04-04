/// P2P identity branch (no backend — persisted locally).
enum UserRole {
  farmer('Farmer', 'Borrower · scan · rent equipment'),
  lender('Equipment owner', 'Lend fleet · revenue · telematics');

  const UserRole(this.label, this.subtitle);

  final String label;
  final String subtitle;

  static UserRole fromStorage(String? value) {
    if (value == lender.name) return lender;
    return farmer;
  }
}
