const int boardThickness = 18;
const int shlefReduction = 30;
const int doorReductionWidth = 4;
const int doorReductionHeight = 4;
const int drawerFillerWidht = 35;

String sideHeight(String a, String b, String c) {
  int numA = int.parse(a);
  return (numA).toString();
}

String sideWidht(String a, String b, String c) {
  int numA = int.parse(c); // Convert input strings to integers
  // int numB = int.parse(b);
  return (numA).toString(); // Perform subtraction and return as string
}

String topBottomHieght(String a, String b, String c) {
  // int numA = int.parse(a); // Convert input strings to integers
  int numB = int.parse(b) - boardThickness - boardThickness;
  return (numB).toString(); // Perform subtraction and return as string
}

String topBottomWidth(String a, String b, String c) {
  int numA = int.parse(c) - boardThickness; // Convert input strings to integers
  return (numA).toString(); // Perform subtraction and return as string)
}

String backHeight(String a, String b, String c) {
  int numA = int.parse(a); // Convert input strings to integers
  // int numB = int.parse(b);
  return (numA).toString(); // Perform multiplication and return as string
}

String backWidth(String a, String b, String c) {
  // int numA = int.parse(a); // Convert input strings to integers
  int numB = int.parse(b) - boardThickness - boardThickness;
  return (numB).toString(); // Perform multiplication and return as string
}

String shelfHeight(String a, String b, String c) {
  int numB = int.parse(b) - boardThickness - boardThickness;
  return (numB).toString();
}

String shelfWidth(String a, String b, String c) {
  int numA = int.parse(c) -
      boardThickness -
      shlefReduction; // Convert input strings to integers
  // int numB = int.parse(b);
  return (numA).toString(); // Perform multiplication and return as string
}

String doorHeight(String a, String b, String c) {
  int numA =
      int.parse(a) - doorReductionHeight; // Convert input strings to integers
  return (numA).toString(); // Perform multiplication and return as string
}

String doorWidth(String a, String b, String c) {
  int numB =
      int.parse(b) - doorReductionWidth; // Convert input strings to integers
  return (numB).toString(); // Perform multiplication and return as string
}

// Drawer formulae Starts Here

String drawerPackTopHeight(String a, String b, String c) {
  int numB = int.parse(b) - boardThickness - boardThickness;
  return (numB).toString(); // Perform multiplication and return as string
}

String drawerPackTopWidth(String a, String b, String c) {
  int numA = int.parse(c) - boardThickness - shlefReduction;
  return (numA).toString();
}

String drawerPackFillerHeight(String a, String b, String c, String d) {
  int numA = int.parse(d);
  return (numA).toString();
}

String drawerPackFillerWidth(String a, String b, String c) {
  int numB = drawerFillerWidht;
  return (numB).toString();
}

String drawerPacksidesHeight(String a, String b, String c, String d) {
  int numA = int.parse(d);
  return (numA).toString();
}

String drawerPacksidesWidth(String a, String b, String c) {
  int numB = int.parse(c) - boardThickness - 95;
  return (numB).toString();
}

String drawerPackTopBottomHeight(String a, String b, String c) {
  int numA = int.parse(b) - 36 - drawerFillerWidht - 36 - drawerFillerWidht;
  return (numA).toString();
}

String drawerPackTopBottomWidth(String a, String b, String c) {
  int numB = int.parse(c) - boardThickness - 95;
  return (numB).toString();
}

String drawerBaseHeight(String a, String b, String c) {
  int numA = int.parse(b) - 36 - drawerFillerWidht - 99 - drawerFillerWidht;
  return (numA).toString();
}

String drawerBaseWidth(String a, String b, String c) {
  int numB = int.parse(c) - boardThickness - 95 - 36 - 20;
  return (numB).toString();
}

String drawerFrontBackHeight(String a, String b, String c) {
  int numA =
      int.parse(b) - 36 - drawerFillerWidht - 99 - drawerFillerWidht + 36;
  return (numA).toString();
}

String drawerFrontBackWidth(String a, String b) {
  int numB = (int.parse(a) ~/ int.parse(b)) - 80;
  return (numB).toString();
}

String drawerSidesHeight(String a, String b, String c) {
  int numA = int.parse(c) - boardThickness - 95 - 36 - 20;
  return (numA).toString();
}

String drawerSidesWidth(String a, String b) {
  int numB = (int.parse(a) ~/ int.parse(b)) - 80;
  return (numB).toString();
}
