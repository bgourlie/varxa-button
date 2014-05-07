library varxa_button;

import 'dart:html';
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

  VarxaButton(this._scope, this._rootElem) {
    this._rootElem.onClick.listen((e) {
      this._progress.classes.remove('noprogress');
      this._rootElem.classes.add('state-loading');

      if (this.onClick == null) {
        print('WTF');
      }

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

  void setProgress({num percent}) {
    switch (this.progressStyle) {
      case STYLE_PERCENT:
        if (percent == null) {
          throw 'must specify percent when progress type is percent.';
        }
        break;
      case STYLE_CONTINUOUS:
        if (percent != null) {
          throw 'percent should not be supplied when progress style is continuous.';
        }
        break;
      default:
        throw 'unexpected style value';
    }

    this._progressInner.style.width = '$percent%';
  }

  void stopProgress() {
    // original has this being done in setTimeout.  If/why is that necessary?
    this._progress.style.opacity = '0';
    this._rootElem.classes.remove('state-loading');
  }
}
