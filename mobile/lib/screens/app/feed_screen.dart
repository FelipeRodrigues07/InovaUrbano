import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:planejamento_urbano/controllers/get_all_posts_feed_controller.dart';
import 'package:planejamento_urbano/models/get_all_post_feed_model.dart';
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
  late GetAllPostsFeedController getAllPostsFeedController;
  final ScrollController _suggestionsScrollController = ScrollController();
  final ScrollController _postsScrollController = ScrollController();
  late TabController _tabController;
  bool isActiveTab = true;
  String? _headerCityLabel;
  bool _headerNoCity = true;

  /// Recarrega sugestões e postagens com a última cidade salva.
  Future<void> reloadFromPrefs() async {
    await _syncHeaderFromPrefs();
    await Future.wait([
      getAllSuggestionFeedController.getSuggestions(),
      getAllPostsFeedController.getPosts(),
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
      message = 'Sugestões e postagens de: $cityLabel';
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
    getAllPostsFeedController = GetAllPostsFeedController();

    Future.microtask(reloadFromPrefs);

    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    _suggestionsScrollController.addListener(_scrollListener);
    _postsScrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _suggestionsScrollController.dispose();
    _postsScrollController.dispose();
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
      getAllPostsFeedController.getPosts();
    }
  }

  void _scrollListener() {
    final controller =
        isActiveTab ? _suggestionsScrollController : _postsScrollController;
    if (!controller.hasClients) return;
    final pos = controller.position;
    if (pos.maxScrollExtent <= 0) return;
    if (pos.pixels < pos.maxScrollExtent - 48) return;

    if (isActiveTab) {
      getAllSuggestionFeedController.getSuggestions(loadMore: true);
    } else {
      getAllPostsFeedController.getPosts(loadMore: true);
    }
  }

  Widget _suggestionLinkChip(GetAllPostsFeedModel post) {
    final parts = <String>[
      if (post.numberSuggestion > 0) 'Sugestão #${post.numberSuggestion}',
      if (post.suggestionType.isNotEmpty) post.suggestionType,
      if (post.suggestionStatus.isNotEmpty) post.suggestionStatus,
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
        ChangeNotifierProvider.value(value: getAllPostsFeedController),
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
                        Tab(text: 'Postagens'),
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
            Consumer<GetAllPostsFeedController>(
              builder: (context, controller, child) {
                final cityLabel =
                    controller.cityLabel ?? _headerCityLabel;
                final noCity =
                    controller.noCitySelected && _headerNoCity;

                if (controller.isLoading && controller.posts.isEmpty) {
                  return _centerFeedMessage(
                    icon: Icons.hourglass_empty,
                    title: 'Carregando postagens...',
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
                        'Selecione o município na tela Início para ver as postagens ligadas às sugestões locais.',
                  );
                }

                if (controller.isError && controller.posts.isEmpty) {
                  return _centerFeedMessage(
                    icon: Icons.cloud_off_outlined,
                    title: 'Não foi possível carregar as postagens',
                    subtitle:
                        'Confira se a API está rodando e o IP em api_constants.dart.',
                    action: _blueActionButton(
                      label: 'Tentar novamente',
                      onPressed: () => controller.getPosts(),
                    ),
                  );
                }

                if (controller.posts.isEmpty) {
                  return _centerFeedMessage(
                    icon: Icons.campaign_outlined,
                    title: 'Não há postagens para esta cidade',
                    subtitle: cityLabel != null
                        ? 'Ainda não há respostas oficiais vinculadas a sugestões de $cityLabel.'
                        : 'As postagens aparecem quando a administração responde a uma sugestão.',
                    action: _blueActionButton(
                      label: 'Atualizar',
                      onPressed: () => controller.getPosts(),
                    ),
                  );
                }

                return ListView.builder(
                        controller: _postsScrollController,
                        padding: const EdgeInsets.all(10.0),
                        itemCount: controller.posts.length + 1,
                        itemBuilder: (context, index) {
                          if (index == controller.posts.length) {
                            return controller.isLoading
                                ? const Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 32.0),
                                    child: Center(
                                        child: CircularProgressIndicator()),
                                  )
                                : const SizedBox.shrink();
                          }

                          final post = controller.posts[index];

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
                                    _suggestionLinkChip(post),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          post.profilePictureUrl.isNotEmpty
                                              ? CircleAvatar(
                                                  radius: 20,
                                                  backgroundColor:
                                                      Colors.grey[300],
                                                  child: ClipOval(
                                                    child: CachedNetworkImage(
                                                      imageUrl: post
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
                                            post.userName,
                                            style: const TextStyle(
                                              color: Colors.black87,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    post.postImageUrl.isNotEmpty == true
                                        ? CachedNetworkImage(
                                            imageUrl: post.postImageUrl,
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
                                        post.title,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        post.description,
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
