class MaterialConfig {
  final int boardThickness;
  final int shelfReduction;
  final int doorReductionWidth;
  final int doorReductionHeight;
  final int drawerFillerWidth;

  MaterialConfig({
    required this.boardThickness,
    required this.shelfReduction,
    required this.doorReductionWidth,
    required this.doorReductionHeight,
    required this.drawerFillerWidth,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': 1,
      'boardThickness': boardThickness,
      'shelfReduction': shelfReduction,
      'doorReductionWidth': doorReductionWidth,
      'doorReductionHeight': doorReductionHeight,
      'drawerFillerWidth': drawerFillerWidth,
    };
  }

  factory MaterialConfig.fromMap(Map<String, dynamic> map) {
    return MaterialConfig(
      boardThickness: map['boardThickness'],
      shelfReduction: map['shelfReduction'],
      doorReductionWidth: map['doorReductionWidth'],
      doorReductionHeight: map['doorReductionHeight'],
      drawerFillerWidth: map['drawerFillerWidth'],
    );
  }
}

//   factory MaterialConfig.fromMap(Map<String, dynamic> map) {
//     return MaterialConfig(
//       boardThickness: map['board_thickness'],
//       shelfReduction: map['shelf_reduction'],
//       doorReductionWidth: map['door_reduction_width'],
//       doorReductionHeight: map['door_reduction_height'],
//       drawerFillerWidth: map['drawer_filler_width'],
//     );
//   }
// }
