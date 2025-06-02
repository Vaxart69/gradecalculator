import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gradecalculator/provider.dart';
import 'package:provider/provider.dart';
import 'dart:async';

class Calculator extends StatefulWidget {
  const Calculator({super.key});

  @override
  State<Calculator> createState() => CalculatorState();
}

class CalculatorState extends State<Calculator> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  double? summaryResult;
  
  // Cache controllers for TextFormFields to prevent rebuilds
  final Map<String, TextEditingController> _rowControllers = {};
  final Map<String, Timer> _debounceTimers = {};

  @override
  void dispose() {
    _debounceTimers.values.forEach((timer) => timer.cancel());
    _rowControllers.values.forEach((controller) => controller.dispose());
    nameController.dispose();
    weightController.dispose();
    super.dispose();
  }

  // Get or create cached controller
  TextEditingController _getController(String rowId, String field, String initialValue) {
    final key = '${rowId}_$field';
    if (!_rowControllers.containsKey(key)) {
      _rowControllers[key] = TextEditingController(text: initialValue);
    } else if (_rowControllers[key]!.text != initialValue) {
      // Only update if value actually changed from Firebase
      _rowControllers[key]!.text = initialValue;
    }
    return _rowControllers[key]!;
  }

  // Increased debounce timer to reduce Firebase calls
  void _autoSaveRow(String rowId, String field, String value, ComponentProvider provider) {
    _debounceTimers["$rowId-$field"]?.cancel();
    _debounceTimers["$rowId-$field"] = Timer(const Duration(milliseconds: 2500), () {
      if (!mounted) return;
      
      switch (field) {
        case 'name':
          provider.updateRow(rowId, name: value);
          break;
        case 'score':
          provider.updateRow(rowId, score: value);
          break;
        case 'total':
          provider.updateRow(rowId, total: value);
          break;
      }
    });
  }

  double computeWeightedGrade(List<Map<String, dynamic>> components, ComponentProvider provider) {
    double total = 0;
    
    for (var component in components) {
      double compWeight = component['weight'] ?? 0;
      double compSum = 0;
      int validScores = 0;
      
      final rows = provider.getRowsForComponent(component['id']);
      
      for (var row in rows) {
        double score = double.tryParse(row['score'] ?? '') ?? 0;
        double totalScore = double.tryParse(row['total'] ?? '') ?? 0;
        
        if (totalScore > 0) {
          compSum += (score / totalScore);
          validScores++;
        }
      }
      
      if (validScores > 0) {
        compSum = compSum / validScores;
        total += compSum * compWeight;
      }
    }
    
    return total / 100;
  }

  @override
  Widget build(BuildContext context) {
    // Use Consumer instead of Selector to reduce rebuilds
    return Consumer<ComponentProvider>(
      builder: (context, provider, _) {
        final components = provider.components;
        final size = MediaQuery.of(context).size;
        final width = size.width;
        final height = size.height;

        return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.all(width * 0.05),
              child: ListView.builder( // Changed from CustomScrollView to ListView.builder
                itemCount: _getItemCount(components),
                itemBuilder: (context, index) => _buildItem(context, index, components, provider, width, height),
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
                          summaryResult = computeWeightedGrade(components, provider);
                        });
                      },
                      child: Text(
                        "Calculate Grade",
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
            onPressed: () => _showAddComponentDialog(context, provider, width, height),
            backgroundColor: const Color(0xFF2F6D5E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(width * 0.1),
            ),
            child: Icon(Icons.add, color: Colors.white, size: height * 0.035),
          ),
        );
      },
    );
  }

  int _getItemCount(List<Map<String, dynamic>> components) {
    int count = 1; // Header
    if (components.isEmpty) {
      count += 1; // Empty state
    } else {
      count += components.length; // Components
      if (summaryResult != null) {
        count += 1; // Summary result
      }
    }
    return count;
  }

  Widget _buildItem(BuildContext context, int index, List<Map<String, dynamic>> components, ComponentProvider provider, double width, double height) {
    if (index == 0) {
      return Column(
        children: [
          SizedBox(height: height * 0.05),
          Text(
            "CMSC 23",
            style: GoogleFonts.poppins(
              fontSize: height * 0.05,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: height * 0.05),
        ],
      );
    }

    if (components.isEmpty && index == 1) {
      return SizedBox(
        height: height * 0.4,
        child: Center(
          child: Text(
            "Please add your components first.",
            style: GoogleFonts.poppins(
              color: const Color(0xFF6E6E6E),
              fontSize: height * 0.02,
            ),
          ),
        ),
      );
    }

    if (components.isNotEmpty) {
      final componentIndex = index - 1;
      if (componentIndex < components.length) {
        return _buildComponentSection(components[componentIndex], provider, width, height);
      }
      
      // Summary result
      if (summaryResult != null && componentIndex == components.length) {
        return Padding(
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
        );
      }
    }

    return const SizedBox.shrink();
  }

  Widget _buildComponentSection(Map<String, dynamic> component, ComponentProvider provider, double width, double height) {
    // Remove Selector - just get rows directly
    final rows = provider.getRowsForComponent(component['id']);
    
    return Container(
      key: ValueKey('component_${component['id']}'), // Add key for performance
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: height * 0.02),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    "${component['name']} (${component['weight'] ?? 0}%)",
                    style: GoogleFonts.poppins(
                      fontSize: height * 0.03,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  tooltip: "Delete Component",
                  onPressed: () => provider.deleteComponent(component['id']),
                ),
              ],
            ),
          ),
          
          // Table with fixed width
          SizedBox(
            width: width * 0.90,
            child: Column(
              children: [
                // Header row
                Row(
                  children: [
                    Expanded(child: Text("Name", style: TextStyle(fontWeight: FontWeight.bold, fontSize: height * 0.02))),
                    SizedBox(width: width * 0.02),
                    Expanded(child: Text("Score", style: TextStyle(fontWeight: FontWeight.bold, fontSize: height * 0.02))),
                    SizedBox(width: width * 0.02),
                    Expanded(child: Text("Total", style: TextStyle(fontWeight: FontWeight.bold, fontSize: height * 0.02))),
                  ],
                ),
                // Data rows
                ...rows.map((row) => _buildRowWidget(row, provider, width, height)).toList(),
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
              onPressed: () => provider.addRow(component['id']),
            ),
          ),
          SizedBox(height: height * 0.03),
        ],
      ),
    );
  }

  Widget _buildRowWidget(Map<String, dynamic> row, ComponentProvider provider, double width, double height) {
    // Use cached controllers to prevent rebuilds
    final nameController = _getController(row['id'], 'name', row['name'] ?? '');
    final scoreController = _getController(row['id'], 'score', row['score'] ?? '');
    final totalController = _getController(row['id'], 'total', row['total'] ?? '');

    return Dismissible(
      key: ValueKey(row['id']),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: EdgeInsets.symmetric(horizontal: width * 0.05),
        child: Icon(Icons.delete, color: Colors.white, size: height * 0.035),
      ),
      onDismissed: (_) => provider.deleteRow(row['id']),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: height * 0.01),
        width: width * 0.90,
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                key: ValueKey('${row['id']}_name_field'),
                controller: nameController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(width * 0.02)),
                  contentPadding: EdgeInsets.symmetric(vertical: height * 0.015, horizontal: width * 0.02),
                ),
                style: TextStyle(fontSize: height * 0.018),
                onChanged: (value) => _autoSaveRow(row['id'], 'name', value, provider),
              ),
            ),
            SizedBox(width: width * 0.02),
            Expanded(
              child: TextFormField(
                key: ValueKey('${row['id']}_score_field'),
                controller: scoreController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(width * 0.02)),
                  contentPadding: EdgeInsets.symmetric(vertical: height * 0.015, horizontal: width * 0.02),
                ),
                keyboardType: TextInputType.number,
                style: TextStyle(fontSize: height * 0.018),
                onChanged: (value) => _autoSaveRow(row['id'], 'score', value, provider),
              ),
            ),
            SizedBox(width: width * 0.02),
            Expanded(
              child: TextFormField(
                key: ValueKey('${row['id']}_total_field'),
                controller: totalController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(width * 0.02)),
                  contentPadding: EdgeInsets.symmetric(vertical: height * 0.015, horizontal: width * 0.02),
                ),
                keyboardType: TextInputType.number,
                style: TextStyle(fontSize: height * 0.018),
                onChanged: (value) => _autoSaveRow(row['id'], 'total', value, provider),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddComponentDialog(BuildContext context, ComponentProvider provider, double width, double height) {
    nameController.clear();
    weightController.clear();
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            "Add a component",
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: height * 0.025),
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
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(width * 0.02)),
                    contentPadding: EdgeInsets.symmetric(vertical: height * 0.015, horizontal: width * 0.02),
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
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(width * 0.02)),
                    contentPadding: EdgeInsets.symmetric(vertical: height * 0.015, horizontal: width * 0.02),
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
                if (nameController.text.trim().isNotEmpty && weightController.text.trim().isNotEmpty) {
                  provider.addComponent({
                    'name': nameController.text.trim(),
                    'weight': double.tryParse(weightController.text.trim()) ?? 0,
                  });
                  Navigator.of(context).pop();
                }
              },
              child: Text("Add", style: GoogleFonts.poppins(fontSize: height * 0.02)),
            ),
          ],
        );
      },
    );
  }
}
