library varxa_button;

import 'dart:html';
import 'dart:async';
import 'package:angular/angular.dart';

typedef void ClickHandler(VarxaButton btn);

@Component(
    selector: 'varxa-button', 
    templateUrl: 'packages/varxa_button/varxa_button.html', 
    cssUrl: 'packages/varxa_button/varxa_button.css', 
    map: const {
      'on-click': '&onClick',
      'progress-style': '@progressStyle'
    })
class VarxaButton implements ShadowRootAware, AttachAware {
  static const String STYLE_PERCENT = 'percent';
  static const String STYLE_CONTINUOUS = 'continuous';

  final Element _rootElem;
  final Scope _scope;
  Element _progress;
  Element _progressInner;

  String progressStyle;
  Function onClick;
  
  bool inProgress = false;
  
  VarxaButton(this._scope, this._rootElem) {
    this._rootElem.onClick.listen((e) {
      ClickHandler clickHandler = this.onClick();
      clickHandler(this);
    });
  }

  void attach() {
    if (this.progressStyle == null) {
      this.progressStyle = STYLE_CONTINUOUS;
    }

    switch (this.progressStyle) {
      case STYLE_PERCENT:
        break;
      case STYLE_CONTINUOUS:
        break;
      default:
        throw 'unexpected style value';
    }
  }

  void onShadowRoot(ShadowRoot shadowRoot) {
    this._progress = shadowRoot.querySelector('.progress');
    this._progressInner = shadowRoot.querySelector('.progress-inner');
  }

  void setProgress(double percent) {
    
    if(!inProgress){
      throw 'you must call startProgress() before calling setProgress()';
    }
    
    if(percent < 0.0 || percent > 1.0) {
      throw 'percent must between 0.0 and 1.0';
    }
    
    if(this.progressStyle != STYLE_PERCENT) {
      throw 'setProgress should only be called when progress-style is "$STYLE_PERCENT"';
    }
    
    this._progressInner.style.width = '${percent * 100.0}%';
  }
  
  void startProgress() {
    this._withoutTransition(() {
      this._progressInner.style.width = '0';
      this._progress.style.opacity = '1';
    });
    this.inProgress = true;
  }
  
  void stopProgress() {
    // call asynchronously after 300ms to ensure that
    // the width transition completes from the last
    // call to setProgress()
    new Timer(new Duration(milliseconds: 300), (){
      this._progress.style.opacity = '0';
      this.inProgress = false;
    });
  }
  
  void _withoutTransition(Function func){
    this._rootElem.style.transition = 'none !important';
    func();
    this._rootElem.style.transition = '';
  }
}
