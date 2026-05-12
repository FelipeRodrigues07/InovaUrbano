import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:planejamento_urbano/models/br_city.dart';

class IbgeCitiesService {
  static const String _base =
      'https://servicodados.ibge.gov.br/api/v1/localidades';

  Future<List<BrCity>> searchMunicipios(String query) async {
    final q = query.trim();
    if (q.length < 2) return [];

    final uri = Uri.parse('$_base/municipios?nome=${Uri.encodeQueryComponent(q)}');
    final res = await http.get(uri, headers: {
      'Accept': 'application/json',
    });

    if (res.statusCode != 200) {
      return [];
    }

    final data = jsonDecode(res.body);
    if (data is! List) return [];

    final results = <BrCity>[];
    for (final item in data) {
      if (item is! Map<String, dynamic>) continue;

      final id = (item['id'] as num?)?.toInt();
      final name = item['nome'] as String?;
      final uf = (item['microrregiao']?['mesorregiao']?['UF']?['sigla'])
          as String?;

      if (id == null || name == null || uf == null) continue;
      results.add(BrCity(ibgeId: id, name: name, uf: uf));
    }

    results.sort((a, b) => a.name.compareTo(b.name));
    return results;
  }
}

