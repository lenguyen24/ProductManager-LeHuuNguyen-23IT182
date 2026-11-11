import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import '../widgets/product_image_view.dart';

class ProductFormDialog extends StatefulWidget {
  final Product? product;

  const ProductFormDialog({super.key, this.product});

  @override
  State<ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<ProductFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _soluongController;
  late TextEditingController _imageController;

  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  bool get isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    final shouldPrefill = kIsWeb && Uri.base.queryParameters['filled'] == 'true';
    _nameController = TextEditingController(
      text: widget.product?.name ?? (shouldPrefill ? 'Tai nghe Sony WH-1000XM5' : ''),
    );
    _priceController = TextEditingController(
      text: widget.product != null
          ? widget.product!.price.toStringAsFixed(0)
          : (shouldPrefill ? '5990000' : ''),
    );
    _soluongController = TextEditingController(
      text: widget.product != null
          ? widget.product!.soluong.toString()
          : (shouldPrefill ? '15' : ''),
    );
    _imageController = TextEditingController(
      text: widget.product?.image ??
          (shouldPrefill ? 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=500' : ''),
    );
    _imageController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _soluongController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        final base64String = 'data:image/jpeg;base64,${base64Encode(bytes)}';
        setState(() {
          _imageController.text = base64String;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể chọn ảnh: $e')),
        );
      }
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final price = double.tryParse(_priceController.text.trim()) ?? 0.0;
    final soluong = int.tryParse(_soluongController.text.trim()) ?? 0;
    final image = _imageController.text.trim();

    setState(() => _isLoading = true);

    try {
      if (isEditing) {
        final updatedProduct = widget.product!.copyWith(
          name: name,
          price: price,
          soluong: soluong,
          image: image,
        );
        await ProductService().updateProduct(updatedProduct);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã cập nhật sản phẩm thành công!')),
          );
          Navigator.of(context).pop(true);
        }
      } else {
        final newProduct = Product(
          name: name,
          price: price,
          soluong: soluong,
          image: image,
        );
        await ProductService().addProduct(newProduct);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã thêm sản phẩm mới thành công!')),
          );
          Navigator.of(context).pop(true);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 550),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          isEditing ? Icons.edit : Icons.add_business,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          isEditing ? 'Cập Nhật Sản Phẩm' : 'Thêm Sản Phẩm Mới',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const Divider(height: 24),

                  // Tên sản phẩm
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Tên sản phẩm *',
                      hintText: 'Nhập tên sản phẩm (vd: iPhone 15 Pro Max)',
                      prefixIcon: Icon(Icons.shopping_bag_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Vui lòng nhập tên sản phẩm';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Giá và Số lượng
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _priceController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Giá sản phẩm (VNĐ) *',
                            hintText: 'vd: 25000000',
                            prefixIcon: Icon(Icons.attach_money),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Vui lòng nhập giá';
                            }
                            final n = double.tryParse(value.trim());
                            if (n == null || n < 0) {
                              return 'Giá phải là số hợp lệ';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _soluongController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Số lượng kho *',
                            hintText: 'vd: 50',
                            prefixIcon: Icon(Icons.inventory_2_outlined),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Nhập số lượng';
                            }
                            final n = int.tryParse(value.trim());
                            if (n == null || n < 0) {
                              return 'Số lượng >= 0';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Nhập hình ảnh
                  TextFormField(
                    controller: _imageController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Đường dẫn ảnh (URL hoặc Base64) *',
                      hintText: 'Dán liên kết ảnh https://... hoặc chọn ảnh bên dưới',
                      prefixIcon: Icon(Icons.link),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Vui lòng cung cấp hình ảnh sản phẩm';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),

                  // Các nút chọn ảnh
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            _nameController.text = 'Tai nghe Sony WH-1000XM5';
                            _priceController.text = '5990000';
                            _soluongController.text = '15';
                            _imageController.text = 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=500';
                          });
                        },
                        icon: const Icon(Icons.auto_fix_high, size: 18, color: Colors.deepOrange),
                        label: const Text('Điền mẫu nhanh'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => _pickImage(ImageSource.gallery),
                        icon: const Icon(Icons.photo_library, size: 18),
                        label: const Text('Chọn ảnh từ thư viện'),
                      ),
                      if (!kIsWeb)
                        OutlinedButton.icon(
                          onPressed: () => _pickImage(ImageSource.camera),
                          icon: const Icon(Icons.camera_alt, size: 18),
                          label: const Text('Chụp ảnh từ Camera'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Khung xem trước hình ảnh
                  if (_imageController.text.trim().isNotEmpty) ...[
                    const Text(
                      'Xem trước hình ảnh:',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: ProductImageView(
                        imageUrl: _imageController.text.trim(),
                        width: 160,
                        height: 140,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Nút hành động Lưu / Hủy
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                        child: const Text('Hủy bỏ'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E88E5),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: _isLoading ? null : _submitForm,
                        icon: _isLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.check),
                        label: Text(isEditing ? 'Lưu Thay Đổi' : 'Thêm Sản Phẩm'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
