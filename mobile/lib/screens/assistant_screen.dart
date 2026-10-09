import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../models/assistant_message.dart';
import '../models/weather_models.dart';
import '../services/weather_assistant_engine.dart';
import '../theme/weatherly_palette.dart';
import '../theme/weatherly_responsive.dart';
import '../theme/weatherly_theme.dart';
import '../widgets/charts/charts_location_header.dart';
import '../widgets/home_premium/dashboard_sections.dart';

class AssistantScreen extends StatefulWidget {
  const AssistantScreen({
    super.key,
    required this.weather,
    required this.loading,
    required this.onRefresh,
    required this.onSettings,
    required this.onUseCurrentLocation,
    required this.locationBusy,
  });

  final WeatherResult? weather;
  final bool loading;
  final Future<void> Function() onRefresh;
  final VoidCallback onSettings;
  final VoidCallback onUseCurrentLocation;
  final bool locationBusy;

  @override
  State<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends State<AssistantScreen> {
  final _engine = WeatherAssistantEngine();
  final _input = TextEditingController();
  final _scroll = ScrollController();
  final _messages = <AssistantMessage>[];

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    });
  }

  void _clearChat() {
    setState(_messages.clear);
  }

  void _submit(String raw) {
    final text = raw.trim();
    if (text.isEmpty) return;

    final weather = widget.weather;
    final reply = _engine.reply(userMessage: text, weather: weather);

    setState(() {
      _messages.add(
        AssistantMessage(
          role: AssistantMessageRole.user,
          text: text,
          timestamp: DateTime.now(),
        ),
      );
      _messages.add(
        AssistantMessage(
          role: AssistantMessageRole.assistant,
          text: reply,
          timestamp: DateTime.now(),
        ),
      );
    });
    _input.clear();
    _scrollToEnd();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final lay = context.weatherly;
    final weather = widget.weather;
    final hasWeather = weather != null;

    return Container(
      decoration: BoxDecoration(gradient: palette.pageBackground),
      child: Column(
        children: [
          SafeArea(
            bottom: false,
            child: WeatherlyTopBar(
              title: AppStrings.assistantTitle,
              onSettings: widget.onSettings,
              onUseCurrentLocation: widget.onUseCurrentLocation,
              locationBusy: widget.locationBusy,
              useCurrentLocationTooltip: AppStrings.useCurrentLocation,
              settingsTooltip: AppStrings.settingsTitle,
              trailing: _messages.isNotEmpty
                  ? IconButton(
                      tooltip: AppStrings.assistantClearChat,
                      onPressed: _clearChat,
                      icon: Icon(Icons.delete_outline_rounded, color: palette.ink),
                    )
                  : null,
            ),
          ),
          if (weather != null) ChartsLocationHeader(location: weather.location),
          Expanded(
            child: RefreshIndicator(
              onRefresh: widget.onRefresh,
              child: ListView(
                controller: _scroll,
                padding: EdgeInsets.fromLTRB(
                  lay.pagePaddingH,
                  lay.gapM,
                  lay.pagePaddingH,
                  lay.gapM,
                ),
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  if (!hasWeather)
                    Padding(
                      padding: EdgeInsets.only(top: lay.sectionGap),
                      child: Text(
                        widget.loading
                            ? AppStrings.searchLoading
                            : AppStrings.assistantNeedWeather,
                        textAlign: TextAlign.center,
                        style: lay.textDayCondition,
                      ),
                    )
                  else if (_messages.isEmpty) ...[
                    _AssistantBubble(
                      isUser: false,
                      text: AppStrings.assistantWelcome,
                    ),
                    SizedBox(height: lay.gapM),
                    _SuggestionChips(
                      prompts: _engine.suggestedPrompts,
                      onSelected: _submit,
                    ),
                  ] else ...[
                    for (final m in _messages)
                      Padding(
                        padding: EdgeInsets.only(bottom: lay.gapM),
                        child: _AssistantBubble(
                          isUser: m.role == AssistantMessageRole.user,
                          text: m.text,
                        ),
                      ),
                    _SuggestionChips(
                      prompts: _engine.suggestedPrompts,
                      onSelected: _submit,
                    ),
                  ],
                ],
              ),
            ),
          ),
          _Composer(
            controller: _input,
            enabled: hasWeather,
            onSubmit: _submit,
          ),
        ],
      ),
    );
  }
}

class _AssistantBubble extends StatelessWidget {
  const _AssistantBubble({required this.isUser, required this.text});

  final bool isUser;
  final String text;

  @override
  Widget build(BuildContext context) {
    final lay = context.weatherly;
    final p = context.palette;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.88),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: lay.gapM, vertical: lay.gapM),
          decoration: weatherlyGlassDecoration(
            context: context,
            radius: lay.radiusM,
            purple: isUser,
          ),
          child: Text(
            text,
            style: lay.textDayCondition.copyWith(
              color: isUser ? p.onAccent : p.ink,
              height: 1.35,
            ),
          ),
        ),
      ),
    );
  }
}

class _SuggestionChips extends StatelessWidget {
  const _SuggestionChips({required this.prompts, required this.onSelected});

  final List<String> prompts;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final lay = context.weatherly;
    final p = context.palette;

    return Wrap(
      spacing: lay.gapS,
      runSpacing: lay.gapS,
      children: [
        for (final label in prompts)
          ActionChip(
            label: Text(label, style: TextStyle(fontSize: lay.font(13))),
            backgroundColor: p.inputFill.withValues(alpha: 0.85),
            side: BorderSide(color: p.border),
            onPressed: () => onSelected(label),
          ),
      ],
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.enabled,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final bool enabled;
  final ValueChanged<String> onSubmit;

  @override
  Widget build(BuildContext context) {
    final lay = context.weatherly;
    final p = context.palette;

    return Material(
      color: Colors.transparent,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            lay.pagePaddingH,
            lay.gapS,
            lay.pagePaddingH,
            lay.gapS,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  enabled: enabled,
                  minLines: 1,
                  maxLines: 4,
                  textInputAction: TextInputAction.send,
                  onSubmitted: enabled ? onSubmit : null,
                  decoration: InputDecoration(
                    hintText: AppStrings.assistantInputHint,
                    filled: true,
                    fillColor: p.inputFill.withValues(alpha: 0.85),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(lay.radiusM),
                      borderSide: BorderSide(color: p.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(lay.radiusM),
                      borderSide: BorderSide(color: p.border),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: lay.gapM,
                      vertical: lay.gapM,
                    ),
                  ),
                ),
              ),
              SizedBox(width: lay.gapS),
              FilledButton(
                onPressed: enabled ? () => onSubmit(controller.text) : null,
                style: FilledButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: lay.gapM,
                    vertical: lay.gapM,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(lay.radiusM),
                  ),
                ),
                child: const Icon(Icons.send_rounded),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
