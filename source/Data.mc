import Toybox.Lang;
import Toybox.Application;
import Toybox.Time;

// object oriented programming? data structures? whats that?
// surely this won't have scalability issues..
typedef Experiment as [String, Array, Number, Number, Number, Number, Array<Record>];
typedef BgExperiment as [String, Array, Number, Number, Number, Number, Number];
typedef Record as [Number, Number, String, Number, Number, Number];

var EX_NAME = 0;
var EX_INPUT = 1;
var EX_GAP = 2;
var EX_START_H = 3;
var EX_END_H = 4;
var EX_DAYS = 5;
var EX_RECORDS = 6;
var EX_BG_LAST_TRIGGER = 6;

var EX_INPUT_V as Array<Array> = [ [1, 2, 3, 4, 5], [1, 2, 3, 4, 5, 6, 7, 8, 9, 10], ["No", "Yes"] ];
var EX_DAYS_S as Array<String> = [ "All Days", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun", "Mon-Fri", "Sat-Sun" ];

var RE_TIME = 0;
var RE_VALUE = 1;
var RE_ACTIVITY = 2;
var RE_HR = 3;
var RE_BATTERY = 4;
var RE_STRESS = 5;
class Data {

    // experiments = [
    //   Experiment [
    //     Name
    //     Input []
    //     Gap
    //     StartHour
    //     EndHour
    //     Days
    //     Records [
    //       Time
    //       Value
    //       Activity Type (See: https://developer.garmin.com/connect-iq/api-docs/Toybox/Activity.html, Sport Enum)
    //       Heart Rate
    //       Body Battery (null If Unsupported)
    //       Stress (null If Unsupported)
    //     ]
    //   ]
    // ]
    public var experiments as Array<Experiment> = [];
    // Copy of experiments but instead of Records, the last value is a timestamp of the last trigger
    (:background)
    public var bgExperiments as Array<BgExperiment> = [];

    public var statsMode as Number = 0;
    (:background)
    public var triggerInActivity as Boolean = false;

    function load() {
        if (Storage.getValue("experiments") != null) {
            experiments = Storage.getValue("experiments") as Array<Experiment>;

            for (var i = 0; i < experiments.size(); i++) {
                // Fix for updating to 1.2, if we don't have all stats on all records, fill with null
                var re = experiments[i][EX_RECORDS] as Array<Record>;
                for (var r = 0; r < re.size(); r++) {
                    while (re[r].size() < 6) {
                        re[r].add(null);
                    }
                }

                // Fix for updating to 1.3, if "input" is a number, convert to array
                if (experiments[i][EX_INPUT] instanceof Number) {
                    experiments[i][EX_INPUT] = EX_INPUT_V[experiments[i][EX_INPUT]];
                }
            }
        }
        if (Storage.getValue("statsMode") != null) {
            statsMode = Storage.getValue("statsMode");
        }
        if (Storage.getValue("inActivity") != null) {
            triggerInActivity = Storage.getValue("inActivity");
        }
    }

    (:background)
    function loadBg() {
        if (Storage.getValue("bgExperiments") != null) {
            bgExperiments = Storage.getValue("bgExperiments") as Array;
        }
        if (Storage.getValue("inActivity") != null) {
            triggerInActivity = Storage.getValue("inActivity");
        }
    }

    function saveExp() {
        Storage.setValue("experiments", experiments as Array);

        bgExperiments = [];
        for (var i = 0; i < experiments.size(); i++) {
            var ex = experiments[i] as Experiment;
            var re = ex[EX_RECORDS] as Array<Record>;
            bgExperiments.add([ ex[0], ex[1], ex[2], ex[3], ex[4], ex[5], re.size() == 0 ? 0 : re[re.size() - 1][RE_TIME] ]);
        }
        Storage.setValue("bgExperiments", bgExperiments as Array);
        Background.registerForTemporalEvent(new Duration(5 * 60));
    }
}