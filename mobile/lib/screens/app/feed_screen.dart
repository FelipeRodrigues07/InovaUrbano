import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:planejamento_urbano/controllers/official_responses_feed_controller.dart';
import 'package:planejamento_urbano/models/official_response_feed_model.dart';
import 'package:planejamento_urbano/controllers/get_all_suggestions_feed_controller.dart';
import 'package:planejamento_urbano/storage/storage_city_prefs.dart';
import 'package:provider/provider.dart';

class Feed extends StatefulWidget {
  const Feed({super.key});

  @override
  FeedState createState() => FeedState();
}

class FeedState extends State<Feed> with SingleTickerProviderStateMixin {

  late GetAllSuggestionsFeedController getAllSuggestionFeedController;
  late OfficialResponsesFeedController officialResponsesFeedController;
  final ScrollController _suggestionsScrollController = ScrollController();
  final ScrollController _officialResponsesScrollController = ScrollController();
  late TabController _tabController;
  bool isActiveTab = true;
  String? _headerCityLabel;
  bool _headerNoCity = true;

  /// Recarrega sugestões e respostas oficiais com a última cidade salva.
  Future<void> reloadFromPrefs() async {
    await _syncHeaderFromPrefs();
    await Future.wait([
      getAllSuggestionFeedController.getSuggestions(),
      officialResponsesFeedController.loadOfficialResponses(),
    ]);
  }

  Future<void> _syncHeaderFromPrefs() async {
    final city = await StorageCityPrefs.getLastCity();
    if (!mounted) return;
    setState(() {
      _headerCityLabel = city?.label;
      _headerNoCity = city == null;
    });
  }

  Widget _buildCityBanner(GetAllSuggestionsFeedController controller) {
    final cityLabel = controller.cityLabel ?? _headerCityLabel;
    final noCity = controller.noCitySelected && _headerNoCity;

    final String message;
    final IconData icon;

    if (noCity) {
      message =
          'Selecione uma cidade na tela Início para ver as sugestões do município.';
      icon = Icons.info_outline;
    } else if (cityLabel != null) {
      message = 'Sugestões e respostas oficiais de: $cityLabel';
      icon = Icons.location_on_outlined;
    } else {
      message = 'Carregando informações da cidade...';
      icon = Icons.hourglass_top_outlined;
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _blueActionButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      child: Text(label),
    );
  }

  Widget _centerFeedMessage({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? action,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 56, color: Colors.grey[500]),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 10),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Colors.grey[700]),
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: 20),
              action,
            ],
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    getAllSuggestionFeedController = GetAllSuggestionsFeedController();
    officialResponsesFeedController = OfficialResponsesFeedController();

    Future.microtask(reloadFromPrefs);

    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    _suggestionsScrollController.addListener(_scrollListener);
    _officialResponsesScrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _suggestionsScrollController.dispose();
    _officialResponsesScrollController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;

    final index = _tabController.index;
    setState(() {
      isActiveTab = index == 0;
    });

    // Ao trocar de aba, recarrega com a cidade atual (evita lista antiga de outro município).
    if (index == 0) {
      getAllSuggestionFeedController.getSuggestions();
    } else {
      officialResponsesFeedController.loadOfficialResponses();
    }
  }

  void _scrollListener() {
    final controller =
        isActiveTab ? _suggestionsScrollController : _officialResponsesScrollController;
    if (!controller.hasClients) return;
    final pos = controller.position;
    if (pos.maxScrollExtent <= 0) return;
    if (pos.pixels < pos.maxScrollExtent - 48) return;

    if (isActiveTab) {
      getAllSuggestionFeedController.getSuggestions(loadMore: true);
    } else {
      officialResponsesFeedController.loadOfficialResponses(loadMore: true);
    }
  }

  Widget _suggestionLinkChip(OfficialResponseFeedModel response) {
    final parts = <String>[
      if (response.numberSuggestion > 0) 'Sugestão #${response.numberSuggestion}',
      if (response.suggestionType.isNotEmpty) response.suggestionType,
      if (response.suggestionStatus.isNotEmpty) response.suggestionStatus,
    ];
    if (parts.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.link, size: 16, color: Colors.blue.shade700),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  parts.join(' · '),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue.shade900,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: getAllSuggestionFeedController),
        ChangeNotifierProvider.value(value: officialResponsesFeedController),
      ],
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          centerTitle: true,
          toolbarHeight: 44,
          title: const Text(
            'Feed',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(84),
            child: Consumer<GetAllSuggestionsFeedController>(
              builder: (context, controller, _) {
                return Column(
                  children: [
                    _buildCityBanner(controller),
                    TabBar(
                      controller: _tabController,
                      labelStyle: const TextStyle(fontSize: 13),
                      unselectedLabelStyle: const TextStyle(fontSize: 13),
                      tabs: const <Widget>[
                        Tab(text: 'Todas as Sugestões'),
                        Tab(text: 'Respostas oficiais'),
                      ],
                      indicatorColor: Colors.white,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.white54,
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: <Widget>[
            // Aba de Sugestões
            Consumer<GetAllSuggestionsFeedController>(
              builder: (context, controller, child) {
                final cityLabel =
                    controller.cityLabel ?? _headerCityLabel;
                final noCity =
                    controller.noCitySelected && _headerNoCity;

                if (controller.isLoading && controller.suggestions.isEmpty) {
                  return _centerFeedMessage(
                    icon: Icons.hourglass_empty,
                    title: 'Carregando sugestões...',
                    subtitle: cityLabel != null
                        ? 'Buscando registros de $cityLabel'
                        : null,
                  );
                }

                if (noCity) {
                  return _centerFeedMessage(
                    icon: Icons.location_city_outlined,
                    title: 'Nenhuma cidade selecionada',
                    subtitle:
                        'Abra a aba Início, busque sua cidade (ex.: Anápolis) e selecione na lista.',
                  );
                }

                if (controller.isError && controller.suggestions.isEmpty) {
                  return _centerFeedMessage(
                    icon: Icons.cloud_off_outlined,
                    title: 'Não foi possível carregar as sugestões',
                    subtitle:
                        'Confira se a API está rodando e o IP em api_constants.dart (emulador: 10.0.2.2; celular: IP do PC).',
                    action: _blueActionButton(
                      label: 'Tentar novamente',
                      onPressed: reloadFromPrefs,
                    ),
                  );
                }

                if (controller.suggestions.isEmpty) {
                  return _centerFeedMessage(
                    icon: Icons.inbox_outlined,
                    title: 'Não há sugestões para esta cidade',
                    subtitle: cityLabel != null
                        ? 'Nenhum registro em $cityLabel no momento.'
                        : 'Escolha outra cidade na tela Início ou registre uma nova sugestão em Reclame.',
                    action: _blueActionButton(
                      label: 'Atualizar',
                      onPressed: reloadFromPrefs,
                    ),
                  );
                }

                return ListView.builder(
                        controller: _suggestionsScrollController,
                        padding: const EdgeInsets.all(10.0),
                        itemCount: controller.suggestions.length + 1,
                        itemBuilder: (context, index) {
                          if (index == controller.suggestions.length) {
                            return controller.isLoading
                                ? const Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 32.0),
                                    child: Center(
                                        child: CircularProgressIndicator()),
                                  )
                                : const SizedBox.shrink();
                          }

                          final suggestion = controller.suggestions[index];

                          return Column(
                            children: [
                              Card(
                                clipBehavior: Clip.antiAlias,
                                elevation: 8,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          suggestion
                                                  .profilePictureUrl.isNotEmpty
                                              ? CircleAvatar(
                                                  radius: 20,
                                                  backgroundColor:
                                                      Colors.grey[300],
                                                  child: ClipOval(
                                                    child: CachedNetworkImage(
                                                      imageUrl: suggestion
                                                          .profilePictureUrl,
                                                      fit: BoxFit.cover,
                                                      width: 40,
                                                      height: 40,
                                                      placeholder: (context,
                                                              url) =>
                                                          CircularProgressIndicator(),
                                                      errorWidget: (context,
                                                              url, error) =>
                                                          Icon(Icons.error),
                                                    ),
                                                  ),
                                                )
                                              : Container(
                                                  width: 35,
                                                  height: 35,
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey[300],
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: const Icon(
                                                    Icons.person,
                                                    size: 32,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                          const SizedBox(width: 8),
                                          Text(
                                            suggestion.userName,
                                            style: const TextStyle(
                                              color: Colors.black87,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    suggestion.suggestionImageUrl.isNotEmpty
                                        ? CachedNetworkImage(
                                            imageUrl:
                                                suggestion.suggestionImageUrl,
                                            height: 200,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                            errorWidget:
                                                (context, url, error) =>
                                                    const Icon(Icons.error,
                                                        color: Colors.red),
                                          )
                                        : const SizedBox.shrink(),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8.0),
                                      child: Text(
                                        suggestion.type,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        suggestion.description,
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16.0),
                            ],
                          );
                        },
                      );
              },
            ),

            // Aba de postagens (vinculadas às sugestões da cidade)
            Consumer<OfficialResponsesFeedController>(
              builder: (context, controller, child) {
                final cityLabel =
                    controller.cityLabel ?? _headerCityLabel;
                final noCity =
                    controller.noCitySelected && _headerNoCity;

                if (controller.isLoading && controller.officialResponses.isEmpty) {
                  return _centerFeedMessage(
                    icon: Icons.hourglass_empty,
                    title: 'Carregando respostas oficiais...',
                    subtitle: cityLabel != null
                        ? 'Respostas da prefeitura em $cityLabel'
                        : null,
                  );
                }

                if (noCity) {
                  return _centerFeedMessage(
                    icon: Icons.location_city_outlined,
                    title: 'Nenhuma cidade selecionada',
                    subtitle:
                        'Selecione o município na tela Início para ver as respostas oficiais ligadas às sugestões locais.',
                  );
                }

                if (controller.isError && controller.officialResponses.isEmpty) {
                  return _centerFeedMessage(
                    icon: Icons.cloud_off_outlined,
                    title: 'Não foi possível carregar as respostas oficiais',
                    subtitle:
                        'Confira se a API está rodando e o IP em api_constants.dart.',
                    action: _blueActionButton(
                      label: 'Tentar novamente',
                      onPressed: () => controller.loadOfficialResponses(),
                    ),
                  );
                }

                if (controller.officialResponses.isEmpty) {
                  return _centerFeedMessage(
                    icon: Icons.campaign_outlined,
                    title: 'Não há respostas oficiais para esta cidade',
                    subtitle: cityLabel != null
                        ? 'Ainda não há respostas oficiais vinculadas a sugestões de $cityLabel.'
                        : 'As respostas oficiais aparecem quando a administração responde a uma sugestão.',
                    action: _blueActionButton(
                      label: 'Atualizar',
                      onPressed: () => controller.loadOfficialResponses(),
                    ),
                  );
                }

                return ListView.builder(
                        controller: _officialResponsesScrollController,
                        padding: const EdgeInsets.all(10.0),
                        itemCount: controller.officialResponses.length + 1,
                        itemBuilder: (context, index) {
                          if (index == controller.officialResponses.length) {
                            return controller.isLoading
                                ? const Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 32.0),
                                    child: Center(
                                        child: CircularProgressIndicator()),
                                  )
                                : const SizedBox.shrink();
                          }

                          final response = controller.officialResponses[index];

                          return Column(
                            children: [
                              Card(
                                clipBehavior: Clip.antiAlias,
                                elevation: 8,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _suggestionLinkChip(response),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          response.profilePictureUrl.isNotEmpty
                                              ? CircleAvatar(
                                                  radius: 20,
                                                  backgroundColor:
                                                      Colors.grey[300],
                                                  child: ClipOval(
                                                    child: CachedNetworkImage(
                                                      imageUrl: response
                                                          .profilePictureUrl,
                                                      fit: BoxFit.cover,
                                                      width: 40,
                                                      height: 40,
                                                      placeholder: (context,
                                                              url) =>
                                                          CircularProgressIndicator(),
                                                      errorWidget: (context,
                                                              url, error) =>
                                                          Icon(Icons.error),
                                                    ),
                                                  ),
                                                )
                                              : Container(
                                                  width: 35,
                                                  height: 35,
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey[300],
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: const Icon(
                                                    Icons.person,
                                                    size: 32,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                          const SizedBox(width: 8),
                                          Text(
                                            response.userName,
                                            style: const TextStyle(
                                              color: Colors.black87,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    response.postImageUrl.isNotEmpty == true
                                        ? CachedNetworkImage(
                                            imageUrl: response.postImageUrl,
                                            height: 200,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                            errorWidget:
                                                (context, url, error) =>
                                                    const Icon(Icons.error,
                                                        color: Colors.red),
                                          )
                                        : const SizedBox.shrink(),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8.0),
                                      child: Text(
                                        response.title,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        response.description,
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16.0),
                            ],
                          );
                        },
                      );
              },
            ),
          ],
        ),
      ),
    );
  }
}
