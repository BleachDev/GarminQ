import Toybox.Lang;
import Toybox.WatchUi;

class RecordsDelegate extends BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onNextPage() as Boolean {
        if (RecordsView.selected < RecordsView.ex[EX_RECORDS].size()) {
            RecordsView.selected++;
            if (RecordsView.offset < RecordsView.selected - 2) {
                RecordsView.offset++;
            }
        }

        WatchUi.requestUpdate();
        return true;
    }

    function onPreviousPage() as Boolean {
        if (RecordsView.selected > 0) {
            RecordsView.selected--;
            if (RecordsView.offset > RecordsView.selected) {
                RecordsView.offset--;
            }
        }

        WatchUi.requestUpdate();
        return true;
    }

    function onSelect() as Boolean {
        if (RecordsView.selected == 0) {
            // Add Record
            WatchUi.pushView(new NotificationView(RecordsView.ex, -1), new NotificationDelegate(), WatchUi.SLIDE_LEFT);
        } else {
            // Edit Record
            var menu = new Menu();
            menu.setTitle("Modify Record");
            menu.addItem("Set Value", :edit);
            menu.addItem("Delete", :delete);
            WatchUi.pushView(menu, new RecordsMenuDelegate(), WatchUi.SLIDE_LEFT);
        }

        return true;
    }
}

class RecordsMenuDelegate extends MenuInputDelegate {

    function initialize() {
        MenuInputDelegate.initialize();
    }

    function onMenuItem(item) {
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);

        if (item == :edit) {
            WatchUi.pushView(new NotificationView(RecordsView.ex, RecordsView.ex[EX_RECORDS].size() - RecordsView.selected), new NotificationDelegate(), WatchUi.SLIDE_LEFT);
        } else if (item == :delete) {
            WatchUi.pushView(
                new Confirmation("DELETE record?"),
                new RecordsDeleteDelegate(),
                WatchUi.SLIDE_IMMEDIATE
            );
        }
    }
}


class RecordsDeleteDelegate extends ConfirmationDelegate {

    function initialize() {
        ConfirmationDelegate.initialize();
    }

    function onResponse(response) {
        if (response == WatchUi.CONFIRM_YES) {
            RecordsView.ex[EX_RECORDS].remove(RecordsView.ex[EX_RECORDS][RecordsView.ex[EX_RECORDS].size() - RecordsView.selected]);
            data.saveExp();
            if (RecordsView.selected >= RecordsView.ex[EX_RECORDS].size()) {
                RecordsView.selected--;
            }
        }
        return true;
    }
}
