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
class VarxaButton implements ShadowRootAware {
  static const String STYLE_PERCENT = 'percent';
  static const String STYLE_CONTINUOUS = 'continuous';

  final Element _rootElem;
  final Scope _scope;
  
  ButtonElement _buttonElem;
  Element _progress;
  Element _progressInner;

  String _progressStyle;
  String get progressStyle => _progressStyle;
  
  set progressStyle(String style){
    this._progressStyle = style;
    
    if (this._buttonElem == null){
      return;
    }
    
    if (style == null) {
      style = STYLE_CONTINUOUS;
    }

    switch (style) {
      case STYLE_PERCENT:
        this._buttonElem.classes.add('style-percent');
        this._buttonElem.classes.remove('style-continuous');
        break;
      case STYLE_CONTINUOUS:
        this._buttonElem.classes.add('style-continuous');
        this._buttonElem.classes.remove('style-percent');
        break;
      default:
        this._progressStyle = null;
        throw 'unexpected style value';
    }
  }
  
  Function onClick;
  
  bool _inProgress = false;
  
  bool get inProgress => _inProgress;
  
  set inProgress(bool value) {
    this._inProgress = value;
    if(value){
      this._buttonElem.classes.add('in-progress');
    }else{
      this._buttonElem.classes.remove('in-progress');
    }
  }
  
  
  VarxaButton(this._scope, this._rootElem) {
    this._rootElem.onClick.listen((e) {
      ClickHandler clickHandler = this.onClick();
      clickHandler(this);
    });
  }

  void onShadowRoot(ShadowRoot shadowRoot) {
    this._buttonElem = shadowRoot.querySelector('.progress-button');
    this._progress = shadowRoot.querySelector('.progress');
    this._progressInner = shadowRoot.querySelector('.progress-inner');
    
    // slight hack to re-evaluate setter logic once our elements have been set.
    this.progressStyle = this.progressStyle;
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
    this._progressInner.style.width = '0';
    this._progress.style.opacity = '1';
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
}
