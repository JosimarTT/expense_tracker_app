import 'package:flutter/material.dart';

import '../../../core/money/currency.dart';
import 'currency_widgets.dart';

class CurrencyPickerDialog extends StatefulWidget {
  const CurrencyPickerDialog({required this.selectedCode, super.key});

  final String selectedCode;

  @override
  State<CurrencyPickerDialog> createState() => _CurrencyPickerDialogState();
}

class _CurrencyPickerDialogState extends State<CurrencyPickerDialog> {
  final _search = TextEditingController();
  final _scroll = ScrollController();

  @override
  void dispose() {
    _search.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _searchChanged() {
    setState(() {});
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final media = MediaQuery.of(context);
    final query = _search.text.trim();
    final currencies = Currency.supported
        .where((item) => item.matches(query))
        .toList();
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 480,
          maxHeight:
              (media.size.height -
                  media.viewInsets.bottom -
                  media.padding.vertical) *
              0.85,
        ),
        child: SingleChildScrollView(
          controller: _scroll,
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Choose currency', style: theme.textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(
                'Choose the currency for this profile.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _search,
                decoration: InputDecoration(
                  labelText: 'Search currencies',
                  hintText: 'Name, code, or country',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _search.text.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Clear currency search',
                          onPressed: () {
                            _search.clear();
                            _searchChanged();
                          },
                          icon: const Icon(Icons.close),
                        ),
                ),
                onChanged: (_) => _searchChanged(),
              ),
              const SizedBox(height: 16),
              if (query.isEmpty) ...[
                Text('Popular currencies', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                PopularCurrencyChips(
                  selectedCode: widget.selectedCode,
                  onSelected: (code) => Navigator.pop(context, code),
                ),
                const SizedBox(height: 20),
              ],
              Semantics(
                liveRegion: true,
                child: Text(
                  query.isEmpty
                      ? 'All currencies (${currencies.length})'
                      : '${currencies.length} matching currencies',
                  style: theme.textTheme.titleMedium,
                ),
              ),
              const SizedBox(height: 8),
              if (currencies.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    'No matching currencies.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: colors.onSurfaceVariant),
                  ),
                )
              else
                for (final currency in currencies)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Semantics(
                      selected: currency.code == widget.selectedCode,
                      button: true,
                      child: Material(
                        color: currency.code == widget.selectedCode
                            ? colors.primaryContainer
                            : colors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(20),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          key: ValueKey('currency-${currency.code}'),
                          onTap: () => Navigator.pop(context, currency.code),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CurrencyBadge(code: currency.code),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        currency.code,
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                              color:
                                                  currency.code ==
                                                      widget.selectedCode
                                                  ? colors.onPrimaryContainer
                                                  : colors.onSurface,
                                            ),
                                      ),
                                      Text(
                                        currency.name,
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              color:
                                                  currency.code ==
                                                      widget.selectedCode
                                                  ? colors.onPrimaryContainer
                                                  : colors.onSurfaceVariant,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (currency.code == widget.selectedCode) ...[
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.check_circle,
                                    color: colors.onPrimaryContainer,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
