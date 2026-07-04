import '../tool.dart';

class CalculatorTool extends Tool {
  @override
  String get name => 'calculator';

  @override
  String get description =>
      'Evaluate a mathematical expression and return the precise numeric result. '
      'Supports +, -, *, /, %, ^, and parentheses.';

  @override
  Map<String, dynamic> get parametersJsonSchema => {
        'type': 'object',
        'properties': {
          'expression': {
            'type': 'string',
            'description': 'Mathematical expression to evaluate (e.g., "2 + 3 * 4").',
          },
        },
        'required': ['expression'],
      };

  @override
  Future<String> execute(Map<String, dynamic> args) async {
    final expr = (args['expression'] as String).replaceAll(RegExp(r'\^'), '**');
    final sanitized = expr.replaceAll(RegExp(r'[^0-9+\-*/.()%^\s]'), '');
    if (sanitized.isEmpty) return 'Invalid expression';
    try {
      final result = _evaluate(sanitized);
      if (result == result.roundToDouble()) {
        return '${result.round()}';
      }
      return result.toStringAsFixed(6).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
    } catch (e) {
      return 'Error: ${e.toString().replaceAll('FormatException: ', '')}';
    }
  }

  double _evaluate(String expr) {
    final cleaned = expr.replaceAll(RegExp(r'\s+'), '');
    return _parseExpression(cleaned);
  }

  double _parseExpression(String s) {
    final tokens = _tokenize(s);
    return _parseTokens(tokens, 0).value;
  }

  List<_Token> _tokenize(String s) {
    final tokens = <_Token>[];
    var i = 0;
    while (i < s.length) {
      final c = s[i];
      if (c == '(') { tokens.add(_Token(_TokenType.openParen)); i++; }
      else if (c == ')') { tokens.add(_Token(_TokenType.closeParen)); i++; }
      else if ('+-*/%'.contains(c)) {
        tokens.add(_Token(_TokenType.op, op: c)); i++;
      } else if (c == '*' && i + 1 < s.length && s[i + 1] == '*') {
        tokens.add(_Token(_TokenType.op, op: '^')); i += 2;
      } else {
        var num = '';
        while (i < s.length && (RegExp(r'[0-9.]').hasMatch(s[i]) ||
            (s[i] == '-' && num.isEmpty && (tokens.isEmpty || tokens.last.type == _TokenType.openParen || tokens.last.type == _TokenType.op)))) {
          num += s[i]; i++;
        }
        if (num.isEmpty) i++;
        else tokens.add(_Token(_TokenType.num, value: double.parse(num)));
      }
    }
    return tokens;
  }

  _ParseResult _parseTokens(List<_Token> tokens, int pos, {int precedence = 0}) {
    var left = _parsePrimary(tokens, pos);
    pos = left.pos;
    while (pos < tokens.length && tokens[pos].type == _TokenType.op) {
      final op = tokens[pos].op!;
      final opPrec = _precedence(op);
      if (opPrec < precedence) break;
      pos++;
      var right = _parseTokens(tokens, pos, precedence: opPrec + 1);
      left = _ParseResult(_applyOp(op, left.value, right.value), right.pos);
      pos = left.pos;
    }
    return left;
  }

  _ParseResult _parsePrimary(List<_Token> tokens, int pos) {
    if (pos >= tokens.length) return _ParseResult(0, pos);
    final token = tokens[pos];
    if (token.type == _TokenType.openParen) {
      final inner = _parseTokens(tokens, pos + 1);
      final closePos = inner.pos < tokens.length && tokens[inner.pos].type == _TokenType.closeParen
          ? inner.pos + 1 : inner.pos;
      return _ParseResult(inner.value, closePos);
    }
    if (token.type == _TokenType.op && token.op == '-') {
      final inner = _parsePrimary(tokens, pos + 1);
      return _ParseResult(-inner.value, inner.pos);
    }
    if (token.type == _TokenType.num) {
      return _ParseResult(token.value!, pos + 1);
    }
    return _ParseResult(0, pos + 1);
  }

  double _applyOp(String op, double a, double b) {
    return switch (op) {
      '+' => a + b,
      '-' => a - b,
      '*' => a * b,
      '/' => a / b,
      '%' => a % b,
      '^' => _pow(a, b),
      _ => a,
    };
  }

  double _pow(double base, double exp) {
    if (exp == exp.roundToDouble()) {
      double result = 1;
      for (var i = 0; i < exp.abs().round(); i++) {
        result *= base;
      }
      return exp < 0 ? 1 / result : result;
    }
    return base;
  }

  int _precedence(String op) => switch (op) { '+' => 1, '-' => 1, '*' => 2, '/' => 2, '%' => 2, '^' => 3, _ => 0 };
}

enum _TokenType { num, op, openParen, closeParen }

class _Token {
  final _TokenType type;
  final String? op;
  final double? value;
  const _Token(this.type, {this.op, this.value});
}

class _ParseResult {
  final double value;
  final int pos;
  const _ParseResult(this.value, this.pos);
}
