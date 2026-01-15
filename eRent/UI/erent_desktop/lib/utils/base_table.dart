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
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: const Color(0xFF5B9BD5).withOpacity(0.08),
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
                // Compact modern header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white,
                        const Color(0xFF5B9BD5).withOpacity(0.02),
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    border: Border(
                      bottom: BorderSide(
                        color: const Color(0xFF5B9BD5).withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      if (icon != null) ...[
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF5B9BD5).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            icon!,
                            color: const Color(0xFF5B9BD5),
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              title ?? 'Data Table',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1F2937),
                                letterSpacing: -0.2,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${rows.length} ${rows.length == 1 ? 'item' : 'items'}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF5B9BD5).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${rows.length}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF5B9BD5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Table content
                Expanded(
                  child: SingleChildScrollView(
                    child: _buildModernDataTable(context),
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
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          width: double.infinity,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: tableWidth,
              child: DataTable(
                showCheckboxColumn: showCheckboxColumn,
                columnSpacing: columnSpacing,
                headingRowHeight: 48,
                dataRowMinHeight: 52,
                dataRowMaxHeight: 52,
                headingRowColor: WidgetStateProperty.all(
                  headingRowColor ?? Colors.transparent,
                ),
                dataRowColor: WidgetStateProperty.resolveWith<Color?>((states) {
                  if (states.contains(WidgetState.hovered)) {
                    return hoverRowColor ??
                        const Color(0xFF5B9BD5).withOpacity(0.04);
                  }
                  if (states.contains(WidgetState.selected)) {
                    return const Color(0xFF5B9BD5).withOpacity(0.08);
                  }
                  return null;
                }),
                columns: _buildModernColumns(context, tableWidth),
                rows: _buildModernRows(context, tableWidth),
                dataTextStyle: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF374151),
                  fontWeight: FontWeight.w400,
                  height: 1.4,
                ),
                headingTextStyle: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                  letterSpacing: 0.3,
                ),
                dividerThickness: 0,
                horizontalMargin: 0,
                border: TableBorder(
                  horizontalInside: BorderSide(
                    color: Colors.grey.withOpacity(0.06),
                    width: 1,
                  ),
                  bottom: BorderSide(
                    color: Colors.grey.withOpacity(0.06),
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
    final defaultPadding = const EdgeInsets.symmetric(vertical: 12, horizontal: 16);
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
    final defaultPadding = const EdgeInsets.symmetric(vertical: 12, horizontal: 16);
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
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (emptyIcon != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF5B9BD5).withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  emptyIcon,
                  size: 48,
                  color: const Color(0xFF5B9BD5),
                ),
              ),
            if (emptyText != null) ...[
              const SizedBox(height: 20),
              Text(
                emptyText!,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                  letterSpacing: -0.2,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (emptySubtext != null) ...[
              const SizedBox(height: 8),
              Text(
                emptySubtext!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.4,
                  fontWeight: FontWeight.w400,
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
