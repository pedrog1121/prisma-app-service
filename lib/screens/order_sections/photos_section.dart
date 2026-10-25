import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/app_store.dart';
import '../../data/mock_data.dart';
import '../../data/models.dart';
import '../../design/adaptive.dart';
import '../../design/components.dart';
import '../../design/tokens.dart';

/// Checklist del preventivo y fotos antes / durante / después.
class PhotosSection extends StatefulWidget {
  const PhotosSection({super.key, required this.order});

  final WorkOrder order;

  @override
  State<PhotosSection> createState() => _PhotosSectionState();
}

class _PhotosSectionState extends State<PhotosSection> {
  final _picker = ImagePicker();

  WorkOrder get o => widget.order;

  Future<void> _add(PhotoStage stage) async {
    final source = await showPrismaSheet<ImageSource>(
      context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(Space.gutter, 0, Space.gutter, Space.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Foto · ${stage.label}', style: ctx.tt.titleLarge),
              const SizedBox(height: Space.lg),
              GroupedSection(children: [
                GroupedTile(
                  icon: Icons.photo_camera_outlined,
                  title: 'Tomar foto',
                  onTap: () => Navigator.pop(ctx, ImageSource.camera),
                ),
                GroupedTile(
                  icon: Icons.photo_library_outlined,
                  title: 'Elegir de la galería',
                  onTap: () => Navigator.pop(ctx, ImageSource.gallery),
                ),
              ]),
            ],
          ),
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
      // Sin cámara (por ejemplo en la vista previa web): foto de ejemplo.
      final n = o.photos.length;
      photo = OrderPhoto(
        stage: stage,
        caption: 'Foto ${n + 1}',
        color: MockData.photoSwatches[n % MockData.photoSwatches.length],
      );
    }
    Haptics.success();
    setState(() => o.photos.add(photo));
    AppStore.instance.touch();
  }

  void _open(OrderPhoto p) {
    final tag = 'photo-${o.number}-${o.photos.indexOf(p)}';
    Navigator.of(context).push(PageRouteBuilder<void>(
      opaque: false,
      barrierColor: Colors.black,
      transitionDuration: Motion.medium,
      pageBuilder: (_, __, ___) => _PhotoViewer(photo: p, tag: tag),
      transitionsBuilder: (_, a, __, child) => FadeTransition(opacity: a, child: child),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.pc;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (o.checklist.isNotEmpty) ...[
          SectionLabel(
            'Checklist preventivo',
            padding: const EdgeInsets.fromLTRB(4, Space.md, 4, Space.sm),
            trailing: Text('${o.checklistDone} de ${o.checklist.length}', style: context.tt.labelMedium),
          ),
          PrismaCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(end: o.checklistDone / o.checklist.length),
                  duration: Motion.slow,
                  curve: Motion.enter,
                  builder: (_, v, __) => LinearProgressIndicator(
                    value: v,
                    minHeight: 4,
                    color: c.success,
                    backgroundColor: c.sunken,
                  ),
                ),
                for (var i = 0; i < o.checklist.length; i++)
                  _CheckRow(
                    item: o.checklist[i],
                    last: i == o.checklist.length - 1,
                    enabled: !o.isClosed,
                    onChanged: () {
                      Haptics.tap();
                      setState(() {});
                      AppStore.instance.touch();
                    },
                  ),
              ],
            ),
          ),
        ],
        for (final stage in PhotoStage.values) ...[
          SectionLabel(
            'Fotos · ${stage.label}',
            padding: EdgeInsets.fromLTRB(
                4, o.checklist.isEmpty && stage == PhotoStage.antes ? Space.md : Space.xxl, 4, Space.sm),
            trailing: Text('${o.photos.where((p) => p.stage == stage).length}', style: context.tt.labelMedium),
          ),
          SizedBox(
            height: 108,
            child: ListView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              physics: const BouncingScrollPhysics(),
              children: [
                if (!o.isClosed) _AddTile(onTap: () => _add(stage)),
                for (final p in o.photos.where((p) => p.stage == stage))
                  Padding(
                    padding: const EdgeInsets.only(left: Space.sm),
                    child: FadeSlideIn(
                      key: ObjectKey(p),
                      offset: 0,
                      child: _Thumb(
                        photo: p,
                        tag: 'photo-${o.number}-${o.photos.indexOf(p)}',
                        onTap: () => _open(p),
                        onRemove: o.isClosed
                            ? null
                            : () {
                                setState(() => o.photos.remove(p));
                                AppStore.instance.touch();
                              },
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _CheckRow extends StatelessWidget {
  const _CheckRow({required this.item, required this.last, required this.enabled, required this.onChanged});

  final ChecklistItem item;
  final bool last;
  final bool enabled;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.pc;
    return InkWell(
      onTap: enabled
          ? () {
              item.done = !item.done;
              onChanged();
            }
          : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: Space.lg, vertical: 13),
        decoration: BoxDecoration(
          border: last ? null : Border(bottom: BorderSide(color: c.border.withValues(alpha: 0.7))),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: Motion.medium,
              curve: Curves.easeOutBack,
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: item.done ? c.success : Colors.transparent,
                borderRadius: BorderRadius.circular(7),
                border: Border.all(color: item.done ? c.success : c.input, width: 1.5),
              ),
              child: AnimatedScale(
                scale: item.done ? 1 : 0,
                duration: Motion.medium,
                curve: Curves.easeOutBack,
                child: const Icon(Icons.check_rounded, size: 17, color: Colors.white),
              ),
            ),
            const SizedBox(width: Space.md),
            Expanded(
              child: AnimatedDefaultTextStyle(
                duration: Motion.fast,
                style: context.tt.bodyMedium!.copyWith(
                  color: item.done ? c.faint : c.foreground,
                  decoration: item.done ? TextDecoration.lineThrough : TextDecoration.none,
                  decorationColor: c.faint,
                ),
                child: Text(item.label),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddTile extends StatelessWidget {
  const _AddTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.pc;
    return Pressable(
      onTap: onTap,
      child: Container(
        width: 108,
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(Radii.lg),
          border: Border.all(color: c.input, style: BorderStyle.solid),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconBadge(icon: Icons.add_a_photo_outlined, color: c.onSelection, background: c.selection, size: 38),
            const SizedBox(height: 6),
            Text('Agregar', style: context.tt.labelMedium?.copyWith(color: c.foreground)),
          ],
        ),
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({required this.photo, required this.tag, required this.onTap, required this.onRemove});

  final OrderPhoto photo;
  final String tag;
  final VoidCallback onTap;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 108,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Pressable(
            onTap: onTap,
            child: Hero(
              tag: tag,
              child: ClipRRect(borderRadius: BorderRadius.circular(Radii.lg), child: PhotoImage(photo: photo)),
            ),
          ),
          if (onRemove != null)
            Positioned(
              top: 6,
              right: 6,
              child: GestureDetector(
                onTap: onRemove,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.5), shape: BoxShape.circle),
                  child: const Icon(Icons.close_rounded, size: 15, color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class PhotoImage extends StatelessWidget {
  const PhotoImage({super.key, required this.photo});

  final OrderPhoto photo;

  @override
  Widget build(BuildContext context) {
    if (photo.bytes != null) return Image.memory(photo.bytes!, fit: BoxFit.cover);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [photo.color!, Color.lerp(photo.color!, Colors.black, 0.45)!],
        ),
      ),
      child: Stack(
        children: [
          const Center(child: Icon(Icons.image_outlined, color: Colors.white70, size: 30)),
          Positioned(
            left: 8,
            bottom: 6,
            right: 8,
            child: Text(photo.caption,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}

class _PhotoViewer extends StatelessWidget {
  const _PhotoViewer({required this.photo, required this.tag});

  final OrderPhoto photo;
  final String tag;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        onTap: () => Navigator.pop(context),
        onVerticalDragEnd: (_) => Navigator.pop(context),
        child: SafeArea(
          child: Stack(
            children: [
              Center(
                child: Hero(
                  tag: tag,
                  child: AspectRatio(
                    aspectRatio: 3 / 4,
                    child: InteractiveViewer(child: PhotoImage(photo: photo)),
                  ),
                ),
              ),
              Positioned(
                top: Space.sm,
                left: Space.lg,
                right: Space.lg,
                child: Row(
                  children: [
                    Expanded(
                      child: Text('${photo.stage.label} · ${photo.caption}',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
