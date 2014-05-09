part of varxa_ui;

@Decorator(
  selector: '[varxa-button-group]',
  visibility: Directive.DIRECT_CHILDREN_VISIBILITY,
  map: const {'type' : '@type'}
)
class VarxaButtonGroup {
  String type;
  final _buttons = new Set<VarxaButton>();

  void _registerMouseDown(VarxaButton btn){
    if(!_buttons.contains(btn)){
      throw 'button not part of group';
    }

    switch(this.type != null ? this.type : 'radio'){
      case 'check':
      btn.checked = !btn.checked;
    break;
      case 'radio':
      _buttons.forEach((b) => b.checked = btn == b);
    break;
    }
  }
}