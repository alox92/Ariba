/// Unit type for representing void operations in functional programming
class Unit {
  const Unit._();
  
  static const Unit unit = Unit._();
  
  @override
  bool operator ==(Object other) => other is Unit;
  
  @override
  int get hashCode => 0;
  
  @override
  String toString() => 'Unit';
}
