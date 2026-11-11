import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/product.dart';
import '../services/auth_service.dart';
import '../services/product_service.dart';
import '../widgets/product_image_view.dart';
import 'login_screen.dart';
import 'product_form_dialog.dart';

class HomeScreen extends StatefulWidget {
  final bool autoOpenAdd;
  final bool autoOpenExport;

  const HomeScreen({
    super.key,
    this.autoOpenAdd = false,
    this.autoOpenExport = false,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _sortBy = 'name_asc'; // name_asc, name_desc, price_asc, price_desc, qty_desc, qty_asc

  final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });

    if (widget.autoOpenAdd) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _openProductForm();
      });
    } else if (widget.autoOpenExport) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _exportJson();
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openProductForm([Product? product]) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => ProductFormDialog(product: product),
    );
  }

  void _confirmDelete(Product product) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('Xác nhận xóa'),
          ],
        ),
        content: Text.rich(
          TextSpan(
            text: 'Bạn có chắc chắn muốn xóa sản phẩm ',
            children: [
              TextSpan(
                text: '"${product.name}"',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(text: ' khỏi hệ thống không? Thao tác này không thể hoàn tác.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await ProductService().deleteProduct(product.id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Đã xóa "${product.name}"')),
                );
              }
            },
            child: const Text('Xóa sản phẩm'),
          ),
        ],
      ),
    );
  }

  Future<void> _seedData() async {
    final count = await ProductService().seedInitialProducts();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã nạp $count sản phẩm mẫu vào cơ sở dữ liệu!')),
      );
    }
  }

  Future<void> _exportJson() async {
    final jsonStr = await ProductService().exportProductsToJson();

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Row(
          children: [
            Icon(Icons.data_object, color: Color(0xFF1E88E5)),
            SizedBox(width: 8),
            Text('Xuất CSDL Sản Phẩm (JSON)'),
          ],
        ),
        content: SizedBox(
          width: 600,
          height: 380,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Dữ liệu JSON tuân thủ chuẩn 4 trường: name, price, soluong, image:',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF263238),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SingleChildScrollView(
                    child: SelectableText(
                      jsonStr,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        color: Color(0xFF80CBC4),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.copy),
            label: const Text('Sao chép JSON'),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: jsonStr));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã sao chép JSON vào clipboard!')),
              );
            },
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  List<Product> _filterAndSort(List<Product> rawList) {
    var list = rawList.where((p) {
      if (_searchQuery.isEmpty) return true;
      return p.name.toLowerCase().contains(_searchQuery);
    }).toList();

    switch (_sortBy) {
      case 'name_asc':
        list.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'name_desc':
        list.sort((a, b) => b.name.compareTo(a.name));
        break;
      case 'price_asc':
        list.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price_desc':
        list.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'qty_desc':
        list.sort((a, b) => b.soluong.compareTo(a.soluong));
        break;
      case 'qty_asc':
        list.sort((a, b) => a.soluong.compareTo(b.soluong));
        break;
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 768;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        titleSpacing: isMobile ? 12 : 24,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF1E88E5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.storefront, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isMobile ? 'Quản Lý Sản Phẩm' : 'Hệ Thống Quản Trị Sản Phẩm (Admin)',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF263238),
                  ),
                ),
                Text(
                  'Lê Hữu Nguyên - 23IT182',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          if (!isMobile) ...[
            OutlinedButton.icon(
              onPressed: _seedData,
              icon: const Icon(Icons.cloud_upload_outlined, size: 16),
              label: const Text('Nạp mẫu'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: _exportJson,
              icon: const Icon(Icons.download, size: 16),
              label: const Text('Xuất JSON'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
            const SizedBox(width: 12),
          ],
          IconButton(
            tooltip: 'Đăng xuất',
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: () {
              AuthService().logout();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
          const SizedBox(width: 12),
        ],
      ),
      floatingActionButton: isMobile
          ? FloatingActionButton.extended(
              backgroundColor: const Color(0xFF1E88E5),
              foregroundColor: Colors.white,
              onPressed: () => _openProductForm(),
              icon: const Icon(Icons.add),
              label: const Text('Thêm Sản Phẩm'),
            )
          : null,
      body: StreamBuilder<List<Product>>(
        stream: ProductService().getProductsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final allProducts = snapshot.data ?? [];
          final displayProducts = _filterAndSort(allProducts);

          // Thống kê nhanh
          final totalCount = allProducts.length;
          final totalQty = allProducts.fold<int>(0, (sum, p) => sum + p.soluong);
          final totalValue = allProducts.fold<double>(0.0, (sum, p) => sum + (p.price * p.soluong));

          return CustomScrollView(
            slivers: [
              // Khu vực Thống kê & Bộ lọc
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 12 : 24,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hàng Thống kê (Statistics Cards)
                      _buildStatsRow(isMobile, totalCount, totalQty, totalValue),
                      const SizedBox(height: 16),

                      // Thanh công cụ tìm kiếm và sắp xếp
                      _buildToolbar(isMobile),
                    ],
                  ),
                ),
              ),

              // Danh sách sản phẩm (Table trên Web, Card trên Mobile)
              if (displayProducts.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        Text(
                          _searchQuery.isNotEmpty
                              ? 'Không tìm thấy sản phẩm phù hợp với "$_searchQuery"'
                              : 'Chưa có sản phẩm nào trong cơ sở dữ liệu!',
                          style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: _seedData,
                          icon: const Icon(Icons.add),
                          label: const Text('Nạp Dữ Liệu Mẫu Ngay'),
                        ),
                      ],
                    ),
                  ),
                )
              else if (isMobile)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 80),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final product = displayProducts[index];
                        return _buildMobileProductCard(product);
                      },
                      childCount: displayProducts.length,
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  sliver: SliverToBoxAdapter(
                    child: _buildWebTable(displayProducts),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatsRow(bool isMobile, int totalCount, int totalQty, double totalValue) {
    final cards = [
      _statCard('Tổng sản phẩm', '$totalCount mặt hàng', Icons.category_outlined, const Color(0xFF1E88E5)),
      _statCard('Tổng tồn kho', '$totalQty cái/chiếc', Icons.warehouse_outlined, const Color(0xFF43A047)),
      _statCard('Tổng giá trị kho', currencyFormatter.format(totalValue), Icons.payments_outlined, const Color(0xFFFB8C00)),
    ];

    if (isMobile) {
      return Column(
        children: cards.map((c) => Padding(padding: const EdgeInsets.only(bottom: 8), child: c)).toList(),
      );
    }

    return Row(
      children: cards.map((c) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 6), child: c))).toList(),
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF263238)),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar(bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Search input
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm sản phẩm theo tên...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () => _searchController.clear(),
                          )
                        : null,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Sort dropdown
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _sortBy,
                    icon: const Icon(Icons.sort, size: 20),
                    items: const [
                      DropdownMenuItem(value: 'name_asc', child: Text('Tên A-Z')),
                      DropdownMenuItem(value: 'name_desc', child: Text('Tên Z-A')),
                      DropdownMenuItem(value: 'price_asc', child: Text('Giá thấp -> cao')),
                      DropdownMenuItem(value: 'price_desc', child: Text('Giá cao -> thấp')),
                      DropdownMenuItem(value: 'qty_desc', child: Text('Tồn kho giảm dần')),
                      DropdownMenuItem(value: 'qty_asc', child: Text('Tồn kho tăng dần')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _sortBy = val);
                    },
                  ),
                ),
              ),

              if (!isMobile) ...[
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E88E5),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () => _openProductForm(),
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text('Thêm Sản Phẩm Mới'),
                ),
              ],
            ],
          ),
          if (isMobile) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _seedData,
                    icon: const Icon(Icons.cloud_upload_outlined, size: 16),
                    label: const Text('Nạp CSDL mẫu', style: TextStyle(fontSize: 12)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _exportJson,
                    icon: const Icon(Icons.download, size: 16),
                    label: const Text('Xuất JSON', style: TextStyle(fontSize: 12)),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWebTable(List<Product> products) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(const Color(0xFFF1F5F9)),
          horizontalMargin: 20,
          columnSpacing: 24,
          dataRowMinHeight: 64,
          dataRowMaxHeight: 74,
          columns: const [
            DataColumn(label: Text('Hình Ảnh (image)', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Tên Sản Phẩm (name)', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Giá (price)', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Số Lượng (soluong)', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Thao Tác Quản Trị', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: products.map((product) {
            return DataRow(
              cells: [
                DataCell(
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: ProductImageView(
                      imageUrl: product.image,
                      width: 54,
                      height: 54,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    product.name,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                ),
                DataCell(
                  Text(
                    currencyFormatter.format(product.price),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                      fontSize: 14,
                    ),
                  ),
                ),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: product.soluong > 20
                          ? Colors.blue.shade50
                          : (product.soluong > 0 ? Colors.orange.shade50 : Colors.red.shade50),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${product.soluong} chiếc',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: product.soluong > 20
                            ? Colors.blue.shade800
                            : (product.soluong > 0 ? Colors.orange.shade800 : Colors.red.shade800),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Sửa sản phẩm',
                        icon: const Icon(Icons.edit_outlined, color: Color(0xFF1E88E5), size: 20),
                        onPressed: () => _openProductForm(product),
                      ),
                      IconButton(
                        tooltip: 'Xóa sản phẩm',
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                        onPressed: () => _confirmDelete(product),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildMobileProductCard(Product product) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Image
            ProductImageView(
              imageUrl: product.image,
              width: 76,
              height: 76,
              borderRadius: BorderRadius.circular(10),
            ),
            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    currencyFormatter.format(product.price),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.inventory_2_outlined, size: 14, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        'Kho: ${product.soluong} chiếc',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Actions
            Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: Color(0xFF1E88E5), size: 20),
                  onPressed: () => _openProductForm(product),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                  onPressed: () => _confirmDelete(product),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
