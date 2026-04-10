import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/favourites_service.dart';

/// Common scaffold for all tool screens with consistent app bar and favourite button
class ToolScaffold extends StatefulWidget {
  final String toolId;
  final String title;
  final IconData icon;
  final Widget body;
  final List<Widget>? extraActions;

  const ToolScaffold({
    super.key,
    required this.toolId,
    required this.title,
    required this.icon,
    required this.body,
    this.extraActions,
  });

  @override
  State<ToolScaffold> createState() => _ToolScaffoldState();
}

class _ToolScaffoldState extends State<ToolScaffold> {
  bool _isFavourite = false;

  @override
  void initState() {
    super.initState();
    _checkFavourite();
  }

  Future<void> _checkFavourite() async {
    final fav = await FavouritesService.isFavourite(widget.toolId);
    if (mounted) setState(() => _isFavourite = fav);
  }

  Future<void> _toggleFavourite() async {
    HapticFeedback.selectionClick();
    await FavouritesService.toggle(widget.toolId);
    _checkFavourite();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(widget.icon, size: 22),
            const SizedBox(width: 8),
            Text(widget.title),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isFavourite ? Icons.star : Icons.star_outline,
              color: _isFavourite ? Colors.amber : null,
            ),
            tooltip: _isFavourite ? 'Remove from favourites' : 'Add to favourites',
            onPressed: _toggleFavourite,
          ),
          if (widget.extraActions != null) ...widget.extraActions!,
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: widget.body,
      ),
    );
  }
}
