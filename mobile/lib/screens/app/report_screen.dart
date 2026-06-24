import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:planejamento_urbano/components/city_search_card.dart';
import 'package:planejamento_urbano/components/report/report_pin_map.dart';
import 'package:planejamento_urbano/components/report/report_suggestion_form.dart';
import 'package:geolocator/geolocator.dart';
import 'package:planejamento_urbano/contexts/authProvider.dart';
import 'package:planejamento_urbano/controllers/create_suggestion_controller.dart';
import 'package:planejamento_urbano/models/create_sugestion_model.dart';
import 'package:provider/provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:planejamento_urbano/models/br_city.dart';
import 'package:planejamento_urbano/services/br_city_flow.dart';
import 'package:planejamento_urbano/storage/storage_city_prefs.dart';
import 'dart:io';
import 'dart:async';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  // Default: Brasília (fallback). We'll move to GPS / last city after boot.
  LatLng _selectedLocation = const LatLng(-15.793889, -47.882778);
  bool _isLoading = false;

  final MapController _mapController = MapController();

  final _cityFlow = BrCityFlow();

  final TextEditingController _cityController = TextEditingController();
  final FocusNode _cityFocusNode = FocusNode();
  Timer? _citySearchDebounce;
  List<BrCity> _citySearchResults = [];
  bool _isSearchingCity = false;
  String _citySearchQuery = '';
  List<BrCity> _recentCities = [];
  BrCity? _selectedCity;
  bool _isResolvingCity = false;
  String? _cityError;

  @override
  void initState() {
    super.initState();
    _cityFocusNode.addListener(() {
      if (!mounted) return;
      setState(() {});
    });
    Future.microtask(_bootstrapLocationAndPrefs);
  }

  @override
  void dispose() {
    _citySearchDebounce?.cancel();
    _cityController.dispose();
    _cityFocusNode.dispose();
    _descriptionController.dispose();
    super.dispose();
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
    await _useCurrentLocation(silent: true);
    if (!mounted) return;

    if (_isLoading) return;
    if (_selectedCity?.lat != null && _selectedCity?.lon != null) {
      _moveToLatLng(LatLng(_selectedCity!.lat!, _selectedCity!.lon!), zoom: 14);
    }
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

  void _moveToLatLng(LatLng target, {double zoom = 14}) {
    setState(() {
      _selectedLocation = target;
    });
    _mapController.move(target, zoom);
  }

  // Função para obter a permissão de localização
  Future<void> _checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }
  }

  // Função para usar a localização atual
  Future<void> _useCurrentLocation({bool silent = false}) async {
    setState(() {
      _isLoading = true;
      if (!silent) _cityError = null;
    });

    await _checkLocationPermission(); // Verifica permissão

    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        if (!silent) {
          setState(() => _cityError = 'Ative o GPS para usar sua localização.');
        }
        return;
      }

      // Try a fast path first (often works immediately on emulator).
      final last = await Geolocator.getLastKnownPosition();
      if (last != null) {
        _moveToLatLng(LatLng(last.latitude, last.longitude), zoom: 14);
        if (silent) return;
      }

      // On boot, avoid high-accuracy GPS — it often ANRs the emulator.
      if (silent) return;

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 8),
        ),
      );

      _moveToLatLng(LatLng(position.latitude, position.longitude), zoom: 14);
    } on TimeoutException {
      if (!silent) {
        setState(() => _cityError =
            'Não consegui pegar o GPS a tempo. No emulador, ative a localização (Extended controls → Location).');
      }
    } catch (e) {
      if (!silent) {
        setState(() => _cityError = 'Não foi possível obter sua localização.');
      }
    } finally {
      setState(() {
        _isLoading = false; // Finaliza o loading
      });
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

      _moveToLatLng(LatLng(resolved.lat!, resolved.lon!), zoom: 14);
    } finally {
      if (mounted) {
        setState(() => _isResolvingCity = false);
      }
    }
  }

  String? _selectedType;

  final List<String> _suggestionTypes = [
    'Infraestrutura',
    'Trânsito',
    'Limpeza',
    'Segurança',
    'Acessibilidade',
    'Saúde Pública',
    'Outro',
  ];

  final TextEditingController _descriptionController = TextEditingController();
  final CreateSuggestionController _createSuggestionController = CreateSuggestionController();

  late AuthProvider authProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    authProvider = Provider.of<AuthProvider>(context,
        listen: true); 
  }

  Future<void> _submitSuggestion() async {
    final token = await authProvider.ensureAccessToken();
    if (token == null) {
      _showLoginModal();
      return;
    }

    if (_selectedType == null || _descriptionController.text.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, preencha todos os campos.'),
        ),
      );
      return;
    }

    final ibgeId = _selectedCity?.ibgeId;
    if (ibgeId == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione uma cidade antes de enviar a solicitação.'),
        ),
      );
      return;
    }

    final suggestion = CreateSugestionModel(
      type: _selectedType!,
      description: _descriptionController.text,
      latitude: _selectedLocation.latitude,
      longitude: _selectedLocation.longitude,
      ibgeId: ibgeId,
    );

    try {
      await _createSuggestionController.createSuggestion(
        suggestion,
        imageFile,
        authToken: token,
      );

      if (!mounted) return;
      setState(() {
        imageFile = null;
      });

      if (!_createSuggestionController.isError) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Solicitação enviada com sucesso!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao enviar solicitação.')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao enviar solicitação: $e')),
      );
    }
  }

  void _showLoginModal() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          height: 200,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
              const Text(
                "Para utilizar essa funcionalidade, faça seu cadastro ou login.",
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity, // Define a largura como 100%
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 80, 144, 227),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12.0,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(); // Fecha o modal
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  child: const Text('FAZER LOGIN'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  File? imageFile;
  final imagePicker = ImagePicker();

  pick(ImageSource source) async {
    final pickedFile = await imagePicker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
      });

      if (await imageFile!.exists()) {
        // print("Arquivo selecionado: ${imageFile!.path}");
      } else {
        // print("Arquivo não encontrado: ${imageFile!.path}");
      }
    }
  }

  void _showOpcoesBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.grey[200],
                  child: Center(
                    child: Icon(
                      PhosphorIcons.image(),
                      color: Colors.grey[500],
                    ),
                  ),
                ),
                title: Text(
                  'Galeria',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  pick(ImageSource
                      .gallery); // Chama a função para selecionar da galeria
                },
              ),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.grey[200],
                  child: Center(
                    child: Icon(
                      PhosphorIcons.camera(),
                      color: Colors.grey[500],
                    ),
                  ),
                ),
                title: Text(
                  'Câmera',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  pick(
                      ImageSource.camera); // Chama a função para tirar uma foto
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _deleteImage() {
    setState(() {
      imageFile = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Center(
          child: Text(
            "Registrar solicitação",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
      ),
      resizeToAvoidBottomInset: true, // Ajusta a tela quando o teclado aparece
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: CitySearchCard(
                cityController: _cityController,
                cityFocusNode: _cityFocusNode,
                isSearchingCity: _isSearchingCity,
                isLocating: _isLoading,
                isResolvingCity: _isResolvingCity,
                citySearchQuery: _citySearchQuery,
                citySearchResults: _citySearchResults,
                cityError: _cityError,
                selectedCity: _selectedCity,
                recentCities: _recentCities,
                onCityQueryChanged: _onCityQueryChanged,
                onMyLocation: () => _useCurrentLocation(),
                onSelectCity: _selectCity,
              ),
            ),
            const SizedBox(height: 12),
            ReportPinMap(
              mapController: _mapController,
              pinLocation: _selectedLocation,
              isBusyOverlay: _isLoading,
              onMapTap: (point) {
                setState(() {
                  _selectedLocation = point;
                });
              },
            ),
            ReportSuggestionForm(
              suggestionTypes: _suggestionTypes,
              selectedType: _selectedType,
              onTypeChanged: (v) {
                setState(() {
                  _selectedType = v;
                });
              },
              descriptionController: _descriptionController,
              imageFile: imageFile,
              onSelectImage: _showOpcoesBottomSheet,
              onDeleteImage: _deleteImage,
              controller: _createSuggestionController,
              onSubmit: _submitSuggestion,
            ),
          ],
        ),
      ),
    );
  }
}
