import Toybox.Application;
import Toybox.Background;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.Time;
import Toybox.WatchUi;

(:background)
public var data as Data?;

(:background)
class App extends Application.AppBase {

    public static var bgData = [];

    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
        data = new Data();
        // Trying to figure out what my own code does challenge (hard)
        // Clear stored bgData, if we have pending bgData it will be loaded AFTER onStart by onBackgroundData
        bgData = [];
        System.println("> start");

        if (Background.getTemporalEventRegisteredTime() == null) {
            Background.registerForTemporalEvent(new Duration(5 * 60));
        }
    }

    // Return the initial view of your application here
    function getInitialView() as [ WatchUi.Views ] or [ WatchUi.Views, WatchUi.InputDelegates ] {
        data.load();
        System.println("> initalview " + bgData);

        return bgData.size() > 0 ? [ new NotificationView(data.experiments[bgData[0]], -1), new NotificationDelegate() ]
                            : [ new ExperimentsView(), new ExperimentsDelegate() ];
    }

    function getServiceDelegate() as [ System.ServiceDelegate ] {
        System.println("> getservice");
        data.loadBg();
        return [ new BackgroundDelegate() ];
    }

    function onBackgroundData(bgData as Application.PersistableType) {
        self.bgData = bgData;
    }
}

function drawHeader(dc as Graphics.Dc, W as Number, H as Number, text as String) {
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
    var font = text.length() > 16 ? Graphics.FONT_XTINY : text.length() > 13 ? Graphics.FONT_TINY : text.length() > 10 ? Graphics.FONT_SMALL : Graphics.FONT_MEDIUM;
    dc.drawText(W / 2, H / 5.1 - dc.getFontHeight(font), font, text, Graphics.TEXT_JUSTIFY_CENTER);
}

function drawValue(dc as Graphics.Dc, x as Float or Number, y as Float or Number, text as String, selected as Boolean, font as FontDefinition) {
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
    if (selected) {
        dc.fillRectangle(x - dc.getFontHeight(font) / 6, y,
                            dc.getTextWidthInPixels(text, font) + dc.getFontHeight(font) / 3,
                            dc.getFontHeight(font));
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
    }

    dc.drawText(x, y, font, text, Graphics.TEXT_JUSTIFY_LEFT);
}