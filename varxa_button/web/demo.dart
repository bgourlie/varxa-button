import 'package:angular/application_factory.dart';
import 'package:angular/angular.dart';
import 'package:di/di.dart';
import 'package:varxa_button/varxa_button.dart';

void main() {
  applicationFactory().addModule(new DemoModule()).run();
}

class DemoModule extends Module {
  DemoModule() {
    bind(DemoController);
    bind(VarxaButton);
  }
}

@Controller(publishAs: 'ctrl', selector: '[main]')
class DemoController {
  void handleClick(VarxaButton sender) {
    print('button pressed!');
    sender.setProgress(percent: 50);
  }
}
