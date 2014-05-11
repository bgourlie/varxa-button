import 'dart:async';
import 'dart:math' as math;
import 'package:angular/application_factory.dart';
import 'package:angular/angular.dart';
import 'package:di/di.dart';
import 'package:varxa_ui/varxa_ui.dart';

void main() {
  applicationFactory()
  .addModule(new VarxaUiModule())
  .addModule(new DemoModule()).run();
}

class DemoModule extends Module {
  DemoModule() {
    bind(DemoController);
  }
}

@Controller(publishAs: 'ctrl', selector: '[main]')
class DemoController{
  void handleClick(VarxaButton sender){
    if(sender.inProgress){
      print('progress stopped');
      sender.stopProgress();
    }else{
      print('starting progress');
      sender.startProgress();
      if(sender.progressStyle == 'percent'){
        final rand = new math.Random();
        var progress = 0.0;
        new Timer.periodic(new Duration(milliseconds: 200), (Timer timer){
          progress = math.min(progress + rand.nextDouble() * .1, 1.0);
          sender.setProgress(progress);
          if(progress == 1.0){
            print('done!');
            timer.cancel();
            sender.stopProgress();
          }
        });
      }
    }
  }
}
