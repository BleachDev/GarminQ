import Toybox.Lang;
import Toybox.WatchUi;

class KeyboardDelegate extends BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onPreviousPage() as Boolean {
        KeyboardView.selected = (KeyboardView.selected + 1) % 29;

        WatchUi.requestUpdate();
        return true;
    }

    function onNextPage() as Boolean {
        KeyboardView.selected = (KeyboardView.selected + 29 - 1) % 29;

        WatchUi.requestUpdate();
        return true;
    }

    function onSelect() as Boolean {
        if (KeyboardView.selected == 26) {
            KeyboardView.caps = KeyboardView.caps == 0 ? 50000 : 0;
        } else if (KeyboardView.selected == 27) {
            if (KeyboardView.string.length() > 0) {
                KeyboardView.string = KeyboardView.string.substring(0, KeyboardView.string.length() - 1);
            }
        } else if (KeyboardView.selected == 28) {
            AddView.title = KeyboardView.string;
            WatchUi.popView(WatchUi.SLIDE_RIGHT);
        } else {
            KeyboardView.string += KeyboardView.chr(KeyboardView.selected);
            if (KeyboardView.caps > 0) {
                KeyboardView.caps--;
            }
        }

        WatchUi.requestUpdate();
        return true;
    }
}

