import Toybox.Application;
import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.Time;

class RecordsView extends View {

    public static var ex as Experiment;
    public static var offset = 0;
    public static var selected = 0;

    function initialize(ex) {
        View.initialize();
        self.ex = ex;
        self.offset = 0;
        self.selected = 0;
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        View.onUpdate(dc);

        var W = dc.getWidth();
        var H = dc.getHeight();
        var TINY_H = dc.getFontHeight(Graphics.FONT_TINY) * 0.9;

        drawHeader(dc, W, H, ex[EX_NAME]);

        var records = ex[EX_RECORDS] as Array<Record>;
        for (var i = offset; i <= offset + 6 && i <= records.size(); i++) {
            var h = H / 4 + (TINY_H * 2.2) * (i - offset);
            if (i == selected) {
                dc.setColor(0x3A3791, Graphics.COLOR_TRANSPARENT);
                dc.fillRectangle(W / 15, h, W - W / 7.5, TINY_H * 2.2);
                dc.setColor(INSTINCT_MODE ? 0xFFFFFF : 0x282663, Graphics.COLOR_TRANSPARENT);
                dc.fillRectangle(W / 15, h, W / 50, TINY_H * 2.2);
                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            }

            if (i == 0) {
                dc.drawText(W / 10, h, Graphics.FONT_TINY, "+ Add Record", Graphics.TEXT_JUSTIFY_LEFT);
                continue;
            }

            var re = records[records.size() - i];
            var time = Time.Gregorian.info(new Moment(re[RE_TIME]), Time.FORMAT_MEDIUM);
            dc.drawText(W / 10, h, Graphics.FONT_TINY, time.month + " " + time.day + " " + time.year, Graphics.TEXT_JUSTIFY_LEFT);
            dc.drawText(W / 9, h + TINY_H, Graphics.FONT_XTINY, time.hour.format("%02d") + ":" + time.min.format("%02d") + ":" + time.sec.format("%02d"), Graphics.TEXT_JUSTIFY_LEFT);
            dc.drawText(W - W / 10, h, Graphics.FONT_TINY,
                        ex[EX_INPUT] == 2 ? (re[RE_VALUE] == 0 ? "No" : "Yes") : re[RE_VALUE] + 1, Graphics.TEXT_JUSTIFY_RIGHT);
        }
    }
}