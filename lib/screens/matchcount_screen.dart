import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/link_service.dart';

class MatchcountScreen extends StatefulWidget {
  const MatchcountScreen({Key? key}) : super(key: key);

  @override
  State<MatchcountScreen> createState() => _MatchcountScreenState();
}

class _MatchcountScreenState extends State<MatchcountScreen> {
  String? _code;
  String? _message;
  bool _isLoading = false;
  bool _isLinked = false;
  String? _alexaUserId;
  String? _statusMessage;

  Future<void> _generateCode() async {
    setState(() {
      _isLoading = true;
      _message = null;
      _code = null;
      _isLinked = false;
      _alexaUserId = null;
      _statusMessage = null;
    });
    try {
      final result = await LinkService.generatePin();
      setState(() {
        _code = result['pin']?.toString();
        _message = result['message'] ?? 'PIN generado correctamente.';
      });
    } catch (e) {
      setState(() {
        _message = 'Error al generar el código: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _checkLinkStatus() async {
    setState(() {
      _isLoading = true;
      _statusMessage = null;
    });
    try {
      final result = await LinkService.checkLinkStatus();
      setState(() {
        _isLinked = result['isLinked'] == true;
        _alexaUserId = result['alexaUserId']?.toString();
        _statusMessage = _isLinked
            ? '¡Cuenta vinculada correctamente con Alexa!'
            : 'Aún no se ha vinculado la cuenta.';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error al verificar estado: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final String infoText = _code == null
        ? 'Presiona el botón para generar tu código de vinculación con Alexa.'
        : 'Utiliza el siguiente código para vincular tu cuenta con Alexa. ¡No lo compartas con nadie!';
    final String buttonText = _code == null
        ? 'Generar código de vinculación'
        : 'Generar nuevo código';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Vincular con Alexa'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 32),
            Text(
              infoText,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                color: AppColors.text,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (_message != null) ...[
              const SizedBox(height: 16),
              Text(
                _message!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.green, fontWeight: FontWeight.bold),
              ),
            ],
            const SizedBox(height: 40),
            if (_code != null)
              Center(
                child: _CodeBox(label: 'Código', value: _code!),
              ),
            if (_statusMessage != null) ...[
              const SizedBox(height: 24),
              Text(
                _statusMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _isLinked ? AppColors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
            const Spacer(),
            if (_isLoading)
              const CircularProgressIndicator()
            else ...[
              ElevatedButton(
                onPressed: _generateCode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkGrey,
                  foregroundColor: AppColors.text,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                child: Text(buttonText),
              ),
              const SizedBox(height: 16),
              if (_code != null)
                ElevatedButton(
                  onPressed: _checkLinkStatus,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  child: const Text('Verificar estado de vinculación'),
                ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _CodeBox extends StatelessWidget {
  final String label;
  final String value;
  const _CodeBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: AppColors.green, width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 18,
              color: AppColors.darkGrey,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          SelectableText(
            value,
            style: const TextStyle(
              fontSize: 40,
              color: AppColors.green,
              fontWeight: FontWeight.bold,
              letterSpacing: 8,
            ),
          ),
        ],
      ),
    );
  }
}
