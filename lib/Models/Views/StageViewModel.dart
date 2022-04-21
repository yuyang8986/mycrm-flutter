class AddStageOptions {
  AddStageOptions(int stageCount, this.insertPosition);

  int first = 1; 
  int last;
  int insertPosition;
}

class StagesDropdownSelection {
  StagesDropdownSelection(this.displayIndex, this.displayText);
  int displayIndex;
  String displayText;
}