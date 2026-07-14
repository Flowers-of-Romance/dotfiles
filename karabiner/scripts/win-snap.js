// Win+Arrows snap with self-managed restore.
// up|left|right: record the window's pre-snap position/size (once per chain), then fire Raycast deeplink.
// down: if we have a record for the frontmost app -> restore that exact geometry; otherwise do nothing.
ObjC.import('AppKit');

var HOME = ObjC.unwrap($.NSHomeDirectory());
var STATE_PATH = HOME + '/.config/karabiner/scripts/.win-snap-state.json';

function loadState() {
  var s = $.NSString.stringWithContentsOfFileEncodingError($(STATE_PATH), $.NSUTF8StringEncoding, null);
  if (s.isNil()) return {};
  try { return JSON.parse(ObjC.unwrap(s)); } catch (e) { return {}; }
}
function saveState(st) {
  $(JSON.stringify(st)).writeToFileAtomicallyEncodingError($(STATE_PATH), true, $.NSUTF8StringEncoding, null);
}
function shell(cmd) {
  var app = Application.currentApplication();
  app.includeStandardAdditions = true;
  app.doShellScript(cmd);
}

function run(argv) {
  var cmd = argv[0];
  var dry = argv.indexOf('--dry-run') >= 0;
  var front = $.NSWorkspace.sharedWorkspace.frontmostApplication;
  if (front.isNil()) return 'no frontmost app';
  var key = ObjC.unwrap(front.bundleIdentifier) || ObjC.unwrap(front.localizedName);
  var st = loadState();

  var se = Application('System Events');
  var procs = se.applicationProcesses.whose({ frontmost: true });
  if (procs.length === 0) return 'no frontmost process';
  var wins = procs[0].windows();
  if (wins.length === 0) return 'no window';
  var win = wins[0];
  var pos = win.position();
  var size = win.size();
  var fullHeight = size[1] >= $.NSScreen.mainScreen.visibleFrame.size.height - 60;

  var deeplinks = { up: 'maximize', left: 'left-half', right: 'right-half' };
  if (cmd in deeplinks) {
    // Record pre-snap geometry unless we are mid-chain (already snapped by us and still full-height)
    var record = !(st[key] && fullHeight);
    if (dry) return key + ' record=' + record + ' -> ' + deeplinks[cmd];
    if (record) {
      st[key] = { pos: pos, size: size, t: Date.now() };
      saveState(st);
    }
    shell('open -g "raycast://extensions/raycast/window-management/' + deeplinks[cmd] + '"');
    return cmd;
  }

  // down: restore recorded geometry, or do nothing
  var e = st[key];
  if (!e) return dry ? key + ' no record -> nothing' : 'nothing';
  if (dry) return key + ' -> restore to ' + e.pos + ' / ' + e.size;
  win.position = e.pos;
  win.size = e.size;
  win.position = e.pos;
  delete st[key];
  saveState(st);
  return 'restored';
}
