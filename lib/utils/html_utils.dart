import 'dart:developer' as developer;
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as html_dom;

class HtmlUtils {
  /// Converts HTML content to plain text, removing all tags and decoding entities
  static String htmlToPlainText(String? htmlContent) {
    if (htmlContent == null || htmlContent.isEmpty) {
      return '';
    }

    try {
      final preview = htmlContent.length > 100 ? htmlContent.substring(0, 100) : htmlContent;
      developer.log(
        'Decoding HTML: $preview...',
        name: 'HtmlUtils',
      );

      // Parse the HTML
      final document = html_parser.parse(htmlContent);

      // Get all text content
      final text = _extractText(document.body ?? document);

      // Clean up whitespace
      final cleaned = text
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();

      developer.log(
        'Decoded to: $cleaned',
        name: 'HtmlUtils',
      );

      return cleaned;
    } catch (e) {
      developer.log(
        'Error decoding HTML: $e',
        name: 'HtmlUtils',
        error: e,
      );
      // Fallback to basic regex stripping
      return _fallbackHtmlStrip(htmlContent);
    }
  }

  /// Recursively extracts text from HTML nodes
  static String _extractText(html_dom.Node? node) {
    if (node == null) return '';

    if (node is html_dom.Text) {
      return node.text;
    }

    if (node is html_dom.Element) {
      // Skip script and style tags
      if (node.localName == 'script' || node.localName == 'style') {
        return '';
      }

      // Add line breaks for block elements
      final isBlock = ['p', 'div', 'br', 'li', 'blockquote', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6']
          .contains(node.localName);

      final text = node.nodes.map(_extractText).join('');

      return isBlock ? '\n$text\n' : text;
    }

    return '';
  }

  /// Fallback method using regex if HTML parsing fails
  static String _fallbackHtmlStrip(String html) {
    developer.log(
      'Using fallback HTML stripping',
      name: 'HtmlUtils',
    );

    return html
        .replaceAll(RegExp(r'<script[^>]*>.*?</script>', caseSensitive: false, dotAll: true), '')
        .replaceAll(RegExp(r'<style[^>]*>.*?</style>', caseSensitive: false, dotAll: true), '')
        .replaceAll(RegExp(r'<[^>]+>', multiLine: true), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&quot;', '"')
        .replaceAll('&apos;', "'")
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&amp;', '&')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  /// Decodes HTML entities only (doesn't remove tags)
  static String decodeHtmlEntities(String? text) {
    if (text == null || text.isEmpty) {
      return '';
    }

    var result = text
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&quot;', '"')
        .replaceAll('&apos;', "'")
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&amp;', '&');

    // Decode numeric entities: &#123; or &#x1F;
    result = result.replaceAllMapped(RegExp(r'&#(\d+);'), (match) {
      final codeStr = match.group(1);
      if (codeStr == null) return match.group(0) ?? '';
      final code = int.tryParse(codeStr);
      return code != null ? String.fromCharCode(code) : (match.group(0) ?? '');
    });

    result = result.replaceAllMapped(RegExp(r'&#x([0-9a-fA-F]+);'), (match) {
      final codeStr = match.group(1);
      if (codeStr == null) return match.group(0) ?? '';
      final code = int.tryParse(codeStr, radix: 16);
      return code != null ? String.fromCharCode(code) : (match.group(0) ?? '');
    });

    return result;
  }
}
