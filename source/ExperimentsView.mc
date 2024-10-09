import Toybox.Application;
import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;

class ExperimentsView extends View {

    public static var offset = 0;
    public static var selected = 0;

    function initialize() {
        View.initialize();
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        View.onUpdate(dc);

        var W = dc.getWidth();
        var H = dc.getHeight();
        var TINY_H = dc.getFontHeight(Graphics.FONT_TINY) * 0.9;

        drawHeader(dc, W, H, INSTINCT_MODE ? "Exps." : "Experiments");

        for (var i = offset; i <= offset + 6 && i <= data.experiments.size(); i++) {
            var h = H / 4 + (TINY_H * 2.2) * (i - offset);
            if (i == selected) {
                dc.setColor(0x1E46A0, Graphics.COLOR_TRANSPARENT);
                dc.fillRectangle(W / 15, h, W - W / 7.5, TINY_H * 2.2);
                dc.setColor(INSTINCT_MODE ? 0xFFFFFF : 0x102550, Graphics.COLOR_TRANSPARENT);
                dc.fillRectangle(W / 15, h, W / 50, TINY_H * 2.2);
                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            }

            if (i == data.experiments.size()) {
                dc.drawText(W / 10, h, Graphics.FONT_TINY, "+ Add Experiment", Graphics.TEXT_JUSTIFY_LEFT);
                dc.drawText(W / 9, h + TINY_H, Graphics.FONT_XTINY, "Purge / Options / Export", Graphics.TEXT_JUSTIFY_LEFT);
                continue;
            }

            var ex = data.experiments[i];
            var re = ex[EX_RECORDS] as Array<Record>;
            var days = (re.size() == 0 ? 0 : re[re.size() - 1][RE_TIME] - re[0][RE_TIME]) / 86400;
            dc.drawText(W / 10, h, Graphics.FONT_TINY, ex[EX_NAME], Graphics.TEXT_JUSTIFY_LEFT);
            dc.drawText(W / 9.5, h + TINY_H, Graphics.FONT_XTINY,
                        ex[EX_START_H].format("%02d") + "-" + ex[EX_END_H].format("%02d") + " " + EX_DAYS_S[ex[EX_DAYS]], Graphics.TEXT_JUSTIFY_LEFT);

            var stat1 = days + " Day" + (days == 1 ? "" : "s");
            var stat2 = re.size() + (INSTINCT_MODE ? " Rec" : " Record") + (re.size() == 1 ? "" : "s");
            if (data.statsMode > 0) {
                var minuteAvg = 1440 * (data.statsMode == 1 ? 7 : 1);
                var sum1 = 0.0;
                var c1 = 0;
                var sum2 = 0.0;
                var c2 = 0;
                for (var j = re.size() - 1; j >= 0; j--) {
                    var time = re[j][RE_TIME];
                    if (time < re[re.size() - 1][RE_TIME] - minuteAvg * 2) {
                        break;
                    } else if (time < re[re.size() - 1][RE_TIME] - minuteAvg) {
                        sum2 += re[j][RE_VALUE] + 1;
                        c2++;
                    } else {
                        sum1 += re[j][RE_VALUE] + 1;
                        c1++;
                    }
                }

                sum1 = (c1 == 0 ? 0.0 : sum1 / c1);
                sum2 = (c2 == 0 ? 0.0 : sum2 / c2);
                stat1 = sum1.format("%.1f") + " (" + minuteAvg / 1440 + "d)";
                stat2 = ((sum1 / (sum2 == 0.0 ? sum1 == 0.0 ? 1.0 : sum1 : sum2)) * 100 - 100).format("%+.1f") + "%";
            }

            if (i == offset && INSTINCT_MODE) {
                dc.drawText(W - W / 5.5, H / 19, Graphics.FONT_TINY, stat1, Graphics.TEXT_JUSTIFY_CENTER);
                dc.drawText(W - W / 5.5, H / 19 + TINY_H, Graphics.FONT_XTINY, stat2, Graphics.TEXT_JUSTIFY_CENTER);
            } else { 
                dc.drawText(W - W / 10, h, Graphics.FONT_TINY, stat1, Graphics.TEXT_JUSTIFY_RIGHT);
                dc.drawText(W - W / 10, h + TINY_H, Graphics.FONT_XTINY, stat2, Graphics.TEXT_JUSTIFY_RIGHT);
            }
        }
    }
}