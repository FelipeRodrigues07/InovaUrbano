import 'package:flutter/material.dart';
import 'package:planejamento_urbano/models/br_city.dart';

/// City search field, IBGE results list, error text, and recent chips (shared by screens).
class CitySearchCard extends StatelessWidget {
  const CitySearchCard({
    super.key,
    required this.cityController,
    required this.cityFocusNode,
    required this.isSearchingCity,
    required this.isLocating,
    required this.isResolvingCity,
    required this.citySearchQuery,
    required this.citySearchResults,
    required this.cityError,
    required this.selectedCity,
    required this.recentCities,
    required this.onCityQueryChanged,
    required this.onMyLocation,
    required this.onSelectCity,
  });

  final TextEditingController cityController;
  final FocusNode cityFocusNode;
  final bool isSearchingCity;
  final bool isLocating;
  final bool isResolvingCity;
  final String citySearchQuery;
  final List<BrCity> citySearchResults;
  final String? cityError;
  final BrCity? selectedCity;
  final List<BrCity> recentCities;
  final ValueChanged<String> onCityQueryChanged;
  final VoidCallback onMyLocation;
  final ValueChanged<BrCity> onSelectCity;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: cityController,
                    focusNode: cityFocusNode,
                    decoration: InputDecoration(
                      hintText: 'Buscar cidade (ex.: Anápolis)',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: isSearchingCity
                          ? const Padding(
                              padding: EdgeInsets.all(12.0),
                              child: SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          : (cityController.text.trim().isEmpty
                              ? null
                              : IconButton(
                                  tooltip: 'Limpar',
                                  onPressed: () {
                                    cityController.clear();
                                    onCityQueryChanged('');
                                    FocusScope.of(context)
                                        .requestFocus(cityFocusNode);
                                  },
                                  icon: const Icon(Icons.close),
                                )),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF5F7FB),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                    onChanged: onCityQueryChanged,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  tooltip: 'Usar minha localização',
                  onPressed: isLocating ? null : onMyLocation,
                  icon: isLocating
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.my_location),
                ),
              ],
            ),
            if (cityFocusNode.hasFocus &&
                citySearchQuery.trim().length >= 2 &&
                citySearchResults.isNotEmpty) ...[
              const SizedBox(height: 8),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black12),
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 220),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: citySearchResults.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final city = citySearchResults[index];
                      return ListTile(
                        dense: true,
                        title: Text(city.name),
                        subtitle: Text(city.uf),
                        onTap: isResolvingCity ? null : () => onSelectCity(city),
                      );
                    },
                  ),
                ),
              ),
            ],
            if (cityError != null) ...[
              const SizedBox(height: 8),
              Text(
                cityError!,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                ),
              ),
            ],
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  if (selectedCity != null) ...[
                    ActionChip(
                      label: Text(selectedCity!.label),
                      avatar: const Icon(Icons.location_city, size: 18),
                      onPressed: isResolvingCity
                          ? null
                          : () => onSelectCity(selectedCity!),
                    ),
                  ],
                  if (recentCities.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    const Text(
                      'Recentes: ',
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                    const SizedBox(width: 6),
                    ...recentCities.take(6).map((c) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: InputChip(
                          label: Text(c.name),
                          onPressed:
                              isResolvingCity ? null : () => onSelectCity(c),
                        ),
                      );
                    }),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
