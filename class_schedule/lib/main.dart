import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ders Programı',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: DersProgramiEkrani(),
    );
  }
}

class DersProgramiEkrani extends StatefulWidget {
  @override
  _DersProgramiEkraniState createState() => _DersProgramiEkraniState();
}

class _DersProgramiEkraniState extends State<DersProgramiEkrani> {
  List<dynamic> dersler = [];
  final List<String> gunler = ["Pazartesi", "Salı", "Çarşamba", "Perşembe", "Cuma"];
  final List<String> saatAraliklari = List.generate(14, (index) {
    int saat = 8 + index;
    return "${saat}:40 - ${saat + 1}:30";
  });

  @override
  void initState() {
    super.initState();
    _dersPrograminiYukle();
  }

  Future<void> _dersPrograminiYukle() async {
    final String response = await rootBundle.loadString('assets/ders_programi.json');
    final data = await json.decode(response);
    setState(() {
      dersler = data["dersler"];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Ders Programı")),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: [
            DataColumn(label: Text("Saatler/Günler")),
            ...gunler.map((gun) => DataColumn(label: Text(gun))).toList(),
          ],
          rows: saatAraliklari.map((saat) {
            return DataRow(cells: [
              DataCell(Text(saat)),
              ...gunler.map((gun) {
                var ders = dersler.firstWhere(
                  (d) => d['gun'] == gun && d['baslangic_saati'] == saat.split(" - ")[0],
                  orElse: () => null,
                );
                return DataCell(
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DersDetayEkrani(
                            gun: gun,
                            saat: saat,
                            dersKodu: ders != null ? ders['ders_kodu'] : "Boş Saat",
                          ),
                        ),
                      );
                    },
                    child: Text(ders != null ? ders['ders_kodu'] : "Boş"),
                  ),
                );
              }).toList(),
            ]);
          }).toList(),
        ),
      ),
    );
  }
}

class DersDetayEkrani extends StatelessWidget {
  final String gun;
  final String saat;
  final String dersKodu;

  DersDetayEkrani({required this.gun, required this.saat, required this.dersKodu});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Ders Detayları")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Ders Kodu: $dersKodu", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text("Gün: $gun", style: TextStyle(fontSize: 18)),
            Text("Saat: $saat", style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Geri Dön"),
            ),
          ],
        ),
      ),
    );
  }
}