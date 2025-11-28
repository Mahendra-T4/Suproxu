class SortListParam {
  final String symbolKey;
  final String symbolOrder;

  SortListParam({required this.symbolKey, required this.symbolOrder});

  Map<String, dynamic> toJson() => {
        'symbolKey': symbolKey,
        'symbolOrder': symbolOrder,
      };
}

