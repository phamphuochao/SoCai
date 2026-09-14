// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appName => 'RetailManager';

  @override
  String get appSubtitle => 'Quản lý doanh thu cửa hàng bán lẻ';

  @override
  String get language => 'Ngôn ngữ';

  @override
  String get vietnamese => 'Tiếng Việt';

  @override
  String get english => 'English';

  @override
  String get dashboard => 'Tổng quan';

  @override
  String get sales => 'Bán hàng';

  @override
  String get invoices => 'Hóa đơn';

  @override
  String get products => 'Sản phẩm';

  @override
  String get inventory => 'Kho hàng';

  @override
  String get expenses => 'Chi phí';

  @override
  String get reports => 'Báo cáo';

  @override
  String get logout => 'Đăng xuất';

  @override
  String get adminRole => 'Quản trị viên';

  @override
  String get staffRole => 'Nhân viên';

  @override
  String get genericError => 'Không thể tải dữ liệu. Vui lòng thử lại.';

  @override
  String get loadingData => 'Đang tải dữ liệu...';

  @override
  String get noData => 'Chưa có dữ liệu.';

  @override
  String get retry => 'Thử lại';

  @override
  String get close => 'Đóng';

  @override
  String get closeNotification => 'Đóng thông báo';

  @override
  String get confirm => 'Xác nhận';

  @override
  String get save => 'Lưu';

  @override
  String get saving => 'Đang lưu...';

  @override
  String get cancel => 'Hủy';

  @override
  String get select => 'Chọn';

  @override
  String get selectDate => 'Chọn ngày';

  @override
  String get fromDate => 'Từ ngày';

  @override
  String get toDate => 'Đến ngày';

  @override
  String get filter => 'Lọc';

  @override
  String get search => 'Tìm kiếm';

  @override
  String get all => 'Tất cả';

  @override
  String get status => 'Trạng thái';

  @override
  String get date => 'Ngày';

  @override
  String get time => 'Thời gian';

  @override
  String get product => 'Sản phẩm';

  @override
  String get category => 'Danh mục';

  @override
  String get amount => 'Số tiền';

  @override
  String get notes => 'Ghi chú';

  @override
  String get action => 'Thao tác';

  @override
  String get type => 'Loại';

  @override
  String get change => 'Thay đổi';

  @override
  String get completed => 'Hoàn tất';

  @override
  String get cancelled => 'Đã hủy';

  @override
  String get edit => 'Sửa';

  @override
  String get back => 'Quay lại';

  @override
  String get welcomeBack => 'Chào mừng trở lại';

  @override
  String get loginSubtitle => 'Đăng nhập để tiếp tục sử dụng hệ thống.';

  @override
  String get username => 'Tên đăng nhập';

  @override
  String get password => 'Mật khẩu';

  @override
  String get login => 'Đăng nhập';

  @override
  String get demoAccount => 'Tài khoản demo: admin / admin123';

  @override
  String get loginHeroTitle => 'Tất cả trong tầm tay';

  @override
  String get loginHeroSubtitle =>
      'Quản lý sản phẩm, bán hàng, kho và theo dõi doanh thu dễ dàng.';

  @override
  String get storeIllustration => 'Minh họa cửa hàng bán lẻ';

  @override
  String welcomeUser(String name) {
    return 'Chào mừng trở lại, $name!';
  }

  @override
  String get revenueToday => 'Doanh thu hôm nay';

  @override
  String get netRevenue => 'Doanh thu thuần';

  @override
  String get grossProfit => 'Lợi nhuận gộp';

  @override
  String get netProfit => 'Lợi nhuận ròng';

  @override
  String get invoiceCount => 'Số hóa đơn';

  @override
  String get lowStockProducts => 'Sản phẩm sắp hết';

  @override
  String get revenueLastSevenDays => 'Doanh thu 7 ngày gần nhất';

  @override
  String get dailyRevenue => 'Doanh thu theo ngày';

  @override
  String get topProducts => 'Sản phẩm bán chạy';

  @override
  String get noSalesInRange => 'Chưa có doanh số trong khoảng này.';

  @override
  String productQuantity(int count) {
    return '$count sản phẩm';
  }

  @override
  String highestAmount(String amount) {
    return 'Cao nhất $amount';
  }

  @override
  String get productsSubtitle =>
      'Tra cứu giá bán, tồn kho và trạng thái kinh doanh.';

  @override
  String get addProduct => 'Thêm sản phẩm';

  @override
  String get searchNameOrSku => 'Tìm theo tên hoặc SKU';

  @override
  String get allStatuses => 'Tất cả trạng thái';

  @override
  String get activeProducts => 'Đang bán';

  @override
  String get inactiveProducts => 'Ngừng bán';

  @override
  String get lowStock => 'Sắp hết';

  @override
  String get inStock => 'Đủ hàng';

  @override
  String get allCategories => 'Tất cả danh mục';

  @override
  String get noMatchingProducts => 'Không tìm thấy sản phẩm phù hợp.';

  @override
  String get uncategorized => 'Chưa phân loại';

  @override
  String get productCode => 'Mã';

  @override
  String get productName => 'Tên sản phẩm';

  @override
  String get sellingPrice => 'Giá bán';

  @override
  String get stock => 'Tồn kho';

  @override
  String stockValue(int count) {
    return 'Tồn $count';
  }

  @override
  String get stopSelling => 'Ngừng bán';

  @override
  String get stopProductTitle => 'Ngừng bán sản phẩm';

  @override
  String stopProductPrompt(String name) {
    return 'Bạn muốn ngừng bán “$name”? Dữ liệu hóa đơn cũ vẫn được giữ.';
  }

  @override
  String stopProductSuccess(String name) {
    return 'Đã ngừng bán $name.';
  }

  @override
  String get editProduct => 'Chỉnh sửa sản phẩm';

  @override
  String get createProduct => 'Thêm sản phẩm';

  @override
  String get adminOnlyProducts => 'Chỉ quản trị viên được thay đổi sản phẩm.';

  @override
  String get sku => 'SKU';

  @override
  String get costPrice => 'Giá vốn';

  @override
  String get initialStock => 'Tồn kho ban đầu';

  @override
  String get lowStockThreshold => 'Ngưỡng sắp hết';

  @override
  String get saveProduct => 'Lưu sản phẩm';

  @override
  String get productUpdated => 'Đã cập nhật sản phẩm.';

  @override
  String get productCreated => 'Đã tạo sản phẩm.';

  @override
  String get salesSubtitle => 'Chọn sản phẩm và tạo hóa đơn nhiều mặt hàng.';

  @override
  String get productList => 'Sản phẩm';

  @override
  String get noActiveProducts => 'Không có sản phẩm đang bán.';

  @override
  String get addToCart => 'Thêm vào giỏ';

  @override
  String get cartStockLimit => 'Số lượng trong giỏ đã bằng tồn kho hiện tại.';

  @override
  String get invoiceCart => 'Hóa đơn';

  @override
  String get clearAll => 'Xóa tất cả';

  @override
  String get emptyCart => 'Giỏ hàng đang trống.';

  @override
  String get customerOptional => 'Tên khách hàng (không bắt buộc)';

  @override
  String get discount => 'Giảm giá';

  @override
  String get paymentMethod => 'Phương thức thanh toán';

  @override
  String get cash => 'Tiền mặt';

  @override
  String get bankTransfer => 'Chuyển khoản';

  @override
  String get card => 'Thẻ';

  @override
  String get estimatedSubtotal => 'Tạm tính dự kiến';

  @override
  String get paymentConfirmationNote =>
      'Số tiền thanh toán sẽ được xác nhận khi tạo hóa đơn.';

  @override
  String get checkout => 'Thanh toán';

  @override
  String get addAtLeastOneProduct => 'Hãy thêm ít nhất một sản phẩm.';

  @override
  String get discountMustNotBeNegative => 'Giảm giá phải là số không âm.';

  @override
  String invoiceCreated(String code, String total) {
    return 'Đã tạo hóa đơn $code với tổng $total.';
  }

  @override
  String get invoicesSubtitle =>
      'Tra cứu và xem chi tiết từng hóa đơn bán hàng.';

  @override
  String get createInvoice => 'Tạo hóa đơn';

  @override
  String get invoiceCode => 'Mã hóa đơn';

  @override
  String get noMatchingInvoices => 'Không có hóa đơn phù hợp.';

  @override
  String get staff => 'Nhân viên';

  @override
  String get payment => 'Thanh toán';

  @override
  String get invoiceList => 'Danh sách hóa đơn';

  @override
  String get cancelInvoice => 'Hủy hóa đơn';

  @override
  String get cancelInvoicePrompt =>
      'Hệ thống sẽ đổi trạng thái hóa đơn và hoàn lại tồn kho đúng một lần.';

  @override
  String get invoiceCancelled => 'Đã hủy hóa đơn và hoàn kho.';

  @override
  String createdAt(String date) {
    return 'Tạo lúc $date';
  }

  @override
  String get customer => 'Khách hàng';

  @override
  String get walkInCustomer => 'Khách lẻ';

  @override
  String get quantity => 'Số lượng';

  @override
  String get unitPrice => 'Đơn giá';

  @override
  String get lineTotal => 'Thành tiền';

  @override
  String get subtotal => 'Tạm tính';

  @override
  String get grandTotal => 'Tổng cộng';

  @override
  String productNumber(int id) {
    return 'Sản phẩm #$id';
  }

  @override
  String get inventorySubtitle =>
      'Tồn kho hiện tại và cảnh báo theo ngưỡng sản phẩm.';

  @override
  String get inventoryHistory => 'Lịch sử kho';

  @override
  String get importOrAdjust => 'Nhập / điều chỉnh';

  @override
  String get noInventoryProducts => 'Chưa có sản phẩm trong kho.';

  @override
  String get currentStock => 'Tồn hiện tại';

  @override
  String get warningThreshold => 'Ngưỡng cảnh báo';

  @override
  String thresholdValue(int value) {
    return 'Ngưỡng $value';
  }

  @override
  String get updateInventory => 'Cập nhật tồn kho';

  @override
  String get operationType => 'Loại thao tác';

  @override
  String get importStock => 'Nhập thêm hàng';

  @override
  String get inventoryAdjustment => 'Điều chỉnh kiểm kê';

  @override
  String get importQuantity => 'Số lượng nhập';

  @override
  String get quantityChange => 'Số thay đổi (+/-)';

  @override
  String get importQuantityPositive => 'Số lượng nhập phải lớn hơn 0.';

  @override
  String get adjustmentNonZero => 'Số điều chỉnh phải khác 0.';

  @override
  String get inventoryHistorySubtitle =>
      'Mỗi thay đổi tồn kho đều có bản ghi truy vết.';

  @override
  String get currentInventory => 'Kho hiện tại';

  @override
  String get filterByProduct => 'Lọc theo sản phẩm';

  @override
  String get allProducts => 'Tất cả sản phẩm';

  @override
  String get noInventoryTransactions => 'Chưa có giao dịch kho.';

  @override
  String get transactionImport => 'Nhập hàng';

  @override
  String get transactionAdjustment => 'Điều chỉnh';

  @override
  String get transactionSale => 'Bán hàng';

  @override
  String get transactionReturn => 'Hoàn hàng';

  @override
  String get expensesSubtitle =>
      'Theo dõi các khoản chi để tính lợi nhuận ròng chính xác.';

  @override
  String get addExpense => 'Thêm chi phí';

  @override
  String totalValue(String amount) {
    return 'Tổng: $amount';
  }

  @override
  String pageTotalValue(String amount) {
    return 'Tổng trang: $amount';
  }

  @override
  String get noExpensesInRange => 'Chưa có chi phí trong khoảng này.';

  @override
  String get expenseType => 'Loại chi phí';

  @override
  String get expenseDate => 'Ngày chi';

  @override
  String get invalidExpense => 'Nhập loại chi phí và số tiền lớn hơn 0.';

  @override
  String get expenseCreated => 'Đã thêm chi phí.';

  @override
  String get reportsSubtitle =>
      'Tổng hợp doanh thu và lợi nhuận theo thời gian đã chọn.';

  @override
  String get viewReport => 'Xem báo cáo';

  @override
  String get averageOrderValue => 'Giá trị đơn TB';

  @override
  String get previousPage => 'Trang trước';

  @override
  String get nextPage => 'Trang sau';

  @override
  String pageNumber(int page) {
    return 'Trang $page';
  }

  @override
  String get pageNotFound => 'Trang bạn mở không tồn tại.';

  @override
  String get backToDashboard => 'Về Tổng quan';

  @override
  String fieldRequired(String field) {
    return '$field không được để trống';
  }

  @override
  String mustBeNumber(String field) {
    return '$field phải là số';
  }

  @override
  String mustNotBeNegative(String field) {
    return '$field không được âm';
  }

  @override
  String mustBePositive(String field) {
    return '$field phải lớn hơn 0';
  }
}
