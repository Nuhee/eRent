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
    final primary = const Color(0xFF5B9BD5);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left side: Navigation buttons and page info
          Row(
            children: [
              // Previous button
              _buildIconButton(
                icon: Icons.chevron_left_rounded,
                onPressed: currentPage > 0 ? onPrevious : null,
                isEnabled: currentPage > 0,
                primary: primary,
              ),
              const SizedBox(width: 12),
              
              // Page info
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${currentPage + 1} / ${totalPages == 0 ? 1 : totalPages}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: primary,
                    fontSize: 13,
                  ),
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Next button
              _buildIconButton(
                icon: Icons.chevron_right_rounded,
                onPressed: (currentPage < totalPages - 1 && totalPages > 0) ? onNext : null,
                isEnabled: currentPage < totalPages - 1 && totalPages > 0,
                primary: primary,
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

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required bool isEnabled,
    required Color primary,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onPressed,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isEnabled
                ? primary.withOpacity(0.1)
                : Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isEnabled
                  ? primary.withOpacity(0.2)
                  : Colors.grey.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            size: 20,
            color: isEnabled ? primary : Colors.grey[400],
          ),
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
                  elevation: 4,
                  shadowColor: Colors.black.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.grey.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: widget.options.map((option) {
                        final bool isSelected = widget.selected == option;
                        final primary = const Color(0xFF5B9BD5);
                        return InkWell(
                          borderRadius: BorderRadius.circular(6),
                          onTap: () {
                            widget.onChanged?.call(option);
                            _toggle();
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 14,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? primary.withOpacity(0.08)
                                  : Colors.transparent,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  height: 14,
                                  width: 14,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isSelected
                                        ? primary
                                        : Colors.grey.withOpacity(0.2),
                                    border: Border.all(
                                      color: isSelected
                                          ? primary
                                          : Colors.grey.withOpacity(0.3),
                                      width: isSelected ? 0 : 1,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  option.toString(),
                                  style: TextStyle(
                                    fontSize: 13,
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
    final primary = const Color(0xFF5B9BD5);
    return GestureDetector(
      onTap: _toggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _open 
                ? primary.withOpacity(0.3) 
                : Colors.grey.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Show',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                widget.selected.toString(),
                style: TextStyle(
                  fontSize: 13,
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
                size: 18,
                color: primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
