part of varxa_ui;

@Injectable()
@Component(
    selector: 'varxa-button', 
    templateUrl: 'packages/varxa_ui/src/varxa_button/varxa_button.html',
    cssUrl: 'packages/varxa_ui/src/varxa_button/varxa_button.css',
    map: const {
      'progress' : '=>progress',
      'progress-style': '@progressStyle',
      'closable': '=>isClosable',
      'checked' : '=>checked',
      'vx-click' : '&onClick',
      'vx-close-click' : '&onCloseClick'
    })
class VarxaButton implements ShadowRootAware {
  static const String STYLE_PERCENT = 'percent';
  static const String STYLE_CONTINUOUS = 'continuous';

  final Element _rootElem;
  final Scope _scope;
  final VarxaButtonGroup _buttonGroup;

  ButtonElement _buttonElem;
  Element _progressElem;
  Element _progressInnerElem;
  Element _closer;

  String _progressStyle;
  bool _checked = false;
  bool _isClosable;
  double _progress = 0.0;
  double _initialProgress;
  
  Function onClick;
  Function onCloseClick;
  
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

  double get progress => _progress;
  set progress(double newProgress) {
    
    if(this._buttonElem == null){
      this._initialProgress = newProgress;
      return;
    }
    
    if(newProgress == null){
      newProgress = 0.0;
    }
    
    if(newProgress < 0.0 || newProgress > 1.0) {
      throw 'percent must between 0.0 and 1.0';
    }
    
    if(_progress == newProgress){
      return;
    }
                   
    switch(this.progressStyle){
      case STYLE_CONTINUOUS:
        if(newProgress > 0){
          this._startProgress();
        }else{
          this._stopProgress();
        }
        break;
      case STYLE_PERCENT:
        if(this.progress == 0.0 && newProgress > 0.0){
          this._startProgress();
        }
        
        this._progressInnerElem.style.width = '${newProgress * 100.0}%';
        
        if(newProgress == 1.0){
          this._stopProgress();
        }
        break;
    }

    this._progress = newProgress;
  }

  bool get checked => _checked;
  set checked(bool value){
    if(value == null){
      value = false;
    }
    
    this._checked = value;
    
    if(this._buttonElem == null){
      return;
    }
    
    if(value){
      this._buttonElem.classes.add('checked');
    }else{
      this._buttonElem.classes.remove('checked');
    }
  }

  bool get isClosable => _isClosable;
  set isClosable(bool value){
    if(value == null){
      value = false;
    }
    
    _isClosable = value;
    
    if(this._buttonElem != null) {
      _isClosable 
        ? this._buttonElem.classes.add('closable') 
        : this._buttonElem.classes.remove('closable');
    }
  }
  
  VarxaButton(this._scope, this._rootElem, this._buttonGroup) {
    if(this._buttonGroup != null){
      this._buttonGroup._buttons.add(this);
    }
  }

  void onShadowRoot(ShadowRoot shadowRoot) {
    this._buttonElem = shadowRoot.querySelector('button');
    this._progressElem = shadowRoot.querySelector('.progress');
    this._progressInnerElem = shadowRoot.querySelector('.progress-inner');
    this._closer = shadowRoot.querySelector('.closer');

    // TODO: probably need something else for touchscreens
    this._rootElem.onClick.listen((Event e){
      if(this._buttonGroup != null){
        this._buttonGroup._registerMouseDown(this);
      }
      
      if(this.onClick != null){
        this.onClick();
      }
    });
    
    this._closer.onClick.listen(_closeClickHandler);

    // hack to re-evaluate setter logic once our elements have been set.
    this.progressStyle = this.progressStyle;
    this.progress = this._initialProgress;
    this.checked = this.checked;
    this.isClosable = this.isClosable;
  }

  void _closeClickHandler(Event e){
    e.stopPropagation();

    if(this.onCloseClick != null){
      this.onCloseClick();
    }
  }

  void _startProgress() {
    _logger.finest('progress started');
    this._buttonElem.classes.add('in-progress');
    if(this.progressStyle == 'percent'){
      this._progressInnerElem.style.width = '0';
    }

    this._progressElem.style.opacity = '1';
  }
  
  void _stopProgress() {
    _logger.finest('progress stopped');
    // call asynchronously after 300ms to ensure that
    // the width transition completes from the last
    // call to setProgress()
    this._buttonElem.classes.remove('in-progress');
    new Timer(new Duration(milliseconds: 300), (){
      this._progressElem.style.opacity = '0';
    });
  }
}
