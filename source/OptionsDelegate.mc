import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class OptionsDelegate extends BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onNextPage() as Boolean {
        if (OptionsView.selected < 1) {
            OptionsView.selected++;
        }

        WatchUi.requestUpdate();
        return true;
    }

    function onPreviousPage() as Boolean {
        if (OptionsView.selected > 0) {
            OptionsView.selected--;
        }

        WatchUi.requestUpdate();
        return true;
    }

    function onSelect() as Boolean {
        if (OptionsView.selected == 0) {
            // Change Stat Mode
            data.statsMode = (data.statsMode + 1) % 3;
            Storage.setValue("statsMode", data.statsMode);
        } else {
            // Save
            WatchUi.popView(WatchUi.SLIDE_RIGHT);
        }

        WatchUi.requestUpdate();
        return true;
    }
}
