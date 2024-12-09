import 'package:flutter/material.dart';
import 'package:dlibphonenumber/dlibphonenumber.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Phone Number Info',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: PhoneNumberScreen(),
    );
  }
}

class PhoneNumberScreen extends StatefulWidget {
  @override
  _PhoneNumberScreenState createState() => _PhoneNumberScreenState();
}

class _PhoneNumberScreenState extends State<PhoneNumberScreen> {
  final PhoneNumberUtil phoneUtil = PhoneNumberUtil.instance;
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _regionCodeController = TextEditingController();
  String _e164 = '';
  String _international = '';
  String _national = '';
  String _rfc3966 = '';
  bool _validPhoneNumber = false;
  String _territory = '';
  String _location = '';
  String _timezones = '';
  String _carrier = '';
  String _asYouType = '';

  void _processPhoneNumber() {
    setState(() {
      _e164 = '';
      _international = '';
      _national = '';
      _rfc3966 = '';
      _validPhoneNumber = false;
      _territory = '';
      _location = '';
      _timezones = '';
      _carrier = '';
      _asYouType = '';
    });

    final String phoneNumberInput = _phoneNumberController.text;
    final String regionCodeInput = _regionCodeController.text;

    if (phoneNumberInput.isEmpty || regionCodeInput.isEmpty) {
      return; // Don't process if input is empty
    }

    try {
      final PhoneNumber phoneNumber =
          phoneUtil.parse(phoneNumberInput, regionCodeInput);
      final AsYouTypeFormatter asYouTypeFormatter =
          phoneUtil.getAsYouTypeFormatter(regionCodeInput);

      setState(() {
        _validPhoneNumber = phoneUtil.isValidNumber(phoneNumber);
        _e164 = phoneUtil.format(phoneNumber, PhoneNumberFormat.e164);
        _international =
            phoneUtil.format(phoneNumber, PhoneNumberFormat.international);
        _national = phoneUtil.format(phoneNumber, PhoneNumberFormat.national);
        _rfc3966 = phoneUtil.format(phoneNumber, PhoneNumberFormat.rfc3966);
        _territory = PhoneNumberOfflineGeocoder.instance
            .getDescriptionForNumber(phoneNumber, Locale.english);
        _location = PhoneNumberOfflineGeocoder.instance
            .getDescriptionForValidNumber(phoneNumber, Locale.english);
        _timezones = PhoneNumberToTimeZonesMapper.instance
            .getTimeZonesForNumber(phoneNumber)
            .toString();
        _carrier = PhoneNumberToCarrierMapper.instance
            .getNameForNumber(phoneNumber, Locale.english);
        for (int i = 0; i < phoneNumberInput.length; i++) {
            final String char = phoneNumberInput[i];
            _asYouType = _asYouType + asYouTypeFormatter.inputDigit(char);
        }
      });
    } catch (e) {
      // Handle error (e.g., show an error message)
      print("Error processing phone number: $e");
      setState(() {
          _e164 = "Invalid number";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Phone Number Info'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _phoneNumberController,
              decoration: InputDecoration(
                labelText: 'Phone Number (e.g., 0241234567)',
              ),
              keyboardType: TextInputType.phone,
            ),
            TextField(
              controller: _regionCodeController,
              decoration: InputDecoration(
                labelText: 'Region Code (e.g., GH)',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _processPhoneNumber,
              child: Text('Process'),
            ),
            SizedBox(height: 20),
            Text('E164: $_e164'),
            Text('International: $_international'),
            Text('National: $_national'),
            Text('RFC3966: $_rfc3966'),
            Text('Valid: $_validPhoneNumber'),
            Text('Territory: $_territory'),
            Text('Location: $_location'),
            Text('Timezones: $_timezones'),
            Text('Carrier: $_carrier'),
            Text('As You Type: $_asYouType'),
          ],
        ),
      ),
    );
  }
}