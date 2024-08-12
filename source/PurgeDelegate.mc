import Toybox.Lang;
import Toybox.WatchUi;

class PurgeDelegate extends BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onNextPage() as Boolean {
        if (PurgeView.selected < 3) {
            PurgeView.selected++;
        }

        WatchUi.requestUpdate();
        return true;
    }

    function onPreviousPage() as Boolean {
        if (PurgeView.selected > 0) {
            PurgeView.selected--;
        }

        WatchUi.requestUpdate();
        return true;
    }

    function onSelect() as Boolean {
        if (PurgeView.selected == 0) {
            // Change Day
            PurgeView.day++;
        } else if (PurgeView.selected == 1) {
            // Change Month
            PurgeView.month = PurgeView.month % 12 + 1; // Weird code but month is 1-12
        } else if (PurgeView.selected == 2) {
            // Change Year
            PurgeView.year++;
            if (PurgeView.year > Time.Gregorian.info(Time.now(), Time.FORMAT_SHORT).year) {
                PurgeView.year -= 6;
            }
        } else {
            // Save
            PurgeView.countRecords(true);
            data.saveExp();
            WatchUi.popView(WatchUi.SLIDE_RIGHT);
        }

        // Leap Day functionality to be added on Feb 28 2028.
        var m = PurgeView.month;
        var d = PurgeView.day;
        if (d > 31 || (d > 30 && (m == 4 || m == 6 || m == 9 || m == 11)) || (d > 28 && m == 2)) {
            PurgeView.day = 1;
        }
        
        PurgeView.count = PurgeView.countRecords(false);

        WatchUi.requestUpdate();
        return true;
    }
}
