import Toybox.Lang;
import Toybox.WatchUi;

class AddDelegate extends BehaviorDelegate {

    private static var GAP_OPTIONS = [ 10, 20, 30, 45, 60, 90, 120, 180, 300, 1440 ] as Array<Number>;

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onNextPage() as Boolean {
        if (AddView.selected < 6) {
            AddView.selected++;
        }

        WatchUi.requestUpdate();
        return true;
    }

    function onPreviousPage() as Boolean {
        if (AddView.selected > 0) {
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
                    new KeyboardDelegate(),
                    WatchUi.SLIDE_LEFT
                );
            }
        } else if (AddView.selected == 1) {
            // Change Input
            AddView.input = (AddView.input + 1) % EX_INPUT_S.size();
        } else if (AddView.selected == 2) {
            // Change Gap
            AddView.gap = GAP_OPTIONS[(GAP_OPTIONS.indexOf(AddView.gap) + 1) % GAP_OPTIONS.size()];
        } else if (AddView.selected == 3) {
            // Change Start Hour
            AddView.startH = (AddView.startH + 1) % 24;
        } else if (AddView.selected == 4) {
            // Change End Hour
            AddView.endH = (AddView.endH + 1) % 24;
        } else if (AddView.selected == 5) {
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
