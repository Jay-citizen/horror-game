<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8" />
<meta name="viewport" content="width=device-width, initial-scale=1.0" />
<title>SAKANIGADIH'S DISAPPEARANCE — PS1 Detective Mystery</title>
<style>
  :root {
    --bg: #07080b;
    --panel: rgba(11, 13, 18, 0.95);
    --border: #3a4252;
    --accent: #d4a656;
    --cyan: #6cb6c9;
    --danger: #c94a4a;
    --ok: #5bb37a;
    --text: #e2dfd7;
    --muted: #8a8f9c;
    --mono: 'Courier New', Consolas, monospace;
  }
  * { box-sizing: border-box; margin: 0; padding: 0; user-select: none; }
  html, body { width: 100%; height: 100%; overflow: hidden; background: #000; color: var(--text); font-family: var(--mono); }

  /* PS1 320x240 Pixelated Canvas + Bayer Dithering / Scanline Overlay */
  #ps1-canvas {
    position: fixed; inset: 0; width: 100%; height: 100%;
    image-rendering: pixelated; image-rendering: crisp-edges; z-index: 1;
  }
  #crt-dither {
    position: fixed; inset: 0; pointer-events: none; z-index: 2;
    background-image:
      repeating-linear-gradient(0deg, rgba(0,0,0,0.22) 0px, rgba(0,0,0,0.22) 1px, transparent 1px, transparent 3px),
      radial-gradient(circle at center, transparent 55%, rgba(0,0,0,0.72) 100%);
  }

  /* Crosshair */
  #crosshair {
    position: fixed; top: 50%; left: 50%; width: 6px; height: 6px;
    transform: translate(-50%, -50%); background: rgba(235,230,215,0.65);
    pointer-events: none; z-index: 5; transition: transform 0.1s;
  }
  #crosshair.active { transform: translate(-50%, -50%) scale(2.2); background: var(--accent); }

  /* HUD */
  #hud { position: fixed; inset: 0; pointer-events: none; z-index: 10; display: none; }
  .hud-box {
    position: absolute; top: 14px; left: 14px; max-width: 400px;
    background: var(--panel); border: 2px solid var(--border); padding: 10px 14px;
  }
  .hud-night { color: var(--accent); font-size: 12px; font-weight: bold; letter-spacing: 1.5px; }
  .hud-loc { color: var(--cyan); font-size: 11px; margin: 2px 0 6px; }
  .hud-lead { font-size: 12px; color: var(--text); line-height: 1.4; }
  .hud-btns { position: absolute; top: 14px; right: 14px; display: flex; gap: 6px; pointer-events: auto; }
  .btn {
    background: var(--panel); color: var(--text); border: 2px solid var(--border);
    padding: 7px 11px; font-family: var(--mono); font-size: 11.5px; cursor: pointer;
  }
  .btn:hover { border-color: var(--accent); color: var(--accent); }
  .btn.primary { border-color: var(--accent); background: #1c1810; color: var(--accent); font-weight: bold; }

  #prompt {
    position: absolute; bottom: 84px; left: 50%; transform: translateX(-50%);
    background: var(--panel); border: 2px solid var(--accent); padding: 7px 14px;
    font-size: 12px; display: none; align-items: center; gap: 8px;
  }
  #prompt span.k { background: var(--accent); color: #090a0d; padding: 1px 6px; font-weight: bold; }
  #toast {
    position: absolute; top: 76px; right: 14px; background: var(--panel);
    border-left: 4px solid var(--ok); border-top: 1px solid var(--border);
    padding: 9px 13px; font-size: 12px; max-width: 320px; opacity: 0; transition: opacity 0.25s;
  }
  #toast.show { opacity: 1; }
  #controls-bar {
    position: absolute; bottom: 12px; left: 14px; font-size: 11px; color: var(--muted);
    background: rgba(7,8,11,0.8); padding: 5px 9px; border: 1px solid #252a34;
  }

  /* Modals */
  .overlay {
    position: fixed; inset: 0; background: rgba(4,5,8,0.88); z-index: 30;
    display: none; align-items: center; justify-content: center; padding: 18px;
  }
  .overlay.open { display: flex; }
  .window {
    background: var(--panel); border: 2px solid var(--border); width: 100%; max-width: 880px;
    max-height: 88vh; display: flex; flex-direction: column;
  }
  .win-head {
    padding: 12px 16px; border-bottom: 2px solid var(--border); display: flex;
    justify-content: space-between; align-items: center; background: #10131a;
  }
  .win-head h2 { font-size: 14px; color: var(--accent); letter-spacing: 1px; }
  .win-body { padding: 16px 18px; overflow-y: auto; font-size: 13px; line-height: 1.55; }

  /* Tabs */
  .tabs { display: flex; border-bottom: 2px solid var(--border); background: #0c0e14; flex-wrap: wrap; }
  .tab {
    padding: 8px 13px; background: transparent; border: none; border-right: 1px solid var(--border);
    color: var(--muted); font-family: var(--mono); font-size: 12px; cursor: pointer;
  }
  .tab.active { background: #171b24; color: var(--accent); font-weight: bold; }

  /* Evidence & Photo Flip Viewer */
  .ev-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(240px, 1fr)); gap: 10px; }
  .card { background: #12151e; border: 1px solid var(--border); padding: 11px; }
  .card h4 { color: var(--accent); font-size: 13px; margin-bottom: 4px; }
  .card .meta { color: var(--cyan); font-size: 11px; margin-bottom: 6px; }
  .doc-sheet {
    background: #dcd6c4; color: #191815; padding: 18px; border: 3px solid #6b6352;
    font-family: 'Courier New', monospace; white-space: pre-wrap; margin: 10px 0;
    transition: transform 0.2s; transform-origin: top left;
  }
  .doc-sheet.zoomed { transform: scale(1.16); }
  .photo-frame {
    background: #e8e4d8; color: #1a1a1a; padding: 14px 14px 26px; max-width: 420px;
    margin: 10px auto; border: 2px solid #8a8372; text-align: center;
  }
  .photo-art {
    height: 170px; background: #26313a; border: 1px solid #444; margin-bottom: 10px;
    display: flex; align-items: center; justify-content: center; color: #d8d4c8; font-size: 12px; padding: 10px;
  }

  /* Dialogue */
  #dialogue {
    position: fixed; bottom: 20px; left: 50%; transform: translateX(-50%);
    width: min(800px, 94vw); background: var(--panel); border: 2px solid var(--accent);
    padding: 15px 18px; z-index: 25; display: none;
  }
  #dialogue.open { display: block; }
  .dlg-head { display: flex; justify-content: space-between; margin-bottom: 8px; border-bottom: 1px solid var(--border); padding-bottom: 6px; }
  .dlg-speaker { color: var(--accent); font-weight: bold; font-size: 14px; }
  .dlg-state { font-size: 11px; padding: 2px 7px; border: 1px solid var(--border); color: var(--cyan); }
  .dlg-line { font-size: 13.5px; line-height: 1.55; margin-bottom: 12px; min-height: 44px; }
  .dlg-opts { display: flex; flex-wrap: wrap; gap: 7px; }

  /* Case Board */
  .board-wrap { display: grid; grid-template-columns: 1fr 1fr; gap: 14px; }
  @media (max-width: 720px) { .board-wrap { grid-template-columns: 1fr; } }
  .pin-list { display: flex; flex-direction: column; gap: 6px; max-height: 320px; overflow-y: auto; }
  .pin-item {
    padding: 8px 10px; background: #131720; border: 1px solid var(--border); cursor: pointer; font-size: 12px;
  }
  .pin-item.selected { border-color: var(--accent); background: #221d12; color: var(--accent); }
  .link-badge { padding: 7px 10px; border: 1px solid var(--ok); background: rgba(91,179,122,0.12); margin-bottom: 6px; font-size: 12px; }
  .recon-row { display: flex; gap: 8px; align-items: center; margin-bottom: 7px; }
  .recon-row select { flex: 1; background: #0f1219; color: var(--text); border: 1px solid var(--border); padding: 6px; font-family: var(--mono); font-size: 12px; }

  /* Cutscene & Title */
  #cutscene, #title-screen {
    position: fixed; inset: 0; z-index: 45; background: #050608;
    display: none; flex-direction: column; align-items: center; justify-content: center;
    padding: 28px; text-align: center;
  }
  #title-screen { display: flex; z-index: 50; background: radial-gradient(circle, #121620 0%, #050608 100%); }
  #cutscene.open { display: flex; }
  .cine-box { max-width: 680px; border: 2px solid var(--border); background: #0b0d13; padding: 24px 28px; text-align: left; }
  .cine-tag { color: var(--accent); font-size: 11px; letter-spacing: 2px; margin-bottom: 8px; }
  .cine-body { font-size: 14px; line-height: 1.7; white-space: pre-line; margin-bottom: 18px; color: #e2dfd7; }
</style>
</head>
<body>

<canvas id="ps1-canvas" width="320" height="240"></canvas>
<div id="crt-dither"></div>
<div id="crosshair"></div>

<!-- HUD -->
<div id="hud">
  <div class="hud-box">
    <div class="hud-night" id="hud-night">NIGHT 1 — THE OFFICE</div>
    <div class="hud-loc" id="hud-loc">Precinct 4 Cold Case Desk</div>
    <div class="hud-lead" id="hud-lead">Review the 2023 case files on your desk before ending the night.</div>
  </div>
  <div class="hud-btns">
    <button class="btn" id="btn-nb">NOTEBOOK [TAB]</button>
    <button class="btn" id="btn-flash">LIGHT [R]: OFF</button>
    <button class="btn" id="btn-pause">PAUSE [ESC]</button>
  </div>
  <div id="prompt"><span class="k">E / LMB</span><span id="prompt-txt">Inspect</span></div>
  <div id="toast"></div>
  <div id="controls-bar">WASD: Move | Mouse: Look | Shift: Sprint | Space: Jump | E/Click: Interact | R: Flashlight | Tab: Notebook | ESC: Pause</div>
</div>

<!-- DIALOGUE -->
<div id="dialogue">
  <div class="dlg-head">
    <span class="dlg-speaker" id="dlg-speaker">Name</span>
    <span class="dlg-state" id="dlg-state">COOPERATIVE</span>
  </div>
  <div class="dlg-line" id="dlg-line"></div>
  <div class="dlg-opts" id="dlg-opts"></div>
</div>

<!-- MODAL (Notebook / Viewer / Case Board / Map / Pause) -->
<div class="overlay" id="overlay">
  <div class="window">
    <div class="win-head">
      <h2 id="win-title">NOTEBOOK</h2>
      <button class="btn" id="win-close">CLOSE [ESC]</button>
    </div>
    <div class="tabs" id="nb-tabs" style="display:none;">
      <button class="tab active" data-t="evidence">Evidence</button>
      <button class="tab" data-t="statements">Statements</button>
      <button class="tab" data-t="timeline">Timeline</button>
      <button class="tab" data-t="map">Map</button>
      <button class="tab" data-t="hints">Hints</button>
    </div>
    <div class="win-body" id="win-body"></div>
  </div>
</div>

<!-- CUTSCENE -->
<div id="cutscene">
  <div class="cine-box">
    <div class="cine-tag" id="cine-tag">NIGHT 1 — PRECINCT 4</div>
    <div class="cine-body" id="cine-body"></div>
    <div style="display:flex; justify-content:space-between;">
      <button class="btn primary" id="cine-next">NEXT</button>
      <button class="btn" id="cine-skip">SKIP CUTSCENE</button>
    </div>
  </div>
</div>

<!-- TITLE SCREEN -->
<div id="title-screen">
  <div style="color:var(--accent); font-size:12px; letter-spacing:3px; margin-bottom:10px;">PRECINCT 4 COLD CASE FILE #2023-1014</div>
  <h1 style="font-size:clamp(26px,5vw,44px); letter-spacing:4px; margin-bottom:12px;">SAKANIGADIH'S DISAPPEARANCE</h1>
  <p style="max-width:540px; color:var(--muted); font-size:13px; line-height:1.6; margin-bottom:26px;">
    Autumn 2026. Three years after 17-year-old Sakanigadih binti Osman vanished, Detective Noriah Lim pulls the abandoned file in secret. Search, question, compare evidence, and uncover what really happened.
  </p>
  <div style="display:flex; flex-direction:column; gap:10px; width:260px;">
    <button class="btn primary" id="btn-start">NEW INVESTIGATION</button>
    <button class="btn" id="btn-load" disabled>CONTINUE CHECKPOINT</button>
    <button class="btn" id="btn-download-title">DOWNLOAD GAME (.HTML)</button>
  </div>
</div>

<script type="importmap">
{
  "imports": {
    "three": "https://cdn.jsdelivr.net/npm/three@0.170.0/build/three.module.js"
  }
}
</script>

<script type="module">
import * as THREE from 'three';

/* ============================================================================
   1. LOCKED CANON DATA: EVIDENCE, CONTRADICTIONS, CHARACTERS, TIMELINE
   ============================================================================ */
const EVIDENCE_DB = {
  EV01: {
    id: 'EV01', type: 'document', title: '2023 Official Missing Person Report',
    loc: 'Precinct 4 Cold Case Desk', night: 1, source: 'Precinct 4 Archive',
    summary: 'Filed 15 Oct 2023 by Encik Osman. Claims Sakanigadih (17) ran away at 19:00 on 14 Oct 2023 carrying a blue hard-shell suitcase.',
    detail: `ROYAL MALAYSIA POLICE — PRECINCT 4\nCASE #2023-1014 | STATUS: CLOSED (RUNAWAY)\nSubject: Sakanigadih binti Osman (Age 17)\nReported Missing: 15 October 2023, 08:10\nComplainant: Encik Osman bin Sulaiman (Father)\n\nSUMMARY:\nComplainant states subject left the family residence at approx. 19:00 on 14 October 2023 after an argument over pre-university exams, taking a blue hard-shell suitcase and personal clothing. No foul play suspected.`
  },
  EV02: {
    id: 'EV02', type: 'document', title: 'October 2023 Newspaper Clipping',
    loc: 'Precinct 4 Corkboard', night: 1, source: 'Local Press Archive',
    summary: 'Article quoting family spokesperson claiming Sakanigadih packed her blue suitcase and left voluntarily due to academic stress.',
    detail: `THE DAILY CHRONICLE — 18 OCTOBER 2023\n"LOCAL TEENAGER STILL MISSING AFTER EXAM STRESS"\n\nFamily representatives of Osman Timber & Transport confirmed that 17-year-old Sakanigadih binti Osman departed home on Saturday evening (14 Oct) with her blue hard-shell suitcase. "She was overwhelmed by school pressure and had no secrets," a relative stated.`
  },
  EV03: {
    id: 'EV03', type: 'photo', title: '2023 Official Case Photo Set',
    loc: 'Precinct 4 Filing Cabinet', night: 1, source: '2023 Investigating Officer',
    summary: 'Standard school ID portrait attached to the 2023 file. Shows Sakanigadih wearing her SMK Seri Sungai prefect badge.',
    frontText: '[PORTRAIT PHOTO: Sakanigadih binti Osman, age 17, wearing school uniform and carrying a worn olive canvas satchel strap over her shoulder.]',
    backText: 'STAMPED: PRECINCT 4 EVIDENCE UNIT — OCT 2023\nHandwritten note: "Supplied by parents. Last known likeness."'
  },
  EV04: {
    id: 'EV04', type: 'document', title: '2023 Official Police Timeline',
    loc: 'Precinct 4 Desk Folder', night: 1, source: 'Precinct 4 Archive',
    summary: 'States Sakanigadih withdrew from school and cut all contact after 10 Oct 2023, before departing at 19:00 on 14 Oct.',
    detail: `OFFICIAL CASE TIMELINE (#2023-1014)\n- 10 Oct 2023: Subject allegedly stops attending school activities and cuts contact with peers.\n- 14 Oct 2023, 19:00: Subject leaves Osman residence on foot with blue suitcase.\n- 15 Oct 2023, 08:10: Parents file runaway report.\n- 02 Nov 2023: Case suspended; classified voluntary runaway.`
  },
  EV05: {
    id: 'EV05', type: 'document', title: 'SMK Seri Sungai Debate & Attendance Roster',
    loc: 'Darius Menon (Neighbourhood Park)', night: 2, source: 'Darius Menon',
    summary: 'School log showing Sakanigadih attended debate prep on 12 & 13 Oct 2023 alongside debate partner Tariq Zulkifli (T.Z.).',
    detail: `SMK SERI SUNGAI — DEBATE SOCIETY LOG (OCT 2023)\n11 Oct 2023: Present — Sakanigadih Osman, Darius Menon, Tariq Zulkifli.\n13 Oct 2023: Present — Sakanigadih Osman (brought old municipal archive folders), Tariq Zulkifli.\nNote by Darius: "She never went anywhere without her olive canvas satchel."`
  },
  EV06: {
    id: 'EV06', type: 'photo', title: 'Aina’s Bedroom Sketch & Photo',
    loc: 'Aina Farhana (Residential Street)', night: 2, source: 'Aina Farhana',
    summary: 'Photo taken by Aina inside Sakanigadih’s bedroom on 16 Oct 2023: the blue hard-shell suitcase is still inside the open closet.',
    frontText: '[BEDROOM PHOTO: Sakanigadih’s bedroom taken 16 Oct 2023. Through the half-open wardrobe door sits a large blue hard-shell suitcase. The hook for her olive canvas satchel is empty.]',
    backText: 'Aina’s note: "16/10/2023 — Puan Zainab let me leave flowers in her room. Her blue suitcase was right there in the closet! Only her canvas satchel was missing."'
  },
  EV07: {
    id: 'EV07', type: 'document', title: 'Teoh Sundry Shop Delivery & CCTV Log',
    loc: 'Mr. Teoh Boon Hock (Lot 16)', night: 2, source: 'Mr. Teoh Boon Hock',
    summary: 'Timestamped camera & delivery ledger at the orchard lane junction showing Hafiz’s silver pickup entering at 21:05 on 14 Oct 2023.',
    detail: `TEOH SUNDRY SHOP (LOT 16) — LANE JUNCTION LOG\nDate: Saturday, 14 October 2023\n20:42 — Evening delivery van departs.\n21:05 — Silver 4x4 Pickup (Plate WXY 4418, Osman Timber) turns onto Private Orchard Lane toward Lot 14.\n21:48 — Same silver pickup exits Orchard Lane at high speed.`
  },
  EV08: {
    id: 'EV08', type: 'photo', title: 'Anonymous Polaroid Photograph',
    loc: 'Slipped under Precinct 4 Office Door', night: 3, source: 'Anonymous Sender',
    summary: 'Polaroid showing Sakanigadih alive and smiling outside Lot 9 Storage Depot holding a ledger. Back is dated 12 Oct 2023.',
    frontText: '[POLAROID PHOTO: Sakanigadih standing beside a corrugated warehouse door stenciled "OSMAN TIMBER — LOT 9 DEPOT", holding a cloth-bound workshop ledger.]',
    backText: 'Handwritten in neat ink:\n"12 October 2023 — 16:20\nLot 9 Storage Building, Jalan Kilang Lama.\nShe found what they hid in 2016. Look inside."'
  },
  EV09: {
    id: 'EV09', type: 'document', title: 'Fresh Brass Key Tag (Oct 2023)',
    loc: 'Lot 9 Storage Building — Front Desk Drawer', night: 4, source: 'Lot 9 Office Desk',
    summary: 'Stamped brass key tag and sign-out slip dated 11 Oct 2023—disproving Pak Cik Karim’s claim that Lot 9 was welded shut since 2018.',
    detail: `LOT 9 DEPOT KEY TAG & LOG SLIP\nTag Stamp: LOT 9 INNER ARCHIVE — KEY #02\nSign-Out Date: 11 October 2023\nAuthorized by: Karim bin Sulaiman\nCondition: Bright unoxidized brass; lock oiled recently.`
  },
  EV10: {
    id: 'EV10', type: 'document', title: '2016 Silent Workshop Repair Invoice',
    loc: 'Lot 9 Storage Building — Stash Bag', night: 4, source: 'Sakanigadih’s Stash Bag',
    summary: 'Hidden 2016 invoice for scrapping a blood-damaged pickup bumper on 10 Nov 2016—one day after cyclist Encik Roslan’s fatal hit-and-run.',
    detail: `CONFIDENTIAL CASH VOUCHER — 10 NOVEMBER 2016\nVehicle: Osman Timber Pickup WXY 4418 (Driver: Hafiz Osman)\nWork Performed: Front grille & right headlamp replacement, chassis repaint, scrap disposal of damaged parts.\nPolice Report Filed: NONE (Incident: Jalan Lama Sungai, 09/11/2016 — cyclist Encik Roslan).\nApproved by: Osman bin Sulaiman & Karim bin Sulaiman.`
  },
  EV11: {
    id: 'EV11', type: 'document', title: 'Draft Letters Between Sakanigadih & "T.Z."',
    loc: 'Lot 9 Storage Building — Stash Bag', night: 4, source: 'Sakanigadih’s Stash Bag',
    summary: 'Letters planning a 21:30 handover on 14 Oct 2023 behind the Lot 14 Osman Timber Annex so T.Z. can publish the 2016 cover-up.',
    detail: `FOLDED NOTEBOOK LETTERS (OCT 2023)\nFrom: Sakanigadih | To: T.Z.\n"They covered up the 2016 Jalan Lama Sungai crash that killed Encik Roslan. Hafiz was driving. I have the 2016 invoice and damaged headlamp bezel in my canvas satchel. Meet me Saturday 14 Oct at 21:30 behind the disused Lot 14 Osman Timber Annex in the private orchard. Bring your press camera. — S."\nReply signed: "T.Z. (Debate Partner)"`
  },
  EV12: {
    id: 'EV12', type: 'document', title: '15 Oct 2023 Concrete-Pour Delivery Docket',
    loc: 'Lot 9 Storage Building — Archive Crate', night: 4, source: 'Lot 9 Archive Crate',
    summary: 'Emergency Sunday morning concrete delivery docket dated 15 Oct 2023 for the Lot 14 Orchard Tool Shed floor.',
    detail: `EXPRESS READY-MIX CONCRETE DOCKET\nDelivery Date: Sunday, 15 October 2023 — 06:15 AM\nDestination: Lot 14 Private Orchard Tool Shed (Osman Property)\nOrdered by: Karim bin Sulaiman & Osman bin Sulaiman\nNotes: "Urgent interior floor slab pour — no exterior crew required."`
  },
  EV13: {
    id: 'EV13', type: 'item', title: 'Damaged Pickup Headlamp Bezel',
    loc: 'Lot 9 Storage Building — Locked Metal Cabinet', night: 4, source: 'Locked Archive Cabinet',
    summary: 'Dented 2016 pickup headlamp rim matching the Jalan Lama Sungai hit-and-run vehicle, hidden inside Lot 9.',
    detail: `PHYSICAL ITEM #EV13\nDented chrome headlamp bezel from a 2015-series pickup truck. Faint dark residue along the inner flange, wrapped in a 2016 Osman Timber rag.`
  },
  EV14: {
    id: 'EV14', type: 'item', title: 'Lot 14 Shed Physical Evidence Bundle',
    loc: 'Lot 14 Orchard Tool Shed (Beneath Concrete Patch)', night: 6, source: 'Lot 14 Concrete Excavation',
    summary: 'Recovered beneath the 15 Oct 2023 concrete patch: the blood-edged cast-iron survey marker, burned jacket zipper, and canvas satchel with the 2016 ledger.',
    detail: `FINAL NIGHT PHYSICAL EVIDENCE (HANDLED WITH FORENSIC CARE)\n1. Cast-iron boundary survey marker bearing trace impact evidence.\n2. Charred brass zipper and fabric fragments from Sakanigadih’s jacket.\n3. Water-stained olive canvas satchel containing the original 2016 workshop ledger.\n(Remains secured respectfully for Supt. Farahiyah’s forensic recovery team.)`
  }
};

const CONTRADICTIONS = [
  { id: 'C1', a: 'EV01', b: 'ST_SALMAH', title: 'C1: Runaway Departure Time (19:00 vs 20:35)', desc: 'EV01 claims Sakanigadih left at 19:00, but Mak Cik Salmah saw her studying at her window at 20:35.' },
  { id: 'C2', a: 'EV02', b: 'EV06', title: 'C2: Missing Blue Suitcase Claim', desc: 'EV02 claims she took her blue suitcase, but EV06 proves the suitcase stayed in her closet; only her satchel vanished.' },
  { id: 'C3', a: 'EV04', b: 'EV08', title: 'C3: Official Timeline vs 12 Oct Polaroid', desc: 'EV04 claims she cut contact after 10 Oct, but EV08 proves she was at Lot 9 on 12 Oct 2023.' },
  { id: 'C4', a: 'ST_KARIM', b: 'EV09', title: 'C4: Lot 9 Welded Shut Claim', desc: 'Pak Cik Karim claims Lot 9 was welded shut since 2018, but EV09 shows an Oct 2023 key tag.' },
  { id: 'C5', a: 'ST_HAFIZ', b: 'EV07', title: 'C5: Hafiz’s Melaka Weekend Alibi', desc: 'Hafiz claims he was in Melaka, but EV07 logs his pickup entering the orchard lane at 21:05 on 14 Oct.' },
  { id: 'C6', a: 'ST_PARENTS', b: 'EV11', title: 'C6: Exam Stress vs 2016 Cover-Up Meeting', desc: 'Parents claimed she left over exam stress with no secrets, but EV11 proves she arranged a 21:30 handover of the 2016 hit-and-run proof.' }
];

const CHARACTERS = {
  PARENTS: {
    id: 'PARENTS', name: 'Encik Osman & Puan Zainab', role: 'Sakanigadih’s Parents (Osman Residence)', state: 'REFUSING',
    statementId: 'ST_PARENTS', statementTitle: 'Parents’ Statement (Doorstep)',
    statementText: '"Our daughter left over exam stress at 19:00 with her suitcase. She had no secrets. Leave our property immediately."',
    intro: 'Encik Osman stands stiffly behind the security grille while Puan Zainab looks away. "We answered every question in 2023. She ran away because of exam pressure. Do not come back."',
    options: [
      { label: 'Ask about 14 October 2023', reply: '"She took her blue suitcase at seven in the evening and walked out. We have nothing more to say to a precinct detective." (They shut the heavy oak door.)' },
      { label: 'Present Evidence', isPresent: true }
    ],
    presentReactions: {
      default: 'Encik Osman refuses to look at the folder. "Speak to our family lawyer. This conversation is over."'
    }
  },
  SALMAH: {
    id: 'SALMAH', name: 'Mak Cik Salmah', role: 'Next-Door Neighbour (Lot 11)', state: 'COOPERATIVE',
    statementId: 'ST_SALMAH', statementTitle: 'Mak Cik Salmah’s Statement',
    statementText: '"Sakanigadih’s upstairs desk lamp was on and I clearly saw her reading at her window at 20:35 on 14 October 2023."',
    intro: 'Mak Cik Salmah waters her jasmine pots by the fence. "Ah, detective? You’re asking about Sakanigadih? Good girl—always polite, never the type to run off."',
    options: [
      { label: 'Ask about the night she vanished (14 Oct)', reply: '"I remember clearly because my favourite drama started at 8:30 PM. At 20:35, I closed my curtains and saw Sakanigadih at her upstairs window, lamp on, flipping through papers."' },
      { label: 'Ask about the Osman family', reply: '"Very proud people. After 2016, Encik Osman and his brother Karim became awfully secretive about their timber yard."'}
    ],
    presentReactions: {
      EV01: '"Seven o’clock? Nonsense! I saw her at her desk window at 20:35 with my own eyes."'
    }
  },
  TEOH: {
    id: 'TEOH', name: 'Mr. Teoh Boon Hock', role: 'Retired Grocer (Lot 16)', state: 'PARTIAL/EVASIVE',
    statementId: 'ST_TEOH', statementTitle: 'Mr. Teoh’s Statement',
    statementText: '"My corner camera faces the orchard lane junction. Once I saw the 2023 report was wrong, I checked my old delivery log—Hafiz’s silver pickup turned in at 21:05."',
    intro: 'Mr. Teoh wipes down his wooden counter, glancing nervously toward the Osman house. "Three years ago? My memory isn’t sharp, detective. Best leave rich families alone."',
    options: [
      { label: 'Ask about traffic on the orchard lane', reply: '"Cars come and go. I didn’t keep notes for the police back then, and nobody asked me anyway."' },
      { label: 'Present Evidence', isPresent: true }
    ],
    presentReactions: {
      EV01: 'Mr. Teoh frowns at the 19:00 claim. "They told the police she left at seven? That’s a lie. Wait here..." He pulls out a dusty ledger and hands you his 14 Oct junction log (EV07). State -> COOPERATIVE!',
      EV04: 'Mr. Teoh studies the official timeline and sighs. "They omitted the lane traffic completely. Take my 14 October delivery & camera log (EV07)—Hafiz’s pickup turned into the private orchard at 21:05." State -> COOPERATIVE!',
      default: 'Mr. Teoh shakes his head. "Show me what the official file claims first, detective."'
    }
  },
  AINA: {
    id: 'AINA', name: 'Aina Farhana', role: 'Childhood Best Friend', state: 'UNCOMFORTABLE',
    statementId: 'ST_AINA', statementTitle: 'Aina’s Statement',
    statementText: '"Sakanigadih called me at 20:50 on 14 Oct sounding urgent, saying she found proof of an old accident. Her blue suitcase never left her closet."',
    intro: 'Aina twists her fingers around her tote strap. "I still feel awful... I missed her call at 8:50 PM that night because my phone was on silent."',
    options: [
      { label: 'Ask about her last contact with Sakanigadih', reply: '"She called me at 20:50 on 14 October. When I called back at 21:25, it went straight to voicemail. Why would she call me at 20:50 if she supposedly ran away at 19:00?"' },
      { label: 'Present Evidence', isPresent: true }
    ],
    presentReactions: {
      EV02: 'Aina looks at the newspaper clipping and tears up. "She didn’t take her blue suitcase! I took a photo in her room two days later—here, take it (EV06)." State -> COOPERATIVE!',
      EV01: 'Aina points at the suitcase line. "That’s false. Look at the photo I took in her bedroom on 16 October (EV06)—the suitcase was still in her closet!" State -> COOPERATIVE!',
      default: 'Aina nods quietly. "She seemed scared about something she found in an old ledger."'
    }
  },
  DARIUS: {
    id: 'DARIUS', name: 'Darius Menon', role: 'Childhood Friend & Debate Teammate', state: 'COOPERATIVE',
    statementId: 'ST_DARIUS', statementTitle: 'Darius’s Statement',
    statementText: '"Sakanigadih carried her olive canvas satchel everywhere. She was working with our debate teammate Tariq Zulkifli (T.Z.) on a local history project."',
    intro: 'Darius adjusts his glasses. "I always knew the runaway story made zero sense. Sakanigadih was preparing for university scholarships."',
    options: [
      { label: 'Ask about her habits and belongings', reply: '"She never used a suitcase for anything. She carried an olive canvas satchel everywhere—for debate notes, ledgers, everything."' },
      { label: 'Ask who she worked with in October 2023', reply: '"She and our debate partner Tariq Zulkifli—everyone called him T.Z.—were digging through old town records. Here is our October debate roster (EV05). Tariq studies journalism at the university library now."' }
    ],
    presentReactions: {
      EV11: 'Darius inspects the initials "T.Z." on the letter. "That’s Tariq Zulkifli, 100%. He’s at the University Press Archive Room every evening."'
    }
  },
  KARIM: {
    id: 'KARIM', name: 'Pak Cik Karim', role: 'Uncle & Owner of Lot 9 Storage Building', state: 'PARTIAL/EVASIVE',
    statementId: 'ST_KARIM', statementTitle: 'Pak Cik Karim’s Statement',
    statementText: '"The Lot 9 storage depot has been welded shut since 2018. Sakanigadih never had a key and never went near it."',
    intro: 'Pak Cik Karim leans against his pickup outside the depot yard, eyes narrowed. "You’re poking into closed family grief, detective. There’s nothing here."',
    options: [
      { label: 'Ask about the Lot 9 Storage Building', reply: '"Lot 9 has been welded shut since 2018. Nobody goes inside, least of all my niece."' },
      { label: 'Present Evidence', isPresent: true }
    ],
    presentReactions: {
      EV09: 'Karim stares at the October 2023 brass key tag, his jaw clenching. "Where did you get that? You’re trespassing on private business. Get out of my sight!" State -> REFUSING!',
      EV08: 'Karim’s face pales as he sees the 12 Oct Polaroid outside Lot 9. "That photo proves nothing! Leave my yard now!" State -> REFUSING!',
      default: 'Karim waves a hand dismissively. "Old timber scrap. Nothing to do with my niece."'
    }
  },
  HAFIZ: {
    id: 'HAFIZ', name: 'Hafiz Osman', role: 'Older Cousin (Age 29, Osman Timber Manager)', state: 'PARTIAL/EVASIVE',
    statementId: 'ST_HAFIZ', statementTitle: 'Hafiz’s Statement',
    statementText: '"I was in Melaka all weekend on 14 October 2023. I wasn’t anywhere near the family orchard."',
    intro: 'Hafiz offers a practiced, polite smile. "Detective Lim, right? Terrible tragedy, though my cousin always was impulsive. How can I help?"',
    options: [
      { label: 'Ask where he was on 14 October 2023', reply: '"I drove down to Melaka on Friday afternoon and stayed there the entire weekend on 14 October. My schedule is spotless."' },
      { label: 'Present Evidence', isPresent: true }
    ],
    presentReactions: {
      EV07: 'Hafiz’s polite smile vanishes as he reads Mr. Teoh’s 21:05 pickup log. Sweat beads on his temple. "That... that log must have misread the plate. I’m done talking without counsel." State -> UNCOMFORTABLE!',
      EV10: 'Hafiz stares at the 2016 repair voucher, voice dropping to a hoarse whisper. "You shouldn’t be digging up 2016..." State -> UNCOMFORTABLE!',
      default: 'Hafiz forces a tight smile. "Ancient history, detective. Focus on real crime."'
    }
  },
  TARIQ: {
    id: 'TARIQ', name: 'Tariq Zulkifli', role: 'Journalism Student (Age 21) & Letter-Writer', state: 'UNCOMFORTABLE',
    statementId: 'ST_TARIQ', statementTitle: 'Tariq’s Statement',
    statementText: '"Sakanigadih planned to meet me at 21:30 on 14 Oct at Lot 14 with proof of Hafiz’s 2016 hit-and-run. When I arrived at 21:30, the shed was empty and Hafiz’s pickup was speeding away."',
    intro: 'Tariq glances anxiously toward the university archive door, clutching his press notebook. "I don’t know why you’re asking me. I barely knew her."',
    options: [
      { label: 'Ask about 14 October 2023', reply: '"Please—the Osman family owns half the timber contracts in this district. I have nothing to say."' },
      { label: 'Present Evidence', isPresent: true }
    ],
    presentReactions: {
      EV11: 'Tariq exhales shakily upon seeing his own "T.Z." letters. "You found them... Okay. She uncovered proof that Hafiz killed cyclist Encik Roslan in a drunk hit-and-run in November 2016 and her father and uncle covered it up. She asked me to meet her at 21:30 on 14 October behind the Lot 14 Orchard Tool Shed. I got there right at 21:30—she wasn’t there, her satchel strap was torn in the dirt, and Hafiz’s silver pickup was driving out of the orchard lane. I was terrified they’d come after me next." State -> COOPERATIVE!',
      default: 'Tariq shakes his head nervously. "I can’t talk unless I know you already have the proof."'
    }
  }
};

/* ============================================================================
   2. WEB AUDIO PROCEDURAL SOUND ENGINE
   ============================================================================ */
class SoundEngine {
  constructor() { this.ctx = null; this.stepTimer = 0; }
  init() {
    if (!this.ctx) this.ctx = new (window.AudioContext || window.webkitAudioContext)();
    if (this.ctx.state === 'suspended') this.ctx.resume();
  }
  playTone(freq, dur = 0.15, type = 'sine', vol = 0.12) {
    if (!this.ctx) return;
    const t = this.ctx.currentTime;
    const o = this.ctx.createOscillator();
    const g = this.ctx.createGain();
    o.type = type; o.frequency.setValueAtTime(freq, t);
    g.gain.setValueAtTime(0.001, t);
    g.gain.exponentialRampToValueAtTime(vol, t + 0.015);
    g.gain.exponentialRampToValueAtTime(0.001, t + dur);
    o.connect(g); g.connect(this.ctx.destination);
    o.start(t); o.stop(t + dur + 0.02);
  }
  paper() { this.playTone(620, 0.08, 'triangle', 0.08); this.playTone(840, 0.09, 'sine', 0.06); }
  clue() { this.playTone(440, 0.14, 'triangle', 0.12); setTimeout(() => this.playTone(587, 0.22, 'triangle', 0.12), 110); }
  step(surface = 'wood') {
    const f = surface === 'gravel' ? 145 : surface === 'concrete' ? 190 : 115;
    this.playTone(f + Math.random() * 25, 0.06, 'triangle', 0.05);
  }
}
const audio = new SoundEngine();

/* ============================================================================
   3. GAME STATE & SAVE MANAGER
   ============================================================================ */
const DEFAULT_STATE = () => ({
  night: 1,
  location: 'OFFICE',
  evidence: [],
  examined: [],
  statements: [],
  charStates: {
    PARENTS: 'REFUSING', SALMAH: 'COOPERATIVE', TEOH: 'PARTIAL/EVASIVE',
    AINA: 'UNCOMFORTABLE', DARIUS: 'COOPERATIVE', KARIM: 'PARTIAL/EVASIVE',
    HAFIZ: 'PARTIAL/EVASIVE', TARIQ: 'UNCOMFORTABLE'
  },
  links: [],
  lot9CabinetUnlocked: false,
  night5Reconstructed: false,
  finalExcavated: false,
  flags: {}
});

let state = DEFAULT_STATE();

function saveGame(msg = 'Checkpoint Saved') {
  localStorage.setItem('sakanigadih_save_v1', JSON.stringify(state));
  showToast(msg);
}
function loadGame() {
  const raw = localStorage.getItem('sakanigadih_save_v1');
  if (!raw) return false;
  state = Object.assign(DEFAULT_STATE(), JSON.parse(raw));
  return true;
}

/* ============================================================================
   4. PS1 THREE.JS RENDERER & ENVIRONMENT BUILDER
   ============================================================================ */
const canvas = document.getElementById('ps1-canvas');
const renderer = new THREE.WebGLRenderer({ canvas, antialias: false, powerPreference: 'low-power' });
renderer.setSize(320, 240, false);
renderer.shadowMap.enabled = true;
renderer.shadowMap.type = THREE.BasicShadowMap;

const scene = new THREE.Scene();
scene.fog = new THREE.FogExp2(0x090b10, 0.042);

const camera = new THREE.PerspectiveCamera(65, 320 / 240, 0.1, 65);
camera.rotation.order = 'YXZ';

const flashlight = new THREE.SpotLight(0xfff1d6, 0, 22, Math.PI / 5, 0.35, 1.2);
flashlight.castShadow = true;
camera.add(flashlight);
camera.add(flashlight.target);
flashlight.target.position.set(0, 0, -5);
scene.add(camera);

let flashlightOn = false;
function setFlashlight(on) {
  flashlightOn = on;
  flashlight.intensity = on ? 3.2 : 0;
  document.getElementById('btn-flash').textContent = `LIGHT [R]: ${on ? 'ON' : 'OFF'}`;
}

// Low-res procedural pixel texture helper
function makeTex(c1, c2, pattern = 'grid') {
  const c = document.createElement('canvas'); c.width = 32; c.height = 32;
  const g = c.getContext('2d');
  g.fillStyle = c1; g.fillRect(0, 0, 32, 32);
  g.fillStyle = c2;
  if (pattern === 'grid') {
    g.fillRect(0, 0, 32, 2); g.fillRect(0, 0, 2, 32);
  } else if (pattern === 'wood') {
    for (let y = 0; y < 32; y += 4) g.fillRect(0, y, 32, 1);
  } else if (pattern === 'brick') {
    for (let y = 0; y < 32; y += 8) { g.fillRect(0, y, 32, 1); g.fillRect((y % 16), y, 1, 8); }
  }
  const tex = new THREE.CanvasTexture(c);
  tex.magFilter = THREE.NearestFilter; tex.minFilter = THREE.NearestFilter;
  tex.wrapS = tex.wrapT = THREE.RepeatWrapping;
  return tex;
}

// PS1 Vertex Jitter Material Factory
function ps1Mat(color, tex = null) {
  const m = new THREE.MeshLambertMaterial({ color, map: tex });
  m.onBeforeCompile = (shader) => {
    shader.vertexShader = shader.vertexShader.replace(
      '#include <project_vertex>',
      `vec4 mvPosition = modelViewMatrix * vec4( transformed, 1.0 );
       gl_Position = projectionMatrix * mvPosition;
       gl_Position.xyz /= gl_Position.w;
       gl_Position.x = floor(gl_Position.x * 160.0) / 160.0;
       gl_Position.y = floor(gl_Position.y * 120.0) / 120.0;
       gl_Position.xyz *= gl_Position.w;`
    );
  };
  return m;
}

let interactables = [];
let colliders = [];
let currentSurface = 'wood';

function addBox(w, h, d, x, y, z, mat, solid = true) {
  const mesh = new THREE.Mesh(new THREE.BoxGeometry(w, h, d), mat);
  mesh.position.set(x, y, z);
  mesh.castShadow = true; mesh.receiveShadow = true;
  scene.add(mesh);
  if (solid) colliders.push({ minX: x - w / 2 - 0.35, maxX: x + w / 2 + 0.35, minZ: z - d / 2 - 0.35, maxZ: z + d / 2 + 0.35 });
  return mesh;
}

function addProp(mesh, label, action) {
  mesh.userData = { label, action };
  interactables.push(mesh);
  return mesh;
}

function addNPC(charId, x, z, shirtColor) {
  const g = new THREE.Group();
  const body = new THREE.Mesh(new THREE.BoxGeometry(0.65, 1.05, 0.38), ps1Mat(shirtColor));
  body.position.y = 0.95; body.castShadow = true;
  const head = new THREE.Mesh(new THREE.BoxGeometry(0.42, 0.44, 0.42), ps1Mat(0xd4a988));
  head.position.y = 1.72; head.castShadow = true;
  const legs = new THREE.Mesh(new THREE.BoxGeometry(0.58, 0.45, 0.34), ps1Mat(0x232733));
  legs.position.y = 0.22;
  g.add(body, head, legs);
  g.position.set(x, 0, z);
  scene.add(g);
  colliders.push({ minX: x - 0.55, maxX: x + 0.55, minZ: z - 0.55, maxZ: z + 0.55 });
  const c = CHARACTERS[charId];
  [body, head].forEach(part => addProp(part, `Talk to ${c.name}`, () => openDialogue(charId)));
  return g;
}

function buildLocation(locId) {
  state.location = locId;
  while (scene.children.length > 0) scene.remove(scene.children[0]);
  scene.add(camera);
  interactables = [];
  colliders = [];

  const woodFloor = ps1Mat(0x523b28, makeTex('#523b28', '#3c2a1b', 'wood'));
  const concFloor = ps1Mat(0x464b54, makeTex('#464b54', '#353940', 'grid'));
  const gravelFloor = ps1Mat(0x3a3833, makeTex('#3a3833', '#292722', 'grid'));
  const wallMat = ps1Mat(0x6d7278, makeTex('#6d7278', '#565a61', 'brick'));
  const deskMat = ps1Mat(0x4a321f, makeTex('#4a321f', '#362314', 'wood'));

  const buildWalls = (w, d, mat = wallMat) => {
    addBox(w, 3.6, 0.4, 0, 1.8, -d / 2, mat);
    addBox(w, 3.6, 0.4, 0, 1.8, d / 2, mat);
    addBox(0.4, 3.6, d, -w / 2, 1.8, 0, mat);
    addBox(0.4, 3.6, d, w / 2, 1.8, 0, mat);
  };

  if (locId === 'OFFICE') {
    currentSurface = 'wood';
    scene.fog.color.setHex(0x0b0e14);
    setFlashlight(false);
    addBox(12, 0.2, 11, 0, -0.1, 0, woodFloor, false);
    addBox(12, 0.2, 11, 0, 3.6, 0, ps1Mat(0x2d3138), false);
    buildWalls(12, 11);

    const amb = new THREE.AmbientLight(0x364258, 0.65); scene.add(amb);
    const lamp = new THREE.PointLight(0xffb86b, 2.2, 11); lamp.position.set(-2.2, 2.1, -2.2); lamp.castShadow = true; scene.add(lamp);

    // Noriah's Desk & Cold Case Materials
    addBox(3.2, 0.85, 1.5, -2.2, 0.42, -2.5, deskMat);
    const folder = addBox(0.65, 0.08, 0.5, -2.6, 0.89, -2.3, ps1Mat(0xc79d54), false);
    addProp(folder, 'Inspect 2023 Missing Person Report (EV01)', () => inspectEvidence('EV01'));

    const timelineDoc = addBox(0.55, 0.06, 0.45, -1.7, 0.88, -2.4, ps1Mat(0xd9d4c5), false);
    addProp(timelineDoc, 'Inspect 2023 Official Timeline (EV04)', () => inspectEvidence('EV04'));

    // Filing Cabinet (EV03)
    const cab = addBox(0.9, 1.6, 0.9, -4.6, 0.8, -3.5, ps1Mat(0x4f5b66));
    addProp(cab, 'Search Filing Cabinet Drawer (EV03)', () => inspectEvidence('EV03'));

    // Corkboard (EV02) + Case Board
    const cork = addBox(2.4, 1.3, 0.12, 1.8, 1.75, -5.2, ps1Mat(0x875c36), false);
    addProp(cork, 'Examine Newspaper Clipping (EV02)', () => inspectEvidence('EV02'));

    const board = addBox(2.8, 1.5, 0.14, 5.7, 1.75, -1.2, ps1Mat(0x283442), false);
    addProp(board, 'Open Detective Case Board', () => openCaseBoard());

    // City Travel Map Table
    addBox(2.0, 0.82, 1.4, 3.2, 0.41, 2.6, deskMat);
    const mapMesh = addBox(1.5, 0.05, 1.0, 3.2, 0.85, 2.6, ps1Mat(0x56786b), false);
    addProp(mapMesh, 'Open District Map / End Night', () => openNotebook('map'));

    // Night 3 Anonymous Polaroid under office door
    if (state.night >= 3) {
      const env = addBox(0.45, 0.03, 0.35, 0, 0.02, 4.4, ps1Mat(0xf0ece1), false);
      addProp(env, 'Pick Up Anonymous Polaroid Under Door (EV08)', () => inspectEvidence('EV08'));
    }

    camera.position.set(-2.0, 1.65, -0.6); camera.rotation.set(0, 0.25, 0);
  }
  else if (locId === 'RESIDENTIAL') {
    currentSurface = 'gravel';
    scene.fog.color.setHex(0x070a10);
    setFlashlight(true);
    addBox(26, 0.2, 22, 0, -0.1, 0, gravelFloor, false);
    buildWalls(26, 22, ps1Mat(0x242a34));

    const moon = new THREE.DirectionalLight(0x6b84b8, 0.65); moon.position.set(6, 12, 8); moon.castShadow = true; scene.add(moon);
    scene.add(new THREE.AmbientLight(0x253042, 0.55));

    // Osman Residence (Locked / Parents Refuse)
    addBox(6.5, 3.2, 5.5, -6.5, 1.6, -5.5, ps1Mat(0x7a7468));
    const door = addBox(1.2, 2.2, 0.2, -6.5, 1.1, -2.7, ps1Mat(0x4a2e1b));
    addProp(door, 'Knock on Osman Residence Door', () => openDialogue('PARENTS'));
    addNPC('PARENTS', -5.2, -2.2, 0x3b4859);

    // Mak Cik Salmah (Lot 11)
    addBox(5.2, 2.8, 4.8, 0.5, 1.4, -5.8, ps1Mat(0x667368));
    addNPC('SALMAH', 0.5, -2.5, 0x7c5278);

    // Mr. Teoh Sundry Shop (Lot 16)
    addBox(5.8, 3.0, 5.0, 7.5, 1.5, -5.2, ps1Mat(0x6c6556));
    addNPC('TEOH', 7.2, -1.8, 0x4f6d6a);

    // Friends Aina & Darius near streetlamp
    const pole = addBox(0.2, 3.5, 0.2, -1.5, 1.75, 4.2, ps1Mat(0x333842));
    const stLight = new THREE.PointLight(0xffcf87, 2.0, 12); stLight.position.set(-1.5, 3.3, 4.2); scene.add(stLight);
    addNPC('AINA', -2.8, 4.5, 0x8f5656);
    addNPC('DARIUS', -0.2, 4.6, 0x456387);

    // Return Car
    const car = addBox(2.2, 1.2, 3.8, 8.5, 0.6, 6.5, ps1Mat(0x2d3846));
    addProp(car, 'Return to Precinct 4 Office', () => buildLocation('OFFICE'));

    camera.position.set(5.5, 1.65, 6.5); camera.rotation.set(0, 0.5, 0);
  }
  else if (locId === 'DEPOT_EXT') {
    currentSurface = 'gravel';
    scene.fog.color.setHex(0x08090d);
    setFlashlight(true);
    addBox(22, 0.2, 20, 0, -0.1, 0, gravelFloor, false);
    buildWalls(22, 20, ps1Mat(0x22252b));
    scene.add(new THREE.AmbientLight(0x28303d, 0.6));

    // Lot 9 Storage Warehouse Facade
    addBox(9.5, 3.5, 6.0, 0, 1.75, -5.5, ps1Mat(0x52575e));
    const depotDoor = addBox(1.8, 2.4, 0.25, 0, 1.2, -2.4, ps1Mat(0x38434f));
    addProp(depotDoor, state.night >= 4 ? 'Unlock & Enter Lot 9 Storage Building' : 'Inspect Padlocked Lot 9 Door', () => {
      if (state.night >= 4) {
        buildLocation('LOT9');
      } else {
        showToast('Heavy steel door. You have no warrant or key to enter yet.');
      }
    });

    addNPC('KARIM', -3.2, -1.2, 0x5c5342);
    addNPC('HAFIZ', 3.4, 1.5, 0x394b5c);

    const car = addBox(2.2, 1.2, 3.8, -7.2, 0.6, 6.2, ps1Mat(0x2d3846));
    addProp(car, 'Return to Precinct 4 Office', () => buildLocation('OFFICE'));

    camera.position.set(-4.5, 1.65, 6.0); camera.rotation.set(0, -0.3, 0);
  }
  else if (locId === 'LOT9') {
    currentSurface = 'concrete';
    scene.fog.color.setHex(0x07080b);
    setFlashlight(true);
    addBox(14, 0.2, 13, 0, -0.1, 0, concFloor, false);
    addBox(14, 0.2, 13, 0, 3.6, 0, ps1Mat(0x25282e), false);
    buildWalls(14, 13, ps1Mat(0x4b4f57));
    scene.add(new THREE.AmbientLight(0x1e2430, 0.5));

    // Front Desk -> EV09 Key Tag
    addBox(2.4, 0.85, 1.2, -4.0, 0.42, -3.5, deskMat);
    const drawer = addBox(0.8, 0.35, 0.9, -3.4, 0.55, -3.4, ps1Mat(0x69472b), false);
    addProp(drawer, 'Search Desk Drawer (Key Tag EV09)', () => inspectEvidence('EV09'));

    // Hidden Canvas Stash Bag behind timber crates -> EV10 & EV11
    addBox(1.6, 1.4, 1.6, 4.5, 0.7, -4.2, ps1Mat(0x6b5335));
    const bag = addBox(0.75, 0.45, 0.55, 4.6, 0.25, -2.8, ps1Mat(0x4d593e), false);
    addProp(bag, 'Search Hidden Stash Bag (EV10 & EV11)', () => {
      inspectEvidence('EV10');
      setTimeout(() => inspectEvidence('EV11'), 400);
    });

    // Archive Crate -> EV12 Concrete-Pour Docket
    const crate = addBox(1.3, 1.0, 1.3, -4.5, 0.5, 2.5, ps1Mat(0x5c4934));
    addProp(crate, 'Search Archive File Crate (EV12)', () => inspectEvidence('EV12'));

    // Locked Metal Cabinet -> EV13 Headlamp Bezel (requires EV09 key tag!)
    const cab = addBox(1.1, 1.8, 0.8, 4.8, 0.9, 2.6, ps1Mat(0x3a434d));
    addProp(cab, 'Open Locked Metal Cabinet (EV13)', () => {
      if (!state.evidence.includes('EV09')) {
        showToast('Locked tight. Search the front desk drawer for a key.');
        return;
      }
      state.lot9CabinetUnlocked = true;
      inspectEvidence('EV13');
    });

    const exitDoor = addBox(1.4, 2.3, 0.2, 0, 1.15, 6.2, ps1Mat(0x38434f));
    addProp(exitDoor, 'Exit Lot 9 & Return to Office', () => buildLocation('OFFICE'));

    camera.position.set(0, 1.65, 4.6); camera.rotation.set(0, 0, 0);
  }
  else if (locId === 'UNIVERSITY') {
    currentSurface = 'wood';
    scene.fog.color.setHex(0x0b0d12);
    setFlashlight(false);
    addBox(12, 0.2, 11, 0, -0.1, 0, woodFloor, false);
    addBox(12, 0.2, 11, 0, 3.6, 0, ps1Mat(0x2e3138), false);
    buildWalls(12, 11, ps1Mat(0x595e68));
    scene.add(new THREE.AmbientLight(0x3b4454, 0.7));
    const lamp = new THREE.PointLight(0xffe1a8, 2.1, 12); lamp.position.set(0, 2.5, -2); scene.add(lamp);

    addBox(2.2, 2.4, 0.6, -3.8, 1.2, -4.5, deskMat);
    addBox(2.2, 2.4, 0.6, 3.8, 1.2, -4.5, deskMat);
    addBox(2.6, 0.8, 1.3, 0, 0.4, -2.2, deskMat);

    addNPC('TARIQ', 0, -3.4, 0x4b6e58);

    const door = addBox(1.3, 2.3, 0.2, 0, 1.15, 5.2, ps1Mat(0x4a321f));
    addProp(door, 'Return to Precinct 4 Office', () => buildLocation('OFFICE'));

    camera.position.set(0, 1.65, 3.6); camera.rotation.set(0, 0, 0);
  }
  else if (locId === 'LOT14') {
    currentSurface = 'concrete';
    scene.fog.color.setHex(0x06080b);
    setFlashlight(true);
    addBox(12, 0.2, 12, 0, -0.1, 0, concFloor, false);
    addBox(12, 0.2, 12, 0, 3.4, 0, ps1Mat(0x25221e), false);
    buildWalls(12, 12, ps1Mat(0x4a3b2c));
    scene.add(new THREE.AmbientLight(0x1c222c, 0.55));

    // Fresh Oct 2023 Concrete Patch in Shed Floor
    const patch = addBox(2.4, 0.06, 2.0, 0, 0.03, -2.2, ps1Mat(0x757b84), false);
    addProp(patch, 'Inspect Fresh Concrete Floor Patch (Lot 14 Shed)', () => {
      if (state.finalExcavated) {
        inspectEvidence('EV14');
        return;
      }
      state.finalExcavated = true;
      inspectEvidence('EV14');
      saveGame('Final Physical Evidence Secured');
    });

    // Burn Barrel & Timber Stack
    addBox(0.9, 1.1, 0.9, -3.6, 0.55, -3.2, ps1Mat(0x3a322d));
    addBox(2.2, 1.2, 1.4, 3.5, 0.6, -3.4, ps1Mat(0x5c4228));

    const gate = addBox(1.5, 2.3, 0.2, 0, 1.15, 5.7, ps1Mat(0x38434f));
    addProp(gate, 'Call Supt. Farahiyah & Close Case', () => {
      if (!state.finalExcavated) {
        showToast('Examine the fresh concrete patch in the tool shed floor first.');
        return;
      }
      triggerFinalCutscenes();
    });

    camera.position.set(0, 1.65, 4.2); camera.rotation.set(0, 0, 0);
  }
  updateHUD();
}

/* ============================================================================
   5. EVIDENCE VIEWER, DIALOGUE & CASE BOARD SYSTEMS
   ============================================================================ */
function collectEvidence(evId) {
  if (!state.evidence.includes(evId)) {
    state.evidence.push(evId);
    audio.clue();
    showToast(`Evidence Logged: ${EVIDENCE_DB[evId].title}`);
  }
  if (!state.examined.includes(evId)) state.examined.push(evId);
  checkNightProgression();
  updateHUD();
}

function inspectEvidence(evId) {
  collectEvidence(evId);
  audio.paper();
  const ev = EVIDENCE_DB[evId];
  let flipped = false, zoomed = false;

  const renderViewer = () => {
    const body = document.getElementById('win-body');
    if (ev.type === 'photo') {
      body.innerHTML = `
        <div style="color:var(--cyan);font-size:11.5px;margin-bottom:6px;">LOCATION: ${ev.loc} | SOURCE: ${ev.source}</div>
        <div class="photo-frame" id="photo-box" style="${zoomed ? 'transform:scale(1.14);' : ''}">
          <div class="photo-art">${flipped ? ev.backText.replace(/\n/g, '<br>') : ev.frontText}</div>
          <div style="font-size:11px;font-weight:bold;">${flipped ? '— REVERSE SIDE OF PHOTOGRAPH —' : ev.title}</div>
        </div>
        <div style="text-align:center;margin-top:12px;">
          <button class="btn primary" id="btn-flip">FLIP PHOTO (${flipped ? 'VIEW FRONT' : 'READ BACK'})</button>
          <button class="btn" id="btn-zoom">${zoomed ? 'RESET ZOOM' : 'ZOOM IN'}</button>
        </div>`;
      document.getElementById('btn-flip').onclick = () => { flipped = !flipped; audio.paper(); renderViewer(); };
      document.getElementById('btn-zoom').onclick = () => { zoomed = !zoomed; renderViewer(); };
    } else {
      body.innerHTML = `
        <div style="color:var(--cyan);font-size:11.5px;margin-bottom:6px;">LOCATION: ${ev.loc} | SOURCE: ${ev.source}</div>
        <div class="doc-sheet ${zoomed ? 'zoomed' : ''}">${ev.detail}</div>
        <button class="btn" id="btn-zoom">${zoomed ? 'RESET ZOOM' : 'ZOOM IN'}</button>`;
      document.getElementById('btn-zoom').onclick = () => { zoomed = !zoomed; renderViewer(); };
    }
  };
  openModal(`${ev.id}: ${ev.title}`, false);
  renderViewer();
}

function openDialogue(charId) {
  const c = CHARACTERS[charId];
  if (!state.statements.includes(c.statementId)) {
    state.statements.push(c.statementId);
    audio.clue();
  }
  const box = document.getElementById('dialogue');
  box.classList.add('open');
  document.getElementById('dlg-speaker').textContent = `${c.name} — ${c.role}`;
  document.getElementById('dlg-state').textContent = `ATTITUDE: ${state.charStates[charId]}`;
  document.getElementById('dlg-line').textContent = c.intro;

  const renderOpts = (presenting = false) => {
    const wrap = document.getElementById('dlg-opts');
    wrap.innerHTML = '';
    if (presenting) {
      state.evidence.forEach(evId => {
        const b = document.createElement('button');
        b.className = 'btn';
        b.textContent = `Present ${evId}: ${EVIDENCE_DB[evId].title}`;
        b.onclick = () => {
          const reaction = c.presentReactions[evId] || c.presentReactions.default;
          document.getElementById('dlg-line').textContent = reaction;
          if (charId === 'TEOH' && (evId === 'EV01' || evId === 'EV04')) {
            state.charStates.TEOH = 'COOPERATIVE';
            collectEvidence('EV07');
          }
          if (charId === 'AINA' && (evId === 'EV01' || evId === 'EV02')) {
            state.charStates.AINA = 'COOPERATIVE';
            collectEvidence('EV06');
          }
          if (charId === 'KARIM' && (evId === 'EV08' || evId === 'EV09')) {
            state.charStates.KARIM = 'REFUSING';
            state.flags.confrontedKarim = true;
          }
          if (charId === 'HAFIZ' && (evId === 'EV07' || evId === 'EV10')) {
            state.charStates.HAFIZ = 'UNCOMFORTABLE';
            state.flags.confrontedHafiz = true;
          }
          if (charId === 'TARIQ' && evId === 'EV11') {
            state.charStates.TARIQ = 'COOPERATIVE';
            state.flags.tariqCooperated = true;
            playCutscene('NIGHT 5 — TARIQ’S CONFESSION', [
              'Tariq Zulkifli lowers his voice inside the empty Press Archive Room:\n\n"Sakanigadih found the 2016 repair voucher in Pak Cik Karim’s depot. Hafiz was driving drunk on Jalan Lama Sungai on 9 November 2016 when he killed cyclist Encik Roslan—and her father and uncle scrapped the pickup to bury it."',
              '"She wrote to me so I could publish the truth. We agreed to meet at 21:30 on 14 October behind the disused Lot 14 Osman Timber Annex in the private orchard. When I arrived at 21:30, the shed was empty, her satchel strap was torn on the ground, and Hafiz’s silver pickup was speeding away."'
            ], () => {
              checkNightProgression();
              saveGame('Night 5 Truth Revealed');
            });
          }
          document.getElementById('dlg-state').textContent = `ATTITUDE: ${state.charStates[charId]}`;
          checkNightProgression();
          renderOpts(false);
        };
        wrap.appendChild(b);
      });
      const back = document.createElement('button');
      back.className = 'btn'; back.textContent = 'Back';
      back.onclick = () => renderOpts(false);
      wrap.appendChild(back);
      return;
    }

    c.options.forEach(opt => {
      const b = document.createElement('button');
      b.className = opt.isPresent ? 'btn primary' : 'btn';
      b.textContent = opt.label;
      b.onclick = () => {
        if (opt.isPresent) { renderOpts(true); return; }
        document.getElementById('dlg-line').textContent = opt.reply;
        if (charId === 'DARIUS' && opt.label.includes('October')) collectEvidence('EV05');
        checkNightProgression();
      };
      wrap.appendChild(b);
    });
    const leave = document.createElement('button');
    leave.className = 'btn'; leave.textContent = 'End Conversation';
    leave.onclick = () => box.classList.remove('open');
    wrap.appendChild(leave);
  };
  renderOpts(false);
  if (document.pointerLockElement) document.exitPointerLock();
}

/* ============================================================================
   6. CASE BOARD (PINNING, CONTRADICTION LINKING, NIGHT 5 RECONSTRUCTION)
   ============================================================================ */
let selectedNode = null;

function getAllNodes() {
  const nodes = state.evidence.map(id => ({ id, label: `${id}: ${EVIDENCE_DB[id].title}` }));
  state.statements.forEach(stId => {
    const ch = Object.values(CHARACTERS).find(c => c.statementId === stId);
    if (ch) nodes.push({ id: stId, label: `${stId}: ${ch.statementTitle}` });
  });
  return nodes;
}

function openCaseBoard() {
  openModal('PRECINCT 4 — DETECTIVE CASE BOARD', false);
  const body = document.getElementById('win-body');
  const nodes = getAllNodes();

  const renderBoard = () => {
    body.innerHTML = `
      <p style="color:var(--muted);margin-bottom:10px;">Select two pinned cards to link them and flag contradictions between statements and physical evidence.</p>
      <div class="board-wrap">
        <div>
          <h4 style="color:var(--accent);margin-bottom:6px;">PINNED EVIDENCE & STATEMENTS</h4>
          <div class="pin-list" id="pin-list"></div>
        </div>
        <div>
          <h4 style="color:var(--cyan);margin-bottom:6px;">CONFIRMED CONTRADICTIONS (${state.links.length}/6)</h4>
          <div id="link-list"></div>
          <div id="recon-zone" style="margin-top:14px;"></div>
        </div>
      </div>`;

    const pinList = document.getElementById('pin-list');
    nodes.forEach(n => {
      const div = document.createElement('div');
      div.className = 'pin-item' + (selectedNode === n.id ? ' selected' : '');
      div.textContent = n.label;
      div.onclick = () => {
        if (!selectedNode) {
          selectedNode = n.id;
        } else if (selectedNode === n.id) {
          selectedNode = null;
        } else {
          const match = CONTRADICTIONS.find(c =>
            (c.a === selectedNode && c.b === n.id) || (c.b === selectedNode && c.a === n.id)
          );
          if (match && !state.links.includes(match.id)) {
            state.links.push(match.id);
            audio.clue();
            showToast(`Contradiction Flagged: ${match.title}`);
            checkNightProgression();
          } else if (!match) {
            showToast('No direct contradiction between those two items.');
          }
          selectedNode = null;
        }
        renderBoard();
      };
      pinList.appendChild(div);
    });

    const linkList = document.getElementById('link-list');
    if (state.links.length === 0) {
      linkList.innerHTML = '<div style="color:var(--muted);font-size:12px;">No contradictions linked yet.</div>';
    } else {
      state.links.forEach(cid => {
        const c = CONTRADICTIONS.find(x => x.id === cid);
        linkList.innerHTML += `<div class="link-badge"><strong>${c.title}</strong><br>${c.desc}</div>`;
      });
    }

    // Night 5 Final Night Timeline Reconstruction
    if (state.night >= 5 && state.links.includes('C4') && state.links.includes('C6')) {
      const steps = [
        '19:00 — Parents claim Sakanigadih left with a suitcase (False)',
        '20:35 — Mak Cik Salmah sees Sakanigadih studying at her window',
        '21:05 — Hafiz’s silver pickup enters the private orchard lane',
        '21:15 — Confrontation at Lot 14; fatal fall onto survey marker',
        '21:30 — Tariq arrives at Lot 14 to an empty shed & torn strap',
        'Night — Hafiz calls Encik Osman & Pak Cik Karim; jacket burned',
        '06:15 (15 Oct) — Fresh concrete poured over Lot 14 tool shed floor',
        '08:10 (15 Oct) — Parents file fabricated runaway report'
      ];
      const rz = document.getElementById('recon-zone');
      rz.innerHTML = `<h4 style="color:var(--accent);margin-bottom:6px;">FINAL NIGHT TIMELINE RECONSTRUCTION</h4>` +
        steps.map((_, idx) => `
          <div class="recon-row">
            <span style="width:24px;color:var(--accent);">${idx + 1}.</span>
            <select id="rec-${idx}">
              <option value="-1">-- Select Event --</option>
              ${steps.map((s, si) => `<option value="${si}" ${state.night5Reconstructed && si === idx ? 'selected' : ''}>${s}</option>`).join('')}
            </select>
          </div>`).join('') +
        `<button class="btn primary" id="btn-verify-recon" style="margin-top:8px;">VERIFY RECONSTRUCTION & COMPILE REPORT</button>`;

      document.getElementById('btn-verify-recon').onclick = () => {
        let ok = true;
        for (let i = 0; i < steps.length; i++) {
          if (parseInt(document.getElementById(`rec-${i}`).value, 10) !== i) ok = false;
        }
        if (ok) {
          state.night5Reconstructed = true;
          audio.clue();
          showToast('Timeline Verified! Burial site deduced: Lot 14 Orchard Tool Shed.');
          checkNightProgression();
          renderBoard();
        } else {
          showToast('Sequence mismatch. Check timestamps from EV01, ST_SALMAH, EV07, EV11 & EV12.');
        }
      };
    }
  };
  renderBoard();
}

/* ============================================================================
   7. NOTEBOOK (EVIDENCE, STATEMENTS, TIMELINE, MAP, HINTS)
   ============================================================================ */
function openNotebook(initialTab = 'evidence') {
  openModal('DETECTIVE NORIAH LIM — CASE NOTEBOOK', true);
  const tabs = document.querySelectorAll('.tab');
  tabs.forEach(t => {
    t.classList.toggle('active', t.dataset.t === initialTab);
    t.onclick = () => openNotebook(t.dataset.t);
  });

  const body = document.getElementById('win-body');
  if (initialTab === 'evidence') {
    if (state.evidence.length === 0) {
      body.innerHTML = '<p style="color:var(--muted);">No evidence collected yet. Search the desk, cabinets, and corkboard.</p>';
      return;
    }
    body.innerHTML = `<div class="ev-grid">` + state.evidence.map(id => {
      const e = EVIDENCE_DB[id];
      return `<div class="card">
        <h4>${e.id}: ${e.title}</h4>
        <div class="meta">Night ${e.night} | ${e.loc}</div>
        <p>${e.summary}</p>
        <button class="btn" style="margin-top:8px;" onclick="window._inspect('${e.id}')">OPEN VIEWER</button>
      </div>`;
    }).join('') + `</div>`;
  }
  else if (initialTab === 'statements') {
    if (state.statements.length === 0) {
      body.innerHTML = '<p style="color:var(--muted);">No witness statements recorded yet.</p>';
      return;
    }
    body.innerHTML = state.statements.map(stId => {
      const ch = Object.values(CHARACTERS).find(c => c.statementId === stId);
      return `<div class="card" style="margin-bottom:9px;">
        <h4>${ch.name} (${state.charStates[ch.id]})</h4>
        <div class="meta">${ch.role}</div>
        <p>${ch.statementText}</p>
      </div>`;
    }).join('');
  }
  else if (initialTab === 'timeline') {
    body.innerHTML = `
      <div class="card" style="margin-bottom:8px;"><h4>09 Nov 2016</h4><p>Hit-and-run on Jalan Lama Sungai kills cyclist Encik Roslan. Osman Timber pickup repaired secretly (EV10, EV13).</p></div>
      <div class="card" style="margin-bottom:8px;"><h4>11–13 Oct 2023</h4><p>Sakanigadih accesses Lot 9 Depot (EV08, EV09) and preps debate records with Tariq Zulkifli (EV05, EV11).</p></div>
      <div class="card" style="margin-bottom:8px;"><h4>14 Oct 2023 (Night of Disappearance)</h4><p>19:00 false departure claim (EV01) vs 20:35 seen at window (ST_SALMAH) vs 21:05 Hafiz pickup on orchard lane (EV07) vs 21:30 Lot 14 meeting (EV11).</p></div>
      <div class="card"><h4>15 Oct 2023</h4><p>06:15 Concrete pour at Lot 14 Orchard Tool Shed (EV12); 08:10 parents file runaway report (EV01).</p></div>`;
  }
  else if (initialTab === 'map') {
    const locs = [
      { id: 'OFFICE', name: 'Precinct 4 Cold Case Office', unlocked: true },
      { id: 'RESIDENTIAL', name: 'Osman Residence & Neighbourhood (Lots 11–16)', unlocked: state.night >= 2 },
      { id: 'DEPOT_EXT', name: 'Lot 9 Storage Depot Exterior', unlocked: state.night >= 2 },
      { id: 'LOT9', name: 'Lot 9 Abandoned Storage Interior', unlocked: state.night >= 4 },
      { id: 'UNIVERSITY', name: 'University Press Archive (Tariq Zulkifli)', unlocked: state.night >= 5 },
      { id: 'LOT14', name: 'Lot 14 Private Orchard Tool Shed', unlocked: state.night >= 6 }
    ];
    body.innerHTML = `<p style="margin-bottom:10px;color:var(--muted);">Travel to unlocked investigation sites or conclude the current night once all leads are complete.</p>` +
      locs.map(l => `
        <div class="card" style="margin-bottom:8px;display:flex;justify-content:space-between;align-items:center;">
          <div><h4>${l.name}</h4><div class="meta">${l.unlocked ? 'ACCESSIBLE' : 'LOCKED — ADVANCE INVESTIGATION'}</div></div>
          <button class="btn ${l.unlocked ? 'primary' : ''}" ${!l.unlocked ? 'disabled' : ''} onclick="window._travel('${l.id}')">TRAVEL</button>
        </div>`).join('') +
      `<div style="margin-top:14px;"><button class="btn primary" id="btn-end-night">END NIGHT ${state.night} & SAVE CHECKPOINT</button></div>`;

    document.getElementById('btn-end-night').onclick = () => tryAdvanceNight();
  }
  else if (initialTab === 'hints') {
    const hints = {
      1: 'Examine all four items in your office: the desk folder (EV01), timeline sheet (EV04), filing cabinet (EV03), and corkboard clipping (EV02). Then open the Map tab to end Night 1.',
      2: 'Visit the Residential Street & Depot Exterior. Present EV01/EV02 to Aina and EV01/EV04 to Mr. Teoh, talk to Salmah, Darius, Karim, and Hafiz, then link C1, C2, and C5 on the Case Board.',
      3: 'Pick up the white envelope under your office door (EV08), flip the photo to read the date & Lot 9 address, then link EV04 + EV08 (C3) on the Case Board.',
      4: 'Travel to Lot 9 Storage Building. Search the front desk drawer for the key tag (EV09), search the stash bag behind the crates (EV10, EV11), check the file crate (EV12), and unlock the metal cabinet (EV13).',
      5: 'Visit the University Press Archive and present EV11 to Tariq. Confront Karim with EV09 and Hafiz with EV07. Link C4 & C6 on the Case Board and complete the 8-step Final Night Timeline.',
      6: 'Travel to Lot 14 Private Orchard Tool Shed, inspect the fresh concrete floor patch (EV14), and interact with the exit gate to report everything to Supt. Farahiyah.'
    };
    body.innerHTML = `<div class="card"><h4>NIGHT ${state.night} DETECTIVE HINT</h4><p>${hints[state.night]}</p></div>`;
  }
}

window._inspect = (id) => inspectEvidence(id);
window._travel = (loc) => { closeModal(); buildLocation(loc); };

/* ============================================================================
   8. STRICT SEQUENTIAL NIGHT GATING & CUTSCENES
   ============================================================================ */
function canAdvanceNight() {
  if (state.night === 1) return ['EV01', 'EV02', 'EV03', 'EV04'].every(id => state.evidence.includes(id));
  if (state.night === 2) return ['C1', 'C2', 'C5'].every(c => state.links.includes(c));
  if (state.night === 3) return state.evidence.includes('EV08') && state.links.includes('C3');
  if (state.night === 4) return ['EV09', 'EV10', 'EV11', 'EV12', 'EV13'].every(id => state.evidence.includes(id));
  if (state.night === 5) return state.flags.tariqCooperated && state.links.includes('C4') && state.links.includes('C6') && state.night5Reconstructed;
  return false;
}

function checkNightProgression() { updateHUD(); }

function tryAdvanceNight() {
  if (!canAdvanceNight()) {
    showToast('Leads incomplete for this night. Check the Hints tab in your Notebook.');
    return;
  }
  closeModal();
  state.night += 1;
  saveGame(`Night ${state.night} Unlocked`);

  if (state.night === 3) {
    buildLocation('OFFICE');
    playCutscene('NIGHT 3 — THE ANONYMOUS MESSAGE', [
      'Late evening at Precinct 4. Before Detective Noriah Lim can lock up for the night, a soft scrape sounds against the frosted glass door.\n\nA plain white envelope lies on the floorboards inside the threshold—addressed simply to "Det. N. Lim".'
    ], () => updateHUD());
  } else {
    buildLocation('OFFICE');
  }
}

function playCutscene(tag, slides, onDone) {
  let idx = 0;
  const cs = document.getElementById('cutscene');
  cs.classList.add('open');
  if (document.pointerLockElement) document.exitPointerLock();

  const render = () => {
    document.getElementById('cine-tag').textContent = tag;
    document.getElementById('cine-body').textContent = slides[idx];
    document.getElementById('cine-next').textContent = idx < slides.length - 1 ? 'NEXT' : 'CONTINUE';
  };
  render();
  document.getElementById('cine-next').onclick = () => {
    idx++;
    if (idx < slides.length) render();
    else { cs.classList.remove('open'); if (onDone) onDone(); }
  };
  document.getElementById('cine-skip').onclick = () => {
    cs.classList.remove('open'); if (onDone) onDone();
  };
}

function triggerFinalCutscenes() {
  playCutscene('FINAL NIGHT — REPORT TO SUPT. FARAHIYAH', [
    '02:40 AM — Lot 14 Private Orchard.\n\nForensic units under Superintendent Farahiyah cordon off the Orchard Tool Shed. Beneath the 15 October 2023 concrete slab, investigators recover the cast-iron boundary marker, charred jacket remnants, and Sakanigadih’s olive canvas satchel containing the 2016 Osman Timber repair ledger.',
    'Supt. Farahiyah reviews Detective Noriah Lim’s compiled case file:\n\n"Every timeline contradiction, Mr. Teoh’s junction log, Tariq Zulkifli’s testimony, and the physical evidence align. Warrants are issued tonight for Hafiz Osman, Encik Osman, and Pak Cik Karim—and the 2016 hit-and-run killing of Encik Roslan is officially reopened."'
  ], () => {
    playCutscene('EPILOGUE — CASE CLOSED', [
      'Two weeks later at Precinct 4 Headquarters.\n\nIn the hallway outside Major Crimes, Mrs. Halimah—the retired Lot 9 bookkeeper—quietly approaches Noriah: "I kept that 12 October Polaroid for three years waiting for someone brave enough to read the file properly."',
      'Inspector Razak and Sergeant Chong stand quietly at the back of the press room as Superintendent Farahiyah formally commends Detective Noriah Lim. Sakanigadih binti Osman is laid to rest with dignity, and both families finally receive justice.\n\nNoriah took the cold file hoping for recognition—and uncovered a truth far larger than ambition.\n\n— THE END —\nSAKANIGADIH’S DISAPPEARANCE\nCreated by Detective Narrative Systems'
    ], () => {
      document.getElementById('title-screen').style.display = 'flex';
    });
  });
}

function updateHUD() {
  const titles = {
    1: ['NIGHT 1 — THE OFFICE', 'Examine all four 2023 case documents in your office, then end Night 1 via the Map.'],
    2: ['NIGHT 2 — INITIAL INVESTIGATION', 'Interview the parents, neighbours, friends & relatives, then link C1, C2 & C5 on the Case Board.'],
    3: ['NIGHT 3 — THE ANONYMOUS MESSAGE', 'Inspect the Polaroid slipped under your office door (EV08) and link C3 on the Case Board.'],
    4: ['NIGHT 4 — LOT 9 STORAGE BUILDING', 'Search Lot 9 for the desk key tag, hidden stash bag, archive docket & locked cabinet.'],
    5: ['NIGHT 5 — THE TRUTH', 'Question Tariq at the University Archive, confront Karim & Hafiz, and reconstruct the final night on the Case Board.'],
    6: ['FINAL NIGHT — CASE CLOSURE', 'Travel to the Lot 14 Private Orchard Tool Shed, inspect the concrete patch, and report to Supt. Farahiyah.']
  };
  document.getElementById('hud-night').textContent = titles[state.night][0];
  document.getElementById('hud-loc').textContent = `Location: ${state.location} | Evidence: ${state.evidence.length}/14 | Contradictions: ${state.links.length}/6`;
  document.getElementById('hud-lead').textContent = titles[state.night][1];
}

/* ============================================================================
   9. MODAL, CONTROLS & FIRST-PERSON LOOP
   ============================================================================ */
function openModal(title, showTabs) {
  document.getElementById('overlay').classList.add('open');
  document.getElementById('win-title').textContent = title;
  document.getElementById('nb-tabs').style.display = showTabs ? 'flex' : 'none';
  if (document.pointerLockElement) document.exitPointerLock();
}
function closeModal() {
  document.getElementById('overlay').classList.remove('open');
  document.getElementById('dialogue').classList.remove('open');
}
document.getElementById('win-close').onclick = closeModal;

function showToast(msg) {
  const t = document.getElementById('toast');
  t.textContent = msg; t.classList.add('show');
  clearTimeout(window._toastT);
  window._toastT = setTimeout(() => t.classList.remove('show'), 3200);
}

const keys = {};
let yaw = 0, pitch = 0, vy = 0, grounded = true, hoveredProp = null;

window.addEventListener('keydown', e => {
  keys[e.code] = true;
  if (e.code === 'Tab') { e.preventDefault(); openNotebook('evidence'); }
  if (e.code === 'KeyR') setFlashlight(!flashlightOn);
  if (e.code === 'KeyE' && hoveredProp) hoveredProp.userData.action();
  if (e.code === 'Escape') {
    if (document.getElementById('overlay').classList.contains('open') || document.getElementById('dialogue').classList.contains('open')) {
      closeModal();
    } else if (document.getElementById('hud').style.display === 'block') {
      openPauseMenu();
    }
  }
});
window.addEventListener('keyup', e => { keys[e.code] = false; });

canvas.addEventListener('click', () => {
  if (document.getElementById('overlay').classList.contains('open') || document.getElementById('dialogue').classList.contains('open')) return;
  if (hoveredProp) { hoveredProp.userData.action(); return; }
  if (document.pointerLockElement !== canvas) canvas.requestPointerLock();
});

window.addEventListener('mousemove', e => {
  if (document.pointerLockElement === canvas) {
    yaw -= e.movementX * 0.0024;
    pitch = Math.max(-1.2, Math.min(1.2, pitch - e.movementY * 0.0024));
  }
});

function openPauseMenu() {
  openModal('PAUSED — PRECINCT 4 FIELD LOG', false);
  document.getElementById('win-body').innerHTML = `
    <p style="margin-bottom:14px;">Night ${state.night} | Evidence Collected: ${state.evidence.length}/14 | Contradictions Solved: ${state.links.length}/6</p>
    <div style="display:flex;flex-wrap:wrap;gap:10px;">
      <button class="btn primary" id="p-resume">RESUME</button>
      <button class="btn" id="p-save">SAVE CHECKPOINT</button>
      <button class="btn" id="p-dl">DOWNLOAD GAME (.HTML)</button>
      <button class="btn" id="p-title">MAIN MENU</button>
    </div>`;
  document.getElementById('p-resume').onclick = closeModal;
  document.getElementById('p-save').onclick = () => saveGame('Manual Checkpoint Saved');
  document.getElementById('p-dl').onclick = downloadSelf;
  document.getElementById('p-title').onclick = () => { closeModal(); document.getElementById('title-screen').style.display = 'flex'; };
}

function downloadSelf() {
  const blob = new Blob([document.documentElement.outerHTML], { type: 'text/html' });
  const a = document.createElement('a');
  a.href = URL.createObjectURL(blob);
  a.download = 'sakanigadih-disappearance.html';
  a.click();
}

document.getElementById('btn-nb').onclick = () => openNotebook('evidence');
document.getElementById('btn-flash').onclick = () => setFlashlight(!flashlightOn);
document.getElementById('btn-pause').onclick = openPauseMenu;
document.getElementById('btn-download-title').onclick = downloadSelf;

if (localStorage.getItem('sakanigadih_save_v1')) document.getElementById('btn-load').disabled = false;

document.getElementById('btn-start').onclick = () => {
  audio.init();
  state = DEFAULT_STATE();
  document.getElementById('title-screen').style.display = 'none';
  document.getElementById('hud').style.display = 'block';
  buildLocation('OFFICE');
  playCutscene('NIGHT 1 — PRECINCT 4 (AUTUMN 2026)', [
    'Inspector Razak tosses a dusty manila folder onto the archive cart beside Sergeant Chong:\n\n"File #2023-1014. Sakanigadih binti Osman. Three years gone, officially a runaway. Don’t waste overtime on it, Chong—the Osman family closed the book years ago."',
    'After they leave, Detective Noriah Lim pulls the folder onto her desk. Overlooked for major cases, she decides to investigate privately—searching, questioning, and checking every date they ignored.'
  ], () => saveGame('Night 1 Started'));
};

document.getElementById('btn-load').onclick = () => {
  audio.init();
  if (loadGame()) {
    document.getElementById('title-screen').style.display = 'none';
    document.getElementById('hud').style.display = 'block';
    buildLocation(state.location || 'OFFICE');
    showToast(`Loaded Night ${state.night}`);
  }
};

const raycaster = new THREE.Raycaster();
raycaster.far = 3.6;
let lastTime = performance.now();

function animate(now) {
  requestAnimationFrame(animate);
  const dt = Math.min(0.05, (now - lastTime) / 1000);
  lastTime = now;

  const blocked = document.getElementById('overlay').classList.contains('open') ||
                  document.getElementById('dialogue').classList.contains('open') ||
                  document.getElementById('cutscene').classList.contains('open') ||
                  document.getElementById('title-screen').style.display !== 'none';

  if (!blocked) {
    camera.rotation.y = yaw;
    camera.rotation.x = pitch;

    const speed = (keys['ShiftLeft'] || keys['ShiftRight']) ? 5.2 : 3.2;
    const forward = new THREE.Vector3(-Math.sin(yaw), 0, -Math.cos(yaw));
    const right = new THREE.Vector3(Math.cos(yaw), 0, -Math.sin(yaw));
    const move = new THREE.Vector3();
    if (keys['KeyW'] || keys['ArrowUp']) move.add(forward);
    if (keys['KeyS'] || keys['ArrowDown']) move.sub(forward);
    if (keys['KeyD'] || keys['ArrowRight']) move.add(right);
    if (keys['KeyA'] || keys['ArrowLeft']) move.sub(right);

    if (move.lengthSq() > 0) {
      move.normalize().multiplyScalar(speed * dt);
      const nx = camera.position.x + move.x;
      const nz = camera.position.z + move.z;
      const hitX = colliders.some(c => nx > c.minX && nx < c.maxX && camera.position.z > c.minZ && camera.position.z < c.maxZ);
      const hitZ = colliders.some(c => camera.position.x > c.minX && camera.position.x < c.maxX && nz > c.minZ && nz < c.maxZ);
      if (!hitX) camera.position.x = nx;
      if (!hitZ) camera.position.z = nz;
      audio.stepTimer += dt * speed;
      if (audio.stepTimer > 1.7) { audio.stepTimer = 0; audio.step(currentSurface); }
    }

    if (keys['Space'] && grounded) { vy = 4.6; grounded = false; }
    vy -= 12.5 * dt;
    camera.position.y += vy * dt;
    if (camera.position.y <= 1.65) { camera.position.y = 1.65; vy = 0; grounded = true; }

    raycaster.setFromCamera(new THREE.Vector2(0, 0), camera);
    const hits = raycaster.intersectObjects(interactables, false);
    hoveredProp = hits.length > 0 ? hits[0].object : null;
    const ch = document.getElementById('crosshair');
    const pr = document.getElementById('prompt');
    if (hoveredProp) {
      ch.classList.add('active');
      pr.style.display = 'flex';
      document.getElementById('prompt-txt').textContent = hoveredProp.userData.label;
    } else {
      ch.classList.remove('active');
      pr.style.display = 'none';
    }
  }

  renderer.render(scene, camera);
}
requestAnimationFrame(animate);
</script>
</body>
</html>