import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ConsumptionHistoryScreen extends StatefulWidget {
  @override
  _ConsumptionHistoryScreenState createState() =>
      _ConsumptionHistoryScreenState();
}

class _ConsumptionHistoryScreenState extends State<ConsumptionHistoryScreen> {
  DateTime selectedDay = DateTime.now();
  DateTime selectedMonth = DateTime.now();

  List<double> hourlyAvg = List.filled(24, 0);
  List<double> dailyAvg = [];
  bool loading = true;
  bool showLineChart = false;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final fechaStr = DateFormat('yyyy-MM-dd').format(selectedDay);

    // 📊 Historial diario
    final dailySnapshot = await FirebaseFirestore.instance
        .collection('consumo_diario')
        .doc(fechaStr)
        .collection('HistorialConsumo')
        .get();

    List<double> tempHourly = List.filled(24, 0);
    List<int> countHourly = List.filled(24, 0);

    for (var doc in dailySnapshot.docs) {
      final docId = doc.id;
      if (docId.length != 6) continue;

      int hour = int.tryParse(docId.substring(0, 2)) ?? -1;
      if (hour < 0 || hour > 23) continue;

      final watts = doc['total_watts']?.toDouble() ?? 0;
      tempHourly[hour] += watts;
      countHourly[hour]++;
    }

    for (int i = 0; i < 24; i++) {
      if (countHourly[i] > 0) {
        tempHourly[i] /= countHourly[i];
      }
    }

    // 📅 Historial mensual
    final daysInMonth =
        DateTime(selectedMonth.year, selectedMonth.month + 1, 0).day;
    List<double> sumDaily = List.filled(daysInMonth, 0);

    for (int day = 1; day <= daysInMonth; day++) {
      final dateStr = DateFormat('yyyy-MM-dd').format(
        DateTime(selectedMonth.year, selectedMonth.month, day),
      );
      final snapshot = await FirebaseFirestore.instance
          .collection('consumo_diario')
          .doc(dateStr)
          .collection('HistorialConsumo')
          .get();

      double dailySum = 0;
      for (var doc in snapshot.docs) {
        final watts = doc['total_watts']?.toDouble() ?? 0;
        dailySum += watts;
      }

      if (snapshot.docs.isNotEmpty) {
        sumDaily[day - 1] = dailySum / snapshot.docs.length;
      }
    }

    setState(() {
      hourlyAvg = tempHourly;
      dailyAvg = sumDaily;
      loading = false;
    });
  }

  Widget buildBarChart(List<double> data, String title,
      {bool isHourly = true}) {
    final maxY = (data.reduce((a, b) => a > b ? a : b)) * 1.2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(
          height: 250,
          child: showLineChart
              ? LineChart(
                  LineChartData(
                    maxY: maxY,
                    minY: 0,
                    lineBarsData: [
                      LineChartBarData(
                        spots: data.asMap().entries.map(
                          (e) => FlSpot(e.key.toDouble(), e.value)).toList(),
                        isCurved: true,
                        color: Colors.green,
                        barWidth: 2,
                        dotData: FlDotData(show: true),
                      ),
                    ],
                    titlesData: getTitlesData(data, isHourly),
                    gridData: FlGridData(show: true),
                    borderData: FlBorderData(show: true),
                  ),
                )
              : BarChart(
                  BarChartData(
                    maxY: maxY,
                    barGroups: data.asMap().entries.map(
                      (e) => BarChartGroupData(
                        x: e.key,
                        barRods: [BarChartRodData(toY: e.value, color: Colors.blue)],
                      )).toList(),
                    titlesData: getTitlesData(data, isHourly),
                    gridData: FlGridData(show: true),
                    borderData: FlBorderData(show: true),
                  ),
                ),
        ),
      ],
    );
  }

  FlTitlesData getTitlesData(List<double> data, bool isHourly) {
    return FlTitlesData(
      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          interval: 50,
          reservedSize: 30,
          getTitlesWidget: (value, meta) {
            if (value % 50 != 0 || value < 0) return SizedBox.shrink();
            return Text(value.toInt().toString(), style: TextStyle(fontSize: 10));
          },
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          interval: isHourly ? 3 : 5,
          getTitlesWidget: (value, meta) {
            int index = value.toInt();
            bool showTitle = isHourly ? index % 2 == 0 : index % 5 == 0;

            if (!showTitle || index < 0 || index >= data.length) {
              return SizedBox.shrink();
            }

            String label = isHourly
                ? '${index.toString().padLeft(2, '0')}:00'
                : '${index + 1}';

            return SideTitleWidget(
              axisSide: meta.axisSide,
              space: 6,
              child: Transform.rotate(
                angle: -0.5,
                child: Text(label, style: TextStyle(fontSize: 10)),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Historial de Consumo"),
        actions: [
          IconButton(
            icon: Icon(showLineChart ? Icons.bar_chart : Icons.show_chart),
            tooltip: showLineChart ? "Ver barras" : "Ver líneas",
            onPressed: () {
              setState(() {
                showLineChart = !showLineChart;
              });
            },
          ),
        ],
      ),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton.icon(
                        icon: Icon(Icons.calendar_today),
                        label: Text('Día: ${DateFormat('yyyy-MM-dd').format(selectedDay)}'),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDay,
                            firstDate: DateTime(2023),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            setState(() {
                              selectedDay = picked;
                              loading = true;
                            });
                            fetchData();
                          }
                        },
                      ),
                      ElevatedButton.icon(
                        icon: Icon(Icons.date_range),
                        label: Text('Mes: ${DateFormat('yyyy-MM').format(selectedMonth)}'),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedMonth,
                            firstDate: DateTime(2023),
                            lastDate: DateTime.now(),
                           // selectableDayPredicate: (date) => date.day == 1,
                          );
                          if (picked != null) {
                            setState(() {
                              selectedMonth = DateTime(picked.year, picked.month);
                              loading = true;
                            });
                            fetchData();
                          }
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  buildBarChart(hourlyAvg, 'Historial Diario (24h)', isHourly: true),
                  SizedBox(height: 30),
                  buildBarChart(dailyAvg, 'Historial Mensual (Prom. por día)', isHourly: false),
                ],
              ),
            ),
    );
  }
}
