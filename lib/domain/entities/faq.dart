class FaqCategory {
  const FaqCategory({
    required this.name,
    required this.items,
  });

  final String name;
  final List<FaqItem> items;
}

class FaqItem {
  const FaqItem({
    required this.question,
    required this.answer,
  });

  final String question;
  final String answer;
}
