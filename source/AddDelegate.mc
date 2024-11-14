import Toybox.Lang;
import Toybox.WatchUi;

class AddDelegate extends BehaviorDelegate {

    private static var GAP_OPTIONS as Array<Number> = [ 10, 20, 30, 45, 60, 90, 120, 180, 300, 1440, 2147483647 ];

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onNextPage() as Boolean {
        if (AddView.gap == 2147483647 && AddView.selected == 4) {
            AddView.selected += 4;
        } else if (AddView.selected < 8) {
            AddView.selected++;
        }

        WatchUi.requestUpdate();
        return true;
    }

    function onPreviousPage() as Boolean {
        if (AddView.gap == 2147483647 && AddView.selected == 8) {
            AddView.selected -= 4;
        } else if (AddView.selected > 0) {
            AddView.selected--;
        }

        WatchUi.requestUpdate();
        return true;
    }

    function onSelect() as Boolean {
        if (AddView.selected == 0) {
            // Change Title
            if (WatchUi has :TextPicker) {
                WatchUi.pushView(
                    new TextPicker(""),
                    new TitlePickerDelegate(),
                    WatchUi.SLIDE_LEFT
                );
            } else {
                WatchUi.pushView(
                    new KeyboardView(""),
                    new KeyboardDelegate(method(:_onTextEnter)),
                    WatchUi.SLIDE_LEFT
                );
            }
        } else if (AddView.selected == 1) {
            // Change Input
            // BAD way to do this, but works for now (until we decide to change EX_INPUT_V)
            AddView.input = EX_INPUT_V[AddView.input.size() == 5 ? 1 : AddView.input.size() == 10 ? 2 : 0];
        } else if (AddView.selected == 2) {
            // Edit Values
            var menu = new WatchUi.Menu();
            menu.setTitle("Values..");
            for (var i = 0; i < AddView.input.size(); i++) {
                menu.addItem((i + 1) + ": " + AddView.input[i], i as Symbol); // Can you believe this isn't Illegal?
            }
            WatchUi.pushView(menu, new ValueMenuDelegate(), WatchUi.SLIDE_IMMEDIATE);
        } else if (AddView.selected == 3) {
            // Next Page
            AddView.selected++;
        } else if (AddView.selected == 4) {
            // Change Gap
            AddView.gap = GAP_OPTIONS[(GAP_OPTIONS.indexOf(AddView.gap) + 1) % GAP_OPTIONS.size()];
        } else if (AddView.selected == 5) {
            // Change Start Hour
            AddView.startH = (AddView.startH + 1) % 24;
        } else if (AddView.selected == 6) {
            // Change End Hour
            AddView.endH = (AddView.endH + 1) % 24;
        } else if (AddView.selected == 7) {
            // Change Days
            AddView.days = (AddView.days + 1) % 10;
        } else {
            // Save
            if (AddView.modifying == -1) {
                data.experiments.add([ AddView.title, AddView.input, AddView.gap, AddView.startH, AddView.endH, AddView.days, [] ]);
            } else {
                data.experiments[AddView.modifying][EX_NAME] = AddView.title;
                data.experiments[AddView.modifying][EX_INPUT] = AddView.input;
                data.experiments[AddView.modifying][EX_GAP] = AddView.gap;
                data.experiments[AddView.modifying][EX_START_H] = AddView.startH;
                data.experiments[AddView.modifying][EX_END_H] = AddView.endH;
                data.experiments[AddView.modifying][EX_DAYS] = AddView.days;
            }

            data.saveExp();
            WatchUi.popView(WatchUi.SLIDE_RIGHT);
        }

        WatchUi.requestUpdate();
        return true;
    }

    function _onTextEnter(string) {
        AddView.title = string;
    }
}

class TitlePickerDelegate extends TextPickerDelegate {

    function initialize() {
        TextPickerDelegate.initialize();
    }

    function onTextEntered(text, changed) {
        if (changed) {
            AddView.title = text;
        }
        return true;
    }
}

class ValueMenuDelegate extends MenuInputDelegate {

    private var index;

    function initialize() {
        MenuInputDelegate.initialize();
    }

    function onMenuItem(index) {
        self.index = index;
        if (WatchUi has :TextPicker) {
            WatchUi.pushView(
                new TextPicker(""),
                new ValuePickerDelegate(index),
                WatchUi.SLIDE_LEFT
            );
        } else {
            WatchUi.pushView(
                new KeyboardView(""),
                new KeyboardDelegate(method(:_onTextEnter)),
                WatchUi.SLIDE_LEFT
            );
        }
    }

     function _onTextEnter(string) {
        AddView.input[index] = string;
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
    }
}

class ValuePickerDelegate extends TextPickerDelegate {

    var index;

    function initialize(index) {
        TextPickerDelegate.initialize();
        self.index = index;
    }

    function onTextEntered(text, changed) {
        if (changed) {
            AddView.input[index] = text;
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        }
        return true;
    }
}