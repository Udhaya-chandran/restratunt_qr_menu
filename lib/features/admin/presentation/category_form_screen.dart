import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/supabase_providers.dart';

import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CategoryFormScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? category;
  const CategoryFormScreen({super.key, this.category});

  @override
  ConsumerState<CategoryFormScreen> createState() => _CategoryFormScreenState();
}

class _CategoryFormScreenState extends ConsumerState<CategoryFormScreen> {
  final _nameController = TextEditingController();
  File? _selectedImage;
  String? _selectedRestaurantId;
  final _picker = ImagePicker();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      _nameController.text = widget.category!['name'] ?? '';
      _selectedRestaurantId = widget.category!['restaurant_id'];
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
    if (_nameController.text.isEmpty || _selectedRestaurantId == null) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          const SnackBar(content: Text('Please fill in all fields')),
        );
      return;
    }

    setState(() => _isSaving = true);

    try {
      String? finalImageUrl = widget.category != null ? widget.category!['image_url'] : null;
      
      if (_selectedImage != null) {
        finalImageUrl = await ref.read(supabaseServiceProvider).uploadImage(
          'restaurant-media',
          'categories',
          _selectedImage!,
        );
      }

      await ref.read(supabaseServiceProvider).saveCategory({
        if (widget.category != null) 'id': widget.category!['id'],
        'name': _nameController.text.trim(),
        'restaurant_id': _selectedRestaurantId,
        'image_url': finalImageUrl,
        'display_order': 10, // Default order
      });

      if (mounted) {
        ref.invalidate(categoriesProvider(_selectedRestaurantId!));
        ref.invalidate(allCategoriesProvider);
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
            SnackBar(content: Text('Error saving category: $e')),
          );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final restaurantsAsync = ref.watch(restaurantsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category != null ? 'EDIT CATEGORY' : 'ADD CATEGORY'),
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
            // Restaurant Selection Dropdown
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
                onChanged: (val) => setState(() => _selectedRestaurantId = val),
              ),
              loading: () => const LinearProgressIndicator(color: AppTheme.primaryGold),
              error: (err, _) => Text('Error loading restaurants: $err', style: const TextStyle(color: Colors.red)),
            ).animate().fadeIn().slideY(begin: 0.2),
            
            const SizedBox(height: 20),
            
            _buildTextField(context, 'Category Name', Icons.category, _nameController),
            const SizedBox(height: 30),
            
            // Image Upload Section
            const Text('Category Image', style: TextStyle(color: Colors.white70, fontSize: 16)),
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
                    : (widget.category?['image_url'] != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(widget.category!['image_url'], fit: BoxFit.cover),
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
                : Text(widget.category != null ? 'UPDATE CATEGORY' : 'SAVE CATEGORY', style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            ).animate().scale(delay: 400.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(BuildContext context, String label, IconData icon, TextEditingController controller) {
    return TextField(
      controller: controller,
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
