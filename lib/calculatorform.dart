import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Calculator extends StatefulWidget {
  const Calculator({super.key});

  @override
  State<Calculator> createState() => CalculatorState();
}

class CalculatorState extends State<Calculator> {

  // declare controllers. 
  List<List<Map<String, TextEditingController>>> rowControllers = [];
  final List<Map<String, dynamic>> components = [];
  final TextEditingController nameController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  List<int> rowCounts = []; 

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ListView(
            children: [
              SizedBox(height: height * 0.05),
              Center(
                child: Text(
                  "CMSC 23",
                  style: GoogleFonts.poppins(
                    fontSize: height * 0.05,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: height * 0.05),

              if (components.isEmpty)
                SizedBox(
                  height: height * 0.5,
                  child: Center(
                    child: Text(
                      "Please add your scores first.",
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF6E6E6E),
                        fontSize: height * 0.015,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    for (var i = 0; i < components.length; i++) ...[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          "${components[i]['name']} (${components[i]['weight'] ?? 0}%)",
                          style: GoogleFonts.poppins(
                            fontSize: height * 0.03,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text("Name")),
                            DataColumn(label: Text("Score")),
                            DataColumn(label: Text("Total")),
                          ],
                          rows: List.generate(
                            rowCounts[i],
                            (index) {
                              // Ensure rowControllers[i] has enough controllers
                              while (rowControllers[i].length < rowCounts[i]) {
                                rowControllers[i].add({
                                  'name': TextEditingController(),
                                  'score': TextEditingController(),
                                  'total': TextEditingController(),
                                });
                              }
                              return DataRow(
                                cells: [
                                  DataCell(
                                    SizedBox(
                                      width: width * 0.3,
                                      child: TextFormField(
                                        controller: rowControllers[i][index]['name'],
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    SizedBox(
                                      width: width * 0.3,
                                      child: TextFormField(
                                        controller: rowControllers[i][index]['score'],
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    SizedBox(
                                      width: width * 0.3,
                                      child: TextFormField(
                                        controller: rowControllers[i][index]['total'],
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          color: const Color(0xFF2F6D5E),
                          iconSize: width * 0.08,
                          tooltip: "Add Row",
                          onPressed: () {
                            setState(() {
                              rowCounts[i] += 1;
                            });
                          },
                        ),
                      ),
                    ],
                  ],
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          nameController.clear();
          weightController.clear();
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text(
                  "Add a component",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: height * 0.02,
                  ),
                ),
                content: SizedBox(
                  width: width * 0.8,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: "Name",
                          labelStyle: GoogleFonts.poppins(),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: height * 0.02),
                      TextFormField(
                        controller: weightController,
                        decoration: InputDecoration(
                          labelText: "Weight",
                          hintText: "Weight in percentage",
                          labelStyle: GoogleFonts.poppins(),
                          border: const OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      if (nameController.text.trim().isNotEmpty &&
                          weightController.text.trim().isNotEmpty) {
                        setState(() {
                          components.add({
                            'name': nameController.text.trim(),
                            'weight': double.tryParse(weightController.text.trim()) ?? 0,
                          });
                          rowControllers.add([
                            {
                              'name': TextEditingController(),
                              'score': TextEditingController(),
                              'total': TextEditingController(),
                            }
                          ]);
                          rowCounts.add(1);
                        });
                        Navigator.of(context).pop();
                      }
                    },
                    child: Text("Okay", style: GoogleFonts.poppins()),
                  ),
                ],
              );
            },
          );
        },
        backgroundColor: const Color(0xFF2F6D5E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(width * 0.1),
        ),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
