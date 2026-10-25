import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/app_store.dart';
import '../../data/mock_data.dart';
import '../../data/models.dart';
import '../../theme.dart';
import '../../widgets/common.dart';

/// Checklist del preventivo y fotos antes / durante / después.
class PhotosTab extends StatefulWidget {
  const PhotosTab({super.key, required this.order});

  final WorkOrder order;

  @override
  State<PhotosTab> createState() => _PhotosTabState();
}

class _PhotosTabState extends State<PhotosTab> {
  final _picker = ImagePicker();

  Future<void> _addPhoto(PhotoStage stage) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text('Foto "${stage.label}"',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_rounded),
              title: const Text('Tomar foto'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: const Text('Elegir de la galería'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (source == null) return;

    OrderPhoto photo;
    try {
      final file = await _picker.pickImage(source: source, maxWidth: 1600, imageQuality: 80);
      if (file == null) return;
      photo = OrderPhoto(stage: stage, caption: file.name, bytes: await file.readAsBytes());
    } catch (_) {
      // Sin cámara (por ejemplo en la vista previa web): agrega una foto de ejemplo.
      final n = widget.order.photos.length;
      photo = OrderPhoto(
        stage: stage,
        caption: 'Foto de ejemplo ${n + 1}',
        color: MockData.photoSwatches[n % MockData.photoSwatches.length],
      );
    }
    setState(() => widget.order.photos.add(photo));
    AppStore.instance.touch();
  }

  @override
  Widget build(BuildContext context) {
    final o = widget.order;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      children: [
        if (o.checklist.isNotEmpty) ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionTitle(
                    'Checklist preventivo',
                    trailing: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Text('${o.checklistDone}/${o.checklist.length}',
                          style: const TextStyle(
                              color: AppColors.primary, fontWeight: FontWeight.w700)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 8, bottom: 6),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: o.checklistDone / o.checklist.length,
                        minHeight: 6,
                        backgroundColor: AppColors.border,
                      ),
                    ),
                  ),
                  for (final item in o.checklist)
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      controlAffinity: ListTileControlAffinity.leading,
                      value: item.done,
                      onChanged: o.isClosed
                          ? null
                          : (v) {
                              setState(() => item.done = v ?? false);
                              AppStore.instance.touch();
                            },
                      title: Text(item.label,
                          style: TextStyle(
                            fontSize: 13.5,
                            decoration: item.done ? TextDecoration.lineThrough : null,
                            color: item.done ? AppColors.muted : AppColors.text,
                          )),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        for (final stage in PhotoStage.values) ...[
          _StageSection(
            stage: stage,
            photos: o.photos.where((p) => p.stage == stage).toList(),
            onAdd: o.isClosed ? null : () => _addPhoto(stage),
            onRemove: o.isClosed
                ? null
                : (p) {
                    setState(() => o.photos.remove(p));
                    AppStore.instance.touch();
                  },
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _StageSection extends StatelessWidget {
  const _StageSection({
    required this.stage,
    required this.photos,
    required this.onAdd,
    required this.onRemove,
  });

  final PhotoStage stage;
  final List<OrderPhoto> photos;
  final VoidCallback? onAdd;
  final ValueChanged<OrderPhoto>? onRemove;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionTitle(
              'Fotos · ${stage.label}',
              trailing: Text('${photos.length}', style: const TextStyle(color: AppColors.muted)),
            ),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              children: [
                for (final p in photos) _PhotoThumb(photo: p, onRemove: onRemove),
                if (onAdd != null)
                  InkWell(
                    onTap: onAdd,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: AppColors.primary.withValues(alpha: 0.05),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo_rounded, color: AppColors.primary),
                          SizedBox(height: 4),
                          Text('Agregar',
                              style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoThumb extends StatelessWidget {
  const _PhotoThumb({required this.photo, required this.onRemove});

  final OrderPhoto photo;
  final ValueChanged<OrderPhoto>? onRemove;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (photo.bytes != null)
            Image.memory(photo.bytes!, fit: BoxFit.cover)
          else
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [photo.color!, Color.lerp(photo.color!, Colors.black, 0.35)!],
                ),
              ),
              child: const Icon(Icons.image_rounded, color: Colors.white70, size: 30),
            ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(6, 10, 6, 4),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black54],
                ),
              ),
              child: Text(photo.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontSize: 10.5)),
            ),
          ),
          if (onRemove != null)
            Positioned(
              top: 4,
              right: 4,
              child: InkWell(
                onTap: () => onRemove!(photo),
                child: const CircleAvatar(
                  radius: 11,
                  backgroundColor: Colors.black45,
                  child: Icon(Icons.close_rounded, size: 14, color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
