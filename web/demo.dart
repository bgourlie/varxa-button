import 'dart:async';
import 'dart:math' as math;
import 'package:angular/application_factory.dart';
import 'package:angular/angular.dart';
import 'package:di/di.dart';
import 'package:varxa_ui/varxa_ui.dart';
import 'package:logging/logging.dart';

void main() {
  Logger.root.level = Level.FINEST;
  Logger.root.onRecord.listen((LogRecord r) => print(r.message));

  applicationFactory()
  .addModule(new DemoModule()).run();
}

class DemoModule extends Module {
  DemoModule() {
    install(new VarxaUiModule());
    bind(DemoController);
  }
}

@Controller(publishAs: 'ctrl', selector: '[main]')
class DemoController {
  final Scope _scope;
  DemoController(this._scope);
  
  double percentButtonProgress = 0.0;
  double continuousButtonProgress = 0.0;

  void continuousButtonClick(){
    this.continuousButtonProgress = this.continuousButtonProgress == 0.0
      ? 1.0
      : 0.0;
  }

  void closeClicked(VarxaButton sender){
    print('close clicked!');
  }

  void percentButtonClick(){
    if(this.percentButtonProgress == 1.0){
      this.percentButtonProgress = 0.0;
    }
    
    if(this.percentButtonProgress == 0.0){
      final rand = new math.Random();
      var progress = 0.0;
      new Timer.periodic(new Duration(milliseconds: 200), (Timer timer){
        progress = math.min(progress + rand.nextDouble() * .1, 1.0);
        this.percentButtonProgress = progress;
        
        if(this.percentButtonProgress == 1.0){
          timer.cancel();
        }
      });
    }
  }
}
