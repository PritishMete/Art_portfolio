// lib/screens/upload/upload_artwork_screen.dart

import 'dart:math';
import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:charmy_craft_studio/models/artwork.dart';
import 'package:charmy_craft_studio/services/firestore_service.dart';
import 'package:charmy_craft_studio/state/categories_provider.dart';
import 'package:charmy_craft_studio/state/upload_provider.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class UploadArtworkScreen extends ConsumerStatefulWidget {
  final Artwork? artworkToEdit;

  const UploadArtworkScreen({super.key, this.artworkToEdit});

  @override
  ConsumerState<UploadArtworkScreen> createState() =>
      _UploadArtworkScreenState();
}

class _UploadArtworkScreenState extends ConsumerState<UploadArtworkScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _tagsController = TextEditingController();
  final _categoryController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();

  final _pxWidthController = TextEditingController();
  final _pxHeightController = TextEditingController();
  final _cmWidthController = TextEditingController();
  final _cmHeightController = TextEditingController();
  final _inchWidthController = TextEditingController();
  final _inchHeightController = TextEditingController();
  final _mmWidthController = TextEditingController();
  final _mmHeightController = TextEditingController();

  String? _selectedCategory;
  bool _isFree = true;
  bool _isDownloadable = true;
  bool _isMultiPhoto = false;
  bool _autoCalculate = true;
  String _currentQuote = '';
  final List<String> _artQuotes = [
    "Every artist was first an amateur.",
    "Creativity takes courage.",
  ];

  bool _isCalculating = false;
  bool _showPixels = true;
  bool _showCm = true;
  bool _showInch = false;
  bool _showMm = false;

  bool get _isEditMode => widget.artworkToEdit != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      final art = widget.artworkToEdit!;
      _titleController.text = art.title;
      _tagsController.text = art.tags.join(', ');
      _selectedCategory = art.category;
      _categoryController.text = art.category;
      _descriptionController.text = art.description;
      _priceController.text = art.price.toString();
      _isFree = art.isFree;
      _isDownloadable = art.isDownloadable;
      _pxWidthController.text = art.dimensions['px']?['width'] ?? '';
      _pxHeightController.text = art.dimensions['px']?['height'] ?? '';
      _cmWidthController.text = art.dimensions['cm']?['width'] ?? '';
      _cmHeightController.text = art.dimensions['cm']?['height'] ?? '';
      _inchWidthController.text = art.dimensions['inch']?['width'] ?? '';
      _inchHeightController.text = art.dimensions['inch']?['height'] ?? '';
      _mmWidthController.text = art.dimensions['mm']?['width'] ?? '';
      _mmHeightController.text = art.dimensions['mm']?['height'] ?? '';
    }
    _cmWidthController.addListener(() => _onCmChange(isWidth: true));
    _cmHeightController.addListener(() => _onCmChange(isWidth: false));
    _inchWidthController.addListener(() => _onInchChange(isWidth: true));
    _inchHeightController.addListener(() => _onInchChange(isWidth: false));
    _mmWidthController.addListener(() => _onMmChange(isWidth: true));
    _mmHeightController.addListener(() => _onMmChange(isWidth: false));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _tagsController.dispose();
    _categoryController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _pxWidthController.dispose();
    _pxHeightController.dispose();
    _cmWidthController.dispose();
    _cmHeightController.dispose();
    _inchWidthController.dispose();
    _inchHeightController.dispose();
    _mmWidthController.dispose();
    _mmHeightController.dispose();
    super.dispose();
  }

  void _onCmChange({required bool isWidth}) {
    if (!_autoCalculate || _isCalculating) return;
    _isCalculating = true;
    final controller = isWidth ? _cmWidthController : _cmHeightController;
    final val = double.tryParse(controller.text);
    if (val != null) {
      if (isWidth) {
        _inchWidthController.text = (val / 2.54).toStringAsFixed(2);
        _mmWidthController.text = (val * 10).toStringAsFixed(1);
      } else {
        _inchHeightController.text = (val / 2.54).toStringAsFixed(2);
        _mmHeightController.text = (val * 10).toStringAsFixed(1);
      }
    } else {
      if (isWidth) {
        _inchWidthController.clear();
        _mmWidthController.clear();
      } else {
        _inchHeightController.clear();
        _mmHeightController.clear();
      }
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _isCalculating = false);
  }

  void _onInchChange({required bool isWidth}) {
    if (!_autoCalculate || _isCalculating) return;
    _isCalculating = true;
    final controller = isWidth ? _inchWidthController : _inchHeightController;
    final val = double.tryParse(controller.text);
    if (val != null) {
      if (isWidth) {
        _cmWidthController.text = (val * 2.54).toStringAsFixed(2);
        _mmWidthController.text = (val * 25.4).toStringAsFixed(1);
      } else {
        _cmHeightController.text = (val * 2.54).toStringAsFixed(2);
        _mmHeightController.text = (val * 25.4).toStringAsFixed(1);
      }
    } else {
      if (isWidth) {
        _cmWidthController.clear();
        _mmWidthController.clear();
      } else {
        _cmHeightController.clear();
        _mmHeightController.clear();
      }
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _isCalculating = false);
  }

  void _onMmChange({required bool isWidth}) {
    if (!_autoCalculate || _isCalculating) return;
    _isCalculating = true;
    final controller = isWidth ? _mmWidthController : _mmHeightController;
    final val = double.tryParse(controller.text);
    if (val != null) {
      if (isWidth) {
        _cmWidthController.text = (val / 10).toStringAsFixed(2);
        _inchWidthController.text = (val / 25.4).toStringAsFixed(2);
      } else {
        _cmHeightController.text = (val / 10).toStringAsFixed(2);
        _inchHeightController.text = (val / 25.4).toStringAsFixed(2);
      }
    } else {
      if (isWidth) {
        _cmWidthController.clear();
        _inchWidthController.clear();
      } else {
        _cmHeightController.clear();
        _inchHeightController.clear();
      }
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _isCalculating = false);
  }

  void _startUploadOrUpdate() {
    if (_formKey.currentState!.validate()) {
      setState(
        () => _currentQuote = _artQuotes[Random().nextInt(_artQuotes.length)],
      );
      final dimensionsMap = {
        if (_showPixels)
          'px': {
            'width': _pxWidthController.text,
            'height': _pxHeightController.text,
          },
        if (_showCm)
          'cm': {
            'width': _cmWidthController.text,
            'height': _cmHeightController.text,
          },
        if (_showInch)
          'inch': {
            'width': _inchWidthController.text,
            'height': _inchHeightController.text,
          },
        if (_showMm)
          'mm': {
            'width': _mmWidthController.text,
            'height': _mmHeightController.text,
          },
      };
      final categoryValue = _categoryController.text.isEmpty
          ? _selectedCategory!
          : _categoryController.text;

      if (_isEditMode) {
        ref
            .read(uploadProvider.notifier)
            .updateArtwork(
              artworkId: widget.artworkToEdit!.id,
              title: _titleController.text,
              tags: _tagsController.text,
              category: categoryValue,
              dimensions: dimensionsMap,
              description: _descriptionController.text,
              price: double.tryParse(_priceController.text) ?? 0.0,
              isFree: _isFree,
              isDownloadable: _isDownloadable,
            );
      } else {
        ref
            .read(uploadProvider.notifier)
            .uploadArtwork(
              title: _titleController.text,
              tags: _tagsController.text,
              category: categoryValue,
              dimensions: dimensionsMap,
              description: _descriptionController.text,
              price: double.tryParse(_priceController.text) ?? 0.0,
              isFree: _isFree,
              isDownloadable: _isDownloadable,
            );
      }
    }
  }

  void _showAddNewCategoryDialog() {
    final newCategoryController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Category'),
          content: TextFormField(
            controller: newCategoryController,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Category Name',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final categoryName = newCategoryController.text.trim();
                if (categoryName.isNotEmpty) {
                  await ref
                      .read(firestoreServiceProvider)
                      .addCategory(categoryName);
                  setState(() => _selectedCategory = categoryName);
                  ref.invalidate(categoriesProvider);
                  if (mounted) Navigator.of(context).pop();
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final uploadState = ref.watch(uploadProvider);
    final uploadNotifier = ref.read(uploadProvider.notifier);
    final categoriesAsync = ref.watch(categoriesProvider);
    ref.listen<UploadState>(uploadProvider, (previous, next) {
      if (previous?.isLoading == true &&
          !next.isLoading &&
          next.errorMessage == null) {
        final message = _isEditMode
            ? 'Artwork updated successfully!'
            : 'Artwork uploaded successfully!';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.green),
        );
        if (mounted) Navigator.of(context).pop();
      }
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${next.errorMessage}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditMode ? 'Edit Artwork' : 'Upload New Artwork',
          style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {},
            tooltip: 'Clear Form',
          ),
        ],
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!_isEditMode) ...[
                    SwitchListTile(
                      title: const Text('Upload Multiple Photos'),
                      value: _isMultiPhoto,
                      onChanged: (value) {
                        setState(() => _isMultiPhoto = value);
                        uploadNotifier.reset();
                      },
                    ),
                    const SizedBox(height: 8),
                    _buildFilePicker(context, uploadState, uploadNotifier),
                    if (uploadState.thumbnailFile != null)
                      _buildThumbnailPreview(uploadState),
                  ],
                  _buildTextField(controller: _titleController, label: 'Title'),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _tagsController,
                    label: 'Tags (comma separated)',
                  ),
                  const SizedBox(height: 16),
                  categoriesAsync.when(
                    data: (categories) {
                      final categoryNames = categories
                          .map((c) => c.name)
                          .toList();
                      if (_selectedCategory != null &&
                          !categoryNames.contains(_selectedCategory)) {
                        _selectedCategory = null;
                      }
                      return CustomDropdown<String>.search(
                        key: ValueKey(_selectedCategory),
                        hintText: 'Select Category',
                        items: [...categoryNames, '+ Add New Category'],
                        initialItem: _selectedCategory,
                        onChanged: (value) {
                          if (value == '+ Add New Category') {
                            WidgetsBinding.instance.addPostFrameCallback(
                              (_) => setState(() => _selectedCategory = null),
                            );
                            _showAddNewCategoryDialog();
                          } else {
                            setState(() => _selectedCategory = value);
                          }
                        },
                        decoration: CustomDropdownDecoration(
                          closedBorder: Border.all(color: Colors.grey.shade400),
                          closedBorderRadius: BorderRadius.circular(12),
                        ),
                        validator: (value) =>
                            (value == null || value.isEmpty) &&
                                _categoryController.text.isEmpty
                            ? 'Please select a category.'
                            : null,
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (err, stack) =>
                        Text('Error loading categories: $err'),
                  ),
                  const SizedBox(height: 16),
                  _buildDimensionsSection(),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _descriptionController,
                    label: 'Description',
                    maxLines: 4,
                  ),
                  const SizedBox(height: 24),
                  SwitchListTile(
                    title: const Text('Artwork is Free'),
                    value: _isFree,
                    onChanged: (value) => setState(() => _isFree = value),
                    secondary: Icon(
                      _isFree ? Icons.celebration : Icons.attach_money,
                    ),
                  ),
                  SwitchListTile(
                    title: const Text('Allow Downloading'),
                    subtitle: Text(
                      _isDownloadable
                          ? 'Users can download this item'
                          : 'Download is disabled',
                    ),
                    value: _isDownloadable,
                    onChanged: (value) =>
                        setState(() => _isDownloadable = value),
                    secondary: Icon(
                      _isDownloadable
                          ? Icons.download_for_offline_outlined
                          : Icons.lock_outline,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _priceController,
                    label: 'Price',
                    keyboardType: TextInputType.number,
                    enabled: !_isFree,
                  ),
                  const Divider(height: 48),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: Icon(_isEditMode ? Icons.save : Icons.upload_file),
                      label: Text(
                        _isEditMode ? 'Save Changes' : 'Upload Artwork',
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed:
                          (_isEditMode ||
                              (uploadState.originalFiles.isNotEmpty &&
                                  !uploadState.isLoading))
                          ? _startUploadOrUpdate
                          : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (uploadState.isLoading)
            Container(
              color: Colors.black.withOpacity(0.7),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 20),
                    Text(
                      '${_isEditMode ? "Updating" : "Uploading"}... Please do not close the app.',
                      style: Theme.of(
                        context,
                      ).textTheme.titleMedium?.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '"$_currentQuote"',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDimensionsSection() => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.shade300),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Dimensions',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        _buildDimensionToggle(
          'Pixels (px)',
          _showPixels,
          (val) => setState(() => _showPixels = val!),
        ),
        _buildDimensionToggle(
          'Centimeters (cm)',
          _showCm,
          (val) => setState(() => _showCm = val!),
        ),
        _buildDimensionToggle(
          'Inches (inch)',
          _showInch,
          (val) => setState(() => _showInch = val!),
        ),
        _buildDimensionToggle(
          'Millimeters (mm)',
          _showMm,
          (val) => setState(() => _showMm = val!),
        ),
        if (_showPixels) const Divider(),
        if (_showPixels)
          _buildDimensionRow('px', _pxWidthController, _pxHeightController),
        if (_showCm || _showInch || _showMm) ...[
          const Divider(),
          SwitchListTile(
            title: const Text('Auto-calculate dimensions'),
            value: _autoCalculate,
            dense: true,
            onChanged: (value) => setState(() => _autoCalculate = value),
          ),
          const Divider(),
        ],
        if (_showCm)
          _buildDimensionRow('cm', _cmWidthController, _cmHeightController),
        if (_showInch)
          _buildDimensionRow(
            'inch',
            _inchWidthController,
            _inchHeightController,
          ),
        if (_showMm)
          _buildDimensionRow('mm', _mmWidthController, _mmHeightController),
      ],
    ),
  );
  Widget _buildDimensionToggle(
    String title,
    bool value,
    ValueChanged<bool?> onChanged,
  ) => CheckboxListTile(
    title: Text(title),
    value: value,
    onChanged: onChanged,
    dense: true,
    controlAffinity: ListTileControlAffinity.leading,
    contentPadding: EdgeInsets.zero,
  );
  Widget _buildDimensionRow(
    String unit,
    TextEditingController widthController,
    TextEditingController heightController,
  ) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: Row(
      children: [
        SizedBox(
          width: 40,
          child: Text(
            unit,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: _buildTextField(
            controller: widthController,
            label: 'Width',
            keyboardType: TextInputType.number,
          ),
        ),
        const SizedBox(width: 8),
        const Text('x'),
        const SizedBox(width: 8),
        Expanded(
          child: _buildTextField(
            controller: heightController,
            label: 'Height',
            keyboardType: TextInputType.number,
          ),
        ),
      ],
    ),
  );

  Widget _buildFilePicker(
    BuildContext context,
    UploadState uploadState,
    UploadNotifier uploadNotifier,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        _isMultiPhoto ? 'Master Images (Max 10)' : 'Master Image',
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 8),
      if (_isMultiPhoto && uploadState.originalFiles.isNotEmpty)
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: uploadState.originalFiles.length,
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  uploadState.originalFiles[index],
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
      const SizedBox(height: 8),
      GestureDetector(
        onTap: () => uploadNotifier.pickImages(allowMultiple: _isMultiPhoto),
        // ** DEFINITIVE FIX for your package version **
        child: DottedBorder(
          options: RoundedRectDottedBorderOptions(
            color: Theme.of(context).colorScheme.secondary,
            strokeWidth: 2,
            dashPattern: const [8, 4],
            radius: const Radius.circular(12),
          ),
          child: Container(
            width: double.infinity,
            height: _isMultiPhoto ? 80 : 200,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary.withAlpha(20),
              borderRadius: BorderRadius.circular(12),
            ),
            child: uploadState.originalFiles.isNotEmpty && !_isMultiPhoto
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      uploadState.originalFiles.first,
                      fit: BoxFit.cover,
                    ),
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate_outlined,
                          size: 48,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _isMultiPhoto
                              ? 'Tap to add images'
                              : 'Tap to select an image',
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ),
      const SizedBox(height: 24),
    ],
  );

  Widget _buildThumbnailPreview(UploadState uploadState) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Discover Page Thumbnail (Cropped from first image)',
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 8),
      Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            uploadState.thumbnailFile!,
            width: 150,
            height: 150,
            fit: BoxFit.cover,
          ),
        ),
      ),
      const SizedBox(height: 24),
    ],
  );
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    TextInputType? keyboardType,
    bool enabled = true,
  }) => TextFormField(
    controller: controller,
    maxLines: maxLines,
    keyboardType: keyboardType,
    enabled: enabled,
    decoration: InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      alignLabelWithHint: true,
    ),
    validator: (value) => (enabled && (value == null || value.isEmpty))
        ? 'Please enter a $label'
        : null,
  );
}
