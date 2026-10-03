import 'package:flutter/material.dart';
import '../../models/weather_models.dart';
import '../../l10n/app_strings.dart';
import '../../theme/weatherly_palette.dart';
import '../../theme/weatherly_responsive.dart';
import '../../utils/weather_utils.dart';
import '../weatherly_logo.dart';

class CitiesScreen extends StatefulWidget {
  const CitiesScreen({
    super.key,
    required this.searchController,
    required this.savedLocations,
    required this.savedWeather,
    required this.savedLoading,
    required this.activeLocation,
    required this.suggestions,
    required this.onSearchChanged,
    required this.onSelectSuggestion,
    required this.onSelectSaved,
    required this.onRemoveSaved,
    required this.onReorderSaved,
    required this.onExploreMap,
    required this.onSearchSubmit,
    required this.searchFocusNode,
  });

  final TextEditingController searchController;
  final FocusNode searchFocusNode;
  final List<LocationOption> savedLocations;
  final List<WeatherResult> savedWeather;
  final bool savedLoading;
  final LocationOption? activeLocation;
  final List<LocationOption> suggestions;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<LocationOption> onSelectSuggestion;
  final ValueChanged<LocationOption> onSelectSaved;
  final ValueChanged<LocationOption> onRemoveSaved;
  final void Function(int oldIndex, int newIndex) onReorderSaved;
  final VoidCallback onExploreMap;
  final ValueChanged<String> onSearchSubmit;

  @override
  State<CitiesScreen> createState() => _CitiesScreenState();
}

class _CitiesScreenState extends State<CitiesScreen> {
  bool _editing = false;

  WeatherResult? _weatherFor(LocationOption loc) {
    for (final w in widget.savedWeather) {
      if (locationsMatch(w.location, loc)) {
        return w;
      }
    }
    return null;
  }

  bool _isActive(LocationOption loc) {
    final active = widget.activeLocation;
    if (active == null) {
      return false;
    }
    return locationsMatch(active, loc);
  }

  @override
  Widget build(BuildContext context) {
    final lay = context.weatherly;
    final p = context.palette;

    return SafeArea(
      bottom: false,
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _CitiesTopBar(title: AppStrings.appTitle),
        Expanded(
          child: Container(
            decoration: BoxDecoration(gradient: p.citiesPageBackground),
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                lay.pagePaddingH,
                lay.pagePaddingV,
                lay.pagePaddingH,
                lay.scrollBottomInset,
              ),
              children: [
                _CitySearchField(
                  controller: widget.searchController,
                  focusNode: widget.searchFocusNode,
                  hint: AppStrings.citiesSearchPlaceholder,
                  onChanged: widget.onSearchChanged,
                  onSubmitted: widget.onSearchSubmit,
                ),
                if (widget.suggestions.isNotEmpty) ...[
                  SizedBox(height: lay.gapS),
                  ...widget.suggestions.map(
                    (s) => _SuggestionTile(
                      location: s,
                      onTap: () => widget.onSelectSuggestion(s),
                    ),
                  ),
                ],
                SizedBox(height: lay.gapM),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppStrings.citiesSavedLocations.toUpperCase(),
                      style: lay.citiesSectionLabel(),
                    ),
                    TextButton(
                      onPressed: () => setState(() => _editing = !_editing),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        _editing ? AppStrings.citiesDoneEditing : AppStrings.citiesEditList,
                        style: lay.textCitiesAction,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: lay.gapS),
                if (widget.savedLoading && widget.savedLocations.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(bottom: lay.gapS),
                    child: LinearProgressIndicator(
                      minHeight: 2,
                      color: p.accent,
                      backgroundColor: p.progressTrack,
                    ),
                  ),
                if (widget.savedLocations.isEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: lay.gapM),
                    child: Text(
                      AppStrings.savedEmpty,
                      style: lay.textCityMeta,
                      textAlign: TextAlign.center,
                    ),
                  )
                else if (_editing)
                  ReorderableListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: widget.savedLocations.length,
                    onReorder: widget.onReorderSaved,
                    buildDefaultDragHandles: false,
                    itemBuilder: (context, index) {
                      final loc = widget.savedLocations[index];
                      return _SavedCityCard(
                        key: ValueKey('${loc.latitude}_${loc.longitude}_${loc.name}'),
                        location: loc,
                        weather: _weatherFor(loc),
                        selected: _isActive(loc),
                        editing: true,
                        index: index,
                        onTap: () => widget.onSelectSaved(loc),
                        onRemove: () => widget.onRemoveSaved(loc),
                      );
                    },
                  )
                else
                  ...widget.savedLocations.map(
                    (loc) => Padding(
                      padding: EdgeInsets.only(bottom: lay.gapS),
                      child: _SavedCityCard(
                        location: loc,
                        weather: _weatherFor(loc),
                        selected: _isActive(loc),
                        editing: false,
                        onTap: () => widget.onSelectSaved(loc),
                        onRemove: () => widget.onRemoveSaved(loc),
                      ),
                    ),
                  ),
                SizedBox(height: lay.sectionGap),
                _MapPreviewSection(
                  label: AppStrings.citiesExploreMap,
                  onExplore: widget.onExploreMap,
                ),
              ],
            ),
          ),
        ),
      ],
      ),
    );
  }
}

class _CitiesTopBar extends StatelessWidget {
  const _CitiesTopBar({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final lay = context.weatherly;
    final p = context.palette;
    return Container(
      height: lay.topBarHeight,
      padding: EdgeInsets.symmetric(horizontal: lay.pagePaddingH),
      decoration: BoxDecoration(
        color: p.topBarStart,
        border: Border(bottom: BorderSide(color: p.border)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          WeatherlyLogo(size: lay.logoSize),
          SizedBox(width: lay.gapS),
          Text(title, style: lay.textCitiesBrand),
        ],
      ),
    );
  }
}

class _CitySearchField extends StatelessWidget {
  const _CitySearchField({
    required this.controller,
    required this.focusNode,
    required this.hint,
    required this.onChanged,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String hint;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    final lay = context.weatherly;
    final p = context.palette;
    return TextField(
      controller: controller,
      focusNode: focusNode,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      style: lay.textCityMeta.copyWith(color: p.cityCardTitle),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: lay.textCityMeta,
        prefixIcon: Icon(Icons.place_outlined, color: p.muted, size: lay.font(20)),
        filled: true,
        fillColor: p.inputFill,
        contentPadding: EdgeInsets.symmetric(vertical: lay.gapM, horizontal: lay.gapS),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(lay.radiusS),
          borderSide: BorderSide(color: p.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(lay.radiusS),
          borderSide: BorderSide(color: p.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(lay.radiusS),
          borderSide: BorderSide(color: p.accent, width: 1.5),
        ),
      ),
    );
  }
}

class _SuggestionTile extends StatelessWidget {
  const _SuggestionTile({required this.location, required this.onTap});

  final LocationOption location;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final lay = context.weatherly;
    final p = context.palette;
    return Material(
      color: p.inputFill,
      borderRadius: BorderRadius.circular(lay.radiusS),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(lay.radiusS),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: lay.gapM, vertical: lay.gapS),
          child: Text(location.displayName, style: lay.textCityName.copyWith(fontSize: lay.font(16))),
        ),
      ),
    );
  }
}

class _SavedCityCard extends StatelessWidget {
  const _SavedCityCard({
    super.key,
    required this.location,
    required this.weather,
    required this.selected,
    required this.editing,
    required this.onTap,
    required this.onRemove,
    this.index,
  });

  final LocationOption location;
  final WeatherResult? weather;
  final bool selected;
  final bool editing;
  final VoidCallback onTap;
  final VoidCallback onRemove;
  final int? index;

  @override
  Widget build(BuildContext context) {
    final lay = context.weatherly;
    final p = context.palette;
    final card = Material(
      color: p.inputFill,
      borderRadius: BorderRadius.circular(lay.radiusS),
      elevation: 0,
      shadowColor: Colors.black.withValues(alpha: 0.03),
      child: InkWell(
        onTap: editing ? null : onTap,
        borderRadius: BorderRadius.circular(lay.radiusS),
        child: Container(
          padding: EdgeInsets.all(lay.gapM),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(lay.radiusS),
            border: Border.all(
              color: selected ? p.accent : p.border,
              width: selected ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: selected ? 0.05 : 0.03),
                blurRadius: selected ? 1 : 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            children: [
              if (editing && index != null)
                ReorderableDragStartListener(
                  index: index!,
                  child: Padding(
                    padding: EdgeInsets.only(right: lay.gapS),
                    child: Icon(Icons.drag_indicator, color: p.muted, size: lay.font(22)),
                  ),
                )
              else
                Padding(
                  padding: EdgeInsets.only(right: lay.gapM),
                  child: Icon(Icons.drag_indicator, color: p.muted.withValues(alpha: 0.45), size: lay.font(20)),
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(location.name, style: lay.textCityName, maxLines: 1, overflow: TextOverflow.ellipsis),
                    SizedBox(height: lay.gapXs / 2),
                    Text(
                      weather != null
                          ? cityWeatherSubtitle(weather!)
                          : AppStrings.searchLoading,
                      style: lay.textCityMeta,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              SizedBox(width: lay.gapS),
              if (weather != null) ...[
                Text(weatherEmoji(weather!.current.weatherCode), style: TextStyle(fontSize: lay.font(26))),
                SizedBox(width: lay.gapM),
                Text('${weather!.current.temperature.round()}°', style: lay.textCityTemp),
              ],
              if (editing)
                IconButton(
                  onPressed: onRemove,
                  icon: Icon(Icons.delete_outline, color: p.muted, size: lay.font(22)),
                  tooltip: AppStrings.savedRemove,
                ),
            ],
          ),
        ),
      ),
    );

    return Padding(
      padding: EdgeInsets.only(bottom: lay.gapS, top: selected ? lay.gapXs : 0),
      child: card,
    );
  }
}

class _MapPreviewSection extends StatelessWidget {
  const _MapPreviewSection({required this.label, required this.onExplore});

  final String label;
  final VoidCallback onExplore;

  @override
  Widget build(BuildContext context) {
    final lay = context.weatherly;
    final p = context.palette;
    return ClipRRect(
      borderRadius: BorderRadius.circular(lay.radiusS),
      child: SizedBox(
        height: lay.citiesMapHeight,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/cities_map_preview.png',
              fit: BoxFit.cover,
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    p.surface0.withValues(alpha: 0.85),
                    p.surface0.withValues(alpha: 0),
                    p.brandIndigo.withValues(alpha: 0.08),
                  ],
                  stops: const [0, 0.45, 1],
                ),
              ),
            ),
            Positioned(
              left: lay.gapM,
              bottom: lay.gapM,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onExplore,
                  borderRadius: BorderRadius.circular(lay.radiusS),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: p.accentGradient,
                      borderRadius: BorderRadius.circular(lay.radiusS),
                      boxShadow: p.glassShadow,
                    ),
                    padding: EdgeInsets.symmetric(horizontal: lay.gapM + 4, vertical: lay.gapS),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.map_outlined, color: p.onAccent, size: lay.font(14)),
                        SizedBox(width: lay.gapS),
                        Text(
                          label.toUpperCase(),
                          style: lay.sectionLabel(color: p.onAccent),
                        ),
                      ],
                    ),
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
