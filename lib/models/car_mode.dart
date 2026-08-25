enum CarMode {
  menu,
  moveFreely,
  control,
  moveLine,
}

extension CarModeExtension on CarMode {
  String get title {
    switch (this) {
      case CarMode.moveFreely:
        return 'Move Freely';
      case CarMode.control:
        return 'Manual Control';
      case CarMode.moveLine:
        return 'Move in Line Chassis';
      case CarMode.menu:
      default:
        return 'Mode Selector';
    }
  }

  String get subtitle {
    switch (this) {
      case CarMode.moveFreely:
        return 'Autonomous Obstacle Avoidance';
      case CarMode.control:
        return 'Full Cockpit Manual Controller';
      case CarMode.moveLine:
        return 'IR Track Following Mode';
      case CarMode.menu:
      default:
        return 'Select Operational Mode';
    }
  }

  String get commandChar {
    switch (this) {
      case CarMode.moveFreely:
        return 'A';
      case CarMode.control:
        return 'M';
      case CarMode.moveLine:
        return 'G';
      case CarMode.menu:
      default:
        return 'S';
    }
  }
}
