import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:planejamento_urbano/components/cards_skeleton_loader.dart';
import 'package:planejamento_urbano/controllers/get_all_posts_feed_controller.dart';
import 'package:planejamento_urbano/controllers/get_all_suggestions_feed_controller.dart';
import 'package:provider/provider.dart';

class Feed extends StatefulWidget {
  const Feed({Key? key}) : super(key: key);

  @override
  State<Feed> createState() => _FeedState();
}

class _FeedState extends State<Feed> with SingleTickerProviderStateMixin {
  late GetAllSuggestionsFeedController getAllSuggestionFeedController;
  late GetAllPostsFeedController getAllPostsFeedController;
  final ScrollController _scrollController = ScrollController();
  late TabController _tabController;
  bool isActiveTab = true;

  @override
  void initState() {
    super.initState();
    getAllSuggestionFeedController = GetAllSuggestionsFeedController();
    getAllPostsFeedController = GetAllPostsFeedController();

    getAllSuggestions();
    getAllPostsFeedController.getPosts();

    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    setState(() {
      isActiveTab = _tabController.index == 0;
    });
  }

  void getAllSuggestions() async {
    await getAllSuggestionFeedController.getSuggestions();
  }

 void _scrollListener() {
  if (_scrollController.position.pixels ==
      _scrollController.position.maxScrollExtent) {
    if (isActiveTab) {
      getAllSuggestionFeedController.getSuggestions(loadMore: true);
    } else {
      getAllPostsFeedController.getPosts(loadMore: true);
    }
  }
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
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1.0),
            child: TabBar(
              controller: _tabController,
              tabs: const <Widget>[
                Tab(text: "Todas as Sugestões"),
                Tab(text: "Administração"),
              ],
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white54,
            ),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: <Widget>[
            // Aba de Sugestões
            Consumer<GetAllSuggestionsFeedController>(
              builder: (context, controller, child) {
                return controller.isLoading && controller.suggestions.isEmpty
                    ? const CardsSkeletonLoader()
                    : ListView.builder(
                        controller: _scrollController,
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

            // Aba de Administração (Posts)
            Consumer<GetAllPostsFeedController>(
              builder: (context, controller, child) {
                return controller.isLoading && controller.posts.isEmpty
                    ? const CardsSkeletonLoader()
                    : ListView.builder(
                        controller: _scrollController,
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
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          post.profilePictureUrl.isNotEmpty ==
                                                  true
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
