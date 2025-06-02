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

  // list to keep track of the number of rows for each component
  List<int> rowCounts = []; 

  // variable to store the summary result
  double? summaryResult; 

  // function for computing the weighted grade
  double computeWeightedGrade() {
    double total = 0;
    for (int i = 0; i < components.length; i++) {
      double compWeight = components[i]['weight'] ?? 0;
      double compSum = 0;
      for (int j = 0; j < rowControllers[i].length; j++) {
        double score = double.tryParse(rowControllers[i][j]['score']?.text ?? '') ?? 0;
        double totalScore = double.tryParse(rowControllers[i][j]['total']?.text ?? '') ?? 0;
        if (totalScore > 0) {
          compSum += (score / totalScore);
        }
      }
      if (rowControllers[i].isNotEmpty) {
        compSum = compSum / rowControllers[i].length; // average for this component
        total += compSum * compWeight;
      }
    }
    return total / 100; // since weights are in percent
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(width * 0.05), // dynamic padding
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
                        fontSize: height * 0.02, // dynamic font size
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
                        padding: EdgeInsets.only(bottom: height * 0.02), // dynamic padding
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
                        child: Column(
                          children: [
                            // Table header
                            SizedBox(
                              width: width * 0.90, // Reduced from 0.96 to account for spacing
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      "Name",
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: height * 0.02),
                                    ),
                                  ),
                                  SizedBox(width: width * 0.02),
                                  Expanded(
                                    child: Text(
                                      "Score",
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: height * 0.02),
                                    ),
                                  ),
                                  SizedBox(width: width * 0.02),
                                  Expanded(
                                    child: Text(
                                      "Total",
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: height * 0.02),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Dismissible rows
                            for (int index = 0; index < rowCounts[i]; index++)
                              Dismissible(
                                key: ValueKey('$i-$index'),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  color: Colors.red,
                                  alignment: Alignment.centerRight,
                                  padding: EdgeInsets.symmetric(horizontal: width * 0.05),
                                  child: Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                    size: height * 0.035,
                                  ),
                                ),
                                onDismissed: (direction) {
                                  setState(() {
                                    rowControllers[i].removeAt(index);
                                    rowCounts[i] = rowControllers[i].length;
                                  });
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: height * 0.01),
                                  width: width * 0.90, // Same width as header - reduced from 0.96
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          controller: rowControllers[i][index]['name'],
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(width * 0.02),
                                            ),
                                            contentPadding: EdgeInsets.symmetric(
                                              vertical: height * 0.015,
                                              horizontal: width * 0.02,
                                            ),
                                          ),
                                          style: TextStyle(fontSize: height * 0.018),
                                        ),
                                      ),
                                      SizedBox(width: width * 0.02),
                                      Expanded(
                                        child: TextFormField(
                                          controller: rowControllers[i][index]['score'],
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(width * 0.02),
                                            ),
                                            contentPadding: EdgeInsets.symmetric(
                                              vertical: height * 0.015,
                                              horizontal: width * 0.02,
                                            ),
                                          ),
                                          keyboardType: TextInputType.number,
                                          style: TextStyle(fontSize: height * 0.018),
                                        ),
                                      ),
                                      SizedBox(width: width * 0.02),
                                      Expanded(
                                        child: TextFormField(
                                          controller: rowControllers[i][index]['total'],
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(width * 0.02),
                                            ),
                                            contentPadding: EdgeInsets.symmetric(
                                              vertical: height * 0.015,
                                              horizontal: width * 0.02,
                                            ),
                                          ),
                                          keyboardType: TextInputType.number,
                                          style: TextStyle(fontSize: height * 0.018),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
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
                              rowControllers[i].add({
                                'name': TextEditingController(),
                                'score': TextEditingController(),
                                'total': TextEditingController(),
                              });
                              rowCounts[i] = rowControllers[i].length;
                            });
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              if (summaryResult != null)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: height * 0.02),
                  child: Text(
                    "Weighted Grade: ${(summaryResult! * 100).toStringAsFixed(2)}%",
                    style: GoogleFonts.poppins(
                      fontSize: height * 0.03,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[800],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: components.isNotEmpty
          ? Padding(
              padding: EdgeInsets.all(width * 0.05),
              child: SizedBox(
                width: width * 0.8,
                height: height * 0.07,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2F6D5E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(width * 0.03),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      summaryResult = computeWeightedGrade();
                    });
                  },
                  child: Text(
                    "Submit",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: height * 0.025,
                    ),
                  ),
                ),
              ),
            )
          : null,
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
                    fontSize: height * 0.025,
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
                          labelStyle: GoogleFonts.poppins(fontSize: height * 0.018),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(width * 0.02),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: height * 0.015,
                            horizontal: width * 0.02,
                          ),
                        ),
                        style: TextStyle(fontSize: height * 0.018),
                      ),
                      SizedBox(height: height * 0.02),
                      TextFormField(
                        controller: weightController,
                        decoration: InputDecoration(
                          labelText: "Weight",
                          hintText: "Weight in percentage",
                          labelStyle: GoogleFonts.poppins(fontSize: height * 0.018),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(width * 0.02),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: height * 0.015,
                            horizontal: width * 0.02,
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        style: TextStyle(fontSize: height * 0.018),
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
                    child: Text("Okay", style: GoogleFonts.poppins(fontSize: height * 0.02)),
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
        child: Icon(Icons.add, color: Colors.white, size: height * 0.035),
      ),
    );
  }
}
