class AppValidators {
  static String? required(String? value, [String fieldName = 'Campo']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName é obrigatório';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'E-mail é obrigatório';
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Informe um e-mail válido';
    }
    return null;
  }

  static String? cpf(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'CPF é obrigatório';
    }
    final cleanCpf = value.replaceAll(RegExp(r'\D'), '');
    if (cleanCpf.length != 11) {
      return 'CPF deve conter 11 dígitos';
    }
    if (RegExp(r'^(\d)\1{10}$').hasMatch(cleanCpf)) {
      return 'CPF inválido';
    }

    // Validação dos dígitos verificadores
    int sum1 = 0;
    for (int i = 0; i < 9; i++) {
      sum1 += int.parse(cleanCpf[i]) * (10 - i);
    }
    int digit1 = 11 - (sum1 % 11);
    if (digit1 >= 10) digit1 = 0;
    if (digit1 != int.parse(cleanCpf[9])) {
      return 'CPF inválido';
    }

    int sum2 = 0;
    for (int i = 0; i < 10; i++) {
      sum2 += int.parse(cleanCpf[i]) * (11 - i);
    }
    int digit2 = 11 - (sum2 % 11);
    if (digit2 >= 10) digit2 = 0;
    if (digit2 != int.parse(cleanCpf[10])) {
      return 'CPF inválido';
    }

    return null;
  }

  static String? cnpj(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'CNPJ é obrigatório';
    }
    final cleanCnpj = value.replaceAll(RegExp(r'\D'), '');
    if (cleanCnpj.length != 14) {
      return 'CNPJ deve conter 14 dígitos';
    }
    if (RegExp(r'^(\d)\1{13}$').hasMatch(cleanCnpj)) {
      return 'CNPJ inválido';
    }

    const weights1 = [5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];
    int sum1 = 0;
    for (int i = 0; i < 12; i++) {
      sum1 += int.parse(cleanCnpj[i]) * weights1[i];
    }
    int digit1 = sum1 % 11 < 2 ? 0 : 11 - (sum1 % 11);
    if (digit1 != int.parse(cleanCnpj[12])) return 'CNPJ inválido';

    const weights2 = [6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];
    int sum2 = 0;
    for (int i = 0; i < 13; i++) {
      sum2 += int.parse(cleanCnpj[i]) * weights2[i];
    }
    int digit2 = sum2 % 11 < 2 ? 0 : 11 - (sum2 % 11);
    if (digit2 != int.parse(cleanCnpj[13])) return 'CNPJ inválido';

    return null;
  }

  static String? licensePlate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Placa é obrigatória';
    }
    final clean = value.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toUpperCase();
    final mercosulRegex = RegExp(r'^[A-Z]{3}[0-9][A-Z][0-9]{2}$');
    final standardRegex = RegExp(r'^[A-Z]{3}[0-9]{4}$');

    if (!mercosulRegex.hasMatch(clean) && !standardRegex.hasMatch(clean)) {
      return 'Formato de placa inválido (ex: ABC1D23 ou ABC-1234)';
    }
    return null;
  }

  static String? money(String? value, {bool allowZero = false, String fieldName = 'Valor'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName é obrigatório';
    }
    final clean = value.replaceAll('R\$', '').replaceAll('.', '').replaceAll(',', '.').trim();
    final numVal = double.tryParse(clean);
    if (numVal == null) {
      return 'Informe um valor numérico válido';
    }
    if (!allowZero && numVal <= 0) {
      return '$fieldName deve ser maior que zero';
    }
    if (numVal < 0) {
      return '$fieldName não pode ser negativo';
    }
    return null;
  }

  static String? positiveInt(String? value, [String fieldName = 'Quantidade']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName é obrigatório';
    }
    final numVal = int.tryParse(value.replaceAll(RegExp(r'\D'), ''));
    if (numVal == null || numVal <= 0) {
      return '$fieldName deve ser um número positivo';
    }
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Telefone é obrigatório';
    }
    final clean = value.replaceAll(RegExp(r'\D'), '');
    if (clean.length < 10 || clean.length > 11) {
      return 'Telefone deve ter 10 ou 11 dígitos';
    }
    return null;
  }
}
