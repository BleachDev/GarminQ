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
            Communications.makeWebRequest("https://api.bleach.dev/file",
                                          {"data" => data.experiments, "deviceId" => System.getDeviceSettings().uniqueIdentifier},
                { :method => Communications.HTTP_REQUEST_METHOD_POST,
                  :headers => {"Content-Type" => Communications.REQUEST_CONTENT_TYPE_JSON} }, method(:onExport));
        }
    }

    function onExport(responseCode as Number, data as Dictionary?) as Void {
        System.println("Finish Export " + responseCode + " " + data);
        WatchUi.pushView(new ExportResultsView(data, responseCode), new BehaviorDelegate(), WatchUi.SLIDE_BLINK);
    }
}

class ExportResultsView extends WatchUi.View {

    private var response;
    private var code;

    function initialize(response, code) {
        View.initialize();
        self.response = response;
        self.code = code;
    }

    function onUpdate(dc) {
        View.onUpdate(dc);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        drawHeader(dc, dc.getWidth(), dc.getHeight(), "EXPORT");
        dc.drawText(dc.getWidth() / 2, dc.getHeight() / 3, Graphics.FONT_TINY,
                    response == null ? "ERROR " + code + "\nOut of Memory?\nTry purging recs." : "https://\napi.bleach.dev/\nview?id=" + response["id"], Graphics.TEXT_JUSTIFY_CENTER);
    }
}
