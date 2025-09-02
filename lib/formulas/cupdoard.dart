const int boardThickness = 18;
const int shlefReduction = 30;
const int doorReductionWidth = 4;
const int doorReductionHeight = 4;
const int drawerFillerWidht = 35;

String sideHeight(int a, int b, int c) {
  return a.toString();
}

String sideWidht(int a, int b, int c) {
  return c.toString();
}

String topBottomHieght(int a, int b, int c) {
  int numB = b - boardThickness - boardThickness;
  return numB.toString();
}

String topBottomWidth(int a, int b, int c) {
  int numA = c - boardThickness;
  return numA.toString();
}

String backHeight(int a, int b, int c) {
  return a.toString();
}

String backWidth(int a, int b, int c) {
  int numB = b - boardThickness - boardThickness;
  return numB.toString();
}

String shelfHeight(int a, int b, int c) {
  int numB = b - boardThickness - boardThickness;
  return numB.toString();
}

String shelfWidth(int a, int b, int c) {
  int numA = c - boardThickness - shlefReduction;
  return numA.toString();
}

String doorHeight(int a, int b, int c) {
  int numA = a - doorReductionHeight;
  return numA.toString();
}

String doorWidth(int a, int b, int c) {
  int numB = b - doorReductionWidth;
  return numB.toString();
}

// Drawer formulae
String drawerPackTopHeight(int a, int b, int c) {
  int numB = b - boardThickness - boardThickness;
  return numB.toString();
}

String drawerPackTopWidth(int a, int b, int c) {
  int numA = c - boardThickness - shlefReduction;
  return numA.toString();
}

String drawerPackFillerHeight(int a, int b, int c, int d) {
  return d.toString();
}

String drawerPackFillerWidth(int a, int b, int c) {
  return drawerFillerWidht.toString();
}

String drawerPacksidesHeight(int a, int b, int c, int d) {
  return d.toString();
}

String drawerPacksidesWidth(int a, int b, int c) {
  int numB = c - boardThickness - 95;
  return numB.toString();
}

String drawerPackTopBottomHeight(int a, int b, int c) {
  int numA = b - 36 - drawerFillerWidht - 36 - drawerFillerWidht;
  return numA.toString();
}

String drawerPackTopBottomWidth(int a, int b, int c) {
  int numB = c - boardThickness - 95;
  return numB.toString();
}

String drawerBaseHeight(int a, int b, int c) {
  int numA = b - 36 - drawerFillerWidht - 99 - drawerFillerWidht;
  return numA.toString();
}

String drawerBaseWidth(int a, int b, int c) {
  int numB = c - boardThickness - 95 - 36 - 20;
  return numB.toString();
}

String drawerFrontBackHeight(int a, int b, int c) {
  int numA = b - 36 - drawerFillerWidht - 99 - drawerFillerWidht + 36;
  return numA.toString();
}

String drawerFrontBackWidth(int a, int b) {
  int numB = (a ~/ b) - 50;
  return numB.toString();
}

String drawerSidesHeight(int a, int b, int c) {
  int numA = c - boardThickness - 95 - 36 - 20;
  return numA.toString();
}

String drawerSidesWidth(int a, int b) {
  int numB = (a ~/ b) - 50;
  return numB.toString();
}

String DrawerFrontsHeight(int a, int b, int c) {
  int numA = (a ~/ b) - 10;
  return numA.toString();
}

String DrawerFrontsWidth(int a) {
  int numB = a - boardThickness - boardThickness - drawerFillerWidht - 5;
  return numB.toString();
}

String splitHalfDividerHeight(int a) {
  int numA = a - boardThickness - boardThickness;
  return numA.toString();
}

String splitHalfDividerWidth(int c) {
  int numB = c - boardThickness - shlefReduction;
  return numB.toString();
}
