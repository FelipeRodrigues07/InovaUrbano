import 'package:flutter/material.dart';
import 'package:planejamento_urbano/components/city_search_card.dart';
import 'package:planejamento_urbano/components/home/home_status_filter_bar.dart';
import 'package:planejamento_urbano/components/home/home_suggestions_map.dart';
import 'package:planejamento_urbano/components/typesSuggestions.dart';
import 'package:planejamento_urbano/contexts/authProvider.dart';
import 'package:planejamento_urbano/controllers/get_all_suggestions_controller.dart';
import 'package:planejamento_urbano/models/get_all_suggestions_model.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:geolocator/geolocator.dart';
import 'package:planejamento_urbano/models/br_city.dart';
import 'package:planejamento_urbano/services/br_city_flow.dart';
import 'package:planejamento_urbano/storage/storage_city_prefs.dart';
import 'dart:math';
import 'dart:async';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomePageState();
}

class _HomePageState extends State<Home> {
  String? avatarImage;

  late LatLng currentLocation;
  late MapController mapController;
  bool isLoading = false;

  late GetAllSuggestionsController getAllSuggestionController;
  bool _didLoadInitialSuggestions = false;

  final _cityFlow = BrCityFlow();

  final TextEditingController _cityController = TextEditingController();
  final FocusNode _cityFocusNode = FocusNode();
  Timer? _citySearchDebounce;
  List<BrCity> _citySearchResults = [];
  bool _isSearchingCity = false;
  String _citySearchQuery = '';
  List<BrCity> _recentCities = [];
  BrCity? _selectedCity;
  bool _isLocating = false;
  bool _isResolvingCity = false;
  String? _cityError;

  @override
  void initState() {
    super.initState();
    // Default: Brasília (fallback). We'll move to GPS / last city after boot.
    currentLocation = const LatLng(-15.793889, -47.882778);
    mapController = MapController();
    getAllSuggestionController = GetAllSuggestionsController(); // Instancie

    _cityFocusNode.addListener(() {
      if (!mounted) return;
      setState(() {});
    });

    Future.microtask(_bootstrapLocationAndPrefs);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didLoadInitialSuggestions) return;
    _didLoadInitialSuggestions = true;
  }

  @override
  void dispose() {
    _citySearchDebounce?.cancel();
    _cityController.dispose();
    _cityFocusNode.dispose();
    super.dispose();
  }

  void _onCityQueryChanged(String raw) {
    final q = raw.trim();
    _citySearchDebounce?.cancel();

    if (q.length < 2) {
      setState(() {
        _citySearchQuery = q;
        _isSearchingCity = false;
        _citySearchResults = [];
      });
      return;
    }

    setState(() {
      _citySearchQuery = q;
      _isSearchingCity = true;
    });

    _citySearchDebounce = Timer(const Duration(milliseconds: 350), () async {
      final queryAtCall = _citySearchQuery;
      final sorted = await _cityFlow.searchMunicipiosSorted(queryAtCall);
      if (!mounted) return;
      if (queryAtCall != _citySearchQuery) return;

      setState(() {
        _citySearchResults = sorted;
        _isSearchingCity = false;
      });
    });
  }

  Future<void> _bootstrapLocationAndPrefs() async {
    final recent = await StorageCityPrefs.getRecent();
    final last = await StorageCityPrefs.getLastCity();

    if (!mounted) return;
    setState(() {
      _recentCities = recent;
      _selectedCity = last;
      if (last != null) {
        _cityController.text = last.label;
      }
    });

    // Try GPS first; if denied/unavailable, fallback to last city coordinates.
    await _useMyLocation(silent: true);
    if (!mounted) return;

    if (_isLocating) return;
    if (_selectedCity?.lat != null && _selectedCity?.lon != null) {
      await _moveToLatLng(
        LatLng(_selectedCity!.lat!, _selectedCity!.lon!),
        zoom: 12,
      );
    }

    // Run first fetch once, after first frame (MediaQuery available).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      getSuggestions();
    });
  }

  Future<void> _moveToLatLng(LatLng target, {double zoom = 12}) async {
    if (!mounted) return;
    setState(() {
      currentLocation = target;
    });
    mapController.move(target, zoom);
  }

  Future<void> _useMyLocation({bool silent = false}) async {
    if (_isLocating) return;
    setState(() {
      _isLocating = true;
      _cityError = null;
      if (!silent) _cityFocusNode.unfocus();
    });

    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        if (!silent) {
          setState(() => _cityError = 'Ative o GPS para usar sua localização.');
        }
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (!silent) {
          setState(() => _cityError = 'Permissão de localização negada.');
        }
        return;
      }

      // Try a fast path first (often works immediately on emulator).
      final last = await Geolocator.getLastKnownPosition();
      if (last != null) {
        await _moveToLatLng(LatLng(last.latitude, last.longitude), zoom: 14);
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      ).timeout(const Duration(seconds: 10));
      await _moveToLatLng(LatLng(pos.latitude, pos.longitude), zoom: 14);
      await getSuggestions();
    } on TimeoutException {
      if (!silent) {
        setState(() => _cityError =
            'Não consegui pegar o GPS a tempo. No emulador, ative a localização (Extended controls → Location).');
      }
    } catch (_) {
      if (!silent) {
        setState(() => _cityError = 'Não foi possível obter sua localização.');
      }
    } finally {
      if (mounted) {
        setState(() => _isLocating = false);
      }
    }
  }

  Future<void> _selectCity(BrCity city) async {
    setState(() {
      _selectedCity = city;
      _isResolvingCity = true;
      _cityError = null;
    });

    try {
      final resolved = await _cityFlow.resolveCoordinates(city);
      if (resolved == null) {
        setState(() {
          _cityError = 'Não consegui localizar essa cidade no mapa.';
        });
        return;
      }

      final recents = await _cityFlow.persistSelection(resolved, _recentCities);

      if (!mounted) return;
      setState(() {
        _recentCities = recents;
      });

      _cityController.text = resolved.label;
      _cityFocusNode.unfocus();

      await _moveToLatLng(LatLng(resolved.lat!, resolved.lon!), zoom: 12);
      await getSuggestions();
    } finally {
      if (mounted) {
        setState(() => _isResolvingCity = false);
      }
    }
  }

  Future<void> getSuggestions() async {
    setState(() {
      isLoading = true;
    });

    final zoom = 12;
    final size = MediaQuery.of(context).size;
    final mapWidth = size.width;
    final mapHeight = 230.0; 

    final latDelta = (180 / (pow(2, zoom)) * (mapHeight / 256));
    final lonDelta = (180 / (pow(2, zoom)) * (mapWidth / 256));

    final latMin = currentLocation.latitude - latDelta;
    final latMax = currentLocation.latitude + latDelta;
    final lonMin = currentLocation.longitude - lonDelta;
    final lonMax = currentLocation.longitude + lonDelta;


    await getAllSuggestionController.getSuggestions(
      latMin: latMin,
      latMax: latMax,
      lonMin: lonMin,
      lonMax: lonMax,
      status: selectedSuggestionStatusType,
    );

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showSuggestionDetails(GetAllSuggestionsModel suggestion) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(suggestion.type),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (suggestion.suggestionImageUrl.isNotEmpty)
              SizedBox(
                height: 180, // Define uma altura fixa para a imagem
                width: double.infinity,
                child: Image.network(
                  suggestion.suggestionImageUrl,
                  fit: BoxFit.cover, // Corta a imagem para ajustar ao espaço
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.error,
                    color: Colors.red,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(suggestion.description),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Fechar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  final List<String> items = [
    'Todas',
    'Em análise',
    'Aprovadas',
    'Em andamento',
    'Concluídas',
  ];

   String selectedSuggestionStatusType = 'Todas';

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: true);

    final String userName = (authProvider.userProfile?.name != null)
        ? 'Olá, ${authProvider.userProfile!.name.split(' ').first}'
        : '';

    // if (authProvider.userProfile?.profilePictureUrl != null) {
    //   print(
    //       'URL da imagem de perfil: ${authProvider.userProfile!.profilePictureUrl}');
    // } else {
    //   print('URL da imagem de perfil não disponível.');
    // }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          "InovaUrbano",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        actions: [
          Row(
            children: [
              Text(
                userName,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                radius: 16, // Tamanho do avatar na AppBar
                backgroundColor: Colors.grey,
                child: ClipOval(
                  child: (authProvider
                              .userProfile?.profilePictureUrl?.isNotEmpty ??
                          false)
                      ? CachedNetworkImage(
                          imageUrl:
                              authProvider.userProfile!.profilePictureUrl!,
                          fit: BoxFit.cover,
                          width:
                              32, // Ajuste do tamanho para o avatar na AppBar
                          height: 32,
                          placeholder: (context, url) =>
                              const CircularProgressIndicator(),
                          errorWidget: (context, url, error) => Icon(Icons
                              .error), // Ícone de erro se a imagem falhar ao carregar
                        )
                      : Icon(Icons.person,
                          size: 32,
                          color:
                              Colors.white), // Ícone padrão quando não há URL
                ),
              ),
              const SizedBox(
                  width: 16), // Espaço entre o avatar e a borda direita
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.center,
            child: const Text(
              'Selecione uma cidade para ver as sugestões',
              style: TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: CitySearchCard(
              cityController: _cityController,
              cityFocusNode: _cityFocusNode,
              isSearchingCity: _isSearchingCity,
              isLocating: _isLocating,
              isResolvingCity: _isResolvingCity,
              citySearchQuery: _citySearchQuery,
              citySearchResults: _citySearchResults,
              cityError: _cityError,
              selectedCity: _selectedCity,
              recentCities: _recentCities,
              onCityQueryChanged: _onCityQueryChanged,
              onMyLocation: () => _useMyLocation(),
              onSelectCity: _selectCity,
            ),
          ),
          const SizedBox(height: 16),
          HomeStatusFilterBar(
            items: items,
            selected: selectedSuggestionStatusType,
            onSelected: (label) {
              setState(() {
                selectedSuggestionStatusType = label;
              });
              getSuggestions();
            },
          ),
          const SizedBox(height: 16),
          HomeSuggestionsMap(
            mapController: mapController,
            initialCenter: currentLocation,
            initialZoom: 12,
            controller: getAllSuggestionController,
            statusType: selectedSuggestionStatusType,
            isBusyOverlay: isLoading,
            onSuggestionTap: _showSuggestionDetails,
          ),
          const SizedBox(height: 8),
          const TypesSuggestions(),
          ],
        ),
      ),
    );
  }
}
