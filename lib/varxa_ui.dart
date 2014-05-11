library varxa_ui;

import 'dart:html';
import 'dart:async';
import 'package:angular/angular.dart';
import 'package:logging/logging.dart';

part 'src/varxa_button/varxa_button.dart';
part 'src/varxa_button_group/varxa_button_group.dart';

final _logger = new Logger('varxa_ui');

class VarxaUiModule extends Module {
  VarxaUiModule(){
    bind(VarxaButton);
    bind(VarxaButtonGroup, toValue: null);
  }
}