// lib/core/utils/editor/math_formula_utils.dart

import 'package:flutter/material.dart';

/// Production-ready custom LaTeX renderer
/// Handles common mathematical notation without external dependencies
class MathFormulaUtils {
  // Cache for parsed results
  static final Map<String, TextSpan> _cache = {};

  // Symbol mapping for LaTeX commands to Unicode
  static final Map<String, String> _symbolMap = {
    // Greek letters
    r'\alpha': 'α',
    r'\beta': 'β',
    r'\gamma': 'γ',
    r'\delta': 'δ',
    r'\epsilon': 'ε',
    r'\zeta': 'ζ',
    r'\eta': 'η',
    r'\theta': 'θ',
    r'\iota': 'ι',
    r'\kappa': 'κ',
    r'\lambda': 'λ',
    r'\mu': 'μ',
    r'\nu': 'ν',
    r'\xi': 'ξ',
    r'\pi': 'π',
    r'\rho': 'ρ',
    r'\sigma': 'σ',
    r'\tau': 'τ',
    r'\upsilon': 'υ',
    r'\phi': 'φ',
    r'\chi': 'χ',
    r'\psi': 'ψ',
    r'\omega': 'ω',
    r'\Gamma': 'Γ',
    r'\Delta': 'Δ',
    r'\Theta': 'Θ',
    r'\Lambda': 'Λ',
    r'\Xi': 'Ξ',
    r'\Pi': 'Π',
    r'\Sigma': 'Σ',
    r'\Phi': 'Φ',
    r'\Psi': 'Ψ',
    r'\Omega': 'Ω',

    // Operators
    r'\times': '×',
    r'\div': '÷',
    r'\pm': '±',
    r'\mp': '∓',
    r'\cdot': '·',
    r'\ast': '∗',
    r'\star': '⋆',
    r'\circ': '∘',
    r'\bullet': '•',
    r'\oplus': '⊕',
    r'\otimes': '⊗',

    // Relations
    r'\leq': '≤',
    r'\geq': '≥',
    r'\neq': '≠',
    r'\approx': '≈',
    r'\equiv': '≡',
    r'\sim': '∼',
    r'\simeq': '≃',
    r'\cong': '≅',
    r'\propto': '∝',
    r'\ll': '≪',
    r'\gg': '≫',
    r'\prec': '≺',
    r'\succ': '≻',

    // Arrows
    r'\rightarrow': '→',
    r'\leftarrow': '←',
    r'\leftrightarrow': '↔',
    r'\Rightarrow': '⇒',
    r'\Leftarrow': '⇐',
    r'\Leftrightarrow': '⇔',
    r'\uparrow': '↑',
    r'\downarrow': '↓',
    r'\mapsto': '↦',
    r'\to': '→',

    // Set theory
    r'\in': '∈',
    r'\notin': '∉',
    r'\subset': '⊂',
    r'\supset': '⊃',
    r'\subseteq': '⊆',
    r'\supseteq': '⊇',
    r'\cup': '∪',
    r'\cap': '∩',
    r'\emptyset': '∅',
    r'\varnothing': '∅',

    // Logic
    r'\forall': '∀',
    r'\exists': '∃',
    r'\nexists': '∄',
    r'\neg': '¬',
    r'\land': '∧',
    r'\lor': '∨',
    r'\wedge': '∧',
    r'\vee': '∨',

    // Calculus/Analysis
    r'\infty': '∞',
    r'\partial': '∂',
    r'\nabla': '∇',

    // Geometry
    r'\angle': '∠',
    r'\perp': '⊥',
    r'\parallel': '∥',
    r'\triangle': '△',

    // Misc symbols
    r'\therefore': '∴',
    r'\because': '∵',
    r'\sqrt': '√',
    r'\cbrt': '∛',
    r'\prime': '′',
    r'\degree': '°',

    // Trig functions (displayed as text)
    r'\sin': 'sin',
    r'\cos': 'cos',
    r'\tan': 'tan',
    r'\cot': 'cot',
    r'\sec': 'sec',
    r'\csc': 'csc',
    r'\arcsin': 'arcsin',
    r'\arccos': 'arccos',
    r'\arctan': 'arctan',
    r'\sinh': 'sinh',
    r'\cosh': 'cosh',
    r'\tanh': 'tanh',
    r'\log': 'log',
    r'\ln': 'ln',
    r'\exp': 'exp',
    r'\lim': 'lim',
    r'\min': 'min',
    r'\max': 'max',
    r'\det': 'det',
    r'\dim': 'dim',
    r'\mod': 'mod',
    r'\gcd': 'gcd',
    r'\lcm': 'lcm',

    // Spacing
    r'\,': ' ',
    r'\;': '  ',
    r'\quad': '    ',
    r'\qquad': '        ',
  };

  // Large operators that should be rendered bigger
  static final Set<String> _largeOperators = {
    r'\sum',
    r'\prod',
    r'\int',
    r'\oint',
    r'\bigcup',
    r'\bigcap',
  };

  static final Map<String, String> _largeOperatorMap = {
    r'\sum': '∑',
    r'\prod': '∏',
    r'\int': '∫',
    r'\oint': '∮',
    r'\bigcup': '⋃',
    r'\bigcap': '⋂',
  };

  /// Main rendering method - converts LaTeX to Flutter Widget
  static Widget renderMath(
    String latex, {
    TextStyle? style,
    TextAlign textAlign = TextAlign.left,
  }) {
    final baseStyle = style ?? const TextStyle(fontSize: 16);

    try {
      final parsed = _parseLatex(latex, baseStyle);
      return RichText(
        text: parsed,
        textAlign: textAlign,
      );
    } catch (e) {
      // Fallback to plain text on error
      return Text(
        latex,
        style: baseStyle,
        textAlign: textAlign,
      );
    }
  }

  /// Parse LaTeX string to TextSpan with formatting
  static TextSpan _parseLatex(String latex, TextStyle baseStyle) {
    final cacheKey = '$latex-${baseStyle.fontSize}-${baseStyle.color}';
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    final result = _parseLatexRecursive(latex, baseStyle);

    if (_cache.length > 100) {
      _cache.clear();
    }
    _cache[cacheKey] = result;

    return result;
  }

  /// Recursive parser for nested LaTeX structures
  static TextSpan _parseLatexRecursive(String latex, TextStyle style) {
    final children = <InlineSpan>[];
    int i = 0;
    String buffer = '';

    void flushBuffer() {
      if (buffer.isNotEmpty) {
        children.add(TextSpan(text: buffer, style: style));
        buffer = '';
      }
    }

    while (i < latex.length) {
      // Handle escape sequences
      if (latex[i] == '\\' && i + 1 < latex.length) {
        flushBuffer();

        final command = _extractCommand(latex, i);

        // Handle special commands with arguments
        if (command == r'\frac') {
          final result = _handleFrac(latex, i + command.length, style);
          children.add(result.span);
          i = result.nextIndex;
          continue;
        }

        if (command == r'\sqrt') {
          final result = _handleSqrt(latex, i + command.length, style);
          children.add(result.span);
          i = result.nextIndex;
          continue;
        }

        if (command == r'\vec' || command == r'\hat' || command == r'\bar') {
          final result = _handleAccent(command, latex, i + command.length, style);
          children.add(result.span);
          i = result.nextIndex;
          continue;
        }

        if (command == r'\text') {
          final result = _handleText(latex, i + command.length, style);
          children.add(result.span);
          i = result.nextIndex;
          continue;
        }

        if (command == r'\begin') {
          // Skip complex environments
          final endIndex = latex.indexOf(r'\end', i);
          if (endIndex != -1) {
            final envEnd = latex.indexOf('}', endIndex);
            i = envEnd != -1 ? envEnd + 1 : latex.length;
            continue;
          }
        }

        // Check large operators
        if (_largeOperators.contains(command)) {
          children.add(TextSpan(
            text: _largeOperatorMap[command],
            style: style.copyWith(fontSize: (style.fontSize ?? 16) * 1.4),
          ));
          i += command.length;
          continue;
        }

        // Check symbol map
        if (_symbolMap.containsKey(command)) {
          children.add(TextSpan(text: _symbolMap[command], style: style));
          i += command.length;
          continue;
        }

        // Unknown command - render as plain text without backslash
        final commandName = command.substring(1); // Remove backslash
        children.add(TextSpan(text: commandName, style: style));
        i += command.length;
        continue;
      }

      // Handle superscript (^)
      if (latex[i] == '^') {
        flushBuffer();
        i++;
        final supResult = _extractGroup(latex, i);
        final superscript = _convertToSuperscript(supResult.content);
        children.add(TextSpan(text: superscript, style: style));
        i = supResult.nextIndex;
        continue;
      }

      // Handle subscript (_)
      if (latex[i] == '_') {
        flushBuffer();
        i++;
        final subResult = _extractGroup(latex, i);
        final subscript = _convertToSubscript(subResult.content);
        children.add(TextSpan(text: subscript, style: style));
        i = subResult.nextIndex;
        continue;
      }

      // Handle braces for grouping
      if (latex[i] == '{') {
        flushBuffer();
        final groupResult = _extractGroup(latex, i);
        children.add(_parseLatexRecursive(groupResult.content, style));
        i = groupResult.nextIndex;
        continue;
      }

      // Skip closing braces
      if (latex[i] == '}') {
        i++;
        continue;
      }

      // Regular character
      buffer += latex[i];
      i++;
    }

    flushBuffer();

    return TextSpan(
      children: children.isEmpty ? [TextSpan(text: latex, style: style)] : children,
    );
  }

  /// Handle \frac{num}{den}
  static CommandResult _handleFrac(String latex, int startIndex, TextStyle style) {
    int i = startIndex;

    // Parse numerator
    final numResult = _extractGroup(latex, i);
    i = numResult.nextIndex;

    // Parse denominator
    final denResult = _extractGroup(latex, i);
    i = denResult.nextIndex;

    // Simple inline fraction display
    final num = _parseLatexRecursive(numResult.content, style);
    final den = _parseLatexRecursive(denResult.content, style);

    return CommandResult(
      span: TextSpan(
        children: [
          const TextSpan(text: '('),
          num,
          const TextSpan(text: ')/('),
          den,
          const TextSpan(text: ')'),
        ],
        style: style,
      ),
      nextIndex: i,
    );
  }

  /// Handle \sqrt{content} or \sqrt[n]{content}
  static CommandResult _handleSqrt(String latex, int startIndex, TextStyle style) {
    int i = startIndex;

    // Check for nth root
    String rootSymbol = '√';
    if (i < latex.length && latex[i] == '[') {
      final bracketEnd = latex.indexOf(']', i);
      if (bracketEnd != -1) {
        final n = latex.substring(i + 1, bracketEnd);
        if (n == '3') {
          rootSymbol = '∛';
        } else if (n == '4') {
          rootSymbol = '∜';
        } else {
          rootSymbol = '${_convertToSuperscript(n)}√';
        }
        i = bracketEnd + 1;
      }
    }

    final contentResult = _extractGroup(latex, i);

    return CommandResult(
      span: TextSpan(
        children: [
          TextSpan(text: rootSymbol, style: style),
          TextSpan(text: '(', style: style),
          _parseLatexRecursive(contentResult.content, style),
          TextSpan(text: ')', style: style),
        ],
      ),
      nextIndex: contentResult.nextIndex,
    );
  }

  /// Handle accent commands like \vec, \hat, \bar
  static CommandResult _handleAccent(String command, String latex, int startIndex, TextStyle style) {
    final contentResult = _extractGroup(latex, startIndex);

    String accent;
    switch (command) {
      case r'\vec':
        accent = '→';
        break;
      case r'\hat':
        accent = '̂';
        break;
      case r'\bar':
        accent = '̄';
        break;
      default:
        accent = '';
    }

    if (command == r'\vec') {
      return CommandResult(
        span: TextSpan(
          text: '${contentResult.content}⃗',
          style: style,
        ),
        nextIndex: contentResult.nextIndex,
      );
    }

    return CommandResult(
      span: TextSpan(
        text: '${contentResult.content}$accent',
        style: style,
      ),
      nextIndex: contentResult.nextIndex,
    );
  }

  /// Handle \text{content}
  static CommandResult _handleText(String latex, int startIndex, TextStyle style) {
    final contentResult = _extractGroup(latex, startIndex);

    return CommandResult(
      span: TextSpan(
        text: contentResult.content,
        style: style,
      ),
      nextIndex: contentResult.nextIndex,
    );
  }

  /// Convert string to superscript using Unicode
  static String _convertToSuperscript(String text) {
    const superscripts = {
      '0': '⁰',
      '1': '¹',
      '2': '²',
      '3': '³',
      '4': '⁴',
      '5': '⁵',
      '6': '⁶',
      '7': '⁷',
      '8': '⁸',
      '9': '⁹',
      '+': '⁺',
      '-': '⁻',
      '=': '⁼',
      '(': '⁽',
      ')': '⁾',
      'n': 'ⁿ',
      'i': 'ⁱ',
      'x': 'ˣ',
      'y': 'ʸ',
      'a': 'ᵃ',
      'b': 'ᵇ',
      'c': 'ᶜ',
      'd': 'ᵈ',
      'e': 'ᵉ',
      'f': 'ᶠ',
      'g': 'ᵍ',
      'h': 'ʰ',
      'j': 'ʲ',
      'k': 'ᵏ',
      'l': 'ˡ',
      'm': 'ᵐ',
      'o': 'ᵒ',
      'p': 'ᵖ',
      'r': 'ʳ',
      's': 'ˢ',
      't': 'ᵗ',
      'u': 'ᵘ',
      'v': 'ᵛ',
      'w': 'ʷ',
      'z': 'ᶻ',
      'T': 'ᵀ',
    };

    final buffer = StringBuffer();
    for (final char in text.split('')) {
      buffer.write(superscripts[char] ?? char);
    }
    return buffer.toString();
  }

  /// Convert string to subscript using Unicode
  static String _convertToSubscript(String text) {
    const subscripts = {
      '0': '₀',
      '1': '₁',
      '2': '₂',
      '3': '₃',
      '4': '₄',
      '5': '₅',
      '6': '₆',
      '7': '₇',
      '8': '₈',
      '9': '₉',
      '+': '₊',
      '-': '₋',
      '=': '₌',
      '(': '₍',
      ')': '₎',
      'a': 'ₐ',
      'e': 'ₑ',
      'h': 'ₕ',
      'i': 'ᵢ',
      'j': 'ⱼ',
      'k': 'ₖ',
      'l': 'ₗ',
      'm': 'ₘ',
      'n': 'ₙ',
      'o': 'ₒ',
      'p': 'ₚ',
      'r': 'ᵣ',
      's': 'ₛ',
      't': 'ₜ',
      'u': 'ᵤ',
      'v': 'ᵥ',
      'x': 'ₓ',
    };

    final buffer = StringBuffer();
    for (final char in text.split('')) {
      buffer.write(subscripts[char] ?? char);
    }
    return buffer.toString();
  }

  /// Extract LaTeX command name
  static String _extractCommand(String latex, int startIndex) {
    if (latex[startIndex] != '\\') return '';

    int i = startIndex + 1;
    String command = '\\';

    while (i < latex.length && _isAlpha(latex[i])) {
      command += latex[i];
      i++;
    }

    return command;
  }

  /// Extract content within braces or single character
  static GroupResult _extractGroup(String latex, int startIndex) {
    int i = startIndex;
    while (i < latex.length && latex[i] == ' ') {
      i++;
    }

    if (i >= latex.length) {
      return GroupResult(content: '', nextIndex: i);
    }

    if (latex[i] == '{') {
      int depth = 1;
      int start = i + 1;
      i++;

      while (i < latex.length && depth > 0) {
        if (latex[i] == '{') depth++;
        if (latex[i] == '}') depth--;
        if (depth > 0) i++;
      }

      return GroupResult(
        content: latex.substring(start, i),
        nextIndex: i + 1,
      );
    }

    return GroupResult(
      content: latex[i],
      nextIndex: i + 1,
    );
  }

  /// Check if character is alphabetic
  static bool _isAlpha(String char) {
    if (char.isEmpty) return false;
    final code = char.codeUnitAt(0);
    return (code >= 65 && code <= 90) || (code >= 97 && code <= 122);
  }

  /// Parse mixed text with inline/display math
  static String parseLatexInText(String text) {
    text = text.replaceAllMapped(
      RegExp(r'\$\$(.*?)\$\$', dotAll: true),
      (match) => match.group(1) ?? '',
    );

    text = text.replaceAllMapped(
      RegExp(r'\$(.*?)\$'),
      (match) => match.group(1) ?? '',
    );

    return text;
  }

  /// Check if string contains LaTeX
  static bool containsLatex(String text) {
    return text.contains(r'\') ||
        text.contains(r'$') ||
        text.contains('^') ||
        text.contains('_');
  }

  /// Clear rendering cache
  static void clearCache() {
    _cache.clear();
  }
}

/// Result from command parsing
class CommandResult {
  final TextSpan span;
  final int nextIndex;

  CommandResult({required this.span, required this.nextIndex});
}

/// Result from group extraction
class GroupResult {
  final String content;
  final int nextIndex;

  GroupResult({required this.content, required this.nextIndex});
}