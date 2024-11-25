import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class OptionsDelegate extends BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onNextPage() as Boolean {
        if (OptionsView.selected < 3) {
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
            Properties.setValue("statsMode", data.statsMode);
        } else if (OptionsView.selected == 1) {
            // Change Trigger In Activity
            data.inActivity = !data.inActivity;
            Properties.setValue("inActivity", data.inActivity);
        } else if (OptionsView.selected == 2) {
            // Change Distribution Mode
            data.distMode = (data.distMode + 1) % 2;
            Properties.setValue("distMode", data.distMode);
        } else {
            // Save
            WatchUi.popView(WatchUi.SLIDE_RIGHT);
        }

        WatchUi.requestUpdate();
        return true;
    }
}
