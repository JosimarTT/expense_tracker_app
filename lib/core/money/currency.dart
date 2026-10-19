class Currency {
  const Currency(this.code, this.name, this.scale, this.searchAliases);

  final String code;
  final String name;
  final int scale;
  final String searchAliases;

  bool matches(String query) => '$code $name $searchAliases'
      .toLowerCase()
      .contains(query.trim().toLowerCase());

  static const supported = [
    Currency('ARS', 'Argentine peso', 2, 'Argentina'),
    Currency('AUD', 'Australian dollar', 2, 'Australia'),
    Currency('BHD', 'Bahraini dinar', 3, 'Bahrain'),
    Currency('BRL', 'Brazilian real', 2, 'Brazil Brasil'),
    Currency('CAD', 'Canadian dollar', 2, 'Canada'),
    Currency('CHF', 'Swiss franc', 2, 'Switzerland'),
    Currency('CLP', 'Chilean peso', 0, 'Chile'),
    Currency('CNY', 'Chinese yuan', 2, 'China renminbi'),
    Currency('COP', 'Colombian peso', 2, 'Colombia'),
    Currency('EUR', 'Euro', 2, 'Eurozone Europe'),
    Currency('GBP', 'British pound', 2, 'United Kingdom UK Britain'),
    Currency('INR', 'Indian rupee', 2, 'India'),
    Currency('JPY', 'Japanese yen', 0, 'Japan'),
    Currency('KRW', 'South Korean won', 0, 'South Korea'),
    Currency('KWD', 'Kuwaiti dinar', 3, 'Kuwait'),
    Currency('MXN', 'Mexican peso', 2, 'Mexico'),
    Currency('PEN', 'Peruvian sol', 2, 'Peru soles'),
    Currency('USD', 'US dollar', 2, 'United States USA'),
  ];

  static Currency fromCode(String code) => supported.firstWhere(
    (currency) => currency.code == code,
    orElse: () => throw ArgumentError.value(
      code,
      'currencyCode',
      'Unsupported currency.',
    ),
  );
}
