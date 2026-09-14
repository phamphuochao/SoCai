class PaginationConstants {
  const PaginationConstants._();

  static const pageSize = 20;
  static const fetchSize = pageSize + 1;

  static int offsetFor(int page) => (page - 1) * pageSize;
}
