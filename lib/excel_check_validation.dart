import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';

class ExcelCheckValidation extends StatefulWidget {
  const ExcelCheckValidation({Key? key}) : super(key: key);

  @override
  _ExcelCheckValidationState createState() => _ExcelCheckValidationState();
}

class _ExcelCheckValidationState extends State<ExcelCheckValidation> {
  // final List<Map<String, dynamic>> _data = [];
  bool _isValid = false;
  String _error = '';
  List<String> failedFields = [];

 Future<void> _importExcel() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['xlsx', 'xls'],
  );

  if (result != null) {
    try {
      List<PlatformFile> files = result.files;
      PlatformFile file = files.first;
      var bytes = file.bytes;

      Excel excel = Excel.decodeBytes(bytes!);

      List<Map<String, String>> allFailedFields = [];

      for (var table in excel.tables.keys) {
        var rows = excel.tables[table]!.rows;

        // Skip the first row (column names)
        bool isFirstRow = true;

        for (var row in rows) {
          if (isFirstRow) {
            isFirstRow = false;
            continue; // Skip the first row
          }

          // Validate each row and extract cell values
          List<dynamic> rowData = row.map((cell) => cell?.value).toList();
          Map<String, String> failedFields = _validateRow(rowData);

          if (failedFields.isNotEmpty) {
            allFailedFields.add(failedFields);
          }
        }
      }

      if (allFailedFields.isEmpty) {
        setState(() {
          _isValid = true;
        });
      } else { setState(() {
       
          _error = 'Validation failed for multiple rows:';
          for (var failedFields in allFailedFields) {
            _error += '\n';
            failedFields.forEach((columnName, error) {
              _error += '$columnName: $error\n';
            });
          }
          print(allFailedFields);
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error occurred while importing Excel: $e';
      });
    }
  }
}




Map<String, String> _validateRow(List<dynamic> row) {
  Map<String, String> failedFields = {};

  // Check if each field meets specific validation criteria
  if (row.length != 2) {
    failedFields['Invalid number of fields'] = '';
  }

  // Validate each field individually
  if (row[0] == null || row[0].toString().isEmpty) {
    failedFields['Employee ID'] = 'cannot be empty';
  }

  // Validate date format
  final dateRegex = RegExp(r'^\d{2}-\d{2}-\d{4}$'); // assuming the date format is 'DD-MM-YYYY'
  if (row[1] == null || !dateRegex.hasMatch(row[1].toString())) {
    failedFields['Date'] = 'has invalid format';
  }

  return failedFields;
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Excel Import'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _importExcel,
              child: Text('Import Excel'),
            ),
            if (_error.isNotEmpty) Text(_error),
            if (_isValid)
              ElevatedButton(
                onPressed: () {
                  // Navigate to the next screen or perform further actions
                },
                child: Text('Next'),
              ),
          ],
        ),
      ),
    );
  }
}
