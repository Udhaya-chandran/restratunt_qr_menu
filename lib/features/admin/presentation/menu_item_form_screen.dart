import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/supabase_providers.dart';

import 'package:image_picker/image_picker.dart';
import 'dart:io';

class MenuItemFormScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? item;
  const MenuItemFormScreen({super.key, this.item});

  @override
  ConsumerState<MenuItemFormScreen> createState() => _MenuItemFormScreenState();
}

class _MenuItemFormScreenState extends ConsumerState<MenuItemFormScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  
  File? _selectedImage;
  String? _selectedRestaurantId;
  String? _selectedCategoryId;
  final _picker = ImagePicker();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      _nameController.text = widget.item!['name'] ?? '';
      _descriptionController.text = widget.item!['description'] ?? '';
      _priceController.text = widget.item!['price']?.toString() ?? '';
      _selectedRestaurantId = widget.item!['restaurant_id'];
      _selectedCategoryId = widget.item!['category_id'];
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _save() async {
    if (_nameController.text.isEmpty || 
        _selectedRestaurantId == null || 
        _selectedCategoryId == null ||
        _priceController.text.isEmpty) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          const SnackBar(content: Text('Please fill in all fields')),
        );
      return;
    }

    setState(() => _isSaving = true);

    try {
      String? finalImageUrl = widget.item != null ? widget.item!['image_url'] : null;
      
      if (_selectedImage != null) {
        finalImageUrl = await ref.read(supabaseServiceProvider).uploadImage(
          'restaurant-media',
          'menu-items',
          _selectedImage!,
        );
      }

      await ref.read(supabaseServiceProvider).saveMenuItem({
        if (widget.item != null) 'id': widget.item!['id'],
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'price': double.tryParse(_priceController.text) ?? 0.0,
        'restaurant_id': _selectedRestaurantId,
        'category_id': _selectedCategoryId,
        'image_url': finalImageUrl,
        'display_order': 10,
      });

      if (mounted) {
        ref.invalidate(menuItemsProvider(_selectedCategoryId!));
        ref.invalidate(allMenuItemsProvider);
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
            SnackBar(content: Text('Error saving menu item: $e')),
          );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final restaurantsAsync = ref.watch(restaurantsProvider);
    final categoriesAsync = _selectedRestaurantId != null 
        ? ref.watch(categoriesProvider(_selectedRestaurantId!))
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item != null ? 'EDIT MENU ITEM' : 'ADD MENU ITEM'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Restaurant Dropdown
            restaurantsAsync.when(
              data: (restaurants) => DropdownButtonFormField<String>(
                value: _selectedRestaurantId,
                decoration: InputDecoration(
                  labelText: 'Select Restaurant',
                  prefixIcon: const Icon(Icons.store, color: AppTheme.primaryGold),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: restaurants.map((r) => DropdownMenuItem(
                  value: r['id'] as String, 
                  child: Text(r['name'] ?? 'Unknown'),
                )).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedRestaurantId = val;
                    _selectedCategoryId = null; // Reset category when restaurant changes
                  });
                },
              ),
              loading: () => const LinearProgressIndicator(color: AppTheme.primaryGold),
              error: (err, _) => Text('Error loading restaurants: $err', style: const TextStyle(color: Colors.red)),
            ).animate().fadeIn().slideY(begin: 0.2),
            
            const SizedBox(height: 20),
            
            // Category Dropdown
            if (categoriesAsync != null)
              categoriesAsync.when(
                data: (categories) => DropdownButtonFormField<String>(
                  value: _selectedCategoryId,
                  decoration: InputDecoration(
                    labelText: 'Select Category',
                    prefixIcon: const Icon(Icons.category, color: AppTheme.primaryGold),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: categories.map((c) => DropdownMenuItem(
                    value: c['id'] as String, 
                    child: Text(c['name'] ?? 'Unknown'),
                  )).toList(),
                  onChanged: (val) => setState(() => _selectedCategoryId = val),
                ),
                loading: () => const LinearProgressIndicator(color: AppTheme.primaryGold),
                error: (err, _) => Text('Error loading categories: $err', style: const TextStyle(color: Colors.red)),
              ).animate().fadeIn().slideY(begin: 0.2)
            else
              const Text('Please select a restaurant first', style: TextStyle(color: Colors.white60)),
            
            const SizedBox(height: 20),

            _buildTextField(context, 'Item Name', Icons.food_bank, _nameController),
            const SizedBox(height: 20),
            _buildTextField(context, 'Description', Icons.description, _descriptionController, maxLines: 3),
            const SizedBox(height: 20),
            _buildTextField(context, 'Price', Icons.attach_money, _priceController, keyboardType: TextInputType.number),
            const SizedBox(height: 30),
            
            // Image Upload Section
            const Text('Item Image', style: TextStyle(color: Colors.white70, fontSize: 16)),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 150,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceDark,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.primaryGold.withValues(alpha: 0.3)),
                ),
                child: _selectedImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(_selectedImage!, fit: BoxFit.cover),
                      )
                    : (widget.item?['image_url'] != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(widget.item!['image_url'], fit: BoxFit.cover),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.add_a_photo, size: 40, color: AppTheme.primaryGold),
                              const SizedBox(height: 8),
                              Text('Select Image', style: TextStyle(color: AppTheme.primaryGold.withValues(alpha: 0.7))),
                            ],
                          )),
              ),
            ),
            
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _isSaving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGold,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isSaving 
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                : Text(widget.item != null ? 'UPDATE ITEM' : 'SAVE MENU ITEM', style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            ).animate().scale(delay: 400.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(BuildContext context, String label, IconData icon, TextEditingController controller, {int maxLines = 1, TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppTheme.primaryGold),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.primaryGold, width: 2),
        ),
      ),
    ).animate().fadeIn().slideY(begin: 0.2);
  }
}
