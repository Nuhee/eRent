import 'package:flutter/material.dart';

class BasePagination extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final VoidCallback? onNext;
  final VoidCallback? onPrevious;
  final bool showPageSizeSelector;
  final int pageSize;
  final List<int> pageSizeOptions;
  final ValueChanged<int?>? onPageSizeChanged;

  const BasePagination({
    super.key,
    required this.currentPage,
    required this.totalPages,
    this.onNext,
    this.onPrevious,
    this.showPageSizeSelector = false,
    this.pageSize = 10,
    this.pageSizeOptions = const [5, 7, 10, 20, 50],
    this.onPageSizeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left side: Page info and navigation
          Row(
            children: [
              // Page info
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Page ${currentPage + 1} of ${totalPages == 0 ? 1 : totalPages}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 24),

              // Previous button
              _buildNavigationButton(
                context,
                icon: Icons.chevron_left_rounded,
                label: 'Previous',
                onPressed: (currentPage == 0) ? null : onPrevious,
                isEnabled: currentPage > 0,
              ),

              const SizedBox(width: 12),

              // Next button
              _buildNavigationButton(
                context,
                icon: Icons.chevron_right_rounded,
                label: 'Next',
                onPressed: (currentPage >= totalPages - 1 || totalPages == 0)
                    ? null
                    : onNext,
                isEnabled: currentPage < totalPages - 1 && totalPages > 0,
                isNext: true,
              ),
            ],
          ),

          // Right side: Page size selector
          if (showPageSizeSelector)
            _PageSizeSelector(
              options: pageSizeOptions,
              selected: pageSize,
              onChanged: onPageSizeChanged,
            ),
        ],
      ),
    );
  }

  Widget _buildNavigationButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    required bool isEnabled,
    bool isNext = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: isEnabled
            ? [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isEnabled
              ? Theme.of(context).colorScheme.primary
              : Colors.grey[300],
          foregroundColor: isEnabled ? Colors.white : Colors.grey[500],
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          minimumSize: const Size(120, 44),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isNext) ...[Icon(icon, size: 20), const SizedBox(width: 8)],
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            if (isNext) ...[const SizedBox(width: 8), Icon(icon, size: 20)],
          ],
        ),
      ),
    );
  }
}

class _PageSizeSelector extends StatefulWidget {
  const _PageSizeSelector({
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  final List<int> options;
  final int selected;
  final ValueChanged<int?>? onChanged;

  @override
  State<_PageSizeSelector> createState() => _PageSizeSelectorState();
}

class _PageSizeSelectorState extends State<_PageSizeSelector>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<double> _scale;
  bool _open = false;
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _opacity = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _scale = Tween<double>(begin: 0.94, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );
  }

  @override
  void dispose() {
    _hideOverlay(removeOnly: true);
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _open = !_open;
      if (_open) {
        _showOverlay();
        _controller.forward();
      } else {
        _controller.reverse().then((_) => _hideOverlay());
      }
    });
  }

  void _showOverlay() {
    final overlay = Overlay.of(context);
    if (overlay == null) return;

    final RenderBox box = context.findRenderObject() as RenderBox;
    final Size buttonSize = box.size;
    final Offset buttonPosition = box.localToGlobal(Offset.zero);
    final double panelWidth = 180;
    final double panelHeight =
        widget.options.length * 42.0 + 20; // item height + padding

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _toggle,
              ),
            ),
            Positioned(
              left: buttonPosition.dx + buttonSize.width - panelWidth,
              top: buttonPosition.dy - panelHeight - 12,
              width: panelWidth,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) => Opacity(
                  opacity: _opacity.value,
                  child: Transform.scale(
                    scale: _scale.value,
                    alignment: Alignment.bottomRight,
                    child: child,
                  ),
                ),
                child: Material(
                  elevation: 8,
                  shadowColor: Colors.black.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: widget.options.map((option) {
                        final bool isSelected = widget.selected == option;
                        final theme = Theme.of(context);
                        final primary = theme.colorScheme.primary;
                        return InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () {
                            widget.onChanged?.call(option);
                            _toggle();
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 14,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: isSelected
                                  ? primary.withOpacity(0.08)
                                  : Colors.transparent,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  height: 16,
                                  width: 16,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isSelected
                                        ? primary
                                        : Colors.grey.withOpacity(0.3),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  option.toString(),
                                  style: TextStyle(
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                    color: isSelected
                                        ? primary
                                        : Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    overlay.insert(_overlayEntry!);
  }

  void _hideOverlay({bool removeOnly = false}) {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
    if (!removeOnly && mounted) {
      setState(() {
        _open = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    return GestureDetector(
      onTap: _toggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _open ? primary.withOpacity(0.25) : Colors.grey[200]!,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Rows per page',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                widget.selected.toString(),
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: primary,
                ),
              ),
            ),
            const SizedBox(width: 6),
            AnimatedRotation(
              turns: _open ? 0.5 : 0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
