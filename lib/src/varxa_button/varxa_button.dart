part of varxa_ui;

typedef CloseClickedHandler(VarxaButton sender);

@Injectable()
@Component(
    selector: 'varxa-button', 
    templateUrl: 'packages/varxa_ui/src/varxa_button/varxa_button.html',
    cssUrl: 'packages/varxa_ui/src/varxa_button/varxa_button.css',
    map: const {
      'tag' : '=>!tag',
      'progress' : '=>progress',
      'progress-style': '@progressStyle',
      'closable': '=>isClosable',
      'checked' : '=>checked',
      'on-close-clicked' : '&onCloseClicked'
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

  dynamic tag;
  String _progressStyle;
  bool _checked = false;
  bool _isClosable;
  double _progress = 0.0;

  Function onCloseClicked;

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
  set progress(double value) {
    if(value == null){
      value = 0.0;
    }
    
    _logger.finest('progress set to $value');
    
    if(this._progress == value || this._buttonElem == null){
      return;
    }

    this._setProgress(value);
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
    _logger.finest('VarxaButton init');

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
    this._buttonElem.onMouseDown.listen((Event e){
      _logger.finest('button elem click');
      if(this._buttonGroup != null){
        this._buttonGroup._registerMouseDown(this);
      }
    });

    this._closer.onMouseDown.listen((Event e) {
      _logger.finest('close elem click');
      e.stopPropagation();

      if(this.onCloseClicked == null){
        return;
      }

      CloseClickedHandler handler = this.onCloseClicked();
      handler(this);
    });

    // hack to re-evaluate setter logic once our elements have been set.
    this.progressStyle = this.progressStyle;
    this.progress = this.progress;
    this.checked = this.checked;
    this.isClosable = this.isClosable;
  }

  void _setProgress(double percent) {
    if(percent < 0.0 || percent > 1.0) {
      throw 'percent must between 0.0 and 1.0';
    }
        
    switch(this.progressStyle){
      case STYLE_CONTINUOUS:
        if(percent > 0){
          this._startProgress();
        }else{
          this._stopProgress();
        }
        break;
      case STYLE_PERCENT:
        if(this.progress == 0.0 && percent > 0.0){
          this._startProgress();
        }
        
        this._progressInnerElem.style.width = '${percent * 100.0}%';
        
        if(percent == 1.0){
          this._stopProgress();
        }
        break;
    }
    
    this._progress = percent;
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
