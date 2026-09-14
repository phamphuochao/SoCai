import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi'),
  ];

  /// No description provided for @appName.
  ///
  /// In vi, this message translates to:
  /// **'RetailManager'**
  String get appName;

  /// No description provided for @appSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Quản lý doanh thu cửa hàng bán lẻ'**
  String get appSubtitle;

  /// No description provided for @language.
  ///
  /// In vi, this message translates to:
  /// **'Ngôn ngữ'**
  String get language;

  /// No description provided for @vietnamese.
  ///
  /// In vi, this message translates to:
  /// **'Tiếng Việt'**
  String get vietnamese;

  /// No description provided for @english.
  ///
  /// In vi, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @dashboard.
  ///
  /// In vi, this message translates to:
  /// **'Tổng quan'**
  String get dashboard;

  /// No description provided for @sales.
  ///
  /// In vi, this message translates to:
  /// **'Bán hàng'**
  String get sales;

  /// No description provided for @invoices.
  ///
  /// In vi, this message translates to:
  /// **'Hóa đơn'**
  String get invoices;

  /// No description provided for @products.
  ///
  /// In vi, this message translates to:
  /// **'Sản phẩm'**
  String get products;

  /// No description provided for @inventory.
  ///
  /// In vi, this message translates to:
  /// **'Kho hàng'**
  String get inventory;

  /// No description provided for @expenses.
  ///
  /// In vi, this message translates to:
  /// **'Chi phí'**
  String get expenses;

  /// No description provided for @reports.
  ///
  /// In vi, this message translates to:
  /// **'Báo cáo'**
  String get reports;

  /// No description provided for @logout.
  ///
  /// In vi, this message translates to:
  /// **'Đăng xuất'**
  String get logout;

  /// No description provided for @adminRole.
  ///
  /// In vi, this message translates to:
  /// **'Quản trị viên'**
  String get adminRole;

  /// No description provided for @staffRole.
  ///
  /// In vi, this message translates to:
  /// **'Nhân viên'**
  String get staffRole;

  /// No description provided for @genericError.
  ///
  /// In vi, this message translates to:
  /// **'Không thể tải dữ liệu. Vui lòng thử lại.'**
  String get genericError;

  /// No description provided for @loadingData.
  ///
  /// In vi, this message translates to:
  /// **'Đang tải dữ liệu...'**
  String get loadingData;

  /// No description provided for @noData.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có dữ liệu.'**
  String get noData;

  /// No description provided for @retry.
  ///
  /// In vi, this message translates to:
  /// **'Thử lại'**
  String get retry;

  /// No description provided for @close.
  ///
  /// In vi, this message translates to:
  /// **'Đóng'**
  String get close;

  /// No description provided for @closeNotification.
  ///
  /// In vi, this message translates to:
  /// **'Đóng thông báo'**
  String get closeNotification;

  /// No description provided for @confirm.
  ///
  /// In vi, this message translates to:
  /// **'Xác nhận'**
  String get confirm;

  /// No description provided for @save.
  ///
  /// In vi, this message translates to:
  /// **'Lưu'**
  String get save;

  /// No description provided for @saving.
  ///
  /// In vi, this message translates to:
  /// **'Đang lưu...'**
  String get saving;

  /// No description provided for @cancel.
  ///
  /// In vi, this message translates to:
  /// **'Hủy'**
  String get cancel;

  /// No description provided for @select.
  ///
  /// In vi, this message translates to:
  /// **'Chọn'**
  String get select;

  /// No description provided for @selectDate.
  ///
  /// In vi, this message translates to:
  /// **'Chọn ngày'**
  String get selectDate;

  /// No description provided for @fromDate.
  ///
  /// In vi, this message translates to:
  /// **'Từ ngày'**
  String get fromDate;

  /// No description provided for @toDate.
  ///
  /// In vi, this message translates to:
  /// **'Đến ngày'**
  String get toDate;

  /// No description provided for @filter.
  ///
  /// In vi, this message translates to:
  /// **'Lọc'**
  String get filter;

  /// No description provided for @search.
  ///
  /// In vi, this message translates to:
  /// **'Tìm kiếm'**
  String get search;

  /// No description provided for @all.
  ///
  /// In vi, this message translates to:
  /// **'Tất cả'**
  String get all;

  /// No description provided for @status.
  ///
  /// In vi, this message translates to:
  /// **'Trạng thái'**
  String get status;

  /// No description provided for @date.
  ///
  /// In vi, this message translates to:
  /// **'Ngày'**
  String get date;

  /// No description provided for @time.
  ///
  /// In vi, this message translates to:
  /// **'Thời gian'**
  String get time;

  /// No description provided for @product.
  ///
  /// In vi, this message translates to:
  /// **'Sản phẩm'**
  String get product;

  /// No description provided for @category.
  ///
  /// In vi, this message translates to:
  /// **'Danh mục'**
  String get category;

  /// No description provided for @amount.
  ///
  /// In vi, this message translates to:
  /// **'Số tiền'**
  String get amount;

  /// No description provided for @notes.
  ///
  /// In vi, this message translates to:
  /// **'Ghi chú'**
  String get notes;

  /// No description provided for @action.
  ///
  /// In vi, this message translates to:
  /// **'Thao tác'**
  String get action;

  /// No description provided for @type.
  ///
  /// In vi, this message translates to:
  /// **'Loại'**
  String get type;

  /// No description provided for @change.
  ///
  /// In vi, this message translates to:
  /// **'Thay đổi'**
  String get change;

  /// No description provided for @completed.
  ///
  /// In vi, this message translates to:
  /// **'Hoàn tất'**
  String get completed;

  /// No description provided for @cancelled.
  ///
  /// In vi, this message translates to:
  /// **'Đã hủy'**
  String get cancelled;

  /// No description provided for @edit.
  ///
  /// In vi, this message translates to:
  /// **'Sửa'**
  String get edit;

  /// No description provided for @back.
  ///
  /// In vi, this message translates to:
  /// **'Quay lại'**
  String get back;

  /// No description provided for @welcomeBack.
  ///
  /// In vi, this message translates to:
  /// **'Chào mừng trở lại'**
  String get welcomeBack;

  /// No description provided for @loginSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Đăng nhập để tiếp tục sử dụng hệ thống.'**
  String get loginSubtitle;

  /// No description provided for @username.
  ///
  /// In vi, this message translates to:
  /// **'Tên đăng nhập'**
  String get username;

  /// No description provided for @password.
  ///
  /// In vi, this message translates to:
  /// **'Mật khẩu'**
  String get password;

  /// No description provided for @login.
  ///
  /// In vi, this message translates to:
  /// **'Đăng nhập'**
  String get login;

  /// No description provided for @demoAccount.
  ///
  /// In vi, this message translates to:
  /// **'Tài khoản demo: admin / admin123'**
  String get demoAccount;

  /// No description provided for @loginHeroTitle.
  ///
  /// In vi, this message translates to:
  /// **'Tất cả trong tầm tay'**
  String get loginHeroTitle;

  /// No description provided for @loginHeroSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Quản lý sản phẩm, bán hàng, kho và theo dõi doanh thu dễ dàng.'**
  String get loginHeroSubtitle;

  /// No description provided for @storeIllustration.
  ///
  /// In vi, this message translates to:
  /// **'Minh họa cửa hàng bán lẻ'**
  String get storeIllustration;

  /// No description provided for @welcomeUser.
  ///
  /// In vi, this message translates to:
  /// **'Chào mừng trở lại, {name}!'**
  String welcomeUser(String name);

  /// No description provided for @revenueToday.
  ///
  /// In vi, this message translates to:
  /// **'Doanh thu hôm nay'**
  String get revenueToday;

  /// No description provided for @netRevenue.
  ///
  /// In vi, this message translates to:
  /// **'Doanh thu thuần'**
  String get netRevenue;

  /// No description provided for @grossProfit.
  ///
  /// In vi, this message translates to:
  /// **'Lợi nhuận gộp'**
  String get grossProfit;

  /// No description provided for @netProfit.
  ///
  /// In vi, this message translates to:
  /// **'Lợi nhuận ròng'**
  String get netProfit;

  /// No description provided for @invoiceCount.
  ///
  /// In vi, this message translates to:
  /// **'Số hóa đơn'**
  String get invoiceCount;

  /// No description provided for @lowStockProducts.
  ///
  /// In vi, this message translates to:
  /// **'Sản phẩm sắp hết'**
  String get lowStockProducts;

  /// No description provided for @revenueLastSevenDays.
  ///
  /// In vi, this message translates to:
  /// **'Doanh thu 7 ngày gần nhất'**
  String get revenueLastSevenDays;

  /// No description provided for @dailyRevenue.
  ///
  /// In vi, this message translates to:
  /// **'Doanh thu theo ngày'**
  String get dailyRevenue;

  /// No description provided for @topProducts.
  ///
  /// In vi, this message translates to:
  /// **'Sản phẩm bán chạy'**
  String get topProducts;

  /// No description provided for @noSalesInRange.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có doanh số trong khoảng này.'**
  String get noSalesInRange;

  /// No description provided for @productQuantity.
  ///
  /// In vi, this message translates to:
  /// **'{count} sản phẩm'**
  String productQuantity(int count);

  /// No description provided for @highestAmount.
  ///
  /// In vi, this message translates to:
  /// **'Cao nhất {amount}'**
  String highestAmount(String amount);

  /// No description provided for @productsSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Tra cứu giá bán, tồn kho và trạng thái kinh doanh.'**
  String get productsSubtitle;

  /// No description provided for @addProduct.
  ///
  /// In vi, this message translates to:
  /// **'Thêm sản phẩm'**
  String get addProduct;

  /// No description provided for @searchNameOrSku.
  ///
  /// In vi, this message translates to:
  /// **'Tìm theo tên hoặc SKU'**
  String get searchNameOrSku;

  /// No description provided for @allStatuses.
  ///
  /// In vi, this message translates to:
  /// **'Tất cả trạng thái'**
  String get allStatuses;

  /// No description provided for @activeProducts.
  ///
  /// In vi, this message translates to:
  /// **'Đang bán'**
  String get activeProducts;

  /// No description provided for @inactiveProducts.
  ///
  /// In vi, this message translates to:
  /// **'Ngừng bán'**
  String get inactiveProducts;

  /// No description provided for @lowStock.
  ///
  /// In vi, this message translates to:
  /// **'Sắp hết'**
  String get lowStock;

  /// No description provided for @inStock.
  ///
  /// In vi, this message translates to:
  /// **'Đủ hàng'**
  String get inStock;

  /// No description provided for @allCategories.
  ///
  /// In vi, this message translates to:
  /// **'Tất cả danh mục'**
  String get allCategories;

  /// No description provided for @noMatchingProducts.
  ///
  /// In vi, this message translates to:
  /// **'Không tìm thấy sản phẩm phù hợp.'**
  String get noMatchingProducts;

  /// No description provided for @uncategorized.
  ///
  /// In vi, this message translates to:
  /// **'Chưa phân loại'**
  String get uncategorized;

  /// No description provided for @productCode.
  ///
  /// In vi, this message translates to:
  /// **'Mã'**
  String get productCode;

  /// No description provided for @productName.
  ///
  /// In vi, this message translates to:
  /// **'Tên sản phẩm'**
  String get productName;

  /// No description provided for @sellingPrice.
  ///
  /// In vi, this message translates to:
  /// **'Giá bán'**
  String get sellingPrice;

  /// No description provided for @stock.
  ///
  /// In vi, this message translates to:
  /// **'Tồn kho'**
  String get stock;

  /// No description provided for @stockValue.
  ///
  /// In vi, this message translates to:
  /// **'Tồn {count}'**
  String stockValue(int count);

  /// No description provided for @stopSelling.
  ///
  /// In vi, this message translates to:
  /// **'Ngừng bán'**
  String get stopSelling;

  /// No description provided for @stopProductTitle.
  ///
  /// In vi, this message translates to:
  /// **'Ngừng bán sản phẩm'**
  String get stopProductTitle;

  /// No description provided for @stopProductPrompt.
  ///
  /// In vi, this message translates to:
  /// **'Bạn muốn ngừng bán “{name}”? Dữ liệu hóa đơn cũ vẫn được giữ.'**
  String stopProductPrompt(String name);

  /// No description provided for @stopProductSuccess.
  ///
  /// In vi, this message translates to:
  /// **'Đã ngừng bán {name}.'**
  String stopProductSuccess(String name);

  /// No description provided for @editProduct.
  ///
  /// In vi, this message translates to:
  /// **'Chỉnh sửa sản phẩm'**
  String get editProduct;

  /// No description provided for @createProduct.
  ///
  /// In vi, this message translates to:
  /// **'Thêm sản phẩm'**
  String get createProduct;

  /// No description provided for @adminOnlyProducts.
  ///
  /// In vi, this message translates to:
  /// **'Chỉ quản trị viên được thay đổi sản phẩm.'**
  String get adminOnlyProducts;

  /// No description provided for @sku.
  ///
  /// In vi, this message translates to:
  /// **'SKU'**
  String get sku;

  /// No description provided for @costPrice.
  ///
  /// In vi, this message translates to:
  /// **'Giá vốn'**
  String get costPrice;

  /// No description provided for @initialStock.
  ///
  /// In vi, this message translates to:
  /// **'Tồn kho ban đầu'**
  String get initialStock;

  /// No description provided for @lowStockThreshold.
  ///
  /// In vi, this message translates to:
  /// **'Ngưỡng sắp hết'**
  String get lowStockThreshold;

  /// No description provided for @saveProduct.
  ///
  /// In vi, this message translates to:
  /// **'Lưu sản phẩm'**
  String get saveProduct;

  /// No description provided for @productUpdated.
  ///
  /// In vi, this message translates to:
  /// **'Đã cập nhật sản phẩm.'**
  String get productUpdated;

  /// No description provided for @productCreated.
  ///
  /// In vi, this message translates to:
  /// **'Đã tạo sản phẩm.'**
  String get productCreated;

  /// No description provided for @salesSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Chọn sản phẩm và tạo hóa đơn nhiều mặt hàng.'**
  String get salesSubtitle;

  /// No description provided for @productList.
  ///
  /// In vi, this message translates to:
  /// **'Sản phẩm'**
  String get productList;

  /// No description provided for @noActiveProducts.
  ///
  /// In vi, this message translates to:
  /// **'Không có sản phẩm đang bán.'**
  String get noActiveProducts;

  /// No description provided for @addToCart.
  ///
  /// In vi, this message translates to:
  /// **'Thêm vào giỏ'**
  String get addToCart;

  /// No description provided for @cartStockLimit.
  ///
  /// In vi, this message translates to:
  /// **'Số lượng trong giỏ đã bằng tồn kho hiện tại.'**
  String get cartStockLimit;

  /// No description provided for @invoiceCart.
  ///
  /// In vi, this message translates to:
  /// **'Hóa đơn'**
  String get invoiceCart;

  /// No description provided for @clearAll.
  ///
  /// In vi, this message translates to:
  /// **'Xóa tất cả'**
  String get clearAll;

  /// No description provided for @emptyCart.
  ///
  /// In vi, this message translates to:
  /// **'Giỏ hàng đang trống.'**
  String get emptyCart;

  /// No description provided for @customerOptional.
  ///
  /// In vi, this message translates to:
  /// **'Tên khách hàng (không bắt buộc)'**
  String get customerOptional;

  /// No description provided for @discount.
  ///
  /// In vi, this message translates to:
  /// **'Giảm giá'**
  String get discount;

  /// No description provided for @paymentMethod.
  ///
  /// In vi, this message translates to:
  /// **'Phương thức thanh toán'**
  String get paymentMethod;

  /// No description provided for @cash.
  ///
  /// In vi, this message translates to:
  /// **'Tiền mặt'**
  String get cash;

  /// No description provided for @bankTransfer.
  ///
  /// In vi, this message translates to:
  /// **'Chuyển khoản'**
  String get bankTransfer;

  /// No description provided for @card.
  ///
  /// In vi, this message translates to:
  /// **'Thẻ'**
  String get card;

  /// No description provided for @estimatedSubtotal.
  ///
  /// In vi, this message translates to:
  /// **'Tạm tính dự kiến'**
  String get estimatedSubtotal;

  /// No description provided for @paymentConfirmationNote.
  ///
  /// In vi, this message translates to:
  /// **'Số tiền thanh toán sẽ được xác nhận khi tạo hóa đơn.'**
  String get paymentConfirmationNote;

  /// No description provided for @checkout.
  ///
  /// In vi, this message translates to:
  /// **'Thanh toán'**
  String get checkout;

  /// No description provided for @addAtLeastOneProduct.
  ///
  /// In vi, this message translates to:
  /// **'Hãy thêm ít nhất một sản phẩm.'**
  String get addAtLeastOneProduct;

  /// No description provided for @discountMustNotBeNegative.
  ///
  /// In vi, this message translates to:
  /// **'Giảm giá phải là số không âm.'**
  String get discountMustNotBeNegative;

  /// No description provided for @invoiceCreated.
  ///
  /// In vi, this message translates to:
  /// **'Đã tạo hóa đơn {code} với tổng {total}.'**
  String invoiceCreated(String code, String total);

  /// No description provided for @invoicesSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Tra cứu và xem chi tiết từng hóa đơn bán hàng.'**
  String get invoicesSubtitle;

  /// No description provided for @createInvoice.
  ///
  /// In vi, this message translates to:
  /// **'Tạo hóa đơn'**
  String get createInvoice;

  /// No description provided for @invoiceCode.
  ///
  /// In vi, this message translates to:
  /// **'Mã hóa đơn'**
  String get invoiceCode;

  /// No description provided for @noMatchingInvoices.
  ///
  /// In vi, this message translates to:
  /// **'Không có hóa đơn phù hợp.'**
  String get noMatchingInvoices;

  /// No description provided for @staff.
  ///
  /// In vi, this message translates to:
  /// **'Nhân viên'**
  String get staff;

  /// No description provided for @payment.
  ///
  /// In vi, this message translates to:
  /// **'Thanh toán'**
  String get payment;

  /// No description provided for @invoiceList.
  ///
  /// In vi, this message translates to:
  /// **'Danh sách hóa đơn'**
  String get invoiceList;

  /// No description provided for @cancelInvoice.
  ///
  /// In vi, this message translates to:
  /// **'Hủy hóa đơn'**
  String get cancelInvoice;

  /// No description provided for @cancelInvoicePrompt.
  ///
  /// In vi, this message translates to:
  /// **'Hệ thống sẽ đổi trạng thái hóa đơn và hoàn lại tồn kho đúng một lần.'**
  String get cancelInvoicePrompt;

  /// No description provided for @invoiceCancelled.
  ///
  /// In vi, this message translates to:
  /// **'Đã hủy hóa đơn và hoàn kho.'**
  String get invoiceCancelled;

  /// No description provided for @createdAt.
  ///
  /// In vi, this message translates to:
  /// **'Tạo lúc {date}'**
  String createdAt(String date);

  /// No description provided for @customer.
  ///
  /// In vi, this message translates to:
  /// **'Khách hàng'**
  String get customer;

  /// No description provided for @walkInCustomer.
  ///
  /// In vi, this message translates to:
  /// **'Khách lẻ'**
  String get walkInCustomer;

  /// No description provided for @quantity.
  ///
  /// In vi, this message translates to:
  /// **'Số lượng'**
  String get quantity;

  /// No description provided for @unitPrice.
  ///
  /// In vi, this message translates to:
  /// **'Đơn giá'**
  String get unitPrice;

  /// No description provided for @lineTotal.
  ///
  /// In vi, this message translates to:
  /// **'Thành tiền'**
  String get lineTotal;

  /// No description provided for @subtotal.
  ///
  /// In vi, this message translates to:
  /// **'Tạm tính'**
  String get subtotal;

  /// No description provided for @grandTotal.
  ///
  /// In vi, this message translates to:
  /// **'Tổng cộng'**
  String get grandTotal;

  /// No description provided for @productNumber.
  ///
  /// In vi, this message translates to:
  /// **'Sản phẩm #{id}'**
  String productNumber(int id);

  /// No description provided for @inventorySubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Tồn kho hiện tại và cảnh báo theo ngưỡng sản phẩm.'**
  String get inventorySubtitle;

  /// No description provided for @inventoryHistory.
  ///
  /// In vi, this message translates to:
  /// **'Lịch sử kho'**
  String get inventoryHistory;

  /// No description provided for @importOrAdjust.
  ///
  /// In vi, this message translates to:
  /// **'Nhập / điều chỉnh'**
  String get importOrAdjust;

  /// No description provided for @noInventoryProducts.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có sản phẩm trong kho.'**
  String get noInventoryProducts;

  /// No description provided for @currentStock.
  ///
  /// In vi, this message translates to:
  /// **'Tồn hiện tại'**
  String get currentStock;

  /// No description provided for @warningThreshold.
  ///
  /// In vi, this message translates to:
  /// **'Ngưỡng cảnh báo'**
  String get warningThreshold;

  /// No description provided for @thresholdValue.
  ///
  /// In vi, this message translates to:
  /// **'Ngưỡng {value}'**
  String thresholdValue(int value);

  /// No description provided for @updateInventory.
  ///
  /// In vi, this message translates to:
  /// **'Cập nhật tồn kho'**
  String get updateInventory;

  /// No description provided for @operationType.
  ///
  /// In vi, this message translates to:
  /// **'Loại thao tác'**
  String get operationType;

  /// No description provided for @importStock.
  ///
  /// In vi, this message translates to:
  /// **'Nhập thêm hàng'**
  String get importStock;

  /// No description provided for @inventoryAdjustment.
  ///
  /// In vi, this message translates to:
  /// **'Điều chỉnh kiểm kê'**
  String get inventoryAdjustment;

  /// No description provided for @importQuantity.
  ///
  /// In vi, this message translates to:
  /// **'Số lượng nhập'**
  String get importQuantity;

  /// No description provided for @quantityChange.
  ///
  /// In vi, this message translates to:
  /// **'Số thay đổi (+/-)'**
  String get quantityChange;

  /// No description provided for @importQuantityPositive.
  ///
  /// In vi, this message translates to:
  /// **'Số lượng nhập phải lớn hơn 0.'**
  String get importQuantityPositive;

  /// No description provided for @adjustmentNonZero.
  ///
  /// In vi, this message translates to:
  /// **'Số điều chỉnh phải khác 0.'**
  String get adjustmentNonZero;

  /// No description provided for @inventoryHistorySubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Mỗi thay đổi tồn kho đều có bản ghi truy vết.'**
  String get inventoryHistorySubtitle;

  /// No description provided for @currentInventory.
  ///
  /// In vi, this message translates to:
  /// **'Kho hiện tại'**
  String get currentInventory;

  /// No description provided for @filterByProduct.
  ///
  /// In vi, this message translates to:
  /// **'Lọc theo sản phẩm'**
  String get filterByProduct;

  /// No description provided for @allProducts.
  ///
  /// In vi, this message translates to:
  /// **'Tất cả sản phẩm'**
  String get allProducts;

  /// No description provided for @noInventoryTransactions.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có giao dịch kho.'**
  String get noInventoryTransactions;

  /// No description provided for @transactionImport.
  ///
  /// In vi, this message translates to:
  /// **'Nhập hàng'**
  String get transactionImport;

  /// No description provided for @transactionAdjustment.
  ///
  /// In vi, this message translates to:
  /// **'Điều chỉnh'**
  String get transactionAdjustment;

  /// No description provided for @transactionSale.
  ///
  /// In vi, this message translates to:
  /// **'Bán hàng'**
  String get transactionSale;

  /// No description provided for @transactionReturn.
  ///
  /// In vi, this message translates to:
  /// **'Hoàn hàng'**
  String get transactionReturn;

  /// No description provided for @expensesSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Theo dõi các khoản chi để tính lợi nhuận ròng chính xác.'**
  String get expensesSubtitle;

  /// No description provided for @addExpense.
  ///
  /// In vi, this message translates to:
  /// **'Thêm chi phí'**
  String get addExpense;

  /// No description provided for @totalValue.
  ///
  /// In vi, this message translates to:
  /// **'Tổng: {amount}'**
  String totalValue(String amount);

  /// No description provided for @pageTotalValue.
  ///
  /// In vi, this message translates to:
  /// **'Tổng trang: {amount}'**
  String pageTotalValue(String amount);

  /// No description provided for @noExpensesInRange.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có chi phí trong khoảng này.'**
  String get noExpensesInRange;

  /// No description provided for @expenseType.
  ///
  /// In vi, this message translates to:
  /// **'Loại chi phí'**
  String get expenseType;

  /// No description provided for @expenseDate.
  ///
  /// In vi, this message translates to:
  /// **'Ngày chi'**
  String get expenseDate;

  /// No description provided for @invalidExpense.
  ///
  /// In vi, this message translates to:
  /// **'Nhập loại chi phí và số tiền lớn hơn 0.'**
  String get invalidExpense;

  /// No description provided for @expenseCreated.
  ///
  /// In vi, this message translates to:
  /// **'Đã thêm chi phí.'**
  String get expenseCreated;

  /// No description provided for @reportsSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Tổng hợp doanh thu và lợi nhuận theo thời gian đã chọn.'**
  String get reportsSubtitle;

  /// No description provided for @viewReport.
  ///
  /// In vi, this message translates to:
  /// **'Xem báo cáo'**
  String get viewReport;

  /// No description provided for @averageOrderValue.
  ///
  /// In vi, this message translates to:
  /// **'Giá trị đơn TB'**
  String get averageOrderValue;

  /// No description provided for @previousPage.
  ///
  /// In vi, this message translates to:
  /// **'Trang trước'**
  String get previousPage;

  /// No description provided for @nextPage.
  ///
  /// In vi, this message translates to:
  /// **'Trang sau'**
  String get nextPage;

  /// No description provided for @pageNumber.
  ///
  /// In vi, this message translates to:
  /// **'Trang {page}'**
  String pageNumber(int page);

  /// No description provided for @pageNotFound.
  ///
  /// In vi, this message translates to:
  /// **'Trang bạn mở không tồn tại.'**
  String get pageNotFound;

  /// No description provided for @backToDashboard.
  ///
  /// In vi, this message translates to:
  /// **'Về Tổng quan'**
  String get backToDashboard;

  /// No description provided for @fieldRequired.
  ///
  /// In vi, this message translates to:
  /// **'{field} không được để trống'**
  String fieldRequired(String field);

  /// No description provided for @mustBeNumber.
  ///
  /// In vi, this message translates to:
  /// **'{field} phải là số'**
  String mustBeNumber(String field);

  /// No description provided for @mustNotBeNegative.
  ///
  /// In vi, this message translates to:
  /// **'{field} không được âm'**
  String mustNotBeNegative(String field);

  /// No description provided for @mustBePositive.
  ///
  /// In vi, this message translates to:
  /// **'{field} phải lớn hơn 0'**
  String mustBePositive(String field);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
