import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
import '../core/breakpoints.dart';
import '../core/load_status.dart';
import '../models/meal.dart';
import '../providers/recipe_detail_provider.dart';
import '../providers/saved_recipe_provider.dart';
import '../widgets/meal_image.dart';
import '../widgets/state_view.dart';
import 'recipe_note_screen.dart';

/// Detail satu resep.
///
/// Data awal diterima lewat konstruktor (passing data dari list) sehingga
/// judul dan gambar langsung tampil. Bahan dan langkah dimuat lewat
/// [RecipeDetailProvider] bila belum tersedia.
///
/// Compact : foto penuh di atas, lembar isi menimpa bagian bawah foto.
/// Expanded: foto di kiri, isi yang bisa digulir di kanan.
class RecipeDetailScreen extends StatefulWidget {
  final Meal meal;

  const RecipeDetailScreen({super.key, required this.meal});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  static const double _maxContentWidth = 1100;
  static const double _photoHeight = 300;
  static const double _sheetOverlap = 36;

  @override
  void initState() {
    super.initState();
    final provider = context.read<RecipeDetailProvider>();
    // Ditunda sampai frame pertama selesai: provider memanggil
    // notifyListeners, dan itu tidak boleh terjadi saat widget dibangun.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) provider.load(widget.meal);
    });
  }

  /// Membuka screen form catatan dan rating, lalu menyimpan bila dikonfirmasi.
  Future<void> _save(Meal meal) async {
    final input = await RecipeNoteScreen.open(context, meal.name);
    if (input == null || !mounted) return;

    final error = await context.read<SavedRecipeProvider>().save(
      meal,
      note: input.note,
      rating: input.rating,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(error ?? 'Tersimpan di koleksi.')));
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RecipeDetailProvider>();
    final id = widget.meal.id;
    // Pakai detail lengkap bila sudah ada, kalau belum pakai data dari list.
    final meal = provider.detailOf(id) ?? widget.meal;

    final info = _DetailInfo(
      meal: meal,
      status: provider.statusOf(id),
      errorMessage: provider.errorOf(id),
      onRetry: () => provider.load(widget.meal),
    );

    return Scaffold(
      bottomNavigationBar: _SaveBar(onPressed: () => _save(meal)),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final expanded = Breakpoints.isExpanded(constraints.maxWidth);
          return expanded ? _buildWide(meal, info) : _buildCompact(meal, info);
        },
      ),
    );
  }

  /// Layar sempit: foto penuh, lembar isi menimpa bagian bawahnya.
  Widget _buildCompact(Meal meal, Widget info) {
    return Stack(
      children: [
        SingleChildScrollView(
          child: Stack(
            children: [
              SizedBox(
                width: double.infinity,
                height: _photoHeight,
                child: MealImage(url: meal.thumbnailUrl, iconSize: 64),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  top: _photoHeight - _sheetOverlap,
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                  decoration: const BoxDecoration(
                    color: AppTheme.background,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(32),
                    ),
                  ),
                  child: info,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: _TopActions(onSave: () => _save(meal)),
            ),
          ),
        ),
      ],
    );
  }

  /// Layar lebar: foto di kiri, isi di kanan.
  Widget _buildWide(Meal meal, Widget info) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _maxContentWidth),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: MealImage(
                            url: meal.thumbnailUrl,
                            iconSize: 64,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 12,
                        left: 12,
                        right: 12,
                        child: _TopActions(onSave: () => _save(meal)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(flex: 3, child: SingleChildScrollView(child: info)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Tombol kembali dan simpan berbentuk lingkaran putih di atas foto.
class _TopActions extends StatelessWidget {
  final VoidCallback onSave;

  const _TopActions({required this.onSave});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        BackButton(
          style: IconButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: AppTheme.ink,
            elevation: 3,
            shadowColor: Colors.black38,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.bookmark_add_outlined),
          tooltip: 'Simpan ke koleksi',
          style: IconButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: AppTheme.primary,
            elevation: 3,
            shadowColor: Colors.black38,
          ),
          onPressed: onSave,
        ),
      ],
    );
  }
}

/// Bilah aksi tetap di bawah layar.
class _SaveBar extends StatelessWidget {
  final VoidCallback onPressed;

  const _SaveBar({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 12,
      shadowColor: const Color(0x40000000),
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
          child: Align(
            heightFactor: 1,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onPressed,
                  icon: const Icon(Icons.bookmark_add),
                  label: const Text('Simpan ke koleksi'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailInfo extends StatelessWidget {
  final Meal meal;
  final LoadStatus status;
  final String? errorMessage;
  final VoidCallback onRetry;

  const _DetailInfo({
    required this.meal,
    required this.status,
    required this.errorMessage,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final category = meal.category;
    final area = meal.area;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(meal.name, style: theme.textTheme.headlineSmall),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (category != null)
              _Pill(
                label: category,
                background: AppTheme.primary.withValues(alpha: 0.10),
                foreground: AppTheme.primary,
              ),
            if (area != null)
              _Pill(
                label: area,
                background: AppTheme.accent.withValues(alpha: 0.28),
                foreground: AppTheme.ink,
              ),
          ],
        ),
        const SizedBox(height: 20),
        _buildBody(),
      ],
    );
  }

  Widget _buildBody() {
    // Data dari list sudah lengkap: tampilkan langsung tanpa menunggu.
    if (meal.ingredients.isNotEmpty || meal.steps.isNotEmpty) {
      return _DetailContent(meal: meal);
    }

    switch (status) {
      case LoadStatus.initial:
      case LoadStatus.loading:
        return const StateView(type: StateViewType.loading);
      case LoadStatus.error:
        return StateView(
          type: StateViewType.error,
          message: errorMessage,
          onRetry: onRetry,
        );
      case LoadStatus.empty:
      case LoadStatus.success:
        return const StateView(
          type: StateViewType.empty,
          message: 'Detail resep belum tersedia.',
        );
    }
  }
}

/// Label kecil berbentuk pil (kategori dan asal resep).
class _Pill extends StatelessWidget {
  final String label;
  final Color background;
  final Color foreground;

  const _Pill({
    required this.label,
    required this.background,
    required this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: ShapeDecoration(
        color: background,
        shape: const StadiumBorder(),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        child: Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            fontSize: 12,
            color: foreground,
          ),
        ),
      ),
    );
  }
}

class _DetailContent extends StatefulWidget {
  final Meal meal;

  const _DetailContent({required this.meal});

  @override
  State<_DetailContent> createState() => _DetailContentState();
}

class _DetailContentState extends State<_DetailContent> {
  // Indeks bahan yang sudah dicentang (hanya state tampilan).
  final Set<int> _checked = {};

  void _toggle(int index) {
    setState(() {
      if (!_checked.add(index)) _checked.remove(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ingredients = widget.meal.ingredients;
    final steps = widget.meal.steps;

    final tiles = <Widget>[
      if (ingredients.isNotEmpty)
        _InfoTile(
          icon: Icons.shopping_basket_outlined,
          label: '${ingredients.length} bahan',
        ),
      if (steps.isNotEmpty)
        _InfoTile(
          icon: Icons.format_list_numbered,
          label: '${steps.length} langkah',
        ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (tiles.isNotEmpty) ...[
          Row(
            children: [
              for (var i = 0; i < tiles.length; i++) ...[
                if (i > 0) const SizedBox(width: 12),
                Expanded(child: tiles[i]),
              ],
            ],
          ),
          const SizedBox(height: 24),
        ],
        if (ingredients.isNotEmpty) ...[
          Text('Bahan', style: theme.textTheme.titleMedium),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 10,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                for (final (index, item) in ingredients.indexed)
                  _IngredientRow(
                    name: item.name,
                    measure: item.measure,
                    checked: _checked.contains(index),
                    onToggle: () => _toggle(index),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
        if (steps.isNotEmpty) ...[
          Text('Langkah memasak', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          for (final (index, step) in steps.indexed)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: AppTheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${index + 1}',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontSize: 13,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Text(
                        step,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: 1.5,
                        ),
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

/// Petak ringkasan kecil (jumlah bahan atau langkah).
class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoTile({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE4DEDC)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppTheme.accent.withValues(alpha: 0.28),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: AppTheme.primary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleSmall,
            ),
          ),
        ],
      ),
    );
  }
}

/// Satu baris bahan dengan kotak centang. Bahan yang dicentang dicoret.
class _IngredientRow extends StatelessWidget {
  final String name;
  final String measure;
  final bool checked;
  final VoidCallback onToggle;

  const _IngredientRow({
    required this.name,
    required this.measure,
    required this.checked,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.bodyMedium?.copyWith(
      decoration: checked ? TextDecoration.lineThrough : null,
      color: checked ? AppTheme.inkSoft : AppTheme.ink,
    );

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onToggle,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Checkbox(
              value: checked,
              onChanged: (_) => onToggle(),
              activeColor: AppTheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            Expanded(flex: 3, child: Text(name, style: style)),
            if (measure.isNotEmpty)
              Flexible(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8, right: 8),
                  child: Text(
                    measure,
                    textAlign: TextAlign.end,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.inkSoft,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
