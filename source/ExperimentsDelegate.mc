import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Application;
import Toybox.Graphics;

class ExperimentsDelegate extends BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onNextPage() as Boolean {
        if (ExperimentsView.selected < data.experiments.size()) {
            ExperimentsView.selected++;
            if (ExperimentsView.offset < ExperimentsView.selected - 2) {
                ExperimentsView.offset++;
            }
        }

        WatchUi.requestUpdate();
        return true;
    }

    function onPreviousPage() as Boolean {
        if (ExperimentsView.selected > 0) {
            ExperimentsView.selected--;
            if (ExperimentsView.offset > ExperimentsView.selected) {
                ExperimentsView.offset--;
            }
        }

        WatchUi.requestUpdate();
        return true;
    }

    function onSelect() as Boolean {
        if (ExperimentsView.selected == data.experiments.size()) {
            // Add Experiment
            var menu = new Menu();
            menu.setTitle("Experiments");
            menu.addItem("+ Add Experiment", :add);
            menu.addItem("- Purge Records", :purge);
            menu.addItem("* Options", :options);
            menu.addItem("> Export", :export);
            WatchUi.pushView(menu, new ExperimentsAddDelegate(), WatchUi.SLIDE_LEFT);
        } else {
            // Edit Experiment
            var menu = new Menu();
            menu.setTitle(data.experiments[ExperimentsView.selected][EX_NAME]);
            menu.addItem("View Records", :view);
            menu.addItem("Edit", :edit);
            menu.addItem("Delete", :delete);
            WatchUi.pushView(menu, new ExperimentsEditDelegate(), WatchUi.SLIDE_LEFT);
        }

        return true;
    }
}

class ExperimentsEditDelegate extends MenuInputDelegate {

    function initialize() {
        MenuInputDelegate.initialize();
    }

    function onMenuItem(item) {
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);

        if (item == :view) {
            WatchUi.pushView(
                new RecordsView(data.experiments[ExperimentsView.selected]),
                new RecordsDelegate(),
                WatchUi.SLIDE_LEFT
            );
        } else if (item == :edit) {
            WatchUi.pushView(
                new AddView(ExperimentsView.selected),
                new AddDelegate(),
                WatchUi.SLIDE_LEFT
            );
        } else if (item == :delete) {
            WatchUi.pushView(
                new Confirmation("DELETE experiment?"),
                new ExperimentsDeleteDelegate(),
                WatchUi.SLIDE_IMMEDIATE
            );
        }
    }
}


class ExperimentsDeleteDelegate extends ConfirmationDelegate {

    function initialize() {
        ConfirmationDelegate.initialize();
    }

    function onResponse(response) {
        if (response == WatchUi.CONFIRM_NO) {
            System.println("Cancel");
        } else {
            data.experiments.remove(data.experiments[ExperimentsView.selected]);
            data.saveExp();
            if (ExperimentsView.selected >= data.experiments.size()) {
                ExperimentsView.selected--;
            }
        }
        return true;
    }
}

class ExperimentsAddDelegate extends MenuInputDelegate {

    function initialize() {
        MenuInputDelegate.initialize();
    }

    function onMenuItem(item) {
        if (item == :add) {
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
            WatchUi.pushView(new AddView(-1), new AddDelegate(), WatchUi.SLIDE_LEFT);
        } else if (item == :purge) {
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
            WatchUi.pushView(new PurgeView(), new PurgeDelegate(), WatchUi.SLIDE_LEFT);
        } else if (item == :options) {
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
            WatchUi.pushView(new OptionsView(), new OptionsDelegate(), WatchUi.SLIDE_LEFT);
        } else if (item == :export) {
            System.println("Begin Export");
            var export = {};
            for (var i = 0; i < data.experiments.size(); i++) {
                var ex = data.experiments[i];
                export[ex[EX_NAME]] = {
                    "title" => ex[EX_NAME],
                    "input" => EX_INPUT_S[ex[EX_INPUT]],
                    "gap" => ex[EX_GAP],
                    "startHour" => ex[EX_START_H],
                    "endHour" => ex[EX_END_H],
                    "days" => ex[EX_DAYS],
                    "records" => []
                };

                for (var r = 0; r < ex[EX_RECORDS].size(); r++) {
                    var re = ex[EX_RECORDS][r];
                    export[ex[EX_NAME]]["records"].add({
                        "time" => re[RE_TIME],
                        "value" => re[RE_VALUE],
                        "activity" => re[RE_ACTIVITY],
                        "heartrate" => re[RE_HR],
                        "bodybattery" => re[RE_BATTERY]
                    });
                }
            }

            Communications.makeWebRequest("https://api.bleach.dev/file", export,
                { :method => Communications.HTTP_REQUEST_METHOD_POST,
                  :headers => {"Content-Type" => Communications.REQUEST_CONTENT_TYPE_JSON} }, method(:onExport));
        }
    }

    function onExport(responseCode as Number, data as Dictionary?) as Void {
        System.println("Finish Export " + responseCode + " " + data);
        if (responseCode == 200 && data != null) {
            WatchUi.pushView(new ExportResultsView(data["id"]), new BehaviorDelegate(), WatchUi.SLIDE_BLINK);
        }
    }
}

class ExportResultsView extends WatchUi.View {

    private var id;

    function initialize(id) {
        View.initialize();
        self.id = id;
    }

    function onUpdate(dc) {
        View.onUpdate(dc);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        drawHeader(dc, dc.getWidth(), dc.getHeight(), "EXPORT");
        dc.drawText(dc.getWidth() / 2, dc.getHeight() / 3, Graphics.FONT_TINY, "https://\napi.bleach.dev/\nfile?id=" + id, Graphics.TEXT_JUSTIFY_CENTER);
    }
}
