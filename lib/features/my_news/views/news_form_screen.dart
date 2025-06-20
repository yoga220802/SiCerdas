import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:project_sicerdas/app/widgets/custom_button.dart';
import 'package:project_sicerdas/app/widgets/custom_text_field.dart';
import 'package:project_sicerdas/app/theme/app_colors.dart';
import 'package:project_sicerdas/app/theme/app_spacing.dart';
import 'package:project_sicerdas/app/theme/app_typography.dart';
import 'package:project_sicerdas/data/models/news_model.dart';
import 'package:project_sicerdas/features/my_news/controllers/my_news_controller.dart';
import 'package:flutter/services.dart';

class NewsFormScreen extends StatefulWidget {
  final NewsModel? news;

  const NewsFormScreen({super.key, this.news});

  @override
  State<NewsFormScreen> createState() => _NewsFormScreenState();
}

class _NewsFormScreenState extends State<NewsFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late MyNewsController _controller;

  late TextEditingController _titleController;
  late TextEditingController _summaryController;
  late TextEditingController _contentController;
  late TextEditingController _featuredImageUrlController;
  late TextEditingController _categoryInputController;
  late ValueNotifier<List<String>> _tagsNotifier;

  bool _isPublished = true;

  @override
  void initState() {
    super.initState();
    _controller = Provider.of<MyNewsController>(context, listen: false);

    _titleController = TextEditingController(text: widget.news?.title ?? '');
    _summaryController = TextEditingController(text: widget.news?.summary ?? '');
    _contentController = TextEditingController(text: widget.news?.content ?? '');
    _featuredImageUrlController = TextEditingController(text: widget.news?.featuredImageUrl ?? '');
    _categoryInputController = TextEditingController();
    _tagsNotifier = ValueNotifier<List<String>>(widget.news?.tags ?? []);
    _isPublished = widget.news?.isPublished ?? true;

    _controller.addListener(_showMessages);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _summaryController.dispose();
    _contentController.dispose();
    _featuredImageUrlController.dispose();
    _categoryInputController.dispose();
    _tagsNotifier.dispose();
    _controller.removeListener(_showMessages);
    super.dispose();
  }

  void _showMessages() {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    if (_controller.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_controller.errorMessage!),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 3),
        ),
      );
      _controller.clearErrorMessage();
    } else if (_controller.successMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_controller.successMessage!),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 3),
        ),
      );
      _controller.clearSuccessMessage();
    }
  }

  void _addTag() {
    final tagText = _categoryInputController.text.trim();
    if (tagText.isNotEmpty && !_tagsNotifier.value.contains(tagText)) {
      final updatedTags = List<String>.from(_tagsNotifier.value)..add(tagText);
      _tagsNotifier.value = updatedTags;
      _categoryInputController.clear();
    }
  }

  void _removeTag(String tag) {
    final updatedTags = List<String>.from(_tagsNotifier.value)..remove(tag);
    _tagsNotifier.value = updatedTags;
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      final newsData = NewsModel(
        id: widget.news?.id ?? '',
        title: _titleController.text.trim(),
        summary: _summaryController.text.trim(),
        content: _contentController.text.trim(),
        featuredImageUrl: _featuredImageUrlController.text.trim(),
        category: _tagsNotifier.value.isNotEmpty ? _tagsNotifier.value.first : 'Umum',
        publishedAt: widget.news?.publishedAt ?? DateTime.now(),
        tags: _tagsNotifier.value,
        isPublished: _isPublished,
        viewCount: widget.news?.viewCount ?? 0,
      );

      bool success;
      if (widget.news == null) {
        success = await _controller.createNews(newsData);
      } else {
        success = await _controller.updateNews(newsData);
      }

      if (success) {
        Navigator.pop(context, true);
      }
    }
  }

  Future<void> _generateSummary() async {
    final content = _contentController.text.trim();
    if (content.isEmpty) {
      _controller.setErrorMessage('Konten berita tidak boleh kosong untuk membuat ringkasan.');
      return;
    }
    final summary = await _controller.generateSummaryFromContent(content);
    if (summary.isNotEmpty) {
      _summaryController.text = summary;
    }
  }

  Future<void> _uploadFeaturedImage() async {
    final imageUrl = await _controller.uploadNewsImageAndGetUrl();
    if (imageUrl.isNotEmpty) {
      _featuredImageUrlController.text = imageUrl;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditMode = widget.news != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditMode ? 'Edit Berita' : 'Buat Berita Baru',
          style: AppTypography.headlineSmall.copyWith(color: AppColors.textBlack),
        ),
        centerTitle: true,
        backgroundColor: AppColors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textBlack),
          onPressed: () => Navigator.pop(context, false),
        ),
      ),
      body: Consumer<MyNewsController>(
        builder: (context, controller, child) {
          final bool anyLoading =
              controller.isLoading || controller.isGeneratingSummary || controller.isUploadingImage;

          return Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: AppSpacing.aPaddingLarge,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomTextField(
                          title: 'Judul Berita',
                          hintText: 'Masukkan judul berita',
                          controller: _titleController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Judul tidak boleh kosong';
                            }
                            return null;
                          },
                        ),
                        AppSpacing.vsMedium,
                        Text(
                          'Kategori (Tekan Enter atau ikon + untuk menambah)',
                          style: AppTypography.labelMedium,
                        ),
                        AppSpacing.vsTiny,
                        Row(
                          children: [
                            Expanded(
                              child: CustomTextField(
                                hintText: 'Tambah kategori...',
                                controller: _categoryInputController,
                                inputFormatters: [
                                  FilteringTextInputFormatter.deny(RegExp(r'[\n\r]')),
                                ],
                                onSubmitted: (value) => _addTag(),
                              ),
                            ),
                            AppSpacing.hsSmall,
                            GestureDetector(
                              onTap: _addTag,
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.add, color: AppColors.white),
                              ),
                            ),
                          ],
                        ),
                        AppSpacing.vsSmall,
                        ValueListenableBuilder<List<String>>(
                          valueListenable: _tagsNotifier,
                          builder: (context, tags, _) {
                            return Wrap(
                              spacing: 8.0,
                              runSpacing: 8.0,
                              children:
                                  tags.map((tag) {
                                    return Chip(
                                      label: Text(tag),
                                      deleteIcon: const Icon(Icons.close, size: 18),
                                      onDeleted: () => _removeTag(tag),
                                      backgroundColor: AppColors.secondary.withOpacity(0.1),
                                      labelStyle: AppTypography.labelSmall.copyWith(
                                        color: AppColors.secondary,
                                        fontWeight: AppTypography.semiBold,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      side: BorderSide(color: AppColors.secondary.withOpacity(0.3)),
                                    );
                                  }).toList(),
                            );
                          },
                        ),
                        AppSpacing.vsMedium,
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'URL Gambar Unggulan',
                              style: Theme.of(
                                context,
                              ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w500),
                            ),
                            AppSpacing.vsTiny,
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: CustomTextField(
                                    hintText: 'Masukkan URL gambar (opsional)',
                                    controller: _featuredImageUrlController,
                                    keyboardType: TextInputType.url,
                                  ),
                                ),
                                AppSpacing.hsSmall,
                                GestureDetector(
                                  onTap: controller.isUploadingImage ? null : _uploadFeaturedImage,
                                  child: Container(
                                    height: 50,
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child:
                                          controller.isUploadingImage
                                              ? SizedBox(
                                                width: 24,
                                                height: 24,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2.5,
                                                  valueColor: AlwaysStoppedAnimation<Color>(
                                                    AppColors.white,
                                                  ),
                                                ),
                                              )
                                              : const Icon(
                                                Icons.cloud_upload_outlined,
                                                color: AppColors.white,
                                              ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        AppSpacing.vsMedium,
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ringkasan Berita',
                              style: Theme.of(
                                context,
                              ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w500),
                            ),
                            AppSpacing.vsTiny,
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: CustomTextField(
                                    hintText: 'Masukkan ringkasan singkat berita',
                                    controller: _summaryController,
                                    maxLines: 3,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Ringkasan tidak boleh kosong';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                AppSpacing.hsSmall,
                                GestureDetector(
                                  onTap: controller.isGeneratingSummary ? null : _generateSummary,
                                  child: Container(
                                    height: 50,
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child:
                                          controller.isGeneratingSummary
                                              ? SizedBox(
                                                width: 24,
                                                height: 24,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2.5,
                                                  valueColor: AlwaysStoppedAnimation<Color>(
                                                    AppColors.white,
                                                  ),
                                                ),
                                              )
                                              : const Icon(
                                                Icons.auto_awesome,
                                                color: AppColors.white,
                                              ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        AppSpacing.vsMedium,
                        CustomTextField(
                          title: 'Konten Berita',
                          hintText: 'Masukkan konten lengkap berita',
                          controller: _contentController,
                          maxLines: 10,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Konten tidak boleh kosong';
                            }
                            return null;
                          },
                        ),
                        AppSpacing.vsXLarge,
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: AppSpacing.aPaddingMedium,
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    boxShadow: [
                      BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, -2)),
                    ],
                  ),
                  child: SafeArea(
                    top: false,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isEditMode)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: CustomButton(
                                    text: _isPublished ? 'Unpublish' : 'Publish',
                                    onPressed:
                                        anyLoading
                                            ? null
                                            : () async {
                                              final success = await controller.togglePublishStatus(
                                                widget.news!.id,
                                                !_isPublished,
                                              );
                                              if (success) {
                                                setState(() {
                                                  _isPublished = !_isPublished;
                                                });
                                                Navigator.pop(context, true);
                                              }
                                            },
                                    type: ButtonType.secondary,
                                  ),
                                ),
                                AppSpacing.hsSmall,
                                Expanded(
                                  child: CustomButton(
                                    text: 'Hapus',
                                    onPressed:
                                        anyLoading
                                            ? null
                                            : () async {
                                              final confirm = await _showConfirmDeleteDialog(
                                                context,
                                              );
                                              if (confirm == true) {
                                                final success = await controller.deleteNews(
                                                  widget.news!.id,
                                                );
                                                if (success) {
                                                  Navigator.pop(context, true);
                                                }
                                              }
                                            },
                                    type: ButtonType.outline,
                                    customOutlineColor: AppColors.error,
                                    customTextColor: AppColors.error,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        CustomButton(
                          text: isEditMode ? 'Simpan Perubahan' : 'Buat Berita',
                          onPressed: anyLoading ? null : _handleSubmit,
                          isLoading: controller.isLoading,
                          width: double.infinity,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<bool?> _showConfirmDeleteDialog(BuildContext buildContext) async {
    return showDialog<bool>(
      context: buildContext,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Konfirmasi Hapus'),
          content: const Text('Apakah Anda yakin ingin menghapus berita ini?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
            ),
            TextButton(
              child: Text('Hapus', style: TextStyle(color: AppColors.error)),
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
            ),
          ],
        );
      },
    );
  }
}
