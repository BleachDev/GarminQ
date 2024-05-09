import Toybox.Application;
import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;

class KeyboardView extends View {

    private static var CHARS = 29;

    public static var string as String;
    public static var caps;
    public static var selected;

    function initialize(string) {
        View.initialize();
        self.string = string;
        caps = 1;
        selected = 0;
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        View.onUpdate(dc);

        var W = dc.getWidth();
        var H = dc.getHeight();

        for (var i = 0; i < 5; i++) {
            var id = (selected + i - 2 + CHARS) % CHARS;
            drawValue(dc, W / 4.9 * i, H / 2.6, chr(id), selected == id, Graphics.FONT_MEDIUM);
        }

        dc.drawText(W / 2, H / 1.7, Graphics.FONT_MEDIUM, string, Graphics.TEXT_JUSTIFY_CENTER);
    }

    public static function chr(id) {
        if (id == 26) {
            return "Aa";
        } else if (id == 27) {
            return "<<";
        } else if (id == 28) {
            return "OK";
        } else {
            return ((caps > 0 ? 65 : 97) + id).toChar().toString();
        }
    }
}