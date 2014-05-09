library varxa_ui;

import 'dart:html';
import 'dart:async';
import 'package:angular/angular.dart';

part 'src/varxa_button/varxa_button.dart';
part 'src/varxa_button_group/varxa_button_group.dart';

class VarxaUiModule extends Module {
  VarxaUiModule(){
    bind(VarxaButtonGroup, toValue: null);
  }
}