double jsonDouble(dynamic value) =>
    double.tryParse(value?.toString() ?? '') ?? 0;

int jsonInt(dynamic value) => int.tryParse(value?.toString() ?? '') ?? 0;

DateTime jsonDateTime(dynamic value) =>
    DateTime.tryParse(value?.toString() ?? '') ?? DateTime(1970);
