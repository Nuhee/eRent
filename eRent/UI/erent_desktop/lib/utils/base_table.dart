import 'package:flutter/material.dart';

class BaseTable extends StatelessWidget {
  final double width;
  final double height;
  final List<DataColumn> columns;
  final List<DataRow> rows;
  final Widget? emptyState;
  final IconData? emptyIcon;
  final String? emptyText;
  final String? emptySubtext;
  final bool showCheckboxColumn;
  final double columnSpacing;
  final Color? headingRowColor;
  final Color? hoverRowColor;
  final EdgeInsetsGeometry? padding;
  final String? title;
  final IconData? icon;
  final List<double>? columnWidths;
  final Set<int>? imageColumnIndices;
  final EdgeInsetsGeometry? imageColumnPadding;

  const BaseTable({
    super.key,
    required this.width,
    required this.height,
    required this.columns,
    required this.rows,
    this.emptyState,
    this.emptyIcon,
    this.emptyText,
    this.emptySubtext,
    this.showCheckboxColumn = false,
    this.columnSpacing = 24,
    this.headingRowColor,
    this.hoverRowColor,
    this.padding,
    this.title,
    this.icon,
    this.columnWidths,
    this.imageColumnIndices,
    this.imageColumnPadding,
  });

  @override
  Widget build(BuildContext context) {
    final bool isEmpty = rows.isEmpty;
    return Container(
      width: width,
      constraints: BoxConstraints(minHeight: height * 0.8, maxHeight: height),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.withOpacity(0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 24,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: const Color(0xFF8B6F47).withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: isEmpty
          ? (emptyState ?? _defaultEmptyState())
          : Column(
              children: [
                // Modern header with elegant design
                Container(
                  padding: const EdgeInsets.fromLTRB(28, 22, 28, 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    border: Border(
                      bottom: BorderSide(
                        color: const Color(0xFF8B6F47).withOpacity(0.2),
                        width: 2,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      if (icon != null)
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFF8B6F47),
                                Color(0xFF6B5434),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF8B6F47).withOpacity(0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            icon!,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      if (icon != null) const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              title ?? 'Data Table',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF2D2D2D),
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  width: 4,
                                  height: 4,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF8B6F47),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${rows.length} ${rows.length == 1 ? 'item' : 'items'}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[600],
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF8B6F47).withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF8B6F47).withOpacity(0.2),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.table_chart_rounded,
                              size: 18,
                              color: const Color(0xFF8B6F47),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${rows.length}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF8B6F47),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Table content
                Expanded(
                  child: Container(
                    padding: padding ?? EdgeInsets.zero,
                    child: SingleChildScrollView(
                      child: _buildModernDataTable(context),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildModernDataTable(BuildContext context) {
    if (rows.isEmpty) {
      return Container(
        height: 100,
        alignment: Alignment.center,
        child: Text('No data available'),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate table width based on column widths or use constraints
        double tableWidth;
        if (columnWidths != null && columnWidths!.isNotEmpty) {
          // Sum of all column widths plus spacing between columns
          tableWidth = columnWidths!.fold(0.0, (sum, width) => sum + width) +
              (columnWidths!.length - 1) * columnSpacing;
        } else {
          tableWidth = constraints.maxWidth;
        }

        return Container(
          margin: const EdgeInsets.all(16),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey.withOpacity(0.12),
              width: 1.5,
            ),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: tableWidth,
              child: DataTable(
                showCheckboxColumn: showCheckboxColumn,
                columnSpacing: columnSpacing,
                headingRowColor: WidgetStateProperty.all(
                  headingRowColor ?? const Color(0xFFF8F9FA),
                ),
                dataRowColor: WidgetStateProperty.resolveWith<Color?>((states) {
                  if (states.contains(WidgetState.hovered)) {
                    return hoverRowColor ??
                        const Color(0xFF8B6F47).withOpacity(0.06);
                  }
                  if (states.contains(WidgetState.selected)) {
                    return const Color(0xFF8B6F47).withOpacity(0.1);
                  }
                  return null;
                }),
                columns: _buildModernColumns(context, tableWidth),
                rows: _buildModernRows(context, tableWidth),
                dataTextStyle: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF1F2937),
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                ),
                headingTextStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2D2D2D),
                  letterSpacing: 0.5,
                ),
                dividerThickness: 1.5,
                border: TableBorder(
                  horizontalInside: BorderSide(
                    color: Colors.grey.withOpacity(0.12),
                    width: 1,
                  ),
                  verticalInside: BorderSide(
                    color: Colors.grey.withOpacity(0.12),
                    width: 1,
                  ),
                  bottom: BorderSide(
                    color: Colors.grey.withOpacity(0.15),
                    width: 1,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  List<DataColumn> _buildModernColumns(
    BuildContext context,
    double tableWidth,
  ) {
    // Use custom column widths if provided, otherwise distribute evenly
    List<double> widths;
    if (columnWidths != null && columnWidths!.length == columns.length) {
      widths = columnWidths!;
    } else {
      double columnWidth = tableWidth / columns.length;
      widths = List.filled(columns.length, columnWidth);
    }

    // Default padding for regular columns
    final defaultPadding = const EdgeInsets.symmetric(vertical: 16, horizontal: 12);
    // Reduced padding for image columns
    final imagePadding = imageColumnPadding ?? const EdgeInsets.symmetric(vertical: 8, horizontal: 8);

    return columns.asMap().entries.map((entry) {
      int index = entry.key;
      DataColumn column = entry.value;
      final isImageColumn = imageColumnIndices != null && imageColumnIndices!.contains(index);
      return DataColumn(
        label: Container(
          width: widths[index],
          padding: isImageColumn ? imagePadding : defaultPadding,
          child: column.label,
        ),
      );
    }).toList();
  }

  List<DataRow> _buildModernRows(BuildContext context, double tableWidth) {
    // Use custom column widths if provided, otherwise distribute evenly
    List<double> widths;
    if (columnWidths != null && columnWidths!.length == columns.length) {
      widths = columnWidths!;
    } else {
      double columnWidth = tableWidth / columns.length;
      widths = List.filled(columns.length, columnWidth);
    }

    // Default padding for regular columns
    final defaultPadding = const EdgeInsets.symmetric(vertical: 14, horizontal: 12);
    // Reduced padding for image columns
    final imagePadding = imageColumnPadding ?? const EdgeInsets.symmetric(vertical: 8, horizontal: 8);

    return rows.map((row) {
      return DataRow(
        onSelectChanged: row.onSelectChanged,
        cells: row.cells.asMap().entries.map((entry) {
          int index = entry.key;
          DataCell cell = entry.value;
          final isImageColumn = imageColumnIndices != null && imageColumnIndices!.contains(index);
          return DataCell(
            Container(
              width: widths[index],
              padding: isImageColumn ? imagePadding : defaultPadding,
              alignment: Alignment.centerLeft,
              child: cell.child,
            ),
          );
        }).toList(),
      );
    }).toList();
  }

  Widget _defaultEmptyState() {
    if (emptyIcon == null && emptyText == null && emptySubtext == null) {
      return Center(
        child: Text(
          'No data',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }
    return Center(
      child: Container(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (emptyIcon != null)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF8B6F47).withOpacity(0.1),
                      const Color(0xFF8B6F47).withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(60),
                  border: Border.all(
                    color: const Color(0xFF8B6F47).withOpacity(0.2),
                    width: 2,
                  ),
                ),
                child: Icon(
                  emptyIcon,
                  size: 56,
                  color: const Color(0xFF8B6F47),
                ),
              ),
            if (emptyText != null) ...[
              const SizedBox(height: 28),
              Text(
                emptyText!,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2D2D2D),
                  letterSpacing: 0.3,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (emptySubtext != null) ...[
              const SizedBox(height: 12),
              Text(
                emptySubtext!,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[600],
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
