part of varxa_ui;

@Injectable()
@Decorator(
  selector: '[varxa-button-group]',
  visibility: Directive.DIRECT_CHILDREN_VISIBILITY,
  map: const {'mode' : '@mode'}
)
class VarxaButtonGroup {
  String mode;
  final _buttons = new Set<VarxaButton>();

  void _registerMouseDown(VarxaButton btn){
    if(!_buttons.contains(btn)){
      throw 'button not part of group';
    }

    switch(this.mode != null ? this.mode : 'radio'){
      case 'check':
      btn.checked = !btn.checked;
    break;
      case 'radio':
      _buttons.forEach((b) => b.checked = btn == b);
    break;
    }
  }
}